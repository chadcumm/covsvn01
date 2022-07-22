/**********************************************************************************
Author		 :
Date Written :  04/02/2018
Program Title:  Covenant Smart Template Demonstration
Source File	 :  cov_smrt_temp_demo.prg
Object Name	 :  cov_smrt_temp_demo
Directory	 :  cust_script
DVD version  :	2010.11.1.10
HNA version  :	01Nov2010
CCL version  :	8.6.4
Purpose      :  This smart template has been created to
                demonstrate how a smart template is
                designed.
 
Tables Read  :  person, encounter, clinical_event
Tables
Updated      :  NA
Include		 :  NA
Files
Shell        :  NA
Scripts
Executing
Application  :  Powerchart
Special Notes:  This script must be added to cs 16529.
                If the template is for PowerNotes,
                then the CKI value must be modified using the
                format "CernerClientName.CODEVALUE!########".
                servers 51, 52, and 80 should be cycled.
Usage        :  ahs_pn_inv_lines go
 
*********************************************************************
                MODIFICATION CONTROL LOG
*********************************************************************
 
 Mod   Date        Engineer          Comment
 ----  ----------- ---------------- ---------------------------
 001    04/02/18    Michael Layman  Original Release.
 
*************************************************************************************/
 
drop program cov_smrt_temp_demo go
create program cov_smrt_temp_demo
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt 	=	i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	hr			=	vc
	2	rr			=	vc
	2	sysbp		=	vc
	2	diabp		=	vc
	2	bp			=	vc
	2	temp		=	vc
)
 
 
FREE RECORD drec
RECORD drec
(
1	line_cnt		=	i4
1	display_line	=	vc
1	line_qual[*]
	2	disp_line	=	vc
)
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE hr = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'PERIPHERALPULSERATE')), PROTECT
DECLARE rr = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'RESPIRATORYRATE')), PROTECT
DECLARE temp = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURE')), PROTECT
DECLARE sysbp = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'SYSTOLICBLOODPRESSURE')), PROTECT
DECLARE diastbp = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'DIASTOLICBLOODPRESSURE')), PROTECT
DECLARE temptmpart			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURETEMPORALARTERY')), PROTECT
DECLARE temptymp			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURETYMPANIC')), PROTECT
DECLARE temporal			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATUREORAL')), PROTECT
DECLARE temprectal			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURERECTAL')), PROTECT
DECLARE tempaxillary		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATUREAXILLARY')), PROTECT
DECLARE encntrid			= F8 WITH NOCONSTANT(0.0), PROTECT
 
;RTF variables.
SET rhead   = concat('{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern Lucida Console;}}',
                  '{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134')
SET RH2r    = '\plain \f0 \fs18 \cb2 \pard\s10 '
SET RH2b    = '\plain \f0 \fs18 \b \cb2 \pard\s10 '
SET RH2bu   = '\plain \f0 \fs18 \b \ul \cb2 \pard\s10 '
SET RH2u    = '\plain \f0 \fs18 \u \cb2 \pard\s10 '
SET RH2i    = '\plain \f0 \fs18 \i \cb2 \pard\s10 '
SET REOL    = '\par '
SET Rtab    = '\tab '
SET wr      = '\plain \f0 \fs16 \cb2 '
SET ul      = '\ul '
SET wb      = '\plain \f0 \fs16 \b \cb2 '
SET wu      = '\plain \f0 \fs18 \ul \cb2 '
SET wi      = '\plain \f0 \fs18 \i \cb2 '
SET wbi     = '\plain \f0 \fs18 \b \i \cb2 '
SET wiu     = '\plain \f0 \fs18 \ul \i \cb2 '
SET wbiu    = '\plain \f0 \fs18 \b \ul \i \cb2 '
SET wbu     = '\plain \f0 \fs18 \b \ul \cb2 '
SET rtfeof  = '} '
SET bullet  = '\bullet '
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
call echo(build('hr :',hr))
call echo(build('rr :',rr))
call echo(build('temporal :',temporal))
call echo(build('sysbp :',sysbp))
call echo(build('diastbp :',diastbp))
SET encntrid = request->visit[1].encntr_id
 
CALL ECHO(encntrid)
 
SELECT into 'nl:'
 
FROM encounter e,
	 person p,
	 clinical_event ce
 
PLAN e
WHERE e.encntr_id = encntrid
;AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
;AND p.active_ind = 1
JOIN ce
WHERE p.person_id = ce.person_id
AND ce.event_cd IN (hr,rr,temporal,sysbp,diastbp)
AND e.encntr_id = ce.encntr_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
HEAD REPORT
	cnt = 0
 
HEAD e.encntr_id
	cnt = cnt + 1
 
	stat = alterlist(a->qual, cnt)
 
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid 	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->rec_cnt 				= cnt
 
 
DETAIL
	CASE (ce.event_cd)
		OF (hr):
 
			a->qual[cnt].hr = TRIM(ce.result_val)
 
		OF (rr):
 
			a->qual[cnt].rr = TRIM(ce.result_val)
 
		OF (temporal):
 
			a->qual[cnt].temp = TRIM(ce.result_val)
 
		OF (sysbp):
 
			a->qual[cnt].sysbp = TRIM(ce.result_val)
 
		OF (diastbp):
 
			a->qual[cnt].diabp = TRIM(ce.result_val)
 
	ENDCASE
 
FOOT e.encntr_id
 
if (a->qual[cnt].sysbp>' ' AND a->qual[cnt].diabp > ' ')
	a->qual[cnt].bp = CONCAT(a->qual[cnt].sysbp,'/',a->qual[cnt].diabp)
endif
 
 
WITH nocounter
 
 
;Output
 
if (a->rec_cnt > 0)
 
	SELECT into 'nl:'
 
	FROM (dummyt d with seq = a->rec_cnt)
 
	HEAD REPORT
	 idx = 0
 
	 idx = idx + 1
	 stat = alterlist(drec->line_qual, idx)
 
	 drec->line_qual[idx].disp_line = CONCAT(rhead,rh2bu,"Patient Vital Signs",wr,reol)
 
	DETAIL
 
	idx = idx + 1
	stat = alterlist(drec->line_qual, idx)
 
	drec->line_qual[idx].disp_line = CONCAT(wbu,"Heart Rate :", wr,a->qual[d.seq].hr,reol)
 
	idx = idx + 1
	stat = alterlist(drec->line_qual, idx)
 
	drec->line_qual[idx].disp_line = CONCAT(wbu,"Respiratory Rate :", wr,a->qual[d.seq].rr,reol)
 
	idx = idx + 1
	stat = alterlist(drec->line_qual, idx)
 
	drec->line_qual[idx].disp_line = CONCAT(wbu,"Temperature :", wr,a->qual[d.seq].temp,reol)
 
	idx = idx + 1
	stat = alterlist(drec->line_qual, idx)
 
	drec->line_qual[idx].disp_line = CONCAT(wbu,"Blood Pressure :", wr,a->qual[d.seq].bp,reol)
	drec->line_cnt = idx
 
	FOOT REPORT
 
	FOR (cnt = 1 to drec->line_cnt)
 
		reply->text = CONCAT(reply->text, drec->line_qual[cnt].disp_line)
 
	ENDFOR
 
	WITH nocounter
 
else
	SELECT into 'nl:'
 
	FROM (dummyt d with seq = 1)
 
	HEAD REPORT
	 idx = 0
 
	 idx = idx + 1
	 stat = alterlist(drec->line_qual, idx)
 
	 drec->line_qual[idx].disp_line = CONCAT(rhead,rh2bu,"Patient Vital Signs",wr,reol)
	 drec->line_qual[idx].disp_line = CONCAT(wr,"******* No results Qualified ********",REOL)
 
	WITH nocounter
 
 
endif
 
SET reply->text = CONCAT(reply->text, rtfeof)
 
 
CALL ECHORECORD(reply)
GO TO exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go
 

 
DROP PROGRAM cov_rad_modality_da2:DBA go
CREATE PROGRAM cov_rad_modality_da2
 
 
EXECUTE CCL_PROMPT_API_DATASET "autoset"
 
 
FREE RECORD a
RECORD a
(
1	rec_cnt = i4
1	qual[*]
	2	code_value 	=	f8
	2	display		=	vc
 
 
 
)
 
 
SET stat = alterlist(a->qual, 1)
 
SET a->qual[1].code_value = 1.00
SET a->qual[1].display = "All Modalities Except Cath Lab."
SET a->rec_cnt = 1
 
SELECT into 'nl'
 
FROM code_value cv
WHERE cv.code_set = 2057
AND cv.active_ind =1
ORDER BY cv.display
 
HEAD REPORT
 
	cnt = a->rec_cnt
 
DETAIL
	cnt = cnt + 1
	stat = alterlist(a->qual, cnt)
 
	a->qual[cnt].code_value	=	cv.code_value
	a->qual[cnt].display	=	cv.display
 
	a->rec_cnt				=	cnt
 
WITH nocounter
 
CALL ECHORECORD(a)
 
 
 
SELECT IF (CNVTINT(GetParameter("_PREPARE_")) = 1)
	with NOCOUNTER, REPORTHELP, CHECK, MAXREC = 1
ELSE
	WITH NOCOUNTER, REPORTHELP, CHECK
ENDIF
 
into 'nl:'
 	display = a->qual[d.seq].display,
 	codevalue = a->qual[d.seq].code_value
 
 
 
 
 
 
FROM (dummyt d with seq = a->rec_cnt)
 
HEAD REPORT
 
	stat = MakeDataSet(40)
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
WITH ReportHelp, Check
 
END
GO
 

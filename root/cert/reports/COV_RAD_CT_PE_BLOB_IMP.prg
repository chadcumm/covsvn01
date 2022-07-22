/***********************************************************
Author 			:	Mike Layman
Date Written	:	11/14/2018
Program Title	:	Radiology CT Thorax PE Blob Extraction Program
Source File		:	COV_RAD_CT_PE_BLOB_IMP.prg
Object Name		:	COV_RAD_CT_PE_BLOB_IMP
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to perform a blob extraction for the
					CT Thorax PE orders and to find the Impression within the report.
					The results are being used in a DA2 report so this is being setup
					as an DA2 ODA data source.
 
Tables Read		:	clinical_event, orders, encounter, ce_blob
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:
Usage			:	cov_example_rpt "mine", 555555.00, 222222.00 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release
002     04/08/2020  Dawn Greer, DBA         Changed the criteria to pull the exam
                                            start date instead of order date. 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program COV_RAD_CT_PE_BLOB_IMP go
create program COV_RAD_CT_PE_BLOB_IMP
 
prompt
	"Facility" = 2552503613.00
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
 
with facility, bdate, edate
 
EXECUTE CCL_PROMPT_API_DATASET "autoset"
 
 
 
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
	2	eventid		=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	orderid		=	f8
	2	orderdttm	=	vc
	2	ordername	=	vc
	2	blobres		=	vc
	2	impression	=	vc
	2   examstartdttm = vc 
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE CTPEOrder = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'CTTHORAXWCONFORPE')), PROTECT
DECLARE completed = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 6004,'COMPLETED')), PROTECT
DECLARE mrn = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE rpt = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'REPORT')), PROTECT
DECLARE compcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',120,'OCFCOMPRESSION')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
CALL ECHO(BUILD('CT PE Order :', CTPEOrder))
CALL ECHO(BUILD('completed :', completed))
CALL ECHO(BUILD('mrn :', mrn))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('REPORT :', rpt))
 
 
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa,
	 order_radiology ord_rad			;002 - Added table to get exam start date
PLAN o
WHERE o.catalog_cd = CTPEOrder				;002 - Removed criteria to pull order date
AND o.order_status_cd = completed
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = mrn
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN ord_rad											;002 - Added table to get exam start date
WHERE o.order_id = ord_rad.order_id	
AND ord_rad.start_dt_tm BETWEEN CNVTDATETIME($bdate)	;002 - Changed the prompts to pull by exam start date
AND CNVTDATETIME($edate)
ORDER BY o.order_id
 
 
HEAD REPORT
	cnt = 0
HEAD o.order_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].orderid	=	o.order_id
	a->qual[cnt].orderdttm	=	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].examstartdttm = FORMAT(ord_rad.start_dt_tm, "mm/dd/yyyy hh:mm;;q")	
	a->qual[cnt].ordername	=	trim(O.hna_order_mnemonic)
	a->rec_cnt				=	cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
WITH nocounter
 
 
;Get Report eventid
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 clinical_event ce,
	 ce_blob cb
PLAN d
JOIN ce
WHERE a->qual[d.seq].orderid = ce.order_id
AND ce.event_cd =    21657431.00
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN cb
WHERE ce.event_id = cb.event_id
AND cb.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
HEAD ce.event_id
 
	blobin = fillstring(32768,' ')
	blobsize = SIZE(blobin)
	rtfbsize = 0
	blobout = fillstring(32768,' ')
	bsize = 0
	blobnortf = fillstring(32768,' ')
	rval = 0
	ipos = 0
	ipos2 = 0
	ipos3 = 0
	ilen = 0
 
detail
	a->qual[d.seq].eventid = ce.event_id
 
	blobin = TRIM(cb.blob_contents)
	blobsize = SIZE(cb.blob_contents)
	if (cb.compression_cd = compcd)
 
		rval = UAR_OCF_UNCOMPRESS(blobin,blobsize,blobout,SIZE(blobout), 0)
 		;call echo(blobout)
		rval = UAR_RTF(blobout,SIZE(blobout),blobnortf,size(blobnortf),bsize,0)
 
		a->qual[d.seq].blobres = blobnortf
		;call echo(build("blobout rec :", a->qual[d.seq].blobres))
	else
 		blobout = blobin
		rval = UAR_RTF2(blobout,SIZE(blobout),blobnortf,size(blobnortf),bsize,0)
		a->qual[d.seq].blobres = blobout
	endif
 	rtfbsize = size(blobnortf)
	;find impression
	ipos = findstring('IMPRESSION',CNVTUPPER(a->qual[d.seq].blobres))
 
	if (ipos > 0)
		;ipos2 = findstring('.',a->qual[d.seq].blobres,ipos+1)
		;if (ipos2 > 0)
			a->qual[d.seq].impression = REPLACE(TRIM(substring(ipos+11,(rtfbsize - ipos + 11),a->qual[d.seq].blobres),3),
			CONCAT(CHAR(13),CHAR(10)),'')
 
 
		;endif
 
 
	endif
 
 
    blobin = fillstring(32768,' ')
	blobsize = 0
	rtfbsize = 0
	blobout = fillstring(32768,' ')
	blobnortf =fillstring(32768,' ')
	bsize = 0
 
WITH nocounter
 
 
;output
SELECT IF (CNVTINT(GetParameter("_PREPARE_")) = 1)
	with NOCOUNTER, REPORTHELP, CHECK, MAXREC = 1
ELSE
	WITH NOCOUNTER, REPORTHELP, CHECK
ENDIF
INTO "NL:"
	PatientName = CONCAT(a->qual[d.seq].name,'                                '),
	MRN = TRIM(a->qual[d.seq].mrn),
	FIN = TRIM(a->qual[d.seq].fin),
	OrderDate = a->qual[d.seq].orderdttm,
	ExamStartDate = a->qual[d.seq].examstartdttm,
	OrderProcedure = a->qual[d.seq].OrderName,
	Impression = CONCAT(a->qual[d.seq].impression,FILLSTRING(1500,' '))
 
FROM (dummyt d with seq = a->rec_cnt)
 
 
HEAD REPORT
	stat = MakeDataSet(200)
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
WITH NOCOUNTER
 
 
CALL ECHORECORD(a)
;GO TO exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go

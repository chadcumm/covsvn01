/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren
    Date Written:      May 2018
    Soluation:         Anatomic Pathology
    Source file name:  cov_rad_MissingImageURL.prg
    Object name:       cov_rad_MissingImageURL
    Layout Builder:    cov_rad_MissingImageURL_LB
    CR #:              41
 
    Program purpose:   Capture Radiology exams with missing image URLs.
 
    Executing from:    CCL.
 
    Special Notes:
 
 ******************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ******************************************************************************
 *
 *  Mod Date     Developer             Comment
 *  -----------  --------------------  ----------------------------------------
 *
 ******************************************************************************/
 
drop program cov_rad_MissingImageURL go
create program cov_rad_MissingImageURL
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "SELECT FACILITY" = 2552503649.00
	, "SELECT MODALITY" = 2553880161.00
	, "Enter a Start Date" = "SYSDATE"
	, "Enter a Ending Date" = "SYSDATE"
 
with OUTDEV, FACILITY_PMPT, IMG_ROOM_PMPT, STARTDATE_PMPT, ENDDATE_PMPT
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record rad
record rad
(
1 recordcnt	          = i4
1 facility            = c50   ;facility prompt
1 modality			  = c50   ;radiology image room
1 modality_room		  = c50	  ;radiology exam room
1 startdate           = c20	  ;start-date prompt
1 enddate             = c20	  ;end-date prompt
1 ords [*]
	2 facility		  = c20   ;facility name
	2 modality	      = c20   ;modality
	2 modality_subsec = c20   ;modality subsection
	2 modality_room   = c20   ;modality_room
	2 pat_name        = c50   ;patient name
	2 accession_nbr	  = c50   ;assession number
	2 procedure	  	  = c100  ;procedure
	2 start_dttm      = dq8   ;start datetime
	2 stop_dttm     = dq8   ;stop datetime
	2 order_dt		  = dq8   ;order date time
	2 ord_status      = c20   ;order status
	2 fin             = c20   ;fin number
	2 cmrn   		  = c20	  ;cmrn number
	2 mrn 			  = c20   ;mrn number
	2 order_id        = f8    ;order id
	2 encntr_id       = f8	  ;encounter id
	2 person_id       = f8    ;person id
)
 
;free record radrm
record radrm
(
	1	rec_cnt	=	i4
	1	qual[*]
		2	modality  = vc
		2	codevalue = f8
		2	desc	  = vc
)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare RADIOLOGY_VAR     = f8 with constant(uar_get_code_by("MEANING",6000,"RADIOLOGY")),protect
declare DEPARTMENT_VAR    = f8 with constant(uar_get_code_by("MEANING",223,"DEPARTMENT")),protect
declare RADCOMPLETED_VAR  = f8 with constant(uar_get_code_by("MEANING",14192,"RADCOMPLETED")),protect
 
declare FIN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare CMRN_VAR          = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
declare MRN_VAR           = f8 with constant(uar_get_code_by("MEANING",4,"MRN")),protect
 
declare initcap()         = c100
declare OPR_IMG_VAR	      = vc with noconstant(fillstring(1000," "))
 
if(substring(1,1,reflect(parameter(parameter2($IMG_ROOM_PMPT),0))) = "L") ;multiple rooms were selected
	set OPR_IMG_VAR = "in"
	elseif(parameter(parameter2($IMG_ROOM_PMPT),1) = 0.0) ;all (any) rooms were selected
		set OPR_IMG_VAR = "!="
	else ;a single value was selected
		set OPR_IMG_VAR = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;set rad->facility  = uar_get_code_description($FACILITY_PMPT)
;set rad->modality   = uar_get_code_description($IMG_ROOM_PMPT)
set rad->startdate = substring(1,11,$STARTDATE_PMPT)
set rad->enddate   = substring(1,11,$ENDDATE_PMPT)
 
 
/*===================================*/
/*  POPULATE RADRM RECORD STRUCTURE  */
/*===================================*/
select into 'nl:'
;	 exam_rm = uar_get_code_display(cv1.code_value )
;    ,exam_rm_cd =  cv1.code_value ;rg1.child_service_resource_cd
from
	 code_value cv
	,location l
	,service_resource sr
	,resource_group rg
	,resource_group rg1
	,resource_group rg2
	,code_value cv1
 
plan cv
	where cv.code_set = 220
		and cv.cdf_meaning = "FACILITY"
		and cv.code_value =  $FACILITY_PMPT
		and cv.active_ind = 1
 
join l
	where l.location_cd = cv.code_value
		and l.active_ind = 1
 
join sr
	where sr.organization_id = l.organization_id
;   		and sr.service_resource_type_cd = DEPARTMENT_VAR ;824
        and sr.active_ind = 1
 
join rg
	where rg.parent_service_resource_cd = sr.service_resource_cd  ;modality
		and rg.child_service_resource_cd = $IMG_ROOM_PMPT
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd  ;sub-modality
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;modality exam rooms
 
join cv1
	where cv1.code_value = rg2.child_service_resource_cd
		and cv1.cdf_meaning = "RADEXAMROOM"
 
head report
 
	cnt = 0
 
detail
	cnt = cnt + 1
	stat = alterlist(radrm->qual, cnt)
 
	radrm->qual[cnt].codevalue = rg2.child_service_resource_cd
	radrm->qual[cnt].desc      = uar_get_code_display(cv1.code_value )
	radrm->qual[cnt].modality  = uar_get_code_display(rg.child_service_resource_cd )
 
with nocounter
 
;CALL ECHORECORD(radrm)
;GO TO exitscript
 
 
;================================================
; SELECT RADIOLOGY PATIENTS
;================================================
select distinct into "NL:"
	 facility		 = uar_get_code_description(e.loc_facility_cd)
;	,modality        = uar_get_code_display(rg.child_service_resource_cd)
;	,modality_subsec = uar_get_code_display(rg1.child_service_resource_cd)
;	,modality_room   = uar_get_code_display(rg2.child_service_resource_cd)
	,pat_name  	     = initcap(p.name_full_formatted)
	,accession_nbr   = cnvtacc(ce.accession_nbr)
	,procedure       = uar_get_code_display(re.task_assay_cd)
	,start_dttm      = o.request_dt_tm
	,stop_dttm       = rr.final_dt_tm
 	,order_dt        = o.request_dt_tm
	,ord_status      = uar_get_code_display(o.exam_status_cd) ;(o.order_status_cd)
	,order_id        = o.order_id
 	,encntr_id 		 = e.encntr_id
	,person_id 		 = p.person_id
 
from
	 ORDER_RADIOLOGY  o
	,TASK_ACTIVITY    ta
	,ENCOUNTER        e
	,PERSON           p
	,CLINICAL_EVENT   ce
	,CODE_VALUE	      cv
	,LOCATION         l
    ,RAD_EXAM         re
    ,RAD_REPORT       rr
	,PRSNL_ORG_RELTN  por
	,(dummyt d1 with seq = radrm->rec_cnt)
 
plan o
	where o.start_dt_tm between cnvtdatetime($STARTDATE_PMPT) and cnvtdatetime($ENDDATE_PMPT)
;		and o.catalog_type_cd = RADIOLOGY_VAR ;2517
		and o.exam_status_cd = RADCOMPLETED_VAR ;4224
 
join ta
	where ta.order_id = o.order_id
		and ta.encntr_id = o.encntr_id
		and not exists
			;QUERY TO PULL RADIOLOGY IMAGES
			(SELECT
				null
			FROM
				clinical_event ce2
			WHERE
				ce2.parent_event_id = ta.event_id
					AND ce2.encntr_id = ta.encntr_id
					AND ce2.person_id = o.person_id
					AND ce2.event_title_text = "IMAGE")
 
join e
	where e.encntr_id = o.encntr_id
		and e.person_id = o.person_id
		and e.loc_facility_cd = $FACILITY_PMPT
		and e.loc_facility_cd in (2553765291.00, 2552503657.00, 2552503635.00, 21250403.00,
 			2552503653.00, 2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00)
		and e.active_ind = 1
		and e.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
join ce
	where ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.order_id = o.order_id
		and substring(6,2,ce.accession_nbr) not in ("CA","NP","SC")
 
join cv
    where cv.cdf_meaning = "FACILITY"
        and cv.code_value = $FACILITY_PMPT
        and cv.code_value in (2553765291.00, 2552503657.00, 2552503635.00, 21250403.00,
 			2552503653.00, 2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00)
        and cv.code_set = 220
        and cv.active_ind = 1
 
join l
    where l.location_cd = cv.code_value
        and l.active_ind = 1
 
join d1
 
join re
	where re.order_id = o.order_id
		and re.service_resource_cd = radrm->qual[d1.seq].codevalue
 
join rr
	where rr.order_id = o.order_id
 
join por  ;check user permissions
    where por.person_id = reqinfo->updt_id
	    and por.active_ind = 1
 		and por.end_effective_dt_tm >= sysdate
 
order by facility, start_dttm, pat_name, accession_nbr
 
head report
	cnt = 0
 
head e.encntr_id
	cnt = cnt + 1
	stat = alterlist(rad->ords,cnt)
 
 	rad->ords[cnt].facility      = facility
 	rad->ords[cnt].modality      = radrm->qual[d1.seq].modality
 	rad->ords[cnt].modality_room = radrm->qual[d1.seq].desc
	rad->ords[cnt].pat_name      = pat_name
	rad->ords[cnt].accession_nbr = accession_nbr
	rad->ords[cnt].procedure     = procedure
	rad->ords[cnt].start_dttm    = start_dttm
	rad->ords[cnt].stop_dttm     = stop_dttm
	rad->ords[cnt].order_dt      = order_dt
	rad->ords[cnt].ord_status    = ord_status
	rad->ords[cnt].order_id      = order_id
 	rad->ords[cnt].encntr_id     = encntr_id
	rad->ords[cnt].person_id     = person_id
 
 	rad->recordcnt = cnt
 
with nocounter
 
;call echojson(enc,"djherren.out",0) ; To see values in record structure
;call echorecord(rad)
;go to exitscript
 
;============================================================================
; SELECT PERSON & ENCOUNTER ALIAS'S: CMRN, MRN, FIN, SSN
;============================================================================
select into "NL:"
	 fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
 	,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
 	,mrn  = decode (pa2.seq, cnvtalias(pa2.alias, pa2.alias_pool_cd), '')
 
from
 	(DUMMYT        	dt with seq = value(size(rad->ords,5)))
 	,ENCOUNTER	   	e
 	,ENCNTR_ALIAS	ea 	;fin
 	,PERSON_ALIAS   pa	;cmrn
 	,PERSON_ALIAS   pa2	;mrn
 
plan dt
 
join e
	where e.encntr_id = rad->ords[dt.seq].encntr_id
		and e.active_ind = 1
		and e.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077
		and ea.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
 
join pa
	where pa.person_id = outerjoin(e.person_id)
		and pa.person_alias_type_cd = outerjoin(CMRN_VAR)    ;2
		and pa.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
 
join pa2
	where pa2.person_id = outerjoin(e.person_id)
		and pa2.person_alias_type_cd = outerjoin(MRN_VAR)     ;10
		and pa2.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
 
order dt.seq ,ea.encntr_id ,pa.person_id ,pa2.person_id
 
head dt.seq
	 rad->ords[dt.seq].fin  = fin
	 rad->ords[dt.seq].cmrn = cmrn
	 rad->ords[dt.seq].mrn  = mrn
 
with nocounter
 
;============================
; REPORT OUTPUT
;============================
if (rad->recordcnt != 0)
 
	select distinct into value ($OUTDEV)
		 facility       = rad->ords[dt.seq].facility
		,modality       = rad->ords[dt.seq].modality
		,modality_room  = rad->ords[dt.seq].modality_room
		,pat_name       = rad->ords[dt.seq].pat_name
		,accession_nbr  = rad->ords[dt.seq].accession_nbr
		,fin		    = rad->ords[dt.seq].fin
		,cmrn		    = rad->ords[dt.seq].cmrn
		,mrn		    = rad->ords[dt.seq].mrn
		,procedure      = rad->ords[dt.seq].procedure
		,start_dttm     = format(rad->ords[dt.seq].start_dttm, "mm/dd/yy hh:mm;;d")
		,stop_dttm      = format(rad->ords[dt.seq].stop_dttm, "mm/dd/yy hh:mm;;d")
		,order_dt       = format(rad->ords[dt.seq].order_dt, "mm/dd/yy hh:mm;;d")
		,ord_status     = rad->ords[dt.seq].ord_status
		,order_id       = rad->ords[dt.seq].order_id
		,encntr_id      = rad->ords[dt.seq].encntr_id
		,person_id      = rad->ords[dt.seq].person_id
;		,facility_pmpt  = rad->facility
;		,modality       = rad->modality
		,startdate_pmpt = rad->startdate
		,enddate_pmpt   = rad->enddate
 
	from
		(dummyt dt with seq = value(size(rad->ords,5)))
 
	order by order_dt desc, pat_name
;	order by fac_name, order_dt, pat_name
 
	with nocounter, format, check, separator = " "
 
endif
#exitscript
 
end
go
 
/*******************************************************************************
   A D H O C   T E S T I N G
*******************************************************************************/
/*
SELECT distinct
	 type = uar_get_code_display(o.catalog_type_cd)
	,pat_name = p.name_full_formatted
	,fin = ea.alias
	,accession_nbr = cnvtacc(ce.accession_nbr)
;	,acc = ce.accession_nbr
	,order_dt = format(o.orig_order_dt_tm, "mm/dd/yyyy HH:mm;;d") ;ce.performed_dt_tm
	,status = uar_get_code_display(o.order_status_cd)
	,zz = uar_get_code_display(ce.result_units_cd)
FROM
	 orders o
	,task_activity ta
	,encounter e
	,encntr_alias ea
	,person p
	,clinical_event ce
 
plan o
	where o.catalog_type_cd = 2517
;		and o.order_status_cd = 2543 ;Completed Status
 
join ta
	where ta.order_id = o.order_id
		and ta.encntr_id = o.encntr_id
		and not exists
			;QUERY TO PULL RADIOLOGY IMAGES
			(SELECT
				null
			FROM
				clinical_event ce2
			WHERE
				ce2.parent_event_id = ta.event_id
					AND ce2.encntr_id = ta.encntr_id
					AND ce2.person_id = o.person_id
					AND ce2.event_title_text = "IMAGE" )
 
join e
	where e.encntr_id = o.encntr_id
		and e.person_id = o.person_id
		and e.active_ind = 1
 
join ea
	where ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = 1077.00
;		and ea.alias = "1812200003" ;JOSHUS
;		and ea.alias = "1810700008" ;XSOLIS
 
join p
	where p.person_id = e.person_id
		and p.active_ind = 1
 
join ce
	where ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.order_id = o.order_id
		and substring(6,2,ce.accession_nbr) not in ("CA","NP","SC")
 
order by
	 pat_name
	,accession_nbr
with maxrec=1000,time=30
 
*/

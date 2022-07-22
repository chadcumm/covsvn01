/*************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
**************************************************************************************
	Author:				Dan Herren
	Date Written:		September 2019
	Solution:			Laboratory - General Lab
	Source file name:  	cov_ant_SpecimenRejection.prg
	Object name:		cov_ant_SpecimenRejection
	Layout file name:   N/A
	CR#:				3804
 
	Program purpose:	Usage report for Lab Cancelled/Modified Specimen Rejections.
	Executing from:		CCL
  	Special Notes:		Revised from cov_gl_cancel_rpt. Added Modify-Recollect Status
						and combined Cancelled/Modified-Recollect with status prompt
						into this new report.
 
**************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #  Mod Date    Developer           Comment
*  	----------- ----------  ------------------	---------------------------
*	001			12/2020		Dan Herren			CR 9226
*
**************************************************************************************/
 
/**************************************************************
; DVDev START CODING
**************************************************************/
drop program cov_ant_SpecimenRejection go
create program cov_ant_SpecimenRejection
 
prompt
	"Output to File/Printer/MINE" = "MINE"                  ;* Enter or select the printer or file name to send this report to.
	, "Select Status Type" = 0
	, "Select Facility" = 0
	, "Select Nursing Unit" = VALUE(1.0)
	, "Select Ordering Physician" = VALUE(1.0           )
	, "Select Cancel Reason" = VALUE(1.0           )
	, "Select the Begin Date" = "SYSDATE"
	, "Select the End Date" = "SYSDATE"
 
with OUTDEV, STATUSTYPE_PMPT, FACILITY_PMPT, UNIT_PMPT, ORDPHYS_PMPT,
	CANCELRSN_PMPT, BDATE_PMPT, EDATE_PMPT
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
free record a
record a
(
1	rec_cnt 			=	i4
1	qual[*]
	2	personid		=	f8
	2	encntrid		=	f8
	2	orderid			=	f8
	2	mrn				=	vc
	2	fin				=	vc
	2	name			=	vc
	2	testname		=	vc
	2	colldttm		=	vc
	2	collprsnl		=	vc
	2	accession		=	vc
	2	ord_loc			= 	vc
	2	orderdttm		=	vc
	2	orderphys		=	vc
	2	canceldttm		=	vc
	2	cancelprsnl		=	vc
	2	cancelrsn		=	vc
	2	col_loc			= 	vc ;001
	2	collevent		=	vc
	2	colleventdttm	=	vc
	2	viewflg			=	i2
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare EXPSZ			= i4 with constant(200), protect
declare EXPSTART 		= i4 with noconstant(1), protect
declare EXPSTOP			= i4 with noconstant(200), protect
declare ACTSZ			= i4 with noconstant(0), protect
declare EXPTOT			= i4 with noconstant(0), protect
declare INDX			= i4 with noconstant(0), protect
;
declare FIN_VAR     	= f8 with constant(uar_get_code_by('DISPLAYKEY',  319, 'FINNBR')),protect
declare CANCEL_VAR 		= f8 with constant(uar_get_code_by('DISPLAYKEY',14281, 'CANCELED')), protect
declare MODRECOL_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY', 2061, 'MODIFYRECOLLECT')), protect
declare ACTCANCEL_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY', 6003, 'CANCEL')), protect
declare ORDER_VAR 		= f8 with constant(uar_get_code_by('DISPLAYKEY', 6003, 'ORDER')), protect
declare COLLECTED_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY', 2061, 'COLLECTED')), protect ;001
declare MODIFY_VAR 		= f8 with constant(uar_get_code_by('DISPLAYKEY', 6003, 'MODIFY')), protect
declare GENLAB_VAR 		= f8 with constant(uar_get_code_by('DISPLAYKEY',  106, 'GENERALLAB')), protect
declare MICRO_VAR 		= f8 with constant(uar_get_code_by('DISPLAYKEY',  106, 'MICRO')), protect
declare BLOODBANK_VAR 	= f8 with constant(uar_get_code_by('DISPLAYKEY',  106, 'BLOODBANK')), protect
declare INDICES_VAR 	= f8 with constant(uar_get_code_by('DISPLAYKEY',  200, 'INDICES')), protect
declare AUTODIFF_VAR 	= f8 with constant(uar_get_code_by('DISPLAYKEY',  200, 'AUTOMATEDDIFF')), protect
;
declare UNIT_VAR		= vc with noconstant(fillstring(2,' ')), protect
declare PHYS_VAR		= vc with noconstant(fillstring(2,' ')), protect
declare CANCELRSN_VAR	= vc with noconstant(fillstring(2,' ')), protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;call echo(build('CANCEL_VAR     :',CANCEL_VAR))
;call echo(build('GENLAB_VAR     :',GENLAB_VAR))
;call echo(build('MICRO_VAR      :',MICRO_VAR))
;call echo(build('BLOODBANK_VAR  :',BLOODBANK_VAR))
;call echo(build('ACTCANCEL_VAR  :',ACTCANCEL_VAR))
;call echo(build('ORDER_VAR      :',ORDER_VAR))
;call echo(build('MODIFY_VAR     :',MODIFY_VAR))
;call echo(build('               :',''))
;call echo(build('OUTDEV        	:',$OUTDEV))
;call echo(build('STATUSTYPE_PMPT:',$STATUSTYPE_PMPT))
;call echo(build('FACILITY_PMPT  :',$FACILITY_PMPT))
;call echo(build('UNIT_PMPT		 :',$UNIT_PMPT))
;call echo(build('ORDPHYS_PMPT   :',$ORDPHYS_PMPT))
;call echo(build('CANCELRSN_PMPT :',$CANCELRSN_PMPT))
;call echo(build('BDATE_PMPT     :',$BDATE_PMPT))
;call echo(build('EDATE_PMPT     :',$EDATE_PMPT))
 
 
;===================================================================
; USER PROMPT SETUP
;===================================================================
;Unit
if (substring(1,1,reflect(parameter(parameter2($UNIT_PMPT),0)))="L")
	set UNIT_VAR = "IN"
elseif (parameter(parameter2($UNIT_PMPT),1) = 1.0)
	set UNIT_VAR = "!="
else
	set UNIT_VAR = "="
endif
 
;Ordering Physician
if (substring(1,1,reflect(parameter(parameter2($ORDPHYS_PMPT),0)))="L")
	set PHYS_VAR = "IN"
elseif (parameter(parameter2($ORDPHYS_PMPT),1) = 1.0)
	set PHYS_VAR = "!="
else
	set PHYS_VAR = "="
endif
 
;Cancel Reason
if (substring(1,1,reflect(parameter(parameter2($CANCELRSN_PMPT),0)))="L")
	set CANCELRSN_VAR = "IN"
elseif (parameter(parameter2($CANCELRSN_PMPT),1) = 1.0)
	set CANCELRSN_VAR = "!="
else
	set CANCELRSN_VAR = "="
endif
 
 
;===================================================================
; GET CANCELLED / MODIFIED-RECOLLECT ORDERS
;===================================================================
if ($STATUSTYPE_PMPT = 0) ;CANCELLED
	call echo('Get Cancelled Orders')
 
	select into 'nl:'
	from ORDERS	o
 
		,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
			and e.organization_id = $FACILITY_PMPT
			and operator(e.loc_nurse_unit_cd, UNIT_VAR, $UNIT_PMPT)
			and e.active_ind = 1)
 
		,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = FIN_VAR ;1077
			and ea.active_ind = 1)
 
		,(inner join PERSON p on p.person_id = e.person_id
			and p.active_ind = 1)
 
		,(inner join ACCESSION_ORDER_R aor on aor.order_id = o.order_id)
 
		,(inner join ORDER_ACTION oa on oa.order_id = o.order_id
			and oa.action_type_cd = ORDER_VAR
			and operator(oa.order_provider_id, PHYS_VAR, $ORDPHYS_PMPT))
 
		,(inner join PRSNL pr on pr.person_id = oa.order_provider_id
			and pr.active_ind = 1)
 
	where o.activity_type_cd in (GENLAB_VAR, MICRO_VAR, BLOODBANK_VAR)
		and o.dept_status_cd = CANCEL_VAR
		and o.catalog_cd not in (INDICES_VAR, AUTODIFF_VAR)
		and (o.orig_order_dt_tm between cnvtdatetime($BDATE_PMPT) and cnvtdatetime($EDATE_PMPT))
 
	head report
		cnt = 0
 
	detail
		cnt = cnt + 1
		if (mod (cnt,10) = 1 or cnt = 1)
			stat = alterlist(a->qual, cnt + 9)
		endif
 
		a->qual[cnt].personid	= p.person_id
		a->qual[cnt].encntrid	= e.encntr_id
		a->qual[cnt].name		= trim(p.name_full_formatted)
		a->qual[cnt].fin		= ea.alias
		a->qual[cnt].testname	= uar_get_code_display(o.catalog_cd)
		a->qual[cnt].accession	= cnvtacc(aor.accession)
		a->qual[cnt].ord_loc	= uar_get_code_display(e.loc_nurse_unit_cd)
;		a->qual[cnt].ord_loc	= build2(trim(uar_get_code_display(e.loc_nurse_unit_cd)),' '
;									,trim(uar_get_code_display(e.loc_room_cd)),' ', trim(uar_get_code_display(e.loc_bed_cd)))
		a->qual[cnt].orderid	= o.order_id
		a->qual[cnt].orderdttm  = format(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
		a->qual[cnt].orderphys  = trim(pr.name_full_formatted)
		a->rec_cnt				= cnt
 
	foot report
		stat = alterlist(a->qual, cnt)
 
	with nocounter
 
else ;MODIFIED-RECOLLECT
 
	call echo('Get Modified-Recollect Orders')
 
	select into 'nl:'
	from ORDERS	o
 
		,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
			and e.organization_id = $FACILITY_PMPT
			and operator(e.loc_nurse_unit_cd, UNIT_VAR, $UNIT_PMPT)
			and e.active_ind = 1)
 
		,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = FIN_VAR ;1077
			and ea.active_ind = 1)
 
		,(inner join PERSON p on p.person_id = e.person_id
			and p.active_ind = 1)
 
		,(inner join ACCESSION_ORDER_R aor on aor.order_id = o.order_id)
 
		,(inner join CONTAINER_ACCESSION ca on ca.accession = aor.accession)
 
		,(inner join CONTAINER_EVENT ce on ce.container_id = ca.container_id
			and ce.event_type_cd = MODRECOL_VAR) ;1806
 
		,(inner join ORDER_ACTION oa on oa.order_id = o.order_id
			and oa.action_type_cd = ORDER_VAR)
;			and operator(oa.order_provider_id, PHYS_VAR, $ORDPHYS_PMPT))
 
		,(inner join PRSNL pr on pr.person_id = oa.order_provider_id
			and pr.active_ind = 1)
 
	where o.activity_type_cd in (GENLAB_VAR, MICRO_VAR, BLOODBANK_VAR)
		and (o.orig_order_dt_tm between cnvtdatetime($BDATE_PMPT) and cnvtdatetime($EDATE_PMPT))
 
	head report
		cnt = 0
 
	detail
		cnt = cnt + 1
		if (mod (cnt,10) = 1 or cnt = 1)
			stat = alterlist(a->qual, cnt + 9)
		endif
 
		a->qual[cnt].personid		= p.person_id
		a->qual[cnt].encntrid		= e.encntr_id
		a->qual[cnt].name			= trim(p.name_full_formatted)
		a->qual[cnt].fin			= ea.alias
		a->qual[cnt].testname		= uar_get_code_display(o.catalog_cd)
		a->qual[cnt].accession		= cnvtacc(aor.accession)
		a->qual[cnt].ord_loc		= uar_get_code_display(e.loc_nurse_unit_cd)
;		a->qual[cnt].ord_loc		= build2(trim(uar_get_code_display(e.loc_nurse_unit_cd)),' '
;										,trim(uar_get_code_display(e.loc_room_cd)),' ', trim(uar_get_code_display(e.loc_bed_cd)))
		a->qual[cnt].orderid		= o.order_id
		a->qual[cnt].orderdttm  	= format(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
		a->qual[cnt].orderphys  	= trim(pr.name_full_formatted)
		a->qual[cnt].collevent		= uar_get_code_display(ce.event_type_cd)
		a->qual[cnt].colleventdttm	= format(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
		a->rec_cnt					= cnt
 
	foot report
		stat = alterlist(a->qual, cnt)
 
	with nocounter
 
endif
 
;call echorecord(a)
;go to exitscript
 
;===================================================================
; GET CANCELLED ORDER ACTION PERSONNEL INFO
;===================================================================
if ($STATUSTYPE_PMPT = 0) ;CANCELED
	call echo('Get Cancel Action Personnel Info')
 
	;Set Up Expand
	set ACTSZ = a->rec_cnt
	set EXPTOT = ACTSZ + (EXPSZ - mod(ACTSZ,EXPSZ))
 
;	call echo(build('ACTSZ  :', ACTSZ))
;	call echo(build('EXPSZ  :', EXPSZ))
;	call echo(build('EXPTOT :', EXPTOT))
 
	set stat = alterlist(a->qual, EXPTOT)
 
	for (idx = ACTSZ+1 to EXPTOT)
		set a->qual[idx].orderid = a->qual[ACTSZ].orderid
	endfor
 
 
	select into 'nl:'
	from (DUMMYT 		d with seq = EXPTOT/EXPSZ)
		 ,ORDER_ACTION	oa
		 ,PRSNL 		pr
 
	plan d
		where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
		and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
 
	join oa
		where expand(INDX,EXPSTART,EXPSTOP,oa.order_id,a->qual[INDX].orderid)
		and oa.action_type_cd = ACTCANCEL_VAR
 
	join pr
		where oa.action_personnel_id = pr.person_id
 
	head report
		;stat = alterlist(a->qual, ACTSZ)
		pos = 0
		idx = 0
 
	head oa.order_id
		pos = locateval(idx,1,a->rec_cnt,oa.order_id,a->qual[idx].orderid)
 
	detail
		a->qual[pos].cancelprsnl = trim(pr.name_full_formatted)
		a->qual[pos].canceldttm  = FORMAT(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;q")
 
	foot oa.order_id
		pos = 0
		idx = 0
 
	foot report
		stat = alterlist(a->qual, ACTSZ)
 
	with nocounter
endif
 
 
;===================================================================
; GET COLLECTION TIME
  call echo ('Get Collection Time/Personnel')
;===================================================================
;Set Up Expand
set INDX = 0
set ACTSZ = a->rec_cnt
set EXPTOT = ACTSZ + (EXPSZ - mod(ACTSZ,EXPSZ))
 
;call echo(build('ACTSZ :', ACTSZ))
;call echo(build('EXPSZ :', EXPSZ))
;call echo(build('EXPTOT :', EXPTOT))
 
set stat = alterlist(a->qual, EXPTOT)
 
for (idx = ACTSZ+1 to EXPTOT)
	set a->qual[idx].orderid = a->qual[ACTSZ].orderid
endfor
 
select into 'nl:'
from (DUMMYT 			d with seq = EXPTOT/EXPSZ)
	 ,ORDER_CONTAINER_R	ocr
	 ,CONTAINER 		c
	 ,PRSNL 			pr
 
plan d
	where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
	and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
 
join ocr
	where expand(INDX,EXPSTART,EXPSTOP,ocr.order_id,a->qual[INDX].orderid)
 
join c
	where ocr.container_id = c.container_id
 
join pr
	where c.drawn_id = pr.person_id
 
head report
	pos = 0
	idx = 0
 
head ocr.order_id
	pos = locateval(idx,1,a->rec_cnt,ocr.order_id,a->qual[idx].orderid)
 
detail
	a->qual[pos].colldttm 	= FORMAT(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[pos].collprsnl	= trim(pr.name_full_formatted)
 
foot ocr.order_id
	pos = 0
	idx = 0
 
foot report
	stat = alterlist(a->qual, ACTSZ)
 
with nocounter
 
 
;===================================================================
; GET CANCEL REASON
;===================================================================
if ($STATUSTYPE_PMPT = 0) ;CANCELED
	call echo('Getting Cancel Reason')
 
	;Set Up Expand
	set INDX = 0
	set ACTSZ = a->rec_cnt
	set EXPTOT = ACTSZ + (EXPSZ - mod(ACTSZ,EXPSZ))
 
;	call echo(build('ACTSZ :', ACTSZ))
;	call echo(build('EXPSZ :', EXPSZ))
;	call echo(build('EXPTOT :', EXPTOT))
 
	set stat = alterlist(a->qual, EXPTOT)
 
	for (idx = ACTSZ+1 to EXPTOT)
		set a->qual[idx].orderid = a->qual[ACTSZ].orderid
	endfor
 
 
	select into 'nl:'
	from (DUMMYT 		d with seq = EXPTOT/EXPSZ)
		 ,ORDER_DETAIL	od
 
	plan d
		where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
		and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
 
	join od
		where expand(INDX,EXPSTART,EXPSTOP,od.order_id,a->qual[INDX].orderid)
		and od.oe_field_meaning = 'CANCELREASON'
		and operator(od.oe_field_value,CANCELRSN_VAR,$CANCELRSN_PMPT)
 
	head report
		pos = 0
		idx = 0
 
	head od.order_id
		pos = locateval(idx,1,a->rec_cnt,od.order_id, a->qual[idx].orderid)
 
	detail
		a->qual[pos].cancelrsn = trim(od.oe_field_display_value)
		a->qual[pos].viewflg = 1
 
	foot od.order_id
		pos = 0
		idx = 0
 
	foot report
		stat = alterlist(a->qual, ACTSZ)
 
		for (icnt = 1 to A->rec_cnt)
			if ($CANCELRSN_PMPT = 1.0)
				if (SIZE(a->qual[icnt].cancelrsn) = 0)
					a->qual[icnt].viewflg = 1
				endif
			endif
		endfor
 
	with nocounter
endif
 
 
;===================================================================
; GET ORDERING LOCATION
  call echo ('Get Ordering Location')
;===================================================================
;set up expand
set INDX = 0
set ACTSZ = a->rec_cnt
set EXPTOT = ACTSZ + (EXPSZ - mod(ACTSZ,EXPSZ))
 
;call echo(build('ACTSZ :', ACTSZ))
;call echo(build('EXPSZ :', EXPSZ))
;call echo(build('EXPTOT :', EXPTOT))
 
set stat = alterlist(a->qual, EXPTOT)
 
for (idx = ACTSZ+1 to EXPTOT)
	set a->qual[idx].orderid = a->qual[ACTSZ].orderid
endfor
 
 
select into 'nl:'
from (DUMMYT 			d with seq = EXPTOT/EXPSZ)
	 ,ORDERS			o
	 ,ENCOUNTER			e
	 ,ENCNTR_LOC_HIST	elh
 
plan d
	where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
	and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
 
join o
	where expand(INDX,EXPSTART,EXPSTOP,o.order_id,a->qual[INDX].orderid)
 
join e
	where e.encntr_id = o.encntr_id
 
join elh
	where elh.encntr_id = o.encntr_id
	and (o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
 
;select into 'nl:'
;	 ord_loc = od.oe_field_display_value
;from (DUMMYT 			d with seq = EXPTOT/EXPSZ),
;	 ORDER_DETAIL		od
;plan d
;	where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
;	and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
;join od
;	where expand(INDX,EXPSTART,EXPSTOP,od.order_id,a->qual[INDX].orderid)
; 		and od.oe_field_meaning = 'ORDERLOC'
 
head report
	pos = 0
	idx = 0
 
head o.order_id
	pos = locateval(idx,1,a->rec_cnt,o.order_id,a->qual[idx].orderid)
 
	a->qual[pos].ord_loc = uar_get_code_display(elh.loc_nurse_unit_cd)
 
foot o.order_id
	pos = 0
	idx = 0
 
foot report
	stat = alterlist(a->qual, ACTSZ)
 
with nocounter
 
;begin 001
;===================================================================
; GET COLLECTION LOCATION
  call echo ('Get Collection Location')
;===================================================================
;set up expand
set INDX = 0
set ACTSZ = a->rec_cnt
set EXPTOT = ACTSZ + (EXPSZ - mod(ACTSZ,EXPSZ))
 
;call echo(build('ACTSZ :', ACTSZ))
;call echo(build('EXPSZ :', EXPSZ))
;call echo(build('EXPTOT :', EXPTOT))
 
set stat = alterlist(a->qual, EXPTOT)
 
for (idx = ACTSZ+1 to EXPTOT)
	set a->qual[idx].orderid = a->qual[ACTSZ].orderid
endfor
 
 
select into 'nl:'
from (DUMMYT 				d with seq = EXPTOT/EXPSZ)
	 ,ORDERS				o
	 ,ACCESSION_ORDER_R		aor
	 ,CONTAINER_ACCESSION	ca
	 ,CONTAINER_EVENT		ce
 
plan d
	where assign(EXPSTART,evaluate(d.seq,1,1,EXPSTART+EXPSZ))
	and assign(EXPSTOP,EXPSTART+(EXPSZ-1))
 
join o
	where expand(INDX,EXPSTART,EXPSTOP,o.order_id,a->qual[INDX].orderid)
 
join aor
	where aor.order_id = o.order_id
 
join ca
	where ca.accession = aor.accession
 
join ce
	where ce.container_id = ca.container_id
			and ce.event_type_cd = COLLECTED_VAR ;1794
 
head report
	pos = 0
	idx = 0
 
head o.order_id
	pos = locateval(idx,1,a->rec_cnt,o.order_id,a->qual[idx].orderid)
 
	a->qual[pos].col_loc = uar_get_code_display(ce.current_location_cd)
 
foot o.order_id
	pos = 0
	idx = 0
 
foot report
	stat = alterlist(a->qual, ACTSZ)
 
with nocounter
;end 001
 
;===================================================================
; REPORT OUTPUT
;===================================================================
if ($STATUSTYPE_PMPT = 0) ;CANCELLED
 	if (a->rec_cnt > 0)
		select distinct into $outdev
			OrderLoc			= substring(1,30,trim(a->qual[d.seq].ord_loc)),
			PatientName 		= substring(1,35,a->qual[d.seq].name),
			FIN					= substring(1,30,a->qual[d.seq].fin),
			AccessionNbr 		= substring(1,30,a->qual[d.seq].accession),
			TestName 			= substring(1,50,trim(a->qual[d.seq].testname)),
;			OrderDateTime		= substring(1,30,a->qual[d.seq].orderdttm),
			CollectLoc			= substring(1,30,trim(a->qual[d.seq].col_loc)), ;001
			CollectedBy 		= substring(1,30,a->qual[d.seq].collprsnl),
			CollectedDateTime	= substring(1,30,a->qual[d.seq].colldttm),
			CancelledDateTime 	= substring(1,30,a->qual[d.seq].canceldttm),
			CancelledReason 	= substring(1,50,a->qual[d.seq].cancelrsn)
 
		from (DUMMYT d with seq = a->rec_cnt)
 
		where a->qual[d.seq].viewflg = 1
 
		order by OrderLoc, PatientName, AccessionNbr, TestName
 
		with nocounter, format, separator = ' '
 	endif
 
else ;MODIFIED-RECOLLECT
 
 	if (a->rec_cnt > 0)
		select distinct into $outdev
			OrderLoc			= substring(1,30,a->qual[d.seq].ord_loc),
			PatientName 		= substring(1,35,a->qual[d.seq].name),
			FIN					= substring(1,30,a->qual[d.seq].fin),
			AccessionNbr 		= substring(1,30,a->qual[d.seq].accession),
;			OrderDateTime		= substring(1,30,a->qual[d.seq].orderdttm),
;			Event				= substring(1,30,a->qual[d.seq].collevent),
			CollectLoc			= substring(1,30,a->qual[d.seq].col_loc), ;001
			EventDtTm			= substring(1,30,a->qual[d.seq].colleventdttm)
 
		from (DUMMYT d with seq = a->rec_cnt)
 
		order by PatientName, AccessionNbr, EventDtTm
 
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

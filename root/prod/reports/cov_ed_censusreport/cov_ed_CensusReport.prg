/***********************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 ***********************************************************************************
 
    Author:            Dan Herren
    Date Written:      November 2017
    Soluation:         Emergency Medicine / FirstNet
    Source file name:  cov_ed_CensusReport.prg
    Object name:       cov_ed_CensusReport
    Request #:         2
 	CR #:			   523
 
    Program purpose:   Census report to allow user to run report on demand.
    				   Report also include disposition condition.
 
    Executing from:    CCL.
 
    Special Notes:
 
 ***********************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ***********************************************************************************
 *
 *  Revision #   Mod Date    Developer         Comment
 *  -----------  ----------  ----------------  ----------------------------
 *	001          09/10/2010	 Dan Herren 	   COMMENTED OUT LINE.  WRONGLY INCLUDED
 *	002			 10/02/2018	 Dan Herren		    Added do_var to include DO providers
 ***********************************************************************************/
 
drop program cov_ed_CensusReport go
create program cov_ed_CensusReport
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FACILITY" = 0
	, "ED AREA" = 2553914297.00
	, "DISPOSITION TO" = VALUE(0.0)
	, "CHECK-IN DATE RANGE" = "SYSDATE"
	, "" = "SYSDATE"
	, "AGE GROUP" = 3
 
with OUTDEV, FACILITY_PMPT, ED_AREA_PMPT, DISPOSITION_TO_PMPT, STARTDATE_PMPT,
	ENDDATE_PMPT, AGE_PMPT
 
 
/**************************************************************
; DVDev declareD SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record enc
;;;record ed
;;;(
;;;1 area              = f8    ;facility name (nursing unit)
;;;1 room_cnt			= i4
;;;1 list [*]
;;;	2 room          = f8	;ed room
;;;	2 fac_ed_area   = f8    ;ea area
;;;	2 roomdesc		= vc
;;;	2 meaning		= vc
;;;)
 
record enc
(
1 recordcnt	        = i4
1 startdate         = c50
1 enddate           = c50
1 list [*]
	2 fac_name      = c50    ;facility name
	2 fac_abbr 	    = c10    ;facility abbr
	2 fac_unit      = c50    ;facility unit
	2 fac_room		= c50	 ;facility room
	2 fac_group     = c50    ;facility group
	2 fac_ed_area   = c50    ;facility ed area
	2 chkin_dt	    = dq8    ;check in date
	2 chkout_dt     = dq8    ;check out date
	2 age		    = c10    ;age
	2 pat_name	 	= c50    ;patient name
	2 birthdate	    = dq8    ;birth date
	2 sex		    = c10    ;male, female etc.
	2 rfv_cc_dx	    = c100   ;reason for visit (chief complaint dx)
	2 provider	    = c50    ;ER doctor
	2 er_nurse	    = c50    ;ER nurse
	2 los_hrs	    = f8     ;length-of-stay hours
	2 encntr_type   = c50    ;encounter type
;-------
	2 dispo_type    = c100	 ;disposition (LWBS,AMA, etc...)
	2 dispo_od_cond	= c100	 ;disposition condition found in order detail for admit / dc orders
	2 dispo_ce_cond	= c100	 ;dispo cond for transfered patients. charted in clinical_event table
	2 dispo_cond	= c100   ;disposition condition (location)
	2 dispo_to      = c50    ;disposition to (admit, discharge, transfer)
;-------
	2 final_dx	    = c255   ;discharge/final dx
;-------
	2 cmrn		    = c20    ;community mrn
	2 mrn		    = c20    ;facility mrn
	2 fin		    = c20    ;encounter FIN
;-------
	2 person_id     = f8     ;PID
	2 encntr_id     = f8     ;EID
)
 
record out
(
1 recordcnt	        = i4
1 startdate         = c50
1 enddate           = c50
1 list [*]
	2 fac_name      = c50    ;facility name
	2 fac_abbr 	    = c10    ;facility abbr
	2 fac_unit      = c50    ;facility unit
	2 fac_room		= c50	 ;facility room
	2 fac_group     = c50    ;facility group
	2 fac_ed_area   = c50    ;facility ed area
	2 chkin_dt	    = dq8    ;check in date
	2 chkout_dt     = dq8    ;check out date
	2 age		    = c10    ;age
	2 pat_name	 	= c50    ;patient name
	2 birthdate	    = dq8    ;birth date
	2 sex		    = c10    ;male, female etc.
	2 rfv_cc_dx	    = c100   ;reason for visit (chief complaint dx)
	2 provider	    = c50    ;ER doctor
	2 er_nurse	    = c50    ;ER nurse
	2 los_hrs	    = f8     ;length-of-stay hours
	2 encntr_type   = c50    ;encounter type
;-------
	2 dispo_type    = c100	 ;disposition (LWBS,AMA, etc...)
	2 dispo_od_cond	= c100	 ;disposition condition found in order detail for admit / dc orders
	2 dispo_ce_cond	= c100	 ;dispo cond for transfered patients. charted in clinical_event table
	2 dispo_cond	= c100   ;disposition condition (location)
	2 dispo_to      = c50    ;disposition to (admit, discharge, transfer)
;-------
	2 final_dx	    = c255   ;discharge/final dx
;-------
	2 cmrn		    = c20    ;community mrn
	2 mrn		    = c20    ;facility mrn
	2 fin		    = c20    ;encounter FIN
;-------
	2 person_id     = f8     ;PID
	2 encntr_id     = f8     ;EID
)
 
/**************************************************************
; DVDev declareD VARIABLES
**************************************************************/
declare FAC_VAR            = vc with noconstant(fillstring(1000," "))
declare AGE_VAR            = vc with noconstant(fillstring(1000," "))
;declare OPR_FAC_VAR	   = vc with noconstant(fillstring(1000," "))
declare OPR_EDAREA_VAR	   = vc with noconstant(fillstring(1000," "))
;declare OPR_DISPO_TYPE_VAR = vc with noconstant(fillstring(1000," "))
declare OPR_DISPO_TO_VAR   = vc with noconstant(fillstring(1000," "))
;
declare FAC_FLMC_VAR      = f8 set FAC_FLMC_VAR = 2552503635.00
declare FAC_FSR_VAR       = f8 set FAC_FSR_VAR	=   21250403.00
declare FAC_LCMC_VAR      = f8 set FAC_LCMC_VAR	= 2552503653.00
declare FAC_MHHS_VAR      = f8 set FAC_MHHS_VAR	= 2552503639.00
declare FAC_MMC_VAR       = f8 set FAC_MMC_VAR	= 2552503613.00
declare FAC_PWMC_VAR      = f8 set FAC_PWMC_VAR	= 2552503645.00
declare FAC_RMC_VAR       = f8 set FAC_RMC_VAR  = 2552503649.00
;
declare FLMC_TRKGRP_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FLMCEDTRACKINGGROUP")),protect
declare FSR_TRKGRP_VAR    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FSREDTRACKINGGROUP")),protect
declare LCMC_TRKGRP_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"LCMCEDTRACKINGGROUP")),protect
declare MHHS_TRKGRP_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MHHSEDTRACKINGGROUP")),protect
declare MMC_TRKGRP_VAR    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MMCEDTRACKINGGROUP")),protect
declare PWMC_TRKGRP_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"PWMCEDTRACKINGGROUP")),protect
declare RMC_TRKGRP_VAR    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"RMCEDTRACKINGGROUP")),protect
 
;staff assignments
DECLARE mdir_var			 = f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",88,"EMERGENCYMEDICINEMEDICALDIRECTOR")),protect
DECLARE md_var				 = f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",88,"PHYSICIANEMERGENCYMEDICINE")),protect
DECLARE pa_var				 = f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",88,"EMERGENCYMEDICINEPHYSICIANASSISTANT")),protect
DECLARE np_var				 = f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",88,"EMERGENCYMEDICINENURSEPRACTITIONER")),protect
 
;
declare FIN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare MRN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"MRN")),protect
declare CMRN_VAR          = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
;
declare RFV_CC_DX_VAR     = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",17,"REASONFORVISIT")),PROTECT	;cheif complaint
declare EMERGENCY_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",71,"EMERGENCY")),protect
declare DIAG_DISCH_VAR    = f8 with constant(uar_get_code_by("MEANING",17,"DISCHARGE")),protect
declare ICD10CM_VAR	 	  = f8 with constant(uar_get_code_by_CKI("CKI.CODEVALUE!4101498946")),protect
;
declare DISPO_COND_ADMIT_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTOADMIT")),protect
declare DISPO_COND_DISCH_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTODISCHARGE")),protect
 
;TRANSFER PATIENT CONDITION
declare dispo_pat_cond_var   = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",72,"PATIENTCONDITIONDISPOSITION")),PROTECT
;declare DISPO_CE_COND_VAR    = f8 with CONSTANT (UAR_GET_CODE_BY("DISPLAY_KEY",72,"EMTALAPATIENTCONDITION")),PROTECT
 
;ADMIT / DISCHARGE PATIENT CONDITION
declare DISPO_OD_COND_VAR    = f8 with CONSTANT (UAR_GET_CODE_BY("DISPLAY_KEY",106,"ADMITTRANSFERDISCHARGE")),PROTECT
 
;declare DISPO_TYPE_VAR       = f8 with CONSTANT (UAR_GET_CODE_BY("DISPLAY_KEY",72,"DISCHARGEDTOCAREOF")),PROTECT
;
declare initcap() = c100
declare	idx       = i4
declare num		  = i4 with noconstant(0)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
set enc->startdate = $STARTDATE_PMPT;substring(1,11,$STARTDATE_PMPT)
set enc->enddate   = $ENDDATE_PMPT;substring(1,11,$ENDDATE_PMPT)
;set  ed->area      = $ED_AREA_PMPT(ED_AREA_CD)
 
; Set Facility Variable
case ($FACILITY_PMPT)
	of  FAC_FLMC_VAR  : set FAC_VAR = build2("tc.tracking_group_cd = ", FLMC_TRKGRP_VAR)
	of  FAC_FSR_VAR   : set FAC_VAR = build2("tc.tracking_group_cd = ", FSR_TRKGRP_VAR)
	of  FAC_LCMC_VAR  : set FAC_VAR = build2("tc.tracking_group_cd = ", LCMC_TRKGRP_VAR)
	of  FAC_MHHS_VAR  : set FAC_VAR = build2("tc.tracking_group_cd = ", MHHS_TRKGRP_VAR)
	of  FAC_MMC_VAR   : set FAC_VAR = build2("tc.tracking_group_cd = ", MMC_TRKGRP_VAR)
	of  FAC_PWMC_VAR  : set FAC_VAR = build2("tc.tracking_group_cd = ", PWMC_TRKGRP_VAR)
	of  FAC_RMC_VAR  :  set FAC_VAR = build2("tc.tracking_group_cd = ", RMC_TRKGRP_VAR)
	else                set FAC_VAR = build2("tc.tracking_group_cd = ", "")
endcase
 
;if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L") ;multiple facilities were selected
;	set OPR_FAC_VAR = "in"
;	elseif(parameter(parameter2($FACILITY_PMPT),1) = 0.0) ;all (any) facilities were selected
;		set OPR_FAC_VAR = "!="
;	else ;a single value was selected
;		set OPR_FAC_VAR = "="
;endif
 
/*============================================================*/
; Set ED Area Variable
;;;if(substring(1,1,reflect(parameter(parameter2($ED_AREA_PMPT),0))) = "L") ;multiple facilities were selected
;;;	set OPR_EDAREA_VAR = "in"
;;;	elseif(parameter(parameter2($ED_AREA_PMPT),1) = 0.0) ;all (any) facilities were selected
;;;		set OPR_EDAREA_VAR = "!="
;;;	else ;a single value was selected
;;;		set OPR_EDAREA_VAR = "="
;;;endif
 
 
/*============================================================*/
 
; Set Disposition Type Variable
;if(substring(1,1,reflect(parameter(parameter2($DISPOSITION_TYPE_PMPT),0))) = "L") ;multiple dispositions were selected
;	set OPR_DISPO_TYPE_VAR = "in"
;	elseif(parameter(parameter2($DISPOSITION_TYPE_PMPT),1) = 0.0) ;all (any) dispositions were selected
;		set OPR_DISPO_TYPE_VAR = "!="
;	else ;a single value was selected
;		set OPR_DISPO_TYPE_VAR = "="
;endif
 
/*============================================================*/
 
; Set Disposition-To Variable
if(substring(1,1,reflect(parameter(parameter2($DISPOSITION_TO_PMPT),0))) = "L") ;multiple dispositions were selected
	set OPR_DISPO_TO_VAR = "in"
	elseif(parameter(parameter2($DISPOSITION_TO_PMPT),1) = 0.0) ;all (any) dispositions were selected
		set OPR_DISPO_TO_VAR = "!="
	else ;a single value was selected
		set OPR_DISPO_TO_VAR = "="
endif
 
/*============================================================*/
 
; Set Age Variable
case($AGE_PMPT)
	of 1 : set AGE_VAR = "datetimediff(tc.checkin_dt_tm, p.birth_dt_tm) >= (18.0*365.25)" ;Adults
	of 2 : set AGE_VAR = "datetimediff(tc.checkin_dt_tm, p.birth_dt_tm) <  (18.0*365.25)" ;Pediatrics
	else   set AGE_VAR = "datetimediff(tc.checkin_dt_tm, p.birth_dt_tm) > 0"              ;Both
endcase
 
/*============================================================*/
 
;================================================
; SELECT NURSE UNIT ROOMS
;================================================
;;;select
;;;;	room_cd = f.loc_room_cd
;;;from
;;;	 LOCATION_GROUP l
;;;	,LOCATION_GROUP lg
;;;	,code_value cv
;;;
;;;plan l
;;;	where l.location_group_type_cd = 796  ;patient tracking view
;;;; 		and l.root_loc_cd =  $ED_AREA_PMPT
;;; 		and operator(l.root_loc_cd, OPR_EDAREA_VAR, $ED_AREA_PMPT)
;;;join lg
;;;	where lg.root_loc_cd = l.root_loc_cd
;;;		and lg.location_group_type_cd IN (794, 772) ;nursing unit (ed area)
;;;
;;;join cv
;;;where lg.child_loc_cd = cv.code_value
;;;	and cv.active_ind = 1
;;;
;;;order by lg.root_loc_cd
;;;
;;;head report
;;;	cnt = 0
;;;	ed->area = l.root_loc_cd
;;;
;;;detail
;;;	cnt = cnt + 1
;;;	ed->room_cnt = cnt
;;;
;;;	stat = alterlist(ed->list,cnt)
;;;
;;;	ed->list[cnt].room        = lg.child_loc_cd  ;room
;;;	ed->list[cnt].fac_ed_area = lg.root_loc_cd   ;area
;;;	ed->list[cnt].roomdesc	  = UAR_GET_CODE_DISPLAY(lg.child_loc_cd)
;;;	ed->list[cnt].meaning	  = cv.cdf_meaning
;;;
;;;with nocounter
 
;call echorecord(ed)
;go to exitscript
;
;================================================
; SELECT MAIN DATA
;================================================
select DISTINCT into "NL:"
	 fac_name	 = uar_get_code_description(e.loc_facility_cd)
	,fac_abbr  	 = uar_get_code_display(e.loc_facility_cd)
	,fac_unit  	 = uar_get_code_display(e.loc_nurse_unit_cd)
	;,fac_room	 = uar_get_code_display(f.loc_room_cd)
	,fac_room	 = uar_get_code_display(f.loc_room_cd)
	,fac_group	 = uar_get_code_display(tc.tracking_group_cd)
	,chkin_dt  	 = tc.checkin_dt_tm
	,chkout_dt	 = tc.checkout_dt_tm
	,pat_name    = initcap(p.name_full_formatted)
	,birthdate 	 = p.birth_dt_tm
	,age 		 = CNVTAGE(p.birth_dt_tm)
	,sex 		 = evaluate2(if(uar_get_code_display(p.sex_cd)="Male") "M"
					elseif(uar_get_code_display(p.sex_cd)="Female") "F"
					else "-" endif)
;	,provider  	 = initcap(pld.name_full_formatted)
	,er_nurse  	 = initcap(pln.name_full_formatted)
	,los_hrs	 = datetimediff(tc.checkout_dt_tm, tc.checkin_dt_tm,3)
	,encntr_type = uar_get_code_display(e.encntr_type_cd)
;	,dispo_cond  = uar_get_code_display(e.disch_disposition_cd)
	,person_id 	 = e.person_id
	,encntr_id 	 = e.encntr_id
 
from
	 TRACKING_CHECKIN  tc
	,TRACKING_ITEM     ti
	,PERSON            p
;	,PRSNL             pld
	,PRSNL             pln
 	,ENCOUNTER         e
	,FN_OMF_ENCNTR     f
 
plan tc
	where tc.checkin_dt_tm between cnvtdatetime($STARTDATE_PMPT) and cnvtdatetime($ENDDATE_PMPT)
		and tc.active_ind = 1
		and parser(FAC_VAR)
;		and tc.checkout_disposition_cd = $DISPOSITION_TYPE_PMPT
 
join ti
	where ti.tracking_id = tc.tracking_id
		and ti.active_ind = 1
 
join p
	where p.person_id = ti.person_id
		and parser(AGE_VAR)
		and p.end_effective_dt_tm >= sysdate
 
;join pld
;	where pld.person_id = tc.primary_doc_id
;		and pld.end_effective_dt_tm >= sysdate
;;		and pld.person_id > 0
 
join pln
	where pln.person_id = tc.primary_nurse_id
;		and pln.end_effective_dt_tm >= sysdate  ;001
;		and pln.person_id > 0
 
join e
	where e.person_id = p.person_id
		and e.encntr_id = ti.encntr_id
;		and e.encntr_type_cd = EMERGENCY_VAR
		and e.end_effective_dt_tm >= sysdate
;		and e.loc_facility_cd = $FACILITY_PMPT
;		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
;		and	e.loc_facility_cd in (
;			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
;			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
;			)
;		and operator(e.disch_disposition_cd, OPR_DISPO_TYPE_VAR, $DISPOSITION_TYPE_PMPT)
 
join f
	where f.encntr_id = e.encntr_id
		and f.active_ind = 1
 
;join f
;	where f.encntr_id = outerjoin(e.encntr_id)
;		and f.active_ind = outerjoin(1)
 
;order by e.encntr_id, tc.checkin_dt_tm
 
head report
	cnt = 0
 
detail
	loop_cnt = 0
;;;
;;;	while (loop_cnt < ed->room_cnt)
;;;		loop_cnt = loop_cnt + 1
;;;		if (ed->list[loop_cnt].room = f.loc_room_cd)
			cnt = cnt + 1
			stat = alterlist(enc->list,cnt)
 
			enc->list[cnt].fac_name	 	= fac_name
			enc->list[cnt].fac_abbr  	= fac_abbr
			enc->list[cnt].fac_unit  	= fac_unit
			enc->list[cnt].fac_room     = fac_room
			enc->list[cnt].fac_group    = fac_group
;;;			enc->list[cnt].fac_ed_area  = uar_get_code_display(ed->list[loop_cnt].fac_ed_area)
			enc->list[cnt].chkin_dt  	= chkin_dt
			enc->list[cnt].chkout_dt	= chkout_dt
			enc->list[cnt].pat_name  	= pat_name
			enc->list[cnt].birthdate 	= birthdate
			enc->list[cnt].age 		 	= age
			enc->list[cnt].sex 		 	= sex
;			enc->list[cnt].provider  	 	= provider
			enc->list[cnt].er_nurse  	= er_nurse
			enc->list[cnt].los_hrs	 	= los_hrs
			enc->list[cnt].encntr_type  = encntr_type
;			enc->list[cnt].dispo_cond   = dispo_cond
			enc->list[cnt].person_id 	= person_id
			enc->list[cnt].encntr_id 	= encntr_id
 
			enc->recordcnt = cnt
			out->recordcnt = cnt
;;;		endif
;;;	endwhile
 
with nocounter
 
;call echorecord(enc)
;go to exitscript
 
if (enc->recordcnt > 0)		;USED TO CHECK FOR RECORDS BEING RETURNED.  THE ENDIF IS AT THE END of THE PROGRAM BEFORE THE END GO
 
 
;==================================================
; SELECT MD's, PA's, & NP's
;==================================================
 
 
SELECT INTO "NL:"
 
	 sname = REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(p.name_full_formatted)," Apn"," APN")," Md"," MD")," Pa"," PA")," PAul"," Paul")
	,sort_flg = IF 		   (p.position_cd = mdir_var) 1
					ELSEIF (p.position_cd = md_var) 2
					ELSEIF (p.position_cd = pa_var) 3
					ELSEIF (p.position_cd = np_var) 4
					ELSE 5
				ENDIF
 
FROM
	 tracking_prv_reln tr
	,(INNER JOIN tracking_item ti ON ti.tracking_id = tr.tracking_id
		AND ti.active_ind = 1
;		AND tr.tracking_id = 13165667.00
	 )
	,(INNER JOIN prsnl p ON p.person_id = tr.tracking_provider_id
		AND p.active_ind = 1
		AND p.physician_ind = 1
		AND p.position_cd in (MDIR_VAR,MD_VAR,PA_VAR,NP_VAR)
	 )
 
WHERE
	expand(num, 1, size(enc->list, 5), ti.encntr_id, enc->list[num].encntr_id)
 
ORDER BY
	 ti.encntr_id
	,sort_flg
 
HEAD REPORT
 
	cnt = 0
 
	idx = 0
 
HEAD ti.encntr_id
 
	idx = locateval(cnt,1,size(enc->list,5),ti.encntr_id,enc->list[cnt].encntr_id)
 
	prov_var = fillstring(300," ")
 
	prov_out = fillstring(300," ")
 
DETAIL
 
	prov_out = sname
 
	prov_var = build2(TRIM(prov_var),TRIM(prov_out),", ")
 
FOOT ti.encntr_id
 
	enc->list[idx].provider = REPLACE(TRIM(prov_var),",","",2)
 
;	CALL ECHO(enc->list[idx].prov_var)
 
WITH nocounter, expand = 1;, format, check, separator = " "
 
 
;==================================================
; SELECT THE DIAGNOSIS
;==================================================
select into "NL:"
;select into value ($OUTDEV)
	 dtcode	=	d.diag_type_cd
	,dx = n.source_string
 
from
	(DUMMYT       dt with seq = SIZE(enc->LIST ,5))
	,DIAGNOSIS    d
	,NOMENCLATURE n
 
PLAN dt
 
join d
	where d.encntr_id = outerjoin(enc->list[dt.seq].encntr_id)
		and d.active_ind = 1
		and d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and d.diag_type_cd in (DIAG_DISCH_VAR, RFV_CC_DX_VAR)
 
join n
	where n.nomenclature_id = outerjoin(d.nomenclature_id)
;		and n.source_vocabulary_cd = ICD10CM_VAR
 
order by d.encntr_id ,d.diagnosis_id
 
detail
	case (dtcode)
		of DIAG_DISCH_VAR : enc->list[dt.seq].final_dx  = dx
		of RFV_CC_DX_VAR  : enc->list[dt.seq].rfv_cc_dx = dx
	endcase
 
with nocounter
 
;call echorecord(enc)
;go to exitscript
;============================================================================
; select the person and encounter alias's cmrn; mrn; fin.
;============================================================================
select into "NL:"
;	 fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
; 	,mrn  = decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
; 	,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
 
from
 	(DUMMYT        	dt with seq = value(size(enc->LIST,5)))
 	,ENCOUNTER	   	e
 	,ENCNTR_ALIAS	ea 	;fin,
 	,ENCNTR_ALIAS   ea2 ;mrn
 	,PERSON_ALIAS   pa	;cmrn
 
plan dt
 
join e
	where e.encntr_id = enc->list[dt.seq].encntr_id
		and e.active_ind = 1
		and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077, 1079
		and ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join ea2
	where ea2.encntr_id = outerjoin(e.encntr_id)
		and ea2.encntr_alias_type_cd = outerjoin(MRN_VAR)   ;1077, 1079
		and ea2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join pa
	where pa.person_id = outerjoin(e.person_id)
		and pa.person_alias_type_cd = outerjoin(CMRN_VAR)    ;2
		and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
detail  ;head dt.seq
	enc->list[dt.seq].fin  = ea.alias                                ;fin
	enc->list[dt.seq].mrn  = cnvtalias(ea2.alias, ea2.alias_pool_cd) ;mrn
	enc->list[dt.seq].cmrn = pa.alias                                ;cmrn
 
with nocounter
;select into "NL:"
;	 fin  = decode (ea.seq,  cnvtalias(ea.alias,  ea.alias_pool_cd), '')
; 	,cmrn = decode (pa.seq,  cnvtalias(pa.alias,  pa.alias_pool_cd), '')
; 	,mrn  = decode (pa2.seq, cnvtalias(pa2.alias, pa2.alias_pool_cd), '')
;;	,ssn  = decode (pa3.seq, cnvtalias(pa3.alias, pa3.alias_pool_cd), '')
;
;from
; 	(DUMMYT       d with seq = value (size(enc->LIST,5)))
; 	,ENCOUNTER    e
; 	,ENCNTR_ALIAS ea 	;fin
; 	,PERSON_ALIAS pa	;cmrn
; 	,PERSON_ALIAS pa2	;mrn
;
;plan d
;
;join e
;	where e.encntr_id = outerjoin(enc->list[d.seq].encntr_id)
;		and e.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
;
;join ea
;	where ea.encntr_id = outerjoin(e.encntr_id)
;		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077.00
;		and ea.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
;
;join pa
;	where pa.person_id = outerjoin(e.person_id)
;		and pa.person_alias_type_cd = outerjoin(CMRN_VAR)    ;2.00
;		and pa.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
;
;join pa2
;	where pa2.person_id = outerjoin(e.person_id)
;		and pa2.person_alias_type_cd = outerjoin(MRN_VAR)     ;10.00
;		and pa2.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
;
;order d.seq ,ea.encntr_id ,pa.person_id ,pa2.person_id
;
;head d.seq
;	 enc->list[d.seq].fin  = fin
;	 enc->list[d.seq].cmrn = cmrn
;	 enc->list[d.seq].mrn  = mrn
;
;with nocounter
 
 
;============================================================================================
; SELECT DISPOSITION CONDITION - Transfered patients.  stable, serious, improved, etc.....
;============================================================================================
select distinct into "NL:"
;select distinct into value ($outdev)
;  	,dispo_ce_cond	= ce.result_val
	 ecode			= ce.event_cd
	,res			= ce.result_val
from
 	(DUMMYT         d with seq = value (size (enc->list,5)))
   	,CLINICAL_EVENT	ce
 
plan d
 
join ce
	where ce.person_id = enc->list[d.seq].person_id
		and ce.encntr_id = enc->list[d.seq].encntr_id
		and ce.event_cd IN (DISPO_PAT_COND_VAR);, DISPO_TYPE_VAR)
;		and ce.event_end_dt_tm >= sysdate
		and ce.valid_until_dt_tm >= sysdate
		and ce.encntr_id = enc->list[d.seq].encntr_id
 
detail
 
	enc->list[d.seq].dispo_ce_cond = res
 
;	enc->list[d.seq].dispo_cond = if(DISPO_CE_COND_VAR != null) cnvtstring(DISPO_CE_COND_VAR) endif
 
with nocounter
 
;CALL ECHOJSON(enc,"djherren.out",0) ; To see values in RECORD STRUCTURE
;call echorecord(enc)
;go to exitscript
 
;==================================================
; SELECT DISPOSITION CONDITION - Orders
;==================================================
;IN BUILD DOMAIN 2561121013 = SERIOUS, STABLE FOR DISCHARGE, DECEASED, GUARDED, IMPROVED ;
;GET ID IN PROD DOMAIN
/*
select distinct od.oe_field_display_value, od.oe_field_id
from order_detail od
where cnvtlower(oe_field_display_value) in ("serious", "stable for discharge", "decease", "guarded", "improved")
*/
select into 'NL:'
	dispo_od_cond = max(evaluate2(if (od.oe_field_id = 2561121013) od.oe_field_display_value else "" endif))
							over(parition by o.encntr_id,o.order_id)
from
	(DUMMYT       d with seq = SIZE(enc->list,5))
	,ORDERS       o
	,ORDER_DETAIL od
 
plan d
 
join o
	where o.encntr_id = enc->list[d.seq].encntr_id
	and o.activity_type_cd = DISPO_OD_COND_VAR
	and o.catalog_cd in (DISPO_COND_ADMIT_VAR, DISPO_COND_DISCH_VAR);2558812301, 2561117857
 
join od where o.order_id = od.order_id
 
head d.seq
		enc->list[d.seq].dispo_od_cond = dispo_od_cond
 
with nocounter
 
;call echorecord(enc)
;go to exitscript
 
;============================================================================================
; SELECT DISPOSITION-TO
;============================================================================================
select distinct into "NL:"
;SELECT DISTINCT INTO VALUE ($outdev)
	 eid		=	ce.encntr_id
	,nid		=	cer.nomenclature_id
	,dispo_to	=	cer.descriptor
	,dispo_type = IF 	   (cer.nomenclature_id = 9450401) 	 "Treated"
					ELSEIF (cer.nomenclature_id = 280701767) "Treated"
					ELSEIF (cer.nomenclature_id = 280693153) "Treated"
					ELSEIF (cer.nomenclature_id = 22489483)  "Treated"
					ELSEIF (cer.nomenclature_id = 280693157) "Treated"
					ELSEIF (cer.nomenclature_id = 280693162) "Treated"
 
					ELSEIF (cer.nomenclature_id = 57798433)  "PT Refused Treatment"
					ELSEIF (cer.nomenclature_id = 14233843)  "PT Refused Treatment"
					ELSEIF (cer.nomenclature_id = 280693164) "PT Refused Treatment"
					ELSEIF (cer.nomenclature_id = 8544649) 	 "PT Refused Treatment"
 
					ELSEIF (cer.nomenclature_id = 280701813) "Not Treated"
					ELSEIF (cer.nomenclature_id = 280693168) "Not Treated"
				ENDIF
 
from
	(DUMMYT d with seq = value (size (enc->LIST,5)))
	,clinical_event ce
	,ce_coded_result cer
 
plan d
 
join ce
	where ce.encntr_id = OUTERJOIN(enc->list[d.seq].encntr_id)
 
join cer
	where ce.event_id = cer.event_id
		and operator(cer.nomenclature_id, OPR_DISPO_TO_VAR, $DISPOSITION_TO_PMPT)
		;the below nomenclature_id's were pulled from the dispo_to_pmpt query.
		and cer.nomenclature_id in (280701767.00, 280693162.00, 280693157.00, 9450401.00, 280701813.00,
            						8544649.00, 57798433.00, 14233843.00, 280693164.00, 280693153.00,
            						280693168.00, 22489483.00)
		and ce.valid_until_dt_tm >= sysdate
 
HEAD d.seq
		enc->list[d.seq].dispo_to = dispo_to
		enc->list[d.seq].dispo_type = dispo_type
 
WITH nocounter
 
;call echorecord(enc)
;go to exitscript
 
;============================
; REPORT OUTPUT
;============================
IF (OPR_DISPO_TO_VAR = "!=")
 
	select distinct into value ($OUTDEV)
		 fac_name  	 = enc->list[d.seq].fac_name
		,fac_abbr  	 = enc->list[d.seq].fac_abbr
		,fac_unit  	 = enc->list[d.seq].fac_unit
		,fac_group   = enc->list[d.seq].fac_group
;;;		,fac_ed_area = enc->list[d.seq].fac_ed_area
		,fac_room  	 = enc->list[d.seq].fac_room
		,checkin_dt	 = format(enc->list[d.seq].chkin_dt, "mm/dd/yyyy hh:mm;;d")
		,checkout_dt = format(enc->list[d.seq].chkout_dt, "mm/dd/yyyy hh:mm;;d")
		,pat_name    = enc->list[d.seq].pat_name
	 	,birthdate	 = format(enc->list[d.seq].birthdate, "mm/dd/yyyy ;;d")
		,age       	 = enc->list[d.seq].age
		,sex         = enc->list[d.seq].sex
		,fin       	 = enc->list[d.seq].fin
		,cmrn      	 = enc->list[d.seq].cmrn
		,mrn       	 = enc->list[d.seq].mrn
		,rfv_cc_dx	 = enc->list[d.seq].rfv_cc_dx
		,final_dx  	 = enc->list[d.seq].final_dx
		,provider    	 = enc->list[d.seq].provider
		,er_nurse  	 = enc->list[d.seq].er_nurse
		,los_hrs   	 = enc->list[d.seq].los_hrs
		,encntr_type = enc->list[d.seq].encntr_type
		,dispo_od_cond = enc->list[d.seq].dispo_od_cond
		,dispo_ce_cond = enc->list[d.seq].dispo_ce_cond
		,dispo_cond	 =  evaluate2(if(enc->list[d.seq].dispo_od_cond = null) enc->list[d.seq].dispo_ce_cond
							else enc->list[d.seq].dispo_od_cond endif)
;		,dispo_cond  = enc->list[d.seq].dispo_cond
		,dispo_to	 = enc->list[d.seq].dispo_to
		,dispo_type	 = enc->list[d.seq].dispo_type
		,person_id 	 = enc->list[d.seq].person_id
		,encntr_id 	 = enc->list[d.seq].encntr_id
		,startdate 	 = enc->startdate
		,enddate   	 = enc->enddate
	    ,recordcnt   = enc->recordcnt
 
	from
		(DUMMYT d with seq = value(size(enc->list,5)))
 
	plan d
 
	order by fac_name, fac_abbr, fac_room, checkin_dt, pat_name, fin, cmrn, mrn
 
	with nocounter, format, check, separator = " ", nullreport
 
else
 
	select distinct into value ($OUTDEV)
		 fac_name  	 = enc->list[d.seq].fac_name
		,fac_abbr  	 = enc->list[d.seq].fac_abbr
		,fac_unit  	 = enc->list[d.seq].fac_unit
		,fac_group   = enc->list[d.seq].fac_group
;;;		,fac_ed_area = enc->list[d.seq].fac_ed_area
		,fac_room  	 = enc->list[d.seq].fac_room
		,checkin_dt	 = format(enc->list[d.seq].chkin_dt, "mm/dd/yyyy hh:mm;;d")
		,checkout_dt = format(enc->list[d.seq].chkout_dt, "mm/dd/yyyy hh:mm;;d")
		,pat_name    = enc->list[d.seq].pat_name
	 	,birthdate	 = format(enc->list[d.seq].birthdate, "mm/dd/yyyy ;;d")
		,age       	 = enc->list[d.seq].age
		,sex         = enc->list[d.seq].sex
		,fin       	 = enc->list[d.seq].fin
		,cmrn      	 = enc->list[d.seq].cmrn
		,mrn       	 = enc->list[d.seq].mrn
		,rfv_cc_dx	 = enc->list[d.seq].rfv_cc_dx
		,final_dx  	 = enc->list[d.seq].final_dx
		,provider    	 = enc->list[d.seq].provider
		,er_nurse  	 = enc->list[d.seq].er_nurse
		,los_hrs   	 = enc->list[d.seq].los_hrs
		,encntr_type = enc->list[d.seq].encntr_type
		,dispo_od_cond = enc->list[d.seq].dispo_od_cond
		,dispo_ce_cond = enc->list[d.seq].dispo_ce_cond
		,dispo_cond	 = evaluate2(if(enc->list[d.seq].dispo_od_cond = null) enc->list[d.seq].dispo_ce_cond
							else enc->list[d.seq].dispo_od_cond endif)
;		,dispo_cond  = enc->list[d.seq].dispo_cond
		,dispo_to	 = enc->list[d.seq].dispo_to
		,dispo_type	 = enc->list[d.seq].dispo_type
		,person_id 	 = enc->list[d.seq].person_id
		,encntr_id 	 = enc->list[d.seq].encntr_id
		,startdate 	 = enc->startdate
		,enddate   	 = enc->enddate
	    ,recordcnt   = enc->recordcnt
 
	from
		(DUMMYT d with seq = value(size(enc->list,5)))
 
	plan d
		where enc->list[d.seq].dispo_to != NULL
 
	order by fac_name, fac_abbr, fac_room, checkin_dt, pat_name, fin, cmrn, mrn
 
	with nocounter, format, check, separator = " ", nullreport
 
endif
 
/**************************************************************
; POPULATE ED_OUT (SECOND) RECORD STRUCTURE WITH OUTPUT OF ED RS
**************************************************************/
	if (OPR_DISPO_TO_VAR = "!=")
 
		SELECT INTO "nl:"
 
		FROM
			(DUMMYT d WITH seq = value(size(enc->list,5)))
 
		PLAN d
 
 		HEAD REPORT
			cnt_out = 0
 
		DETAIL
			cnt_out = cnt_out + 1
 
			stat = alterlist(out->list,cnt_out)
 
			out->list[cnt_out].fac_name       = enc->list[d.seq].fac_name
			,out->list[cnt_out].fac_abbr      = enc->list[d.seq].fac_abbr
			,out->list[cnt_out].fac_unit      = enc->list[d.seq].fac_unit
			,out->list[cnt_out].fac_group     = enc->list[d.seq].fac_group
;;;			,out->list[cnt_out].fac_ed_area   = enc->list[d.seq].fac_ed_area
			,out->list[cnt_out].fac_room      = enc->list[d.seq].fac_room
			,out->list[cnt_out].chkin_dt      = enc->list[d.seq].chkin_dt
			,out->list[cnt_out].chkout_dt     = enc->list[d.seq].chkout_dt
			,out->list[cnt_out].pat_name      = enc->list[d.seq].pat_name
		 	,out->list[cnt_out].birthdate     = enc->list[d.seq].birthdate
			,out->list[cnt_out].age           = enc->list[d.seq].age
			,out->list[cnt_out].sex           = enc->list[d.seq].sex
			,out->list[cnt_out].fin           = enc->list[d.seq].fin
			,out->list[cnt_out].cmrn          = enc->list[d.seq].cmrn
			,out->list[cnt_out].mrn           = enc->list[d.seq].mrn
			,out->list[cnt_out].rfv_cc_dx     = enc->list[d.seq].rfv_cc_dx
			,out->list[cnt_out].final_dx      = enc->list[d.seq].final_dx
			,out->list[cnt_out].provider      = enc->list[d.seq].provider
			,out->list[cnt_out].er_nurse      = enc->list[d.seq].er_nurse
			,out->list[cnt_out].los_hrs       = enc->list[d.seq].los_hrs
			,out->list[cnt_out].encntr_type   = enc->list[d.seq].encntr_type
			,out->list[cnt_out].dispo_od_cond = enc->list[d.seq].dispo_od_cond
			,out->list[cnt_out].dispo_ce_cond = enc->list[d.seq].dispo_ce_cond
			,out->list[cnt_out].dispo_cond	  = evaluate2(if(enc->list[d.seq].dispo_od_cond = null) enc->list[d.seq].dispo_ce_cond
							else enc->list[d.seq].dispo_od_cond endif)
			,out->list[cnt_out].dispo_to      = enc->list[d.seq].dispo_to
			,out->list[cnt_out].dispo_type    = enc->list[d.seq].dispo_type
			,out->list[cnt_out].person_id     = enc->list[d.seq].person_id
			,out->list[cnt_out].encntr_id     = enc->list[d.seq].encntr_id
			,out->startdate                   = enc->startdate
			,out->enddate                     = enc->enddate
			,out->recordcnt                   = enc->recordcnt
 
 			with nocounter, format, check, separator = " "
 
 	else
 
 		SELECT INTO "nl:"
 
		FROM
			(DUMMYT d WITH seq = value(size(enc->list,5)))
 
		PLAN d
			WHERE enc->list[d.seq].dispo_to != NULL
 
 		HEAD REPORT
			cnt_out = 0
 
		DETAIL
			cnt_out = cnt_out + 1
 
			stat = alterlist(out->list,cnt_out)
 
 			out->list[cnt_out].fac_name       = enc->list[d.seq].fac_name
			,out->list[cnt_out].fac_abbr      = enc->list[d.seq].fac_abbr
			,out->list[cnt_out].fac_unit      = enc->list[d.seq].fac_unit
			,out->list[cnt_out].fac_group     = enc->list[d.seq].fac_group
;;;			,out->list[cnt_out].fac_ed_area   = enc->list[d.seq].fac_ed_area
			,out->list[cnt_out].fac_room      = enc->list[d.seq].fac_room
			,out->list[cnt_out].chkin_dt      = enc->list[d.seq].chkin_dt
			,out->list[cnt_out].chkout_dt     = enc->list[d.seq].chkout_dt
			,out->list[cnt_out].pat_name      = enc->list[d.seq].pat_name
		 	,out->list[cnt_out].birthdate     = enc->list[d.seq].birthdate
			,out->list[cnt_out].age           = enc->list[d.seq].age
			,out->list[cnt_out].sex           = enc->list[d.seq].sex
			,out->list[cnt_out].fin           = enc->list[d.seq].fin
			,out->list[cnt_out].cmrn          = enc->list[d.seq].cmrn
			,out->list[cnt_out].mrn           = enc->list[d.seq].mrn
			,out->list[cnt_out].rfv_cc_dx     = enc->list[d.seq].rfv_cc_dx
			,out->list[cnt_out].final_dx      = enc->list[d.seq].final_dx
			,out->list[cnt_out].provider      = enc->list[d.seq].provider
			,out->list[cnt_out].er_nurse      = enc->list[d.seq].er_nurse
			,out->list[cnt_out].los_hrs       = enc->list[d.seq].los_hrs
			,out->list[cnt_out].encntr_type   = enc->list[d.seq].encntr_type
			,out->list[cnt_out].dispo_od_cond = enc->list[d.seq].dispo_od_cond
			,out->list[cnt_out].dispo_ce_cond = enc->list[d.seq].dispo_ce_cond
			,out->list[cnt_out].dispo_cond	  = evaluate2(if(enc->list[d.seq].dispo_od_cond = null) enc->list[d.seq].dispo_ce_cond
							else enc->list[d.seq].dispo_od_cond endif)
			,out->list[cnt_out].dispo_to      = enc->list[d.seq].dispo_to
			,out->list[cnt_out].dispo_type    = enc->list[d.seq].dispo_type
			,out->list[cnt_out].person_id     = enc->list[d.seq].person_id
			,out->list[cnt_out].encntr_id     = enc->list[d.seq].encntr_id
			,out->startdate                   = enc->startdate
			,out->enddate                     = enc->enddate
			,out->recordcnt                   = enc->recordcnt
 
 			with nocounter, format, check, separator = " "
	endif
 
	select distinct into value ($OUTDEV)
		 fac_name  	   = out->list[d.seq].fac_name
		,fac_abbr  	   = out->list[d.seq].fac_abbr
		,fac_unit  	   = out->list[d.seq].fac_unit
		,fac_group     = out->list[d.seq].fac_group
;;;		,fac_ed_area   = out->list[d.seq].fac_ed_area
		,fac_room  	   = out->list[d.seq].fac_room
		,checkin_dt	   = format(out->list[d.seq].chkin_dt, "mm/dd/yyyy hh:mm;;d")
		,checkout_dt   = format(out->list[d.seq].chkout_dt, "mm/dd/yyyy hh:mm;;d")
		,pat_name      = out->list[d.seq].pat_name
	 	,birthdate	   = format(out->list[d.seq].birthdate, "mm/dd/yyyy ;;d")
		,age       	   = out->list[d.seq].age
		,sex           = out->list[d.seq].sex
		,fin       	   = out->list[d.seq].fin
		,cmrn      	   = out->list[d.seq].cmrn
		,mrn       	   = out->list[d.seq].mrn
		,rfv_cc_dx	   = out->list[d.seq].rfv_cc_dx
		,final_dx  	   = out->list[d.seq].final_dx
		,provider      = out->list[d.seq].provider
		,er_nurse  	   = out->list[d.seq].er_nurse
		,los_hrs   	   = out->list[d.seq].los_hrs
		,encntr_type   = out->list[d.seq].encntr_type
		,dispo_od_cond = out->list[d.seq].dispo_od_cond
		,dispo_ce_cond = out->list[d.seq].dispo_ce_cond
		,dispo_cond	   = evaluate2(if(out->list[d.seq].dispo_od_cond = null) out->list[d.seq].dispo_ce_cond
							else out->list[d.seq].dispo_od_cond endif)
		,dispo_to	   = out->list[d.seq].dispo_to
		,dispo_type	   = out->list[d.seq].dispo_type
		,person_id 	   = out->list[d.seq].person_id
		,encntr_id 	   = out->list[d.seq].encntr_id
		,startdate 	   = enc->startdate
		,enddate   	   = enc->enddate
	    ,recordcnt     = out->recordcnt
 
	from
		(DUMMYT d with seq = value(size(out->list,5)))
 
	plan d
 
	order by fac_name, fac_abbr, fac_room, checkin_dt, pat_name, fin, cmrn, mrn
 
	with nocounter, format, check, separator = " ", nullreport
 
endif	;USED TO CHECK FOR RECORDS BEING RETURNED.
 
;call echojson(enc,"djherren.out",0)
;CALL ECHORECORD(ENC)
#exitscript
end
go
 
 
 

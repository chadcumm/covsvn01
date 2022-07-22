/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren / Paul Hester
    Date Written:      July 2021 / January 2019
    Soluation:         Pharmacy / Physician Track
    Source file name:  cov_powerplan_usage_facility.prg
    Object name:       cov_powerplan_usage_facility
    Request #:
 
    Program purpose:   Provides usage counts for powerplans within a given date prompt.
 
    Executing from:    CCL.
 
 ***********************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ***********************************************************************************
 *
 *
 *										NOTES
 *	--------------------------------------------------------------------------------
 *  07/2021 - Copied cov_powerplan_usage.prg into cov_powerplan_usage_facility.prg
 *		and added prompt for Facility.  This is used by the Pharamcy team. ;001
 *
 *	The status is determined by the end effective date and begin effective date.
 *	TESTING status has a future begin date,
 *	PRODUCTION status has a begin prior to now and an end in the future.
 *	ARCHIVE has an end status prior to today.  https://connect.cerner.com/message/1023425#1023425
 *
 *
 *
 *	Revision #	Mod Date	Developer		Comment
 *  ----------	----------	-----------		----------------------------------------
 *	001			June 2021	Dan Herren		CR 10259 
 ***********************************************************************************/
 
drop program cov_powerplan_usage_facility:dba go
create program cov_powerplan_usage_facility:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "PowerPlan Type" = "1"
	, "Start Date (defaults to Wave1 Go-live)" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, PPTYPE_PMPT, STARTDATE_PMPT, ENDDATE_PMPT, FACILITY_PMPT
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;free record ids
;RECORD ids (
;	1 facility		= vc
;  	1 enctrs[*]
;		2 encntr_id	= f8
;)
 
;FREE RECORD PPU
RECORD PPU (
	1 startdate = c50
	1 enddate   = c50
	1 list[*]
		2	pp			= c150	;powerplan name
		2	pcid		= f8	;powerplan catalog id
		2	ppt			= c20	;powerplan type
		2	begin_dt	= f8
		2	end_dt		= f8
		2	ver			= i4	;version
		2	stat		= c15	;status
		2	pptot		= i4	;powerplan count
		2	facility	= vc	;facility  ;001
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
SET PPU->startdate	= $STARTDATE_PMPT;substring(1,11,$STARTDATE_PMPT)
SET PPU->enddate	= $ENDDATE_PMPT;substring(1,11,$ENDDATE_PMPT)
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 1)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
declare num	= i4 with noconstant(0)
declare idx	= i4 with noconstant(0)
 
 
IF(OPR_FAC_VAR = "!=") ;ALL Facilities
 
	SELECT
 
		IF($PPTYPE_PMPT = "1")
			WHERE (;pc.active_ind = 1 AND
					pc.type_mean IN ("CAREPLAN", "PATHWAY"))
 
		ELSEIF ($PPTYPE_PMPT = "ONCP")	;regimen
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description = "ONCP*")
 
		ELSEIF ($PPTYPE_PMPT = "IPOC")	;caresets
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description = "*IPOC*")
 
		ELSEIF ($PPTYPE_PMPT = "SUB")	;subphase
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.sub_phase_ind = 1)
 
		ELSEIF ($PPTYPE_PMPT = "REG")	;regular
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description != "ONCP*" AND
				pc.description!= "*IPOC*" AND
				pc.sub_phase_ind = 0)
		ENDIF
 
	INTO 'NL:'
	;	 powerplan = build(pc.description," (Ver ",cnvtreal(pc.version),")")
		 powerplan = pc.description
		,pc.pathway_catalog_id
		,PP_Type = IF(pc.description = "ONCP*") "Regimen"
						ELSEIF(pc.description = "*IPOC*") "Caresets"
						ELSEIF(pc.sub_phase_ind = 1) "Sub-Phase"
						ELSE "Regular"
				   ENDIF
		,status = IF (CNVTDATETIME(pc.beg_effective_dt_tm) > CNVTDATETIME(sysdate)) "Testing"
					ELSEIF (CNVTDATETIME(pc.beg_effective_dt_tm) < CNVTDATETIME(sysdate)
						AND CNVTDATETIME(pc.end_effective_dt_tm) > CNVTDATETIME(sysdate)) "Prod"
					ELSEIF (CNVTDATETIME(pc.end_effective_dt_tm) < CNVTDATETIME(sysdate)) "Archived"
	;				else "??"
				  ENDIF
	;	,pw.pw_group_nbr
		,pc.version
		,pp_count = COUNT(DISTINCT(pw.pw_group_nbr))
 
	FROM pathway_catalog pc
 
		,(LEFT JOIN pathway pw ON pw.pw_cat_group_id = pc.pathway_catalog_id
	;		AND expand (num, 1, size(ids->enctrs, 5), pw.encntr_id, ids->enctrs[num].encntr_id)
			AND pw.type_mean != "DOT"
			AND (pw.order_dt_tm BETWEEN cnvtdatetime($STARTDATE_PMPT) AND cnvtdatetime($ENDDATE_PMPT)))
 
		,(LEFT JOIN encounter e on e.encntr_id = pw.encntr_id
			AND e.active_ind = 1) ;001
 
	GROUP BY
		 pc.description
		,pc.pathway_catalog_id
		,pc.version
		,pc.beg_effective_dt_tm
		,pc.end_effective_dt_tm
		,pc.sub_phase_ind
		,e.loc_facility_cd
 
	ORDER BY
	;	 pp_type
	;	 COUNT(DISTINCT(pw.pw_group_nbr)) desc
		  pc.pathway_catalog_id
		 ,pc.version
	;	,pw.pw_group_nbr
 
	HEAD REPORT
		cnt = 0
		CALL alterlist(PPU->LIST, 100)
 
	HEAD pc.pathway_catalog_id
		NULL
 
	DETAIL
		cnt = cnt + 1
		ppcnt = 0
 
		IF(mod(cnt, 10) = 1 and cnt > 100)
			CALL alterlist(PPU->LIST, cnt+9)
		ENDIF
 
		PPU->LIST[cnt].pp		= pc.description	;build(pc.description," (Ver ",pc.version,")")
		PPU->LIST[cnt].pcid		= pc.pathway_catalog_id
		PPU->LIST[cnt].ver		= pc.version
		PPU->LIST[cnt].ppt		= pp_type
		PPU->LIST[cnt].begin_dt = pc.beg_effective_dt_tm
		PPU->LIST[cnt].end_dt	= pc.end_effective_dt_tm
		PPU->LIST[cnt].stat		= status
		PPU->LIST[cnt].pptot	= pp_count
		PPU->LIST[cnt].facility	= uar_get_code_display(e.loc_facility_cd)
 
	FOOT REPORT
	 	CALL ALTERLIST(PPU->LIST, cnt)
 
	WITH nocounter, time=60
 
ELSE
 
	SELECT
 
		IF($PPTYPE_PMPT = "1")
			WHERE (;pc.active_ind = 1 AND
					pc.type_mean IN ("CAREPLAN", "PATHWAY"))
 
		ELSEIF ($PPTYPE_PMPT = "ONCP")	;regimen
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description = "ONCP*")
 
		ELSEIF ($PPTYPE_PMPT = "IPOC")	;caresets
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description = "*IPOC*")
 
		ELSEIF ($PPTYPE_PMPT = "SUB")	;subphase
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.sub_phase_ind = 1)
 
		ELSEIF ($PPTYPE_PMPT = "REG")	;regular
			WHERE (;pc.active_ind = 1 AND
				pc.type_mean IN ("CAREPLAN", "PATHWAY") AND
				pc.description != "ONCP*" AND
				pc.description!= "*IPOC*" AND
				pc.sub_phase_ind = 0)
		ENDIF
 
	INTO 'NL:'
	;	 powerplan = build(pc.description," (Ver ",cnvtreal(pc.version),")")
		 powerplan = pc.description
		,pc.pathway_catalog_id
		,PP_Type = IF(pc.description = "ONCP*") "Regimen"
						ELSEIF(pc.description = "*IPOC*") "Caresets"
						ELSEIF(pc.sub_phase_ind = 1) "Sub-Phase"
						ELSE "Regular"
				   ENDIF
		,status = IF (CNVTDATETIME(pc.beg_effective_dt_tm) > CNVTDATETIME(sysdate)) "Testing"
					ELSEIF (CNVTDATETIME(pc.beg_effective_dt_tm) < CNVTDATETIME(sysdate)
						AND CNVTDATETIME(pc.end_effective_dt_tm) > CNVTDATETIME(sysdate)) "Prod"
					ELSEIF (CNVTDATETIME(pc.end_effective_dt_tm) < CNVTDATETIME(sysdate)) "Archived"
	;				else "??"
				  ENDIF
	;	,pw.pw_group_nbr
		,pc.version
		,pp_count = COUNT(DISTINCT(pw.pw_group_nbr))
 
	FROM pathway_catalog pc
 
		,(INNER JOIN pathway pw ON pw.pw_cat_group_id = pc.pathway_catalog_id
	;		AND expand (num, 1, size(ids->enctrs, 5), pw.encntr_id, ids->enctrs[num].encntr_id)
			AND pw.type_mean != "DOT"
			AND (pw.order_dt_tm BETWEEN cnvtdatetime($STARTDATE_PMPT) AND cnvtdatetime($ENDDATE_PMPT))
		 )
		,(INNER JOIN encounter e on e.encntr_id = pw.encntr_id
			AND operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
			AND e.active_ind = 1) ;001
 
	GROUP BY
		 pc.description
		,pc.pathway_catalog_id
		,pc.version
		,pc.beg_effective_dt_tm
		,pc.end_effective_dt_tm
		,pc.sub_phase_ind
		,e.loc_facility_cd
 
 
	ORDER BY
	;	 pp_type
	;	 COUNT(DISTINCT(pw.pw_group_nbr)) desc
		  pc.pathway_catalog_id
		 ,pc.version
	;	,pw.pw_group_nbr
 
	HEAD REPORT
		cnt = 0
		CALL alterlist(PPU->LIST, 100)
 
	HEAD pc.pathway_catalog_id
		NULL
 
	DETAIL
		cnt = cnt + 1
		ppcnt = 0
 
		IF(mod(cnt, 10) = 1 and cnt > 100)
			CALL alterlist(PPU->LIST, cnt+9)
		ENDIF
 
		PPU->LIST[cnt].pp		= pc.description	;build(pc.description," (Ver ",pc.version,")")
		PPU->LIST[cnt].pcid		= pc.pathway_catalog_id
		PPU->LIST[cnt].ver		= pc.version
		PPU->LIST[cnt].ppt		= pp_type
		PPU->LIST[cnt].begin_dt = pc.beg_effective_dt_tm
		PPU->LIST[cnt].end_dt	= pc.end_effective_dt_tm
		PPU->LIST[cnt].stat		= status
		PPU->LIST[cnt].pptot	= pp_count
		PPU->LIST[cnt].facility	= uar_get_code_display(e.loc_facility_cd)
 
	FOOT REPORT
	 	CALL ALTERLIST(PPU->LIST, cnt)
 
	WITH nocounter, time=60
 
ENDIF
 
;CALL ECHORECORD(PPU)
;GO TO exitscript
 
;**********************DISPLAY RESULT SET TO SCREEN**********************
 
SELECT
 
	IF(OPR_FAC_VAR = "!=") ;ALL Facilities
		 powerplan			= PPU->LIST[d.seq].pp
		,pathway_catalog_id	= PPU->LIST[d.seq].pcid
		,ver				= PPU->LIST[d.seq].ver
		,type				= PPU->LIST[d.seq].ppt
		,Implemented_dt 	= FORMAT(PPU->LIST[d.seq].begin_dt,"MM/DD/YYYY hh:mm;;d")
		,Inactive_dt 		= IF (PPU->LIST[d.seq].end_dt > SYSDATE) "" ELSE FORMAT(PPU->LIST[d.seq].end_dt,"MM/DD/YYYY hh:mm;;d") ENDIF
		,status 			= PPU->LIST[d.seq].stat
		,pptot				= PPU->LIST[d.seq].pptot
		,facility 			= substring(1,30,PPU->LIST[d.seq].facility)
	ELSE
		 powerplan			= PPU->LIST[d.seq].pp
		,pathway_catalog_id	= PPU->LIST[d.seq].pcid
		,ver				= PPU->LIST[d.seq].ver
		,type				= PPU->LIST[d.seq].ppt
		,Implemented_dt 	= FORMAT(PPU->LIST[d.seq].begin_dt,"MM/DD/YYYY hh:mm;;d")
		,Inactive_dt 		= IF (PPU->LIST[d.seq].end_dt > SYSDATE) "" ELSE FORMAT(PPU->LIST[d.seq].end_dt,"MM/DD/YYYY hh:mm;;d") ENDIF
		,status 			= PPU->LIST[d.seq].stat
		,pptot				= PPU->LIST[d.seq].pptot
		,facility 			= substring(1,30,PPU->LIST[d.seq].facility)
	ENDIF
 
INTO $outdev
FROM (dummyt d WITH seq = VALUE(SIZE(PPU->LIST,5)))
 
PLAN d
 
ORDER BY type, powerplan, ver, pptot desc
 
WITH nocounter, separator = " ", format;, maxcol = 500
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
end
go
 


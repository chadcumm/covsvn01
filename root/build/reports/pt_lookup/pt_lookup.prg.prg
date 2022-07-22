drop program pt_lookup go
create program pt_lookup
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""
	, "Encounter ID" = 0
	, "Person ID" = 0
	, "Medical Record Number" = ""
	, "Community Medical Record Number" = ""
 
with OUTDEV, FIN, EID, PID, MRN, CMRN
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD pt
RECORD pt
(
1	list[*]
	2	fac				= c50
	2	pname			= vc
	2	dob				= dq8	;date of birth
	2	CMRN			= VC	;community medical record number
	2	FIN				= VC	;financial number
	2	MRN				= VC	;medical record number
	2	EID				= f8	;encounter number
	2	PID				= f8	;person id
	2	age				= i4	;age
	2	enc_visit_type	= C20	;ENCOUNTER VISIT TYPE
	2	admit_dt		= dq8	;admit date
	2	dc_dt			= dq8	;discharge date
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE FIN_VAR          	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",319,"FIN NBR")),PROTECT
DECLARE CMRN_VAR         	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",4,"CMRN")),PROTECT
DECLARE MRN_VAR          	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",319,"MRN")),PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
	select
if(cnvtint($fin) >0)
 
		 fac = uar_get_code_display(e.loc_facility_cd)
		,age = datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
		,pname = p.name_full_formatted
		,pid	= p.person_id
		,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
		,mrn  = ea2.alias;decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
		,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
		,ea2.alias
		,eid = e.encntr_id
		,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
		,admit = e.arrive_dt_tm;FORMAT(e.arrive_dt_tm,"MM/DD/YYYY hh:mm;;d")
		,DOB = p.birth_dt_tm
		,dc = e.disch_dt_tm
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
		,room = uar_get_code_display(e.loc_room_cd)
		,bed = uar_get_code_display(e.loc_bed_cd)
		,e.updt_dt_tm "@SHORTDATETIME"
	FROM
		 PERSON P
		,ENCOUNTER		e
		,ENCNTR_ALIAS	ea	;fin,
		,ENCNTR_ALIAS	ea2 ;mrn
		,PERSON_ALIAS	pa	;cmrn
 
	PLAN p
 
	JOIN e
		WHERE 	OUTERJOIN(p.person_id) = e.person_id
			AND e.active_ind = 1
	        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
	JOIN ea
		WHERE	ea.encntr_id = outerJOIN(e.encntr_id)
			AND ea.encntr_alias_type_cd = outerJOIN(FIN_VAR)   ;1077
			AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
	        AND ea.alias = $fin
 
	JOIN ea2
		WHERE 	ea2.encntr_id = outerJOIN(e.encntr_id)
			AND ea2.encntr_alias_type_cd = outerJOIN(MRN_VAR)   ;1079
			AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
	JOIN pa
		WHERE 	pa.person_id = outerJOIN(e.person_id)
			AND pa.person_alias_type_cd = outerJOIN(CMRN_VAR)    ;2
			AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
elseif($eid >0)
 
		 fac = uar_get_code_display(e.loc_facility_cd)
		,age = datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
		,pname = p.name_full_formatted
		,pid	= p.person_id
		,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
		,mrn  = ea2.alias;decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
		,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
		,ea2.alias
		,eid = e.encntr_id
		,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
		,admit = e.arrive_dt_tm;FORMAT(e.arrive_dt_tm,"MM/DD/YYYY hh:mm;;d")
		,DOB = p.birth_dt_tm
		,dc = e.disch_dt_tm
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
		,room = uar_get_code_display(e.loc_room_cd)
		,bed = uar_get_code_display(e.loc_bed_cd)
		,e.updt_dt_tm "@SHORTDATETIME"
	FROM
		 PERSON P
		,ENCOUNTER		e
		,ENCNTR_ALIAS	ea	;fin,
		,ENCNTR_ALIAS	ea2 ;mrn
		,PERSON_ALIAS	pa	;cmrn
 
	PLAN p
 
	JOIN e
		WHERE 	OUTERJOIN(p.person_id) = e.person_id
			AND e.active_ind = 1
	        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
			AND e.encntr_id = $eid
 
	JOIN ea
		WHERE	ea.encntr_id = outerJOIN(e.encntr_id)
			AND ea.encntr_alias_type_cd = outerJOIN(FIN_VAR)   ;1077
			AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN ea2
		WHERE 	ea2.encntr_id = outerJOIN(e.encntr_id)
			AND ea2.encntr_alias_type_cd = outerJOIN(MRN_VAR)   ;1079
			AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN pa
		WHERE 	pa.person_id = outerJOIN(e.person_id)
			AND pa.person_alias_type_cd = outerJOIN(CMRN_VAR)    ;2
			AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
elseif($pid >0)
 
		 fac = uar_get_code_display(e.loc_facility_cd)
		,age = datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
		,pname = p.name_full_formatted
		,pid	= p.person_id
		,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
		,mrn  = ea2.alias;decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
		,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
		,ea2.alias
		,eid = e.encntr_id
		,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
		,admit = e.arrive_dt_tm;FORMAT(e.arrive_dt_tm,"MM/DD/YYYY hh:mm;;d")
		,DOB = p.birth_dt_tm
		,dc = e.disch_dt_tm
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
		,room = uar_get_code_display(e.loc_room_cd)
		,bed = uar_get_code_display(e.loc_bed_cd)
		,e.updt_dt_tm "@SHORTDATETIME"
	FROM
		 PERSON P
		,ENCOUNTER		e
		,ENCNTR_ALIAS	ea	;fin,
		,ENCNTR_ALIAS	ea2 ;mrn
		,PERSON_ALIAS	pa	;cmrn
 
	PLAN p
 
	JOIN e
		WHERE 	OUTERJOIN(p.person_id) = e.person_id
			AND e.active_ind = 1
	        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
			AND e.person_id = $pid
 
	JOIN ea
		WHERE	ea.encntr_id = outerJOIN(e.encntr_id)
			AND ea.encntr_alias_type_cd = outerJOIN(FIN_VAR)   ;1077
			AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN ea2
		WHERE 	ea2.encntr_id = outerJOIN(e.encntr_id)
			AND ea2.encntr_alias_type_cd = outerJOIN(MRN_VAR)   ;1079
			AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN pa
		WHERE 	pa.person_id = outerJOIN(e.person_id)
			AND pa.person_alias_type_cd = outerJOIN(CMRN_VAR)    ;2
			AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
elseif(cnvtint($mrn) >0)
 
		 fac = uar_get_code_display(e.loc_facility_cd)
		,age = datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
		,pname = p.name_full_formatted
		,pid	= p.person_id
		,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
		,mrn  = ea2.alias;decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
		,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
		,ea2.alias
		,eid = e.encntr_id
		,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
		,admit = e.arrive_dt_tm;FORMAT(e.arrive_dt_tm,"MM/DD/YYYY hh:mm;;d")
		,DOB = p.birth_dt_tm
		,dc = e.disch_dt_tm
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
		,room = uar_get_code_display(e.loc_room_cd)
		,bed = uar_get_code_display(e.loc_bed_cd)
		,e.updt_dt_tm "@SHORTDATETIME"
	FROM
		 PERSON P
		,ENCOUNTER		e
		,ENCNTR_ALIAS	ea	;fin,
		,ENCNTR_ALIAS	ea2 ;mrn
		,PERSON_ALIAS	pa	;cmrn
 
	PLAN p
 
	JOIN e
		WHERE 	OUTERJOIN(p.person_id) = e.person_id
			AND e.active_ind = 1
	        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
	JOIN ea
		WHERE	ea.encntr_id = outerJOIN(e.encntr_id)
			AND ea.encntr_alias_type_cd = outerJOIN(FIN_VAR)   ;1077
			AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN ea2
		WHERE 	ea2.encntr_id = outerJOIN(e.encntr_id)
			AND ea2.encntr_alias_type_cd = outerJOIN(MRN_VAR)   ;1079
			AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
			AND	ea2.alias = $mrn
 
	JOIN pa
		WHERE 	pa.person_id = outerJOIN(e.person_id)
			AND pa.person_alias_type_cd = outerJOIN(CMRN_VAR)    ;2
			AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
elseif(cnvtint($cmrn) >0)
 
		 fac = uar_get_code_display(e.loc_facility_cd)
		,age = datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
		,pname = p.name_full_formatted
		,pid	= p.person_id
		,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
		,mrn  = ea2.alias;decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
		,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
		,ea2.alias
		,eid = e.encntr_id
		,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
		,admit = e.arrive_dt_tm;FORMAT(e.arrive_dt_tm,"MM/DD/YYYY hh:mm;;d")
		,DOB = p.birth_dt_tm
		,dc = e.disch_dt_tm
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
		,room = uar_get_code_display(e.loc_room_cd)
		,bed = uar_get_code_display(e.loc_bed_cd)
		,e.updt_dt_tm "@SHORTDATETIME"
	FROM
		 PERSON P
		,ENCOUNTER		e
		,ENCNTR_ALIAS	ea	;fin,
		,ENCNTR_ALIAS	ea2 ;mrn
		,PERSON_ALIAS	pa	;cmrn
 
	PLAN p
 
	JOIN e
		WHERE 	OUTERJOIN(p.person_id) = e.person_id
			AND e.active_ind = 1
	        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
	JOIN ea
		WHERE	ea.encntr_id = outerJOIN(e.encntr_id)
			AND ea.encntr_alias_type_cd = outerJOIN(FIN_VAR)   ;1077
			AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN ea2
		WHERE 	ea2.encntr_id = outerJOIN(e.encntr_id)
			AND ea2.encntr_alias_type_cd = outerJOIN(MRN_VAR)   ;1079
			AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
	JOIN pa
		WHERE 	pa.person_id = outerJOIN(e.person_id)
			AND pa.person_alias_type_cd = outerJOIN(CMRN_VAR)    ;2
			AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
			AND	pa.alias = $cmrn
 
endif
 
	message = "No prompts entered"
 
from dummyt
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
 
	IF(mod(cnt, 10) = 1 OR cnt > 10)
		CALL alterlist(pt->LIST, cnt+9)
	ENDIF
 
	pt->LIST[cnt].fac				= fac
	pt->LIST[cnt].pname				= pname
	pt->LIST[cnt].dob				= dob
	pt->LIST[cnt].fin				= fin
	pt->LIST[cnt].mrn				= mrn
	pt->LIST[cnt].cmrn				= cmrn
	pt->LIST[cnt].eid				= eid
	pt->LIST[cnt].pid				= pid
	pt->LIST[cnt].age				= age
	pt->LIST[cnt].enc_visit_type	= EncounterVisit_type
	pt->LIST[cnt].admit_dt			= admit
	pt->LIST[cnt].dc_dt				= dc
 
FOOT REPORT
 
 	CALL ALTERLIST(pt->LIST, cnt)
 
WITH nocounter, time = 10
 
;**********************DISPLAY RESULT SET TO SCREEN**********************
 
		SELECT DISTINCT INTO $outdev
			 fac			= pt->LIST[d.seq].fac				;facility name
			,pname			= pt->LIST[d.seq].pname				;patient name
			,dob			= FORMAT(pt->LIST[d.seq].dob,"MM/DD/YYYY ;;d")				;date of birth
			,FIN			= pt->LIST[d.seq].FIN				;FIN
			,MRN			= pt->LIST[d.seq].MRN				;MRN
			,CMRN			= pt->LIST[d.seq].CMRN				;MRN
			,EID			= pt->LIST[d.seq].EID				;EID
			,PID			= pt->LIST[d.seq].PID				;PID
			,age			= pt->LIST[d.seq].age				;age
			,enc_visit_type	= pt->LIST[d.seq].enc_visit_type	;encounter visit type
			,admit_dt		= FORMAT(pt->LIST[d.seq].admit_dt,"MM/DD/YYYY hh:mm;;d")
			,dc_dt			= FORMAT(pt->LIST[d.seq].dc_dt,"MM/DD/YYYY hh:mm;;d")
 
		FROM
			(dummyt d WITH seq = VALUE(SIZE(pt->LIST,5)))
 
		PLAN d
 
;		ORDER BY
;			  pname
 
WITH nocounter ,separator = " ",format, maxcol = 500
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

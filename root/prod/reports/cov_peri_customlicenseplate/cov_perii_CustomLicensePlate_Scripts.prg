
/* CUSTOM LICENSE PLATE HAS NO .PRG PROGRAM FOR LAYOUT BUILDER */
/* THESE ARE THE SCRIPTS FOR LB */
SELECT DISTINCT
	PAT = P.NAME_FULL_FORMATTED
	, PHYS = PR.NAME_FULL_FORMATTED
	, PROC = CONCAT("- ", UAR_GET_CODE_DISPLAY(SCP.SCHED_SURG_PROC_CD))
	, MODIFIER = if(textlen(scp.sched_modifier) > 1) scp.sched_modifier else "N/A" endif
	, PROC_DETAIL = if(textlen(scp.proc_text) > 1) scp.proc_text else "N/A" endif
	, SURG_AREA = TRIM(UAR_GET_CODE_DISPLAY(scp.sched_surg_area_cd),3)
	, SURG_ROOM = UAR_GET_CODE_DISPLAY(SC.SCHED_OP_LOC_CD)
	, FAC = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
	, SCHED_DATE = FORMAT(SC.SCHED_START_DT_TM, "MM-DD-YYYY;;D")
	, SCHED_TIME = FORMAT(SC.SCHED_START_DT_TM, "HH:MM;;M")

FROM
	PERSON   P
	, PRSNL   PR
	, ENCOUNTER   E
	, SURG_CASE_PROCEDURE   SCP
	, SURGICAL_CASE   SC

PLAN SCP 
	WHERE SCP.SCHED_SURG_PROC_CD > 0
	AND scp.active_ind = 1
	AND scp.sched_surg_area_cd =       2554023941.00

JOIN sc 
	WHERE sc.surg_case_id = scp.surg_case_id 
;	AND (sc.sched_start_dt_tm BETWEEN CNVTDATETIME("01-JAN-2018 00:00:00")
;	AND CNVTDATETIME("2018-MAR-31 23:59:59"))
JOIN e 
	WHERE e.encntr_id = sc.encntr_id
JOIN p 
	WHERE p.person_id = e.person_id
	AND p.person_id = sc.person_id
JOIN pr 
	WHERE pr.person_id = sc.surgeon_prsnl_id

ORDER BY
	SCHED_DATE
	, SURG_ROOM
	, SCHED_TIME
	, PAT
	, PROC

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=60, maxrec=100



/* SURG AREA PROMPT */
SELECT DISTINCT
	service_resource_cd = sr.service_resource_cd
	, service_resource_nm = UAR_GET_CODE_DISPLAY(sr.service_resource_cd)

FROM
	prsnl_org_reltn   por
	, service_resource   sr

PLAN por
    WHERE por.person_id = REQINFO->updt_id
        AND por.active_ind = 1 
        AND por.end_effective_dt_tm > SYSDATE
JOIN sr
    WHERE sr.organization_id = por.organization_id
        AND sr.active_ind = 1
        AND sr.end_effective_dt_tm > SYSDATE
        AND sr.service_resource_type_cd = VALUE(UAR_GET_CODE_BY("MEANING",223,"SURGAREA"))

ORDER BY
	service_resource_nm

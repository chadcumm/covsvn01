 
/***********************PROGRAM NOTES*************************
        Source file name:       COV_CMRN_NGPN_RPT.PRG
        Object name:            COV_CMRN_NGPN_RPT
        Request #:              N/A
 
        Product:                CRMN/NextGen Report
        Product Team:           MPI/IT
 
        Program purpose:        List of Patients with CMRN and
                                NextGen Person Nbr
 
        Tables read:            PERSON   P
								PERSON_ALIAS   SSN
								PERSON_ALIAS   CMRN
								PERSON_ALIAS   NGPN
								PERSON_PATIENT   PP
 
        Tables updated:         N/A
 
        Executing from:         DA2/Reporting Portal
 
        Special Notes:
 
*****************************************************************************/
/***********************Change Log*******************************************
VERSION DATE        ENGINEER            COMMENT
-------	---------   ----------------    -------------------------------------
001		11/8/2018 	Dawn Greer, DBA		Created
*****************************************************************************/
 
drop program    COV_CMRN_NGPN_RPT:dba go
create program  COV_CMRN_NGPN_RPT:dba
 
declare ssn_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "SSN")), protect
declare mrn_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "MRN")), protect
declare cmrn_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "CMRN")), protect
declare NGPN_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "NEXTGENPERSONID")), protect
 
declare ssn = f8 with constant(uar_get_code_by("MEANING", 4, "SSN")), protect
declare mrn = f8 with constant(uar_get_code_by("MEANING", 4, "MRN")), protect
declare cmrn = f8 with constant(uar_get_code_by("MEANING", 4, "CMRN")), protect
 
SELECT INTO "NL:"
	P.NAME_FULL_FORMATTED
	, P.BIRTH_DT_TM
	, P_SEX_DISP = UAR_GET_CODE_DISPLAY(P.SEX_CD)
	, P.PERSON_ID
	, P.CREATE_DT_TM
	, P.UPDT_DT_TM
	, SSN = SSN.ALIAS
	, CMRN = CMRN.ALIAS
	, NEXTGEN_PERSON_NBR = NGPN.ALIAS
 
FROM
	PERSON   P
	, PERSON_ALIAS   SSN
	, PERSON_ALIAS   CMRN
	, PERSON_ALIAS   NGPN
	, PERSON_PATIENT   PP
 
PLAN P
WHERE p.person_id > 0
 
;WHERE p.person_id = 16570266
;AND p.name_full_formatted LIKE "*PARMALEE*DARWIN*"
JOIN PP WHERE pp.person_id = p.person_id
JOIN      SSN
WHERE SSN.person_id = OUTERJOIN(p.person_id)
AND     SSN.person_alias_type_cd = OUTERJOIN(SSN)
AND       SSN.alias_pool_cd = outerjoin(ssn_pool)
AND       ssn.active_ind = OUTERJOIN(1)
JOIN      CMRN
WHERE CMRN.person_id = OUTERJOIN(p.person_id)
AND     CMRN.person_alias_type_cd = OUTERJOIN(CMRN)
AND       CMRN.alias_pool_cd = outerjoin(CMRN_pool)
AND       CMRN.active_ind = OUTERJOIN(1)
JOIN      NGPN
WHERE NGPN.person_id = p.person_id
;AND     NGPN.person_alias_type_cd = OUTERJOIN(NGPN)
AND       NGPN.alias_pool_cd = NGPN_pool
AND       NGPN.active_ind = 1
 
ORDER BY
	P.NAME_FULL_FORMATTED
	, SSN
	, CMRN
	, NEXTGEN_PERSON_NBR
 
 
HEAD REPORT
	stat = MakeDataSet(100)
 
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
 
WITH MAXREC = 350000, NOCOUNTER, SEPARATOR=" ", FORMAT
 
END GO
 

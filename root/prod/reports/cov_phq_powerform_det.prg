/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Sep'2021
	Solution:			Quality
	Source file name:  	cov_phq_powerform_det.prg
	Object name:		cov_phq_powerform_det
	CR#:				11252
	Program purpose:		Quality
	Executing from:		CCL/DA2
  	Special Notes:
 
*****************************************************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  -----------  -------------------------------------------------------------------------
 
   CR# 11252    09/21/21    Geetha   Initial release
 
*******************************************************************************************************************/
 
 
drop program cov_phq_powerform_det:dba go
create program cov_phq_powerform_det:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Form Selection" = 0 

with OUTDEV, start_datetime, end_datetime, dcp_form_id
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ed_pf_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "ED Behavioral Health Call Log")),protect
 
 
/**************************************************************
; CCL CODE HERE
**************************************************************/
 
select distinct into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd), fin = trim(ea.alias),patient = p.name_full_formatted
,ce.event_end_dt_tm, performed_by = pr.name_full_formatted
,form = uar_get_code_display(ce.event_cd)
 
from encounter e
	, person p
	, encntr_alias ea
	, clinical_event ce
	, prsnl pr
	, dcp_forms_activity dfa
	, dcp_forms_ref dfr


plan dfr where dfr.active_ind=1
	and dfr.dcp_form_instance_id = $dcp_form_id

join dfa where dfa.dcp_forms_ref_id = dfr.dcp_forms_ref_id
	and dfa.active_ind = 1
 
join ce where ce.encntr_id = dfa.encntr_id
	and ce.event_cd = dfr.event_cd
	;and ce.event_cd = 2557595361.00 ;ED Behavioral Health Call Log
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
join e where e.encntr_id = ce.encntr_id
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr where ce.performed_prsnl_id = pr.person_id
	and pr.active_ind = 1
 
order by facility, ce.encntr_id, ce.event_id
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
end go
 
 
 
 
 
 
;*********************** Powerform Build Detail Report **************************************************************************
 
;drop program cov_powerform_audit_alpha:dba go
;create program cov_powerform_audit_alpha:dba
 
/*
 
call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif
 
call set_codevalues(null)
call check_ops(null)
 
free set t_rec
record t_rec
(
	1 cnt			= i4
)
 
 
 
SELECT DISTINCT into $OUTDEV
 
        FORM_DESCRIPTION=trim(F.DESCRIPTION),
 
        FORM_DEFINITION=trim(f.definition),
 
        FORM_ID = f.dcp_form_instance_id,
 
        SECTION_DESC=SUBSTRING(1,50,S.DESCRIPTION),
 
        DTA_DESC=DTA.DESCRIPTION,
 
        DTA_MNEM=DTA.MNEMONIC,
 
        DTA.task_assay_cd,
 
		V5C.event_cd,
 
	EVSET_NAME=SUBSTRING(1,40,V5C.EVENT_SET_NAME),
 
        ALPHA_RESPONSE=SUBSTRING(1,50,A.DESCRIPTION),
 
        NOMEN_MNEM=N.MNEMONIC,
 
        NOMEN_STSTRING=N.SHORT_STRING,
 
        NOMEN_SOURCESRG=N.SOURCE_STRING,
 
        ALPHA_NOMEN_ID=A.NOMENCLATURE_ID
        , def.pvc_name
        , def.pvc_value
        , def.updt_dt_tm ";;q"
        , p1.name_full_formatted
 
 
 
 
FROM    DCP_FORMS_DEF D,
 
        DCP_FORMS_REF F,
 
        DCP_SECTION_REF S,
 
        DCP_INPUT_REF I,
 
        NAME_VALUE_PREFS PRF,
 
        DISCRETE_TASK_ASSAY DTA,
 
        V500_EVENT_CODE V5C,
 
	REFERENCE_RANGE_FACTOR R,
 
        ALPHA_RESPONSES A,
 
        prsnl p1,
 
        (DUMMYT D1 WITH SEQ=1),
 
        NOMENCLATURE N,
 
        DUMMYT D2,
 
        name_value_prefs   def
 
PLAN F
 
WHERE F.ACTIVE_IND=1
and f.dcp_form_instance_id = $DCP_FORM_ID
 
JOIN D WHERE F.DCP_FORM_INSTANCE_ID = D.DCP_FORM_INSTANCE_ID
 
AND D.ACTIVE_IND=1
 
JOIN S WHERE S.DCP_SECTION_REF_ID = D.DCP_SECTION_REF_ID
 
AND S.ACTIVE_IND=1
 
JOIN I WHERE I.DCP_SECTION_INSTANCE_ID = S.DCP_SECTION_INSTANCE_ID
 
AND I.ACTIVE_IND=1
 
JOIN PRF WHERE I.DCP_INPUT_REF_ID = PRF.PARENT_ENTITY_ID
 
AND PRF.ACTIVE_IND=1
 
JOIN dta WHERE PRF.MERGE_ID = DTA.TASK_ASSAY_CD
 
AND DTA.ACTIVE_IND=1
;and dta.task_assay_cd = 31981115
 
 
 
join def where def.parent_entity_id = outerjoin(i.dcp_input_ref_id)
           and def.parent_entity_name = outerjoin("DCP_INPUT_REF")
           and def.pvc_name = outerjoin("*default*")
           and def.active_ind = outerjoin(1)
join p1 where p1.person_id = def.updt_id
JOIN D1
 
JOIN V5C WHERE DTA.EVENT_CD = V5C.EVENT_CD
 
JOIN R WHERE DTA.TASK_ASSAY_CD = R.TASK_ASSAY_CD
 
AND R.ACTIVE_IND = 1
 
JOIN D2
 
JOIN A WHERE R.REFERENCE_RANGE_FACTOR_ID = A.REFERENCE_RANGE_FACTOR_ID
 
JOIN N WHERE A.NOMENCLATURE_ID = N.NOMENCLATURE_ID
;and n.source_string = "Rehab*"
 
 
ORDER BY F.DESCRIPTION, S.DESCRIPTION, DTA.DESCRIPTION, V5C.EVENT_SET_NAME,
   ALPHA_RESPONSE,
 
        NOMEN_MNEM,
 
        NOMEN_STSTRING,
 
        NOMEN_SOURCESRG,
 
        ALPHA_NOMEN_ID
WITH OUTERJOIN=D1,OUTERJOIN=D2, COUNTER, format, separator=" ",uar_code(d)
 
 
 
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)
 
 
end
go
 
 

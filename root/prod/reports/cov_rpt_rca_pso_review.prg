/******************************************Change Log***********************************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         -------------------
1.0		05/28/2018	Ryan Gotsche		CR-2097 - Create PSO Review Report
2.0		06/05/2018	Ryan Gotsche		Modified joins to LEFT JOINs to qualify
3.0		06/26/2018	Ryan Gotsche		Included Transfer Level of Care Order
4.0		07/23/2018	Ryan Gotsche		CR-2593 - Included PSO for BH and Adjustment Order
5.0		07/25/2018	Ryan Gotsche		Included other PSO scoped orders
6.0		08/28/2018	Todd A. Blanchard	Revised CCL structure and included all PSO orders.
7.0		09/18/2018	Todd A. Blanchard	Revised table joins and criteria, and trimmed strings.
8.0		09/19/2018	Todd A. Blanchard	Revised criteria.
9.0		10/10/2018	Todd A. Blanchard	Added columns to output:
											Reg Date Time, Arrival Date Time, Inpatient Date Time,
											Observation Date Time, Outpatient in a Bed Date Time
***************************************************************************************************/
 
 
/***********************Program Notes*************************
Description - Report to display the PSO Orders placed for UM to review
 
Tables read: ORDERS, CODE_VALUE, PERSON, ENCOUNTER, ENCNTR_ALIAS
	ORDER_DETAIL
 
Tables updated: None
**************************************************************/
 
drop program cov_rpt_rca_pso_review:DBA go
create program cov_rpt_rca_pso_review:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = ""
	, "End Date" = ""
 
with OUTDEV, STARTDATE, ENDDATE
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare 200_ADJ_PSO_ADMIT_TO_INPATIENT
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOINPATIENT")), protect ;v6.0
declare 200_ADJ_PSO_ADMIT_TO_INPATIENT_REHAB
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOINPATIENTREHAB")), protect ;v6.0
declare 200_ADJ_PSO_ADMIT_TO_PBH
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOPBH")), protect ;v6.0
;declare 200_ADJ_PSO_ADMIT_TO_PBH_BEHAVIORAL
;	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOPBHBEHAVIORALH")), protect ;v8.0
;declare 200_ADJ_PSO_ADMIT_TO_SENIOR_BEHAVIORAL
;	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOSENIORBEHAVIORA")), protect ;v8.0
declare 200_ADJ_PSO_ADMIT_TO_SKILLED_NURSING
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOSKILLEDNURSING")), protect ;v6.0
declare 200_ADJ_PSO_FOR_SENIOR_BEHAVIORAL
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOFORSENIORBEHAVIORALHEA")), protect ;v6.0
declare 200_ADJ_PSO_OBSERVATION
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOOBSERVATION")), protect ;v6.0
declare 200_ADJ_PSO_OUTPATIENT_FOR_PROC
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOOUTPATIENTFORPROCEDURE")), protect ;v6.0
declare 200_ADJ_PSO_OUTPATIENT_IN_A_BED
	= f8 with Constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOOUTPATIENTINABED")), protect ;v6.0
 
declare 200_BH_30_READMIT = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"BEHAVIORALHEALTH30DAYREADMIT")),protect ;v5.0
declare 200_BH_EMERG_ADM = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"BEHAVIORALHEALTHEMERGENCYADMIT")),protect ;v5.0
declare 200_BH_VOL_ADM = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"BEHAVIORALHEALTHVOLUNTARYADMIT")),protect ;v5.0
 
declare 200_PSO_ADMIT_TO_INP = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOADMITTOINPATIENT")),protect
declare 200_PSO_ADMIT_TO_INP_REHB = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOADMITTOINPATIENTREHAB")),protect
declare 200_PSO_ADMIT_TO_SBU = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOADMITTOSENIORBEHAVIORALHEALTH")),protect ;v4.0
declare 200_PSO_ADMIT_TO_SNF = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOADMITTOSKILLEDNURSINGFACILITY")),protect ;v5.0
declare 200_PSO_OBS = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOOBSERVATION")),protect
declare 200_PSO_OPT_PROC = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOOUTPATIENTFORPROCEDUREORSERVICE")),protect
declare 200_PSO_OPT_BED = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"PSOOUTPATIENTINABED")),protect
 
declare 200_TRANS_LVL = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"TRANSFERPATIENTLEVELOFCARE")),protect ;v3.0
 
declare 319_FIN = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2930")),protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
SELECT INTO $OUTDEV
	patient_name = p.name_full_formatted
	, fin = ea.alias
 
	; v9.0
	, reg_dt_tm				= e.reg_dt_tm "@SHORTDATETIME"
	, arrive_dt_tm			= e.arrive_dt_tm "@SHORTDATETIME"
	, inpat_adm_dt_tm		= evaluate(od.oe_field_meaning, "INPTADMDTETME", trim(od.oe_field_display_value, 3), "")
	, obs_dt_tm				= evaluate2(
								if ((o.catalog_cd = 200_ADJ_PSO_OBSERVATION) or (o.catalog_cd = 200_PSO_OBS))
									trim(od.oe_field_display_value, 3)
								endif
								)
	, outpat_bed_dt_tm		= evaluate(od.oe_field_meaning, "OUTPTBEDDTETME", trim(od.oe_field_display_value, 3), "")
 
	, encntr_type			= trim(uar_get_code_display(e.encntr_type_cd), 3)
	, facility				= trim(uar_get_code_display(e.loc_facility_cd), 3)
	, unit					= trim(uar_get_code_display(e.loc_nurse_unit_cd), 3)
	, order_mnemonic		= trim(o.order_mnemonic, 3)
	, pso_ord_dt_tm			= o.orig_order_dt_tm "@SHORTDATETIME"
	, pso_request_dt_tm		= trim(od.oe_field_display_value, 3)
 
	, loc_admit_trans_to	= trim(odr.oe_field_display_value, 3)
	, order_status			= trim(uar_get_code_display(o.order_status_cd), 3)
	, disch_dt_tm			= e.disch_dt_tm "@SHORTDATETIME"
	, payor					= trim(hp.plan_name, 3)
	
FROM
	PERSON p
	; v6.0
	, (INNER JOIN ENCOUNTER e on e.person_id = p.person_id
		and e.active_ind = 1
		and e.end_effective_dt_tm > sysdate
		and e.organization_id in (
			select por.organization_id
			from prsnl_org_reltn por
			where por.active_ind = 1
				and por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
				and por.person_id = reqinfo->updt_id))
 
	; v6.0
	, (LEFT JOIN ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.active_ind = 1
		and ea.end_effective_dt_tm > sysdate
		and ea.encntr_alias_type_cd = 319_FIN)
 
	; v6.0
	, (LEFT JOIN ENCNTR_PLAN_RELTN ep on ep.encntr_id = e.encntr_id ;v7.0
		and ep.active_ind = 1
		and ep.end_effective_dt_tm > sysdate
		and ep.priority_seq = 1) ;Primary
 
	; v6.0
	, (LEFT JOIN HEALTH_PLAN hp ON (hp.health_plan_id = ep.health_plan_id
		and hp.active_ind = 1
		and hp.end_effective_dt_tm > sysdate))
 
	; v6.0
	, (INNER JOIN ORDERS o on o.encntr_id = e.encntr_id ;v7.0
		and o.active_ind = 1
		and o.orig_order_dt_tm between cnvtdatetime($STARTDATE) and cnvtdatetime($ENDDATE)
		and o.catalog_cd in (
			200_ADJ_PSO_ADMIT_TO_INPATIENT, ;v6.0
			200_ADJ_PSO_ADMIT_TO_INPATIENT_REHAB, ;v6.0
			200_ADJ_PSO_ADMIT_TO_PBH, ;v6.0
;			200_ADJ_PSO_ADMIT_TO_PBH_BEHAVIORAL, ;v8.0
;			200_ADJ_PSO_ADMIT_TO_SENIOR_BEHAVIORAL, ;v8.0
			200_ADJ_PSO_ADMIT_TO_SKILLED_NURSING, ;v6.0
			200_ADJ_PSO_FOR_SENIOR_BEHAVIORAL, ;v6.0
			200_ADJ_PSO_OBSERVATION, ;v6.0
			200_ADJ_PSO_OUTPATIENT_FOR_PROC, ;v6.0
			200_ADJ_PSO_OUTPATIENT_IN_A_BED, ;v6.0
 
			200_PSO_ADMIT_TO_INP,
			200_PSO_ADMIT_TO_INP_REHB,
			200_PSO_ADMIT_TO_SBU, ;v4.0
			200_PSO_ADMIT_TO_SNF,
			200_PSO_OBS,
			200_PSO_OPT_PROC,
			200_PSO_OPT_BED,
 
			200_BH_30_READMIT, ;v5.0
			200_BH_EMERG_ADM, ;v5.0
			200_BH_VOL_ADM, ;v5.0
 
			200_TRANS_LVL ;v3.0
		))
 
	; v6.0
	, (LEFT JOIN ORDER_DETAIL od on od.order_id = o.order_id ;v7.0
		and od.oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME", "CHARGESTARTDTTM", "OUTPTBEDDTETME")) ;v9.0
 
	; v6.0
	, (LEFT JOIN ORDER_DETAIL odr ON odr.order_id = o.order_id ;v7.0
		and odr.oe_field_meaning in ("ADMITTO", "TRANSFERLOC", "OTHER") ;v8.0
		; v6.0
		and odr.oe_field_id in (
			select oef.oe_field_id
			from ORDER_ENTRY_FIELDS oef
			where ( ;v8.0
				cnvtupper(oef.description) like "*ADMIT TO*"
				or cnvtupper(oef.description) like "*TRANSFER TO*"
				or cnvtupper(oef.description) like "*TRANSFER LOC*"
				)
				and not cnvtupper(oef.description) like "*PRESCRIPT*"
				and oef.oe_field_meaning_id in (
					select ofm.oe_field_meaning_id
					from OE_FIELD_MEANING ofm
					where ofm.oe_field_meaning in ("ADMITTO", "TRANSFERLOC", "OTHER")
				)
		))
 
;Get patient name and filter out test patients
where p.active_ind = 1
	and p.end_effective_dt_tm > sysdate
	and (p.name_last_key != "ZZ*"
	and p.name_last_key != "FFF*"
	and p.name_last_key != "TTTT*")
 
order by
	facility
	, unit
	, patient_name
	, o.orig_order_dt_tm
 
with time=120, nocounter, separator=" ", format
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

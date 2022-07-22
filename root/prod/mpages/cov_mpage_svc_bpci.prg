/*****************************************************************************
  Covenant Health InformatiON Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author: Todd A. Blanchard
  Date Written: 12/10/2019
  Solution: Revenue Cycle - Acute Care Management
  Source file name: cov_mpage_svc_bpci.prg
  Object name: cov_mpage_svc_bpci
  Request #: 6683
 
  Program purpose:  Lists patient populations for BPCI bundles.
 
  Executing from:   CCL
 
  Special Notes:    Called by mPages.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
    Mod Date    Developer             Comment
    ----------  --------------------  --------------------------------------
001 12/30/2019  Mark Maples           Added bundle field.
002 01/13/2020  Todd A. Blanchard     Adjusted DRG codes AND health plans.
003 01/27/2020  Mark Maples           Adjusted DRG pull for Y2020 compared to Y2019 based ON email
                                      from Jenny Moody (Cov Corp, Continuum Of Care) concerning bundle
                                      for Covenant participatiON in Y2020
 
******************************************************************************/
 
DROP PROGRAM cov_mpage_svc_bpci:dba GO
CREATE PROGRAM cov_mpage_svc_bpci:dba
 
PROMPT
  "Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
WITH OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE cmrn_var                = f8 WITH CONSTANT(uar_get_code_by("MEANING", 4, "CMRN"))
DECLARE ssn_var                 = f8 WITH CONSTANT(uar_get_code_by("MEANING", 4, "SSN"))
DECLARE fin_var                 = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
DECLARE inpatient_var           = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 321, "INPATIENT"))
DECLARE discharged_var          = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 261, "DISCHARGED"))
DECLARE covenant_var            = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
DECLARE plan_type_medicare_var  = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 367, "MEDICARE"))
DECLARE fin_class_medicare_var  = f8 WITH CONSTANT(uar_get_code_by("DISPLAYKEY", 354, "MEDICARE"))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select data
SELECT INTO $OUTDEV
    cmrn                = pa.alias
  , patient_name_last   = p.name_last
  , patient_name_first  = p.name_first
  , patient_name_middle = p.name_middle
  , gender              = cva.alias
  , dob                 = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1), "mm/dd/yyyy;;d")
  , ssn                 = pa2.alias
  , marital_status      = uar_get_code_display(p.marital_type_cd)
  , nationality         = uar_get_code_display(p.nationality_cd)
  , language            = uar_get_code_display(p.language_cd)
 
  ;001
  , bundle              = evaluate(n.source_identifier,
 
            /* ************************************************************** */
            /* 003:BELOW:START FOR Y2020 */
            /* ************************************************************** */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       will START to participate in [BPCI_LIVER_DZ] in Y2020
                */
                "441", "BPCI_LIVER_DZ",
                "442", "BPCI_LIVER_DZ",
                "443", "BPCI_LIVER_DZ",
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       will START to participate in [BPCI_SEIZURES] in Y2020
                */
                "100", "BPCI_SEIZURES",
                "101", "BPCI_SEIZURES",
 
            /* ************************************************************** */
            /* 003:BELOW:CONTINUE FOR Y2020 (AND PARTICIPATED IN Y2019) */
            /* ************************************************************** */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will CONTINUE to participate in [BPCI_ACUTE_MI] in Y2020
                */
                "280", "BPCI_ACUTE_MI",
                "281", "BPCI_ACUTE_MI",
                "282", "BPCI_ACUTE_MI",
 
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will CONTINUE to participate in [BPCI_CARDIA_ARRHYTHMIA] in Y2020
                */
                "308", "BPCI_CARDIA_ARRHYTHMIA",
                "309", "BPCI_CARDIA_ARRHYTHMIA",
                "310", "BPCI_CARDIA_ARRHYTHMIA",
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will CONTINUE to participate in [BPCI_GI_HEMORRHAGE] in Y2020
                */
                "377", "BPCI_GI_HEMORRHAGE",
                "378", "BPCI_GI_HEMORRHAGE",
                "379", "BPCI_GI_HEMORRHAGE",
 
            /* ************************************************************** */
            /* 003:BELOW:STOP FOR Y2020 (BUT WAS VALID FOR Y2019) */
            /* ************************************************************** */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_UTI] in Y2020
                "689", "BPCI_UTI",
                "690", "BPCI_UTI",
                */
 
                 /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_MAJOR_JOINT] in Y2020
                "469", "BPCI_MAJOR_JOINT",
                "470", "BPCI_MAJOR_JOINT",
                */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_CHF] in Y2020
                "291", "BPCI_CHF",
                "292", "BPCI_CHF",
                "293", "BPCI_CHF",
                */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_GI_OBSTRUCTION] in Y2020
                "388", "BPCI_GI_OBSTRUCTION",
                "389", "BPCI_GI_OBSTRUCTION",
                "390", "BPCI_GI_OBSTRUCTION",
                */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_HIP_FEMUR] in Y2020
                "480", "BPCI_HIP_FEMUR",
                "481", "BPCI_HIP_FEMUR",
                "482", "BPCI_HIP_FEMUR",
                */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_RENAL_FAILURE] in Y2020
                "682", "BPCI_RENAL_FAILURE",
                "683", "BPCI_RENAL_FAILURE",
                "684", "BPCI_RENAL_FAILURE",
                */
 
                /*
                20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                       we will STOP participation in [BPCI_SIMPLE_PNEUMONIA] in Y2020
                "177", "BPCI_SIMPLE_PNEUMONIA",
                "178", "BPCI_SIMPLE_PNEUMONIA",
                "179", "BPCI_SIMPLE_PNEUMONIA",
                "193", "BPCI_SIMPLE_PNEUMONIA",
                "194", "BPCI_SIMPLE_PNEUMONIA",
                "195", "BPCI_SIMPLE_PNEUMONIA",
                */
 
                "_")
FROM
  ENCOUNTER e
 
  , (INNER JOIN ENCNTR_ALIAS eaf
     ON eaf.encntr_id = e.encntr_id
        AND eaf.encntr_alias_type_cd = fin_var
        AND eaf.end_effective_dt_tm > sysdate
        AND eaf.active_ind = 1)
 
  , (INNER JOIN DRG d
     ON d.encntr_id = e.encntr_id
        AND d.end_effective_dt_tm > sysdate
        AND d.active_ind = 1)
 
  , (INNER JOIN NOMENCLATURE n
     ON n.nomenclature_id = d.nomenclature_id
     AND n.source_identifier in (
                                 /*
                                 20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                                        will START to participate in items below in Y2020
                                 */
                                 "441", "442", "443",   ; 003:START Y2020:LIVER DZ (EXCEPT MALIGNANCY/ETOH CIRRHOSIS)
                                 "100", "101",          ; 003:START Y2020:SEIZURES
 
                                 /*
                                 20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                                        we will CONTINUE to participate in items in Y2020
                                 */
                                 "280", "281", "282",  ; 003:CONTINUE Y2020:ACUTE MI
                                 "308", "309", "310",  ; 003:CONTINUE Y2020:CARDIAC ARRHYTHMIA
                                 "377", "378", "379"   ; 003:CONTINUE Y2020:GI HEMORRHAGE
 
                                 /*
                                 20200127: Mark Maples: Per Jenny Moody (Cov Corp, Continuum Of Care)
                                                        we will STOP participation in items below in Y2020
                                 "689", "690",         ; 003:STOP Y2020:UTI
                                 "469", "470",         ; 003:STOP Y2020:MAJOR JOINT REPLACEMENT OF LE -NO FRACTURE
                                 "291", "292", "293",  ; 003:STOP Y2020:CHF
                                 "388", "389", "390",  ; 003:STOP Y2020:GI OBSTRUCTION
                                 "480", "481", "482",  ; 003:STOP Y2020:HIP/FEMUR PROCEDURE EXCEPT MAJOR JOINT
                                 "682", "683", "684",  ; 003:STOP Y2020:RENAL FAILURE
                                 "177", "178", "179", "193", "194", "195", ; 003:STOP Y2020:SIMPLE PNEUMONIA & RESPIR
                                 */
                                )
    )
 
  , (INNER JOIN PERSON p
     ON p.person_id = e.person_id
     AND p.end_effective_dt_tm > sysdate
     AND p.active_ind = 1)
 
  , (LEFT JOIN CODE_VALUE_ALIAS cva
     ON cva.code_value = p.sex_cd
        AND cva.code_set = 57
        AND cva.contributor_source_cd = covenant_var
    )
 
  , (LEFT JOIN PERSON_ALIAS pa
     ON pa.person_id = p.person_id
     AND pa.person_alias_type_cd = cmrn_var
     AND pa.end_effective_dt_tm > sysdate
     AND pa.active_ind = 1
    )
 
  , (LEFT JOIN PERSON_ALIAS pa2
     ON pa2.person_id = p.person_id
        AND pa2.person_alias_type_cd = ssn_var
        AND pa2.end_effective_dt_tm > sysdate
        AND pa2.active_ind = 1
    )
 
  , (INNER JOIN ENCNTR_PLAN_RELTN epr
     ON epr.encntr_id = e.encntr_id
        AND epr.priority_seq = 1
        AND epr.beg_effective_dt_tm <= e.reg_dt_tm
        AND epr.end_effective_dt_tm >= e.reg_dt_tm
        AND epr.active_ind = 1
    )
 
  , (INNER JOIN HEALTH_PLAN hp
     ON hp.health_plan_id = epr.health_plan_id
    ;002
     AND (hp.plan_type_cd = plan_type_medicare_var
          or hp.financial_class_cd = fin_class_medicare_var
         )
     AND hp.beg_effective_dt_tm <= e.reg_dt_tm
     AND hp.end_effective_dt_tm >= e.reg_dt_tm
     AND hp.active_ind = 1
    )
WHERE
  e.encntr_class_cd = inpatient_var
  AND e.encntr_status_cd != discharged_var
  AND e.loc_facility_cd in (2552503635.00,  ; FLMC
                            2552503653.00,  ; LCMC
                            2552503639.00,  ; MHHS
                            2552503613.00,  ; MMC
                            2552503649.00   ; RMC
                          )
ORDER BY
  p.name_full_formatted
  , p.person_id
 
;WITH NOCOUNTER, FORMAT, SEPARATOR = " ", TIME = 60
WITH NOCOUNTER, FORMAT, SEPARATOR = "|", NOHEADING, TIME = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
END
GO

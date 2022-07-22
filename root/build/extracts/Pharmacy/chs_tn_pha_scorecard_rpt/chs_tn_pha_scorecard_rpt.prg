/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:       chs_tn_pha_scorecard_rpt.prg
        Object name:            chs_tn_pha_scorecard_rpt
        Request #:
 
        Product:                PharmNet
        Product Team:
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Pharmacy extract (data dump) of drug information
                                to be inputted into a separate Scorecard system
                                per CHS_TN.
 
        Tables read:
 
        Tables updated:         None
 
        Executing from:         explorermenu
                                ,operations
 
        Special Notes:          This program uses the experimental executable
                                ccps_parse_date_prompt_prg.
 
******************************************************************************/
 
 
;~DB~*************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG               *
;    *************************************************************************
;    *                                                                       *
;    *Mod Date     Engineer     Comment                                      *
;    *--- -------- ------------ -------------------------------------------- *
;    *001 12/28/14 RS049105     CCPS-13468 Initial Release                   *
;~DE~*************************************************************************
drop program chs_tn_pha_scorecard_rpt:dba go
create program chs_tn_pha_scorecard_rpt:dba
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Begin Date:" = ""
	, "End Date:" = "CURDATE"
	, "Generate File:" = 0
 
with OUTDEV, BEGIN_DT, END_DT, TO_FILE
 
/*****************************************************************************
    Include Files
*****************************************************************************/
;CCPS Reusables
%i ccluserdir:ccps_script_logging.inc        ;Error and message logging
%i ccluserdir:ccps_parse_date_subs.inc       ;Date prompt parsing
 
/*****************************************************************************
    Global Variables
*****************************************************************************/
declare active        = i2 with protect, constant(1)
declare display_msg   = vc with protect, noconstant("")
declare date_time_fmt = vc with protect, constant("MM/DD/YYYY HH:MM;;Q")
 
/*****************************************************************************
    Test File
*****************************************************************************/
;set ccps_debug = 3 go
;execute chs_tn_pha_scorecard_rpt "MINE","CURDATE-1","CURDATE",0 go
 
/*****************************************************************************
    Record Structures
*****************************************************************************/
if(not validate(pha_data))
    record pha_data
    (
        1 qual_cnt                   = i4
        1 qual[*]
            2 encntr_id               = f8 ;Primary keys
            2 encntr_alias_id         = f8
            2 event_id                = f8
            2 clinical_event_id       = f8
            2 person_id               = f8
            2 person_alias_id         = f8
            2 charge_item_id          = f8
            2 bill_item_id            = f8
            2 bill_item_mod_id        = f8
            2 item_id                 = f8
            2 task_id                 = f8
            2 organization_id         = f8
            2 order_id                = f8
            2 order_action_id         = f8
            2 order_prod_id           = f8
            2 template_order_id       = f8
            2 prsnl_alias_id          = f8
            2 phys_person_id          = f8
            2 ordered_by_id           = f8
            2 synonym_id              = f8
            2 facility_cd             = vc ;Extract attributes
            2 fin                     = vc
            2 cmrn                    = vc
            2 item_number             = vc
            2 charge_entered_dt       = dq8
            2 charged_dt              = dq8
            2 order_display           = vc
            2 drug_generic_name       = vc
            2 drug_brand_name         = vc
            2 strength_dose           = vc
            2 strength_dose_unit      = vc
            2 route_of_admin          = vc
            2 volume_dose             = vc
            2 volume_dose_unit        = vc
            2 rate                    = vc
            2 rate_unit               = vc
            2 normalized_rate         = vc
            2 normalized_rate_unit    = vc
            2 drug_form               = vc
            2 quantity_doses_charged  = f8
            2 frequency_code          = f8
            2 frequency_display       = vc
            2 duration                = vc
            2 drug_class_code1        = vc
            2 drug_class_description1 = vc
            2 drug_class_code2        = vc
            2 drug_class_description2 = vc
            2 drug_class_code3        = vc
            2 drug_class_description3 = vc
            2 physician_number        = vc
            2 personnel_username      = vc
            2 mrn                     = vc ;Additional attributes
            2 d_number                = vc
            2 multm_main_drug_code    = i4
            2 multm_flag              = i2
            2 data_origin             = vc
            2 category_cd             = f8
            2 result_status_cd        = f8
            2 item_id_flag            = i2
            2 template_order_flag     = i4
            2 volume_dose_flag        = i2
            2 strength_dose_flag      = i2
    )
endif
 
;Data from Acudose
if(not validate(acudose_data))
    record acudose_data
    (
        1 qual_cnt                   = i4
        1 qual[*]
            2 encntr_id               = f8 ;Primary keys
            2 encntr_alias_id         = f8
            2 event_id                = f8
            2 clinical_event_id       = f8
            2 person_id               = f8
            2 person_alias_id         = f8
            2 charge_item_id          = f8
            2 bill_item_id            = f8
            2 bill_item_mod_id        = f8
            2 item_id                 = f8
            2 task_id                 = f8
            2 organization_id         = f8
            2 order_id                = f8
            2 order_action_id         = f8
            2 order_prod_id           = f8
            2 template_order_id       = f8
            2 prsnl_alias_id          = f8
            2 phys_person_id          = f8
            2 ordered_by_id           = f8
            2 synonym_id              = f8
            2 facility_cd             = vc ;Extract attributes
            2 fin                     = vc
            2 cmrn                    = vc
            2 item_number             = vc
            2 charge_entered_dt       = dq8
            2 charged_dt              = dq8
            2 order_display           = vc
            2 drug_generic_name       = vc
            2 drug_brand_name         = vc
            2 strength_dose           = vc
            2 strength_dose_unit      = vc
            2 route_of_admin          = vc
            2 volume_dose             = vc
            2 volume_dose_unit        = vc
            2 rate                    = vc
            2 rate_unit               = vc
            2 normalized_rate         = vc
            2 normalized_rate_unit    = vc
            2 drug_form               = vc
            2 quantity_doses_charged  = f8
            2 frequency_code          = f8
            2 frequency_display       = vc
            2 duration                = vc
            2 drug_class_code1        = vc
            2 drug_class_description1 = vc
            2 drug_class_code2        = vc
            2 drug_class_description2 = vc
            2 drug_class_code3        = vc
            2 drug_class_description3 = vc
            2 physician_number        = vc
            2 personnel_username      = vc
            2 mrn                     = vc ;Additional attributes
            2 d_number                = vc
            2 multm_main_drug_code    = i4
            2 multm_flag              = i2
            2 data_origin             = vc
            2 category_cd             = f8
            2 result_status_cd        = f8
            2 item_id_flag            = i2
            2 template_order_flag     = i4
            2 volume_dose_flag        = i2
            2 strength_dose_flag      = i2
    )
endif
 
;Data from Acudose
if(not validate(charge_credit_data))
    record charge_credit_data
    (
        1 qual_cnt                   = i4
        1 qual[*]
            2 encntr_id               = f8 ;Primary keys
            2 encntr_alias_id         = f8
            2 event_id                = f8
            2 clinical_event_id       = f8
            2 person_id               = f8
            2 person_alias_id         = f8
            2 charge_item_id          = f8
            2 bill_item_id            = f8
            2 bill_item_mod_id        = f8
            2 item_id                 = f8
            2 task_id                 = f8
            2 organization_id         = f8
            2 order_id                = f8
            2 order_action_id         = f8
            2 order_prod_id           = f8
            2 template_order_id       = f8
            2 prsnl_alias_id          = f8
            2 phys_person_id          = f8
            2 ordered_by_id           = f8
            2 synonym_id              = f8
            2 facility_cd             = vc ;Extract attributes
            2 fin                     = vc
            2 cmrn                    = vc
            2 item_number             = vc
            2 charge_entered_dt       = dq8
            2 charged_dt              = dq8
            2 order_display           = vc
            2 drug_generic_name       = vc
            2 drug_brand_name         = vc
            2 strength_dose           = vc
            2 strength_dose_unit      = vc
            2 route_of_admin          = vc
            2 volume_dose             = vc
            2 volume_dose_unit        = vc
            2 rate                    = vc
            2 rate_unit               = vc
            2 normalized_rate         = vc
            2 normalized_rate_unit    = vc
            2 drug_form               = vc
            2 quantity_doses_charged  = f8
            2 frequency_code          = f8
            2 frequency_display       = vc
            2 duration                = vc
            2 drug_class_code1        = vc
            2 drug_class_description1 = vc
            2 drug_class_code2        = vc
            2 drug_class_description2 = vc
            2 drug_class_code3        = vc
            2 drug_class_description3 = vc
            2 physician_number        = vc
            2 personnel_username      = vc
            2 mrn                     = vc ;Additional attributes
            2 d_number                = vc
            2 multm_main_drug_code    = i4
            2 multm_flag              = i2
            2 data_origin             = vc
            2 category_cd             = f8
            2 result_status_cd        = f8
            2 item_id_flag            = i2
            2 template_order_flag     = i4
            2 volume_dose_flag        = i2
            2 strength_dose_flag      = i2
    )
endif
/*****************************************************************************
    Subroutine Declaration
*****************************************************************************/
declare GetMedAminData        (null) = i2
declare GetAcudoseData        (null) = i2
declare GetChargeCreditData   (null) = i2
declare GetOrderIngredientData(null) = i2
declare GetOrderProductData   (null) = i2
declare GetOrderDetailData    (null) = i2
declare GetDrugSynonymData    (null) = i2
declare GetDrugIdentifierData (null) = i2
declare GetDrugClassData      (null) = i2
declare GetChargeData         (null) = i2
declare GetFINMRNData         (null) = i2
declare GetCMRNData           (null) = i2
declare GetPhysicianData      (null) = i2
declare GetOrderingUsername   (null) = i2
declare GetFacilityAlias      (null) = i2
declare OutputToFile          (null) = i2
declare OutputToScreen        (null) = i2
 
/*****************************************************************************
    Main Program
*****************************************************************************/
;Determine from ops
if(not(validate(is_ops_job)))
    declare is_ops_job = i2 with protect, noconstant(0)
    if(validate(request->batch_selection))
        set is_ops_job = 1
        call logMsg(build2("IS_OPS_JOB: ",is_ops_job))
    endif
endif
 
;Prompt validation
if(is_ops_job = true)
    ;If ops, run the previous day, usual scenario
    call logMsg("Extract is being ran from ops...")
    declare start_dt = dq8 with protect, constant(ParseDateOperations("CURDATE-1",B,B))
    declare end_dt   = dq8 with protect, constant(ParseDateOperations("CURDATE-1",E,E))
else
    ;Ran ad hoc
    call logMsg("Extract is being ran from the front end...")
    declare start_dt = dq8 with protect, constant(ParseDatePrompt($BEGIN_DT,CURDATE,0))
    declare end_dt   = dq8 with protect, constant(ParseDatePrompt($END_DT,CURDATE,235959))
endif
 
;Log prompts
call logMsg(build2("start_dt: ",start_dt))
call logMsg(build2("end_dt:   ",end_dt))
 
;GetMedAminData
if(not(GetMedAminData(null)))
    call logMsg("Failed to load Med Admin data, going to exit script...")
    set display_msg = "Failed to load med admin data"
    go to exit_script
endif
 
;GetAcudoseData
if(not(GetAcudoseData(null)))
    call logMsg("Failed to load Acudose data, going to exit script...")
    set display_msg = "Failed to load Acudose data"
    go to exit_script
endif
 
;GetChargeCreditData
if(not(GetChargeCreditData(null)))
    call logMsg("Failed to load Charge Credit data, going to exit script...")
    set display_msg = "Failed to load Charge Credit data"
    go to exit_script
endif
 
;GetOrderIngredientData
if(not(GetOrderIngredientData(null)))
    call logMsg("Failed to load Order Ingredient data, going to exit script...")
    set display_msg = "Failed to load Order Ingredient data"
    go to exit_script
endif
 
;GetOrderProductData
if(not(GetOrderProductData(null)))
    call logMsg("Failed to load Order Product data, going to exit script...")
    set display_msg = "Failed to load Order Product data"
    go to exit_script
endif
 
;GetOrderDetailData
if(not(GetOrderDetailData(null)))
    call logMsg("Failed to load Order Detail data, going to exit script...")
    set display_msg = "Failed to load Order Detail data"
    go to exit_script
endif
 
;GetDrugSynonymData
if(not(GetDrugSynonymData(null)))
    call logMsg("Failed to load Drug Synonym data, going to exit script...")
    set display_msg = "Failed to load Drug Synonym data"
    go to exit_script
endif
 
;GetDrugIdentifierData
if(not(GetDrugIdentifierData(null)))
    call logMsg("Failed to load Drug Identifier data, going to exit script...")
    set display_msg = "Failed to load Drug Identifier data"
    go to exit_script
endif
 
;GetDrugClassData
if(not(GetDrugClassData(null)))
    call logMsg("Failed to load Drug Class data, going to exit script...")
    set display_msg = "Failed to load Drug Class data"
    go to exit_script
endif
 
;GetChargeData
if(not(GetChargeData(null)))
    call logMsg("Failed to load Charge data, going to exit script...")
    set display_msg = "Failed to load Charge data"
    go to exit_script
endif
 
;GetFINMRNData
if(not(GetFINMRNData(null)))
    call logMsg("Failed to load FIN and MRN data, going to exit script...")
    set display_msg = "Failed to load FIN and MRN data"
    go to exit_script
endif
 
;GetCMRNData
if(not(GetCMRNData(null)))
    call logMsg("Failed to load CMRN data, going to exit script...")
    set display_msg = "Failed to load CMRN data"
    go to exit_script
endif
 
;GetPhysicianData
if(not(GetPhysicianData(null)))
    call logMsg("Failed to load Physician data, going to exit script...")
    set display_msg = "Failed to load Physician data"
    go to exit_script
endif
 
;GetOrderingUsername
if(not(GetOrderingUsername(null)))
    call logMsg("Failed to load ordering personnel username, going to exit script...")
    set display_msg = "Failed to load the ordering personnel's username"
    go to exit_script
endif
 
;GetFacilityAlias
if(not(GetFacilityAlias(null)))
    call logMsg("Failed to load organization alias, going to exit script...")
    set display_msg = "Failed to load the organization alias"
    go to exit_script
endif
 
;Output destination
if($TO_FILE = active)
    call logMsg("Outputting to file...")
    call OutputToFile(null)
else
    call logMsg("Outputting to screen...")
    call OutputToScreen(null)
endif
 
call echorecord(pha_data)
 
call echo("001 12/28/14 RS049105 CCPS-13468 Initial Release") ;last mod
 
return ;End program
 
/*****************************************************************************
    Exit Script
*****************************************************************************/
#exit_script
 
call logMsg("Creating Exit Script...")
 
;Display Exit Script
select into $OUTDEV
from (dummyt d with seq = 1)
plan d
 
head report
  "{CPI/9}{FONT/4}"
 
  row 0, col 0, call print(build2("PROGRAM:  ", cnvtlower(curprog), "       NODE:  ", curnode))
  row + 3
  col 0, call print(display_msg)
  row + 3
  col 0, call print(build2("Number of rows of data found: ",pha_data->qual_cnt))
  row + 3
  col 0, call print(build2("Execution Date/Time:  ", format(cnvtdatetime(curdate,curtime), "mm/dd/yyyy hh:mm:ss;;q")))
 
with nocounter, nullreport, maxcol = 300, dio = postscript
 
call echo("001 12/28/14 RS049105 CCPS-13468 Initial Release") ;last mod
/*****************************************************************************
    Subroutine Implementation
*****************************************************************************/
/*****************************************************************************
*   Name: GetMedAminData(null)
*
*   Description: Main query of the program. Loads basic med admin data
*                data, including primary keys.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: ce_med_result
*   	         ,clinical_event
*   	         ,encounter
*   	         ,orders
*   	         ,order_action
*   	         ,task_activity
*
*****************************************************************************/
subroutine GetMedAminData(null)
    call logMsg("*******Beginning Subroutine: GetMedAminData(null) = i2*******")
 
    ;Local variables
    declare return_ind               = i2 with protect, noconstant(1)
    declare empty                    = i2 with protect, constant(0)
 
    declare strenght_dose            = vc with protect, noconstant("")
    declare IVPARVAR_VC              = vc with protect, constant("IVPARENT")
 
    declare 8_ACTIVE_CD              = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!2627"))
    declare 8_MODIFIED_CD            = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!16901"))
    declare 8_AUTH_CD                = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!2628"))
    declare 24_CHILD_RELTN_CD        = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!2661"))
    declare 54_VOL_ML_RESULT_UNIT_CD = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3780"))
    declare 180_IVWASTEVAR_CD        = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!31649"))
    declare 6000_PHARMACY_VAR_CD     = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3079"))
    declare 6003_ORDER_ACTION_CD     = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3094"))
 
    ;Log coded values
    call logMsg(build2("24_CHILD_RELTN_CD:    ",24_CHILD_RELTN_CD))
    call logMsg(build2("180_IVWASTEVAR_CD:    ",180_IVWASTEVAR_CD))
    call logMsg(build2("6000_PHARMACY_VAR_CD: ",6000_PHARMACY_VAR_CD))
 
    ;Query for drug order and encounter data
    select into "nl:"
    from
    	ce_med_result   cmr
    	,clinical_event ce
    	,encounter      e
    	,orders         o
    	,order_action   oa
    	,task_activity  ta
    plan ce
    	where ce.event_end_dt_tm  between cnvtdatetime(start_dt) and cnvtdatetime(end_dt)
    	and ce.view_level         =  active
    	and ce.publish_flag       =  active
    	and ce.valid_until_dt_tm  =  (cnvtdatetime("31-DEC-2100 00:00:00"))
    	and ce.event_title_text   != IVPARVAR_VC
    	and ce.task_assay_cd      =  empty
    	and ce.event_reltn_cd     =  24_CHILD_RELTN_CD
    	and ce.RESULT_STATUS_CD   IN (8_ACTIVE_CD,8_MODIFIED_CD,8_AUTH_CD)
    join cmr
    	where cmr.event_id        =  outerjoin(ce.event_id)
    	and cmr.event_id          != outerjoin(empty)
    	and cmr.valid_until_dt_tm =  outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    	and cmr.synonym_id        != outerjoin(empty)
    	and cmr.iv_event_cd       != 180_IVWASTEVAR_CD
    join o
    	where o.order_id          =  ce.order_id
    	and o.catalog_type_cd     =  6000_PHARMACY_VAR_CD
    join e
    	where e.encntr_id         =  o.encntr_id
    	and e.active_ind          =  active
    	and e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    	and e.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    join oa
    	where oa.order_id         =  o.order_id
    	and oa.action_sequence    in (select max(oa1.action_sequence)
    							     from order_action oa1
    							     where oa1.order_id = oa.order_id)
    join ta
    	where ta.order_id         =  o.order_id
    order by
        o.order_id
        ,ce.RESULT_STATUS_CD
    head report
        cnt   = 0
    head o.order_id
        null
    head ce.RESULT_STATUS_CD
        cnt     += 1
        if(mod(cnt,100) = 1)
            stat = alterlist(pha_data->qual,cnt + 99)
        endif
 
        ;Primary keys
        pha_data->qual[cnt].encntr_id              = e.ENCNTR_ID
        pha_data->qual[cnt].event_id               = ce.EVENT_ID
        pha_data->qual[cnt].clinical_event_id      = ce.CLINICAL_EVENT_ID
        pha_data->qual[cnt].person_id              = e.PERSON_ID
        pha_data->qual[cnt].task_id                = ta.TASK_ID
        pha_data->qual[cnt].order_id               = o.ORDER_ID
        pha_data->qual[cnt].order_action_id        = oa.ORDER_ACTION_ID
        pha_data->qual[cnt].phys_person_id         = oa.ORDER_PROVIDER_ID
        pha_data->qual[cnt].template_order_id      = o.TEMPLATE_ORDER_ID
        pha_data->qual[cnt].template_order_flag    = o.TEMPLATE_ORDER_FLAG
        pha_data->qual[cnt].organization_id        = e.ORGANIZATION_ID
        pha_data->qual[cnt].ordered_by_id          = oa.ACTION_PERSONNEL_ID
 
        ;Template order id logic
        if(pha_data->qual[cnt].template_order_flag = 4)
            pha_data->qual[cnt].order_prod_id = pha_data->qual[cnt].template_order_id
            pha_data->qual[cnt].order_id      = pha_data->qual[cnt].template_order_id
        else
            pha_data->qual[cnt].order_prod_id = pha_data->qual[cnt].order_id
        endif
 
        ; IV Synonym
        if(o.IV_IND = active)
            pha_data->qual[cnt].synonym_id           = o.IV_SET_SYNONYM_ID
        else
            pha_data->qual[cnt].synonym_id           = o.SYNONYM_ID
        endif
 
        ; Strength dose and units
        if(cmr.ADMIN_DOSAGE > 0.0)
            strength_dose                            = cnvtstring(cmr.ADMIN_DOSAGE)
            if(findstring(".",strength_dose) = 0)
                pha_data->qual[cnt].strength_dose    = strength_dose
            else
                pha_data->qual[cnt].strength_dose    = substring(1,findstring(".",strength_dose)+2,strength_dose)
            endif
            pha_data->qual[cnt].strength_dose_unit   = uar_get_code_display(cmr.DOSAGE_UNIT_CD)
            pha_data->qual[cnt].strength_dose_flag   = 1
        endif
 
        ; Volume dose and units
        if(ce.RESULT_UNITS_CD = 54_VOL_ML_RESULT_UNIT_CD)
            if(cnvtreal(ce.RESULT_VAL) != 0.00)
                if(findstring(".",ce.result_val) = 0)
                    pha_data->qual[cnt].volume_dose  = trim(ce.RESULT_VAL,3)
                else
                    pha_data->qual[cnt].volume_dose  = substring(1,findstring(".",ce.result_val)+2,ce.result_val)
                endif
                pha_data->qual[cnt].volume_dose_unit = uar_get_code_display(ce.RESULT_UNITS_CD)
            endif
        endif
 
        ;Extract attributes
        pha_data->qual[cnt].route_of_admin           = uar_get_code_display(cmr.ADMIN_ROUTE_CD)
        pha_data->qual[cnt].result_status_cd         = ce.RESULT_STATUS_CD
        pha_data->qual[cnt].charge_entered_dt        = o.ORIG_ORDER_DT_TM
        pha_data->qual[cnt].order_display            = trim(o.DEPT_MISC_LINE,3)
        pha_data->qual[cnt].data_origin              = "CLINICAL EVENT"
 
        ;Additional attributes
        d_pos                                        = findstring("!d",o.cki)
        multm_code_pos                               = findstring("!",o.cki)
        cki_len                                      = textlen(o.cki)
        if (d_pos > 0)
            pha_data->qual[cnt].d_number             = trim(substring(d_pos + 1, cki_len, o.cki))
        elseif(multm_code_pos > 0)
            multm_code                               = trim(substring(multm_code_pos + 1, cki_len, o.cki))
            pha_data->qual[cnt].multm_main_drug_code = cnvtint(multm_code)
            pha_data->qual[cnt].multm_flag           = 1
        endif
        pha_data->qual[cnt].category_cd              = o.CATALOG_CD
 
    foot ce.RESULT_STATUS_CD
        null
    foot o.order_id
        null
    foot report
        pha_data->qual_cnt = cnt
        stat = alterlist(pha_data->qual,pha_data->qual_cnt)
    with nocounter
 
    ;Check errors
    if(catchErrors("Error occured in the Clinical Event query!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetMedAminData(null) = i2*******")
    return(return_ind)
end ;subroutine GetMedAminData(null) = i2
 
/*****************************************************************************
*   Name: GetAcudoseData(null)
*
*   Description: Main query of the program. Loads basic med admin data
*                data, including primary keys.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: encounter
*   	         ,orders
*   	         ,order_action
*
*****************************************************************************/
subroutine GetAcudoseData(null)
    call logMsg("*******Beginning Subroutine: GetAcudoseData(null) = i2*******")
 
    ;Local variables
    declare return_ind            = i2 with protect, noconstant(1)
    declare empty                 = i2 with protect, constant(0)
 
    ;Coded values
    declare 89_ACUDOSE_CONTRIB_CD = f8 with protect, constant(GetCodeWithCheck("DISPLAYKEY",89,"ACUDOSE"))
 
    ;Query
    select into "nl:"
    from orders         o
         ,order_action  oa
         ,encounter     e
    plan o  where o.ORIG_ORDER_DT_TM between cnvtdatetime(start_dt) and cnvtdatetime(end_dt)
            and o.CONTRIBUTOR_SYSTEM_CD = 89_ACUDOSE_CONTRIB_CD
            and o.ACTIVE_IND            = active
    join oa where oa.order_id           = o.order_id
    	    and oa.action_sequence in (select max(oa1.action_sequence)
    							     from order_action oa1
    							     where oa1.order_id = oa.order_id)
    join e  where e.ENCNTR_ID           = o.ENCNTR_ID
            and e.ACTIVE_IND            = active
    order by
        o.ORDER_ID
    head report
        cnt = 0
    head o.ORDER_ID
        cnt += 1
        if(mod(cnt,100) = 1)
            stat = alterlist(acudose_data->qual,cnt + 99)
        endif
 
        ;Primary keys
        acudose_data->qual[cnt].encntr_id           = o.ENCNTR_ID
        acudose_data->qual[cnt].person_id           = o.PERSON_ID
        acudose_data->qual[cnt].order_id            = o.ORDER_ID
        acudose_data->qual[cnt].phys_person_id      = oa.ORDER_PROVIDER_ID
        acudose_data->qual[cnt].template_order_id   = o.TEMPLATE_ORDER_ID
        acudose_data->qual[cnt].template_order_flag = o.TEMPLATE_ORDER_FLAG
        acudose_data->qual[cnt].organization_id     = e.ORGANIZATION_ID
        acudose_data->qual[cnt].ordered_by_id       = oa.ACTION_PERSONNEL_ID
 
        ;Template order id logic
        if(acudose_data->qual[cnt].template_order_flag = 4)
            acudose_data->qual[cnt].order_prod_id   = acudose_data->qual[cnt].template_order_id
            acudose_data->qual[cnt].order_id        = acudose_data->qual[cnt].template_order_id
        else
            acudose_data->qual[cnt].order_prod_id   = acudose_data->qual[cnt].order_id
        endif
 
        ; IV Synonym
        if(o.IV_IND = active)
            acudose_data->qual[cnt].synonym_id      = o.IV_SET_SYNONYM_ID
        else
            acudose_data->qual[cnt].synonym_id      = o.SYNONYM_ID
        endif
 
        ;Additional attributes
        d_pos                                       = findstring("!d",o.cki)
        multm_code_pos                              = findstring("!",o.cki)
        cki_len                                     = textlen(o.cki)
        if (d_pos > 0)
            acudose_data->qual[cnt].d_number        = trim(substring(d_pos + 1, cki_len, o.cki))
        elseif(multm_code_pos > 0)
            multm_code                                   = trim(substring(multm_code_pos + 1, cki_len, o.cki))
            acudose_data->qual[cnt].multm_main_drug_code = cnvtint(multm_code)
            acudose_data->qual[cnt].multm_flag           = 1
        endif
        acudose_data->qual[cnt].category_cd         = o.CATALOG_CD
        acudose_data->qual[cnt].charge_entered_dt   = o.ORIG_ORDER_DT_TM
        acudose_data->qual[cnt].order_display       = trim(o.DEPT_MISC_LINE,3)
        acudose_data->qual[cnt].data_origin         = "ACUDOSE"
 
    foot o.order_id
        null
    foot report
        acudose_data->qual_cnt = cnt
        stat = alterlist(acudose_data->qual,acudose_data->qual_cnt)
    with nocounter
 
    ;Check errors
    if(catchErrors("Error occured in the Acudose query!"))
        set return_ind = 0
    endif
 
    ;Copy Acudose data to pha_data
    set stat = movereclist(acudose_data->qual,pha_data->qual,1,pha_data->qual_cnt,acudose_data->qual_cnt,true)
    set pha_data->qual_cnt = size(pha_data->qual,5)
 
    call logMsg("*******End of Subroutine: GetAcudoseData(null) = i2*******")
    return(return_ind)
end ;subroutine GetAcudoseData(null)
 
subroutine GetChargeCreditData(null)
    call logMsg("*******Beginning Subroutine: GetChargeCreditData(null) = i2*******")
 
    ;Local variables
    declare return_ind            = i2 with protect, noconstant(1)
    declare empty                 = i2 with protect, constant(0)
 
    declare charge_credit_app_nbr = i4 with protect, constant(390000)
 
    ;Query
        ;Query
    select into "nl:"
    from orders         o
         ,order_action  oa
         ,application   a
         ,encounter     e
    plan o  where o.ORIG_ORDER_DT_TM between cnvtdatetime(start_dt) and cnvtdatetime(end_dt)
            and o.ACTIVE_IND            = active
    join oa where oa.order_id           = o.order_id
    	    and oa.action_sequence in (select max(oa1.action_sequence)
    							     from order_action oa1
    							     where oa1.order_id = oa.order_id)
    join a  where a.APPLICATION_NUMBER  = oa.ORDER_APP_NBR
            and a.APPLICATION_NUMBER    = charge_credit_app_nbr
    join e  where e.ENCNTR_ID           = o.ENCNTR_ID
            and e.ACTIVE_IND            = active
    order by
        o.ORDER_ID
    head report
        cnt = 0
    head o.ORDER_ID
        cnt += 1
        if(mod(cnt,100) = 1)
            stat = alterlist(charge_credit_data->qual,cnt + 99)
        endif
 
        ;Primary keys
        charge_credit_data->qual[cnt].encntr_id           = o.ENCNTR_ID
        charge_credit_data->qual[cnt].person_id           = o.PERSON_ID
        charge_credit_data->qual[cnt].order_id            = o.ORDER_ID
        charge_credit_data->qual[cnt].phys_person_id      = oa.ORDER_PROVIDER_ID
        charge_credit_data->qual[cnt].template_order_id   = o.TEMPLATE_ORDER_ID
        charge_credit_data->qual[cnt].template_order_flag = o.TEMPLATE_ORDER_FLAG
        charge_credit_data->qual[cnt].organization_id     = e.ORGANIZATION_ID
        charge_credit_data->qual[cnt].ordered_by_id       = oa.ACTION_PERSONNEL_ID
 
        ;Template order id logic
        if(charge_credit_data->qual[cnt].template_order_flag = 4)
            charge_credit_data->qual[cnt].order_prod_id   = charge_credit_data->qual[cnt].template_order_id
            charge_credit_data->qual[cnt].order_id        = charge_credit_data->qual[cnt].template_order_id
        else
            charge_credit_data->qual[cnt].order_prod_id   = charge_credit_data->qual[cnt].order_id
        endif
 
        ; IV Synonym
        if(o.IV_IND = active)
            charge_credit_data->qual[cnt].synonym_id      = o.IV_SET_SYNONYM_ID
        else
            charge_credit_data->qual[cnt].synonym_id      = o.SYNONYM_ID
        endif
 
        ;Additional attributes
        d_pos                                             = findstring("!d",o.cki)
        multm_code_pos                                    = findstring("!",o.cki)
        cki_len                                           = textlen(o.cki)
        if (d_pos > 0)
            charge_credit_data->qual[cnt].d_number        = trim(substring(d_pos + 1, cki_len, o.cki))
        elseif(multm_code_pos > 0)
            multm_code                                         = trim(substring(multm_code_pos + 1, cki_len, o.cki))
            charge_credit_data->qual[cnt].multm_main_drug_code = cnvtint(multm_code)
            charge_credit_data->qual[cnt].multm_flag           = 1
        endif
        charge_credit_data->qual[cnt].category_cd         = o.CATALOG_CD
        charge_credit_data->qual[cnt].charge_entered_dt   = o.ORIG_ORDER_DT_TM
        charge_credit_data->qual[cnt].order_display       = trim(o.DEPT_MISC_LINE,3)
        charge_credit_data->qual[cnt].data_origin         = "CHARGE/CREDIT"
 
    foot o.order_id
        null
    foot report
        charge_credit_data->qual_cnt = cnt
        stat = alterlist(charge_credit_data->qual,charge_credit_data->qual_cnt)
    with nocounter
 
    ;Copy Charge/Credit data to pha_data
    set stat = movereclist(charge_credit_data->qual,pha_data->qual,1,pha_data->qual_cnt,charge_credit_data->qual_cnt,true)
    set pha_data->qual_cnt = size(pha_data->qual,5)
 
    call logMsg("*******End of Subroutine: GetChargeCreditData(null) = i2*******")
    return(return_ind)
end ;subroutine GetChargeCreditData
 
/*****************************************************************************
*   Name: GetOrderIngredientData(null)
*
*   Description: Query to find the strength, volume and normalized rate if the
*                mediciation ordered was apart of an IV or collection of
*                medications.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: order_ingredient oi
*
*****************************************************************************/
subroutine GetOrderIngredientData(null)
    call logMsg("*******Beginning Subroutine: GetOrderIngredientData(null) = i2*******")
 
    ;Local variables
    declare return_ind           = i2 with protect, noconstant(1)
    declare expand_idx           = i4 with protect, noconstant(0)
    declare locate_idx           = i4 with protect, noconstant(0)
    declare pos                  = i4 with protect, noconstant(0)
 
    declare volume_dose          = vc with protect, noconstant("")
    declare volume_dose_unit     = vc with protect, noconstant("")
    declare strength_dose        = vc with protect, noconstant("")
    declare strength_dose_unit   = vc with protect, noconstant("")
    declare normalized_rate      = vc with protect, noconstant("")
    declare normalized_rate_unit = vc with protect, noconstant("")
 
    ;Query
    select into "nl:"
    from order_ingredient oi
    plan oi where expand(expand_idx,1,pha_data->qual_cnt,oi.order_id,pha_data->qual[expand_idx].order_id)
    order by
        oi.order_id
        ,oi.SYNONYM_ID
        ,oi.action_sequence desc
    head oi.ORDER_ID
        null
    head oi.SYNONYM_ID
        volume_dose          = ""
        volume_dose_unit     = ""
        strength_dose        = ""
        strength_dose_unit   = ""
        normalized_rate      = ""
        normalized_rate_unit = ""
    detail
        volume_dose          = build(oi.volume)
        volume_dose_unit     = trim(uar_get_code_display(oi.VOLUME_UNIT),3)
        strength_dose        = build(oi.STRENGTH)
        strength_dose_unit   = trim(uar_get_code_display(oi.STRENGTH_UNIT),3)
        normalized_rate      = build(oi.NORMALIZED_RATE)
        normalized_rate_unit = trim(uar_get_code_display(oi.NORMALIZED_RATE_UNIT_CD),3)
    foot oi.SYNONYM_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,oi.order_id,pha_data->qual[locate_idx].order_id)
        while(pos > 0)
            ;Volume dose
            if(textlen(trim(pha_data->qual[pos].volume_dose,3)) = 0)
                if(cnvtreal(volume_dose) != 0.00)
                    if(findstring(".",volume_dose) = 0)
                        pha_data->qual[pos].volume_dose  = volume_dose ;volume dose
                    else
                        pha_data->qual[pos].volume_dose  = substring(1,findstring(".",volume_dose)+2,volume_dose)
                    endif
                    pha_data->qual[pos].volume_dose_unit = volume_dose_unit
			        pha_data->qual[pos].volume_dose_flag = 1
                endif
            endif
 
            ;Strength dose
            if(textlen(trim(pha_data->qual[pos].strength_dose,3)) = 0)
                if(cnvtreal(strength_dose) != 0.00)
                     if(findstring(".",strength_dose) = 0)
                        pha_data->qual[pos].strength_dose  = strength_dose
                     else
                        pha_data->qual[pos].strength_dose  = substring(1,findstring(".",strength_dose)+2,strength_dose)
                     endif
                     pha_data->qual[pos].strength_dose_unit = strength_dose_unit
    				 pha_data->qual[pos].strength_dose_flag = 1
                endif
            endif
 
            ;Normalized rate
            if(textlen(trim(pha_data->qual[pos].normalized_rate,3)) = 0)
                if(cnvtreal(normalized_rate) != 0.0)
                    if(findstring(".",normalized_rate) = 0)
                        pha_data->qual[pos].normalized_rate  = normalized_rate
                    else
                        pha_data->qual[pos].normalized_rate  = substring(1,findstring(".",normalized_rate)+2,normalized_rate)
                    endif
                     pha_data->qual[pos].normalized_rate_unit = normalized_rate_unit
                endif
            endif
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,oi.order_id,pha_data->qual[locate_idx].order_id)
        endwhile
    foot oi.ORDER_ID
        null
    with nocounter,expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetOrderIngredientData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetOrderIngredientData(null) = i2*******")
    return(return_ind)
end ;subroutine GetOrderIngredientData(null)
 
/*****************************************************************************
*   Name: GetOrderProductData(null)
*
*   Description: Gather the item id from how the product was ordered for
*                generic and brand names. This situation, the ordered
*                product is a combination of medications.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: order_product op
*
*****************************************************************************/
subroutine GetOrderProductData(null)
    call logMsg("*******Beginning Subroutine: GetOrderProductData(null) = i2*******")
 
    ;Local variables
    declare return_ind          = i2 with protect, noconstant(1)
    declare expand_idx          = i4 with protect, noconstant(0)
    declare locate_idx          = i4 with protect, noconstant(0)
    declare pos                 = i4 with protect, noconstant(0)
 
    declare 8_inerror_result_status_cd = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!7982"))
 
    call logMsg(build2("8_inerror_result_status_cd: ",8_inerror_result_status_cd))
 
    ;Query
    select into "nl:"
    from
	   order_product op
    plan op where expand(expand_idx, 1, pha_data->qual_cnt, op.order_id, pha_data->qual[expand_idx].order_prod_id)
    order by
	   op.order_id
	   ,op.action_sequence desc
	head op.ORDER_ID
	   pos = locateval(locate_idx, 1, pha_data->qual_cnt, op.order_id, pha_data->qual[locate_idx].order_prod_id)
 
	   while(pos > 0)
	       pha_data->qual[pos].item_id = op.ITEM_ID
	       if(pha_data->qual[pos].item_id > 0)
	           pha_data->qual[pos].item_id_flag = 1
	       endif
 
    	   ;The administration was uncharted so it will be credited.
    	   if(pha_data->qual[pos].result_status_cd = 8_inerror_result_status_cd)
    		   pha_data->qual[pos].volume_dose      = cnvtstring(ceil(op.dose_quantity * - 1))
    		   pha_data->qual[pos].volume_dose_unit = uar_get_code_display(op.dose_quantity_unit_cd)
    	   else
    		   pha_data->qual[pos].volume_dose      = cnvtstring(ceil(op.dose_quantity))
    		   pha_data->qual[pos].volume_dose_unit = uar_get_code_display(op.dose_quantity_unit_cd)
    	   endif
 
	       pos = locateval(locate_idx,pos+1, pha_data->qual_cnt, op.order_id, pha_data->qual[locate_idx].order_prod_id)
	   endwhile
 
	head op.ACTION_SEQUENCE
	   null
	foot op.ACTION_SEQUENCE
	   null
	foot op.ORDER_ID
	   null
	with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetOrderProductData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetOrderProductData(null) = i2*******")
    return(return_ind)
end ;subroutine GetOrderProductData(null)
 
/*****************************************************************************
*   Name: GetOrderDetailData(null)
*
*   Description: Load order detail including: frequency, dose strength
*                , dose volume, and drug form.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: order_detail
*
*****************************************************************************/
subroutine GetOrderDetailData(null)
    call logMsg("*******Beginning Subroutine: GetOrderDetailData(null) = i2*******")
 
    ;Local variables
    declare return_ind          = i2 with protect, noconstant(1)
    declare expand_idx          = i4 with protect, noconstant(0)
    declare locate_idx          = i4 with protect, noconstant(0)
    declare pos                 = i4 with protect, noconstant(0)
 
    declare frequency_code      = f8 with protect, noconstant(0.0)
    declare frequency           = vc with protect, noconstant("")
    declare strength_dose       = vc with protect, noconstant("")
    declare strength_dose_unit  = vc with protect, noconstant("")
    declare volume_dose         = vc with protect, noconstant("")
    declare volume_dose_unit    = vc with protect, noconstant("")
    declare drug_form           = vc with protect, noconstant("")
    declare duration            = vc with protect, noconstant("")
    declare duration_unit       = vc with protect, noconstant("")
    declare rate                = vc with protect, noconstant("")
    declare rate_unit           = vc with protect, noconstant("")
    declare route               = vc with protect, noconstant("")
 
    declare OE_FREQ             = f8 with protect, constant(12690.00)
    declare OE_STRENGTHDOSE     = f8 with protect, constant(12715.00)
    declare OE_STRENGTHDOSEUNIT = f8 with protect, constant(12716.00)
    declare OE_VOLUMEDOSE       = f8 with protect, constant(12718.00)
    declare OE_VOLUMEDOSEUNIT   = f8 with protect, constant(12719.00)
    declare OE_DRUGFORM         = f8 with protect, constant(12693.00)
    declare OE_DURATION         = f8 with protect, constant(12721.00)
    declare OE_DURATIONUNIT     = f8 with protect, constant(12723.00)
    declare OE_RXROUTE          = f8 with protect, constant(12711.00)
    declare OE_RATE             = f8 with protect, constant(12704.00)
    declare OE_RATE_UNIT        = f8 with protect, constant(633585.00)
 
    ;Query
    select into "nl:"
    from order_detail od
    plan od where expand(expand_idx,1,pha_data->qual_cnt,od.ORDER_ID,pha_data->qual[expand_idx].order_id)
            and od.OE_FIELD_ID in (
                                   OE_FREQ
                                   ,OE_STRENGTHDOSE
                                   ,OE_STRENGTHDOSEUNIT
                                   ,OE_VOLUMEDOSE
                                   ,OE_VOLUMEDOSEUNIT
                                   ,OE_DRUGFORM
                                   ,OE_DURATION
                                   ,OE_DURATIONUNIT
                                   ,OE_RATE
                                   ,OE_RATE_UNIT
                                   ,OE_RXROUTE
                                  )
    order by
        od.ORDER_ID     ;Each order
        ,od.OE_FIELD_ID ;Individual attributes
    head od.ORDER_ID
        pos                = locateval(locate_idx,1,pha_data->qual_cnt,od.ORDER_ID,pha_data->qual[locate_idx].order_id)
        frequency_code     = 0.0
        frequency          = ""
        strength_dose      = ""
        strength_dose_unit = ""
        volume_dose        = ""
        volume_dose_unit   = ""
        drug_form          = ""
        duration           = ""
        duration_unit      = ""
        rate               = ""
        rate_unit          = ""
        route              = ""
    head od.OE_FIELD_ID
        case(od.OE_FIELD_ID)
            of OE_FREQ:
                frequency_code     = od.OE_FIELD_VALUE
                frequency          = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_STRENGTHDOSE:
                strength_dose      = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_STRENGTHDOSEUNIT:
                strength_dose_unit = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_VOLUMEDOSE:
                volume_dose        = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_VOLUMEDOSEUNIT:
                volume_dose_unit   = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_DRUGFORM:
                drug_form          = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_DURATION:
                duration           = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_DURATIONUNIT:
                duration_unit      = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_RATE:
                rate               = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_RATE_UNIT:
                rate_unit          = trim(od.OE_FIELD_DISPLAY_VALUE,3)
            of OE_RXROUTE:
                route              = trim(od.OE_FIELD_DISPLAY_VALUE,3)
        endcase
    foot od.OE_FIELD_ID
        null
    foot od.ORDER_ID
        while(pos > 0)
            pha_data->qual[pos].frequency_code     = frequency_code
            pha_data->qual[pos].frequency_display  = frequency
            if(textlen(trim(strength_dose,3)) != 0)
                pha_data->qual[pos].strength_dose      = strength_dose
            endif
            if(textlen(trim(strength_dose_unit,3)) != 0)
                pha_data->qual[pos].strength_dose_unit = strength_dose_unit
            endif
            if(textlen(trim(volume_dose,3)) != 0)
                pha_data->qual[pos].volume_dose        = volume_dose
            endif
            if(textlen(trim(volume_dose_unit,3)) != 0)
                pha_data->qual[pos].volume_dose_unit   = volume_dose_unit
            endif
            if(textlen(trim(route,3)) != 0 )
                pha_data->qual[pos].route_of_admin     = route
            endif
            pha_data->qual[pos].drug_form          = drug_form
            pha_data->qual[pos].duration           = build2(duration," ",duration_unit)
            pha_data->qual[pos].rate               = rate
            pha_data->qual[pos].rate_unit          = rate_unit
 
            ;Next position
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,od.ORDER_ID,pha_data->qual[locate_idx].order_id)
        endwhile
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetOrderDetailData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetOrderDetailData(null) = i2*******")
    return(return_ind)
end ;subroutine GetOrderDetailData(null)
 
/*****************************************************************************
*   Name: GetDrugSynonymData(null)
*
*   Description: Retrieve drug synonymn data including: CDM, Brand, and Generic
*                name.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: order_catalog_synonym
*                ,med_identifier
*
*****************************************************************************/
subroutine GetDrugSynonymData(null)
    call logMsg("*******Beginning Subroutine: GetOrderDetailData(null) = i2*******")
 
    ;Local variables
    declare return_ind            = i2 with protect, noconstant(1)
    declare expand_idx            = i4 with protect, noconstant(0)
    declare locate_idx            = i4 with protect, noconstant(0)
    declare pos                   = i4 with protect, noconstant(0)
    declare empty                 = i2 with protect, constant(0)
 
    ;Query
    select into "nl:"
    from order_catalog_synonym ocs
    plan ocs where expand(expand_idx,1,pha_data->qual_cnt,ocs.SYNONYM_ID,pha_data->qual[expand_idx].synonym_id)
    order by
        ocs.SYNONYM_ID
    head ocs.SYNONYM_ID
        pos = locateval(locate_idx,pos,pha_data->qual_cnt,ocs.SYNONYM_ID,pha_data->qual[locate_idx].synonym_id)
        while(pos >0)
            if(pha_data->qual[pos].item_id < 1)
                pha_data->qual[pos].item_id = ocs.ITEM_ID
                if(pha_data->qual[pos].item_id > 0)
                    pha_data->qual[pos].item_id_flag = 1
                endif
            endif
            ;Next position
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,ocs.SYNONYM_ID,pha_data->qual[locate_idx].synonym_id)
        endwhile
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetOrderDetailData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetOrderDetailData(null) = i2*******")
    return(return_ind)
end ;subroutine GetDrugSynonymData(null)
 
/*****************************************************************************
*   Name: GetDrugIdentifierData(null)
*
*   Description: Drug generic, brand, and charge names/numbers.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: med_identifier mi
*
*****************************************************************************/
subroutine GetDrugIdentifierData(null)
    call logMsg("*******Beginning Subroutine: GetDrugIdentifierData(null) = i2*******")
 
    ;Local variables
    declare return_ind            = i2 with protect, noconstant(1)
    declare expand_idx            = i4 with protect, noconstant(0)
    declare locate_idx            = i4 with protect, noconstant(0)
    declare pos                   = i4 with protect, noconstant(0)
    declare empty                 = i2 with protect, constant(0)
 
    declare drug_brand_name       = vc with protect, noconstant("")
    declare drug_generic_name     = vc with protect, noconstant("")
    declare item_number           = vc with protect, noconstant("")
 
    declare 11000_BRANDNAME_CD    = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3303"))
    declare 11000_CHARGENUMBER_CD = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3304"))
    declare 11000_GENERICNAME_CD  = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!3294"))
 
    ;Log code values
    call logMsg(Build2("11000_BRANDNAME_CD:    ",11000_BRANDNAME_CD))
    call logMsg(Build2("11000_CHARGENUMBER_CD: ",11000_CHARGENUMBER_CD))
    call logMsg(Build2("11000_GENERICNAME_CD:  ",11000_GENERICNAME_CD))
 
    ;Query
    select into "nl:"
    from med_identifier mi
    plan mi where expand(expand_idx,1,pha_data->qual_cnt,mi.ITEM_ID,pha_data->qual[expand_idx].item_id
                                                        ,1,pha_data->qual[expand_idx].item_id_flag)
            and mi.PRIMARY_IND            =  active
            and mi.MED_PRODUCT_ID         =  empty
            and mi.MED_IDENTIFIER_TYPE_CD in (
                                             11000_BRANDNAME_CD
                                             ,11000_CHARGENUMBER_CD
                                             ,11000_GENERICNAME_CD
                                             )
            and mi.ACTIVE_IND             = active
    order by
        mi.ITEM_ID
        ,mi.MED_IDENTIFIER_TYPE_CD
    head mi.ITEM_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,mi.ITEM_ID,pha_data->qual[locate_idx].item_id
                                                        ,1,pha_data->qual[locate_idx].item_id_flag)
    head mi.MED_IDENTIFIER_TYPE_CD
        case(mi.MED_IDENTIFIER_TYPE_CD)
            of 11000_BRANDNAME_CD:
                drug_brand_name   = trim(mi.VALUE,3)
            of 11000_CHARGENUMBER_CD:
                item_number       = trim(mi.VALUE,3)
            of 11000_GENERICNAME_CD:
                drug_generic_name = trim(mi.VALUE,3)
        endcase
    foot mi.MED_IDENTIFIER_TYPE_CD
        null
    foot mi.ITEM_ID
        while(pos >0)
            pha_data->qual[pos].drug_brand_name   = drug_brand_name
            pha_data->qual[pos].item_number       = item_number
            pha_data->qual[pos].drug_generic_name = drug_generic_name
 
            ;Next position
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,mi.ITEM_ID,pha_data->qual[locate_idx].item_id
                                                        ,1,pha_data->qual[locate_idx].item_id_flag)
        endwhile
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetDrugIdentifierData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetDrugIdentifierData(null) = i2*******")
    return(return_ind)
end ;subroutine GetDrugIdentifierData(null)
 
/*****************************************************************************
*   Name: GetDrugClassData(null)
*
*   Description: Gets the drug class description. This is as close to AHFS
*                as they can get for now. This does not use MULTM class,
*                as it looks at their active order catalog.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: order_catalog_synonym
*                ,med_identifier
*
*****************************************************************************/
subroutine GetDrugClassData(null)
    call logMsg("*******Beginning Subroutine: GetDrugClassData(null) = i2*******")
 
    ;Local variables
    declare return_ind            = i2 with protect, noconstant(1)
    declare expand_idx            = i4 with protect, noconstant(0)
    declare locate_idx            = i4 with protect, noconstant(0)
    declare pos                   = i4 with protect, noconstant(0)
 
    declare theraputic_class      = i4 with protect, constant(2)
    declare empty                 = f8 with protect, constant(0.0)
    declare drug_cat1             = vc with protect, noconstant("")
    declare drug_desc1            = vc with protect, noconstant("")
    declare drug_cat2             = vc with protect, noconstant("")
    declare drug_desc2            = vc with protect, noconstant("")
    declare drug_cat3             = vc with protect, noconstant("")
    declare drug_desc3            = vc with protect, noconstant("")
 
    ;Query
    select into "nl:"
    from mltm_mmdc_name_map mmnm
        ,mltm_drug_name     mdn
        ,mltm_drug_name_map mdnm
        ,mltm_drug_id       mdi
    plan mmnm where expand(expand_idx,1,pha_data->qual_cnt,mmnm.MAIN_MULTUM_DRUG_CODE
                                                          ,pha_data->qual[expand_idx].multm_main_drug_code
                                                          ,1,pha_data->qual[expand_idx].multm_flag)
    join mdn where mmnm.drug_synonym_id  = mdn.drug_synonym_id
    join mdnm where mdnm.drug_synonym_id = mdn.drug_synonym_id
    join mdi where mdi.drug_identifier   = mdnm.drug_identifier
    order by
        mmnm.MAIN_MULTUM_DRUG_CODE
    head report
        pos = 0
    head mmnm.MAIN_MULTUM_DRUG_CODE
        pos = locateval(locate_idx,1,pha_data->qual_cnt,mmnm.MAIN_MULTUM_DRUG_CODE
                                                          ,pha_data->qual[locate_idx].multm_main_drug_code
                                                          ,1,pha_data->qual[locate_idx].multm_flag)
        while(pos > 0)
            pha_data->qual[pos].d_number = mdnm.DRUG_IDENTIFIER
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,mmnm.MAIN_MULTUM_DRUG_CODE
                                                          ,pha_data->qual[locate_idx].multm_main_drug_code
                                                          ,1,pha_data->qual[locate_idx].multm_flag)
        endwhile
    foot mmnm.MAIN_MULTUM_DRUG_CODE
        null
    with expand = 1
 
    ;Drug category query
    select into "nl:"
        mcdx.drug_identifier,
        dc1.multum_category_id,
        parent_category = substring(1,50,dc1.category_name),
        dc2.MULTUM_CATEGORY_ID,
        sub_category = substring(1,50,dc2.category_name),
        dc3.MULTUM_CATEGORY_ID,
        sub_sub_category = substring(1,50,dc3.category_name)
    from
        mltm_drug_categories dc1,
        mltm_category_drug_xref mcdx,
        mltm_category_sub_xref dcs1,
        mltm_drug_categories dc2,
        mltm_category_sub_xref dcs2,
        mltm_drug_categories dc3
    plan dc1 where not exists(
            select
                mcsx.multum_category_id
            from
                mltm_category_sub_xref mcsx
            where
                mcsx.sub_category_id = dc1.multum_category_id
            )
    join dcs1
        where dc1.multum_category_id = dcs1.multum_category_id
    join dc2
        where dcs1.sub_category_id = dc2.multum_category_id
    join dcs2
        where dcs2.multum_category_id = outerjoin(dc2.multum_category_id)
    join dc3
        where dc3.multum_category_id = outerjoin(dcs2.sub_category_id)
    join mcdx
        where ( mcdx.multum_category_id = dc1.multum_category_id
            or mcdx.multum_category_id = dc2.multum_category_id
            or mcdx.multum_category_id = dc3.multum_category_id )
        and expand(expand_idx,1,pha_data->qual_cnt,mcdx.DRUG_IDENTIFIER,pha_data->qual[expand_idx].d_number)
    order by
        mcdx.DRUG_IDENTIFIER
    head mcdx.DRUG_IDENTIFIER
        pos = locateval(locate_idx,1,pha_data->qual_cnt,mcdx.DRUG_IDENTIFIER,pha_data->qual[locate_idx].d_number)
        while(pos > 0)
            if(dc1.MULTUM_CATEGORY_ID != empty)
                pha_data->qual[pos].drug_class_code1        = trim(cnvtstring(dc1.MULTUM_CATEGORY_ID),3)
                pha_data->qual[pos].drug_class_description1 = dc1.CATEGORY_NAME
            endif
 
            if(dc2.MULTUM_CATEGORY_ID != empty)
                pha_data->qual[pos].drug_class_code2        = trim(cnvtstring(dc2.MULTUM_CATEGORY_ID),3)
                pha_data->qual[pos].drug_class_description2 = dc2.CATEGORY_NAME
            endif
 
            if(dc3.MULTUM_CATEGORY_ID != empty)
                pha_data->qual[pos].drug_class_code3        = trim(cnvtstring(dc3.MULTUM_CATEGORY_ID),3)
                pha_data->qual[pos].drug_class_description3 = dc3.CATEGORY_NAME
            endif
 
            ;Next position
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,mcdx.DRUG_IDENTIFIER,pha_data->qual[locate_idx].d_number)
        endwhile
    foot mcdx.DRUG_IDENTIFIER
        null
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetDrugClassData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetDrugClassData(null) = i2*******")
    return(return_ind)
end ;subroutine GetDrugClassData(null)
 
/*****************************************************************************
*   Name: GetChargeData(null)
*
*   Description: Simple charge data query. Posted date and Charged date.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: charge
*
*****************************************************************************/
subroutine GetChargeData(null)
    call logMsg("*******Beginning Subroutine: GetChargeData(null) = i2*******")
 
    ;Local variables
    declare return_ind = i2 with protect, noconstant(1)
    declare expand_idx = i4 with protect, noconstant(0)
    declare locate_idx = i4 with protect, noconstant(0)
    declare pos        = i4 with protect, noconstant(0)
 
    ;Query
    select into "nl:"
    from dispense_hx d
    plan d where expand(expand_idx,1,pha_data->qual_cnt,d.ORDER_ID,pha_data->qual[expand_idx].order_id)
           and d.CHARGE_IND = active
    order by
        d.ORDER_ID
    head d.ORDER_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,d.ORDER_ID,pha_data->qual[locate_idx].order_id)
        while(pos > 0)
            pha_data->qual[pos].charged_dt             = d.CHARGE_DT_TM
            pha_data->qual[pos].quantity_doses_charged = d.DOSES
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,d.ORDER_ID,pha_data->qual[locate_idx].order_id)
        endwhile
    foot d.ORDER_ID
        null
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetChargeData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetChargeData(null) = i2*******")
    return(return_ind)
end ;subroutine GetChargeData(null)
 
/*****************************************************************************
*   Name: GetFINMRNData(null)
*
*   Description: FIN and MRN of the patient.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: encntr_alias
*
*****************************************************************************/
subroutine GetFINMRNData(null)
    call logMsg("*******Beginning Subroutine: GetFINMRNData(null) = i2*******")
 
    ;Local variables
    declare return_ind    = i2 with protect, noconstant(1)
    declare expand_idx    = i4 with protect, noconstant(0)
    declare locate_idx    = i4 with protect, noconstant(0)
    declare pos           = i4 with protect, noconstant(0)
 
    declare finnbr        = vc with protect, noconstant("")
    declare mrn           = vc with protect, noconstant("")
 
    declare 319_FINNBR_CD = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!2930"))
    declare 319_MRN_CD    = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!8021"))
 
    ;Log coded values
    call logMsg(build2("319_FINNBR_CD: ",319_FINNBR_CD))
    call logMsg(build2("319_MRN_CD:    ",319_MRN_CD))
 
    ;Query
    select into "nl:"
    from encntr_alias ea
    plan ea where expand(expand_idx,1,pha_data->qual_cnt,ea.ENCNTR_ID,pha_data->qual[expand_idx].encntr_id)
            and ea.ENCNTR_ALIAS_TYPE_CD in(
                                          319_FINNBR_CD
                                          ,319_MRN_CD
                                          )
            and ea.ACTIVE_IND           =  active
            and ea.beg_effective_dt_tm  <= cnvtdatetime(curdate,curtime3)
    	    and ea.end_effective_dt_tm  >  cnvtdatetime(curdate,curtime3)
    order by
        ea.ENCNTR_ID
        ,ea.ENCNTR_ALIAS_TYPE_CD
    head ea.ENCNTR_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,ea.ENCNTR_ID,pha_data->qual[locate_idx].encntr_id)
        mrn = ""
        fin = ""
    head ea.ENCNTR_ALIAS_TYPE_CD
        pha_data->qual[pos].encntr_alias_id = ea.ENCNTR_ALIAS_ID ;Primary key
        case (ea.ENCNTR_ALIAS_TYPE_CD)
            of 319_FINNBR_CD:
                finnbr = trim(ea.ALIAS,3)
            of 319_MRN_CD:
                mrn    = trim(ea.ALIAS,3)
        endcase
    foot ea.ENCNTR_ALIAS_TYPE_CD
        null
    foot ea.ENCNTR_ID
        while(pos > 0)
            pha_data->qual[pos].fin = finnbr
            pha_data->qual[pos].mrn = mrn
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,ea.ENCNTR_ID,pha_data->qual[locate_idx].encntr_id)
        endwhile
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetFINMRNData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetFINMRNData(null) = i2*******")
    return(return_ind)
end ;subroutine GetFINMRNData(null)
 
/*****************************************************************************
*   Name: GetCMRNData(null)
*
*   Description: Get the CMRN person alias.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: person_alias
*
*****************************************************************************/
subroutine GetCMRNData(null)
    call logMsg("*******Beginning Subroutine: GetCMRNData(null) = i2*******")
 
    ;Local variables
    declare return_ind    = i2 with protect, noconstant(1)
    declare expand_idx    = i4 with protect, noconstant(0)
    declare locate_idx    = i4 with protect, noconstant(0)
    declare pos           = i4 with protect, noconstant(0)
 
    declare 263_CMRN_CD = f8 with protect, constant(GetCodeWithCheck("DISPLAYKEY",263,"CMRN"))
 
    ;Log coded values
    call logMsg(build2("263_CMRN_CD: ",263_CMRN_CD))
 
    ;Query
    select into "nl:"
    from person_alias pa
    plan pa where expand(expand_idx,1,pha_data->qual_cnt,pa.PERSON_ID,pha_data->qual[expand_idx].person_id)
            and pa.ALIAS_POOL_CD        =  263_CMRN_CD
            and pa.ACTIVE_IND           =  active
            and pa.beg_effective_dt_tm  <= cnvtdatetime(curdate,curtime3)
    	    and pa.end_effective_dt_tm  >  cnvtdatetime(curdate,curtime3)
    order by
        pa.PERSON_ID
    head pa.PERSON_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,pa.PERSON_ID,pha_data->qual[locate_idx].person_id)
        while(pos > 0)
            pha_data->qual[pos].person_alias_id = pa.PERSON_ALIAS_ID
            pha_data->qual[pos].cmrn            = trim(pa.ALIAS,3)
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,pa.PERSON_ID,pha_data->qual[locate_idx].person_id)
        endwhile
    foot pa.PERSON_ID
        null
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetCMRNData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetCMRNData(null) = i2*******")
    return(return_ind)
end ;subroutine GetCMRNData(null)
 
/*****************************************************************************
*   Name: GetPhysicianData(null)
*
*   Description: Get all physican alias data including: DEA, NPI, and Doctor
*                Number.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: person_alias
*
*****************************************************************************/
subroutine GetPhysicianData(null)
    call logMsg("*******Beginning Subroutine: GetPhysicianData(null) = i2*******")
 
    ;Local variables
    declare return_ind     = i2 with protect, noconstant(1)
    declare expand_idx     = i4 with protect, noconstant(0)
    declare locate_idx     = i4 with protect, noconstant(0)
    declare pos            = i4 with protect, noconstant(0)
 
    declare 263_STAR_CD    = f8 with protect, constant(GetCodeWithCheck("DISPLAYKEY",263,"STARDOCTORNUMBER"))
    declare 320_ORG_DOC_CD = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!6664"))
    declare 333_ATTENDING_CD = f8 with protect, constant(GetCodeWithCheck("CKI.CODEVALUE!4024"))
 
    ;Query
    select into "nl:"
    from encntr_prsnl_reltn epr
         ,prsnl_alias       pa
    plan epr where expand(expand_idx,1,pha_data->qual_cnt,epr.ENCNTR_ID,pha_data->qual[expand_idx].encntr_id)
             and epr.ENCNTR_PRSNL_R_CD   =  333_ATTENDING_CD
             and epr.ACTIVE_IND          =  active
             and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    	     and epr.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    join pa  where pa.PERSON_ID          =  epr.PRSNL_PERSON_ID
             and pa.ALIAS_POOL_CD        =  263_STAR_CD
             and pa.PRSNL_ALIAS_TYPE_CD  =  320_ORG_DOC_CD
             and pa.ACTIVE_IND           =  active
             and pa.beg_effective_dt_tm  <= cnvtdatetime(curdate,curtime3)
    	     and pa.end_effective_dt_tm  >  cnvtdatetime(curdate,curtime3)
    order by
        epr.ENCNTR_ID
    head epr.ENCNTR_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,epr.ENCNTR_ID,pha_data->qual[locate_idx].encntr_id)
        while(pos > 0)
            pha_data->qual[pos].prsnl_alias_id   = pa.PRSNL_ALIAS_ID
            pha_data->qual[pos].physician_number = trim(pa.ALIAS,3)
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,epr.ENCNTR_ID,pha_data->qual[locate_idx].encntr_id)
        endwhile
    foot epr.ENCNTR_ID
        null
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetPhysicianData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetPhysicianData(null) = i2*******")
    return(return_ind)
end ;subroutine GetPhysicianData(null)
 
/*****************************************************************************
*   Name: GetOrderingUsername(null)
*
*   Description: Query to get the username of the person who made the order
*                or preformed the action.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: prsnl
*
*****************************************************************************/
subroutine GetOrderingUsername(null)
    call logMsg("*******Beginning Subroutine: GetPhysicianData(null) = i2*******")
 
    ;Local variables
    declare return_ind = i2 with protect, noconstant(1)
    declare expand_idx = i4 with protect, noconstant(0)
    declare locate_idx = i4 with protect, noconstant(0)
    declare pos        = i4 with protect, noconstant(0)
 
    ;Query
    select into "nl:"
    from prsnl p
    plan p where expand(expand_idx,1,pha_data->qual_cnt,p.PERSON_ID,pha_data->qual[expand_idx].ordered_by_id)
           and p.ACTIVE_IND          =  active
           and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    	   and p.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    order by
        p.PERSON_ID
    head p.PERSON_ID
        pos = locateval(locate_idx,1,pha_data->qual_cnt,p.PERSON_ID,pha_data->qual[locate_idx].ordered_by_id)
        while(pos > 0)
            pha_data->qual[pos].personnel_username = trim(p.USERNAME,3)
            pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,p.PERSON_ID,pha_data->qual[locate_idx].ordered_by_id)
        endwhile
    foot p.PERSON_ID
        null
    with nocounter, expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetPhysicianData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetPhysicianData(null) = i2*******")
    return(return_ind)
end ;subroutine GetOrderingUsername(null)
 
/*****************************************************************************
*   Name: GetFacilityAlias(null)
*
*   Description: Facility Alias for where the medication was ordered. Using
*                the STRATA alias set up for CHS_TN.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: prsnl
*
*****************************************************************************/
subroutine GetFacilityAlias(null)
    call logMsg("*******Beginning Subroutine: GetPhysicianData(null) = i2*******")
 
    ;Local variables
    declare return_ind          = i2 with protect, noconstant(1)
    declare expand_idx          = i4 with protect, noconstant(0)
    declare locate_idx          = i4 with protect, noconstant(0)
    declare pos                 = i4 with protect, noconstant(0)
 
    declare 263_STRATA_ALIAS_CD = f8 with protect, constant(GetCodeWithCheck("DISPLAYKEY",263,"STRATAPHARMACYORGIDS"))
 
    ;Query
    select into "nl:"
    from organization_alias oa
    plan oa where expand(expand_idx,1,pha_data->qual_cnt,oa.ORGANIZATION_ID,pha_data->qual[expand_idx].organization_id)
            and oa.ALIAS_POOL_CD       =  263_STRATA_ALIAS_CD
            and oa.ACTIVE_IND          =  active
            and oa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    	    and oa.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    order by
        oa.ORGANIZATION_ID
    head oa.ORGANIZATION_ID
      pos = locateval(locate_idx,1,pha_data->qual_cnt,oa.ORGANIZATION_ID,pha_data->qual[locate_idx].organization_id)
      while(pos > 0)
        pha_data->qual[pos].facility_cd = trim(oa.ALIAS,3)
        pos = locateval(locate_idx,pos+1,pha_data->qual_cnt,oa.ORGANIZATION_ID,pha_data->qual[locate_idx].organization_id)
      endwhile
    foot oa.ORGANIZATION_ID
      null
    with expand = 1
 
    ;Check errors
    if(catchErrors("Error occured in the GetPhysicianData(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: GetPhysicianData(null) = i2*******")
    return(return_ind)
end ;subroutine GetFacilityAlias(null)
 
/*****************************************************************************
*   Name: OutputToFile(null)
*
*   Description: Output data as pipe delimited file.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: none
*
*****************************************************************************/
subroutine OutputToFile(null)
    call logMsg("*******Beginning Subroutine: OutputToFile(null) = i2*******")
 
    record cclio_rec
    ( 1 file_desc            = i4
      1 file_name            = vc
      1 file_buf             = vc
      1 file_dir             = i4
      1 file_offset          = i4
    ) with protect
 
    declare return_ind = i2 with protect, noconstant(1)
    declare data_idx         = i4 with protect, noconstant(0)
 
    declare extract_filename = vc with protect, constant(concat("chs_tn"))
    declare full_file_path   = vc with protect, noconstant("")
    declare output_string    = vc with protect, noconstant("")
    declare file_directory   = vc with protect, constant(trim(logical("ccluserdir"),3))
    declare carriage_return  = c1 with protect, constant(char(13))
    declare line_feed        = c1 with protect, constant(char(10))
    declare file_delimiter   = c1 with protect, constant("|")
    declare file_header      = vc with protect, constant(build2("Facility Code",file_delimiter
                                                               ,"Hospital Account Number",file_delimiter
                                                               ,"Master Patient Account",file_delimiter
                                                               ,"HMM Item Number",file_delimiter
                                                               ,"Date of Charged Entered",file_delimiter
                                                               ,"Date Charged",file_delimiter
                                                               ,"Prescription Number",file_delimiter
                                                               ,"Drug Generic Name",file_delimiter
                                                               ,"Brand Name",file_delimiter
                                                               ,"Strength Dose",file_delimiter
                                                               ,"Strength Dose Unit",file_delimiter
                                                               ,"Route of Admin",file_delimiter
                                                               ,"Volume Dose",file_delimiter
                                                               ,"Volume Dose Unit",file_delimiter
                                                               ,"Drug Form",file_delimiter
                                                               ,"Quantity of Doses Charged",file_delimiter
                                                               ,"Frequency Code",file_delimiter
                                                               ,"Frequency Code Description",file_delimiter
                                                               ,"Number of Doses for Therapy",file_delimiter
                                                               ,"Class of Drug",file_delimiter
                                                               ,"Physician Number",file_delimiter
                                                               ,"Entering Personnel Identifier",file_delimiter
                                                               ,carriage_return,line_feed
                                                               ))
 
    set full_file_path = build(file_directory, trim(extract_filename))
    set cclio_rec->file_name = full_file_path
 
    ;Open file
    set cclio_rec->file_buf  = "w"
    set stat = cclio("OPEN",cclio_rec)
 
    ;Write headers
    set cclio_rec->file_buf = file_header
    set stat = cclio("WRITE",cclio_rec)
 
    ;Write data
    for(data_idx = 1 to pha_data->qual_cnt)
        set output_string = build(pha_data->qual[data_idx].facility_cd,file_delimiter
                                 ,pha_data->qual[data_idx].mrn,file_delimiter
                                 ,pha_data->qual[data_idx].fin,file_delimiter
                                 ,pha_data->qual[data_idx].item_number,file_delimiter
                                 ,format(pha_data->qual[data_idx].charge_entered_dt,date_time_fmt),file_delimiter
                                 ,format(pha_data->qual[data_idx].charged_dt,date_time_fmt),file_delimiter
                                 ,pha_data->qual[data_idx].order_id,file_delimiter
                                 ,pha_data->qual[data_idx].drug_generic_name,file_delimiter
                                 ,pha_data->qual[data_idx].drug_brand_name,file_delimiter
                                 ,pha_data->qual[data_idx].strength_dose,file_delimiter
                                 ,pha_data->qual[data_idx].strength_dose_unit,file_delimiter
                                 ,pha_data->qual[data_idx].route_of_admin,file_delimiter
                                 ,pha_data->qual[data_idx].volume_dose,file_delimiter
                                 ,pha_data->qual[data_idx].volume_dose_unit,file_delimiter
                                 ,pha_data->qual[data_idx].drug_form,file_delimiter
                                 ,pha_data->qual[data_idx].quantity_doses_charged,file_delimiter
                                 ,pha_data->qual[data_idx].frequency_code,file_delimiter
                                 ,pha_data->qual[data_idx].frequency_display,file_delimiter
                                 ,pha_data->qual[data_idx].duration,file_delimiter
                                 ,pha_data->qual[data_idx].drug_class_description,file_delimiter
                                 ,pha_data->qual[data_idx].physician_number,file_delimiter
                                 ,pha_data->qual[data_idx].personnel_username,file_delimiter
                                 ,carriage_return,line_feed
                                 )
        set cclio_rec->file_buf = output_string
        set stat = cclio("WRITE",cclio_rec)
        set output_string = ""
    endfor
 
    ;Finish what you started
    set stat = cclio("CLOSE",cclio_rec)
 
    ;Check errors
    if(catchErrors("Error occured in the OutputToFile(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: OutputToFile(null) = i2*******")
    return(return_ind)
end ;subroutine OutputToFile(null)
 
/*****************************************************************************
*   Name: OutputToScreen(null)
*
*   Description: Output data to screen.
*
*   Parameters: None
*
*   Outputs: return_ind - i2
*                     0 - Failure
*                     1 - Success
*
*   Tables Read: none
*
*****************************************************************************/
subroutine OutputToScreen(null)
    call logMsg("*******Beginning Subroutine: OutputToFile(null) = i2*******")
 
    declare return_ind = i2 with protect, noconstant(1)
 
    SELECT INTO $OUTDEV
	FACILITY_CD = PHA_DATA->qual[D1.SEQ].facility_cd
	, FIN = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].fin)
	, CMRN = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].cmrn)
	, ITEM_NUMBER = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].item_number)
	, PRESCRIPTION_NUMBER = PHA_DATA->qual[D1.SEQ].order_id
	, CHARGE_ENTERED_DT = format(PHA_DATA->qual[D1.SEQ].charge_entered_dt,date_time_fmt)
	, CHARGED_DT = format(PHA_DATA->qual[D1.SEQ].charged_dt,date_time_fmt)
	, ORDER_DISPLAY = SUBSTRING(1,255,PHA_DATA->qual[D1.SEQ].order_display)
	, DRUG_GENERIC_NAME = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_generic_name)
	, DRUG_BRAND_NAME = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_brand_name)
	, STRENGTH_DOSE = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].strength_dose)
	, STRENGTH_DOSE_UNIT = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].strength_dose_unit)
	, ROUTE_OF_ADMIN = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].route_of_admin)
	, VOLUME_DOSE = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].volume_dose)
	, VOLUME_DOSE_UNIT = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].volume_dose_unit)
	, RATE = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].rate)
	, RATE_UNIT = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].rate_unit)
;    	,NORMALIZED_RATE        = PHA_DATA->qual[D1.SEQ].normalized_rate
;    	,NORMALIZED_RATE_UNIT   = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].normalized_rate_unit)
	, DRUG_FORM = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_form)
	, QUANTITY_DOSES_CHARGED = PHA_DATA->qual[D1.SEQ].quantity_doses_charged
	, FREQUENCY_CODE = PHA_DATA->qual[D1.SEQ].frequency_code
	, FREQUENCY_DISPLAY = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].frequency_display)
	, DURATION = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].duration)
	, DRUG_CLASS_CODE1 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_code1)
	, DRUG_CLASS_DESCRIPTION1 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_description1)
	, DRUG_CLASS_CODE2 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_code2)
	, DRUG_CLASS_DESCRIPTION2 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_description2)
	, DRUG_CLASS_CODE3 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_code3)
	, DRUG_CLASS_DESCRIPTION3 = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].drug_class_description3)
	, PHYSICIAN_NUMBER = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].physician_number)
	, PERSONNEL_USERNAME = SUBSTRING(1, 30, PHA_DATA->qual[D1.SEQ].personnel_username)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(PHA_DATA->qual, 5)))
 
PLAN D1
 
ORDER BY
	FACILITY_CD
	, FIN
	, CHARGED_DT
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
    ;Check errors
    if(catchErrors("Error occured in the OutputToFile(null) subroutine!"))
        set return_ind = 0
    endif
 
    call logMsg("*******End of Subroutine: OutputToFile(null) = i2*******")
    return(return_ind)
end ;subroutine OutputToScreen(null)
 
end ;program chs_tn_pha_scorecard_rpt:dba
go

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
 
        Source file name:       CERN_ORMREQ04.PRG
        Object name:            cern_ormreq04
        Request #:              N/A
 
        Product:                PowerChart
        Product Team:           Order Management
        HNA Version:            500
        CCL Version:            8.3.0
 
        Program purpose:        Patient order requisition template
 
        Tables read:            person
                                encounter
                                person_alias
                                encntr_alias
                                encntr_prsnl_reltn
                                prsnl
                                clinical_event
                                allergy
                                nomenclature
                                name_value_prefs
                                app_prefs
                                orders
                                order_action
                                oe_format_fields
                                order_detail
                                order_entry_fields
                                accession_order_r
                                order_ingredient
                                order_comment
 
        Tables updated:         N/A
 
        Executing from:         PowerChart
 
        Special Notes:          Revision of dcpreqgen template
 
*****************************************************************************/
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ***********************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ------------------------------------*
;    *001 **/**/** CERNER               Initial Release                     *
;    *002 08/07/07 RD012555             Add ellipsis to mnemonics that are  *
;                                       truncated.                          *
;    *003 02/05/09 MK012585             Join Order_action table using       *
;                                       conversation_id if one is passed in.*
;    *004 04/30/09 KW8277               Correct dummytable error.           *
;    *005 06/02/09 AS017690             Complex Meds changes                *
;    *006 08/20/09 AD010624             Replace > " " comparisons with      *
;                                       size() > 0, trim both sides of order*
;                                       details instead of right side only  *
;    *007 11/05/09 RD012555             Do not print for Protocols          *
;    *008  17/10/11 KM019227            If special instruction is exceeding *
;                                       the page limit then break the line  *
;                                       and allow for page breaks.          *
;    *009 12/13/11 KM019227             If order label text longer than the *
;                                       order detail value text then print  *
;                                       order detail with ellipses after    *
;                                       label text                          *
;    *010 12/22/11 SS019071             Globalization Regional locale support*
;    *011 04/25/12 KK023353             CR 1-5689212177 - Admit Date        *
;                                       displays a day early on DCPREQGEN0x *
;                                       when UTC is enabled                 *
;    *012 09/06/12 KM019227             Display most recent comment entered *
;    *013 09/13/12 MS021481             CR 1-6172020321                     *
;                                       do not display the most recent      *
;                                       attending physician                 *
;    *014 12/27/12 MS021481             CR 1-5750697621 - Combo drug        *
;                                       strength based ordering. To Display *
;                                       Combination dosing Ingredient Id    *
;    *015 04/04/13 PB027274             Fixed incorrect conversion of DOB   *
;                                       from UTC to local by adding birth   *
;                                       timezone.                           *
;    *016 07/18/13 BK024219             Reverted the changes done in        *
;                                       previous check-in and removing the  *
;                                       line which was overriding the value *
;                                       as label text for field type yes/no.*
;	 *017 01/17/14 DN029187				CR 1-7700897486 					*
;										Freetext allergies not displaying 	*
;										with DCPREQGEN06					*
;	 *018 01/08/15 SM032003				CR 1-6900337773 					*
;										When the ICD9 detail is printed on 	*
;										an orders requisition have the 		*
;										numerical value print along with    *
;										the description for detail.   		*
;    *019 03/05/17 HV030682             Replacing tab with spaces in order  *
;                                       comments	 	                    *
;    *020 10/09/17 SB032903             CR 1-12560985770:- When UTC is      *
;                                       turned on, only the date for the    *
;                                       ORDER DATE/TIME is printed.         *
;    *021 24/09/18 SR051119             Added order date time.              *
;                                       Added enter by with npi and         *
;                                       electronicalliy signed by.          *
;                                       removed unneccesary order details   *
;                                       fields.                             *
;                                       Increased the charecter limit of    *
;                                       comments to be printed.             *
;                                       Printing every order detail field   *
;                                       one after another.                  *
;                                       Did some formatting change.         *
;                                       did self code review and changed    *
;                                       mode variable                       *
;                                       Restricting the requisition to      *
;                                       Order, Modify and Discontinue order *
;                                       status.                             *
;                                       restricting the requisition from    *
;                                       printing for Acute orders if the    *
;                                       patient is discharged               *
;    *022 08/22/18 ccummin4             Added logic to print suprvng CR2677 *
;    *023 08/30/18 ccummin4             print elec_signby if DME ord CR2677 *
;    *024 08/30/18 ccummin4             added insurance for ADT ord  CR2677 *
;    *025 09/10/18 ccummin4             added prim,sec ins only qualifier   *
;    *026 09/24/18 ccummin4             allow special orders print on disch *
;    *027 10/03/18 ccummin4             disch print only with manual reprint*
;~DE~************************************************************************
 
drop program testingchstnreq04:dba go
create program testingchstnreq04:dba
 
;022 drop program chstnreqtst:dba go
;022 create program chstnreqtst:dba 
 
/*********************************************************************
*  NOTE: The request record definition MUST come first in the script *
*  and cannot be modified without changing the entire script         *
**********************************************************************/
 
record request
( 1 person_id = f8
  1 print_prsnl_id = f8
  1 order_qual[*]
    2 order_id = f8
    2 encntr_id = f8
    2 conversation_id = f8
  1 printer_name = c50
)
free set orders
free set allergy
free set diagnosis
free set pt
 
record orders
( 1 name = vc
  1 pat_type = vc
  1 age = vc
  1 dob = vc
  1 mrn = vc
  1 cmrn = vc
  1 location = vc
  1 facility = vc
  1 nurse_unit = vc
  1 room = vc
  1 bed = vc
  1 sex = vc
  1 disch_dt_tm = vc
 
 
  1 org_id = f8;021
  1 org_name = vc;021
  1 org_street_add = vc;021
  1 org_city_state_zip = vc;021
 
 
  1 fnbr = vc
  1 med_service = vc
  1 admit_diagnosis = vc
  1 height = vc
  1 height_dt_tm = vc
  1 weight = vc
  1 weight_dt_tm = vc
  1 admit_dt = vc
  1 los = i4
  1 attending_cnt = i2
  1 attending [*]
    2 attending_phy = vc
  1 admitting = vc
  1 order_location = VC
  1 spoolout_ind = i2
  1 cnt = i2
  1 qual[*]
    2 order_id = f8
    2 encntr_id = f8
    2 org_id_future = f8
    2 org_name_future = vc
    2 org_street_add_fut = vc;021
    2 org_city_state_zip_fut = vc;021
    2 display_ind = i2
    2 template_order_flag = i2
    2 cs_flag = i2
    2 iv_ind = i2
    2 diag_code = vc ;021
    2 mnemonic = vc
    2 mnem_ln_cnt = i2
    2 mnem_ln_qual[*]
      3 mnem_line = vc
    2 display_line = vc
    2 disp_ln_cnt = i2
    2 disp_ln_qual[*]
      3 disp_line = vc
     2 disp_ln_cnt1 = i2
    2 disp_ln_qual1[*]
      3 disp_line1 = vc
    2 order_dt = vc
    2 signed_dt = vc
    2 status = vc
    2 accession = vc
    2 catalog = vc
    2 catalog_type_cd = f8
    2 activity = vc
    2 activity_type_cd = f8
    2 last_action_seq = i4
    2 enter_by = vc
    2 elec_signby = vc;021
    2 elec_signby2 =vc;021
    2 enter_npi = vc ;021
    2 enter_pos_cd = i4 ;021
    2 sup_signby = vc 			;022
    2 sup_pos_cd = i4			;022
    2 sup_npi = vc				;022
    2 order_dr = vc ;021
    2 ord_npi = vc ;021
    2 ord_pos_cd=i4 ;021
 
    2 enter_for = vc
    2 type = vc
    2 action = vc
    2 action_type_cd = f8
    2 comment_ind = i2
    2 comment = vc
    2 com_ln_cnt = i2
    2 com_ln_qual[*]
      3 com_line = vc
    2 oe_format_id = f8
    2 clin_line_ind = i2
    2 stat_ind = i2
    2 d_cnt = i2
    2 d_qual[*]
      3 field_description = vc
      3 label_text = vc
      3 value = vc
      3 field_value = f8
      3 oe_field_meaning_id = f8
      3 group_seq = i4
      3 print_ind = i2
      3 clin_line_ind = i2
      3 label = vc
      3 suffix = i2
      3 special_ind = i2
      3 dia_equ_ind = i2
      3 priority_ind = i2
    2 priority = vc
    2 req_st_dt = vc
    2 frequency = vc
    2 rate = vc
    2 duration = vc
    2 duration_unit = vc
    2 nurse_collect = vc
    2 fmt_action_cd = f8
    2 communication_type = vc
   1 dme_ind = i2					;023
   1 adt_ind = i2					;024
   1 disch_print_override = i2		;026
   1 health_plan[*]					;024
    2 plan_name = vc				;024
    2 seq = i2						;025
    2 subs_member_nbr = vc			;024
    2 group_name = vc				;024
    2 group_nbr	= vc				;024
    2 encntr_plan_reltn_id = f8		;024
    2 disp_line	= vc				;024
)
 
record allergy
( 1 cnt = i2
  1 qual[*]
    2 list = vc
  1 line = vc
  1 line_cnt = i2
  1 line_qual[*]
    2 line = vc
)
 
record diagnosis
( 1 cnt = i2
  1 qual[*]
    2 diag = vc
  1 dline = vc
  1 dline_cnt = i2
  1 dline_qual[*]
    2 dline = vc
)
 
record pt
( 1 line_cnt = i2
  1 lns[*]
    2 line = vc
)
 
 
/*****************************************************************************
*    Program Driver Variables                                                *
*****************************************************************************/
declare modnum				= c4 with protect,constant("v027") ;026;027
declare filename			= vc with protect,constant(concat(trim(cnvtlower(curprog)),modnum))	;026
declare NPI_CD              = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021"));021
declare CMRN_CD             = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"));021
 
declare order_cnt           = i4 with protect, noconstant(size(request->order_qual,5))
declare ord_cnt             = i4 with protect, noconstant(size(request->order_qual,5))
declare ord_cnt2            = i4 with protect, noconstant(0)
declare vv                  = i4 with protect, noconstant
set stat                    = alterlist(orders->qual,order_cnt)
 
declare person_id           = f8 with protect, noconstant(0.0)
declare encntr_id           = f8 with protect, noconstant(0.0)
 
set orders->spoolout_ind    = 0
set pharm_flag              = 0 ;set to 1 if you want to pull the MNEM_DISP_LEVEL and IV_DISP_LEVEL from the tables.
set vv                      = 0
 
declare comment_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 14, "ORD COMMENT"))
declare mrn_cd              = f8 with protect, constant(uar_get_code_by("MEANING", 319, "MRN"))
declare fnbr_cd             = f8 with protect, constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare admit_doc_cd        = f8 with protect, constant(uar_get_code_by("MEANING", 333, "ADMITDOC"))
declare attend_doc_cd       = f8 with protect, constant(uar_get_code_by("MEANING", 333, "ATTENDDOC"))
declare canceled_cd         = f8 with protect, constant(uar_get_code_by("MEANING", 12025, "CANCELED"))
declare inerror_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERROR"))
declare pharmacy_cd         = f8 with protect, constant(uar_get_code_by("MEANING", 6000, "PHARMACY"))
declare iv_cd               = f8 with protect, constant(uar_get_code_by("MEANING", 16389, "IVSOLUTIONS"))
declare complete_cd         = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "COMPLETE"))
declare modify_cd           = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "MODIFY"))
declare order_cd            = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ORDER"))
declare cancel_cd           = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "CANCEL"))
declare discont_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "DISCONTINUE"))
declare transfer_cd         = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "TRANSFER/CAN"))
declare reorder_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "CANCEL REORD"))
declare studactivate_cd     = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "STUDACTIVATE"))
declare activate_cd         = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ACTIVATE"))
declare void_cd             = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "VOID"))            ;005
declare suspend_cd          = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "SUSPEND"))         ;005
declare resume_cd           = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "RESUME"))          ;005
declare intermittent_cd     = f8 with protect, constant(uar_get_code_by("MEANING", 18309, "INTERMITTENT"))  ;005
 
 
declare electronic_sign_by                      = i4 with noconstant(0),protect;021
declare Amb_ind                                 = i4 with noconstant(0),protect;021
declare electronic_sign_by2                     = i4 with noconstant(0),protect;021
declare 400_ICD10_cd	                        = f8  with protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"));021
declare 261_discharge_cd                        = f8  with protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17019"));021
 
declare 6000_Radiology_cd                       = f8  with protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3082"));021
declare 6000_ADT_cd                 		    = f8  with protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1302985"));024
 
;021
declare 88_PHYSANESTHESIOLOGY_CD                = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANANESTHESIOLOGY"))
declare 88_PHYSCOLONANDRECTALSURGERY_CD         = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANCOLONANDRECTALSURGERY"))
declare 88_PHYSCARDIOVASCULARSURGERY_CD         = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANCARDIOVASCULARSURGERY"))
declare 88_PHYSCARDIOLOGY_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANCARDIOLOGY"))
declare 88_PHYSDERMATOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANDERMATOLOGY"))
declare 88_PHYSEMERGENCYMEDICINE_CD             = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANEMERGENCYMEDICINE"))
declare 88_EMERMEDICINEMEDICALDIRECTOR_CD       = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "EMERGENCYMEDICINEMEDICALDIRECTOR"))
declare 88_EMERMEDICINENURSEPRACTITIONER_CD     = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "EMERGENCYMEDICINENURSEPRACTITIONER"))
declare 88_EMERMEDICINEPHYSICIANASSISTANT_CD    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "EMERGENCYMEDICINEPHYSICIANASSISTANT"))
declare 88_PHYSENDOCRINOLOGY_CD                 = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANENDOCRINOLOGY"))
declare 88_PHYSOTOLARYNGOLOGY_CD                = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANOTOLARYNGOLOGY"))
declare 88_PHYSGASTROENTEROLOGY_CD              = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANGASTROENTEROLOGY"))
declare 88_PHYSGENERALSURGERY_CD                = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANGENERALSURGERY"))
declare 88_PHYSHOSPITALIST_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANHOSPITALIST"))
declare 88_PHYSNEPHROLOGY_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANNEPHROLOGY"))
declare 88_PHYSNEUROSURGERY_CD                  = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANNEUROSURGERY"))
declare 88_PHYSWOMENSHEALTH_CD                  = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANWOMENSHEALTH"))
declare 88_PHYSOPHTHALMOLOGY_CD                 = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANOPHTHALMOLOGY"))
declare 88_PHYSORTHOPAEDICSURGERY_CD            = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANORTHOPAEDICSURGERY"))
declare 88_PHYSPEDIATRICCARDIOLOGY_CD           = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICCARDIOLOGY"))
declare 88_PHYSPEDIATRICEMERGENCY_CD            = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICEMERGENCY"))
declare 88_PHYSPEDIATRICGASTROENTEROLOGY_CD     = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICGASTROENTEROLOGY"))
declare 88_PHYSPEDIATRICS_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICS"))
declare 88_PHYSPEDIATRICSURGERY_CD              = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICSURGERY"))
declare 88_PHYSNEUROLOGY_CD                     = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANNEUROLOGY"))
declare 88_PHYSPHYSICALMEDICINEREHAB_CD         = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPHYSICALMEDICINEREHAB"))
declare 88_PHYSONCOLOGY_CD                      = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANONCOLOGY"))
declare 88_PHYSPLASTICSURGERY_CD                = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPLASTICSURGERY"))
declare 88_PHYSPODIATRY_CD                      = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPODIATRY"))
declare 88_PHYSADULTMEDICINE_CD                 = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANADULTMEDICINE"))
declare 88_PHYSPULMONOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPULMONOLOGY"))
declare 88_RADNIOLOGIST_CD                      = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "RADNETRADIOLOGIST"))
declare 88_PHYSINTERVENTIONALRADIOLOGIST_CD     = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANINTERVENTIONALRADIOLOGIST"))
declare 88_PHYSUROLOGY_CD                       = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANUROLOGY"))
declare 88_PHYSVASCULARSURGERY_CD               = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANVASCULARSURGERY"))
declare 88_NURSTITIONER_CD                      = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "NURSEPRACTITIONER"))
declare 88_PHYSASSISTANT_CD                     = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANASSISTANT"))
declare 88_PHYSURGENTCARE_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANURGENTCARE"))
declare 88_PHYSPSYCHIATRY_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPSYCHIATRY"))
declare 88_PHYSNEONATOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANNEONATOLOGY"))
declare 88_PHYSINTENSIVIST_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANINTENSIVIST"))
declare 88_PHYSLTC_CD                           = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANLTC"))
declare 88_PHYSTRANSPLANT_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANTRANSPLANT"))
declare 88_PHYSINFECTIOUSDISEASE_CD             = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANINFECTIOUSDISEASE"))
declare 88_PHYSTRAUMASURGERY_CD                 = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANTRAUMASURGERY"))
declare 88_PHYSIM_CD                            = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANIM"))
declare 88_PHYSPALLIATIVECARE_CD                = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPALLIATIVECARE"))
declare 88_PHYSPHYSIATRIST_CD                   = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANPHYSIATRIST"))
declare 88_PHYSORALMAXILLOFACIAL_CD             = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANORALMAXILLOFACIAL"))
declare 88_PHYSNEUROHOSPITALIST_CD              = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANNEUROHOSPITALIST"))
declare 88_PHYSGYNECOLOGYONCOLOGY_CD            = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 88, "PHYSICIANGYNECOLOGYONCOLOGY"))
 
declare 6006_COSIGNED_REQ_CD                    = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 6006, "COSIGNREQUIRED"))
declare 6000_AMBULATORYPROCEDURES_CD            = f8 with protect, constant(uar_get_code_by
                                                    ("DISPLAYKEY", 6000, "AMBULATORYPROCEDURES"))
 
;CLINICAL STAFF'S POSITIONS     /*021*/
 
declare 88_AMBULATORYCLINICALOFFICEMANAGER_CD        = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYCLINICALOFFICEMANAGER"))
declare 88_AMBULATORYLPN_CD                          = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYLPN"))
declare 88_AMBULATORYLPNWITHRADNET_CD                = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYLPNWITHRADNET"))
declare 88_AMBULATORYLABRADTECH_CD                   = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYLABRADTECH"))
declare 88_AMBULATORYMACERTIFIED_CD                  = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYMACERTIFIED"))
declare 88_AMBULATORYMACERTIFIEDWITHRADNET_CD        = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYMACERTIFIEDWITHRADNET"))
declare 88_AMBULATORYRN_CD                           = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYRN"))
declare 88_AMBULATORYRNWITHRADNET_CD                 = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYRNWITHRADNET"))
declare 88_AMBULATORYREFERRALCOORDINATOR_CD          = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "AMBULATORYREFERRALCOORDINATOR"))
declare 88_WOMENSHEALTHAMBULATORYLPN_CD              = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "WOMENSHEALTHAMBULATORYLPN"))
declare 88_WOMENSHEALTHAMBULATORYMACERTIFIED_CD      = f8 with protect, constant(uar_get_code_by
                                                                          ("DISPLAYKEY", 88, "WOMENSHEALTHAMBULATORYMACERTIFIED"))
declare 88_WOMENSHEALTHAMBULATORYRN_CD               = f8 with protect, constant(uar_get_code_by
                                                                           ("DISPLAYKEY", 88, "WOMENSHEALTHAMBULATORYRN"))
 
; Physician's position      /*021*/
 
declare 88_PHYSICIANCARDIOLOGY_CD                    = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANCARDIOLOGY"))
declare 88_PHYSICIANCARDIOVASCULARSURGERY_CD         = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANCARDIOVASCULARSURGERY"))
declare 88_PHYSICIANDERMATOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANDERMATOLOGY"))
declare 88_PHYSICIANENDOCRINOLOGY_CD                 = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANENDOCRINOLOGY"))
declare 88_PHYSICIANGASTROENTEROLOGY_CD              = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANGASTROENTEROLOGY"))
declare 88_PHYSICIANGYNECOLOGYONCOLOGY_CD            = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANGYNECOLOGYONCOLOGY"))
declare 88_PHYSICIANADULTMEDICINE_CD                 = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANADULTMEDICINE"))
declare 88_PHYSICIANINFECTIOUSDISEASE_CD             = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANINFECTIOUSDISEASE"))
declare 88_PHYSICIANINTENSIVIST_CD                   = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANINTENSIVIST"))
declare 88_PHYSICIANINTERVENTIONALRADIOLOGIST_CD     = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANINTERVENTIONALRADIOLOGIST"))
declare 88_PHYSICIANLTC_CD                           = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANLTC"))
declare 88_PHYSICIANNEPHROLOGY_CD                    = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANNEPHROLOGY"))
declare 88_PHYSICIANNEONATOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANNEONATOLOGY"))
declare 88_PHYSICIANNEUROSURGERY_CD                  = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANNEUROSURGERY"))
declare 88_PHYSICIANNEUROLOGY_CD                     = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANNEUROLOGY"))
declare 88_PHYSICIANWOMENSHEALTH_CD                  = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANWOMENSHEALTH"))
declare 88_PHYSICIANONCOLOGY_CD                      = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANONCOLOGY"))
declare 88_PHYSICIANOPHTHALMOLOGY_CD                 = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANOPHTHALMOLOGY"))
declare 88_PHYSICIANORALMAXILLOFACIAL_CD             = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANORALMAXILLOFACIAL"))
declare 88_PHYSICIANORTHOPAEDICSURGERY_CD            = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANORTHOPAEDICSURGERY"))
declare 88_PHYSICIANOTOLARYNGOLOGY_CD                = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANOTOLARYNGOLOGY"))
declare 88_PHYSICIANPALLIATIVECARE_CD                = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPALLIATIVECARE"))
declare 88_PHYSICIANPEDIATRICS_CD                    =  f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICS"))
declare 88_PHYSICIANPHYSIATRIST_CD                   =  f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPHYSIATRIST"))
declare 88_PHYSICIANPLASTICSURGERY_CD                = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPLASTICSURGERY"))
declare 88_PHYSICIANPODIATRY_CD                      = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPODIATRY"))
declare 88_PHYSICIANPSYCHIATRY_CD                    = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPSYCHIATRY"))
declare 88_PHYSICIANPULMONOLOGY_CD                   = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPULMONOLOGY"))
DECLARE 88_PHYSICIANPHYSICALMEDICINEREHAB_CD         = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPHYSICALMEDICINEREHAB"))
declare 88_PHYSICIANRHEUMATOLOGY_CD                  = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANRHEUMATOLOGY"))
declare 88_PHYSICIANGENERALSURGERY_CD                = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANGENERALSURGERY"))
declare 88_PHYSICIANUROLOGY_CD                       = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANUROLOGY"))
declare 88_PHYSICIANVASCULARSURGERY_CD               = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANVASCULARSURGERY"))
declare 88_PHYSICIANASSISTANT_CD                     = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANASSISTANT"))
declare 88_NURSEPRACTITIONER_CD                      = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "NURSEPRACTITIONER"))
declare 88_PHYSICIANANESTHESIOLOGY_CD                = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANANESTHESIOLOGY"))
declare 88_PHYSICIANPEDIATRICEMERGENCY_CD            = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANPEDIATRICEMERGENCY"))
declare 88_PHYSICIANURGENTCARE_CD                    = f8 with protect, constant(uar_get_code_by
                                                       ("DISPLAYKEY", 88, "PHYSICIANURGENTCARE"))
;021
 
declare last_mod                = c3 with private, noconstant(fillstring(3, "000"))
declare offset                  = i2 with protect, noconstant(0)
declare daylight                = i2 with protect, noconstant(0)
declare attending_wrap          = i2 with protect, noconstant(0)
declare attending_line_cnt      = i2 with protect, noconstant(0)
declare max_space               = i4 with protect, constant(42)
declare max_display             = i4 with protect, constant(38)
 
declare mnemonic_size           = i4 with protect, noconstant(0)  ;002
declare mnem_length             = i4 with protect, noconstant(0)    ;002
declare num                     = i4 with noconstant(0)
 
 
 
;order detail constants     ;021
 
declare Preprocessing_Script_cd 		          = f8 with protect, constant(21728437.00)
declare Adhoc_Frequency_Instance_cd 		      = f8 with protect, constant(12775.00)
declare Next_Dose_Dt_Tm_cd           		      = f8 with protect, constant(633594.00)
declare Difference_in_Minutes_cd          		  = f8 with protect, constant(633595.00)
declare Frequency_Schedule_Id_cd          		  = f8 with protect, constant(2553779337.00)
declare req_radiology_ord_field_cd         		  = f8 with protect, constant(12585.00)
declare Ord_entered_by_cd         		          = f8 with protect, constant(73801613.00)


/* start ;026 */

declare op_cardiac_rehab_cd 					  = f8 with protect, noconstant(0.0)
declare op_pulmonary_rehab_cd 					  = f8 with protect, noconstant(0.0)

select into "nl:"
from
	order_catalog oc
plan oc
	where oc.primary_mnemonic in(
									 "Schedule For Outpatient Cardiac Rehabilitation"
									,"Schedule For Outpatient Pulmonary Rehabilitation"
								)
	and	  oc.active_ind 		= 1
order by
	 oc.primary_mnemonic
	,oc.updt_dt_tm desc
head oc.primary_mnemonic
	case (oc.primary_mnemonic)
		of "Schedule For Outpatient Cardiac Rehabilitation":		op_cardiac_rehab_cd		= oc.catalog_cd
		of "Schedule For Outpatient Pulmonary Rehabilitation":		op_pulmonary_rehab_cd	= oc.catalog_cd
	endcase
with nocounter

call echo(build2(^"Schedule for Outpatient for Cardiac Rehabilitation":^,op_cardiac_rehab_cd))
call echo(build2(^"Schedule for Outpatient for Pulmonary Rehabilitation":^,op_pulmonary_rehab_cd))

/*end ;026 */ 
/******************************************************************************
*     PATIENT INFORMATION                                                     *
******************************************************************************/
 
select into "nl:"
 
from
    person  p,
    encounter  e,
    organization org,;021
    address a,;021
    person_alias  pa,
    encntr_alias  ea,
    encntr_prsnl_reltn  epr,
    prsnl  pl,
    (dummyt d1 with seq = 1),
    encntr_loc_hist elh,
    time_zone_r t
plan p
  where p.person_id =  request->person_id
 
join e
  where e.encntr_id = outerjoin(request->order_qual[1].encntr_id)   ;021
 
join org;021
   where org.ORGANIZATION_ID = outerjoin(e.ORGANIZATION_ID) ;021
 
join a  ;021
  where a.PARENT_ENTITY_ID = outerjoin(org.ORGANIZATION_ID)   ;021
    and a.ADDRESS_TYPE_CD  =outerjoin(754)  ;021
    and a.ACTIVE_IND =outerjoin( 1) ;021
    and a.END_EFFECTIVE_DT_TM >outerjoin( cnvtdatetime(curdate,curtime))    ;021
 
join elh
  where elh.encntr_id = outerjoin(e.encntr_id)  ;021
 
join t
  where t.parent_entity_id = outerjoin(elh.loc_facility_cd)
    and t.parent_entity_name = outerjoin("LOCATION")
 
join pa
  where pa.person_id = outerjoin(p.person_id)
    and pa.PERSON_ALIAS_TYPE_CD = outerjoin(CMRN_CD)    ;021
    and pa.active_ind = outerjoin(1)    ;021
    and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))  ;021
    and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))  ;021
 
join ea
  where ea.encntr_id = outerjoin(e.encntr_id)
    and (ea.encntr_alias_type_cd = outerjoin(mrn_cd)    ;021
    or ea.encntr_alias_type_cd = outerjoin(fnbr_cd))    ;021
    and ea.active_ind = outerjoin(1)    ;021
 
join d1
 
join epr
  where epr.encntr_id = outerjoin(e.encntr_id)
    and (epr.encntr_prsnl_r_cd =outerjoin( admit_doc_cd)    ;021
    or epr.encntr_prsnl_r_cd =outerjoin( attend_doc_cd))    ;021
    and epr.active_ind = outerjoin(1)   ;021
 
join pl
  where pl.person_id = outerjoin(epr.prsnl_person_id)   ;021
 
head report
 
  person_id                  = p.person_id
  encntr_id                  = e.encntr_id
  orders->name               = p.name_full_formatted
  orders->pat_type           = trim(uar_get_code_display(e.encntr_type_cd))
  orders->sex                = uar_get_code_display(p.sex_cd)
  orders->age                = cnvtage(p.birth_dt_tm)
  orders->admit_dt           = format(e.reg_dt_tm, "@SHORTDATE")  ;011
  orders->dob                = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"@SHORTDATE") ;015
  orders->facility           = uar_get_code_description(e.loc_facility_cd)
  orders->nurse_unit         = uar_get_code_display(e.loc_nurse_unit_cd)
  orders->room               = uar_get_code_display(e.loc_room_cd)
  orders->bed                = uar_get_code_display(e.loc_bed_cd)
  orders->location           = concat(trim(orders->room)," ",trim(orders->bed))
  orders->admit_diagnosis    = e.reason_for_visit
  orders->med_service        = uar_get_code_display(e.med_service_cd)
  orders->disch_dt_tm        = format(e.disch_dt_tm, "@SHORTDATE")
 
  orders->org_id             = org.ORGANIZATION_ID  ;021
  orders->org_name           = org.ORG_NAME    ;021
 
  if(a.STREET_ADDR2 != null)
    orders->org_street_add   = concat(trim(a.STREET_ADDR)," ",trim(a.STREET_ADDR2))
  else
    orders->org_street_add   = trim(a.STREET_ADDR)
  endif
 
  orders->org_city_state_zip = build2(trim(a.city),", ",trim(a.STATE)," ",a.ZIPCODE)
 
  if (e.disch_dt_tm = null or e.disch_dt_tm = 0)
    orders->los              = datetimecmp(cnvtdatetime(curdate,curtime3),e.reg_dt_tm)+1
  else
    orders->los              = datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+1
  endif
 
head epr.encntr_prsnl_r_cd
 
  if (epr.encntr_prsnl_r_cd = admit_doc_cd)
    orders->admitting       = pl.name_full_formatted
  endif
 
detail
 
  if (ea.encntr_alias_type_cd = mrn_cd)
    if (ea.alias_pool_cd > 0)
      orders->mrn           = cnvtalias(ea.alias,ea.alias_pool_cd)
    else
      orders->mrn           = ea.alias
    endif
  endif
 
  if (ea.encntr_alias_type_cd = fnbr_cd)
    if (ea.alias_pool_cd > 0)
      orders->fnbr          = cnvtalias(ea.alias,ea.alias_pool_cd)
    else
      orders->fnbr          = ea.alias
    endif
  endif
 
  if (pa.PERSON_ALIAS_TYPE_CD = cmrn_cd)
    if (pa.ALIAS_POOL_CD > 0)
      orders->cmrn          = cnvtalias(pa.alias,pa.alias_pool_cd)
    else
      orders->cmrn          = pa.alias
    endif
  endif
 
with nocounter,outerjoin=d1,dontcare=epr
 
 
/* Attending MD requires an additional select statement */
 
select into "nl:"
from encntr_prsnl_reltn epr,
     prsnl pl
 
plan epr
  where epr.encntr_prsnl_r_cd = attend_doc_cd
    and epr.encntr_id = request->order_qual[1].encntr_id
    and epr.expiration_ind + 0 = 0
join pl
  where pl.person_id = epr.prsnl_person_id
 
order by epr.active_status_dt_tm DESC                                                                       /*13 starts here*/
 
head report
   orders->attending_cnt        = 0
   stat                         = alterlist(orders->attending, 1)
detail
  orders->attending_cnt         = orders->attending_cnt + 1
  if (orders->attending_cnt = 1)
    orders->attending[1].attending_phy = pl.name_full_formatted
  endif
foot report
    row +0
with nocounter
 
;The multiple lines are created for attending physician's whose name cannot be fit within the boundary of the requisition,
;i.e. if there is only one attending physician and if the name of that attending physician is greater than the space(max_space)
;that is available in the requisition we display the name in two lines.
 
if (orders->attending_cnt = 1)
   set pt->line_cnt = 0
   execute dcp_parse_text value(orders->attending[orders->attending_cnt].attending_phy), value(max_space)
   set stat = alterlist(orders->attending, pt->line_cnt)
   set attending_line_cnt = pt->line_cnt
   set attending_wrap = 1
   for (x = 1 to pt->line_cnt)
     set orders->attending[x].attending_phy = pt->lns[x].line
   endfor
elseif (orders->attending_cnt > 1)
    if (textlen(orders->attending[1].attending_phy) > max_space)
        set orders->attending[1].attending_phy = concat(substring(1, max_display,orders->attending[1].attending_phy), "...")
    endif
endif
 
;The "elseif" part is used if there are more than one attending physician so that the name of attending physician
;will display along with an ellipsis if its too long to be displayed in the same line.                      /*13 ends here*/
 
 
/******************************************************************************
*     CLINICAL EVENT INFORMATION                                              *
******************************************************************************/
 
set height_cd = uar_get_code_by("DISPLAYKEY", 72, "CLINICALHEIGHT")
set weight_cd = uar_get_code_by("DISPLAYKEY", 72, "CLINICALWEIGHT")
 
select into "nl:"
 
from
    clinical_event  c
 
plan c
  where c.person_id = person_id
    and c.event_cd in (height_cd,weight_cd)
    and c.view_level = 1
    and c.publish_flag = 1
    and c.valid_until_dt_tm = cnvtdatetime("31-DEC-2100,00:00:00")
    and c.result_status_cd != inerror_cd
 
 
 
order by
    c.event_end_dt_tm
 
detail  if (c.event_cd = height_cd)
    orders->height = concat(trim(c.event_tag)," ",
        trim(uar_get_code_display(c.result_units_cd)))
    orders->height_dt_tm =
        datetimezoneformat(c.performed_dt_tm, c.performed_tz, "@SHORTDATETIMENOSEC")
  elseif (c.event_cd = weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",
        trim(uar_get_code_display(c.result_units_cd)))
    orders->weight_dt_tm =
        datetimezoneformat(c.performed_dt_tm, c.performed_tz, "@SHORTDATETIMENOSEC")
  endif
 
with  nocounter
 
 
/******************************************************************************
*     FIND ACTIVE ALLERGIES AND CREATE ALLERGY LINE                           *
******************************************************************************/
 
select into "nl:"
from allergy a,
     nomenclature n
 
plan a
  where a.person_id = request->person_id
    and a.active_ind = 1
    and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and (a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      or a.end_effective_dt_tm = NULL)
    and a.reaction_status_cd != canceled_cd
join n
  where n.nomenclature_id = outerjoin(a.substance_nom_id)
 
order cnvtdatetime(a.onset_dt_tm)
 
head report
  allergy->cnt = 0
 
detail
    allergy->cnt = allergy->cnt + 1
    stat = alterlist(allergy->qual,allergy->cnt)
    if (n.nomenclature_id < 1)
        allergy->qual[allergy->cnt].list = trim(a.substance_ftdesc, 3)
    else
        allergy->qual[allergy->cnt].list = trim(n.source_string, 3)
    endif
with nocounter
 
for (x = 1 to allergy->cnt)
  if (x = 1)
    set allergy->line = allergy->qual[x].list
  else
    set allergy->line = concat(trim(allergy->line),", ",
      trim(allergy->qual[x].list))
  endif
endfor
 
if (allergy->cnt > 0)
   set pt->line_cnt = 0
   set max_length = 90          ; Number of characters to be prined per line
   execute dcp_parse_text value(allergy->line), value(max_length)
   set stat = alterlist(allergy->line_qual, pt->line_cnt)
   set allergy->line_cnt = pt->line_cnt
   for (x = 1 to pt->line_cnt)
     set allergy->line_qual[x].line = pt->lns[x].line
   endfor
endif
 
 
/******************************************************************************
*     USED FOR THE MNEMONIC ON PHARMACY ORDERS                                *
******************************************************************************/
 
set mnem_disp_level = "1"
set iv_disp_level = "0"
 
if (pharm_flag = 1)
   select into "nl:"
   from name_value_prefs n,app_prefs a
 
   plan n
     where n.pvc_name in ("MNEM_DISP_LEVEL","IV_DISP_LEVEL")
   join a
     where a.app_prefs_id = n.parent_entity_id
       and a.prsnl_id = 0
       and a.position_cd = 0
 
   detail
     if (n.pvc_name = "MNEM_DISP_LEVEL"
     and n.pvc_value in ("0","1","2"))
       mnem_disp_level = n.pvc_value
     elseif (n.pvc_name = "IV_DISP_LEVEL"
     and n.pvc_value in ("0","1"))
       iv_disp_level = n.pvc_value
     endif
 
   with nocounter
endif
 
 
/******************************************************************************
*     ORDER LEVEL INFORMATION                                                 *
******************************************************************************/
declare oiCnt = i4 with protect, noconstant(0)          ;005
 
set ord_cnt = 0                 ;014
set oiCnt = 0                   ;018
set max_length = 70 ;018
 
select into "nl:"
from  orders o,
      order_action oa,
      order_notification ono,   ;021
      order_proposal op,    ;021
      encounter e,   ;021
      prsnl pl,
      prsnl pl2,
      prsnl pl3,    ;021
      prsnl pl4,    ;022
      prsnl_alias pa,
      prsnl_alias pa1,
      prsnl_alias pa2,  ;021
      prsnl_alias pa3,  ;022
 
       diagnosis d,;021
       nomenclature nomen,
      (dummyt d1 with seq = value(order_cnt)),
      (dummyt d2 with seq = value(order_cnt)),
      order_ingredient oi                                           ;018
 
plan d1
 
join o
  where o.order_id = request->order_qual[d1.seq].order_id
 
 
join e
    where e.encntr_id=o.encntr_id
    and e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
join oa
  where oa.order_id = o.order_id
    and ((request->order_qual[d1.seq].conversation_id > 0 and       ;017
          oa.order_conversation_id = request->order_qual[d1.seq].conversation_id) or
          (request->order_qual[d1.seq].conversation_id <= 0 and oa.action_sequence = o.last_action_sequence))
 
join ono    ;021
where ono.ORDER_ID=outerjoin(o.ORDER_ID)    ;021
 
join op ;021
where op.order_id=outerjoin(o.order_id) ;021
 
join pl3    ;021
where pl3.person_id= outerjoin(op.entered_by_prsnl_id)  ;021
 
join pl
  where pl.person_id = outerjoin(oa.action_personnel_id)
 
join pl2
  where pl2.person_id = outerjoin(oa.order_provider_id)
 
join pl4															;022
  where pl4.person_id = outerjoin(oa.supervising_provider_id)		;022
 
join pa
    where outerjoin(pl2.PERSON_ID)=(pa.PERSON_ID)
    and pa.ACTIVE_IND = outerjoin(1)
    and pa.PRSNL_ALIAS_TYPE_CD=outerjoin(NPI_CD)    ;021
 
join pa1
    where outerjoin(pl.PERSON_ID)=(pa1.PERSON_ID)
    and pa1.ACTIVE_IND = outerjoin(1)
    and pa1.PRSNL_ALIAS_TYPE_CD=outerjoin(NPI_CD)   ;021
 
join pa2
 where outerjoin(pl3.PERSON_ID)=pa2.PERSON_ID
    and pa1.ACTIVE_IND = outerjoin(1)
    and pa1.PRSNL_ALIAS_TYPE_CD=outerjoin(NPI_CD)   ;021
 
join pa3											;022
 where outerjoin(pl4.PERSON_ID)=pa3.PERSON_ID		;022
    and pa3.ACTIVE_IND = outerjoin(1)				;022
    and pa3.PRSNL_ALIAS_TYPE_CD=outerjoin(NPI_CD)   ;022
    ;021 start
 
    join d
        where d.ENCNTR_ID = outerjoin(o.ENCNTR_ID)
        and d.active_ind = outerjoin(1)
        and d.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
        and d.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    join nomen
        where nomen.nomenclature_id = outerjoin(d.nomenclature_id)
        and nomen.active_ind =outerjoin(1)
        and nomen.source_vocabulary_cd = outerjoin( 400_ICD10_cd );   647081.00
        and nomen.PRINCIPLE_TYPE_CD= outerjoin(1252)
        and nomen.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
        and nomen.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
 
    ;021 stop
 
join d2
  join oi where o.order_id = oi.order_id                            ;018
    and o.last_ingred_action_sequence = oi.action_sequence          ;018
 
order by o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
 
head report
  orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  mnemonic_size = size(o.hna_order_mnemonic,3) - 1  ;002
 
head o.order_id
  ord_cnt = ord_cnt + 1
  orders->qual[ord_cnt].status                      = uar_get_code_display(o.order_status_cd)
  orders->qual[ord_cnt].catalog                     = uar_get_code_display(o.catalog_type_cd)
  orders->qual[ord_cnt].catalog_type_cd             = o.catalog_type_cd
  orders->qual[ord_cnt].activity                    = uar_get_code_display(o.activity_type_cd)
  orders->qual[ord_cnt].activity_type_cd            = o.activity_type_cd
  orders->qual[ord_cnt].display_line                = o.clinical_display_line
  orders->qual[ord_cnt].order_id                    = o.order_id
  orders->qual[ord_cnt].encntr_id                   = o.encntr_id
  orders->qual[ord_cnt].display_ind                 = 1
  orders->qual[ord_cnt].template_order_flag         = o.template_order_flag
  orders->qual[ord_cnt].cs_flag                     = o.cs_flag
  orders->qual[ord_cnt].oe_format_id                = o.oe_format_id
 
  orders->qual[ord_cnt].communication_type          = uar_get_code_display(oa.communication_type_cd)
 
  if(o.CATALOG_TYPE_CD != 6000_AMBULATORYPROCEDURES_CD) ;021
    orders->qual[ord_cnt].diag_code                   = concat(trim(d.diagnosis_display)," ",trim(nomen.source_identifier,3)) ;021
  endif
  
  if (o.catalog_cd in(op_cardiac_rehab_cd,op_pulmonary_rehab_cd))		;026
  	orders->disch_print_override = 1									;026
  endif																	;026

 
  if (size(substring(245,10,o.clinical_display_line),1) > 0)     ;006
    orders->qual[ord_cnt].clin_line_ind = 1
  else
    orders->qual[ord_cnt].clin_line_ind = 0
  endif
 
  ;BEGIN 002
  mnem_length = size(trim(o.hna_order_mnemonic),1)
 
  if (mnem_length >= mnemonic_size
      and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
    orders->qual[ord_cnt].mnemonic = concat(cnvtupper(trim(o.hna_order_mnemonic)), "...")
  else
    orders->qual[ord_cnt].mnemonic = cnvtupper(trim(o.hna_order_mnemonic))
  endif
 
    orders->qual[ord_cnt].order_dt                  = format(oa.order_dt_tm, "@SHORTDATETIMENOSEC")
    orders->qual[ord_cnt].signed_dt                 = format(o.orig_order_dt_tm, "@SHORTDATETIMENOSEC")
    orders->qual[ord_cnt].comment_ind               = o.order_comment_ind
    orders->qual[ord_cnt].last_action_seq           = o.last_action_sequence
    orders->qual[ord_cnt].enter_by                  = pl.name_full_formatted
    orders->qual[ord_cnt].enter_npi                 = pa1.ALIAS     ;021
    orders->qual[ord_cnt].enter_pos_cd              = pl.POSITION_CD
    orders->qual[ord_cnt].order_dr                  = pl2.name_full_formatted
    orders->qual[ord_cnt].ord_npi                   = pa.ALIAS      ;021
    orders->qual[ord_cnt].ord_pos_cd                = pl2.POSITION_CD
 
 
 
 
 ;for discharg date to print only for acute         ;021
  if(o.CATALOG_TYPE_CD != 6000_AMBULATORYPROCEDURES_CD)
    Amb_ind =1
  endif
 
 ;lOGIC OF SIGNATURE                    ;021
 
 if(op.communication_type_cd = 6006_COSIGNED_REQ_CD)
 
    if(pl3.position_cd in (88_AMBULATORYCLINICALOFFICEMANAGER_CD ;op.entered_by_prsnl_id
                          ,88_AMBULATORYLPN_CD
                          ,88_AMBULATORYLPNWITHRADNET_CD
                          ,88_AMBULATORYLABRADTECH_CD
                          ,88_AMBULATORYMACERTIFIED_CD
                          ,88_AMBULATORYMACERTIFIEDWITHRADNET_CD
                          ,88_AMBULATORYRN_CD
                          ,88_AMBULATORYRNWITHRADNET_CD
                          ,88_AMBULATORYREFERRALCOORDINATOR_CD
                          ,88_WOMENSHEALTHAMBULATORYLPN_CD
                          ,88_WOMENSHEALTHAMBULATORYMACERTIFIED_CD
                          ,88_WOMENSHEALTHAMBULATORYRN_CD )
 
   and pl2.POSITION_CD in (88_PHYSICIANCARDIOLOGY_CD			;oa.order_provider_id
                          ,88_PHYSICIANCARDIOVASCULARSURGERY_CD
                          ,88_PHYSICIANDERMATOLOGY_CD
                          ,88_PHYSICIANENDOCRINOLOGY_CD
                          ,88_PHYSICIANGASTROENTEROLOGY_CD
                          ,88_PHYSICIANGYNECOLOGYONCOLOGY_CD
                          ,88_PHYSICIANADULTMEDICINE_CD
                          ,88_PHYSICIANINFECTIOUSDISEASE_CD
                          ,88_PHYSICIANINTENSIVIST_CD
                          ,88_PHYSICIANINTERVENTIONALRADIOLOGIST_CD
                          ,88_PHYSICIANLTC_CD
                          ,88_PHYSICIANNEPHROLOGY_CD
                          ,88_PHYSICIANNEONATOLOGY_CD
                          ,88_PHYSICIANNEUROSURGERY_CD
                          ,88_PHYSICIANNEUROLOGY_CD
                          ,88_PHYSICIANWOMENSHEALTH_CD
                          ,88_PHYSICIANONCOLOGY_CD
                          ,88_PHYSICIANOPHTHALMOLOGY_CD
                          ,88_PHYSICIANORALMAXILLOFACIAL_CD
                          ,88_PHYSICIANORTHOPAEDICSURGERY_CD
                          ,88_PHYSICIANOTOLARYNGOLOGY_CD
                          ,88_PHYSICIANPALLIATIVECARE_CD
                          ,88_PHYSICIANPEDIATRICS_CD
                          ,88_PHYSICIANPHYSIATRIST_CD
                          ,88_PHYSICIANPLASTICSURGERY_CD
                          ,88_PHYSICIANPODIATRY_CD
                          ,88_PHYSICIANPSYCHIATRY_CD
                          ,88_PHYSICIANPULMONOLOGY_CD
                          ,88_PHYSICIANPHYSICALMEDICINEREHAB_CD
                          ,88_PHYSICIANRHEUMATOLOGY_CD
                          ,88_PHYSICIANGENERALSURGERY_CD
                          ,88_PHYSICIANUROLOGY_CD
                          ,88_PHYSICIANVASCULARSURGERY_CD
                          ,88_PHYSICIANASSISTANT_CD
                          ,88_NURSEPRACTITIONER_CD
                          ,88_PHYSICIANANESTHESIOLOGY_CD
                          ,88_PHYSICIANPEDIATRICEMERGENCY_CD
                          ,88_PHYSICIANURGENTCARE_CD )
                        )
                orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
                orders->qual[ord_cnt].enter_by= pl3.name_full_formatted
                orders->qual[ord_cnt].enter_npi  = pa2.ALIAS
 
    endif
 else
    if(oa.action_personnel_id= oa.order_provider_id)
            if(pl2.POSITION_CD in (
                        88_PHYSANESTHESIOLOGY_CD,
                        88_PHYSCOLONANDRECTALSURGERY_CD,
                        88_PHYSCARDIOVASCULARSURGERY_CD,
                        88_PHYSCARDIOLOGY_CD,
                        88_PHYSDERMATOLOGY_CD,
                        88_PHYSEMERGENCYMEDICINE_CD,
                        88_EMERMEDICINEMEDICALDIRECTOR_CD,
                        88_EMERMEDICINENURSEPRACTITIONER_CD,
                        88_EMERMEDICINEPHYSICIANASSISTANT_CD,
                        88_PHYSENDOCRINOLOGY_CD,
                        88_PHYSOTOLARYNGOLOGY_CD,
                        88_PHYSGASTROENTEROLOGY_CD,
                        88_PHYSGENERALSURGERY_CD,
                        88_PHYSHOSPITALIST_CD,
                        88_PHYSNEPHROLOGY_CD,
                        88_PHYSNEUROSURGERY_CD,
                        88_PHYSWOMENSHEALTH_CD,
                        88_PHYSOPHTHALMOLOGY_CD,
                        88_PHYSORTHOPAEDICSURGERY_CD,
                        88_PHYSPEDIATRICCARDIOLOGY_CD,
                        88_PHYSPEDIATRICEMERGENCY_CD,
                        88_PHYSPEDIATRICGASTROENTEROLOGY_CD,
                        88_PHYSPEDIATRICS_CD,
                        88_PHYSPEDIATRICSURGERY_CD,
                        88_PHYSNEUROLOGY_CD,
                        88_PHYSPHYSICALMEDICINEREHAB_CD,
                        88_PHYSONCOLOGY_CD,
                        88_PHYSPLASTICSURGERY_CD,
                        88_PHYSPODIATRY_CD,
                        88_PHYSADULTMEDICINE_CD,
                        88_PHYSPULMONOLOGY_CD,
                        88_RADNIOLOGIST_CD,
                        88_PHYSINTERVENTIONALRADIOLOGIST_CD,
                        88_PHYSUROLOGY_CD,
                        88_PHYSVASCULARSURGERY_CD,
                        88_NURSTITIONER_CD,
                        88_PHYSASSISTANT_CD,
                        88_PHYSURGENTCARE_CD,
                        88_PHYSPSYCHIATRY_CD,
                        88_PHYSNEONATOLOGY_CD,
                        88_PHYSINTENSIVIST_CD,
                        88_PHYSLTC_CD,
                        88_PHYSTRANSPLANT_CD,
                        88_PHYSINFECTIOUSDISEASE_CD,
                        88_PHYSTRAUMASURGERY_CD,
                        88_PHYSIM_CD,
                        88_PHYSPALLIATIVECARE_CD,
                        88_PHYSPHYSIATRIST_CD,
                        88_PHYSORALMAXILLOFACIAL_CD,
                        88_PHYSNEUROHOSPITALIST_CD,
                        88_PHYSGYNECOLOGYONCOLOGY_CD
                       ))
 
                   orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
            endif
 
 endif
 
 
 if (ono.notification_status_flag = 2 and ono.NOTIFICATION_TYPE_FLAG = 2 )
     if(o.CATALOG_TYPE_CD = 6000_AMBULATORYPROCEDURES_CD)
 
        if(pl.POSITION_CD in(88_AMBULATORYCLINICALOFFICEMANAGER_CD
                            ,88_AMBULATORYLPN_CD
                            ,88_AMBULATORYLPNWITHRADNET_CD
                            ,88_AMBULATORYLABRADTECH_CD
                            ,88_AMBULATORYMACERTIFIED_CD
                            ,88_AMBULATORYMACERTIFIEDWITHRADNET_CD
                            ,88_AMBULATORYRN_CD
                            ,88_AMBULATORYRNWITHRADNET_CD
                            ,88_AMBULATORYREFERRALCOORDINATOR_CD
                            ,88_WOMENSHEALTHAMBULATORYLPN_CD
                            ,88_WOMENSHEALTHAMBULATORYMACERTIFIED_CD
                            ,88_WOMENSHEALTHAMBULATORYRN_CD)
 
        and pl2.POSITION_CD in (88_PHYSICIANCARDIOLOGY_CD
                              ,88_PHYSICIANCARDIOVASCULARSURGERY_CD
                              ,88_PHYSICIANDERMATOLOGY_CD
                              ,88_PHYSICIANENDOCRINOLOGY_CD
                              ,88_PHYSICIANGASTROENTEROLOGY_CD
                              ,88_PHYSICIANGYNECOLOGYONCOLOGY_CD
                              ,88_PHYSICIANADULTMEDICINE_CD
                              ,88_PHYSICIANINFECTIOUSDISEASE_CD
                              ,88_PHYSICIANINTENSIVIST_CD
                              ,88_PHYSICIANINTERVENTIONALRADIOLOGIST_CD
                              ,88_PHYSICIANLTC_CD
                              ,88_PHYSICIANNEPHROLOGY_CD
                              ,88_PHYSICIANNEONATOLOGY_CD
                              ,88_PHYSICIANNEUROSURGERY_CD
                              ,88_PHYSICIANNEUROLOGY_CD
                              ,88_PHYSICIANWOMENSHEALTH_CD
                              ,88_PHYSICIANONCOLOGY_CD
                              ,88_PHYSICIANOPHTHALMOLOGY_CD
                              ,88_PHYSICIANORALMAXILLOFACIAL_CD
                              ,88_PHYSICIANORTHOPAEDICSURGERY_CD
                              ,88_PHYSICIANOTOLARYNGOLOGY_CD
                              ,88_PHYSICIANPALLIATIVECARE_CD
                              ,88_PHYSICIANPEDIATRICS_CD
                              ,88_PHYSICIANPHYSIATRIST_CD
                              ,88_PHYSICIANPLASTICSURGERY_CD
                              ,88_PHYSICIANPODIATRY_CD
                              ,88_PHYSICIANPSYCHIATRY_CD
                              ,88_PHYSICIANPULMONOLOGY_CD
                              ,88_PHYSICIANPHYSICALMEDICINEREHAB_CD
                              ,88_PHYSICIANRHEUMATOLOGY_CD
                              ,88_PHYSICIANGENERALSURGERY_CD
                              ,88_PHYSICIANUROLOGY_CD
                              ,88_PHYSICIANVASCULARSURGERY_CD
                              ,88_PHYSICIANASSISTANT_CD
                              ,88_NURSEPRACTITIONER_CD
                              ,88_PHYSICIANANESTHESIOLOGY_CD
                              ,88_PHYSICIANPEDIATRICEMERGENCY_CD
                              ,88_PHYSICIANURGENTCARE_CD ))
 
                   orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
                endif
                                elseif(pl2.POSITION_CD in (
                                88_PHYSANESTHESIOLOGY_CD,
                                88_PHYSCOLONANDRECTALSURGERY_CD,
                                88_PHYSCARDIOVASCULARSURGERY_CD,
                                88_PHYSCARDIOLOGY_CD,
                                88_PHYSDERMATOLOGY_CD,
                                88_PHYSEMERGENCYMEDICINE_CD,
                                88_EMERMEDICINEMEDICALDIRECTOR_CD,
                                88_EMERMEDICINENURSEPRACTITIONER_CD,
                                88_EMERMEDICINEPHYSICIANASSISTANT_CD,
                                88_PHYSENDOCRINOLOGY_CD,
                                88_PHYSOTOLARYNGOLOGY_CD,
                                88_PHYSGASTROENTEROLOGY_CD,
                                88_PHYSGENERALSURGERY_CD,
                                88_PHYSHOSPITALIST_CD,
                                88_PHYSNEPHROLOGY_CD,
                                88_PHYSNEUROSURGERY_CD,
                                88_PHYSWOMENSHEALTH_CD,
                                88_PHYSOPHTHALMOLOGY_CD,
                                88_PHYSORTHOPAEDICSURGERY_CD,
                                88_PHYSPEDIATRICCARDIOLOGY_CD,
                                88_PHYSPEDIATRICEMERGENCY_CD,
                                88_PHYSPEDIATRICGASTROENTEROLOGY_CD,
                                88_PHYSPEDIATRICS_CD,
                                88_PHYSPEDIATRICSURGERY_CD,
                                88_PHYSNEUROLOGY_CD,
                                88_PHYSPHYSICALMEDICINEREHAB_CD,
                                88_PHYSONCOLOGY_CD,
                                88_PHYSPLASTICSURGERY_CD,
                                88_PHYSPODIATRY_CD,
                                88_PHYSADULTMEDICINE_CD,
                                88_PHYSPULMONOLOGY_CD,
                                88_RADNIOLOGIST_CD,
                                88_PHYSINTERVENTIONALRADIOLOGIST_CD,
                                88_PHYSUROLOGY_CD,
                                88_PHYSVASCULARSURGERY_CD,
                                88_NURSTITIONER_CD,
                                88_PHYSASSISTANT_CD,
                                88_PHYSURGENTCARE_CD,
                                88_PHYSPSYCHIATRY_CD,
                                88_PHYSNEONATOLOGY_CD,
                                88_PHYSINTENSIVIST_CD,
                                88_PHYSLTC_CD,
                                88_PHYSTRANSPLANT_CD,
                                88_PHYSINFECTIOUSDISEASE_CD,
                                88_PHYSTRAUMASURGERY_CD,
                                88_PHYSIM_CD,
                                88_PHYSPALLIATIVECARE_CD,
                                88_PHYSPHYSIATRIST_CD,
                                88_PHYSORALMAXILLOFACIAL_CD,
                                88_PHYSNEUROHOSPITALIST_CD,
                                88_PHYSGYNECOLOGYONCOLOGY_CD
 
                                ))
 
                   orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
 
            endif
 endif
 endif
 
 ;021 ends
 
 ;023 start
 if ((o.order_mnemonic = "DME *") or (o.order_mnemonic = "SC DME *"))
 	orders->dme_ind = 1
 	orders->disch_print_override = 1	;026
 	if (ono.notification_status_flag = 2 and ono.NOTIFICATION_TYPE_FLAG = 2 ) 	;completed and cosign
 		call echo(build2(^if (ono.notification_status_flag = 2 and ono.NOTIFICATION_TYPE_FLAG = 2 )^))
 		orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
 	elseif (ono.notification_status_flag = 0 and ono.NOTIFICATION_TYPE_FLAG = 0 ) 	;no cosign needed
 	 	call echo(build2(^if (ono.notification_status_flag = 0 and ono.NOTIFICATION_TYPE_FLAG = 0 )^))
 		orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
 	endif
 	if (oa.action_personnel_id= oa.order_provider_id)							;person taking action is ordering provider
 		call echo(build2(^if (oa.action_personnel_id= oa.order_provider_id)^))
 		orders->qual[ord_cnt].elec_signby=build2(orders->qual[ord_cnt].order_dr,"  NPI #:",orders->qual[ord_cnt].ord_npi)
 	endif
 endif
 ;023 ends
 
 ;024 start
 if (o.catalog_type_cd = 6000_ADT_cd)
 	orders->adt_ind = 1
 endif
 ;024 end
 
 ;022 start
 if (oa.supervising_provider_id > 0.0)
    orders->qual[ord_cnt].sup_pos_cd	= pl4.position_cd
	orders->qual[ord_cnt].sup_signby 	= pl4.name_full_formatted
	orders->qual[ord_cnt].sup_npi  		= pa3.alias
	orders->qual[ord_cnt].sup_signby	= concat(trim(pl4.name_full_formatted),"  NPI #:",trim(pa3.alias))
 endif ;(oa.supervising_provider_id > 0.0)
 ;022 end
 
  orders->qual[ord_cnt].type                = uar_get_code_display(oa.communication_type_cd)
  orders->qual[ord_cnt].action_type_cd      = oa.action_type_cd
  orders->qual[ord_cnt].action              = uar_get_code_display(oa.action_type_cd)
  orders->qual[ord_cnt].iv_ind              = o.iv_ind
 
  if (o.dcp_clin_cat_cd = iv_cd)
    orders->qual[ord_cnt].iv_ind = 1
  endif
 
  head oi.comp_sequence                                                             ;005
 
    if (oi.comp_sequence >0 and o.med_order_type_cd = intermittent_cd)              ;005
      ;if the order ingredient is a diluent and is clinically significant           ;005
      if (oi.ingredient_type_flag = 2 and oi.clinically_significant_flag = 2)       ;005
        oiCnt = oiCnt + 1                                                           ;005
      ;if the order ingredient is a additive                                        ;005
      else if (oi.ingredient_type_flag = 3)                                         ;005
        oiCnt = oiCnt + 1                                                           ;005
      endif                                                                         ;005
      endif                                                                         ;005
    endif                                                                           ;005
 
  foot o.order_id                                                                   ;005
 
  if (o.catalog_type_cd = pharmacy_cd)
    if (o.iv_ind = 1 or (o.med_order_type_cd = intermittent_cd and oiCnt > 1) )                                     ;018
      if (iv_disp_level = "1")                                                                                      ;018
        ;if the display text is larger then the print area , add the '...' at the end                               ;018
        mnem_length = size(trim(o.ordered_as_mnemonic),1)                                                           ;018
        if (mnem_length > max_length)                                                                       ;018
          orders->qual[ord_cnt].mnemonic = trim(concat(substring(1, max_length-3, o.ordered_as_mnemonic), "..."))   ;018
        else                                                                                                        ;018
          orders->qual[ord_cnt].mnemonic = o.ordered_as_mnemonic                                                    ;018
        endif                                                                                                       ;018
      else                                                                                                          ;018
        ;if the display text is larger then the print area , add the '...' at the end                               ;018
        mnem_length = size(trim(o.hna_order_mnemonic),1)                                                            ;018
        if (mnem_length > max_length)                                                                               ;018
          orders->qual[ord_cnt].mnemonic = trim(concat(substring(1, max_length-3, o.hna_order_mnemonic), "..."))    ;018
        else                                                                                                        ;018
          orders->qual[ord_cnt].mnemonic = o.hna_order_mnemonic                                                     ;018
        endif                                                                                                       ;018
      endif                                                                                                         ;018
    else                                                                                                            ;018
    if (mnem_disp_level = "0")
      ;BEGIN 002
      mnem_length = size(trim(o.hna_order_mnemonic),1)
      if (mnem_length >= mnemonic_size
          and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
      else
        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
      endif
      ;END 002
    endif
    if (mnem_disp_level = "1")
      if ((o.hna_order_mnemonic = o.ordered_as_mnemonic)
         or (o.ordered_as_mnemonic = " "))
        ;BEGIN 002
        mnem_length = size(trim(o.hna_order_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
        else
          orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
        endif
        ;END 002
      else
        ;BEGIN 002
        mnem_length = size(trim(o.hna_order_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
        else
          orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
        endif
 
        mnem_length = size(trim(o.ordered_as_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),"...)")
        else
          orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),")")
        endif
        ;END 002
      endif
    endif
    if (mnem_disp_level = "2" and o.iv_ind != 1)
      if ((o.hna_order_mnemonic = o.ordered_as_mnemonic)
         or (o.ordered_as_mnemonic = " "))
        ;BEGIN 002
        mnem_length = size(trim(o.hna_order_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
        else
          orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
        endif
        ;END 002
      else
        ;BEGIN 002
        mnem_length = size(trim(o.hna_order_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic), "...")
        else
          orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
        endif
 
        mnem_length = size(trim(o.ordered_as_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.ordered_as_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),"...)")
        else
          orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o.ordered_as_mnemonic),")")
        endif
        ;END 002
      endif
      if ((o.order_mnemonic != o.ordered_as_mnemonic) and (size(o.order_mnemonic,1) > 0))     ;006
        ;BEGIN 002
        mnem_length = size(trim(o.order_mnemonic),1)
        if (mnem_length >= mnemonic_size
            and SUBSTRING(mnem_length - 3, mnem_length, o.order_mnemonic) != "...")
          orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o.order_mnemonic),"...)")
        else
          orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o.order_mnemonic),")")
        endif
        ;END 002
      endif
    endif
  endif
  endif     ;005
 
  if (oa.action_type_cd in (order_cd, suspend_cd, resume_cd, cancel_cd, discont_cd, void_cd))   ;005
    orders->qual[ord_cnt].fmt_action_cd = oa.action_type_cd                                     ;005
  else
    orders->qual[ord_cnt].fmt_action_cd = order_cd
  endif
 
  /* Put logic in here if you want to keep certain types of orders to not print
    May be things like complete orders/continuing orders/etc. */
 
;021 removed otherorder status and restring to only order,modify and discontinue status.
 
;021-new logic for printing
 
  if(o.CATALOG_TYPE_CD in (6000_AMBULATORYPROCEDURES_CD,6000_Radiology_cd)
  AND (oa.action_type_cd in (order_cd,modify_cd,discont_cd,activate_cd))
   AND o.template_order_flag != 7)
 
            orders->spoolout_ind = 1
            orders->qual[ord_cnt]->display_ind = 1
 
   elseif(o.CATALOG_TYPE_CD != 6000_AMBULATORYPROCEDURES_CD AND e.encntr_status_cd!=  261_discharge_cd
   AND(oa.action_type_cd in (order_cd,modify_cd,discont_cd,activate_cd)) AND o.template_order_flag != 7)
 
            orders->spoolout_ind = 1
            orders->qual[ord_cnt]->display_ind = 1
   
   elseif(	(orders->disch_print_override = 1)																	;026
   		AND	(oa.action_type_cd in (order_cd,modify_cd,discont_cd,activate_cd)) AND o.template_order_flag != 7)	;026
   																												;026
   			if (oa.action_type_cd in (discont_cd))																;027	
   				if (request->print_prsnl_id > 0)																;027
   					orders->spoolout_ind = 1																	;027
            		orders->qual[ord_cnt]->display_ind = 1														;027
            	endif																							;027
            else																								;027
   																												;027
   				orders->spoolout_ind = 1																		;026
            	orders->qual[ord_cnt]->display_ind = 1															;026
 																												;026
 			endif																								;027
   else																
 	
            orders->qual[ord_cnt]->display_ind = 0
   endif
 
;021    ends
 
with outerjoin = d2, nocounter
 
 
 
 
/******************************************************************************
*     ORDER DETAIL INFORMATION                                                *
******************************************************************************/
 declare z =i4
select into "nl:"
from order_detail od,
     oe_format_fields oef,
     order_entry_fields of1,
     nomenclature n,
     (dummyt d1 with seq = value(order_cnt))
 
plan d1
join od
  where orders->qual[d1.seq].order_id = od.order_id
join oef
  where oef.oe_format_id = orders->qual[d1.seq].oe_format_id
  and oef.oe_field_id = od.oe_field_id
  and oef.OE_FIELD_ID not in (Preprocessing_Script_cd   ;021
,Adhoc_Frequency_Instance_cd 	            ;021
,Next_Dose_Dt_Tm_cd           	            ;021
,Difference_in_Minutes_cd                   ;021
,Frequency_Schedule_Id_cd                   ;021
,req_radiology_ord_field_cd                 ;021
,Ord_entered_by_cd  )                       ;021
 
join of1
  where of1.oe_field_id = oef.oe_field_id
 
join n
    where n.nomenclature_id = outerjoin(od.oe_field_value)
 
order by od.order_id, od.oe_field_id, od.action_sequence desc
 
/* If order details need to print in the order on the format:
   order by od.order_id,oef.group_seq,oef.field_seq,od.oe_field_id,
   od.action_sequence desc */
 
head report
  orders->qual[d1.seq].d_cnt = 0
 
head od.order_id
  stat = alterlist(orders->qual[d1.seq].d_qual,5)
  orders->qual[d1.seq].stat_ind = 0
 
head od.oe_field_id
 
  act_seq = od.action_sequence
  odflag = 1
  case (od.oe_field_meaning)
    of "COLLPRI": orders->qual[d1.seq].priority = od.oe_field_display_value
    of "PRIORITY": orders->qual[d1.seq].priority = od.oe_field_display_value
    of "REQSTARTDTTM": orders->qual[d1.seq].req_st_dt = od.oe_field_display_value
    of "FREQ": orders->qual[d1.seq].frequency = od.oe_field_display_value
    of "RATE": orders->qual[d1.seq].rate = od.oe_field_display_value
    of "DURATION": orders->qual[d1.seq].duration = od.oe_field_display_value
    of "DURATIONUNIT": orders->qual[d1.seq].duration_unit = od.oe_field_display_value
    of "NURSECOLLECT": orders->qual[d1.seq].nurse_collect = od.oe_field_display_value
  endcase
 
head od.action_sequence
  if (act_seq != od.action_sequence)
    odflag = 0
  endif
 
detail
  if (odflag = 1)
    orders->qual[d1.seq].d_cnt=orders->qual[d1.seq].d_cnt+1
    dc = orders->qual[d1.seq].d_cnt
    if (dc > size(orders->qual[d1.seq].d_qual,5))
      stat = alterlist(orders->qual[d1.seq].d_qual,dc + 5)
    endif
 ;021
    if (trim(oef.label_text)="ICD9 Code")
     orders->qual[d1.seq].d_qual[dc].label_text = "Diagnosis Code"
    else
 ;021
     orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text)
    endif
 
 
    orders->qual[d1.seq].d_qual[dc].field_value = od.oe_field_value
    orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq
    orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id
    if (orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = 20)
 
        /* Printing both numerical value and description of diagnoses
           for example, "G89.11 : Acute pain" */
        orders->qual[d1.seq].d_qual[dc].value = concat(trim(n.source_identifier),
          " : ",trim(od.oe_field_display_value,3))
    else
        orders->qual[d1.seq].d_qual[dc].value = trim(od.oe_field_display_value,3)    ;006
    endif
 
    orders->qual[d1.seq].d_qual[dc].clin_line_ind = oef.clin_line_ind
    orders->qual[d1.seq].d_qual[dc].label = trim(oef.clin_line_label)
    orders->qual[d1.seq].d_qual[dc].suffix = oef.clin_suffix_ind
 
    ind_flag = cnvtupper(trim(orders->qual[d1.seq].d_qual[dc].label_text))
 
    if (ind_flag = "SPECIAL INSTRUCTIONS")
      orders->qual[d1.seq].d_qual[dc].special_ind = 1
    else
      orders->qual[d1.seq].d_qual[dc].special_ind = 0
    endif
 
    if ((ind_flag = "PRIORITY") or (ind_flag = "COLLECTION PRIORITY") or
        (ind_flag = "REPORTING PRIORITY") or (ind_flag = "PHARMACY PRIORITY")
        or (ind_flag = "PHARMACY ORDER PRIORITY"))
      orders->qual[d1.seq].d_qual[dc].priority_ind = 1
    else
      orders->qual[d1.seq].d_qual[dc].priority_ind = 0
    endif
 
    if (size(od.oe_field_display_value,1) > 0)     ;006
      orders->qual[d1.seq].d_qual[dc].print_ind = 0
    else
      orders->qual[d1.seq].d_qual[dc].print_ind = 1
    endif
 
    if ((od.oe_field_meaning_id = 1100
       or od.oe_field_meaning_id = 8
       or od.oe_field_meaning_id = 127
       or od.oe_field_meaning_id = 43)
       and trim(cnvtupper(od.oe_field_display_value),3) = "STAT")     ;006
      orders->qual[d1.seq].stat_ind = 1
    endif
    if (of1.field_type_flag = 7)
        if (od.oe_field_value = 1)
          if (oef.disp_yes_no_flag = 2)
            orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
          endif
        else
          if (oef.disp_yes_no_flag = 1)
            orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
          endif
        endif
      endif
  endif
 
foot od.order_id
  stat = alterlist(orders->qual[d1.seq].d_qual, dc)
 
with nocounter
 
/* Build order details line if it exceeds 255 characters */
 
for (x = 1 to order_cnt)
  if (orders->qual[x].clin_line_ind = 1)
    set started_build_ind = 0
    for (fsub = 1 to 71)
      for (xx = 1 to orders->qual[x].d_cnt)
        if ((orders->qual[x].d_qual[xx].group_seq = fsub or fsub = 71)
             and orders->qual[x].d_qual[xx].print_ind = 0)
          if (orders->qual[x].d_qual[xx].clin_line_ind = 1)
            if (started_build_ind = 0)
              set started_build_ind = 1
              if (orders->qual[x].d_qual[xx].suffix = 0
                  and size(orders->qual[x].d_qual[xx].label,1) > 0)     ;006
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].label)," ",
                    trim(orders->qual[x].d_qual[xx].value))
              elseif (orders->qual[x].d_qual[xx].suffix = 1
                      and size(orders->qual[x].d_qual[xx].label,1) > 0)     ;006
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].value)," ",
                    trim(orders->qual[x].d_qual[xx].label))
              else
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].d_qual[xx].value)," ")
              endif
            else
              if (orders->qual[x].d_qual[xx].suffix = 0
                  and size(orders->qual[x].d_qual[xx].label,1) > 0)     ;006
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].label)," ",
                    trim(orders->qual[x].d_qual[xx].value))
              elseif (orders->qual[x].d_qual[xx].suffix = 1
                      and size(orders->qual[x].d_qual[xx].label,1) > 0)     ;006
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].value)," ",
                    trim(orders->qual[x].d_qual[xx].label))
              else
                set orders->qual[x].display_line =
                  concat(trim(orders->qual[x].display_line),",",
                    trim(orders->qual[x].d_qual[xx].value)," ")
              endif
            endif
          endif
        endif
      endfor
    endfor
  endif
endfor
 
/* Line wrapping for special instructions */
 
for (x = 1 to order_cnt)
  for (y = 1 to orders->qual[x].d_cnt)
    if (orders->qual[x].d_qual[y].special_ind = 1)
      set pt->line_cnt = 0
      set max_length = 60           ;008
      call echo(build2("orders->qual[x].d_qual[y].value=",orders->qual[x].d_qual[y].value))
      call echo(build2("max_length=",max_length))
    
    
      execute dcp_parse_text value(orders->qual[x].d_qual[y].value),value(max_length)
      set stat = alterlist(orders->qual[x].disp_ln_qual, pt->line_cnt)
      set orders->qual[x].disp_ln_cnt = pt->line_cnt
      call echorecord(pt)
      for (z = 1 to pt->line_cnt)
        set orders->qual[x].disp_ln_qual[z].disp_line = pt->lns[z].line
      endfor
    endif
  endfor
endfor
 
 
 
/******************************************************************************
*     GET ACCESSION NUMBER                                                    *
******************************************************************************/
 
select into "nl:"
from accession_order_r aor
 
plan aor
  where expand(num, 1, order_cnt, aor.order_id, orders->qual[num].order_id)
 
head aor.order_id   ;021
x=locateval(num, 1, order_cnt, aor.order_id, orders->qual[num].order_id)    ;021
  orders->qual[x].accession = aor.accession
 
foot aor.order_id
null
 
with nocounter, expand=2
 
 
 
/* Line wrapping for orderable */
 
for (x = 1 to order_cnt)
  if (size(orders->qual[x].mnemonic,1) > 0)     ;006
   set pt->line_cnt = 0
   set max_length = 90
   execute dcp_parse_text value(orders->qual[x].mnemonic),value(max_length)
   set stat = alterlist(orders->qual[x].mnem_ln_qual, pt->line_cnt)
   set orders->qual[x].mnem_ln_cnt = pt->line_cnt
   for (y = 1 to pt->line_cnt)
     set orders->qual[x].mnem_ln_qual[y].mnem_line = pt->lns[y].line
   endfor
  endif
endfor
 
 
/******************************************************************************
*     RETRIEVE ORDER COMMENT AND LINE WRAPPING                                *
******************************************************************************/
 
for (x = 1 to order_cnt)
  if (orders->qual[x].comment_ind = 1)
    select into "nl:"
    from order_comment oc,
         long_text lt
 
    plan oc
      where oc.order_id = orders->qual[x].order_id
        and oc.comment_type_cd = comment_cd
    join lt
      where lt.long_text_id = oc.long_text_id
    order by
        oc.action_sequence desc ;012
 
    head report
      orders->qual[x].comment = lt.long_text
 
    with nocounter
 
    set pt->line_cnt = 0
    set max_length = 90
    execute dcp_parse_text value(orders->qual[x].comment),value(max_length)
    set stat = alterlist(orders->qual[x].com_ln_qual, pt->line_cnt)
    set orders->qual[x].com_ln_cnt = pt->line_cnt
    for (y = 1 to pt->line_cnt)
      set orders->qual[x].com_ln_qual[y].com_line = pt->lns[y].line
      set orders->qual[x].com_ln_qual[y].com_line = replace(orders->qual[x].com_ln_qual[y].com_line,char(9),"    ",0)
    endfor
  endif
endfor
 
;start 024 only find HP for ADT Orders
if (orders->adt_ind = 1)
	;025 select
	select into "nl:"																;025
		 hp.plan_name
		,epr.subs_member_nbr
		,epr.encntr_plan_reltn_id
		;025 ,*
	from
		 encntr_plan_reltn epr
	  	,health_plan hp
	plan epr
		where epr.encntr_id 			= request->order_qual[1].encntr_id
		and   epr.beg_effective_dt_tm 	<= cnvtdatetime(curdate,curtime3)
		and   epr.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
		and   epr.priority_seq			in( 1,2 )										;025
	join hp
		where hp.health_plan_id = epr.health_plan_id
	order by
		 epr.beg_effective_dt_tm desc
		,epr.priority_seq																;025
		,epr.encntr_id
	head report
		cnt = 0
	;025 head epr.encntr_id
	head epr.priority_seq 																;025
		cnt = (cnt + 1)
		stat = alterlist(orders->health_plan,cnt)
		orders->health_plan[cnt].encntr_plan_reltn_id	= epr.encntr_plan_reltn_id
		orders->health_plan[cnt].group_name				= epr.group_name
		orders->health_plan[cnt].group_nbr				= epr.group_nbr
		orders->health_plan[cnt].plan_name				= hp.plan_name
		orders->health_plan[cnt].subs_member_nbr		= epr.subs_member_nbr
		orders->health_plan[cnt].disp_line				= substring(1,47,hp.plan_name)
		orders->health_plan[cnt].seq					= epr.priority_seq
	with nocounter
endif
;end 024
 
/******************************************************************************
*     SEND TO OUTPUT PRINTER                                                  *
******************************************************************************/
 
if (orders->spoolout_ind = 1)
 
execute cpm_create_file_name filename,"dat"	;026
 
select into cpm_cfn_info->file_name_path
 
d1.seq
from (dummyt d1 with seq = 1)
 
plan d1
 
head report
    BC_DIO    = "{LPI/24}{CPI/8}{BCR/250}{FONT/28/7}"
    REG_DIO   = "{LPI/8}{CPI/12}{FONT/8}"
    REG2_DIO  = "{LPI/6}{CPI/12}{COLOR/0}{FONT/0}"
    REG3_DIO  = "{LPI/8}{CPI/12}{FONT/4}"
 
    /* This script allows for a custom hospital image or logo to be inserted
       at the top of each page.  The image must be in PostScript format and
       must have corresponding .FRM and .DCT files.  Insert the name and location
       of the .FRM file here and uncomment the line. */
 
    ;call printimage(user:[path]filename.frm)
 
    vv = 0
    save_vv = 1
    save_ww = 0
 
    next_column = 0
 
head page
    REG_DIO, row+1
    var1 =fillstring(250," ")
    var2 =fillstring(250," ")
 
    /* These two lines also need to be modified and uncommented to add a
       hospital logo. */
 
    ;call print(calcpos(700,50))
    ;call printimage(user:[path]filename.dct)
 
 ;021_head
 
 
 
  "{CPI/9}{POS/0/64}{B}", call CENTER(orders->org_name,1,186), row+1 ;021
  "{CPI/9}{POS/0/80}{B}" call CENTER(orders->org_street_add,1,186), row+1 ;021
  "{CPI/9}{POS/0/96}{B}" call CENTER(orders->org_city_state_zip,1,186), row+1 ;021
  "{CPI/9}{POS/0/112}{B}{CENTER//17}", row+1 ;additional information
 
 
  "{CPI/12}{B}", call print(calcpos(85,140)), "Patient Name: ",
      call print(trim(orders->name,3))
 
  "{CPI/12}{B}", call print(calcpos(380,140)), "MRN: ",
      call print(trim(orders->mrn,3))
 
  "{CPI/12}{B}", call print(calcpos(380,150)), "FIN: ",
      call print(trim(orders->fnbr,3)), row+1
   ;021
  "{CPI/12}{B}", call print(calcpos(380,160)), "CMRN: ",
      call print(trim(orders->cmrn,3)), row+1
 
  "{CPI/14}{POS/85/180}", "Admitting Date: "
  "{CPI/14}{POS/145/180}", call print(trim(orders->admit_dt,3))
  "{CPI/14}{POS/380/180}", "Date of Birth: "
  "{CPI/14}{POS/440/180}", call print(trim(orders->dob,3)), row+1
  "{CPI/14}{POS/85/190}", "Location: "
  "{CPI/14}{POS/145/190}", call print(trim(orders->nurse_unit,3))
  "{CPI/14}{POS/380/190}", "Age: "
  "{CPI/14}{POS/440/190}", call print(trim(orders->age,3)), row+1
  "{CPI/14}{POS/85/200}", "Room: "
  "{CPI/14}{POS/145/200}", call print(trim(orders->location,3))
  "{CPI/14}{POS/380/200}", "Sex: "
  "{CPI/14}{POS/440/200}", call print(trim(orders->sex,3)), row+1
  "{CPI/14}{POS/85/210}", "LOS: "
  "{CPI/14}{POS/145/210}", call print(trim(cnvtstring(orders->los),3)), " Days"
  "{CPI/14}{POS/380/210}", "Attending MD: "
  if (orders->attending_cnt = 1 AND attending_line_cnt = 1)                                     /*13 starts here*/
    "{CPI/14}{POS/440/210}", call print(orders->attending[1].attending_phy),row+1
  elseif (orders->attending_cnt = 1 AND attending_line_cnt > 1 AND attending_wrap = 1)
    "{CPI/14}{POS/440/210}", call print(orders->attending[1].attending_phy),row+1
    "{CPI/14}{POS/440/220}", call print(orders->attending[2].attending_phy),row+1
  elseif (orders->attending_cnt > 1 AND attending_wrap = 0)
    "{CPI/14}{POS/440/210}", call print(orders->attending[1].attending_phy),row+1
    "{CPI/14}{POS/440/220}", "More Attending MDs Exist",row+1
  endif                                                                                         /*13 ends here*/
   "{CPI/14}{POS/85/230}", "Allergies: "
  if (allergy->line_cnt > 0)
    "{CPI/14}{POS/125/230}{B}", allergy->line_qual[1].line, row+1
  endif
  if (allergy->line_cnt > 1)
    "{CPI/14}{POS/125/240}{B}", allergy->line_qual[2].line
  endif
  if (allergy->line_cnt > 2)
    "{CPI/14}", "{B}", " ..." ,row+1
    "{CPI/14}{POS/125/250}{B}", "(see patient chart for more information)", row+1
  endif
 
  if ((orders->adt_ind = 1) and (size(orders->health_plan,5) > 0))								;024
	if (size(orders->health_plan,5) = 1)														;025
  		"{CPI/14}{POS/380/230}", "Primary Ins: "												;025
  		"{CPI/14}{POS/440/230}", call print(trim(orders->health_plan[1].disp_line,3)), row+1	;024
  	elseif (size(orders->health_plan,5) > 1)													;025
  		"{CPI/14}{POS/380/230}", "Primary Ins: "												;025
  		"{CPI/14}{POS/440/230}", call print(trim(orders->health_plan[1].disp_line,3)), row+1	;025
  		"{CPI/14}{POS/380/240}", "Secondary Ins: "												;025
  		"{CPI/14}{POS/440/240}", call print(trim(orders->health_plan[2].disp_line,3)), row+1	;025
  	endif																						;025
  endif
  row+1
   ycol = 260
 
 ;021_head
detail
  /* The following lines allow for customized hospital information
     to be entered.  Replace the default text with location-specific
     information (NOTE: May need to be re-centered, do so by adjusting
     the numeric value following the text). */
 
 
 
  for (VV = 1 to VALUE(ord_cnt))
 
  if (orders->qual[vv]->display_ind = 1)
    ycol_test = ycol + (10*(value(orders->qual[vv].d_cnt))/2)
        + (10*(value(orders->qual[vv].com_ln_cnt))) + 52
 
    if (ycol_test > 720)
      ycol = 64
      break
    endif
 
    "{CPI/8}{B}", call print(calcpos(63,ycol)),
        call print("___________________________________________________________"), row+1
 
    ycol = ycol + 12
    "{CPI/11}{B}", call print(calcpos(85,ycol)), "Order: "
    if (size(orders->qual[vv].mnemonic) > 70)
      call print(concat(substring(1,70,orders->qual[vv].mnemonic),"...")), row+1
    else
      call print(orders->qual[vv].mnemonic), row+1
    endif
    ycol=ycol+10
    "{CPI/14}{b}", call print(calcpos(440,ycol)), "Order Action: ",
        call print(uar_get_code_display(orders->qual[vv].action_type_cd)), row+1
 
;021
       ;NPI FOR ORDER PROVIDER
    Var1= build2(orders->qual[vv].order_dr,"  NPI #:",orders->qual[vv].ord_npi)
 
    "{CPI/14}", call print(calcpos(85,ycol)), "Ordering Provider: ",
       call print(var1),row+1
       ycol = ycol + 10
;021
 
	;SUPERVISING PROVIDER  													;022
	if((orders->qual[vv].sup_signby != null) and (orders->adt_ind = 1))		;022
 																			;022
	    "{CPI/14}", call print(calcpos(85,ycol)), "Supervising Provider: ",	;022
	        call print(orders->qual[vv].sup_signby);, row+1					;022
	endif																	;022
 
	   "{CPI/14}", call print(calcpos(440,ycol)), "Order ID: ",
	        call print(trim(cnvtstring(orders->qual[vv].order_id),3)), row+1
	        ycol = ycol + 10
;021
 
    ;SIGNATURE OF THE PROVIDER
 
    if(orders->qual[vv].elec_signby != null)
        ycol = ycol + 10
        "{CPI/14}", call print(calcpos(85,ycol)), "Electronically Signed By: ",
          call print(trim(orders->qual[vv].elec_signby,3)),  row+1
    endif
 
    ;ENTER BY PROVIDER  ;021
 
    ycol = ycol + 10
    "{CPI/14}", call print(calcpos(85,ycol)), "Entered By: ",
        call print(orders->qual[vv].enter_by);, row+1
 
 
    ;CHANGED THE POSITION OF COMMUNICATION TYPE     ;021
 
    ycol = ycol + 10
    "{CPI/14}", call print(calcpos(85,ycol)), "Communication Type: ",
        call print(orders->qual[vv].communication_type)
 
    ; DIAGNOSIS & ICD_10 CODE FOR ACUTE         ;021
 
        if(orders->qual[vv].diag_code!=null)
            ycol = ycol + 10
            "{CPI/14}", call print(calcpos(85,ycol)), "Diagnosis Code: ",
                call print(orders->qual[vv].diag_code)
         endif
 
    ;ADDED ORDER DATE/TIME              ;021
 
    "{CPI/14}", call print(calcpos(440,ycol+18)), "Order Dt/Tm: ",
        call print(orders->qual[vv].order_dt), row+1
 
    ;Adding discharge da/tm for acute orders                ;021
 
    If (Amb_ind=1)
        if(orders->disch_dt_tm!=null)
            "{CPI/14}", call print(calcpos(440,ycol+28)), "Discharge Dt/Tm: ",
                call print(orders->disch_dt_tm), row+1
        endif
    endif
 
;021
 
    save_ww = -1
    next_column = 0
    xcol = 85
    ycol = ycol + 15
 
    for (fsub = 1 to 71)
 
      for (ww = 1 to orders->qual[vv]->d_cnt)
 
        if (((orders->qual[vv].d_qual[ww]->group_seq = fsub)
           or (fsub = 71 and orders->qual[vv]->d_qual[ww]->print_ind = 0))
           and (size(orders->qual[vv]->d_qual[ww]->value,1) > 0))
                ;006
          orders->qual[vv]->d_qual[ww]->print_ind = 1
 
          if (orders->qual[vv]->d_qual[ww]->special_ind = 1)
            save_ww = ww
           else
 
            if (xcol = 85)
 
              if (size(orders->qual[vv]->d_qual[ww]->label_text) > 28)
                "{CPI/15}"
              else
                "{CPI/14}"
              endif
 
              call print(calcpos(xcol,ycol)),
 
              if(textlen(orders->qual[vv]->d_qual[ww]->label_text)>37)
 
                    if ((size(orders->qual[vv]->d_qual[ww]->label_text)
                         + size(orders->qual[vv]->d_qual[ww]->value)) > 0)      ;021
                         call print(orders->qual[vv]->d_qual[ww]->label_text),": ",
                         orders->qual[vv]->d_qual[ww]->value
                    endif
               else
 
                  call print(trim(orders->qual[vv]->d_qual[ww]->label_text,3)), ": ",
                  call print(calcpos(250,ycol))
 
                  if (orders->qual[vv]->d_qual[ww]->priority_ind = 1)
                    "{B}"
                  endif
 
                  if (size(orders->qual[vv]->d_qual[ww]->value) > 0)    ;021
                    "{CPI/14}", call print(trim(orders->qual[vv]->d_qual[ww]->value,3)), row+1
                  endif
 
               endif
 
                    "{ENDB}"
 
            elseif (xcol = 325)
 
 
            xcol=85     ;021
            ycol=ycol+10    ;021
              if (size(orders->qual[vv]->d_qual[ww]->label_text) > 28)
                "{CPI/15}"
              else
                "{CPI/14}"
              endif
 
              call print(calcpos(xcol,ycol)),
              if(textlen(orders->qual[vv]->d_qual[ww]->label_text)>37)
                    if ((size(orders->qual[vv]->d_qual[ww]->label_text)
                         + size(orders->qual[vv]->d_qual[ww]->value)) > 0) ;021
                         call print(orders->qual[vv]->d_qual[ww]->label_text),": ",
                         orders->qual[vv]->d_qual[ww]->value
                    endif
               else
                  call print(trim(orders->qual[vv]->d_qual[ww]->label_text,3)), ": ",
                  call print(calcpos(250,ycol))
 
                  if (orders->qual[vv]->d_qual[ww]->priority_ind = 1)
                    "{B}"
                  endif
                  if (size(orders->qual[vv]->d_qual[ww]->value) > 0)    ;021
                    "{CPI/14}", call print(trim(orders->qual[vv]->d_qual[ww]->value,3)), row+1
                  endif
               endif
              "{ENDB}"
            endif
          endif
 
          if ((xcol > 319) and (orders->qual[vv]->d_qual[ww]->special_ind =0 ))
 
            xcol = 85
            ycol = ycol + 10
          elseif (orders->qual[vv]->d_qual[ww]->special_ind = 0 )
            xcol = 325
          endif
 
        endif
      endfor
    endfor
 
    if (save_ww >= 0)
      xcol = 85
      ycol=ycol+10
      "{CPI/14}", call print(calcpos(xcol,ycol)),
          call print(trim(orders->qual[vv]->d_qual[save_ww]->label_text,3)), ": "
 
      for (zz = 1 to orders->qual[vv].disp_ln_cnt)
        "{CPI/14}", call print(calcpos(250,ycol)),
            call print(orders->qual[vv].disp_ln_qual[zz].disp_line), row+1
                ycol = ycol + 10
            if (ycol > 720 and zz < orders->qual[vv].disp_ln_cnt)
                call print (calcpos(220,ycol)),"**Continued on next page**"
                saved_pos = vv
                break
                xcol=85
                ycol=64
                "{CPI/14}",call print(calcpos(xcol,ycol)),
                call print(concat(orders->qual[vv]->d_qual[save_ww]->label_text, " cont. "))
            endif
      endfor
    endif
 
 
    ycol = ycol + 15
    "{CPI/13}{B}", call print(calcpos(85,ycol)), "Comments: ", "{ENDB}"
    for (zz = 1 to orders->qual[vv].com_ln_cnt)
 
      if(ycol<720)
 
      ycol = ycol + 10
      else
         ycol = 64
 
      break
      endif
      "{CPI/13}", call print(calcpos(140,ycol)),
      call print(orders->qual[vv].com_ln_qual[zz].com_line), row+1
      if (zz = 41)  ;021
        "{CPI/13}", call print(calcpos(140,ycol)),
            "(see patient chart for more information)", row+1
        zz = orders->qual[vv].com_ln_cnt
      endif
    endfor
    ycol = ycol + 10
 
 
    save_vv = vv + 1
  endif
  endfor
 
with nocounter, maxrow=800, maxcol=750, dio=postscript
 
set spool = value(trim(cpm_cfn_info->file_name_path)) value(trim(request->printer_name)) with deleted
 
endif
 
call echorecord(orders)
 
#exit_script
set last_mod = "021 14/06/18 SR051119   changes mod and declared some variable"
end
go

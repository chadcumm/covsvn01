;     ************************************************************************
;     * ProFile Deficiency Reporting by Physician PROGRAM                    *
;~BB~ ************************************************************************
;     *                                                                      *
;     *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
;     *                              Technology, Inc.                        *
;     *       Revision      (c) 1984-1995 Cerner Corporation                 *
;     *                                                                      *
;     *                                                                      *
;     *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
;     *  This material contains the valuable properties and trade secrets of *
;     *  Cerner Corporation of Kansas City, Missouri, United States of       *
;     *  America (Cerner), embodying substantial creative efforts and        *
;     *  confidential information, ideas and expressions, no part of which   *
;     *  may be reproduced or transmitted in any form or by any means, or    *
;     *  retained in any storage or retrieval system without the expressed   *
;     *  written permission of Cerner.                                       *
;     *                                                                      *
;     *  Cerner is a registered mark of Cerner Corporation.                  *
;     *                                                                      *
;~BE~ ************************************************************************
/*****************************************************************************
 
        Source file name:       him_mak_defic_by_phys_driver
        Object name:            him_mak_defic_by_phys_driver.prg
        Request #:              N/A
 
        Product:                ProFile
        Product Team:           ProFile
        HNA Version:            500
        CCL Version:            8.2
 
        Program purpose:
 
        Tables read:            Prompts
 
        Tables updated:         None
 
        Executing from:         reports
 
        Special Notes:
 
;**************************************************************************************
;* Feature   Date      Engineer       Comment                                         *
;* ------- --------    -------------- ----------------------------------------------- *
;*   59927 04/27/04    SM8093         Initial Release
;*    001  04/02/19	   CCUMMIN4		  Updated for Covenant specific fields
;**************************************************************************************/
 
 
free record organizations
record organizations
(
 1 qual[*]
   2 item_id = f8
   2 item_name = vc
)
 
free record physicians
record physicians
(
	1 qual[*]
	  2 item_id = f8
	  2 item_name = vc
)
 
free record data
record data
(
 1 qual[*]
   2 patient_name = vc
   2 patient_id  = f8
   2 patient_type_cd  = f8
   2 organization_name = vc
   2 organization_id  = f8
   2 mrn  = vc
   2 fin  = vc
   2 physician_name = vc
   2 physician_id = f8
   2 encntr_id = f8
   2 chart_alloc_dt_tm = dq8
   2 chart_age = i4
   2 disch_dt_tm = dq8
   2 location = vc
%i cclsource:him_prmpt_patient.inc
%i cclsource:him_prmpt_physician.inc
   2 physician_star_id = vc					; 001
%i cclsource:him_prmpt_encntr.inc
%i cclsource:him_prmpt_encntr_mrn.inc
%i cclsource:him_prmpt_encntr_fin.inc
%i cclsource:him_prmpt_chart_process.inc
%i cclsource:him_prmpt_org.inc
   2 defic_qual[*]
      3 deficiency_name = vc
      3 status = vc
      3 alloc_dt_tm = dq8
      3 defic_age = i4
      3 event_id = f8 ;only applies to documents
      3 order_id = f8 ;only applies to orders
      3 action_sequence = i4 ;only applies to orders
      ;3 encntr_id = f8
      ;3 physician_id = f8
      3 deficiency_flag = i2
;If the deficiency flag = 1, the doc_qual will be = 1 and populated and the order_qual empty
;if the deficiency flag = 2, the order_qual will by = 1 and populated and the doc_qual empty
	  3 otg_id = i2							;001
      3 scanning_prsnl = vc					;001
      3 scanning_prsnl_id = f8				;001
      3 age_days = i4						;001
      3 order_communication_type_cd = f8	;001
      3 order_communication_type = vc		;001
      3 order_action_prsnl_id = f8			;001
      3 order_action_prsnl_name = vc		;001
      3 order_action_prsnl_position_cd = f8 ;001
      3 order_action_prsnl_position = vc	;001
      3 order_refuse_provider_id = f8		;001
      3 order_refuse_provider_name = vc		;001
      3 order_refuse_reason = vc			;001
      3 doc_qual[*]
%i cclsource:him_prmpt_him_event_allocation4.inc
      3 order_qual[*]
%i cust_script:cov_him_prmpt_orders4.inc
%i cclsource:him_prmpt_order_review4.inc
%i cclsource:him_prmpt_order_notification4.inc
 1 max_defic_qual_count = i4
)
 
 
if(i1MultiFacilityLogicInd)
	/*Extract selected organizations.*/
	call GetDataFromPrompt(2, organizations)
	call HIMGetNamesFromTable(organizations, "organization", "org_name", "organization_id")
endif
 
/*Extract physicians and get their names by identification number.*/
call GetDataFromPrompt(3, physicians)
call HIMGetNamesFromTable(physicians, "prsnl", "name_full_formatted", "person_id")
 
execute him_mak_defic_by_phys_driver
 
/*If there is no data to display in the layout then render a blank report.*/
/*This keeps the head group sections from rendering in a layout which selects*/
/*from the dummyt table.*/
if(HIMRenderNoDataReport(size(data->qual, 5), $OUTDEV))
   return
endif
 
 
 

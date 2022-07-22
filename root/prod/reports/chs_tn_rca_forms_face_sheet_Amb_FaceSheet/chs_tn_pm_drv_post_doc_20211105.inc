 
/****************************************************************************
 *                                                                          *
 *  Copyright Noties:  (c) 1983 Laboratory Information Systems &            *
 *                              Technology, Inc.                            *
 *       Revision      (c) 1984-1997 Cerner Corporation                     *
 *                                                                          *
 *  Cerner (R) Proprietary Rights Noties:  All rights reserved.             *
 *  This material contains the valuable properties and trade secrets of     *
 *  Cerner Corporation of Kansas City, Missouri, United States of           *
 *  America (Cerner), embodying substantial creative efforts and            *
 *  confidential information, ideas and expressions, no part of which       *
 *  may be reproduesd or transmitted in any form or by any means, or        *
 *  retained in any storage or retrieval system without the express         *
 *  written permission of Cerner.                                           *
 *                                                                          *
 *  Cerner is a registered mark of Cerner Corporation.                      *
 *                                                                          *
 *                                                                          *
 ****************************************************************************
 
          Date Written:       06/02/2005
          Soures file name:   PM_DRV_POST_DOC
          Object name:        PM_DRV_POST_DOC
          Request #:
 
          Product:            PERSON MANAGEMENT
          Product Team:       PERSON MANAGEMENT
          HNA Version:        V500
          CCL Version:
 
          Program purpose:    Driver script for post documents
 
          Tables read:        pm_post_doc_ref
          Tables updated:
          Executing from:
 
          Special Notes:
 
 ***********************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                 *
 ***********************************************************************
 *                                                                     *
 *Feature  Date     Engineer             Comment                       *
 *-------  -------- -------------------- ------------------------------*
  59888    06/02/05 Chad Pugh            Initial Release
  70552    09/09/05 Chad Pugh            1-464576211 - Post Doc Script error
  75747    12/08/05 Chad Pugh            CR 1-547077331 - SCH not displayed correctly
  75998    12/14/05 Chad Pugh 			  CR 1-550322222 - Demog_reltn items
 95020a    04/19/06 Chad Pugh            CR 1-670593321 - Added ApptFacilityPhone logic
 95020b    04/19/06 Chad Pugh            CR 1-651060061 - Correspondence address
 157201    01/10/08 Chad Pugh            CR 1-1357892700 - EncntrType = vc is defined twice
 168622    04/22/08 Gayle Siegfried      CR 1-1924298153 - Brief Discharge Summary
 170348    05/08/08 Regan Ellertson      CR 1-1963808221 - Discharge Summary
 174138    07/24/08 Regan Ellertson      CR 1-1911369911 - Correspondence Tags Additions
 204768    04/15/09 Chad Pugh            CR 1-2494420558 - Forms in RCA
 ***********************************************************************
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
 
 
 
   ;+204768
   set bDrvStructCreated = FALSE
 
   if (validate(post_doc_rec->struct_created, -9) != -9)
      if (post_doc_rec->struct_created = TRUE)
         set bDrvStructCreated = TRUE
      endif  ;if (post_doc_rec->struct_created = TRUE)
   endif  ;if (validate(post_doc_rec->struct_created, -9) != -9)
 
   if (bDrvStructCreated != TRUE)
%i ccluserdir:chs_tn_pm_drv_post_doc_struct.inc
   endif
 
;168622++
/*
  set post_doc_rec->person_id = cnvtreal(trim($dPERSON_ID, 3))
  set post_doc_rec->encntr_id = cnvtreal(trim($dENCNTR_ID, 3))
  set post_doc_rec->sch_event_id = cnvtreal(trim($dSCH_EVENT_ID, 3))
  set post_doc_rec->schedule_id = cnvtreal(trim($dSCHEDULE_ID, 3))
*/
  if (validate(temp_post_doc_rec_input->person_id,-999) != -999)
     if (temp_post_doc_rec_input->person_id < 0)
        set post_doc_rec->person_id = cnvtreal(trim($dPERSON_ID, 3))
     else
        set post_doc_rec->person_id = temp_post_doc_rec_input->person_id
     endif
  else
     set post_doc_rec->person_id = cnvtreal(trim($dPERSON_ID, 3))
  endif
  if (validate(temp_post_doc_rec_input->encntr_id ,-999) != -999)
     if (temp_post_doc_rec_input->encntr_id  < 0)
        set post_doc_rec->encntr_id = cnvtreal(trim($dENCNTR_ID, 3))
     else
        set post_doc_rec->encntr_id = temp_post_doc_rec_input->encntr_id
     endif
  else
     set post_doc_rec->encntr_id = cnvtreal(trim($dENCNTR_ID, 3))
  endif
  if (validate(temp_post_doc_rec_input->sch_event_id ,-999) != -999)
     if (temp_post_doc_rec_input->sch_event_id < 0)
        set post_doc_rec->sch_event_id = cnvtreal(trim($dSCH_EVENT_ID, 3))
     else
        set post_doc_rec->sch_event_id = temp_post_doc_rec_input->sch_event_id
     endif
  else
     set post_doc_rec->sch_event_id = cnvtreal(trim($dSCH_EVENT_ID, 3))
  endif
  if (validate(temp_post_doc_rec_input->schedule_id ,-999) != -999)
     if (temp_post_doc_rec_input->schedule_id < 0)
        set post_doc_rec->schedule_id = cnvtreal(trim($dSCHEDULE_ID, 3))
     else
        set post_doc_rec->schedule_id = temp_post_doc_rec_input->schedule_id
     endif
  else
     set post_doc_rec->schedule_id = cnvtreal(trim($dSCHEDULE_ID, 3))
  endif
;168622--
 
 


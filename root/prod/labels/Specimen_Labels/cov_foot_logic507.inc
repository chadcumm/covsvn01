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
      *  retained in any storage or retrieval system without the expressed   *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~************************************************************************
 
/*****************************************************************************
 
        Author                  David Compton
        Date Written:           10/15/97
        Source file name:       FOOT_LOGIC507.INC
        Object name:
        Request #:              265084
 
        Product:                Specimen Collections
        Product Team:           Pathnet
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Adds logic for variable declarations in
                                barcode label programs.
 
        Tables read:
 
        Tables updated:         None
        Executing from:         scs**_cl****.prg
 
        Special Notes:          None
 
*****************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     001 10/15/97 David Compton        FOOT_LOGIC507.INC sets logic needed *
;                                       to print work-site specific         *
;                                       specimen labels for all bar code    *
;                                       formats.                            *
;     002 01/10/00 Todd Anderson        Fix for Collection Class Options    *
;     003 02/05/2018 Dawn Greer, DBA    Renamed to                          *
;                                       cust_script:cov_foot_logic507.inc   *
;     004 02/14/2018 Dawn Greer, DBA    Added label text to spec_ins field  *
;~DE~************************************************************************
 
   cntnr_disp = substring(1, 8, request->container_qual[tube]->spec_cntnr_disp),
 
   dr_name = concat("DR. ", substring(1, 20,
                      request->container_qual[tube]->order_qual[1].provider_name)),
 
   format_vol = concat(trim(format(request->container_qual[tube]->volume, "####.##;l")),
                          request->container_qual[tube]->volume_units),
   bc_symbology = request->container_qual[tube]->symbology,
 
   bc_accn = request->container_qual[tube].barcode_acc_container,
   bc_pour_accn = request->container_qual[tube].barcode_acc_container,
   bc_accn_size = 7,
   bc_pour_size = 7,
   smg_format = cnvtint(request->container_qual[tube]->smg_format),
   smg_adjust = request->container_qual[tube]->smg_barcode_adjust,
   ins_print_id = request->container_qual[tube]->container_id_print,
 
   /***************************************************************/
   /* Added to correct for Collection class option N, Y, and B.   */
   /* TA3668 01/10/00  Should be fixed in the latest Q_BC_GEN.INC */
   /* Uncomment out the below IF/ENDIF information if needed.     */
   /***************************************************************/
 
;   if (ins_print_id = "B")
;    ins_print_id = "Y"
;   endif
 
   ;---2/14/2018 - DG - 004 Added Text Label to the spec_ins field
   spec_ins = concat("Spec Ins: ",substring(1, 16, request->container_qual[tube]->spec_hndl_disp)),
 
   workc = substring(1, 12, request->container_qual[tube]->coll_class_disp),
 
   if (smg_format != 2)
      smg_format = 1
   endif,
 
   if ((smg_adjust < 0) or (smg_adjust > 300))
      smg_adjust = 0
   endif,
 
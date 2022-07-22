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
      ***********************************************************************/
 
/*****************************************************************************
 
        Author                  David Compton
        Date Written:           10/15/97
        Source file name:       SPECIMEN_ZB_VAC507.INC
        Object name:
        Request #:              265084
 
        Product:                Specimen Collections
        Product Team:           Pathnet
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:
 
        Tables read:
 
        Tables updated:
        Executing from:         scszb_cl****.prg
 
        Special Notes:          none
 
******************************************************************************/
 
 
;~DB~***************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                 *
;    ***************************************************************************
;    *                                                                         *
;    *Mod Date     Engineer             Comment                                *
;    *--- -------- -------------------- ---------------------------------------*
;     001 10/15/97 David Compton        SPECIMEN_ZB_VAC507.INC prints the      *
;                                       fields in the specimen part of the     *
;                                       label format for Zebra printers,       *
;                                       using a 2" specimen label, allowing    *
;                                       up to a 9 digit barcoded accession.    *
;     002 04/13/98 David Compton        Corrected ins_print_id functionality   *
;     003 02/05/2018 Dawn Greer, DBA    Renamed to                             *
;                                       cust_script:cov_specimen_zb_vac507.inc *
;     004 02/14/2018 Dawn Greer, DBA    Added two fields, changed one field    *
;                                       and adjusted alignment                 *
;     005 07/31/2018 Dawn Greer, DBA    Changed to print the Finnbr instead of *
;                                       of the mednbr                          *
;     006 09/19/2018 Dawn Greer, DBA    Moved DOB to print after the Finnbr    *
;     007 09/20/2018 Dawn Greer, DBA    Adjusted positions of DOB and Date/Time*
;     008 09/24/2018 Dawn Greer, DBA    Adjusted position of the Room/Bed field*
;~DE~***************************************************************************
 
   if (smg_print_id_flag = 'Y')
      /***********************************************************/
      /*  The convention for printing accession numbers in 304+  */
      /*  environments on Cerner standard labels is to print a   */
      /*  blank between the accession number and the container   */
      /*  id if the container id is not included in the          */
      /*  instrument specific barcoded field.                    */
      /***********************************************************/
/*
** 002...      if (ins_print_id = 'Y')
*/
      if (ins_print_id = 'B')                                                                /* 002... */
         accession = concat(trim(request->formatted_accession), cntnr->qual[tube]->id)
      elseif(ins_print_id = 'Y')
         accession = concat(trim(request->formatted_accession), ' ',
                            cntnr->qual[tube]->id)
      else
         accession = request->formatted_accession
      endif /* (ins_print_id = 'Y') */
   else
      accession = request->formatted_accession
   endif, /* (smg_print_id_flag = 'Y') */
 
   /*****************************/
   /* Set barcode position here */
   /*****************************/
   bc_x_pos = 20 + smg_adjust,                ;---2/14/2018 - DG - 004 Changed from 5 to 20 to move the barcode over slightly
   bc_y_pos = 22,
 
   call print(calcpos(5 + label_x_pos, 0 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
   ;"{lpi/8}{cpi/17}{font/2}", request->mednbr,
   "{lpi/8}{cpi/17}{font/2}", bc_med_nbr,
   			;---7/31/2018-DG-005-changed to finnbr from mednbr
   			;---9/20/2018-DG-007 changed to bc_med_nbr variable instead of request->finnbr
 
   ;---9/19/2018 - 006 - Moved DOB to be beside the finnbr
   call print(calcpos(52 + label_x_pos, 0 + label_y_pos)),  ;---9/20/2018 - DG - 007 - Changed from 30 to 36
   "{lpi/8}{cpi/17}{font/2}", dob,
 
   call print(calcpos(5 + label_x_pos, 7 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
   "{lpi/8}{cpi/30}{font/1}", request->name_full_formatted,
 
   row+1,
 
   if (request->disch_dt_tm > 0 and request->disch_dt_tm <= cnvtdatetime(curdate, curtime3))
       call print(calcpos(5 + label_x_pos, 16 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
       "{lpi/8}{cpi/17}{font/2}", "DSCH"
   else
 
       call print(calcpos(5 + label_x_pos, 16 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
       "{lpi/8}{cpi/17}{font/2}", request->nurse_unit_disp,
 
       call print(calcpos(91 + label_x_pos, 16 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 35 to 40 for the label_x_pos
       				;---9/24/2018 - DG - 008 Changed from 40 to 91 for the label_x_pos
       room_bed
   endif
 
;   006 - Moving to after the finnbr
;   call print(calcpos(68 + label_x_pos, 16 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 65 to 68 for the label_x_pos
;    ;age_sex,    ;---2/14/2018 - DG - 004 Changed to DOB and added font settings
;    "{lpi/8}{cpi/17}{font/2}", dob,
 
   call print(calcpos(91 + label_x_pos, 9 + label_y_pos)),   ;---9/20/2018 - DG - 007 Moved over to the right from 88 to 91
   "{lpi/12}{cpi/23}{font/1}",
   date_time,
 
   row+1,
 
   call print(calcpos(101 + label_x_pos, 0 + label_y_pos)),
   "{lpi/4}{cpi/11}{font/4}", cntnr->qual[tube]->pri,
 
   row+1,
 
   /***********************************************/
   /* Print the instrument specific barcode here. */
   /***********************************************/
   call print(calcpos(bc_x_pos + label_x_pos, bc_y_pos + label_y_pos)),
   call print(trim(smg_bc_dio)),
   call print(trim(smg_bc)),
 
   row+1,
 
   call print(calcpos(5 + label_x_pos, 54 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
   "{lpi/6}{cpi/15}{font/4}", accession,
 
   row+1,
 
/***
**
=>    Print tests across specimen label.
**
***/
 
   yoffset = 5,
   x_offset = 35,
   test_x  = 5,   ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
   test_y  = 65,
   max_limit = 8,
   limit = max_limit / 2,
   test_cnt = 1,
   "{lpi/12}{cpi/23}{font/1}",
 
   while ((test_cnt <= limit) and (test_cnt <= cntnr->qual[tube]->test_cnt))
      call print(calcpos(test_x + label_x_pos, test_y + label_y_pos)),
      test_trunc = substring(1, 10,
           request->container_qual[tube]->order_qual[test_cnt]->order_mnemonic),
 
      if ((test_cnt = limit) and (cntnr->qual[tube]->test_cnt > max_limit))
         call print(build(substring(1, 8, test_trunc), " C"))
      else
         test_trunc
      endif, /* ((test_cnt = limit) and ... */
 
      test_x = test_x + x_offset,
      row+1,
      if ((test_cnt = limit) and (limit != max_limit))
         limit = max_limit,
         test_y = test_y + yoffset,
         test_x = 0
      endif, /* ((test_cnt = limit) and (limit != max_limit)) */
      test_cnt = test_cnt + 1
   endwhile, /* ((test_cnt <= limit) and ... */
 
   ;---2/14/2018 - DG - 004 Added Special Handling Comment to the label
   call print(calcpos(5 + label_x_pos, 69 + label_y_pos)),
   "{lpi/8}{cpi/17}{font/2}", spec_ins,
 
   ;---2/14/2018 - DG - 004 Added Label Comment to the label
   call print(calcpos(5 + label_x_pos, 74 + label_y_pos)),
   "{lpi/8}{cpi/17}{font/2}", comment,
 
   row+1,
 
   call print(calcpos(5 + label_x_pos, 80 + label_y_pos)),  ;---2/14/2018 - DG - 004 Changed from 0 to 5 for the label_x_pos
   "{lpi/8}{cpi/17}{font/2}", format_vol";LP ",
 
   call print(calcpos(35 + label_x_pos, 80 + label_y_pos)), ;---2/14/2018 - DG - 004 Changed from 30 to 35 for the label_x_pos
   "{lpi/8}{cpi/17}{font/2}", cntnr_disp,
 
   row+1,
 
   collection_class = build(substring(1, 12, request->container_qual[tube]->coll_class_disp)),
 
   call print(calcpos(88 + label_x_pos, 80 + label_y_pos)),
   "{lpi/8}{cpi/17}{font/2}", collection_class,
 
   row+1,
 


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
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Author                  David Compton
        Date Written:           10/15/97
        Source file name:       ALIQUOT_ZB_VAC507.INC
        Object name:
        Request #:              265084
 
        Product:                Specimen Collections
        Product Team:           Pathnet
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Aliquot label generator for Zebra printers
                                using formats with a 2" wide specimen label.
 
        Tables read:
 
        Tables updated:         None
        Executing from:         scszb_cl****.prg
 
        Special Notes:          None
 
*****************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     001 10/15/97 David Compton        ALIQUOT_ZB_VAC507.INC prints the    *
;                                       fields in the aliquot label for the *
;                                       2" specimen label on Zebra printers.*
;     002 02/05/2018 Dawn Greer, DBA    Renamed to                          *
;                                       cust_script:cov_aliquot_zb_vac507.inc*
;     003 02/14/2018 Dawn Greer, DBA    Changing x/y locations              *
;~DE~************************************************************************
 
   all_stop = cntnr->qual[tube]->test_cnt,
 
      if (ins_print_id = 'B')
         accession = concat(trim(request->formatted_accession), cntnr->qual[tube]->id)
      elseif(ins_print_id = 'Y')
         accession = concat(trim(request->formatted_accession), ' ',
                            cntnr->qual[tube]->id)
      else
         accession = request->formatted_accession
      endif /* (ins_print_id = 'B') */
 
   row+1,
 
   call print(calcpos(3 + label_x_pos, 0 + label_y_pos)),  ;---2/14/2018 - DG - 003 Changed from 0 to 3 for the label_x_pos
   "{lpi/8}{cpi/17}{font/2}", cntnr->qual[tube]->reppri
   row+1,
 
   call print(calcpos(3 + label_x_pos, 5 + label_y_pos)),  ;---2/14/2018 - DG - 003 Changed from 11 to 3 for the label_x_pos
   "{lpi/8}{cpi/17}{font/2}", accession,                   ;---2/14/2018 - DG - 003 Changed from 3 to 5 for the label_y_pos
 
   call print(calcpos(3 + label_x_pos, 11 + label_y_pos)), ;---2/14/2018 - DG - 003 Changed from 0 to 3 for the label_x_pos
   "{lpi/12}{cpi/23}{font/1}", al_name,
 
   call print(calcpos(3 + label_x_pos, 16 + label_y_pos)), ;---2/14/2018 - DG - 003 Added to put the DOB on the label
   dob,
 
   row+1,
 
   call print(calcpos(3 + label_x_pos, 22 + label_y_pos)), ;---2/14/2018 - DG - 003 Changed from 19 to 22 for the label_y_pos
   call print(trim(smg_bc_dio)),
   call print(trim(smg_bc)),
 
   /**************************/
   /* Aliquot printing logic */
   /**************************/
 
   split = tests_per_aliq,
   max = tests_per_aliq * 2,
 
   if (all_stop > max)
      all_stop = max
   elseif ((tests_per_aliq < all_stop) and (all_stop <= max))
      split = ceil(all_stop / 2.0)
   endif, /* (all_stop > max) */
 
   "{lpi/12}{cpi/23}{font/1}",
 
   inc = 0,
   xoffset = 40,
   yoffset = 6,
 
   field_x_pos = xoffset + label_x_pos,
   field_y_pos = 40 + label_y_pos,
 
   while ((inc < split) and (aliq_index + inc <= all_stop))
      if (field_x_pos = xoffset + label_x_pos)
         field_x_pos = 1 + label_x_pos,
         field_y_pos = yoffset + field_y_pos,
         row+1
      else
         field_x_pos = xoffset + label_x_pos
      endif, /* (field_x_pos = xoffset + label_x_pos) */
 
      aliquot_test = substring( 1, 10, request->container_qual[tube]->order_qual[aliq_index + inc]->order_mnemonic),
      call print(calcpos(field_x_pos, field_y_pos)),
      aliquot_test,
 
      inc = inc + 1
 
   endwhile, /* ((inc < split) and (aliq_index+inc <= all_stop)) */
 
   if (all_stop <= tests_per_aliq)
      if (secnd_alq_flg = 'Y')
         if (even(all_pos) = 1)
            printed = 'Y'
         endif
      else
         all_pos = all_pos + 1,
         printed = 'Y'
      endif /* (secnd_alq_flg = 'Y') */
   else
      aliq_index = aliq_index + inc,
      if (aliq_index > all_stop)
         printed = 'Y'
      endif
   endif, /* (all_stop <= tests_per_aliq) */
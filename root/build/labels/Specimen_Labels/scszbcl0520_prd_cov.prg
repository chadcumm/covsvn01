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
 
        Author                  David Compton
        Date Written:           10/15/97
        Source file name:       SCSZB_CL0520.PRG
        Object name:            SCSZBCL0520
        Request #:              265084
 
        Product:                Specimen Collections
        Product Team:           Pathnet
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Barcode label program for CL-0520 on Zebra
 
        Tables read:
 
        Tables updated:         None
        Executing from:         specimen_label.prg
 
        Special Notes:          None
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     001 10/15/97 David Compton        Initial Release                     *
;     002 08/15/03 Todd Anderson        Modified to use q_bc_gen507z.inc    *
;                                       file needed for Code128 symbology.  *
;     003 02/14/2018 Dawn Greer, DBA    Renamed to cust_script:             *
;                                       SCSZBCL0520_prd_cov                 *
;~DE~************************************************************************
 
drop program SCSZBCL0520_prd_cov go
create program SCSZBCL0520_prd_cov
 
   /****************************************************/
   /* Declare additional container demographics array. */
   /****************************************************/
   record cntnr
   ( 1 qual[*]
       2 colpri = C2
       2 colprinum = I4
       2 reppri = C2
       2 repprinum = I4
       2 pri = C5
       2 id = C1
       2 stop = I4
       2 test_cnt = I4
   )
 
set sts = alterlist(cntnr->qual, value(request->container_count))
 
select into value(print_queue)
 
request
 
from (dummyt d1 with seq = 1)
 
%i cust_script:cov_init_logic507.inc
 
   c_x_offset = 0,
   c_y_offset = 0,
 
   label_x_pos = home_x_pos + c_x_offset,
   label_y_pos = home_y_pos + c_y_offset,
 
 
   while (tube <= record_total)
      date_time = format(request->container_qual[tube]->label_dt_tm, "DDMMMYY HHMM;;D"),
 
      if ( print_collect = 'Y' )
         print_collect = 'N',
         label_x_pos = home_x_pos + c_x_offset,
         label_y_pos = home_y_pos + c_y_offset,
;%i cclsource:collect_zb_vac507.inc
         row+1
      endif, /* (tube = 1) */
 
      if (aliq_index = 1)
         /********************/
         /* Tube labels code */
         /********************/
         /************************/
         /* Define the variables */
         /************************/
 
         case (all_pos)
         of 1: label_x_pos = home_x_pos
         of 2: label_x_pos = home_x_pos
         of 3: label_x_pos = home_x_pos + 144
         else  label_x_pos = home_x_pos + 144
         endcase, /* (all_pos) */
 
         label_y_pos = home_y_pos + 0,
%i cust_script:cov_foot_logic507.inc
         accn = 1,
%i cust_script:cov_q_bc_gen507z.inc
%i cust_script:cov_specimen_zb_vac507.inc
 
         row+1
      endif, /* (aliq_index = 1) */
 
       /***********************/
      /* Aliquot labels code */
      /***********************/
 
      printed = 'N',
      while (printed = 'N')
 
        case (all_pos)
        of 1: label_x_pos = home_x_pos
        of 2: label_x_pos = home_x_pos + 71
        of 3: label_x_pos = home_x_pos + 143
        else  label_x_pos = home_x_pos + 215
        endcase, /* (all_pos) */
 
       label_y_pos = home_y_pos + 90,
       accn = 0,
 
       aliq_per_format = 4,
 
%i cust_script:cov_q_bc_gen507z.inc
%i cust_script:cov_aliquot_zb_vac507.inc
 
         all_pos = all_pos + 1,
         if (all_pos = aliq_per_format + 1)
            print_collect = 'Y',
            all_pos = 1,
            row+1,
            if (rec_cnt < record_total)
              "{np}"
            endif /* (rec_cnt < record_total) */
         endif /* (all_pos = aliq_per_format + 1) */
 
      endwhile, /* (printed = 'N') */
 
      tube = tube + 1,
      aliq_index = 1
 
   endwhile /* (done = 'N') */
 
with dio = 16,
     format = undefined,
     maxcol = 256,
     maxrow = 96,
     noformfeed,
     size = 256
end
go
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
        Source file name:       INIT_LOGIC507.INC
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
;     001 10/15/97 David Compton        INIT_LOGIC507.INC sets logic needed *
;                                       to print work-site specific         *
;                                       specimen labels for all bar code    *
;                                       formats.                            *
;     002 04/04/01 Todd Anderson        Added Code128 Symbology.            *
;     003 02/05/2018 Dawn Greer, DBA    Renamed to                          *
;                                       cust_script:cov_init_logic507.inc   *
;     004 02/14/2018 Dawn Greer, DBA    Changed Sex field to DOB            *
;     005 07/31/2018 Dawn Greer, DBA    Changed MEDNBR to be the FINNBR     *
;     006 09/19/2018 Dawn Greer, DBA    Removed 'DOB' text from DOB String  *
;     007 09/20/2018 Dawn Greer, DBA    Changed the size of the DOB string  *
;~DE~************************************************************************
 
head report
 
   if (request->print_id_flag = 1)
      smg_print_id_flag = 'Y'
   else
      smg_print_id_flag = 'N'
   endif,
 
   if (request->hibc_flag = 1)
      hibc_flag = 'Y'
   else
      hibc_flag = 'N'
   endif,
 
   if (request->print_med_rec_flag = 1)
      print_med_rec_flag = 'N'    ;;;;;;;;;005 DG changed from 'Y'
   else
      print_med_rec_flag = 'N'
   endif,
 
   /**********************************************************/
   /* secnd_alq_flg will print a second aliquot, regardless. */
   /* Normally 'on', included for upward compatibility.      */
   /**********************************************************/
   secnd_alq_flg = 'Y',
 
   /**************************************************************/
   /* standard = 1 will cause aliquot labels to print with       */
   /* container id, if used, and code 39 without checksum.       */
   /* I.E. Standardly printed aliquot bar codes prior to 3.06.   */
   /* standard = 0 prints instrument specific aliquot bar codes. */
   /**************************************************************/
   standard = 0,
   record_total = 1,
 
   /****************************************/
   /* Find the total number of occurences. */
   /****************************************/
   record_total = value(request->container_count),
 
   /*********************************/
   /* declare positioning variables */
   /*********************************/
   all_pos      = 1,
   bc_x_pos     = 0,
   bc_y_pos     = 0,
   field_x_pos  = 0,
   field_y_pos  = 0,
   home_x_pos   = lbl_x_pos,
   home_y_pos   = lbl_y_pos,
   label_x_pos  = 0,
   label_y_pos  = 0,
   pos_string   = fillstring(30, " "),
   yoffset      = 0,
   xoffset      = 0,
 
   /*********************************/
   /* Declare barcode format fields */
   /*********************************/
   bc_med_string     = fillstring(35, " "),
   bc_accn_string    = fillstring(31, " "),
 
   /**********************************/
   /* declare code128c format fields */
   /**********************************/
     alpha_prefix       = 'n',
     alpha_suffix       = 'n',
     total_digits       = 0,
     num_digits         = 0,
     num_alpha          = 0,
     pos                = 1,
     alpha_prefix_start = 1,
     alpha_prefix_end   = 1,
 
   /************************************/
   /* declare generic output variables */
   /************************************/
   accession        = fillstring(20, " "),
   accn_prt         = fillstring(20, " "),
   ;age_sex         = fillstring(9, " "),	---2/14/2018 - DG - 004 Changed to DOB
   dob              = fillstring(10, " "),  ;---9/20/2018 - DG - 007 Changed from 15 to 10 (took out DOB string)
   al_name          = fillstring(20, " "),
   bc_accn          = fillstring(30, " "),
   bc_med_nbr       = fillstring(45, " "),
   bc_symbology     = ' ',
   bc_pour_accn     = fillstring(15, " "),
   bc_accn_size     = 0,
   bc_pour_size     = 0,
   cntnr_disp       = fillstring(10, " "),
   col_cont_flag[2] = fillstring(1, " "),
   comment          = fillstring(29, " "),  ;---2/14/2018 - DG - 004 Changed from 20 to 29 to add text label
   date_time        = fillstring(13, " "),
   dr_name          = fillstring(24, " "),
   fin_suffix       = '  ',
   format_vol       = fillstring(7, " "),
   ins_print_id     = ' ',
   list_line        = fillstring(7, " "),
   pri[2]           = fillstring(5, " "),
   print_collect    = 'Y',
   repri[20,2]      = fillstring(2, " "),
   room_bed         = fillstring(7, " "),
   smg_bc           = fillstring(30, " "),
   smg_format       = 0,
   smg_adjust       = 0,
   smg_tube_id[2]   = fillstring(1, " "),
   spec_ins         = fillstring(26, " "),  ;---2/14/2018 - DG - 004 Changed from 15 to 26 to add text label
   test[20,2]       = fillstring(10, " "),
   test_last        = fillstring(10, " "),
   tcntnr           = fillstring(9, " "),
   tmp1             = fillstring(20, " "),
   workc            = fillstring(12, " "),
 
   /***************************/
   /* Declare other variables */
   /***************************/
   a             = 0,
   accn          = 1,
   aliq_cnt      = 1,
   all_proc_stop = 6,
   all_stop      = 1,
   break_pt      = 0,
   ck_sum        = " ",
   ck_accn       = fillstring(30, " "),
   col_proc_stop = 10,
   default       = 0,
   inc           = 0,
   idx           = 0,
   print_cnt     = 0,
   rec_cnt       = 1,
   smg_form      = " ",
   split         = 0,
   stop[2]       = 0,
   test_cnt[2]   = 0,
   tube          = 1,
   tube_id       = 0,
   tub_proc_stop = 7,
   x             = 0,
   finsuffix     = "01",
   templc        = fillstring(5, " "),
   tests_per_aliq = 6,
 
   i = 0,
   j = 0,
 
   /***********************************************************/
   /* Initialize the additional container demographics array. */
   /***********************************************************/
   for (i = 1 to record_total)
      cntnr->qual[i]->colpri = "RT",
      cntnr->qual[i]->colprinum = 9999,
      cntnr->qual[i]->reppri = "RT",
      cntnr->qual[i]->repprinum = 9999,
      cntnr->qual[i]->pri = "  /  ",
      cntnr->qual[i]->id = ' ',
      cntnr->qual[i]->stop = 0,
      cntnr->qual[i]->test_cnt = 0
   endfor,
 
   /******************/
   /* Define globals */
   /******************/
   aliq_index    = 1,
   done          = 'N',
   printed       = 'N',
   print_coll    = 'Y',
   tube_ptr      = 1
 
detail
 
   if (home_x_pos < 0)
      home_x_pos = 0
   endif,
   if (home_y_pos < 0)
      home_y_pos = 0
   endif,
 
   for (i = 1 to record_total)
      for (j = 1 to request->container_qual[i]->order_count)
         if (request->container_qual[i]->order_qual[j]->label_sequence <
                                                      cntnr->qual[i]->colprinum)
            cntnr->qual[i]->colprinum =
                             request->container_qual[i]->order_qual[j]->label_sequence
            cntnr->qual[i]->colpri =
                            request->container_qual[i]->order_qual[j]->cpri_disp
            cntnr->qual[i]->reppri =
                            request->container_qual[i]->order_qual[j]->rpri_disp
         endif
      endfor, /* (j = 1 to ...) */
 
      cntnr->qual[i]->pri = concat(cntnr->qual[i]->colpri, '/',
                                   cntnr->qual[i]->reppri),
      cntnr->qual[i]->test_cnt = request->container_qual[i]->order_count
 
     if ((cnvtint(request->container_qual[i]->acc_container_nbr) > 0)
		and (cnvtint(request->container_qual[i]->acc_container_nbr) < 27))
		cntnr->qual[i]->id =
			char(cnvtint(request->container_qual[i]->acc_container_nbr) + 64)
      endif
	 if ((cnvtint(request->container_qual[i]->acc_container_nbr) > 26)
		 and (cnvtint(request->container_qual[i]->acc_container_nbr) < 53))
		cntnr->qual[i]->id =
			char(cnvtint(request->container_qual[i]->acc_container_nbr) + 70)
      endif
 
   endfor /* (i = 1 to ...) */
 
foot report
 
   /*************************/
   /* Define temporary vars */
   /*************************/
   age = substring(1, 5, cnvtage(cnvtdate(request->birthdate), 1) ),
   ;age_sex = concat( age, ' ', substring(1, 1, request->sex_disp) ), ;---2/14/2018 - DG - 004 Changed to DOB
   ;dob = concat("DOB: ",format(request->birthdate, "mm/dd/yyyy;;d")), ;---2/14/2018 - DG - 004 Created with text label
   dob = format(request->birthdate, "mm/dd/yyyy;;d"), ;---9/19/2018 - DG - 006 removed 'DOB' text from DOB String
   al_name = substring( 1, 12, request->name_full_formatted),
   ;bc_med_nbr = cnvtalphanum(request->mednbr),		;---7/31/2018 - DG - 005 Commented out
   bc_med_nbr = cnvtalphanum(request->finnbr),      ;---7/31/2018 - DG - 005 Changed to Request->finnbr
   bc_accn = cnvtalphanum(request->accession),
   ;---2/14/2018 - DG - 004 Added text label to comment field.
   comment = concat("Comment: ", substring(1, 20, request->container_qual[1]->container_comment)),
   room_bed = concat(trim(request->room_disp), '-', trim(request->bed_disp)),
   templc = substring(1, 5, request->loc_temp_disp),
   tube_ptr = 1,
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
        Source file name:       Q_BC_GEN507.INC
        Object name:
        Request #:              265084
 
        Product:                Specimen Collections
        Product Team:           Pathnet
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Barcode generation logic for label programs.
 
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
;     001 10/15/97 David Comtpon        Q_BC_GEN507.INC figures checksum    *
;                                       algorithms and sets symbology DIO   *
;                                       for barcoded labels.                *
;     002 04/13/98 David Compton        Corrected ins_print_id functionality*
;     003 04/04/01 Todd Anderson        Added Code128 Symbology.            *
;     004 08/15/03 Todd Anderson        Modified for Code128 for Zebras to  *
;                                       correctly handle symbology being    *
;                                       passed from the collection class ap.*
;     005 02/05/2018 Dawn Greer, DBA    Renumbered the Mods above.  002 was *
;                                       used twice.  Renamed to             *
;                                       cust_script:cov_q_bc_gen507z.inc    *
;~DE~************************************************************************
 
   /*****************************/
   /* Declare common variables. */
   /*****************************/
   ck_sum = ' ',
   start_ch = ' ',
   stop_ch = ' ',
 
   /********************************/
   /* Declare temporary variables. */
   /********************************/
   smg_bc_tmp = fillstring(20, " "),
   smg_bc = fillstring(20, " "),
 
   if (accn = 1)
      smg_bc_tmp = bc_accn
   else
      smg_bc_tmp = bc_pour_accn
   endif, /* (accn = 1) */
 
/*
** 002...   if ((ins_print_id = 'Y') and (smg_print_id_flag = 'Y'))
*/
   if ((ins_print_id = 'B') and (smg_print_id_flag = 'Y'))               /* 002... */
     smg_bc_tmp = build(smg_bc_tmp, cntnr->qual[tube]->id)
   endif, /*  ((ins_print_id = 'B') and ... */
 
   if (start_ch = ' ')
      start_ch = 'A'
   endif, /* (start_ch = ' ') */
 
   if (stop_ch = ' ')
      stop_ch = 'B'
   endif, /* (stop_ch = ' ') */
 
   if (accn = 1)
      case (bc_symbology)
      of ' ': smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/28/7}"
      of 'A': smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/28/7}"
      of 'B': smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/29/7}"
      of 'C': smg_bc_dio = "{lpi/12}{cpi/14}{bcr/300}{font/30/5}"
      of 'D': smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/28/7}"
      of 'E': smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/29/7}"
      of 'F': smg_bc_dio = "{lpi/12}{cpi/14}{bcr/300}{font/30/5}"
      OF 'G': smg_bc_dio = "{lpi/16}{cpi/12}{bcr/250}{font/31/7}"
      else    smg_bc_dio = "{lpi/16}{cpi/8}{bcr/250}{font/28/7}"
      endcase /* (bc_symbology) */
   else
      if (standard = 1)
         smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/28/2}",              /* 002... */
/*
** 002...         smg_bc_dio = "{lpi/6}{cpi/16}{bcr/250}{font/28/2}",
** 002...         if ((smg_print_id_flag = 'Y') and (ins_print_id = 'N'))
*/
         if ((smg_print_id_flag = 'Y') and (ins_print_id = 'B'))          /* 002... */
            smg_bc = build('*', smg_bc_tmp, cntnr->qual[tube]->id, '*')
         else
            smg_bc = build('*', smg_bc_tmp, '*')
         endif /* (smg_print_id_flag = 'Y') and ... */
      else
         case (bc_symbology)
         of ' ': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/28/2}"
         of 'A': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/28/2}"
         of 'B': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/29/2}"
         of 'C': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/30/2}"
         of 'D': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/28/2}"
         of 'E': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/29/2}"
         of 'F': smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/30/2}"
         of 'G': smg_bc_dio = "{lpi/6}{cpi/25}{bcr/300}{font/31/2}"
         else    smg_bc_dio = "{lpi/6}{cpi/16}{bcr/300}{font/28/2}"
         endcase /* (bc_symbology) */
      endif /* (standard = 1) */
   endif, /* (accn = 1) */
 
   if ((accn = 1) or (standard = 0))
     case (bc_symbology)
       of ' ': /* Default is Code 39 without checksum */
                if ((substring(size(trim(smg_bc_tmp)) - 8, 1, smg_bc_tmp)
                     between 'A' and 'Z')
                    or (substring(size(trim(smg_bc_tmp)) - 7, 1, smg_bc_tmp)
                        between 'A' and 'Z'))
                   /* Alpha prefixed accession */
                   smg_bc = build('*',
                      (substring(size(trim(smg_bc_tmp)) - 8, 2, smg_bc_tmp)),
                      (substring(size(trim(smg_bc_tmp)) - 4, 5, smg_bc_tmp)), '*')
                else
                   smg_bc = build('*', smg_bc_tmp, '*')
                endif /* ((substring(size(trim(... */
 
       of 'A': /* Code 39 without checksum */
                smg_bc = build('*', smg_bc_tmp, '*')
 
       of 'B': /* Codabar without checksum */
                smg_bc = build(start_ch, trim(smg_bc_tmp), stop_ch)
 
       of 'C': /* Interleave 2 of 5 without checksum */
                smg_bc = build('*', smg_bc_tmp, '*')
 
       of 'D': /* Code 39 symbology with Modulo 43 checksum */
                ck_sum = char(modcheck(43, trim(smg_bc_tmp))),
                smg_bc = concat('*', smg_bc_tmp, ck_sum, '*')
 
       of 'E': /* Codabar symbology with Modulo 16 checksum */
                i = 1,
                v = 0,
                c = ' ',
                smg_bc_tmp_2 = build(start_ch, smg_bc_tmp, stop_ch),
                strlen = size(smg_bc_tmp_2),
                total = 0,
                while (i <= strlen)
                   c = substring(i, 1, smg_bc_tmp_2)
                   case (c)
                   of '-' : v = 10
                   of '$' : v = 11
                   of ':' : v = 12
                   of '/' : v = 13
                   of '.' : v = 14
                   of '+' : v = 15
                   of 'A' : v = 16
                   of 'B' : v = 17
                   of 'C' : v = 18
                   of 'D' : v = 19
                   else     v = cnvtint(c)
                   endcase, /* (c) */
                   i = i + 1,
                   total = total + v
                endwhile, /* (i <= strlen) */
 
                remainder = mod(total, 16),
                remainder = 16 - remainder,
 
                case (remainder)
                of 10 : ck_sum = '-'
                of 11 : ck_sum = '$'
                of 12 : ck_sum = ':'
                of 13 : ck_sum = '/'
                of 14 : ck_sum = '.'
                of 15 : ck_sum = '+'
                of 16 : ck_sum = 'A'
                of 17 : ck_sum = 'B'
                of 18 : ck_sum = 'C'
                of 19 : ck_sum = 'D'
                else    ck_sum = cnvtstring(remainder)
                endcase, /* (remainder) */
                smg_bc = concat(start_ch, smg_bc_tmp, ck_sum, stop_ch)
 
       of 'F': /* Interleave 2 of 5 symbology with checksum */
                sym_str = "Int 2 of 5 w/ checksum",
                odd_num = 0,
                even_num = 0,
                sum = 0,
                str_ptr = size(trim(smg_bc_tmp)),
                while (str_ptr > 1)
                   even_num =
                            cnvtint(substring(str_ptr, 1, smg_bc_tmp)) + even_num,
                   str_ptr = str_ptr - 1,
                   odd_num = cnvtint(substring(str_ptr, 1, smg_bc_tmp)) + odd_num,
                   str_ptr = str_ptr - 1
                endwhile, /* (str_ptr > 1) */
 
                if (str_ptr = 1)
                   even_num =
                             cnvtint(substring(str_ptr, 1, smg_bc_tmp)) + even_num
                endif, /* (str_ptr = 1) */
                sum = odd_num + (even_num * 3),
                ck_sum = substring(3, 1, cnvtstring(1000 - sum)),
                smg_bc = concat('*', smg_bc_tmp, ck_sum, '*')
 
       of 'G':/* Code128 for Zebras */
     	       len = size(trim(smg_bc_tmp), 1),
               pos = 1,
               cypher_b_start = 0,
               cypher_b_end = 0,
               cypher_suffix = 0,
               cypher_prefix = 0,
               while (pos <= len)
	               if ((substring(pos, 1, smg_bc_tmp) between 'A' and 'Z') or (substring(pos, 1, smg_bc_tmp) = ' '))
				;Determine if we have an alpha prefix or container id.
	                  if (pos < len)
 			               if (cypher_b_start = 0)
 			                 cypher_prefix = 1
                          cypher_b_start = pos
                	      endif
			               cypher_b_end = pos
					      else
			               cypher_suffix = 1
			            endif
		             endif
	               pos = pos + 1
               endwhile
 
               if(cypher_b_start > 1) ;Check whether there is a site prefix
                 ;Determine if the site_prefix is odd.  If so, decrement the start of cypher b to ensure there is an even number
                 ;of digits in the site prefix to use cypher c
                 if(mod(cypher_b_start - 1, 2) = 1)
                   cypher_b_start = cypher_b_start - 1
                 endif
               endif
 
               ;Check if the digits after the alpha prefix are odd or the entire accession is odd for numerical accessions.
               if(mod(len - cypher_b_end - cypher_suffix, 2) = 1)
                 if(cypher_prefix = 1) ;This is an alpha prefixed accession, move the end of the alpha prefix one spot to ensure the
                                         ;sequence has a even number of digits to print with Cypher Set C
                   cypher_b_end = cypher_b_end + 1
                 else ;This is a numeric accession with an odd number of digits, print the first character with Cypher Set B
                   cypher_prefix = 1
                   cypher_b_start = 1
                   cypher_b_end = 1
                 endif
               endif
 
               if(cypher_prefix = 1) ;This is an alpha prefixed accession or a numeric accession with an odd number of digits
                 if(cypher_b_start > 1) ;Alpha prefixed accession with site prefix
                   smg_bc = build( '*>;', substring(1, cypher_b_start - 1, smg_bc_tmp),
                        	         '>6', substring(cypher_b_start, (cypher_b_end - cypher_b_start + 1), smg_bc_tmp),
                                   '>5', substring(cypher_b_end + 1, len - cypher_b_end - cypher_suffix, smg_bc_tmp))
                 else ;no site prefix but we have an alpha prefix or a numeric accession with an odd number of digits
                   smg_bc = build( '*>:',
                                   substring(cypher_b_start, (cypher_b_end - cypher_b_start + 1), smg_bc_tmp),
                                   '>5', substring(cypher_b_end + 1, len - cypher_b_end - cypher_suffix, smg_bc_tmp))
                 endif
               else ;numeric accession with an even number of digits
                 smg_bc = build('*>;', substring(1, len - cypher_suffix, smg_bc_tmp))
               endif
 
 
                 if(cypher_suffix = 1) ;We have a container id
                   smg_bc = build(smg_bc, '>6', substring(len, 1, smg_bc_tmp))
                 endif
 
 	             smg_bc = build(smg_bc, '*{font/0}')
 
 
       else    /* Default is code 39 without checksum */
         if ((substring(size(trim(smg_bc_tmp)) - 8, 1, smg_bc_tmp) between 'A' and 'Z')
            or (substring(size(trim(smg_bc_tmp)) - 7, 1, smg_bc_tmp) between 'A' and 'Z'))
            /* Alpha prefixed accession */
           smg_bc = build('*',
                (substring(size(trim(smg_bc_tmp)) - 8, 2, smg_bc_tmp)),
                (substring(size(trim(smg_bc_tmp)) - 4, 5, smg_bc_tmp)),'*')
         else
           smg_bc = build('*', smg_bc_tmp, '*')
         endif /* ((substring(size(trim(... */
 
     endcase /* (bc_symbology) */
   endif /* ((accn = 1) or (standard = 0)) */


/*~BB~************************************************************************
  *                                                                      *
  *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
  *                              Technology, Inc.                        *
  *       Revision      (c) 1984-2004 Cerner Corporation                 *
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
 
        Source file name:       care_rh_bbt_tag_driver.prg
        Object name:            care_rh_bbt_tag_driver
        Request #:
 
        Product:                Pathnet
        Product Team:           Blood Bank Transfusion
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Print component tags
 
        Tables read:            ?
 
        Tables updated:         None
 
        Executing from:         VB
 
        Special Notes:          ??
******************************************************************************/
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date         Engineer           Comment                           *
;    *--- -----------  ------------------ --------------------------------- *
;    *001 12-APR-2016  CERFTS             Initial Release                   *
;~DE~************************************************************************
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
 
drop program chs_tn_bbt_tag_driver:dba go
create program chs_tn_bbt_tag_driver:dba
 
 
;record request populated in bbt_tag_print_ctrl.prg which calls this program
;declare internal record structures for antigens, antibodies and pooled component products */
 
;%i ccluserdir:chs_tn_bbt_struct.inc
 
 
record extrainfo
(
1 taglist[*]
  2 product_check_digit = vc
  2 isbt_barcode 		  = vc
  2 xm_result_value_alpha_long = vc
)
 
;;process antigens - need to separate out true antigens from other special testing for display on output
;set tot_tag_cnt = size(tag_request->taglist,5)
;set stat = alterlist(extrainfo->taglist, size(tag_request->taglist,5))
;for (x=1 to tot_tag_cnt)
;	set extrainfo->taglist[x].product_check_digit = CalculateCheckDigit(trim(tag_request->taglist[x].product_nbr))
;endfor
 
%i cclsource:bbt_get_rpt_filename.inc
 
if(tag_request->tag_type = "COMPONENT")
    execute cpm_create_file_name_logical "bbt_tag_comp", "dat", "x"
elseif(tag_request->tag_type = "CROSSMATCH")
    execute cpm_create_file_name_logical "bbt_tag_cross", "dat", "x"
else
    execute cpm_create_file_name_logical "bbt_tag_emerg", "dat", "x"
endif
 
set rpt_filename = cpm_cfn_info->FILE_NAME
/******************************************************
*                Call Layout                          *
******************************************************/
if (tag_request->tag_type = "EMERGENCY")
   execute CHS_TN_BBT_EM_TAG_LYT value(CPM_CFN_INFO->FILE_NAME_PATH)
else
   execute CHS_TN_BBT_TAG_LYT value(CPM_CFN_INFO->FILE_NAME_PATH)
endif
 
 set last_mod = "001 029-JAN-2018 CERFTS"
 
end go

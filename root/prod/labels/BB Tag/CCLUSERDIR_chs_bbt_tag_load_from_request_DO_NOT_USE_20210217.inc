/*********************************************************************************************************************************
Copyright Notice:  (c) 1983 Laboratory Information Systems & Technology, Inc.
Revision:          (c) 1984-2015 Cerner Corporation
 
 Cerner (R) Proprietary Rights Notice:  All rights reserved.  This material contains the valuable properties and trade secrets of
 Cerner Corporation of Kansas City, Missouri, United States of America (Cerner), embodying substantial creative efforts and
 confidential information, ideas and expressions, no part of which may be reproduced or transmitted in any form or by any means,
 or retained in any storage or retrieval system without the express written permission of Cerner.
 
 Cerner is a registered mark of Cerner Corporation.
**********************************************************************************************************************************
Date Written:       02/18/2015
Source file name:   ccps_bbt_tag_load_from_request.inc
Object name:        not a stand alone prg.  Must be used as an include file
Purpose:
    This include file is used by ccps_bbt_tag_crossmatch.prg, ccps_bbt_tag_component.prg and ccps_bbt_tag_emergency.prg
    to set the locally defined program variables = to the respective variables in each subsequent instance of the request record
    (so that the entire request record path need not be specified when referencing a variable from the request record).
 
**********************************************************************************************************************************
MODIFICATION CONTROL LOG
**********************************************************************************************************************************
Mod Date     	Engineer  Comment
--- ---------- 	--------  ------------------------------------------------
001 05/16/2016 	BA045754  			Modify for template use.
002 09/20/2017 	TD020616  			Added antigens/antibody and also barcodes to the template.
003 04/12/2018 	CERFTS    			Correct issue where antigens are displaying twice
                                     
**********************************************************************************************************************************
END OF ALL MODCONTROL BLOCKS
*********************************************************************************************************************************/
 
    ;initialize the barcode value
    patient_name_barcode = " "
    mrn_barcode          = " "
    fin_barcode          = " "
    DOB_barcode          = " "
    BBID_barcode         = " "
    person_aborh_barcode = " "
    product_num_barcode  = " "
    bridge_barcode = " "
    volume_disp  =     "                      "
 
    pe_event_dt_tm                  = cnvtdatetime(tag_request->taglist[d.seq].pe_event_dt_tm)
    tech_name                       = trim(tag_request->taglist[d.seq].tech_name)
    product_disp                    = trim(tag_request->taglist[d.seq].product_disp)
    product_desc                    = trim(tag_request->taglist[d.seq].product_desc) ;cjp 10-21-97
    product_nbr                     = trim(tag_request->taglist[d.seq].product_nbr)
    product_sub_nbr                 = trim(tag_request->taglist[d.seq].product_sub_nbr)
    product_flag_chars              = trim(tag_request->taglist[d.seq].flag_chars)
    product_nbr_full                = concat(trim(tag_request->taglist[d.seq].supplier_prefix),
                                           trim(tag_request->taglist[d.seq].product_nbr),  
                                           " ",   
                                           trim(tag_request->taglist[d.seq].product_sub_nbr))	

    if (textlen(trim(product_nbr)) = 13)
      ;ISBT product number
      product_barcode_nbr             = concat(trim(tag_request->taglist[d.seq].product_nbr),
                                               trim(tag_request->taglist[d.seq].flag_chars))
    else
      product_barcode_nbr             = trim(tag_request->taglist[d.seq].product_barcode_nbr)
    endif
 
    if (textlen(trim(product_barcode_nbr)) > 0)
      ;Check if the product number is Eurocode, ISBT or Codabar product number.
      if (findstring("!", trim(product_barcode_nbr), 1, 0) = 1 and textlen(trim(product_barcode_nbr)) >= 13
        and textlen(trim(product_barcode_nbr)) <= 19)
        ;Eurocode product number
        product_num_barcode         = concat("e", trim(product_barcode_nbr), "u")
      elseif (textlen(trim(product_barcode_nbr)) = 15)
        ;ISBT product number. 13 digits product nbr + 2 digits flag char
        product_num_barcode         = concat("=", trim(product_barcode_nbr), "u")
      else
        ;Codabar unit
        product_num_barcode         = concat("r", trim(product_barcode_nbr), "u")
      endif
    endif
    alternate_nbr                   = trim(tag_request->taglist[d.seq].alternate_nbr)
    segment_nbr                     = trim(tag_request->taglist[d.seq].segment_nbr)
    if (tag_request->taglist[d.seq].cur_volume > 0)
        cur_volume                  = trim(cnvtstring(tag_request->taglist[d.seq].cur_volume))
    else
        cur_volume                  = " "
    endif
    cur_unit_meas_disp              = trim(tag_request->taglist[d.seq].cur_unit_meas_disp)
    bb_id_nbr                       = trim(tag_request->taglist[d.seq].bb_id_nbr)
    if (textlen(trim(bb_id_nbr)) > 0)
      BBID_barcode                    = concat("r", trim(bb_id_nbr), "s")
    endif
    product_expire_dt_tm            = cnvtdatetime(tag_request->taglist[d.seq].product_expire_dt_tm)
    derivative_ind                  = tag_request->taglist[d.seq].derivative_ind
    if (tag_request->taglist[d.seq].derivative_ind != 1)
        cur_abo_disp                    = trim(tag_request->taglist[d.seq].cur_abo_disp)
        cur_rh_disp                     = trim(tag_request->taglist[d.seq].cur_rh_disp)
        supplier_prefix                 = trim(tag_request->taglist[d.seq].supplier_prefix)
        qty_vol_disp
            =   concat("VOL: ", trim(cnvtstring(tag_request->taglist[d.seq].cur_volume)),
                    " ", trim(tag_request->taglist[d.seq].cur_unit_meas_disp))
        qty_vol_disp_1
            =   concat(trim(cnvtstring(tag_request->taglist[d.seq].cur_volume)),
                    " ", trim(tag_request->taglist[d.seq].cur_unit_meas_disp))
 
    else
        cur_abo_disp                    = " "
        cur_rh_disp                     = " "
        supplier_prefix                 = " "
        volume_disp                     = " "
 
 
        if (tag_request->taglist[d.seq].item_unit_per_vial = 0)
            if (tag_request->taglist[d.seq].item_volume > 0)
                volume_disp = concat("  VOL: ", trim(cnvtstring(tag_request->taglist[d.seq].item_volume)),
                    " ", trim(tag_request->taglist[d.seq].item_unit_meas_disp))
            endif
 
            qty_vol_disp
                =   concat("QTY: ", trim(cnvtstring(tag_request->taglist[d.seq].quantity)),volume_disp)
;                    "  VOL: ", trim(cnvtstring(tag_request->taglist[d.seq].item_volume)),
;                    " ", trim(tag_request->taglist[d.seq].item_unit_meas_disp))
            qty_vol_disp_1
                =   concat(trim(cnvtstring(tag_request->taglist[d.seq].quantity)),volume_disp)
;                    "  VOL: ", trim(cnvtstring(tag_request->taglist[d.seq].item_volume)),
;                    " ", trim(tag_request->taglist[d.seq].item_unit_meas_disp))
        else
            qty_vol_disp
                =  concat("QTY: ", trim(cnvtstring(tag_request->taglist[d.seq].quantity)),
                   "  IU PER: ", trim(cnvtstring(tag_request->taglist[d.seq].item_unit_per_vial)),
                   "  TOT IU: ", trim(cnvtstring(tag_request->taglist[d.seq].item_volume)))
            qty_vol_disp_1
                =  concat(trim(cnvtstring(tag_request->taglist[d.seq].quantity)),
                   "  IU PER: ", trim(cnvtstring(tag_request->taglist[d.seq].item_unit_per_vial)),
                   "  TOT IU: ", trim(cnvtstring(tag_request->taglist[d.seq].item_volume)))
        endif
    endif
 
    accession                       = trim(tag_request->taglist[d.seq].accession)
    xm_result_value_alpha           = trim(tag_request->taglist[d.seq].xm_result_value_alpha)
    xm_result_event_prsnl_username  = trim(tag_request->taglist[d.seq].xm_result_event_prsnl_username)
    xm_result_event_dt_tm           = cnvtdatetime(tag_request->taglist[d.seq].xm_result_event_dt_tm)
    xm_expire_dt_tm                 = cnvtdatetime(tag_request->taglist[d.seq].xm_expire_dt_tm)
    reason_disp                     = trim(tag_request->taglist[d.seq].reason_disp)
 
    if (tag_type != emergency_tag
    or tag_request->taglist[d.seq].unknown_patient_ind != 1)
        /*
         * If emergency_tag and unknown_patient then print unknown_patient_text for patient name
         * and do not fillout any other patient information
         */
        name_full_formatted             = trim(tag_request->taglist[d.seq].name_full_formatted)
        if (textlen(trim(name_full_formatted))> 0)
          patient_name_barcode          = concat("r", trim(name_full_formatted), "n")
        endif
        alias_mrn                       = trim(tag_request->taglist[d.seq].alias_mrn)
        alias_mrn_formatted             = trim(tag_request->taglist[d.seq].alias_mrn_formatted)
        if (textlen(trim(alias_mrn))    > 0)
          mrn_barcode                   = concat("r", trim(alias_mrn), "i")
        endif
        alias_fin                       = trim(tag_request->taglist[d.seq].alias_fin)
        alias_fin_formatted             = trim(tag_request->taglist[d.seq].alias_fin_formatted)
        if (textlen(trim(alias_fin))    > 0)
          fin_barcode                   = concat("r", trim(alias_fin), "f")
        endif
        alias_ssn                       = trim(tag_request->taglist[d.seq].alias_ssn)
        alias_ssn_formatted             = trim(tag_request->taglist[d.seq].alias_ssn_formatted)
        age                             = trim(tag_request->taglist[d.seq].age)
        sex_disp                        = trim(tag_request->taglist[d.seq].sex_disp)
        patient_location                = trim(tag_request->taglist[d.seq].patient_location)
        prvdr_name_full_formatted       = trim(tag_request->taglist[d.seq].prvdr_name_full_formatted)
        person_abo_disp                 = trim(tag_request->taglist[d.seq].person_abo_disp)
        person_rh_disp                  = trim(tag_request->taglist[d.seq].person_rh_disp)
        if (textlen(trim(tag_request->taglist[d.seq].person_aborh_barcode)) > 0)
          person_aborh_barcode            = concat("r", trim(tag_request->taglist[d.seq].person_aborh_barcode), "b")
        endif
        birth_dt_tm                     = cnvtdatetime(tag_request->taglist[d.seq].birth_dt_tm)
        if (birth_dt_tm > 0)
          DOB_barcode                     = build("r", cnvtstring(YEAR(birth_dt_tm)),
                                                  format(cnvtstring(JULIAN(birth_dt_tm)), "###;P0;"),
                                                  format(cnvtstring(HOUR(birth_dt_tm)), "##;P0;"),
                                                  format(cnvtstring(MINUTE(birth_dt_tm)), "##;P0;"), "s")
        endif
 
        if (textlen(trim(tag_request->taglist[d.seq]->bb_id_nbr)) > 0)
 			bridge_barcode = build("*", trim(tag_request->taglist[d.seq].alias_mrn)
								   ,"!", trim(tag_request->taglist[d.seq].bb_id_nbr)
 								   ,"!", trim(tag_request->taglist[d.seq].name_full_formatted)
 			                       ,"!", trim(product_nbr_full)
 			                       ,"!", trim(tag_request->taglist[d.seq].person_aborh_barcode)
 			                       ,"*")
		else
			bridge_barcode = build("*", trim(tag_request->taglist[d.seq].alias_mrn),
 			                       "!", trim(tag_request->taglist[d.seq].name_full_formatted),
 			                       "!", trim(product_nbr_full),
 			                       "!", trim(tag_request->taglist[d.seq].person_aborh_barcode),
 			                       "*")
 		endif
 
    else
        name_full_formatted             = tag_request->taglist[d.seq].unknown_patient_text
        if (textlen(trim(name_full_formatted))> 0)
          patient_name_barcode            = concat("r", trim(name_full_formatted), "n")
        endif
        alias_mrn                       = " "
        mrn_barcode                     = " "
        alias_fin                       = " "
        fin_barcode                     = " "
        age                             = " "
        sex_disp                        = " "
        patient_location                = " "
        prvdr_name_full_formatted       = " "
        person_abo_disp                 = " "
        person_rh_disp                  = " "
        person_aborh_barcode            = " "
        birth_dt_tm                     = cnvtdatetime("")
        DOB_barcode                     = " "
    endif
 
    antibody_cnt                    = cnvtint(tag_request->taglist[d.seq].antibody_cnt)
    stat                            = alter(antibody->antibodylist, tag_request->taglist[d.seq].antibody_cnt)
    for (antbdy = 1 to antibody_cnt)
        antibody->antibodylist[antbdy].antibody_cd    = tag_request->taglist[d.seq].antibodylist[antbdy].antibody_cd
        if (tag_request->taglist[d.seq].antibodylist[antbdy].antibody_cd > 0)
           antibody->antibodylist[antbdy].antibody_disp  =
              trim(uar_get_code_display(tag_request->taglist[d.seq].antibodylist[antbdy].antibody_cd))
        else
           antibody->antibodylist[antbdy].antibody_disp  =
              trim(tag_request->taglist[d.seq].antibodylist[antbdy].antibody_disp)
        endif
        antibody->antibodylist[antbdy].trans_req_ind  = tag_request->taglist[d.seq].antibodylist[antbdy].trans_req_ind
    endfor
    antigen_cnt                     = cnvtint(tag_request->taglist[d.seq].antigen_cnt)
    stat                            = alter(antigen->antigenlist, tag_request->taglist[d.seq].antigen_cnt)
    for (antgen = 1 to antigen_cnt)
        antigen->antigenlist[antgen].antigen_cd    = tag_request->taglist[d.seq].antigenlist[antgen].antigen_cd
        if (tag_request->taglist[d.seq].antigenlist[antgen].antigen_cd > 0)
            antigen->antigenlist[antgen].antigen_disp =
               trim(uar_get_Code_display(tag_request->taglist[d.seq].antigenlist[antgen].antigen_cd))
        else
            antigen->antigenlist[antgen].antigen_disp  = trim(tag_request->taglist[d.seq].antigenlist[antgen].antigen_disp)
        endif
        antigen->antigenlist[antgen].antigen_cdf    ;mp9098
                                    = trim(uar_get_code_meaning(tag_request->taglist[d.seq].antigenlist[antgen].antigen_cd))
    endfor
    cmpnt_cnt                       = tag_request->taglist[d.seq].cmpnt_cnt
    stat                            = alter(component->cmpntlist, tag_request->taglist[d.seq].cmpnt_cnt)
    for (cmpnt = 1 to cmpnt_cnt)
        component->cmpntlist[cmpnt].product_id      = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_id
        component->cmpntlist[cmpnt].product_cd      = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_cd
        component->cmpntlist[cmpnt].product_disp    = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].product_disp)
        component->cmpntlist[cmpnt].product_nbr     = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].product_nbr)
        component->cmpntlist[cmpnt].product_sub_nbr = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].product_sub_nbr)
        component->cmpntlist[cmpnt].cur_abo_cd      = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_abo_cd
        component->cmpntlist[cmpnt].cur_abo_disp    = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_abo_disp)
        component->cmpntlist[cmpnt].supplier_prefix = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].supplier_prefix)
        component->cmpntlist[cmpnt].cur_rh_cd       = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_rh_cd
        component->cmpntlist[cmpnt].cur_rh_disp     = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_rh_disp)
    endfor
 
    dispense_tech_username                          = trim(tag_request->taglist[d.seq].dispense_tech_username)
    dispense_dt_tm                                  = cnvtdatetime(tag_request->taglist[d.seq].dispense_dt_tm)
    dispense_courier                                = trim(tag_request->taglist[d.seq].dispense_courier)
    dispense_prvdr_name                             = trim(tag_request->taglist[d.seq].dispense_prvdr_name)
   ;special_testing_disp                             = trim(tag_addl->tag_qual[d.seq].special_testing_disp)
 
 
 
;>> Custom <<
    antig_attrib_disp = ""
    antig_only_disp = ""
    attrib_only_disp = ""
    for(antgen = 1 to antigen_cnt)
      ;>> Antigen/Attributes Display <<
      if (textlen(trim(antig_attrib_disp)) = 0)
         antig_attrib_disp = trim(antigen->antigenlist[antgen]->antigen_disp)
      else
         antig_attrib_disp = concat(trim(antig_attrib_disp),", ", trim(antigen->antigenlist[antgen]->antigen_disp))
      endif
      ;>> Antigen Only Display <<
      if(antigen->antigenlist[antgen]->antigen_cdf != "SPTYP")
         if (textlen(trim(antig_only_disp)) = 0)
           antig_only_disp = trim(antigen->antigenlist[antgen]->antigen_disp)
         else
           antig_only_disp = concat(trim(antig_only_disp), ", ", trim(antigen->antigenlist[antgen]->antigen_disp))
         endif
       else
          if (textlen(trim(attrib_only_disp)) = 0)
             attrib_only_disp = trim(antigen->antigenlist[antgen]->antigen_disp)
          else
             attrib_only_disp = concat(trim(attrib_only_disp), ", ", trim(antigen->antigenlist[antgen]->antigen_disp))
          endif
      endif
 
;      ;>> Attributes Only Display <<
;      if(antigen->antigenlist[antgen]->antigen_cd in (CMV_NEG_CD, DEGLY_CD, IRRAD_CD, HGBS_NEG_CD))
;         if (textlen(trim(attrib_only_disp)) = 0)
;            attrib_only_disp = trim(antigen->antigenlist[antgen]->antigen_disp)
;         else
;            attrib_only_disp = concat(trim(attrib_only_disp), ", ", trim(antigen->antigenlist[antgen]->antigen_disp))
;         endif
;         call echo(build(antgen,attrib_only_disp))
;      endif
    endfor
 
    antibdy_disp = ""
    transfusion_disp = ""
    for(antbdy = 1 to antibody_cnt)
      ;>> Antibody Display <<
      if(antibody->antibodylist[antbdy]->trans_req_ind = 0)
         if (textlen(trim(antibdy_disp)) = 0)
            antibdy_disp = trim(antibody->antibodylist[antbdy]->antibody_disp)
         else
            antibdy_disp = concat(trim(antibdy_disp),", ", trim(antibody->antibodylist[antbdy]->antibody_disp))
          endif
      endif
      ;>> Transfusion Display <<
      if(antibody->antibodylist[antbdy]->trans_req_ind = 1)
         if (textlen(trim(transfusion_disp)) = 0) ;can't use antbdy, need to see if anything is in the display
            transfusion_disp = trim(antibody->antibodylist[antbdy]->antibody_disp)
         else
            transfusion_disp = concat(trim(transfusion_disp), ", ", trim(antibody->antibodylist[antbdy]->antibody_disp))
         endif
      endif
    endfor
 
;    if(textlen(trim(transfusion_disp)) > 0)
;      txn_disp_size = textlen(trim(transfusion_disp))
;      if(txn_disp_size <= 50)
;        txn_disp_short = trim(substring(1,50,transfusion_disp))
;      else
;        temp_txn_disp = trim(substring(1,50,transfusion_disp))
;        split_pos = findstring("    ", temp_txn_disp, 1, 1)
;
;
;        txn_disp_short = trim(substring(1,split_pos+3,transfusion_disp))
;        txn_disp_remainder = trim(substring(split_pos+4,txn_disp_size,transfusion_disp))
;      endif
;    else
;       transfusion_disp = "No transfusion data found"
;    endif
 
 		;>> Cleanup Strings to remove beginning spaces from first item <<
 		antig_attrib_disp = trim(antig_attrib_disp,3)
 		antibdy_disp 			= trim(antibdy_disp,3)
 		transfusion_disp 	= trim(transfusion_disp,3)
 	call echorecord(antigen)
    call echo(concat("***  antig_attrib_disp: ",antig_attrib_disp))
    call echo(concat("***  antibdy_disp: ",antibdy_disp))
    call echo(concat("***  transfusion_disp: ",transfusion_disp))
    call echo(concat("*** antig_only_disp:",antig_only_disp))
    call echo(concat("*** attrib_only_disp:",attrib_only_disp))
    call echorecord(antigen)
    call echorecord(antibody)
    call echorecord(tag_request)
 
 
;set last_mod = "002 09/20/17 TD020616  Added barcodes and antigens/antibodies to template"
/* END ccps_bbt_tag_load_from_request.inc */
 
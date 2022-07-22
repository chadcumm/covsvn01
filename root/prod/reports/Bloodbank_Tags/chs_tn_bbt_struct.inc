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
Source file name:   ccps_bbt_tag_internal_struct.inc
Object name:        not a stand alone prg.  Must be used as an include file
Purpose:
    This include file is used by ccps_bbt_tag_crossmatch.prg, ccps_bbt_tag_component.prg and ccps_bbt_tag_emergency.prg
    and is used in conjuction with ccps_bbt_tag_load_from_request.inc.
 
**********************************************************************************************************************************
MODIFICATION CONTROL LOG
**********************************************************************************************************************************
Mod Date     Engineer  Comment
--- -------- --------  ------------------------------------------------
001 05/16/16 BA045754  Modify for template use.
002 09/19/17 TD020616  Added antigens/antibody and barcodes to template
**********************************************************************************************************************************
END OF ALL MODCONTROL BLOCKS
*********************************************************************************************************************************/
 
/*
 * Initialize local program variables
 */
 
   record antibody
(
 1  antibodylist[10]
     2  antibody_cd     = f8
     2  antibody_disp   = c40
     2  trans_req_ind   = i2
)
 
record antigen
(
 1  antigenlist[10]
     2  antigen_cd      = f8
     2  antigen_disp    = c40
     2  antigen_cdf     = c5
 
)
 
record component
(
 1  cmpntlist[10]
     2  product_id      = f8
     2  product_cd      = f8
     2  product_disp    = c40
     2  product_nbr     = c20
     2  product_sub_nbr = c5
     2  alternate_nbr   = c20
     2  cur_abo_cd      = f8
     2  cur_abo_disp    = c20
     2  cur_rh_cd       = f8
     2  cur_rh_disp     = c20
     2  supplier_prefix = c5
)
 
/*
 * Initialize local program variables
 */
    set antbdy                  = 0
    set antibody_cnt            = 0
    set addtnl_antibody_ind     = 0
 
    set antgen                  = 0
    set antigen_cnt             = 0
    set addtnl_antigen_ind      = 0
    set cmpnt                   = 0
    set cmpnt_cnt               = 0
    set addtnl_cmpnt_ind        = 0
    declare cmpnt_disp_row      = c109
    set cmpnt_disp_row          = ""
    declare cmpnt_disp          = c34
    set cmpnt_col               = 0
    set rpt_row                 = 0
 
    declare tech_name           = c15
    declare product_disp        = c40
    declare product_desc        = c60
    declare antibdy_disp       = c109
    declare product_nbr         = c20
    declare product_sub_nbr     = c5
    declare product_flag_chars  = c2     with public, noconstant("  ")
    declare product_nbr_full    = c30
    declare alternate_nbr       = c20
    declare segment_nbr         = c20 ;ds3161 changed from c5
    declare cur_unit_meas_disp  = c15
    declare bb_id_nbr           = c20
    declare cur_abo_disp        = c20
    declare cur_rh_disp         = c20
    declare supplier_prefix     = c5
    declare accession           = c20
    declare xm_result_value_alpha = c15
    declare xm_result_event_prsnl_username  = c15
    declare reason_disp           = c15
    declare name_full_formatted   = c50
    declare alias_mrn             = c25
    declare alias_fin             = c25
    declare alias_ssn             = c25
    declare alias_mrn_formatted   = c25
    declare alias_fin_formatted   = c25
    declare alias_ssn_formatted   = c25
    declare age                   = c12
    declare sex_disp              = c6
    declare patient_location      = c30
    declare prvdr_name_full_formatted  = c50
    declare person_abo_disp       = c20
    declare person_rh_disp        = c20
    declare dispense_tech_username = c15
    declare dispense_courier      = c50
    declare dispense_prvdr_name   = c50
    declare admit_prvdr_name      = c50
    declare qty_vol_disp          = c36
    declare qty_vol_disp_1        = c36   with public, noconstant(" ")
    declare derivative_ind        = i2    with public, noconstant(0)
    declare patient_name_barcode  = vc    with public, noconstant(" ")
    declare mrn_barcode           = vc    with public, noconstant(" ")
    declare fin_barcode           = vc    with public, noconstant(" ")
    declare bridge_barcode        = vc    with public, noconstant(" ")
    declare DOB_barcode           = vc    with public, noconstant(" ")
    declare BBID_barcode          = vc    with public, noconstant(" ")
    declare person_aborh_barcode  = vc    with public, noconstant(" ")
    declare product_barcode_nbr   = c20   with public, noconstant(" ")
    declare product_num_barcode   = vc    with public, noconstant(" ")
    declare special_testing_disp  = vc    with public, noconstant(" ")
 
 
    declare antig_attrib_disp     = vc with protect, noconstant(" ")
    declare antig_only_disp       = vc with protect, noconstant(" ")
    declare attrib_only_disp      = vc with protect, noconstant(" ")
    declare antibdy_disp          = vc with protect, noconstant(" ")
    declare transfusion_disp      = vc with protect, noconstant(" ")
 
    declare txn_disp_size         = i4 with public, noconstant(0)
    declare txn_disp_short        = vc with public, noconstant(" ")
    declare txn_disp_remainder    = vc with public, noconstant(" ")
    declare split_pos             = i4 with public, noconstant(0)
    declare temp_txn_disp         = vc with public, noconstant(" ")
 
    ;The following represent the only Product Attributes to display.  Applicable to each tag.
    declare CMV_NEG_CD            = f8   with Constant(uar_get_code_by("DISPLAYKEY",   1612,"CMVNEGATIVE")),public
    declare DEGLY_CD              = f8   with Constant(uar_get_code_by("DISPLAYKEY",   1612,"DEGLYCEROLIZED")),public
    declare IRRAD_CD              = f8   with Constant(uar_get_code_by("DISPLAYKEY",   1612,"IRRADIATED")),public
    declare HGBS_NEG_CD           = f8   with Constant(uar_get_code_by("DISPLAYKEY",   1612,"HGBSNEG")),public
 
 
    declare 1612_CMVPOS    = f8 with protect, noconstant(uar_get_code_by("DISPLAY",1612,"CMV+"))
;display key for this entry is the same as CMV-,
declare 1612_CMVNEG    = f8 with protect, noconstant(uar_get_code_by("DISPLAY",1612,"CMV-"))
;have to use display instead of display_key
declare 1612_CRYO      = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("CRYOREDUCED")))
declare 1612_DEGLY     = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("DEGLYCEROLIZED")))
declare 1612_HLAMATCH  = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("HLAMATCHED")))
declare 1612_IRRAD     = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("IRRADIATED")))
declare 1612_PLASMAADD = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("PLASMAADDED")))
declare 1612_PLASMARED = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("PLASMAREDUCED")))
declare 1612_PLTRED    = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("PLTSREDUCED")))
declare 1612_THAWED    = f8 with protect, noconstant(uar_get_code_by("DISPLAYKEY",1612, trim("THAWED")))
 
 
/************************/
 
free set tag_addl
record tag_addl
(
   1 tot_tag_cnt              = i4
   1 tag_qual[*]
      2 special_testing_disp  = vc
      2 isbt_barcode          = vc
      2 transfusion_requirements = vc
      2 facility              = vc
      2 fac_cd                = f8
      2 street1               = vc
      2 street2               = vc
      2 street3               = vc
      2 city                  = vc
      2 state                 = vc
      2 zip                   = vc
      2 tot_tag_mrn			  = vc
      2 result_comment        = vc
      2 cur_owner_area_cd = f8
      2 medical_director	  = vc
      2 product_class_cd = f8
   1 tot_tag_mrn              = vc
)
 
set stat = alterlist(tag_addl->tag_qual,value(tot_tag_cnt))
set tag_addl->tot_tag_cnt = tot_tag_cnt
 
declare bus_var = f8 with Constant(uar_get_code_by("MEANING",212,"BUSINESS")),protect
declare num= i4 with protect, noconstant(0)
declare MRN2_VAR = f8 with Constant(uar_get_code_by("MEANING",4,"MRN")),protect
declare cmv_cd = f8 with Constant(uar_get_code_by("DESCRIPTION",1612,"CMV-")),protect
 
SELECT
	D.SEQ
 
FROM
	(DUMMYT   D  WITH SEQ = VALUE(TOT_TAG_CNT))
	, product p
	, location l
	, organization o
 	,address a
 	,code_value_extension cve
 
 
 
PLAN D
 
join p
where p.product_id = tag_request->taglist[d.seq].product_id
join l where l.location_cd = p.cur_inv_area_cd
and l.active_ind = 1
join o where o.organization_id = l.organization_id
and o.active_ind = 1
join a where  a.parent_entity_id = p.cur_owner_area_cd
	   and a.parent_entity_name = "LOCATION"
	   and a.address_type_cd = bus_var
	   and a.ACTIVE_IND = 1
       and a.BEG_EFFECTIVE_DT_TM <= CNVTDATETIME(SYSDATE)
       and a.END_EFFECTIVE_DT_TM >= CNVTDATETIME(SYSDATE)
join cve
	where cve.code_value = outerjoin(p.cur_owner_area_cd)
	  and cve.field_name = outerjoin("BBT Medical Director")
DETAIL
 
   tag_addl->tag_qual[d.seq]->facility = trim(o.org_name)
   tag_addl->tag_qual[d.seq]->street1 = trim(a.street_addr,3)
   tag_addl->tag_qual[d.seq]->fac_cd = p.cur_inv_area_cd
   tag_addl->tag_qual[d.seq]->street2 = trim(a.street_addr2,3)
   tag_addl->tag_qual[d.seq]->street3 = trim(a.street_addr3,3)
   tag_addl->tag_qual[d.seq]->city = trim(a.city,3)
   tag_addl->tag_qual[d.seq]->state = trim(a.state,3)
   tag_addl->tag_qual[d.seq]->zip = trim(a.zipcode,3)
   tag_addl->tag_qual[d.seq]->cur_owner_area_cd = p.cur_owner_area_cd
   tag_addl->tag_qual[d.seq]->medical_director = trim(cve.field_value, 3)
   tag_addl->tag_qual[d.seq]->product_class_cd = p.product_class_cd
 
WITH NOCOUNTER, OUTERJOIN = D
 
 
select into "nl:"
from
    (dummyt d with seq = value(tot_tag_cnt))
    ,special_testing st
    ,code_value cv
plan d
join st
where st.product_id = tag_request->taglist[d.seq].product_id
and st.active_ind = 1
join cv
where cv.code_set=1612 and cv.code_value = st.special_testing_cd
and (CV.CDF_MEANING IN ("+","-") )
OR  (CV.CDF_MEANING ="SPTYP" and St.SPECIAL_TESTING_CD = cmv_cd)
 
 
order
    d.seq
head d.seq
    row+0
detail
    tag_addl->tag_qual[d.seq].special_testing_disp = build(tag_addl->tag_qual[d.seq].special_testing_disp
                                                        ,uar_get_code_display(st.special_testing_cd),",")
 
foot d.seq
    tag_addl->tag_qual[d.seq].special_testing_disp = trim(replace(tag_addl->tag_qual[d.seq].special_testing_disp
                                                        ,",","",2),3) ;replace last comma
    tag_addl->tag_qual[d.seq].special_testing_disp = replace(tag_addl->tag_qual[d.seq].special_testing_disp
                                                        ,",",", ",0) ;add space after each comma
with nocounter
 
select into "nl:"
from
    (dummyt d with seq = value(tot_tag_cnt)),
     bb_isbt_product_type bipt
plan d
join bipt where bipt.product_cd = tag_request->taglist[d.seq]->PRODUCT_CD
 
detail
	tag_addl->tag_qual[d.seq]->isbt_barcode = bipt.isbt_barcode
 
with nocounter
 
select into "nl:"
from
    (dummyt d with seq = value(tot_tag_cnt)),
     person_trans_req ptr,
     transfusion_requirements tr
plan d
join ptr
	where ptr.person_id = tag_request->taglist[d.seq]->person_id
	and ptr.active_ind = 1
join tr
	where ptr.requirement_cd = tr.requirement_cd and tr.active_ind = 1
 
detail
	if (textlen(tag_addl->tag_qual[d.seq]->transfusion_requirements) > 0)
		tag_addl->tag_qual[d.seq]->transfusion_requirements = build2(tag_addl->tag_qual[d.seq]->transfusion_requirements,
		                                                             ", ", tr.description)
	else
		tag_addl->tag_qual[d.seq]->transfusion_requirements = tr.description
	endif
 
with nocounter
 
 
/*****************/
 
/* END ccps_bbt_tag_internal_struct.inc */
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Jul'2019
	Solution:			Pharmacy/Quality
	Source file name:	      cov_pha_synonymId_extract.prg
	Object name:		cov_pha_synonymId_extract
	Request#:			5324
	Program purpose:	      extract of all synonym id's with the Multum class of opioid analgesic to build a separate
					translation table for discharge prescription data
	Executing from:		DA2
 	Special Notes:          One time extract and periodic update on needed basis.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_synonymId_extract:dba go
create program cov_pha_synonymId_extract:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare strength_dose_var  = f8 with constant (12715.00)
declare strength_unit_var  = f8 with constant (12716.00)
declare volume_dose_var    = f8 with constant (12718.00)
declare volume_unit_var    = f8 with constant (12719.00)
 
Record mltum(
	1 rec_cnt = i4
	1 mltlist[*]
		2 drug_id = vc
		2 class1 = f8
		2 class1_desc = vc
		2 class2 = f8
		2 class2_desc = vc
		2 class3 = f8
		2 class3_desc = vc
)
 
Record syno(
	1 list[*]
		2 drug_id = vc
		2 class1 = f8
		2 class1_desc = vc
		2 class2 = f8
		2 class2_desc = vc
		2 class3 = f8
		2 class3_desc = vc
		2 synonym_id = f8
		2 catalog_item = vc
		2 order_sentence_id = f8
		2 oe_format_id = f8
		2 strength = vc
		2 strength_unit = vc
		2 dose = vc
		2 dose_unit = vc
	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get Multum class of opioid analgesic
select into 'nl:'
 
  mcdx.drug_identifier
  ,class_code1 = dc1.multum_category_id
  ,class_description1 = substring (1 ,50 ,dc1.category_name )
  ,class_code2 = dc2.multum_category_id
  ,class_description2 = substring (1 ,50 ,dc2.category_name )
  ,class_code3 = dc3.multum_category_id
  ,class_description3 = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
	and dc1.multum_category_id = 57 ;central nervous system agents
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
	and dc2.multum_category_id = 58 ;analgesics
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = dcs2.sub_category_id
	and dc3.multum_category_id in(60, 191) ;narcotic analgesics; narcotic analgesic combinations
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
 
order by mcdx.drug_identifier
 
Head report
	cnt = 0
	call alterlist(mltum->mltlist, 100)
 
Head mcdx.drug_identifier
	cnt += 1
 	call alterlist(mltum->mltlist, cnt)
Detail
 
	mltum->mltlist[cnt].drug_id = mcdx.drug_identifier
	mltum->mltlist[cnt].class1 = class_code1
	mltum->mltlist[cnt].class1_desc = class_description1
	mltum->mltlist[cnt].class2 = class_code2
	mltum->mltlist[cnt].class2_desc = class_description2
	mltum->mltlist[cnt].class3 = class_code3
	mltum->mltlist[cnt].class3_desc = class_description3
 
Foot report
  	call alterlist(mltum->mltlist, cnt)
 
with nocounter
 
;call echorecord(mltum)
 
 
;------------------------------------------------------------------------------------------------
;Get Synonym id's
 
select into 'nl:'
 
 drug_id = mltum->mltlist[d.seq].drug_id, ocs.synonym_id
, catalog_item = uar_get_code_display(oc.catalog_cd)
, ocs.order_sentence_id, oc.oe_format_id
, osd.oe_field_display_value, osd.oe_field_value
, ofm.description, osd.oe_field_id
 
, class1 =mltum->mltlist[d.seq].class1
, class1_description = trim(substring(1,200,mltum->mltlist[d.seq].class1_desc))
, class2 =mltum->mltlist[d.seq].class2
, class2_description = trim(substring(1,200,mltum->mltlist[d.seq].class2_desc))
, class3 =mltum->mltlist[d.seq].class3
, class3_description = trim(substring(1,200,mltum->mltlist[d.seq].class3_desc))
 
from (dummyt d with seq = value(size(mltum->mltlist, 5)))
	, order_catalog oc
	, order_catalog_synonym ocs
	, order_sentence os
	, order_sentence_detail osd
	, oe_field_meaning ofm
 
plan d
 
join oc where trim(substring(( findstring("!" ,oc.cki) + 1 ) ,textlen(oc.cki) ,oc.cki)) = mltum->mltlist[d.seq].drug_id
	and oc.active_ind = 1
	;andmltum->mltlist[d.seq].drug_id = 'd00017'
 
join ocs where ocs.catalog_cd = oc.catalog_cd
	and ocs.active_ind = 1
	and ocs.active_status_cd = 188
	and ocs.activity_type_cd = 705 ;Pharmacy
	and ocs.order_sentence_id != 0
 
join os where os.order_sentence_id = ocs.order_sentence_id
	and os.oe_format_id = oc.oe_format_id
 
join osd where osd.order_sentence_id = os.order_sentence_id
	and osd.oe_field_id in(strength_dose_var, strength_unit_var, volume_dose_var, volume_unit_var)
	;in(12715, 12716, 12718, 12719)
 
join ofm where ofm.oe_field_meaning_id = osd.oe_field_meaning_id
 
order by drug_id, catalog_item, ocs.order_sentence_id, oc.oe_format_id, osd.oe_field_display_value, osd.oe_field_value
 
Head report
	cnt = 0
	call alterlist(syno->list, 100)
 
Head ocs.order_sentence_id
	cnt += 1
 	call alterlist(syno->list, cnt)
Detail
 
	syno->list[cnt].drug_id = drug_id
	syno->list[cnt].class1 = class1
	syno->list[cnt].class1_desc = class1_description
	syno->list[cnt].class2 = class2
	syno->list[cnt].class2_desc = class1_description
	syno->list[cnt].class3 = class3
	syno->list[cnt].class3_desc = class3_description
	syno->list[cnt].catalog_item = uar_get_code_display(oc.catalog_cd)
	syno->list[cnt].oe_format_id = oc.oe_format_id
	syno->list[cnt].order_sentence_id = ocs.order_sentence_id
	syno->list[cnt].synonym_id = ocs.synonym_id
 
	case(osd.oe_field_id)
		of strength_dose_var:
			syno->list[cnt].strength = osd.oe_field_display_value
		of strength_unit_var:
			syno->list[cnt].strength_unit = osd.oe_field_display_value
		of volume_dose_var:
			syno->list[cnt].dose = osd.oe_field_display_value
		of volume_unit_var:
			syno->list[cnt].dose_unit = osd.oe_field_display_value
	endcase
 
Foot report
  	call alterlist(syno->list, cnt)
 
with nocounter
 
call echorecord(syno)
;---------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	CATALOG_ITEM = SUBSTRING(1, 30, SYNO->list[D1.SEQ].catalog_item)
	, SYNONYM_ID = SYNO->list[D1.SEQ].synonym_id
	, STRENGTH_DOSE = SUBSTRING(1, 30, SYNO->list[D1.SEQ].strength)
	, STRENGTH_DOSE_UNIT = SUBSTRING(1, 30, SYNO->list[D1.SEQ].strength_unit)
	, VOLUME_DOSE = SUBSTRING(1, 30, SYNO->list[D1.SEQ].dose)
	, VOLUME_DOSE_UNIT = SUBSTRING(1, 30, SYNO->list[D1.SEQ].dose_unit)
	, CLASS1 = SYNO->list[D1.SEQ].class1
	, CLASS1_DESCRIPTION = SUBSTRING(1, 30, SYNO->list[D1.SEQ].class1_desc)
	, CLASS2 = SYNO->list[D1.SEQ].class2
	, CLASS2_DESCRIPTION = SUBSTRING(1, 30, SYNO->list[D1.SEQ].class2_desc)
	, CLASS3 = SYNO->list[D1.SEQ].class3
	, CLASS3_DESCRIPTION = SUBSTRING(1, 30, SYNO->list[D1.SEQ].class3_desc)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(SYNO->list, 5))
 
PLAN D1
 
ORDER BY CATALOG_ITEM, SYNONYM_ID
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
end go
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

select distinct catalog = uar_get_code_display(oc.catalog_cd), oci.synonym_id
, identifier_type = uar_get_code_display(oi.identifier_type_cd),identifier = oi.value
, form = uar_get_code_display(md.form_cd), md.strength, strength_unit = uar_get_code_display(md.strength_unit_cd)
, md.volume, volume_unit = uar_get_code_display(md.volume_unit_cd), md.given_strength 
, oc.cki, oci.item_id, oi.identifier_type_cd
from order_catalog oc, order_catalog_item_r oci, object_identifier_index oi,medication_definition md ;(have strength and volume)
where oc.cki = 'MUL.ORD!d03428'
and oci.catalog_cd = oc.catalog_cd
and oci.catalog_cd = 2748200.00
and md.item_id = oci.item_id
and oi.object_id = oci.item_id
and oi.identifier_type_cd = 3096


 
select * from medication_definition md where md.cki = 'MUL.FRMLTN!2313'

;item_id = object_id
select * from object_identifier_index oi where oi.object_id in(77723207.00,   79784193.00)
and oi.identifier_type_cd = 3096

select * from medication_definition md where md.cki = 'MUL.ORD!d03428'

select * from order_catalog oc where oc.cki = 'MUL.ORD!d03428'

select * from order_catalog_item_r oci where oci.catalog_cd = 2748200.00


select form = uar_get_code_display(md.form_cd), md.* from medication_definition md where md.item_id in(
   77352954.00,
   77353003.00,
   77353211.00,
   77353315.00,
   77352848.00,
   77353476.00,
   77353421.00,
   78294357.00,
   77353260.00,
   77353368.00,
   77353107.00,
   77352901.00,
   77353052.00,
   77353580.00,
   77353160.00,
   77353529.00)


;item_id = object_id
select * from object_identifier_index oi where oi.object_id in(77723207.00,   79784193.00)
and oi.identifier_type_cd = 3096
  
MUL.ORD!d05355

MUL.FRMLTN!2313
MUL.FRMLTN!28112
MUL.FRMLTN!8387
MUL.FRMLTN!27192
MUL.FRMLTN!6767

select * from order_sentence os where os.order_sentence_id = 2560988775.00
 
select * from order_sentence os where os.external_identifier = 'd00017'
 
select * from order_catalog_synonym ocs where ocs.synonym_id in(2762830.00, 2762831.00)
 
select * from order_sentence os where os.order_sentence_id = 44353541.00
 
select distinct os.order_sentence_id from order_sentence os where os.oe_format_id = 273220713.00
**every format_id have 1000's of sentence_id
 
select * from order_sentence_detail osd where osd.order_sentence_id = 44353541.00
 
select * from oe_format_fields of1 where of1.oe_format_id = 273220697 ;273220713.00
 
select * from order_sentence_detail osd where osd.oe_field_id in(12715) ;, 12716, 12718, 12719)
 
select * from order_sentence_detail osd where osd.order_sentence_id =      273923769.00
and osd.oe_field_id in(12715, 12716, 12718, 12719)
 
select * from oe_field_meaning ofm where ofm.oe_field_meaning_id in(2050.00,2058.00, 2059.00, 2043.00, 2044.00, 2014.00)
 
select * from alt_sel_list asl where asl.synonym_id =   202016265.00
 
select * from alt_sel_cat al where al.alt_sel_category_id in(632464.00, 632526.00)
 
 select identifier_type = uar_get_code_display(oi.identifier_type_cd), oi.identifier_type_cd ,oi.* 
from object_identifier_index oi where oi.object_id = 77892334.00

       3096.00	Charge Number	CDM	Charge Number

;You would just add another oii (oii5) table for the Charge Number identifier.  The identifier_type_cd should be available in code set 11000.
 
;UCern query to find CDM
SELECT

item_nbr = oii.value
, mfg_catalog_nbr = oii3.value
, upn = oii4.value
, cdm = oii5.value

FROM
  object_identifier_index   oii
, object_identifier_index   oii2
, object_identifier_index   oii3
, object_identifier_index   oii4
, object_identifier_index   oii5

plan oii where oii.generic_object=0.00 
	and oii.identifier_type_cd=3101.00   ;item number code set 11001
	and oii.object_id in (select oii.object_id from object_identifier_index oii
		where oii.generic_object=0.00 
		and oii.object_type_cd in (3119.00, 3117.00, 3122.00)    ;item master, equip master, and med def in 11001
		and oii.identifier_type_cd in (3103.00)    ;manuf item number code set 11000
		group by oii.object_id
		having count(*) > 1)

join oii2 where oii2.generic_object=0.00 
	and oii2.object_id=oii.object_id 
	and oii2.identifier_type_cd=3103.00 ;manuf item number code set 11000
	and oii2.object_type_cd in (3119.00, 3117.00, 3122.00)

join oii3 where oii3.generic_object=0.00
	and oii3.object_type_cd = 3121.00 ; manf item type cd from 11001
	and oii3.identifier_id=oii2.identifier_id

join oii4 where outerjoin(oii3.object_id)=oii4.object_id 
	and oii4.generic_object=outerjoin(0.00)
	and oii4.identifier_type_cd=outerjoin(638956.00) ;upn from code set 11000

join oii5 where outerjoin(oii3.object_id)=oii4.object_id 
	and oii5.generic_object=outerjoin(0.00)
	and oii5.identifier_type_cd=outerjoin(3096.00) ;CDM type cd from code set 11000

ORDER BY ITEM_NBR, MFG_CATALOG_NBR, UPN, CDM


  


 

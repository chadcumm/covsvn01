/***********************Change Log*************************
VERSION 	 DATE       ENGINEER            COMMENT
-------	 	-------    	-----------         ------------------------
0.1			10/26/2017	Ryan Gotsche		Development
1.0			11/2/2017	Ryan Gotsche		Initial Release
2.0			2/6/2018	Ryan Gotsche		CR-1382, do not include immunizations in this smart template.
3.0			3/14/2018	Ryan Gotsche		CR-1382, change output format to match that of idn_st_amb_immu_admin
4.0			4/5/2018	Ryan Gotsche		CR-1382, logic changes due to AMB lot nbr and expire date.
5.0			8/1/2018	Ryan Gotsche		CR-2867, logic for when IMMUNIZATIONIND not defined at all
6.0               8/15/2018   Geetha Saravanan        CR-3042, Non-formulary med name and dosage not showing up
7.0               11/06/2018  Geetha Saravanan        CR-3687, update for injection documentation for diluents
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - This Custom Smart Template will pull in information
	related to the medication administration to the encounter
	that is being documented on.
 
Tables Read: ORDERS, CLINICAL_EVENT, CE_MED_RESULT, PRSNL
 
Tables Updated: None
 
Scripts Executed: None
**************************************************************/
drop program cov_idn_st_amb_meds_admin:dba go
create program cov_idn_st_amb_meds_admin:dba
 
/****************************************************************************
*       Request record                                                      *
*****************************************************************************/
/*The embedded RTF commands at top of document */
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
set rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}",
    "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134 ")
/*The end of line embedded RTF command */
set Reol = "\par "
/*The tab embedded RTF command */
set Rtab = "\tab "
/*the embedded RTF commands for normal word(s) */
set wr = "\plain \f0 \fs18 \cb2 "
/*the embedded RTF commands for bold word(s) */
set wb = "\plain \f0 \fs18 \b \cb2 "
/*the embedded RTF commands for stike-thru word(s) */
set ws = "\plain \f0 \fs18 \strike \cb2 "
/*the embedded RTF command for hanging indent */
set hi = "\pard\fi-2340\li2340 "
/*the embedded RTF commands to end the document*/
set rtfeof = "}"
/*the embedded RTF commands for bold & underline & font26 word(s) */
set wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
/*The embedded RTF command for resetting paragraph-formatting attributes to their default value */
set rpard = "\pard "
/*the embedded RTF commands for underlined, bold word(s) */
set wbu = "\plain \f0 \fs18 \b \ul \cb2 "
;%i rtf_commands.inc ;saved in CCLUSERDIR on all nodes
record reply
( 1 text = vc
%i cclsource:status_block.inc
)
/****************************************************************************
*       Problem data record                                                 *
*****************************************************************************/
/****************************************************************************
*       Problem data record                                                 *
*****************************************************************************/
record medsadmin_struc
( 1 data[*]
    2 order_id = f8
    2 encntrid = f8
    2 personid = f8
    2 medication_name = vc
    2 diluent = vc
    2 diluent_dose = vc
    2 diluent_unit = vc
    2 name_full_format = vc
    2 prsnl_id = f8
    2 event_id = f8
    2 text = vc
    2 amb_lot_nbr = vc
    2 manufact = vc
    2 amb_substance_expire_date = vc
    2 admin_date = vc
    2 admin_dose = vc
    2 admin_volume = vc
    2 admin_unit = vc
    2 admin_dose_unt = vc
    2 admin_route = vc
    2 admin_site = vc
    2 order_date = vc
    2 order_status = vc
    2 admin_start_tm = vc
    2 admin_end_tm = vc
)
 
 
/****************************************************************************
*       Declare Variables                                                   *
*****************************************************************************/
declare 106_PHARMACY = f8 with public, constant(uar_get_code_by_cki("CKI.CODEVALUE!2825"))
declare 6004_COMPLETE = f8 with public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100"))
declare 72_AMBLOTNBR = f8 with public, Constant(uar_get_code_by("DISPLAYKEY",72,"AMBONLYLOTNUMBER")),protect ;v4.0
declare 72_AMBEXPIREDATE = f8 with Constant(uar_get_code_by("DISPLAYKEY",72,"AMBONLYEXPIRATIONDATEMMYY")),protect ;v4.0
 
declare medsCnt = i4 with noconstant(0)
declare comCnt = i4 with noconstant(0)
declare cnt = i4 with noconstant(0)
 
/****************************************************************************
*       Retrieve the Meds Admin information                                    *
*****************************************************************************/
 
select distinct into 'nl:'
od.encntr_id, od.order_id
 
from
 
code_value cv
 
, (left join code_value_extension cx on (cx.code_value = cv.code_value
	and cx.code_set = cv.code_set
	and cx.field_name = "IMMUNIZATIONIND"
	and cx.field_value != "1"))
, orders od
 
plan cv where cv.code_set = 200
	and cv.active_ind = 1
	and cv.end_effective_dt_tm > sysdate
 
join cx
 
join od where od.catalog_cd = cv.code_value
	and od.encntr_id = request->visit[1].encntr_id ;110456652.00
	and od.activity_type_cd = 106_PHARMACY
	and od.order_status_cd = 6004_COMPLETE
	and od.active_ind = 1
 
order by od.order_id
 
 
Head report
  medsCnt = 0
 
Head od.order_id
  medsCnt = medsCnt + 1
  stat = alterlist(medsadmin_struc->data,medsCnt)
 
Detail
 
 if(od.order_id !=0)
 	if(od.order_mnemonic = 'template non-formulary (medication)')
		medsadmin_struc->data[medsCnt].medication_name = trim(od.ordered_as_mnemonic)
	else
		medsadmin_struc->data[medsCnt].medication_name = trim(od.order_mnemonic)
	endif
	medsadmin_struc->data[medsCnt].order_id = od.order_id
	medsadmin_struc->data[medsCnt].encntrid = od.encntr_id
	medsadmin_struc->data[medsCnt].personid = od.person_id
	medsadmin_struc->data[medsCnt].order_date = format(od.orig_order_dt_tm, "mm/dd/yyyy")
	medsadmin_struc->data[medsCnt].order_status = trim(uar_get_code_display(od.order_status_cd),3)
else
 
 	if(od.order_mnemonic = 'template non-formulary (medication)')
		medsadmin_struc->data[medsCnt].medication_name = trim(od.ordered_as_mnemonic)
	else
		medsadmin_struc->data[medsCnt].medication_name = trim(od.order_mnemonic)
	endif
	medsadmin_struc->data[medsCnt].encntrid = od.encntr_id
	medsadmin_struc->data[medsCnt].personid = od.person_id
	medsadmin_struc->data[medsCnt].order_date = format(od.orig_order_dt_tm, "mm/dd/yyyy")
	medsadmin_struc->data[medsCnt].order_status = trim(uar_get_code_display(od.order_status_cd),3)
 endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------------------------
 
if(medsCnt > 0)
; get clinical & med details
 
select distinct into 'nl:'
 
ce.order_id, ce.event_title_text, ce.event_id, c.diluent_type_cd, d_type = uar_get_code_display(c.diluent_type_cd)
 
from
 
(dummyt d with seq = value(medsCnt))
, clinical_event ce
, ce_med_result c
, prsnl p
 
plan d
 
join ce where ce.order_id = medsadmin_struc->data[d.seq].order_id
	and ce.person_id = medsadmin_struc->data[d.seq].personid
	and ce.encntr_id = medsadmin_struc->data[d.seq].encntrid
	and ce.event_class_cd = 232.00 ;MED
 
join c where c.event_id = ce.event_id
 
join p where p.person_id = c.updt_id
 
order by ce.order_id
 
 
Head ce.order_id
  cnt = 0
  idx = 0
  idx = locateval(cnt,1,size(medsadmin_struc->data,5),ce.order_id, medsadmin_struc->data[cnt].order_id)
 
Detail
 
	if(medsadmin_struc->data[d.seq].order_id !=0)
	 	medsadmin_struc->data[idx].admin_volume = cnvtstring(c.infused_volume)
	      medsadmin_struc->data[idx].admin_unit = trim(uar_get_code_display(c.infused_volume_unit_cd))
		medsadmin_struc->data[idx].name_full_format = trim(p.name_full_formatted)
		medsadmin_struc->data[idx].admin_date = format(c.valid_from_dt_tm, "mm/dd/yyyy")
		medsadmin_struc->data[idx].admin_route = trim(uar_get_code_display(c.admin_route_cd),3)
		medsadmin_struc->data[idx].admin_site = trim(uar_get_code_display(c.admin_site_cd),3)
		medsadmin_struc->data[idx].admin_dose = cnvtstring(c.admin_dosage,8,2)
		medsadmin_struc->data[idx].admin_dose_unt = trim(uar_get_code_display(c.dosage_unit_cd),3)
		medsadmin_struc->data[idx].admin_start_tm = format(c.admin_start_dt_tm, "mm/dd/yyyy hh:mm")
		medsadmin_struc->data[idx].admin_end_tm = format(c.admin_end_dt_tm, "mm/dd/yyyy hh:mm")
		medsadmin_struc->data[idx].event_id = ce.event_id
	else
	      medsadmin_struc->data[idx].admin_volume = cnvtstring(c.infused_volume)
	      medsadmin_struc->data[idx].admin_unit = trim(uar_get_code_display(c.infused_volume_unit_cd))
		medsadmin_struc->data[idx].name_full_format = trim(p.name_full_formatted)
		medsadmin_struc->data[idx].admin_date = format(c.valid_from_dt_tm, "mm/dd/yyyy")
		medsadmin_struc->data[idx].admin_route = trim(uar_get_code_display(c.admin_route_cd),3)
		medsadmin_struc->data[idx].admin_site = trim(uar_get_code_display(c.admin_site_cd),3)
		medsadmin_struc->data[idx].admin_dose = cnvtstring(c.admin_dosage,8,2)
		medsadmin_struc->data[idx].admin_dose_unt = trim(uar_get_code_display(c.dosage_unit_cd),3)
		medsadmin_struc->data[idx].admin_start_tm = format(c.admin_start_dt_tm, "mm/dd/yyyy hh:mm")
		medsadmin_struc->data[idx].admin_end_tm = format(c.admin_end_dt_tm, "mm/dd/yyyy hh:mm")
		medsadmin_struc->data[idx].event_id = ce.event_id
	endif
 
Foot ce.order_id
	null
 
with nocounter
 
;------------------------------------------------------------------------------------------------
 
;get Diluent details
select distinct into 'nl:'
 
from
 
(dummyt d with seq = value(medsCnt))
, clinical_event ce
, ce_med_result c
 
plan d
 
join ce where ce.order_id = medsadmin_struc->data[d.seq].order_id
	and ce.person_id = medsadmin_struc->data[d.seq].personid
	and ce.encntr_id = medsadmin_struc->data[d.seq].encntrid
	and ce.event_class_cd = 232.00 ;MED
 
join c where c.event_id = ce.event_id
	and c.diluent_type_cd != 0
 
order by ce.order_id
 
 
Head ce.order_id
  cnt = 0
  idx = 0
  idx = locateval(cnt,1,size(medsadmin_struc->data,5),ce.order_id, medsadmin_struc->data[cnt].order_id)
 
Detail
 
if(c.diluent_type_cd != 0.00)
	medsadmin_struc->data[idx].diluent = uar_get_code_display(c.diluent_type_cd)
	medsadmin_struc->data[idx].diluent_dose = cnvtstring(c.admin_dosage,4,2)
	medsadmin_struc->data[idx].diluent_unit = uar_get_code_display(c.dosage_unit_cd)
endif

 
with nocounter
 
call echorecord(medsadmin_struc)
 
endif ;medsCnt
 
;--------------------------------------------------------------------------------------------------------------
 
 
;Version 4 Subtraction
/*
if (medsCnt > 0)
  select into "nl:"
  from (dummyt d with seq = value(medsCnt)),
    orders dod
    , clinical_event   dce
	, ce_med_result   dc
	, prsnl  dp
  plan d
  join dod
    where dod.order_id = medsadmin_struc->data[d.seq].order_id
  join dce
  	where dce.order_id = medsadmin_struc->data[d.seq].order_id
  join dc
  	where dc.event_id = medsadmin_struc->data[d.seq].event_id
  join dp
  	where dp.person_id = medsadmin_struc->data[d.seq].prsnl_id
  detail
 
    medsadmin_struc->data[d.seq].text = concat(medsadmin_struc->data[d.seq].text,dod.order_id)
    medsadmin_struc->data[d.seq].text = concat(medsadmin_struc->data[d.seq].text,trim(dod.order_mnemonic))
    medsadmin_struc->data[d.seq].text = concat(medsadmin_struc->data[d.seq].text,trim(dp.name_full_formatted))
    medsadmin_struc->data[d.seq].text = replace(medsadmin_struc->data[d.seq].text,char(10)," \par ")
    medsadmin_struc->data[d.seq].text = replace(medsadmin_struc->data[d.seq].text,char(13)," ")
  with nocounter
endif
*/
;Version 4 Addition
if (medsCnt > 0)
  select into "nl:"
  from (dummyt d with seq = value(medsCnt)),
   clinical_event   dce
  plan d
  join dce
  	where dce.order_id =  medsadmin_struc->data[d.seq].order_id
  detail
  	if(dce.event_cd = 72_AMBLOTNBR)
   		medsadmin_struc->data[d.seq].amb_lot_nbr = trim(dce.result_val)
 
    elseif(dce.event_cd = 72_AMBEXPIREDATE)
    	medsadmin_struc->data[d.seq].amb_substance_expire_date = concat(dce.result_val)
    endif
    medsadmin_struc->data[d.seq].text = replace(medsadmin_struc->data[d.seq].text,char(10)," \par ")
    medsadmin_struc->data[d.seq].text = replace(medsadmin_struc->data[d.seq].text,char(13)," ")
  with nocounter
endif
 
/****************************************************************************
*       Build the display                                                   *
*****************************************************************************/
; If the above query returned no data, write out "No Data Available"
if(medsCnt < 1)
  ;set reply->text = concat(rhead,wr,"No qualifying data available",reol)
  set reply->text = concat("")
  go to exit_script
 
endif
 
set reply->text = concat(rhead, wr)
for (x = 1 to medsCnt)
  if (medsadmin_struc->data[x].text > "")
    set reply->text = concat(reply->text,Reol,wbuf26,"Order:",wr," ",wr,medsadmin_struc->data[x].medication_name, Reol
    									,Rtab,wb,"Dose: ",wr,medsadmin_struc->data[x].admin_dose," ",medsadmin_struc->data[x].
    											admin_dose_unt," | ",
    										wb,"Volume: ",wr,medsadmin_struc->data[x].admin_volume," ", ;v6.0
    										wr,medsadmin_struc->data[x].admin_unit," | ", ;v6.0
    										wb,"Route: ",wr,medsadmin_struc->data[x].admin_route," | ",
    										wb,"Site: ",wr,medsadmin_struc->data[x].admin_site,reol
    									,Rtab,wb,"Diluent: ",wr,medsadmin_struc->data[x].diluent, " "
    										,medsadmin_struc->data[x].diluent_dose, " "
   										,medsadmin_struc->data[x].diluent_unit,reol
    									,Rtab,wb,"Order Date: ",wr,medsadmin_struc->data[x].order_date," | ",
    										wb,"Order Status: ",wr,medsadmin_struc->data[x].order_status,reol
    									,Rtab,wb,"Administered By: ",wr,medsadmin_struc->data[x].name_full_format," | ",
    										wb,"Administered Date: ",wr,medsadmin_struc->data[x].admin_date,reol
    									,Rtab,wb,"Admin Start Time: ",wr,medsadmin_struc->data[x].admin_start_tm," | ",
    										wb,"Admin End Time: ",wr,medsadmin_struc->data[x].admin_end_tm,reol
    									,Rtab,wb,"Expiration Date: ",wr,medsadmin_struc->data[x].amb_substance_expire_date," | ",
    									;	wb,"Manufacturer: ",wr,medsadmin_struc->data[x].manufact," | ", v3.0
    										wb,"Lot Number: ",wr,medsadmin_struc->data[x].amb_lot_nbr,reol,
    										rpard)
  else
    set reply->text = concat(reply->text,Reol,wbuf26,"Order:",wr," ",wr,medsadmin_struc->data[x].medication_name, Reol
    									,Rtab,wb,"Dose: ",wr,medsadmin_struc->data[x].admin_dose," ",medsadmin_struc->data[x].
    											admin_dose_unt," | ",
    										wb,"Volume: ",wr,medsadmin_struc->data[x].admin_volume," ", ;v6.0
    										wr,medsadmin_struc->data[x].admin_unit," | ", ;v6.0
    										wb,"Route: ",wr,medsadmin_struc->data[x].admin_route," | ",
    										wb,"Site: ",wr,medsadmin_struc->data[x].admin_site,reol
    									,Rtab,wb,"Diluent: ",wr,medsadmin_struc->data[x].diluent, " "
    										,medsadmin_struc->data[x].diluent_dose, " "
    										,medsadmin_struc->data[x].diluent_unit,reol
    									,Rtab,wb,"Order Date: ",wr,medsadmin_struc->data[x].order_date," | ",
    										wb,"Order Status: ",wr,medsadmin_struc->data[x].order_status,reol
    									,Rtab,wb,"Administered By: ",wr,medsadmin_struc->data[x].name_full_format," | ",
    										wb,"Administered Date: ",wr,medsadmin_struc->data[x].admin_date,reol
    									,Rtab,wb,"Admin Start Time: ",wr,medsadmin_struc->data[x].admin_start_tm," | ",
    										wb,"Admin End Time: ",wr,medsadmin_struc->data[x].admin_end_tm,reol
    									,Rtab,wb,"Expiration Date: ",wr,medsadmin_struc->data[x].amb_substance_expire_date," | ",
    									;	wb,"Manufacturer: ",wr,medsadmin_struc->data[x].manufact," | ", v3.0
    										wb,"Lot Number: ",wr,medsadmin_struc->data[x].amb_lot_nbr,reol,
    										rpard)
 
  endif
endfor
 
 
#EXIT_SCRIPT
set reply->text = concat(reply->text,rtfeof)
 
call echo(reply->text)
 
 
/*Query for validation in future
 
select distinct cv.code_value, cv.display
from
	code_value cv
	, code_value_extension cx
	, order_catalog_synonym ocs
plan cv
where cv.code_set = 200
and cv.active_ind = 1
and cv.end_effective_dt_tm > sysdate
;Immunization Logic
join cx
where cx.code_set = cv.code_set
and cx.code_value = cv.code_value
and cx.field_name = "IMMUNIZATIONIND"
and cx.field_value != "1"
join ocs
where ocs.catalog_cd = cx.code_value
and ocs.activity_type_cd = value(uar_get_code_by("MEANING",106,"PHARMACY"))
and ocs.active_ind = 1
and ocs.synonym_id in
(select synonym_id from ocs_facility_r
where facility_cd in (
select code_value from code_value
where code_set = 220
and display_key = "CLINTON*"))
*/
end
go

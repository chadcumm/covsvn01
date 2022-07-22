/***********************Change Log*************************
VERSION 	 DATE       ENGINEER            COMMENT
-------	 	-------    	-----------         ------------------------
1.0			2/12/2018	Ryan Gotsche		CR-1382, Smart Template only to return immunizations administered.
2.0			3/7/2018	Ryan Gotsche		CR-1382, Clarification on output/format
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - This Custom Smart Template will pull in information
	related to the medication administration to the encounter
	that is being documented on.
 
Tables Read: ORDERS, CLINICAL_EVENT, CE_MED_RESULT, PRSNL
 
Tables Updated: None
 
Scripts Executed: None
**************************************************************/
drop program idn_st_amb_immu_admin:dba go
create program idn_st_amb_immu_admin:dba
 
/****************************************************************************
*       Request record                                                      *
*****************************************************************************/
/*The embedded RTF commands at top of document */
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
record medsadmin_struc
( 1 data[*]
    2 order_id = f8
    2 medication_name = vc
    2 name_full_format = vc
    2 prsnl_id = f8
    2 event_id = f8
    2 text = vc
    2 lot_nbr = vc
    2 manufact = vc
    2 substance_expire_date = vc
    2 admin_date = vc
    2 admin_dose = vc
    2 admin_dose_unt = vc
    2 admin_route = vc
    2 admin_site = vc
    2 order_date = vc
    2 order_status = vc
)
 
/****************************************************************************
*       Declare Variables                                                   *
*****************************************************************************/
declare 106_PHARMACY = f8 with public, constant(uar_get_code_by_cki("CKI.CODEVALUE!2825"))
declare 6004_COMPLETE = f8 with public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100"))
declare medsCnt = i4 with noconstant(0)
declare comCnt = i4 with noconstant(0)
 
/****************************************************************************
*       Retrieve the Meds Admin information                                    *
*****************************************************************************/
select distinct into "nl:"
 
from
	code_value cv
	, code_value_extension cx
	, orders od
	, clinical_event   ce
	, ce_med_result   c
	, prsnl   p
 
plan cv
where cv.code_set = 200
and cv.active_ind = 1
and cv.end_effective_dt_tm > sysdate
;Immunization Logic
join cx
where cx.code_set = cv.code_set
and cx.code_value = cv.code_value
and cx.field_name = "IMMUNIZATIONIND"
and cx.field_value = "1"
join od
where od.catalog_cd = cx.code_value
and od.encntr_id = request->visit[1].encntr_id
and od.activity_type_cd = 106_PHARMACY
and od.order_status_cd = 6004_COMPLETE
and od.active_ind = 1
join ce
where ce.order_id = od.order_id
and ce.person_id = od.person_id
and ce.encntr_id = od.encntr_id
join c
where c.event_id = ce.event_id
join p
where p.person_id = c.updt_id
order by od.order_id
detail
  medsCnt = medsCnt + 1
  stat = alterlist(medsadmin_struc->data,medsCnt)
 
 if(od.order_id !=0)
  medsadmin_struc->data[medsCnt].medication_name = trim(od.order_mnemonic)
  medsadmin_struc->data[medsCnt].name_full_format = trim(p.name_full_formatted)
  medsadmin_struc->data[medsCnt].lot_nbr = trim(c.substance_lot_number)
  medsadmin_struc->data[medsCnt].manufact = trim(uar_get_code_display(c.substance_manufacturer_cd),3)
  medsadmin_struc->data[medsCnt].substance_expire_date = format(c.substance_exp_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].admin_date = format(c.valid_from_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].admin_route = trim(uar_get_code_display(c.admin_route_cd),3)
  medsadmin_struc->data[medsCnt].admin_site = trim(uar_get_code_display(c.admin_site_cd),3)
  medsadmin_struc->data[medsCnt].admin_dose = cnvtstring(c.admin_dosage,4,2)
  medsadmin_struc->data[medsCnt].admin_dose_unt = trim(uar_get_code_display(c.dosage_unit_cd),3)
  medsadmin_struc->data[medsCnt].order_date = format(od.orig_order_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].order_status = trim(uar_get_code_display(od.order_status_cd),3)
 
 else
  medsadmin_struc->data[medsCnt].medication_name = trim(od.order_mnemonic)
  medsadmin_struc->data[medsCnt].name_full_format = trim(p.name_full_formatted)
  medsadmin_struc->data[medsCnt].lot_nbr = trim(c.substance_lot_number)
  medsadmin_struc->data[medsCnt].manufact = trim(uar_get_code_display(c.substance_manufacturer_cd),3)
  medsadmin_struc->data[medsCnt].substance_expire_date = format(c.substance_exp_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].admin_date = format(c.valid_from_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].admin_route = trim(uar_get_code_display(c.admin_route_cd),3)
  medsadmin_struc->data[medsCnt].admin_site = trim(uar_get_code_display(c.admin_site_cd),3)
  medsadmin_struc->data[medsCnt].admin_dose = cnvtstring(c.admin_dosage,4,2)
  medsadmin_struc->data[medsCnt].admin_dose_unt = trim(uar_get_code_display(c.dosage_unit_cd),3)
  medsadmin_struc->data[medsCnt].order_date = format(od.orig_order_dt_tm, "mm/dd/yyyy")
  medsadmin_struc->data[medsCnt].order_status = trim(uar_get_code_display(od.order_status_cd),3)
 endif
with nocounter
 
 
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
    										wb,"Route: ",wr,medsadmin_struc->data[x].admin_route," | ",
    										wb,"Site: ",wr,medsadmin_struc->data[x].admin_site,reol
    									,Rtab,wb,"Order Date: ",wr,medsadmin_struc->data[x].order_date," | ",
    										wb,"Order Status: ",wr,medsadmin_struc->data[x].order_status,reol
    									,Rtab,wb,"Administered By: ",wr,medsadmin_struc->data[x].name_full_format," | ",
    										wb,"Administered Date: ",wr,medsadmin_struc->data[x].admin_date,reol
    									,Rtab,wb,"Expiration Date: ",wr,medsadmin_struc->data[x].substance_expire_date," | ",
    										wb,"Manufacturer: ",wr,medsadmin_struc->data[x].manufact," | ",
    										wb,"Lot Number: ",wr,medsadmin_struc->data[x].lot_nbr,reol,
    										rpard)
  else
    set reply->text = concat(reply->text,Reol,wbuf26,"Order:",wr," ",wr,medsadmin_struc->data[x].medication_name, Reol
    									,Rtab,wb,"Dose: ",wr,medsadmin_struc->data[x].admin_dose," ",medsadmin_struc->data[x].
    											admin_dose_unt," | ",
    										wb,"Route: ",wr,medsadmin_struc->data[x].admin_route," | ",
    										wb,"Site: ",wr,medsadmin_struc->data[x].admin_site,reol
    									,Rtab,wb,"Order Date: ",wr,medsadmin_struc->data[x].order_date," | ",
    										wb,"Order Status: ",wr,medsadmin_struc->data[x].order_status,reol
    									,Rtab,wb,"Administered By: ",wr,medsadmin_struc->data[x].name_full_format," | ",
    										wb,"Administered Date: ",wr,medsadmin_struc->data[x].admin_date,reol
    									,Rtab,wb,"Expiration Date: ",wr,medsadmin_struc->data[x].substance_expire_date," | ",
    										wb,"Manufacturer: ",wr,medsadmin_struc->data[x].manufact," | ",
    										wb,"Lot Number: ",wr,medsadmin_struc->data[x].lot_nbr,reol,
    										rpard)
 
  endif
endfor
 
#EXIT_SCRIPT
set reply->text = concat(reply->text,rtfeof)
 
call echo(reply->text)
 
end
go

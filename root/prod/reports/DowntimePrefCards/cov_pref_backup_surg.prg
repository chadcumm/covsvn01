/************************** Program Header ******************************************************************
 
Report Name: 		cov_pref_backup_surg.PRG
Object Name: 		cov_pref_backup_surg
 
Development Date:  	March 2018
 
Author:  			Alix Govatsos
 
Report Description: Retrieves surgical preferences for surgeons
 
/************************************************************************************************************
*                       MODIFICATION CONTROL LOG		                             						*
*************************************************************************************************************
*                                                                                    						*
Mod Date       Worker        Comment                                                 						*
--- ---------- ------------- -------------------------------------------------------------------------------*
001 12/18/2011 Alix Govatsos  Initial Development (finalized by Brad Weaver)
002 11/20/2018 Dawn Greer, DBA Fixed errors.
003 11/30/2018 Dawn Greer, DBA Added Morristown Hamblen (MHHS) Ambulatory Surgery	
004 01/15/2019 Dawn Greer, DBA Changed the folder for MHHS Ambulatory Surgery to MHAS_Ambulatory
*************************************************************************************************************/
 
drop program 	cov_pref_backup_surg go
create program 	cov_pref_backup_surg
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility Code:" = ""
 
with OUTDEV, pfacility
 
DECLARE FAC_VAR = c2
 
SET OcfCD = 0.0
Set stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,OcfCD)
set BlobOut= fillstring( 32768, " " )				;002 - Changed from ' ' to " "
set BlobNoRTF =  fillstring( 32768, " " )			;002 - Changed from ' ' to " "
set bsize = 0
 
if(substring(1,1,reflect(parameter(parameter2($pfacility),0))) = "L") ;multiple dispositions were selected
	set FAC_VAR = "IN"
	elseif(parameter(parameter2($pfacility),1) = 0.0) ;all (any) dispositions were selected
		set FAC_VAR = "!="
	else ;a single value was selected
		set FAC_VAR = "="
endif
 
 
;declare comment = c5000 with noconstant(fillstring(5000," "))
 
record output (
	1 temp = vc
	1 locator = vc
	1 filename = vc
	1 directory_m = vc  ;methodist
	1 directory_r = vc	;roane
	1 directory_p = vc	;parkwest
	1 directory_l = vc	;leconte
	1 directory_h = vc  ;morristown
	1 directory_s = vc  ;fort sanders
	1 directory_n = vc ; fort loudoun
	1 directory_a = vc ;Morristown Amublatory Surgery		;003 - Added ;004 - changed to a from ha
	1 list[*]
		2 prsnl_id = f8
		2 service_resource = vc
		2 resource_key = vc
		2 resource_cd = f8
		2 org		= vc
		2 resource = vc
		2 filename = vc
		2 surg_area_disp = vc
		2 name_full_formatted = vc
		2 facility_cd = f8
		2 procedure = vc
		2 proc_title = vc
		2 procedure_cd = f8
		2 pref_card_id = f8
)
 
 
set output->directory_m = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/Methodist/"
set output->directory_r = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/Roane/"
set output->directory_p = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/Parkwest/"
set output->directory_l = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/LeConte/"
set output->directory_h = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/Morristown/"
set output->directory_s = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/FortSanders/"
set output->directory_n = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/Loudoun/"
;003 - Added MHHS_Ambulatory below
;004 - Changed folder name
set output->directory_a = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PreferenceCards/MHAS_Ambulatory/"
 
 
select distinct into "nl:"
;SELECT distinct INTO VALUE ($OUTDEV)
 
 service_resource = uar_get_code_display (sr.service_resource_cd)
,surgeon = pr.name_full_formatted
,procedure = uar_get_code_display(pc.catalog_cd)
,pref_card_id = pc.pref_card_id
,proc_title = cp.display_key
,org = trim(o.org_name,3)
 
 
FROM
	  service_resource   sr
	, organization o
	, location_group   lg
	, code_value   cv
	, preference_card   pc
	, code_value cp
	, prsnl   pr
	, person   p
 
where sr.service_resource_type_cd+0  in ( 840, 841, 842) ; code_set 223 ;= 660
  and sr.active_ind = 1
  and sr.service_resource_cd+0 = cv.code_value
  and cv.code_set+0 = 221
  and cv.active_ind = 1
  and operator(substring(1,3,cnvtupper(cv.display_key)) ,FAC_VAR, $pfacility)	;002 - Change $pfacility to match case
  and o.organization_id = sr.organization_id
  and sr.location_cd = lg.child_loc_cd
  and sr.service_resource_cd = pc.surg_area_cd
  and pc.active_ind = 1
 
  and pc.prsnl_id = pr.person_id
  and pr.person_id = p.person_id
  and cp.code_value = pc.catalog_cd
  and pr.active_ind = 1
  and p.active_ind = 1
 
 
ORDER BY
 o.org_name
,sr.service_resource_cd
,pr.name_full_formatted
,pc.catalog_cd
,pc.pref_card_id
 
 
head report
  cnt=0
 
head pc.pref_card_id
 if (pc.prsnl_id > 0)
  cnt=cnt+1
  stat = alterlist(output->list, cnt)
  output->list[cnt].prsnl_id 		= pc.prsnl_id
  output->list[cnt].resource_key	= cv.display_key
  output->list[cnt].facility_cd 	= lg.parent_loc_cd
  output->list[cnt].service_resource = uar_get_code_display(sr.service_resource_cd)
  output->list[cnt].resource_cd 	= sr.service_resource_cd
  output->list[cnt].org				= org
  output->list[cnt].resource 		= trim (cv.display, 3)
  output->list[cnt].facility_cd 	= lg.parent_loc_cd
  output->list[cnt].procedure	 	= trim (uar_get_code_display (pc.catalog_cd), 3)
  output->list[cnt].procedure_cd 	= pc.catalog_cd
  output->list[cnt].proc_title 		= proc_title
  output->list[cnt].pref_card_id 	= pc.pref_card_id
  output->list[cnt].surg_area_disp 	= trim(uar_get_code_display(sr.service_resource_cd),3)
  	IF (trim(p.name_middle,3) >  " ")
		tmpname = TRIM (
		CHECK(REPLACE(
		CONCAT(CNVTCAP(p.name_last_key), "_", substring(1,1,CNVTCAP(p.name_first_key)), "_", CNVTCAP(p.name_middle))
		,CHAR(32),"",0),CHAR(14)),3)
 
	ELSE
		tmpname = TRIM (
		CHECK(REPLACE(
		CONCAT(CNVTCAP(p.name_last_key), "_", substring(1,1,CNVTCAP(p.name_first_key)))
		,CHAR(32),"",0),CHAR(14)),3)
	ENDIF
  tmpname = replace (tmpname,char(42), "", 0) ;remove '*'
  output->list[cnt].name_full_formatted = replace (tmpname,char(44), "", 0)
 endif
 
 
WITH nocounter, memsort ; , FORMAT, separator = " ", check
 
 
for (x = 1 to size(output->list,5))
 
set output->temp = build(format(x,"######"), "/", format(size(output->list,5),"######"))
 
call echo (output->temp)  ;shows x of y number of files
 
set output->filename =
				cnvtlower(
				replace (
				CONCAT(
				trim(output->list[x].surg_area_disp,3), "_",
				cnvtcap(TRIM(output->list[x].name_full_formatted,3)),"_",
				trim(output->list[x].proc_title,3)),
				char(32), ""))
 
call echo (output->filename)
call echo (output->list[x].pref_card_id)
 
free record surg_out
record surg_out (
	1 list[*]
		2  	name_full_formatted = vc ;c100
  		2	pref_card_id = f8
  		2	resource 	= c500
		2 	procedure 	= c500
  		2	comment 	= c5000
  	 	2   sn_comment_id = f8
  		2   pref_text_id = f8
  		2   long_blob_id = f8
		2   item[*]
	  	 	3  	item_desc 		= c500
	  	 	3 	item_class		= c50
	  		3  	item_num 		= c100
	  		3	locator 		= c50
	  		3   location		= c50
	  		3	open_qty 		= i4
	  		3  	hold_qty 		= i4
	  		3   duplicate_ind 	= i2
 )
 
;declare comment = c5000 with noconstant(fillstring(5000," "))
 
select distinct into "nl:"
;SELECT distinct INTO VALUE ($OUTDEV)
  pc.prsnl_id,
  name_full_formatted = p.name_full_formatted,
 ;bw1 locator = check(trim(uar_get_code_display(lr.locator_cd),3), char(32)),
  locator = if (lg2.parent_loc_cd = output->list[x].facility_cd) ;bw1
  				cnvtalphanum(check(trim(uar_get_code_display(lr.locator_cd),3), char(32)));bw1
  			else
  				cnvtalphanum(check(trim(uar_get_code_display(lr.locator_cd),3), char(32)))
 
  			endif,
  location = trim(uar_get_code_display(lr.locator_cd),3),
  hold_qty = pl.request_hold_qty,
  item_desc = o2.value,
  item_num = o.value,
  open_qty = pl.request_open_qty,
  pref_card_id = pc.pref_card_id,
  procedure = oc.description,
  resource = uar_get_code_display(sr.service_resource_cd),
  comment = if (lt2.long_text_id > 0.0)
  				substring(1,5000,check(lt2.long_text,char(32)))
  			else
    			substring(1,5000,check(lt.long_text, char(32)))
     		endif
 
from
	 preference_card pc,
     service_resource sr,
     location_group lg,
     code_value cv,
     prsnl p,
     order_catalog oc,
     locator_rollup lr,
     location_group lg2,
     sn_comment_text sct,
     long_text_reference lt,
     long_text_reference lt2,
	 dummyt dp,
     pref_card_pick_list pl,
     object_identifier_index o,
     object_identifier_index o2,
     item_class_node_r icnr,
     class_node cn
 
 
 
plan 	pc
where   pc.pref_card_id =  output->list[x].pref_card_id
and 	pc.active_ind = 1
 
join   	sr
where  	sr.service_resource_cd = pc.surg_area_cd
and 	sr.service_resource_type_cd >0 ; in ( 840, 841, 842) ;= 660
and 	sr.active_ind = 1
 
join 	cv
where 	cv.code_value = sr.service_resource_cd
and 	cv.code_value = output->list[x].resource_cd
  and cv.code_set = 221
  and cv.active_ind = 1
  and cnvtupper(cv.display_key) = output->list[x].resource_key
 
join 	lg
where  	lg.child_loc_cd = sr.location_cd
and 	lg.active_ind = 1
 
join p
where  p.person_id = pc.prsnl_id
and p.person_id  = output->list[x].prsnl_id
 
join oc
where
  oc.catalog_cd =  pc.catalog_cd
  and oc.catalog_cd = output->list[x].procedure_cd
 
join (dp
join 	pl
where   pl.pref_card_id =  pc.pref_card_id
and 	pl.active_ind = 1
 
join o
where o.object_id =  pl.item_id
  and o.identifier_type_cd+0 =  (select code_value from code_value where
            code_set = 11000 and active_ind = 1 and display_key = "ITEMNUMBER")
  and o.generic_object 	=  0
  and o.active_ind 		=  1
 
join o2
  where o2.object_id =  pl.item_id
  and o2.identifier_type_cd+0 =  (select code_value from code_value where
            code_set = 11000 and active_ind = 1 and cdf_meaning = "DESC")
  and o2.generic_object =  0
  and o2.active_ind =  1
join icnr
  where icnr.item_id = outerjoin(o2.object_id)
  and icnr.active_ind = outerjoin(1)
join cn
  where cn.class_node_id = outerjoin(icnr.class_node_id)
  and cn.active_ind = outerjoin(1)
 )
 
join lr
where lr.item_id = outerjoin(pl.item_id)
 
join lg2
where lg2.child_loc_cd = outerjoin(lr.location_cd)
and lg2.parent_loc_cd = outerjoin(output->list[x].facility_cd)
 
join sct
where sct.root_id = outerjoin(pc.pref_card_id)
and sct.root_name = outerjoin("PREFERENCE_CARD")
 
join lt
where lt.long_text_id = outerjoin(sct.long_text_id)
 
join lt2
where lt2.parent_entity_id = outerjoin(sct.sn_comment_id)
 and lt2.parent_entity_name = outerjoin("SN_COMMENT_TEXT")
 
order by item_num ;locator, item_desc, item_num
;order by pc.prsnl_id , oc.description, pref_card_id, locator, item_desc, item_num
 
 head report
 cnt = 0
 idx = 0
 pos = 0
 
;head pref_card_id
 i_cnt = 0
 cnt = cnt + 1
 stat = alterlist (surg_out->list, cnt)
 surg_out->list[cnt].name_full_formatted = name_full_formatted
 surg_out->list[cnt].pref_card_id = pref_card_id
 surg_out->list[cnt].procedure = procedure
 surg_out->list[cnt].resource = resource
 surg_out->list[cnt].comment = comment
 surg_out->list[cnt].sn_comment_id  = lt2.PARENT_ENTITY_ID
 surg_out->list[cnt].pref_text_id  = lt.PARENT_ENTITY_ID
 surg_out->list[cnt].long_blob_id = sct.long_blob_id
 
head item_num
pos = locateval(idx,1,size(surg_out->list[cnt]->item,5),item_num,surg_out->list[cnt]->item[idx].item_num)
;detail
 
 i_cnt = i_cnt + 1
 stat = alterlist (surg_out->list[cnt].item, i_cnt)
 surg_out->list[cnt]->item[i_cnt].item_desc = item_desc
 surg_out->list[cnt]->item[i_cnt].item_class = substring(1,25,cn.description)
 surg_out->list[cnt]->item[i_cnt].item_num  = item_num
 surg_out->list[cnt]->item[i_cnt].hold_qty  = hold_qty
 surg_out->list[cnt]->item[i_cnt].open_qty  = open_qty
 surg_out->list[cnt]->item[i_cnt].locator  =  locator
 surg_out->list[cnt]->item[i_cnt].location  =  location
 ;if pos > 0, then the current item being evaluated has already been added to the struct
 ;they are sorted in a way that the latested record added is one we don't want since the locator is blank and the previous
 ;record has a locator that is valued with a facility
if (pos > 0)
 	 if (size(trim(surg_out->list[cnt]->item[pos].locator),1) = 0)
	 	 surg_out->list[cnt]->item[pos].duplicate_ind = 1
	 endif
endif
 
 with nocounter ;, FORMAT, separator = " ", check
 , memsort , expand = 1
 , outerjoin = dp, dontcare = pl, dontcare = o, dontcare = o2, dontcare = icnr, dontcare = cn
 
 
 
select into  value(output->filename)
;select into value($outdev)
;select into "nl"
 
 name_full_formatted = trim(surg_out->list[d.seq].name_full_formatted)
,pref_card_id = surg_out->list[d.seq].pref_card_id
,procedure 	= trim(surg_out->list[d.seq].procedure)
,resource   = trim(surg_out->list[d.seq].resource)
,comment 	= trim(surg_out->list[d.seq].comment)
,locator 	= cnvtalphanum(trim(surg_out->list[d.seq]->item[d2.seq].location,3))
,hold_qty 	= surg_out->list[d.seq]->item[d2.seq].hold_qty
,item_class	= trim(surg_out->list[d.seq]->item[d2.seq].item_class)
,item_desc 	= trim(surg_out->list[d.seq]->item[d2.seq].item_desc)
,item_num 	= trim(surg_out->list[d.seq]->item[d2.seq].item_num)
,open_qty 	= surg_out->list[d.seq]->item[d2.seq].open_qty
 
 
from
 (dummyt d with seq = value (size(surg_out->list,5)))
 ,(dummyt d2 with seq = 1)
 
plan d where maxrec(d2, size(surg_out->list[d.seq].item,5))
 
join d2 where surg_out->list[d.seq]->item[d2.seq].duplicate_ind = 0
 
order by
;procedure,
;pref_card_id,
;locator
item_class,
item_desc
;item_num
 
head report
 
  col 0 "<html><body>"
  row+1
  output->locator = ""
 
head pref_card_id
 
output->temp =
build ("<table><tr><td width='600'><b>", trim(resource) , "</b></td><td>"
, "</td><td><small></td></tr>")
col 0  output->temp
row + 1
 
 
output->temp =
build ("<table><tr><td width='600'><b>", trim(procedure) , "</b></td><td>"		;002 - Change ^ to "
,trim(name_full_formatted) , "</td><td><small>"									;002 - Change ^ to "
,format(pref_card_id,"##########") , "</small></td></tr>")						;002 - Change ^ to "
col 0  output->temp
row + 1
 
output->temp =
build ("<tr><td colspan='3'><b>Comments: </b><small>"							;002 - Change ^ to "
,trim(surg_out->list[d.seq].comment), "</small></td></tr></table>")				;002 - Change ^ to "
col 0  output->temp
row + 1
 
output->temp =											;002 - Change ^ to "
build ("<table><tr><td><small><b>Class</b></td><td></small><small><b>Locator</b></small></td><td><small><b>Item #</b></small></td>",
"<td><small><b>Item    </b></td></small>",				;002 - Change ^ to "
"<td><small><b>Open Qty</b></td></small>",				;002 - Change ^ to "
"<td><small><b>Hold Qty</b></td></small>",				;002 - Change ^ to "
"</td></tr>")											;002 - Change ^ to "
col 0  output->temp
row + 1
 
detail
 
output->temp =
 build ("<tr><td><small>"								;002 - Change ^ to "
 ,trim(item_class) , "</small></td><td><small>"			;002 - Change ^ to "
 ,trim(surg_out->list[d.seq]->item[d2.seq].locator) , "</small></td><td><small>"		;002 - Change ^ to "
 ,item_num , "</small></td><td><small>"					;002 - Change ^ to "
 ,trim(item_desc),"</small></td><td><small>"			;002 - Change ^ to "
 ,open_qty , "</small></td><td><small>"					;002 - Change ^ to "
 ,hold_qty , "</small></td></tr>")						;002 - Change ^ to "
 
 
col 0  output->temp
row + 1
 
foot pref_card_id
 col 01 "</table><br/><hr><br/>"
 row+1
 
 
foot report
 col 01 "</table></body></html>"
 row+1
 
with maxcol = 5080, noformfeed, format, separator = " ", check, memsort  ;002 - Changed maxcol = 5050 to maxcol = 5070
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Reply for successful OPS Logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 IF(VALIDATE(REQUEST->OPS_DATE,999) != 999)
        SET REPLY->STATUS_DATA->STATUS = "S"
 ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
set statx = 0
if 		(substring(1,3, output->list[x].service_resource) = "MMC") 	;Methodist
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_m, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "RMC") 	;Roane
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_r, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "FLM") 	;Loudoun
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_n, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "LCM") 	;LeConte
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_l, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "MHH") 	;Morristown
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_h, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "PWM") 	;ParkWest
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_p, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "FSR") 	;FortSanders
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_s, output->filename, ".dat")
 
elseif  (substring(1,3, output->list[x].service_resource) = "MHA") 	;Morristown Ambulatory Surgery		;003 - Added 
	;004 - Changed dir name
	set  output->temp  = concat("mv $CCLUSERDIR/", output->filename,".dat ",output->directory_a, output->filename, ".dat")
endif
 
;call echo (output->temp)
call dcl( output->temp ,size(output->temp  ), statx)
set output->temp = ""
 
 
select into value($outdev)
Message =  "Files successfully created to backup Astream folders."
with check  ;004 - Removed ', NOHEADER'
 
 
;call echorecord(surg_out)
 endfor; loop area/phys
 
 ;call echorecord(output)
 
 
#exit_report
end go
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		03/17/2020
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_Interfaced_Charges.prg
	Object name:		cov_cs_Interfaced_Charges
	Request #:			6186
 
	Program purpose:	Selected data from table to be extracted to files:
							- INTERFACE_CHARGE
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							interfaced_charges.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_cs_Interfaced_Charges:dba go
create program cov_cs_Interfaced_Charges:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, output_file
 
 
/**************************************************************
; DVDevdeclareD SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDevdeclareD VARIABLES
**************************************************************/
	
declare start_datetime			= dq8 with constant(cnvtdatetime((curdate - 1), 000000))
declare end_datetime			= dq8 with constant(cnvtdatetime((curdate - 1), 235959))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare charge_type_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 13028, "CREDIT"))
declare contributor_source_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))

declare num						= i4 with noconstant(0)
declare pos						= i4 with noconstant(0)
 
declare file_var				= vc with constant("interfaced_charges.csv")
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/ChargeServices/", file_var))
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record charges
record charges (
   1 c_total_extended_price	= f8
   
   1 c_cnt					= i4
   1 c_detail[*]
     2 fin					= c20
     2 patient_name			= c100
     2 service_date_time	= dq8
     2 cdm					= c40
     2 cpt					= c40
     2 description			= c200
     2 charge_type			= c40
     2 item_quantity		= f8
     2 qcf					= f8
     2 extended_quantity	= f8
     2 item_price			= f8
     2 extended_price		= f8
     2 encntr_id			= f8
     2 person_id			= f8
     2 charge_item_id		= f8
     2 organization_id		= f8
     2 organization_name	= c100
     2 activity_type_cd		= f8
     2 activity_type		= c40
     2 cost_center_cd		= f8
     2 cost_center			= c40
     2 interface_file_id	= f8
     2 interface_file_name	= c100
     2 billing_entity		= c40
     2 tier_group_cd		= f8
     2 tier_group			= c40
     2 encntr_type_cd		= f8
     2 encntr_type			= c40
     2 posted_date			= dq8     
)
 
 
/**************************************************************/
; select interface charge data
select into "NL:"
from 
	INTERFACE_CHARGE ic
	
	, (inner join CHARGE c on c.charge_item_id = ic.charge_item_id
		and c.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
		and c.end_effective_dt_tm > cnvtdatetime (curdate, curtime3))
		
	, (inner join ORGANIZATION org on org.organization_id = ic.organization_id
		and org.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
		and org.end_effective_dt_tm > cnvtdatetime (curdate, curtime3)
		and org.active_ind = 1)
	
	, (inner join INTERFACE_FILE ifile on ifile.interface_file_id = ic.interface_file_id
		and ifile.active_ind = 1)
	
	, (inner join PERSON p on p.person_id = c.person_id)
	
	, (left join ENCNTR_ALIAS ea on ea.encntr_id = c.encntr_id
		and ea.encntr_alias_type_cd = 1077.00 ; fin
		and ea.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
		and ea.end_effective_dt_tm > cnvtdatetime (curdate, curtime3))
	
	, (left join ENCNTR_COMBINE ec on ec.from_encntr_id = ic.encntr_id
		and ec.active_ind = 1)
	
	, (left join ENCNTR_ALIAS ea2 on ea2.encntr_id = ec.to_encntr_id
		and ea2.encntr_alias_type_cd = 1077.00
		and ea2.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
		and ea2.end_effective_dt_tm > cnvtdatetime (curdate, curtime3))
		
	, (inner join ENCOUNTER e on e.encntr_id = ic.encntr_id)
	
	, (left join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
		and cvo.alias_type_meaning = "FACILITY"
		and cvo.contributor_source_cd = contributor_source_var)
	
where 
	ic.beg_effective_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and ic.process_flg = 999
	and ic.active_ind = 1

order by
	c.charge_item_id
	, ea.end_effective_dt_tm desc
	, ea2.end_effective_dt_tm desc
 
 
; populate record structure	
head report
	c_cnt = 0
   
head c.charge_item_id
	c_cnt += 1
   
	if (mod(c_cnt, 100) = 1) 
		stat = alterlist(charges->c_detail, (c_cnt + 99))
	endif
   
	if ((c.charge_type_cd = charge_type_var) and (c.item_price > 0.00)) 
		charges->c_detail[c_cnt].item_price = (ic.price * -(1.00))
		charges->c_detail[c_cnt].extended_price = (ic.net_ext_price * -(1.00))
		charges->c_total_extended_price = (charges->c_total_extended_price + (ic.net_ext_price * -(1.00)))		
	else 
		charges->c_detail[c_cnt].item_price = ic.price
		charges->c_detail[c_cnt].extended_price = ic.net_ext_price
		charges->c_total_extended_price = (charges->c_total_extended_price + ic.net_ext_price)		
	endif
   
	if ((textlen(trim(ea.alias, 3)) > 0)) 
		charges->c_detail[c_cnt].fin = cnvtalias(ea.alias, ea.alias_pool_cd)
	else 
		charges->c_detail[c_cnt].fin = cnvtalias(ea2.alias, ea2.alias_pool_cd)
	endif
	
	charges->c_cnt									= c_cnt
	charges->c_detail[c_cnt].patient_name			= p.name_full_formatted
	charges->c_detail[c_cnt].service_date_time		= ic.service_dt_tm
	charges->c_detail[c_cnt].cdm					= ic.prim_cdm
	charges->c_detail[c_cnt].cpt					= ic.prim_cpt
	charges->c_detail[c_cnt].description			= c.charge_description
	charges->c_detail[c_cnt].charge_type			= uar_get_code_display(ic.charge_type_cd)
	charges->c_detail[c_cnt].item_quantity			= ic.quantity
	charges->c_detail[c_cnt].qcf					= ic.qty_conv_factor
	charges->c_detail[c_cnt].extended_quantity		= ic.ext_bill_qty
	charges->c_detail[c_cnt].encntr_id				= ic.encntr_id
	charges->c_detail[c_cnt].person_id				= ic.person_id
	charges->c_detail[c_cnt].charge_item_id			= c.charge_item_id
	charges->c_detail[c_cnt].organization_id		= ic.organization_id
	charges->c_detail[c_cnt].organization_name		= org.org_name
	charges->c_detail[c_cnt].billing_entity			= cvo.alias
	charges->c_detail[c_cnt].activity_type_cd		= ic.activity_type_cd
	charges->c_detail[c_cnt].activity_type			= uar_get_code_display(ic.activity_type_cd)
	charges->c_detail[c_cnt].cost_center_cd			= ic.cost_center_cd
	charges->c_detail[c_cnt].cost_center			= uar_get_code_display(ic.cost_center_cd)
	charges->c_detail[c_cnt].interface_file_id		= ic.interface_file_id
	charges->c_detail[c_cnt].interface_file_name	= ifile.description
	charges->c_detail[c_cnt].tier_group_cd			= c.tier_group_cd
	charges->c_detail[c_cnt].tier_group				= uar_get_code_display(c.tier_group_cd)
	charges->c_detail[c_cnt].encntr_type_cd			= ic.encntr_type_cd
	charges->c_detail[c_cnt].encntr_type			= uar_get_code_display(ic.encntr_type_cd)
	charges->c_detail[c_cnt].posted_date			= ic.posted_dt_tm
   
foot report
	stat = alterlist(charges->c_detail, c_cnt)
   
with nocounter 
 
 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, separator = " ", format, time = 600
endif
    
into value(output_var)
    interface_filename		= trim(charges->c_detail[d1.seq].interface_file_name, 3)
    , tier_group			= trim(charges->c_detail[d1.seq].tier_group, 3)
    , interfaced_date		= charges->c_detail[d1.seq].posted_date "@SHORTDATETIME"
    , organization_name		= trim(charges->c_detail[d1.seq].organization_name, 3)
    , billing_entity		= trim(charges->c_detail[d1.seq].billing_entity, 3)
;    , cost_center			= trim(charges->c_detail[d1.seq].cost_center, 3)
    , fin					= trim(charges->c_detail[d1.seq].fin, 3)
    , encounter_type		= trim(charges->c_detail[d1.seq].encntr_type, 3)
    , patient_name			= trim(charges->c_detail[d1.seq].patient_name, 3)
    , service_date_time		= charges->c_detail[d1.seq].service_date_time "@SHORTDATETIME"
    , cdm					= trim(charges->c_detail[d1.seq].cdm, 3)
    , cpt					= trim(charges->c_detail[d1.seq].cpt, 3)
    , description			= trim(charges->c_detail[d1.seq].description, 3)
    , activity_type			= trim(charges->c_detail[d1.seq].activity_type, 3)
    , charge_type			= trim(charges->c_detail[d1.seq].charge_type, 3)
    , item_quantity			= charges->c_detail[d1.seq].item_quantity
    , qcf					= charges->c_detail[d1.seq].qcf
    , extended_quantity		= charges->c_detail[d1.seq].extended_quantity
    , item_price			= charges->c_detail[d1.seq].item_price
    , extended_price		= charges->c_detail[d1.seq].extended_price
    
from
	(dummyt d1 with seq = value(charges->c_cnt))

plan d1

order by
	organization_name
	, fin
	, activity_type
	, description
 
 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
;call echorecord(charges)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go


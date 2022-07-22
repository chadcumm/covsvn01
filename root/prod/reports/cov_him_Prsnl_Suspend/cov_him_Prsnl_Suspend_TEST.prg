/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/10/2022
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_Prsnl_Suspend.prg
	Object name:		cov_him_Prsnl_Suspend
	Request #:			12866
 
	Program purpose:	Lists data similar to the ProFile Letters app.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_Prsnl_Suspend_TEST:dba go
create program cov_him_Prsnl_Suspend_TEST:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Letter Type" = 0
	, "Facility" = 0 

with OUTDEV, letter_type, facility
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")), protect
declare status_pending_var			= i2 with constant(1), protect
declare type_completed_var			= i2 with constant(2), protect
declare tempord_none_var			= i2 with constant(0), protect
declare tempord_template_var		= i2 with constant(1), protect

declare phys_ind					= i2 with constant(1), protect
declare num							= i4 with noconstant(0), protect


/**************************************************************
; DVDev Start Coding
**************************************************************/

record org_data (
	1 qual[*]
		2 organization_id		= f8
)

record 1120018_request (
	1 code_set							= f8   
	1 code_value						= f8   
	1 get_alias_ind						= i2   
	1 get_outbound_alias_ind			= i2   
	1 chk_for_effec_code_value_ind		= i2   
)
 
record 1120018_reply (
	1 qual[*]
		2 code_set					= i4
		2 code_value				= f8
		2 code_display				= vc
		2 code_description			= vc
		2 code_definition			= vc
		2 code_cdf_meaning			= vc
		2 code_active_ind			= i2
		2 code_updt_cnt				= i4
		2 code_collation_seq		= i4
		2 ext[*]
			3 field_cd				= f8
			3 field_disp			= vc
			3 field_value			= vc
			3 field_name			= vc
			3 field_type			= i4
		2 alias[*]
			3 contributor_source_cd			= f8
			3 contributor_source_disp		= vc
			3 alias							= vc
			3 alias_null_ind				= i2
			3 alias_type_meaning			= vc
			3 atm_null_ind					= i2
			3 primary_ind					= i2
			3 cki							= vc
			3 updt_cnt						= i4
	1  status_data[*]
		2 status 					= vc
		2 subeventstatus[*]
			3 operationname			= vc
			3 operationstatus		= vc
			3 targetobjectname		= vc
			3 targetobjectvalue		= vc
)

record 1120041_request (
	1 debug_ind					= i2
	1 start_age					= i4
	1 stop_age					= i4
	1 most_severe_ind			= i2
	1 organization_id			= f8
	1 allocated_charts_ind		= i2
	1 qualified_charts_ind		= i2
	1 visit_status_flag			= i2
	1 org_qual[1]
		2 organization_id			= f8
		2 use_default_event_set		= i2
)

record 1120041_reply (
	1 batch_nbr						= f8
	1 getltrspref_success_ind		= i2
	1 reply_qual[*]
		2 physician_id				= f8
		2 physician_name			= c100
		2 total_age					= i4
		2 hold_ind					= i2
		2 phys_ind 					= i2
		2 email_address				= vc
		2 cur_avail[*]
			3 svalue				= vc
		2 pref_avail[*]
			3 svalue				= vc
		2 letters_dist_pref			= vc
		2 pref_cur_avail_ind		= i2
	1  status_data[*]
		2 status 					= vc
		2 subeventstatus[*]
			3 operationname			= vc
			3 operationstatus		= vc
			3 targetobjectname		= vc
			3 targetobjectvalue		= vc
)

record final_data (
	1 cnt					= i4
	1 qual[*]
		2 provider_name		= c100
		2 prsnl_id			= f8
		2 phys_ind			= i2
		2 hold_ind			= i2
		
		2 defic				= c100
		2 total_age			= i4
		
		2 patient_name		= c100
		2 fin				= c20
		2 disch_date		= dq8
		2 org_name			= c100
)


/**************************************************************/ 
; select organization data
select if ($facility > 0)
	plan per
	where
		per.person_id = reqinfo->updt_id
		and per.active_ind = 1
	
	join por
	where 
		por.person_id = per.person_id
	    
	join org
	where
		org.organization_id = por.organization_id
		and org.organization_id = $facility
		and org.active_ind = 1
	
endif

distinct into "NL:"
from
    PRSNL per
    
    , PRSNL_ORG_RELTN por
    
    , ORGANIZATION org
    
plan per
where
	per.person_id = reqinfo->updt_id
	and per.active_ind = 1

join por
where 
	por.person_id = per.person_id
    
join org
where
	org.organization_id = por.organization_id
	and org.active_ind = 1
    
order by
	org.organization_id
	
	
; populate record structure
head report
	cnt = 0

head org.organization_id
	cnt = cnt + 1
	 
	call alterlist(org_data->qual, cnt)
	
	org_data->qual[cnt].organization_id = org.organization_id
	
with nocounter, time = 180

call echorecord(org_data)


/**************************************************************/ 
; select him code values/extensions for letters data

set 1120018_request->code_set							= 14429
set 1120018_request->code_value							= $letter_type
set 1120018_request->get_alias_ind						= 0
set 1120018_request->get_outbound_alias_ind				= 0
set 1120018_request->chk_for_effec_code_value_ind		= 0

set stat = tdbexecute(1120005, 1120010, 1120018, "REC", 1120018_request, "REC", 1120018_reply)

call echorecord(1120018_reply)


/**************************************************************/ 
; select him age for letters data

set idx1 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Day Start Range", 1120018_reply->qual[1].ext[num].field_name)
set idx2 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Day End Range", 1120018_reply->qual[1].ext[num].field_name)
set idx3 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Print Most Severe Ind", 1120018_reply->qual[1].ext[num].field_name)
set idx4 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Qualified Defs Only Ind", 1120018_reply->qual[1].ext[num].field_name)
set idx5 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Qualified Charts Only Ind", 1120018_reply->qual[1].ext[num].field_name)
set idx6 = locateval(num, 1, size(1120018_reply->qual[1].ext, 5), "Visit_Status_Flag", 1120018_reply->qual[1].ext[num].field_name)

set 1120041_request->debug_ind					= 0
set 1120041_request->start_age					= cnvtint(1120018_reply->qual[1].ext[idx1].field_value)
set 1120041_request->stop_age					= cnvtint(1120018_reply->qual[1].ext[idx2].field_value)
set 1120041_request->most_severe_ind			= cnvtint(1120018_reply->qual[1].ext[idx3].field_value)
set 1120041_request->organization_id			= 0
set 1120041_request->allocated_charts_ind		= cnvtint(1120018_reply->qual[1].ext[idx4].field_value)
set 1120041_request->qualified_charts_ind		= cnvtint(1120018_reply->qual[1].ext[idx5].field_value)
set 1120041_request->visit_status_flag			= cnvtint(1120018_reply->qual[1].ext[idx6].field_value)

set stat = tdbexecute(1120005, 1120010, 1120041, "REC", 1120041_request, "REC", 1120041_reply)

call echorecord(1120041_request) 
call echorecord(1120041_reply)

;go to exitscript
 
 
/**************************************************************/ 
; select him allocation data
select into "NL:"	
from
	HIM_EVENT_ALLOCATION hea

	, ENCOUNTER e
	
	, ENCNTR_ALIAS ea
	
	, ORGANIZATION org
	
	, PERSON p
	
	, (dummyt d1 with seq = size(1120041_reply->reply_qual, 5))
	
	, (dummyt d2 with seq = size(org_data->qual, 5))
	
plan d1
where
	1120041_reply->reply_qual[d1.seq].physician_name > " "
	and 1120041_reply->reply_qual[d1.seq].phys_ind = phys_ind
	
join hea
where
	hea.prsnl_id = 1120041_reply->reply_qual[d1.seq].physician_id
	and hea.completed_dt_tm > cnvtdatetime(curdate, curtime)
	and hea.request_dt_tm != null
	
join e
where
	e.encntr_id = hea.encntr_id
	
join ea
where
	ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	
join org
where
	org.organization_id = e.organization_id
	
join p
where
	p.person_id = e.person_id
	and p.active_ind = 1
	
join d2
where
	org_data->qual[d2.seq].organization_id = org.organization_id
	
	
; populate record structure
head report
	cnt = 0
 
detail
	total_age = cnvtint(round(datetimediff(sysdate, e.disch_dt_tm), 0))
	
	if (total_age between 1120041_request->start_age and 1120041_request->stop_age)
		cnt = cnt + 1
	 
		call alterlist(final_data->qual, cnt)
	
		final_data->cnt							= cnt
		final_data->qual[cnt].provider_name		= 1120041_reply->reply_qual[d1.seq].physician_name
		final_data->qual[cnt].prsnl_id			= 1120041_reply->reply_qual[d1.seq].physician_id
		final_data->qual[cnt].phys_ind			= 1120041_reply->reply_qual[d1.seq].phys_ind
		final_data->qual[cnt].hold_ind			= 1120041_reply->reply_qual[d1.seq].hold_ind
	
		final_data->qual[cnt].defic				= uar_get_code_display(hea.event_cd)
		final_data->qual[cnt].total_age			= total_age
		
		final_data->qual[cnt].patient_name		= p.name_full_formatted
		final_data->qual[cnt].fin				= ea.alias
		final_data->qual[cnt].disch_date		= e.disch_dt_tm
		final_data->qual[cnt].org_name			= org.org_name
	endif
	
with nocounter, time = 180

;call echorecord(final_data)
 
 
/**************************************************************/ 
; select order notification data
select into "NL:"	
from
	ORDER_NOTIFICATION ot
	
	, ORDERS o

	, ENCOUNTER e
	
	, ENCNTR_ALIAS ea
	
	, ORGANIZATION org
	
	, PERSON p
	
	, (dummyt d1 with seq = size(1120041_reply->reply_qual, 5))
	
	, (dummyt d2 with seq = size(org_data->qual, 5))
	
plan d1
where
	1120041_reply->reply_qual[d1.seq].physician_name > " "
	and 1120041_reply->reply_qual[d1.seq].phys_ind = phys_ind
	
join ot
where
	ot.to_prsnl_id = 1120041_reply->reply_qual[d1.seq].physician_id
	and ot.notification_status_flag = status_pending_var
	and ot.notification_type_flag = type_completed_var
	
join o
where
	o.order_id = ot.order_id
	and o.template_order_flag in (tempord_none_var, tempord_template_var)
	and o.need_doctor_cosign_ind > 0
	
join e
where
	e.encntr_id = o.encntr_id
	
join ea
where
	ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	
join org
where
	org.organization_id = e.organization_id
	
join p
where
	p.person_id = e.person_id
	and p.active_ind = 1
	
join d2
where
	org_data->qual[d2.seq].organization_id = org.organization_id
	
	
; populate record structure
head report
	cnt = final_data->cnt
 
detail
	total_age = cnvtint(round(datetimediff(sysdate, e.disch_dt_tm), 0))
	
	if (total_age between 1120041_request->start_age and 1120041_request->stop_age)
		cnt = cnt + 1
	 
		call alterlist(final_data->qual, cnt)
	
		final_data->cnt							= cnt
		final_data->qual[cnt].provider_name		= 1120041_reply->reply_qual[d1.seq].physician_name
		final_data->qual[cnt].prsnl_id			= 1120041_reply->reply_qual[d1.seq].physician_id
		final_data->qual[cnt].phys_ind			= 1120041_reply->reply_qual[d1.seq].phys_ind
		final_data->qual[cnt].hold_ind			= 1120041_reply->reply_qual[d1.seq].hold_ind
	
		final_data->qual[cnt].defic				= o.order_mnemonic
		final_data->qual[cnt].total_age			= total_age
	
		final_data->qual[cnt].patient_name		= p.name_full_formatted
		final_data->qual[cnt].fin				= ea.alias
		final_data->qual[cnt].disch_date		= e.disch_dt_tm
		final_data->qual[cnt].org_name			= org.org_name
	endif
	
with nocounter, time = 180

call echorecord(final_data)
 
 
/**************************************************************/ 
; select data
select distinct into value($OUTDEV)
	provider_name				= final_data->qual[d1.seq].provider_name
	, prsnl_id					= final_data->qual[d1.seq].prsnl_id
	, phys_ind					= evaluate(final_data->qual[d1.seq].phys_ind, 1, "Y", "")
	, hold_ind					= evaluate(final_data->qual[d1.seq].hold_ind, 1, "Y", "")

	, deficiency				= trim(final_data->qual[d1.seq].defic, 3)
	, total_age					= final_data->qual[d1.seq].total_age
	
	, patient_name				= final_data->qual[d1.seq].patient_name
	, fin						= final_data->qual[d1.seq].fin
	, disch_date				= final_data->qual[d1.seq].disch_date "mm/dd/yyyy;;d"
	, org_name					= trim(final_data->qual[d1.seq].org_name, 3)
	
from
	(dummyt d1 with seq = final_data->cnt)
	
plan d1
where
	final_data->qual[d1.seq].total_age > 0
	
order by
	provider_name
	, prsnl_id
	, total_age desc
	, final_data->qual[d1.seq].disch_date
	
with nocounter, separator = " ", format, time = 180
	

/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 

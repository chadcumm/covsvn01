/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Aug'2022
	Solution:			All
	Source file name:	      cov_eks_get_interp_req.prg
	Object name:		cov_eks_get_interp_req.prg
	Request#:			13308
	Program purpose:	      Alert for Interpreter request
	Executing from:		Rule / Smart Zone
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
-------------------------------------------------------------------------------
 
/22    Geetha    CR#13308     Initial release
 
******************************************************************************/

drop program cov_eks_get_interp_req:dba go
create program cov_eks_get_interp_req:dba


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare encntrid_var = f8 with noconstant(0.0), protect
declare personid_var = f8 with noconstant(0.0), protect
declare log_message  = vc with noconstant('CCL did not return any values'), protect
declare log_misc1    = vc with noconstant(' '), protect
declare log_retval   = i4 with noconstant(0), protect

declare result_dt_var = vc with noconstant(' '), protect
declare result_dt_var_dq = dq8 
 
;set personid_var = trigger_personid 
;set encntrid_var = trigger_encntrid ;link_encntrid ;125474550 
set log_retval = 0
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;eid = 130143712 
;pid = 22376109        


/*
select into 'nl:' 
from  person p
where p.person_id =    20757826.00 ;trigger_personid
	and p.active_ind = 1
	
Detail
	if((cnvtupper(p.name_last) = 'TEST') or (cnvtupper(p.name_last) = '*TEST')
		or (cnvtupper(p.name_last) = 'TEST*') or (cnvtupper(p.name_last) = '*TEST*') )
		log_retval = 100
		log_misc1 = p.name_full_formatted
	else	
		log_retval = 0
		log_misc1 = p.name_full_formatted
	endif	
	log_message = concat( 'Patient Name - ', log_misc1)

with nocounter;, nullreport go
*/



select into 'nl:' 
e.encntr_id, ea.alias
from encounter e ,encntr_alias ea 

plan e where e.encntr_id =   125487077.00 ;trigger_encntrid  

join ea where outerjoin(e.encntr_id) = ea.encntr_id
	and ea.encntr_alias_type_cd = value(uar_get_code_by("DISPLAY", 319, "FIN NBR")) 
	and ea.active_ind = 1

Head report
	log_message = "No Alias found"
	log_retval = 100
	log_misc1 = 'NO IN'
Detail
 	log_retval = 100
 	if(ea.alias = ' ')
 		log_misc1 = 'NO FIN'
 	else	
 		log_misc1 = ea.alias
 	endif	
 	log_message = concat( 'Alias Found - ', log_misc1)
with nocounter;, nullreport go


;select * from encounter e where e.encntr_id =    131617747.00; 128655117.00 ;trigger_encntrid  

/*

;Deaf dismiss expired - l5

;Cert
select diff = datetimediff(sysdate, pa.end_effective_dt_tm,3),pa.*
from passive_alert pa
plan pa where pa.person_id = 22376109.00 ; custdev ;22386109.00 ;devgrp ;trigger_personid 
	and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	;and pa.alert_txt in('LANGUAGE: Interpreter needed');, 'DEAF/HOH: Interpreter needed')
	and pa.end_effective_dt_tm <= sysdate
	/*and pa.passive_alert_id = (select max(pa1.passive_alert_id) from passive_alert pa1 
			where pa1.person_id = pa.person_id
			and pa1.alert_txt = pa.alert_txt
			group by pa1.person_id)*/
/*			
order by pa.passive_alert_id desc			
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180			
			
Head report 
 	log_retval = 0
 	log_message = 'Deaf Alert Not expired'
Detai
	log_retval = 100
	log_misc1 = format(pa.end_effective_dt_tm, 'mm/dd/yy hh:mm;;q')
 	log_message = build2('Deaf Alert expired - ', log_misc1)
With nocounter;, nullreport go


;select * from prsnl pr where pr.person_id =    12428721.00
/*

;see gstest1 results - InERROR issue

/*select ce.encntr_id, ce.event_id, ce.parent_event_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
, result_status = uar_get_code_display(ce.result_status_cd), ce.verified_dt_tm ';;q'
, ce.performed_dt_tm ';;q', ce.valid_until_dt_tm ';;q'


select into 'nl:' 
from clinical_event ce
plan ce where ce.encntr_id = 130143712.00 ;trigger_encntrid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		group by ce1.encntr_id, ce1.event_cd)

order by ce.encntr_id, ce.event_cd
		
Head report 
 	log_retval = 0
 	log_message = 'InError Status Not Found'
Head ce.encntr_id
	if(ce.result_status_cd in(28,29,30,31))
		log_retval = 100
		log_misc1 = uar_get_code_display(ce.result_status_cd)
 		log_message = build2('InError Status found - ', log_misc1)
 	endif	
With nocounter;, nullreport go


;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180

	


/*
select into 'nl:'
from clinical_event ce, clinical_event ce2
plan ce where ce.person_id = 22376109.00 ;trigger_personid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ( 
			( (ce1.result_val = 'Video interpretation') or (ce1.result_val = '*Video interpretation')
				or (ce1.result_val = '*Video interpretation*') or (ce1.result_val = 'Video interpretation*') 
			)
		    OR((ce1.result_val = 'In-person interpretation') or (ce1.result_val = '*In-person interpretation')
		    		or (ce1.result_val = '*In-person interpretation*') or (ce1.result_val = 'In-person interpretation*')
		    	)	
		    OR((ce1.result_val = 'Telephone interpretation') or (ce1.result_val = '*Telephone interpretation')
		    		or (ce1.result_val = '*Telephone interpretation*') or (ce1.result_val = 'Telephone interpretation*')
		    	)
		    )		

		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
	
join ce2 where ce2.encntr_id = ce.encntr_id
	and ce2.parent_event_id = ce.parent_event_id
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
	and ((ce2.result_val  = 'Deaf') or (ce2.result_val  = '*Deaf') or (ce2.result_val  = 'Deaf*') or (ce2.result_val  = '*Deaf*') )
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
order by ce2.encntr_id, ce2.event_id	
Head report 
 	log_retval = 0
	log_misc1 = cnvtstring(log_retval)
 	log_message = build2('Deaf Interpreter Request Not Found - ', log_misc1)
Head ce2.event_id
	d_start_pos = findstring("Deaf" ,ce2.result_val)
	final_rslt = substring(d_start_pos, 4, ce2.result_val)
	if(final_rslt = 'Deaf')
 		log_misc1 = 'DEAF/HOH: Interpreter needed'
 	endif
 	log_retval = 100
	log_misc1 = ce2.result_val
 	log_message = build2('Deaf Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go







/*

select sa.encntr_id, sa.person_id, sed.oe_field_display_value, sa.beg_dt_tm, sa.end_dt_tm, ofm.description
,sa.updt_dt_tm, ofm.oe_field_meaning, ofm.oe_field_meaning_id, sed.*

from sch_appt sa, sch_event_detail sed, oe_field_meaning ofm
plan sa where sa.encntr_id = 131651703.00 ;trigger_encntrid
	and sa.active_ind = 1
join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
	and((sed.oe_field_display_value = 'Yes - Language other than English')or (sed.oe_field_display_value = 'Yes - Deaf/HOH'))
	and sed.active_ind = 1
join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id

Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
 	if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
 		log_misc1 = 'DEAF/HOH: Interpreter needed'
 	elseif (sed.oe_field_display_value = 'Yes - Language other than English')	
 		log_misc1 = 'LANGUAGE: Interpreter needed'
 	endif	
	log_retval = 100
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go


/*

select ;into 'nl:' 
ce.event_cd, ce.result_val, ce.event_end_dt_tm,ce.verified_prsnl_id, ce.*
from clinical_event ce;, clinical_event ce2
plan ce where ce.encntr_id =  129183724                 ;129207712.00 ;trigger_encntrid
	;and ce.person_id = trigger_personid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ( 
			( (ce1.result_val = 'Video interpretation') or (ce1.result_val = '*Video interpretation')
				or (ce1.result_val = '*Video interpretation*') or (ce1.result_val = 'Video interpretation*') 
			)
		    OR((ce1.result_val = 'In-person interpretation') or (ce1.result_val = '*In-person interpretation')
		    		or (ce1.result_val = '*In-person interpretation*') or (ce1.result_val = 'In-person interpretation*')
		    	)	
		    OR((ce1.result_val = 'Telephone interpretation') or (ce1.result_val = '*Telephone interpretation')
		    		or (ce1.result_val = '*Telephone interpretation*') or (ce1.result_val = 'Telephone interpretation*')
		    	)
		    )		
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.person_id, ce1.event_cd)

with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 	
	
join ce2 where ce2.encntr_id = ce.encntr_id
	and ce2.person_id = ce.person_id
	and ce2.parent_event_id = ce.parent_event_id
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
	and ((ce2.result_val  = 'Deaf') or (ce2.result_val  = '*Deaf') or (ce2.result_val  = 'Deaf*') or (ce2.result_val  = '*Deaf*') 
		or (ce2.result_val  =  'Other Language Preferred') or (ce2.result_val  =  '*Other Language Preferred')
		or (ce2.result_val  =  'Other Language Preferred*') or (ce2.result_val  =  '*Other Language Preferred*'))
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	
Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
	d_start_pos = findstring("Deaf" ,ce2.result_val)
	deaf_rslt = substring(d_start_pos, 4, ce2.result_val)
	l_start_pos = findstring("Other Language Preferred" ,ce2.result_val)
	lang_rslt = substring(l_start_pos, 24, ce2.result_val)
	
	if(deaf_rslt = 'Deaf')
		final_rslt = 'Deaf'
	elseif(lang_rslt = 'Other Language Preferred')	
		final_rslt = 'Other Language Preferred'
	endif
	call echo(build2('str = ' ,final_rslt, ' - pos = ',d_start_pos, '- result_val- = ', ce2.result_val))

	if(final_rslt = 'Deaf')
 		log_misc1 = 'DEAF/HOH: Interpreter needed'
 	elseif (final_rslt = 'Other Language Preferred')	
 		log_misc1 = 'LANGUAGE: Interpreter needed'
 	endif
 	log_retval = 100
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go  	
   	
/*
	call echo(build2('str = ' ,final_rslt, ' - pos = ',start_pos))
	
	start_pos = findstring("Deaf" ,'Hearing impaired, Deaf, left ear')
	final_rslt = substring(start_pos, 4, 'Hearing impaired, Deaf, left ear')

 select txt = textlen('Deaf, Hearing impaired, left ear')
 , str_start_pos = findstring("Deaf" ,'Deaf, Hearing impaired, left ear')
 ;,ft = trim(substring((findstring("Other:" , 'Stayed, Other: awaiting donor') + 7) ,textlen('Stayed, Other: awaiting donor') ,
 ;					'Stayed, Other: awaiting donor'))
 , final_rslt = substring(, 8 , 'Stayed, Other: awaiting donor') 
 
 from dummyt
   	

 select tt = substring(1, (findstring("Deaf", ce.result_val) -3), ce.result_val)
 from clinical_event ce where ce.encntr_id =   130090550.00
 and ce.event_cd =    21910897.00
   	
 



/*
22376109        130143712


select into 'nl:' 
from clinical_event ce, clinical_event ce2
plan ce where ce.encntr_id = trigger_encntrid
	and ce.person_id = trigger_personid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ce1.result_val in('Video interpretation', 'In-person interpretation', 'Telephone interpretation')
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.person_id, ce1.event_cd)
	
join ce2 where ce2.encntr_id = ce.encntr_id
	and ce2.person_id = ce.person_id
	and ce2.parent_event_id = ce.parent_event_id
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
	and ce2.result_val  = 'Other Language Preferred'
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	
Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
 	log_retval = 100
	log_misc1 = ce2.result_val
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter, nullreport go



/*
select into 'nl:'
diff = datetimediff(sysdate, paa.beg_effective_dt_tm,3)
from passive_alert pa, passive_alert_action paa
plan pa where pa.person_id = 22386109.00 ;trigger_personid
	and pa.active_ind = 1
	and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	and pa.alert_removal_source is null
	
join paa where paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS'
Head report 
 	log_retval = 0
 	log_message = 'Dismisel not found'
Detail
 	log_misc1 = cnvtstring(diff)
With nocounter;, nullreport go



/*
=======================================================================================
REMOVED FROM COV_OC...

select into 'nl:'
diff = datetimediff(sysdate, paa.beg_effective_dt_tm,3)
from passive_alert pa, passive_alert_action paa, dummyt d
plan pa where pa.person_id = trigger_personid
	and pa.active_ind = 1
	and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	and pa.alert_removal_source is null
	
join paa where paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS'

join d where datetimediff(sysdate, paa.beg_effective_dt_tm,3) >= 48.00
	
Head report 
 	log_retval = 0
 	log_message = 'Deaf Alert Not expired'
Detail
	log_retval = 100
	log_misc1 = cnvtstring(diff)
 	log_message = build2('Deaf Alert expired - ', log_misc1, 'Hrs')
With nocounter, nullreport go


select into 'nl:'
diff = datetimediff(sysdate, paa.beg_effective_dt_tm,3)
from passive_alert pa, passive_alert_action paa, dummyt d
plan pa where pa.person_id = trigger_personid
	and pa.active_ind = 1
	and pa.alert_txt = 'LANGUAGE: Interpreter needed'
	and pa.alert_removal_source is null
	
join paa where paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS'

join d where datetimediff(sysdate, paa.beg_effective_dt_tm,3) >= 48.00
	
Head report 
 	log_retval = 0
 	log_message = 'Lang Alert Not expired'
Detail
	log_retval = 100
	log_misc1 = cnvtstring(diff)
 	log_message = build2('Lang Alert expired - ', log_misc1, 'Hrs')
With nocounter, nullreport go

=======================================================================================

/*

select into 'nl:'
diff = datetimediff(sysdate, paa.beg_effective_dt_tm,3), paa.beg_effective_dt_tm, paa.end_effective_dt_tm
,diff_alert = datetimediff(sysdate, pa.beg_effective_dt_tm,3), paa.action_type_txt
 ,pa.person_id, pa.encntr_id, pa.beg_effective_dt_tm, pa.end_effective_dt_tm, pa.*
, paa.*

from passive_alert pa
, (left join passive_alert_action paa on paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS')
plan pa where pa.person_id = 22386109.00 ;trigger_personid
	and pa.active_ind = 1
	and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	and pa.alert_removal_source is null
	
join paa 

;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

	
Head report 
 	log_retval = 0
 	log_misc1 = 'Head Report Section...'
 	log_message = 'Deaf Alert Not expired'
 	call echo(build('enc = ',pa.encntr_id))
Detail
	call echo(build2('enc inside = ',pa.encntr_id))
	if((paa.action_type_txt = 'DISMISS')and (diff < 48.00))
	 	log_retval = 0
	 	log_misc1 = cnvtstring(diff)
	 	log_message = build2('Deaf Dismisel Found, Timer Not expired - ', log_misc1, 'Hrs')
	elseif((paa.action_type_txt = 'DISMISS')and (diff >= 48.00))	 	
		log_retval = 100
		log_misc1 = cnvtstring(diff)
	 	log_message = build2('Deaf Dismisel Found, Timer Expired - ', log_misc1, 'Hrs')
	elseif((paa.action_type_txt = '')and (diff_alert >= 48.00))
		log_retval = 100
		log_misc1 = cnvtstring(diff_alert)
	 	log_message = build2('Deaf Alert expired - ', log_misc1, 'Hrs')
 	elseif((paa.action_type_txt = '')and (diff_alert < 48.00))
		log_retval = 0
		log_misc1 = cnvtstring(diff_alert)
	 	log_message = build2('Deaf Alert Not expired - ', log_misc1, 'Hrs')
	endif
With nocounter;, nullreport go



/*
select into 'nl:' 
from clinical_event ce
plan ce where ce.encntr_id = 130143712.00 ;trigger_encntrid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ce1.result_val = 'Patient declined'
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
Head report 
 	log_retval = 0
 	log_message = 'Patient declined Not Found'
Head ce.event_id
 	log_retval = 100
	log_misc1 = ce.result_val
 	log_message = build2('Decline Status found - ', log_misc1)
With nocounter;, nullreport go



/*
select ;into 'nl:' 
ce.encntr_id, ce.event_cd, ce.result_val
from clinical_event ce
plan ce where ce.encntr_id = 130143712.00 ;trigger_encntrid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ce1.result_val != 'Patient declined'
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
	
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


	
Head report 
 	log_retval = 0
	log_misc1 = cnvtstring(log_retval)
 	log_message = build2('Interpreter Request Not Found - ', log_misc1)
Head ce2.event_id
 	log_retval = 100
	log_misc1 = ce2.result_val
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter, nullreport go


select ;distinct ce1.encntr_id 
max(ce1.encntr_id) 
from clinical_event ce1 
where ce1.person_id = 22376109.00
group by ce1.person_id

ENCNTR_ID
  130141712.00
  130143712.00
  130141715.00


/*
select ;into 'nl:'
diff = datetimediff(sysdate, paa.beg_effective_dt_tm,3)
,diff1 = datetimecmp(datetimetrunc(cnvtdatetime(curdate,curtime3), "HH"), paa.beg_effective_dt_tm)
, pa.person_id, pa.encntr_id, pa.beg_effective_dt_tm, pa.end_effective_dt_tm
, paa.*

from passive_alert pa, passive_alert_action paa;, dummyt d
plan pa where pa.person_id = 22376109.00 ;trigger_personid
	and pa.active_ind = 1
	;and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	and pa.alert_removal_source is null
	
join paa where paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS'

join d where datetimediff(sysdate, paa.beg_effective_dt_tm,3) >= 48.00
	
Head report 
 	log_retval = 0
 	log_message = 'Deaf Alert Not expired'
Detail
	log_retval = 100
	log_misc1 = cnvtstring(diff)
 	log_message = build2('Deaf Alert expired - ', log_misc1, 'Hrs')
With nocounter;, nullreport go

/*
select * 
from passive_alert_action paa
where paa.passive_alert_id in(9032493.00,9034493.00,9030493.00)
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select *
from passive_alert pa
where pa.passive_alert_id = 9034493.00
;and pa.active_ind = 1

select trunc_date = datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "dd") ';;q' 
, today_dt = datetimetrunc(cnvtdatetime(curdate,curtime3), "dd") ';;q' , sysdate ';;q'
, t1 = cnvtdatetime(curdate, 0) ';;q' ,t2= cnvtdatetime(curdate, 235959) ';;q'
from dummyt



/*
INCLUDE THE ALERT SOURCE = 'COV_OC*'

select ;into 'nl:'
pa.person_id, pa.encntr_id, pa.passive_alert_id, pa.beg_effective_dt_tm ';;q', pa.end_effective_dt_tm ';;q', pa.alert_source
, pa.active_ind;, trunc_beg_dt = datetimetrunc(cnvtdatetime(pa.end_effective_dt_tm), "dd") ';;q' 
,pa.alert_txt, diff = datetimecmp(datetimetrunc(cnvtdatetime(curdate,curtime3), "dd"), pa.end_effective_dt_tm)

from passive_alert pa
plan pa where pa.person_id = 22376109.00 ;trigger_personid
	and pa.active_ind = 1
	;and pa.alert_source in('COV_SZ_SCHREG_INTER*', 'COV_SZ_INTERP_REMINDE*')
	;and pa.alert_txt = 'DEAF/HOH: Interpreter needed'
	and pa.alert_removal_source is null
	and datetimecmp(datetimetrunc(cnvtdatetime(curdate,curtime3), "dd"), pa.end_effective_dt_tm) >= 0 
	;and pa.end_effective_dt_tm between cnvtdatetime(curdate, 0) and cnvtdatetime(curdate, 235959)

Head report 
 	log_retval = 0
 	log_message = 'Alert Not expiring today'
Detail
	log_retval = 100
 	log_message = 'Alert expiring today'
With nocounter, nullreport go



select trunc_date = datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "dd") ';;q' 
, today_dt = datetimetrunc(cnvtdatetime(curdate,curtime3), "dd") ';;q' , sysdate ';;q'
, t1 = cnvtdatetime(curdate, 0) ';;q' ,t2= cnvtdatetime(curdate, 235959) ';;q'
from dummyt


select * from encounter e where e.encntr_id =   130141715.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


/*
select into "nl:"
pt.n_person_id, pt.n_encntr_id, pt.n_language_cd, pp.interp_required_cd
,lang_disp = trim(uar_get_code_display(pt.n_language_cd))

from person_patient pp, pm_transaction pt

plan pt where pt.n_encntr_id = 130141715.00 ;trigger_encntrid

join pp where pp.person_id = pt.n_person_id
	and pp.interp_required_cd = value(uar_get_code_by("DISPLAY", 329, "Yes"))
	
Head report
	log_retval = 0
	log_message = "Interpreter Request not found"
Detail
	log_retval = 100
	 if(lang_disp = 'Sign Language')
 	     	log_misc1 = 'DEAF/HOH: Interpreter needed'
 	else
 		log_misc1 = 'LANGUAGE: Interpreter needed'
 	endif	
 	log_message = build2(trim(lang_disp), ', Request Found - ', log_misc1)
With nocounter;, nullreport go


;   22376109.00	 130141715.00

;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


/*

select into 'nl:'
;pa.person_id, pa.encntr_id, pa.passive_alert_id, pa.end_effective_dt_tm ';;q', pa.alert_source
;, trunc_beg_dt = datetimetrunc(cnvtdatetime(pa.end_effective_dt_tm), "dd") ';;q' 

from passive_alert pa

plan pa where pa.person_id = 22376109.00 ;trigger_personid
	and pa.active_ind = 1
	and pa.alert_source in('COV_SZ_SCHREG_INTER*', 'COV_SZ_INTERP_REMINDE*')
	and pa.alert_txt in('LANGUAGE: Interpreter needed', 'DEAF/HOH: Interpreter needed')
	and pa.alert_removal_source is null
	and pa.end_effective_dt_tm between cnvtdatetime(curdate, 0) and cnvtdatetime(curdate, 235959)
	
Head report 
 	log_retval = 0
 	log_message = 'Alert Not expiring today'
Detail
	log_retval = 100
 	log_message = 'Alert expiring today'
With nocounter;, nullreport go
	
	
/*	
	
select trunc_date = datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "dd") ';;q' 
, today_dt = datetimetrunc(cnvtdatetime(curdate,curtime3), "dd") ';;q' , sysdate ';;q'
, t1 = cnvtdatetime(curdate, 0) ';;q' ,t2= cnvtdatetime(curdate, 235959) ';;q'
from dummyt
	
	
join paa where paa.passive_alert_id = pa.passive_alert_id	
	and paa.action_type_txt = 'DISMISS'
	
;and ((datetimetrunc(cnvtdatetime(pa.end_effective_dt_tm), "dd")) = (datetimetrunc(cnvtdatetime(curdate,curtime3), "dd")))
	



PASSIVE_ALERT_ACTION_ID	PASSIVE_ALERT_ID	ACTION_TYPE_TXT	PRSNL_ID	BEG_EFFECTIVE_DT_TM	END_EFFECTIVE_DT_TM
             9036493.00	      9034493.00	DISMISS	   12428721.00	09-06-2022 15:14:10	12-31-2100 00:00:00




/*
  ;125218890.00 - zzmock, crista
  ;125348890  - zzztest, medication
  
  select ;into 'nl:'
  sed.oe_field_id, sed.oe_field_display_value, sed.*
from sch_appt sa, sch_event_detail sed;, oe_field_meaning ofm
plan sa where sa.encntr_id = 125487173;125486924 ;trigger_encntrid
	and sa.active_ind = 1
join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
	and sed.oe_field_display_value in('Yes - Deaf/HOH')
	and sed.active_ind = 1
join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id

Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
	log_misc1 = sed.oe_field_display_value
	log_retval = 100
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go
  
  
  ;125486924
  /*
 select into 'nl:'
from sch_appt sa, sch_event_detail sed, oe_field_meaning ofm
plan sa where sa.encntr_id = 125487176                ;trigger_encntrid
	and sa.active_ind = 1
join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
	and sed.oe_field_display_value in('Yes - Language other than English', 'Yes - Deaf/HOH')
	and sed.active_ind = 1
join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id

Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
 	if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
 		log_misc1 = 'DEAF/HOH: Interpreter needed'
 	elseif (sed.oe_field_display_value = 'Yes - Language other than English')	
 		log_misc1 = 'LANGUAGE: Interpreter needed'
 	endif	
	log_retval = 100
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go 
  
  
 /* 

select into 'nl:'
from sch_appt sa, sch_event_detail sed, oe_field_meaning ofm
plan sa where sa.encntr_id = trigger_encntrid
	and sa.active_ind = 1
join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
	and sed.oe_field_display_value in('Yes - Language other than English', 'Yes - Deaf/HOH')
	and sed.active_ind = 1
join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id

Head report 
 	log_retval = 0
 	log_message = 'Interpreter Request Not Found'
Detail
 	if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
 		log_misc1 = 'DEAF/HOH: Interpreter needed'
 	elseif (sed.oe_field_display_value = 'Yes - Language other than English')	
 		log_misc1 = 'LANGUAGE: Interpreter needed'
 	endif	
	log_retval = 100
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go

/*
select into 'nl:'
from pm_transaction pm 
plan pm where pm.n_encntr_id = 125487113.00 ;trigger_encntrid
and pm.n_encntr_type_cd = value(uar_get_code_by("DISPLAY", 71, "Scheduled"))
Head report 
 	log_retval = 0
 	log_message = 'Patient Schedule Not Found'
Detail
	log_retval = 100
 	log_message = 'Patient Schedule Found'
With nocounter, nullreport go

/*
select into 'nl:'
;pm.n_encntr_type_cd, pm.n_encntr_type_class_cd, pm.* 
from pm_transaction pm 
plan pm where pm.n_encntr_id = 125486519.00
and pm.n_encntr_type_cd = value(uar_get_code_by("DISPLAY", 71, "Scheduled"))
;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

Head report 
 	log_retval = 0
 	log_message = 'Patient Schedule Not Found'
Detail
	log_retval = 100
 	log_message = 'Patient Schedule Found'
With nocounter;, nullreport go 
  
 /* 
select ;into 'nl:' 
ce.encntr_id, ce.verified_dt_tm ';;q', ce.result_val, ce.event_id, ce.parent_event_id
;, ce2.parent_event_id, ce2.result_val, ce2.verified_dt_tm ';;q'
from clinical_event ce;, clinical_event ce2
plan ce where ce.encntr_id = 125348890  ;trigger_encntrid
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ce1.result_val in('Video interpretation', 'In-person interpretation', 'Telephone interpretation')
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
	
join ce2 where ce2.encntr_id = ce.encntr_id
	and ce2.parent_event_id = ce.parent_event_id
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
	and ce2.result_val in('Deaf', 'Hearing impaired, left ear', 'Hearing impaired, right ear', 'Other Language Preferred')
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
order by ce2.encntr_id, ce2.event_id	

Head report 
 	retval = 0
	log_misc1 = ce2.result_val
 	log_message = build2('Interpreter Request Not Found - ', log_misc1)
Head ce2.event_id
 	retval = 100
	log_misc1 = ce2.result_val
 	log_message = build2('Interpreter Request Found - ', log_misc1)
With nocounter;, nullreport go



/*
select into "nl:"
from person_patient pp
plan pp where pp.person_id = trigger_personid
	and pp.interp_required_cd = is not null
	and pp.updt_dt_tm 
Head report
	retval = 0
	log_message = "Interpreter Request Found"
Detail
	retval = 100
	log_misc1 = uar_get_code_display(pp.interp_required_cd)
 	log_message = build2('Interpreter Request - ', log_misc1)
With nocounter, nullreport go

/*
;Clinical Doc
select into 'nl:' 
from clinical_event ce2
plan ce2 where ce2.encntr_id = 125474550 ;trigger_encntrid
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
Head report 
 	retval = 0
 	log_message = 'Doc Not Found for this encounter'
Detail
 	retval = 100
 	log_misc1 = ce2.result_val
 	log_message = build2('Doc Found for this encounter - ', log_misc1)

With nocounter;, nullreport go
*/


;-----------------------------------------------------------------------
;========================================================================================================

;call echo(build2('encntrid_var = ', encntrid_var))
call echo(build2('log_retval = ', log_retval))
call echo(build2('log_message = ', log_message))
call echo(build2('log_misc1 = ', log_misc1))

end go






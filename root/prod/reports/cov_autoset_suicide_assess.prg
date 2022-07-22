/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Feb'2020
	Solution:			Quality
	Source file name:  	cov_autoset_suicide_assess.prg
	Object name:		cov_autoset_suicide_assess
	CR#:				7063
	Program purpose:		Supporting CCL for cov_phq_suicide_risk_assment.prg
	Executing from:		CCL
  	Special Notes:		Used to get prsnl and their work location
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
******************************************************************************/
 
drop program cov_autoset_suicide_assess:dba go
create program cov_autoset_suicide_assess:dba
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare position_var = vc with noconstant(' ')
declare work_location_var = vc with noconstant(' ')
declare tmp_loc1 = vc with noconstant(' ')
declare tmp_loc2 = vc with noconstant(' ')
declare tmp_loc3 = vc with noconstant(' ')
declare tmp_loc4 = vc with noconstant(' ')
declare tmp_pos1 = vc with noconstant(' ')
declare tmp_pos2 = vc with noconstant(' ')
declare tmp_pos3 = vc with noconstant(' ')
declare tmp_pos4 = vc with noconstant(' ')
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
;create the AutoSet subroutines
execute ccl_prompt_api_dataset "autoset"
 
;--------------------------------------------------------------------------------------------
;Get user's work location and position
 
select into 'nl:'
 
p.name_full_formatted, p.username, loc = os.name
,pos = uar_get_code_display(p.position_cd)
 
from
	 prsnl p
      ,org_set_prsnl_r o
      ,org_set os
 
plan p where p.active_ind = 1
	and p.person_id = reqinfo->updt_id
	;and p.username = 'CDAY2'
 
join o where o.prsnl_id = p.person_id
	and o.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between o.beg_effective_dt_tm and o.end_effective_dt_tm
 
join os where os.org_set_id = o.org_set_id
	and os.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between os.beg_effective_dt_tm and os.end_effective_dt_tm
 
Head p.updt_id
	tmp_loc1 = '', tmp_loc2 = '', tmp_loc3 = '', tmp_loc4 = ''
	tmp_pos1 = '', tmp_pos2 = '', tmp_pos3 = '', tmp_pos4 = ''
Detail
	if(loc = 'All Facilities (with BH)')
		tmp_loc1 = loc
		tmp_pos1 = pos
	elseif(loc = 'MHHS Senior BH Unit')
		tmp_loc2 = loc
		tmp_pos2 = pos
	elseif(loc = 'PW Senior BH Unit')
		tmp_loc3 = loc
		tmp_pos3 = pos
	else
		tmp_loc4 = loc
		tmp_pos4 = pos
	endif
 
Foot p.updt_id
 
	if(tmp_loc1 != '')
		work_location_var = tmp_loc1
		position_var = tmp_pos1
	elseif(tmp_loc2 != '')
		work_location_var = tmp_loc2
		position_var = tmp_pos2
	elseif(tmp_loc3 != '')
		work_location_var = tmp_loc3
		position_var = tmp_pos3
	elseif(tmp_loc4 != '')
		work_location_var = tmp_loc4
		position_var = tmp_pos4
	endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get user related locations - prompt
 
select
;All location with BH
if(work_location_var = 'All Facilities (with BH)' and position_var = 'BH - Nurse*' or position_var = 'DBA'
		or position_var = 'BH - Family Nurse Practitioner' or position_var = 'BH - Ambulatory RN/LPN'
	 	or position_var = 'IT - Advanced Access PC' or position_var = 'BH - Therapist/Psychologist'
	 	or position_var = 'Nurse - Supervisor' or position_var = 'IT - PowerChart'
	 	or position_var = 'IT - Perioperative' or position_var = 'Quality Manager')
	where l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00
		,2552503649.00, 2553765475.00, 2553765531.00)
;MHHS
elseif(work_location_var = 'MHHS Senior BH Unit' and position_var = 'BH - Nurse*' or position_var = 'DBA'
		or position_var = 'BH - Family Nurse Practitioner' or position_var = 'BH - Ambulatory RN/LPN'
	 	or position_var = 'IT - Advanced Access PC' or position_var = 'BH - Therapist/Psychologist'
	 	or position_var = 'Nurse - Supervisor' or position_var = 'IT - PowerChart'
	 	or position_var = 'IT - Perioperative' or position_var = 'Quality Manager')
	where l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00
				  ,2552503649.00,2553765475)
;PW
elseif(work_location_var = 'PW Senior BH Unit' and position_var = 'BH - Nurse*' or position_var = 'DBA'
		or position_var = 'BH - Family Nurse Practitioner' or position_var = 'BH - Ambulatory RN/LPN'
	 	or position_var = 'IT - Advanced Access PC' or position_var = 'BH - Therapist/Psychologist'
	 	or position_var = 'Nurse - Supervisor' or position_var = 'IT - PowerChart'
	 	or position_var = 'IT - Perioperative' or position_var = 'Quality Manager')
	where l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00
				  ,2552503649.00,2553765531.00)
;All location without BH
elseif(work_location_var = 'All Facilities (no BH)' or position_var != 'BH - Nurse*' or position_var != 'DBA'
		or position_var != 'BH - Family Nurse Practitioner'  or position_var != 'BH - Ambulatory RN/LPN'
	 	or position_var != 'IT - Advanced Access PC' or position_var != 'BH - Therapist/Psychologist'
	 	or position_var != 'Nurse - Supervisor' or position_var != 'IT - PowerChart'
	 	or position_var != 'IT - Perioperative' or position_var != 'Quality Manager')
	where l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00
				,2552503649.00)
endif
 
into 'nl:'
 
	facility = uar_get_code_description(l.location_cd)
	, l.location_cd
 
from location l
	where l.location_type_cd = 783.00
	and l.active_ind = 1
 
order by facility
 
Head report
	stat = MakeDataSet(10)
Detail
	stat = WriteRecord(0)
Foot report
	stat = CloseDataSet(0)
 
with ReportHelp, Check
 
 
;--------------------------------------------------------------------------------------------
 
end go
 
/*
;get org cd
select o.organization_id, o.org_name, l.location_cd
from organization o, location l
where o.organization_id = l.organization_id
and l.location_type_cd = 783.00
and l.active_ind = 1
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00)
 
;get location cd
select loc = uar_get_code_display(l.location_cd), l.location_cd
from organization o, location l
where o.organization_id = l.organization_id
and l.location_type_cd = 783.00
and l.active_ind = 1
and l.organization_id in(3234068.00, 3234061.00)
 
;MHHS Behav Hlth	 2553765475.00
;PW Senior Behav	 2553765531.00
 
;get Org info with org id's
select o.organization_id, o.org_name
from organization o where o.organization_id in(
675844.00, 3144499.00, 3144501.00, 3144502.00, 3144503.00, 3144504.00, 3144505.00, 3234074.00, 3234068.00, 3234061.00)
 
 
/***** Testing code - to get users from a location.
 
select
 
p.name_full_formatted, p.username, loc = os.name
 ,pos = uar_get_code_display(p.position_cd)
 
from
	 prsnl p
      ,org_set_prsnl_r o
      ,org_set os
 
plan p where p.active_ind = 1
	and p.position_cd =     4346303.00
	;and p.person_id = 16719851.00 ;reqinfo->updt_id
	;and cnvtlower(p.username) in('mcolli11', 'ycollier','aphill19', 'aseals3', 'ataylor4', 'kgreen12')
 
join o where o.prsnl_id = p.person_id
  and o.active_ind = 1
  and cnvtdatetime(curdate, curtime3) between o.beg_effective_dt_tm and o.end_effective_dt_tm
 
join os where os.org_set_id = o.org_set_id
  and os.active_ind = 1
  and cnvtdatetime(curdate, curtime3) between os.beg_effective_dt_tm and os.end_effective_dt_tm
  ;and os.name like "PW S*"
  and os.name like "MHHS S*"
 
******/
 
 
 
 
 
 
 
 
 

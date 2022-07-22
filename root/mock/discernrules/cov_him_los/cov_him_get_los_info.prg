/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/23/2022
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_get_los_info.prg
	Object name:		cov_him_get_los_info
	Request #:			12871
 
	Program purpose:	Gets information for length of stay.
 
	Executing from:		Discern Rules
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/

drop program cov_him_get_los_info:dba go
create program cov_him_get_los_info:dba

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare los_var		= i4 with constant(35)


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record t_rec
record t_rec
(
	1 log_message		= vc
	1 misc1				= vc
	1 retval			= i2
	1 continue_ind		= i2
	1 encntr_id			= f8
	1 person_id			= f8
	1 patient_name		= vc
	1 fin				= vc
	1 los				= i4
)

set t_rec->retval			= -1 ;initialize to failed
set t_rec->continue_ind		= 0
set t_rec->encntr_id		= link_encntrid

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)), ":", trim(cnvtstring(t_rec->encntr_id)))

if (t_rec->encntr_id = 0.0)
	go to exit_script
endif


/**************************************************************/ 
; select encounter data
select into "nl:" 
from 
	ENCOUNTER e 
	, PERSON p
	, ENCNTR_ALIAS ea
	
plan e
where 
	e.encntr_id = t_rec->encntr_id

join p
where 
	p.person_id = e.person_id
	
join ea
where 
	ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING", 319, "FIN NBR"))
	and ea.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
	and ea.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
		
order by
	e.encntr_id
	, ea.beg_effective_dt_tm desc
	
head e.encntr_id
	t_rec->person_id		= e.person_id
	t_rec->fin				= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->patient_name		= p.name_full_formatted
	
	t_rec->los = if (e.disch_dt_tm > cnvtdatetime(curdate, curtime))
					(curdate - cnvtdate(e.reg_dt_tm))
				 else
					(cnvtdate(nullval(e.disch_dt_tm, cnvtdatetime(curdate, curtime))) - 
					 cnvtdate(nullval(e.reg_dt_tm, cnvtdatetime(curdate, curtime))))
				 endif
	
with nocounter


set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtstring(t_rec->person_id)))

if (t_rec->person_id = 0.0)
	go to exit_script
else
	if (t_rec->los >= los_var)		
		set t_rec->misc1 = build2("Patient’s length of stay is greater than or equal to 35 days.",
								  " @NEWLINE ",
								  "Please generate release in sections.")

		set t_rec->retval = 100
	else
		set t_rec->retval = 0
	endif
endif  


/**************************************************************/ 
; finalize

#exit_script

set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtrectojson(t_rec)))

set retval			= t_rec->retval
set log_misc1		= t_rec->misc1
set log_message		= t_rec->log_message

call echorecord(t_rec)

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end go


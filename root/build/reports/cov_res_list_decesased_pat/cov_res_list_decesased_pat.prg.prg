/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Scheduling
  Source file name:   cov_res_list_with_address.prg
  Object name:        cov_res_list_with_address
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_res_list_decesased_pat go
create program cov_res_list_decesased_pat

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Resource" = 0 

with OUTDEV, RESOURCE_CD


select into $OUTDEV
   BEGIN_DATE = a.beg_dt_tm ";;q",
   DURATION = a.duration,
   ea.alias,
   PERSON_NAME = p.name_full_formatted,
   p.deceased_dt_tm ";;q"
   APPT_TYPE = e.appt_synonym_free,
   STATE = uar_get_code_display(a.sch_state_cd),
   address_type=uar_get_code_display(aa.address_type_cd),
   street = concat(trim(aa.street_addr)," ",trim(aa.street_addr2)," ",trim(aa.street_addr3)," ",trim(aa.street_addr4)),
   city = trim(aa.city),
   state=uar_get_Code_display(aa.state_cd),
   zip=trim(aa.zipcode),
SCHEVENTID = a.sch_event_id,
SCHEDULEID = a.schedule_id,
STATEMEANING = a.state_meaning,
ENCOUNTERID = ep.encntr_id,
PERSONID = ep.person_id


from
   sch_resource r,
   sch_appt a,
   sch_event e,
   sch_event_patient ep,
   person p ,
   encntr_alias ea,
   address aa,
   dummyt d1

plan r where
   r.resource_cd = $RESOURCE_CD ;2817288369.00; $1 ;14231

join a where
   a.person_id = r.person_id
    and a.resource_cd = r.resource_cd
    ;and a.beg_dt_tm < cnvtdatetime($3)
    ;and a.end_dt_tm > cnvtdatetime($2)
    and a.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    and a.state_meaning != "RESCHEDULED"
    and a.active_ind = 1
    and a.role_meaning != "PATIENT"

join e where
   e.sch_event_id = a.sch_event_id
    and e.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")

join ep where
   ep.sch_event_id = e.sch_event_id
    and ep.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")

join p where
   p.person_id = ep.person_id
   and p.deceased_cd in( value(uar_get_code_by("MEANING",268,"YES")))
join aa
	where  aa.parent_entity_id = p.person_id
	and    aa.address_type_cd =         756.00	;Home
	and    aa.active_ind = 1
	and    aa.beg_effective_dt_tm <=cnvtdatetime(curdate,curtime3)
	and    aa.end_effective_dt_tm >=cnvtdatetime(curdate,curtime3)
join d1
join ea
	where ea.encntr_id = ep.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.active_ind = 1
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by a.beg_dt_tm
with outerjoin=d1,format, separator = " "
end 
go


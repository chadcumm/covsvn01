/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   cov_him_antic_ed_scribe_rpt.prg
  Object name:        cov_him_antic_ed_scribe_rpt
  Request #:

  Program purpose:

  Executing from:    CCL

  Special Notes:     Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer             Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_him_antic_auth_rpt:dba go
create program cov_him_antic_auth_rpt:dba

prompt
  "Output to File/Printer/MINE" = "MINE"

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0  ;do not create log = 1    , create log = 0
set noaudvar = 1  ;do not create audit = 1  , create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
  1 text = vc
  1 status_data
   2 status = c1
   2 subeventstatus[1]
    3 operationname = c15
    3 operationstatus = c1
    3 targetobjectname = c15
    3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
  1 cnt      = i4
  1 doc_cnt    = i4
  1 task_assay_Cd = f8
  1 doc_qual[*]
   2 event_cd    = f8
  1 qual[*]
   2 event_id    = f8
   2 event_cd    = f8
   2 antcipated_dt_tm = dq8
   2 encntr_id  = f8
   2 patient_name = vc
   2 person_id    = f8
   2 fin      = vc
   2 cmrn      = vc
   2 encntr_status = f8
   2 encntr_type = f8
   2 deficient  = i2
   2 auth_dt_tm    = dq8
   2 auth_event_id  = f8
   2 loc_facility_cd = f8
   2 loc_nurse_unit_cd = f8

)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* START Finding Document IDs   ****************************"))

select into "nl:"
from
  code_value cv
plan cv
  where cv.code_set = 72
  and   cv.active_ind  = 1
  and   cv.code_value in(
                code_values->cv.cs_72.ed_note_physician
  )
order by
  cv.code_value
head report
  t_rec->doc_cnt = 0
head cv.code_value
  t_rec->doc_cnt = (t_rec->doc_cnt + 1)
  stat = alterlist(t_rec->doc_qual,t_rec->doc_cnt)
  t_rec->doc_qual[t_rec->doc_cnt].event_cd = cv.code_value
with nocounter

call writeLog(build2("* END   Finding Document IDs    ****************************"))

call writeLog(build2("* START Finding Clinical Events ****************************"))

for (i = 1 to t_rec->doc_cnt)
  call writeLog(build2("--> Searching for:",trim(uar_get_code_display(t_rec->doc_qual[i].event_cd))," ******************"))
  select into "nl:"
  from
    clinical_event ce
    ,prsnl p1
  plan ce
    where ce.result_status_cd   = code_values->cv.cs_8.anticipated_cd
    and   ce.valid_until_dt_tm   = cnvtdatetime ("31-DEC-2100 00:00:00")
    and   ce.event_cd       = t_rec->doc_qual[i].event_cd
  join p1
  	where p1.person_id = ce.verified_prsnl_id
  	and   p1.physician_ind != 1
  order by
     ce.event_cd
    ,ce.event_id
  head report
    stat = 0
  head ce.event_id
    t_rec->cnt = (t_rec->cnt + 1)
    stat = alterlist(t_rec->qual,t_rec->cnt)
    t_rec->qual[t_rec->cnt].event_id       = ce.event_id
    t_rec->qual[t_rec->cnt].event_cd       = ce.event_cd
    t_rec->qual[t_rec->cnt].antcipated_dt_tm  = ce.event_end_dt_tm
    t_rec->qual[t_rec->cnt].encntr_id      = ce.encntr_id
  foot report
    stat = 1
  with nocounter
endfor
call writeLog(build2("* END   Finding Clinical Events ****************************"))

call writeLog(build2("* START Finding ED Provider Patient Seen Documents ********************"))

select into "nl:"
from
   clinical_event ce1
  ,clinical_event ce2
  ,(dummyt d1 with seq = t_rec->cnt)
plan d1
join ce1
  where ce1.event_id         = t_rec->qual[d1.seq].event_id
join ce2
  where ce2.encntr_id        = ce1.encntr_id
  and   ce2.event_cd        = ce1.event_cd
  and   ce2.result_status_cd     = code_values->cv.cs_8.auth_cd
  and   ce2.valid_until_dt_tm   = cnvtdatetime ("31-DEC-2100 00:00:00")
  and   ce2.event_id        != ce1.event_id
order by
  ce1.event_id
head report
  stat = 0
head ce1.event_id
  t_rec->qual[d1.seq].deficient     = 1
  t_rec->qual[d1.seq].auth_event_id   = ce2.event_id
  t_rec->qual[d1.seq].auth_dt_tm    = ce2.event_end_dt_tm
  call writeLog(build2("-->Found same document on encounter:",trim(cnvtstring(ce1.encntr_id)), " *******************"))
foot report
  stat = 1
with nocounter

call writeLog(build2("* END   Finding Authenticated Documents ********************"))


call writeLog(build2("* START Finding Demographics   ****************************"))

select into "nl:"
from
   encounter e
  ,person p
  ,encntr_alias ea
  ,person_alias pa
  ,(dummyt d1 with seq=t_rec->cnt)
plan d1
  where t_rec->qual[d1.seq].deficient in(1,0)
join e
  where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p
  where p.person_id = e.person_id
join ea
  where ea.encntr_id = e.encntr_id
  and   ea.active_ind = 1
  and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
join pa
  where pa.person_id = p.person_id
  and   pa.active_ind = 1
  and   pa.person_alias_type_cd = code_values->cv.cs_4.community_medical_record_number_cd
order by
   e.encntr_id
  ,ea.end_effective_dt_tm
  ,pa.end_effective_dt_tm
head report
  stat = 0
detail
  t_rec->qual[d1.seq].patient_name    = p.name_full_formatted
  t_rec->qual[d1.seq].cmrn        = pa.alias
  t_rec->qual[d1.seq].fin          = ea.alias
  t_rec->qual[d1.seq].encntr_status    = e.encntr_status_cd
  t_rec->qual[d1.seq].encntr_type      = e.encntr_type_cd
  t_rec->qual[d1.seq].person_id      = p.person_id
  t_rec->qual[d1.seq].loc_facility_cd    = e.loc_facility_cd
  t_rec->qual[d1.seq].loc_nurse_unit_cd  = e.loc_nurse_unit_cd
  call writeLog(build2("-->Found Encounter Info for:",trim(cnvtstring(e.encntr_id)),":",trim(ea.alias)))
with nocounter


call writeLog(build2("* END   Finding Demographics   ****************************"))


call writeLog(build2("* START Generating Report **********************************"))

select into $OUTDEV
   facility          = uar_get_code_display(t_rec->qual[d1.seq].loc_facility_cd)
  ,unit            = uar_get_code_display(t_rec->qual[d1.seq].loc_nurse_unit_cd)
  ,fin             = t_rec->qual[d1.seq].fin
  ,patient           = t_rec->qual[d1.seq].patient_name
  ,anticipated_document     = uar_get_code_display(t_rec->qual[d1.seq].event_cd)
  ,anticipated_dt_tm      = format(t_rec->qual[d1.seq].antcipated_dt_tm,";;q")
  ,authendicated_dt_tm    = format(t_rec->qual[d1.seq].auth_dt_tm,";;q")
  ,anticipated_id        = t_rec->qual[d1.seq].event_id
  ,authenticated_id      = t_rec->qual[d1.seq].auth_event_id
from
  (dummyt d1 with seq=t_rec->cnt)
order by
   facility
  ,anticipated_document
  ,anticipated_dt_tm
with nocounter, FORMAT, SEPARATOR = " "


call writeLog(build2("* END   Generating Report **********************************"))

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)

call echo("cov_him_antic_auth_rpt finish")
end
go

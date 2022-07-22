drop program cov_sample_smart_template go
create program cov_sample_smart_template
 
set nologvar = 1	;do not create log
set noaudvar = 1	;do not create audit
%i ccluserdir:cov_custom_ccl_common.inc
call set_codevalues(null)
 
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
 
declare person_id = f8 with public, noconstant(0.0)
declare encntr_id = f8 with public, noconstant(0.0)
 
select into "nl:"
 e.person_id,
 e.encntr_id
from encounter e
plan e where e.encntr_id = request->visit[1].encntr_id
detail
 	person_id 	= e.person_id
	encntr_id 	= e.encntr_id
with nocounter
 
;RTF variables.
SET rhead   = concat('{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern Lucida Console;}}',
                  '{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134')
SET RH2r    = '\plain \f0 \fs18 \cb2 \pard\s10 '
SET RH2b    = '\plain \f0 \fs18 \b \cb2 \pard\s10 '
SET RH2bu   = '\plain \f0 \fs18 \b \ul \cb2 \pard\s10 '
SET RH2u    = '\plain \f0 \fs18 \u \cb2 \pard\s10 '
SET RH2i    = '\plain \f0 \fs18 \i \cb2 \pard\s10 '
SET REOL    = '\par '
SET Rtab    = '\tab '
SET wr      = '\plain \f0 \fs16 \cb2 '
SET ul      = '\ul '
SET wb      = '\plain \f0 \fs16 \b \cb2 '
SET wu      = '\plain \f0 \fs18 \ul \cb2 '
SET wi      = '\plain \f0 \fs18 \i \cb2 '
SET wbi     = '\plain \f0 \fs18 \b \i \cb2 '
SET wiu     = '\plain \f0 \fs18 \ul \i \cb2 '
SET wbiu    = '\plain \f0 \fs18 \b \ul \i \cb2 '
SET wbu     = '\plain \f0 \fs18 \b \ul \cb2 '
SET rtfeof  = '} '
SET bullet  = '\bullet '
 
;set reply->text = (concat(reply->text,concat(rhead,rh2bu,"Output from:",curprog,wr,reol)))
 
select into "nl:"
	date = format(ce.event_end_dt_tm, "mmm dd HH:MM;;d")
	,result_val = trim(ce.result_val)
	,event = uar_get_code_display(ce.event_cd)
from
	clinical_event ce
plan ce
	where ce.person_id		= person_id
	and   ce.encntr_id		= encntr_id
	and   ce.result_status_cd in(
									 code_values->cv.cs_8.altered_cd
									,code_values->cv.cs_8.auth_cd
									,code_values->cv.cs_8.modified_cd
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
	and   ce.valid_from_dt_tm >= cnvtdatetime(curdate-17,0)
order by
	 ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	cnt = 0
head ce.event_cd
	reply->text = (concat(reply->text,trim(ce.result_val)))
										;concat(trim(uar_get_code_display(ce.event_cd)),": ",trim(ce.result_val)
								;)))
with nocounter
 
#exit_script
;SET reply->text = CONCAT(reply->text, rtfeof)
 
call echorecord(reply)
 
end go
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_covid19_pos_admit.prg
	Object name:		cov_covid19_pos_admit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_covid19_pos_admit:dba go
create program cov_covid19_pos_admit:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
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
	1 cnt			= i4
	1 patient_cnt				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 cov_facility_alias		= vc
	 2 cov_unit_alias			= vc
	 2 cov_room_alias			= vc
	 2 cov_bed_alias			= vc
	 2 loc_facility_cd			= f8
	 2 loc_unit_cd				= f8
	 2 loc_room_cd				= f8
	 2 loc_bed_cd				= f8
	 2 loc_class_1				= vc
	 2 encntr_type_cd			= f8
	 2 expired_ind				= i2
	 2 expired_dt_tm			= dq8
	 2 reg_dt_tm				= dq8
	 2 disch_dt_tm				= dq8
	 2 inpatient_dt_tm			= dq8
	 2 observation_dt_tm		= dq8
	 2 arrive_dt_tm				= dq8
	 2 dob						= dq8
	 2 ip_los_hours				= i2
	 2 ip_los_days				= i2
	 2 fin						= vc
	 2 name_full_formatted		= vc
	 2 diagnosis				= vc
	 2 result					= vc
	 2 encntr_ignore			= i2
	 2 diagnosis_cnt			= i2
	 2 diagnosis_qual[*]
	  3 diagnosis_id			= f8
	  3 source_string			= vc
	  3 nomenclature_id			= f8
	  3 orig_nomenclature_id	= f8
	  3 orig_source_string		= vc
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Finding Encoutners with Positive Results ***********"))
select into "nl:"
from
	 clinical_event ce
	,encounter e
	,person p
plan ce
	where ce.event_cd in( 	  3350122787.00
							, 3350126077.00
							, 3355850351.00
							, 3358526621.00
							, 3361701755.00
							, 3361702989.00) 
	and ce.result_val in(
							"Detected","Positive","POSITIVE","DETECTED","Presumptive Positive","Presumptive Pos",
							"PRESUMPTIVE POSITIVE","PRESUMPTIVE POS"
						)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
join p
	where p.person_id = ce.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
join e
	where e.encntr_id = ce.encntr_id	
order by
	ce.encntr_id
head report
	call writeLog(build2("->inside result query"))
head ce.encntr_id
	call writeLog(build2("-->inside encntr_id=",trim(cnvtstring(ce.encntr_id))))
	t_rec->patient_cnt = (t_rec->patient_cnt + 1)
	stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
	t_rec->patient_qual[t_rec->patient_cnt].encntr_id 			= ce.encntr_id
	t_rec->patient_qual[t_rec->patient_cnt].person_id 			= ce.person_id
	t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm 		= e.arrive_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm 		= e.disch_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].dob 				= p.birth_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd		= e.encntr_type_cd
	t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm		= p.deceased_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm		= e.inpatient_admit_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd		= e.loc_facility_cd
	t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted = p.name_full_formatted
	t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm			= e.reg_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd			= e.loc_bed_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd			= e.loc_nurse_unit_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd			= e.loc_room_cd
	t_rec->patient_qual[t_rec->patient_cnt].result			   = ce.result_val	
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))))
foot report
	call writeLog(build2("->leaving result query"))	
with nocounter
call writeLog(build2("* END   Finding Encoutners with Positive Results ***********"))


call writeLog(build2("* START Finding Encoutners with Positive Results ***********"))
select into "nl:"
from
	 diagnosis d
	,encounter e
	,person p
plan d
	 where d.updt_dt_tm >= cnvtdatetime("01-MAR-2020") 
and ((d.originating_nomenclature_id in(
17897551,
17928672,
17955364,
57940454,
275219901,
275263647,
290002129,
290002153,
290002433,
290002441,
290002776)) or (d.nomenclature_id in(17897551,
17928672,
17955364,
57940454,
275219901,
275263647,
290002129,
290002153,
290002433,
290002441,
290002776)))
and d.active_ind = 1
and cnvtdatetime(curdate,curtime3) between d.beg_effective_dt_tm and d.end_effective_dt_tm
join p
	where p.person_id = d.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
join e
	where e.encntr_id = d.encntr_id	
order by
	d.encntr_id
head report
	call writeLog(build2("->inside result query"))
	pos = 0
head d.encntr_id
	call writeLog(build2("-->inside encntr_id=",trim(cnvtstring(d.encntr_id))))
	pos = locateval(i,1,t_rec->patient_cnt,d.encntr_id,t_rec->patient_qual[i].encntr_id)
	if (pos = 0)
		t_rec->patient_cnt = (t_rec->patient_cnt + 1)
		stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
		t_rec->patient_qual[t_rec->patient_cnt].encntr_id 			= d.encntr_id
		t_rec->patient_qual[t_rec->patient_cnt].person_id 			= d.person_id
		t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm 		= e.arrive_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm 		= e.disch_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].dob 				= p.birth_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd		= e.encntr_type_cd
		t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm		= p.deceased_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm		= e.inpatient_admit_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd		= e.loc_facility_cd
		t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted = p.name_full_formatted
		t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm			= e.reg_dt_tm
		t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd			= e.loc_bed_cd
		t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd			= e.loc_nurse_unit_cd
		t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd			= e.loc_room_cd
	endif
foot d.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(d.encntr_id))))
foot report
	call writeLog(build2("->leaving result query"))	
with nocounter
call writeLog(build2("* END   Finding Encoutners with Positive Results ***********"))

call writeLog(build2("* START Finding Diagnosis **********************************"))
select into "nl:"
from
	 diagnosis ea
	,nomenclature n
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.classification_cd in(
									 value(uar_get_code_by("MEANING",12033,"MEDICAL"))
									,value(uar_get_code_by("MEANING",12033,"PATSTATED"))
								 )
	and ((ea.originating_nomenclature_id in(
17897551,
17928672,
17955364,
57940454,
275219901,
275263647,
290002129,
290002153,
290002433,
290002441,
290002776)) or (ea.nomenclature_id in(17897551,
17928672,
17955364,
57940454,
275219901,
275263647,
290002129,
290002153,
290002433,
290002441,
290002776)))
join n
	where n.nomenclature_id = ea.nomenclature_id
order by
	 ea.encntr_id
	,ea.diagnosis_id
head report
	call writeLog(build2("->Inside diagnosis query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].diagnosis_cnt = (t_rec->patient_qual[j].diagnosis_cnt + 1)
	 	stat = alterlist(t_rec->patient_qual[j].diagnosis_qual,t_rec->patient_qual[j].diagnosis_cnt)
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].diagnosis_id 	= ea.diagnosis_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].nomenclature_id	= ea.nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].orig_nomenclature_id	= ea.originating_nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].source_string	= ea.diagnosis_display
	 	call writeLog(build2("--->added diagnosis=",trim(ea.diagnosis_display)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
		for (i=1 to t_rec->patient_qual[j].diagnosis_cnt)
	 	t_rec->patient_qual[j].diagnosis 
	 		= concat(t_rec->patient_qual[j].diagnosis,";",t_rec->patient_qual[j].diagnosis_qual[i].source_string)
		endfor
	endif
	j = 0
with nocounter

call writeLog(build2("* END Finding Diagnosis **********************************"))

call writeLog(build2("* START Finding FIN ****************************************"))
select into "nl:"
from
	 encntr_alias ea
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
order by
	 ea.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	call writeLog(build2("->Inside encntr_alias query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	 	call writeLog(build2("--->added fin nbr=",trim(t_rec->patient_qual[j].fin)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END   Finding FIN ****************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into $OUTDEV
	 loc_facility_cd		=substring(1,20,uar_get_code_display(t_rec->patient_qual[d1.seq].loc_facility_cd))
	,loc_nurse_unit_cd		= substring(1,20,uar_get_code_display(t_rec->patient_qual[d1.seq].loc_unit_cd))
	,loc_room_cd			= substring(1,20,uar_get_code_display(t_rec->patient_qual[d1.seq].loc_room_cd))
	,loc_bed_cd				= substring(1,20,uar_get_code_display(t_rec->patient_qual[d1.seq].loc_bed_cd))
	,name_full_formatted	= substring(1,100,t_rec->patient_qual[d1.seq].name_full_formatted)
	,birth_dt_tm			= format(t_rec->patient_qual[d1.seq].dob ,";;q")
	,fin					= substring(1,100,t_rec->patient_qual[d1.seq].fin)
	,encntr_type_cd			= substring(1,20,uar_get_code_display(t_rec->patient_qual[d1.seq].encntr_type_cd))
	,arrive_dt_tm			= format(t_rec->patient_qual[d1.seq].arrive_dt_tm,";;q")
	,reg_dt_tm				= format(t_rec->patient_qual[d1.seq].reg_dt_tm,";;q")
	,inpatient_admit_dt_tm	= format(t_rec->patient_qual[d1.seq].inpatient_dt_tm,";;q")
	,disch_dt_tm			= format(t_rec->patient_qual[d1.seq].disch_dt_tm,";;q")
	,deceased_dt_tm			= format(t_rec->patient_qual[d1.seq].expired_dt_tm,";;q")
	,result					= substring(1,100,t_rec->patient_qual[d1.seq].result)
	,diagnosis				= substring(1,150,t_rec->patient_qual[d1.seq].diagnosis)
	,encntr_id 				= substring(1,20,cnvtstring(t_rec->patient_qual[d1.seq].encntr_id ))
	,person_id 				= t_rec->patient_qual[d1.seq].person_id 

from
	(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
order by
	loc_facility_cd
with nocounter,separator=" ",format

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go

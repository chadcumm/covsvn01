drop program cov_test_ruleQuery go
create program cov_test_ruleQuery
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
/* 
;-----------------------------------------------------------------------------------------------------------------------
 
;Tobacco Cessation Education rule testing
 
;-----------------------------------------------------------------------------------------------------------------------
 
select distinct into $outdev
 
e.encntr_id, e.location_cd, uar_get_code_display(e.location_cd)
from encounter e
where e.encntr_type_cd in(309308, 2555137035)    ;inpa, psy
where e.loc_facility_cd in( 2555448351.00, 2556763627.00, 2556764139.00, 2556764387.00, 2556764619.00)
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxrec = 10000

*/ 

/*

select * from code_value cv where cv.display = "SHX*"

 
/*
ce.event_cd, uar_get_code_display(ce.event_cd), ce.result_val
from clinical_event ce
where ce.event_cd = 275233115.00
 
order by ce.encntr_id
*/

/* code values used

 (309308, 2555137035)    ;inpa, psy
  275233115.00	         72		SHX Tobacco use
 
2555448351.00	        220	NURSEUNIT	PBH UA	PBHUA	PBH UNIT A
2556763627.00	        220	NURSEUNIT	PBH UB	PBHUB	PBH UNIT B
2556764139.00	        220	NURSEUNIT	PBH UD	PBHUD	PBH UNIT D
2556764387.00	        220	NURSEUNIT	PBH UE	PBHUE	PBH UNIT E
2556764619.00	        220	NURSEUNIT	PBH UF	PBHUF	PBH UNIT F

/*
 
 
 
;-----------------------------------------------------------------------------------------------------------------------
 
;Bluecare Insurance rule testing
 
;-----------------------------------------------------------------------------------------------------------------------
 
select distinct into $outdev
 
 hp.plan_name
,hp.beg_effective_dt_tm
,hp.end_effective_dt_tm
,e.encntr_id
,fin = ea.alias
,patType = uar_get_code_display(e.encntr_type_cd)
,p.birth_dt_tm
,age = CNVTAGE(p.birth_dt_tm)
,ststus = uar_get_code_display(e.encntr_status_cd)
 
 
;,age = CNVTINT(CNVTALPHANUM(CNVTAGE(p.birth_dt_tm), 1))
 
,p.name_full_formatted
 
from health_plan hp, encntr_plan_reltn ep, encounter e, person p, encntr_alias ea
 
plan hp where (CNVTUPPER(hp.plan_name) = "BLUECARE*" OR CNVTUPPER(hp.plan_name) = "TENNCARE*")
	and hp.active_ind = 1
 
join ep where hp.health_plan_id = ep.health_plan_id
	;AND E.ENCNTR_ID = encntrid ;97733145.00
 
join e where e.encntr_id = ep.encntr_id
	and e.encntr_type_cd not in (309308.00, 309310.00, 2555267433.00, 309312.00, 2555137099.00, 2555137277.00, 2555137333.00)
	and e.encntr_status_cd = 854.00 ;Active
 
join ea where ea.encntr_id = e.encntr_id
	;and ea.alias = "1803900034"
 
join p where p.person_id = e.person_id
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxrec = 10000
 
*/
 
/*
 
 select hp.plan_name
 from health_plan hp, encntr_plan_reltn ep, encntr_alias ea
 where hp.health_plan_id = ep.health_plan_id
 and ea.encntr_id = ep.encntr_id
 and ea.alias = "1803900034"
 
 
 select * from encntr_alias where alias = "1803900034"
 encntr_id =    98674807.00
 
 select * from encntr_plan_reltn where encntr_id =    98674807.00
 
     309308.00	Inpatient
     309310.00	Emergency
    2555267433.00	Newborn
       309312.00	Observation
 2555137099.00	Contract
 2555137277.00	Quick ED Registration
  2555137333.00	Select Specialty
 
*/
 
 
 

;-----------------------------------------------------------------------------------------------------------------------
 
 
; Behavior Health - Addiction referral Rule test query
 
 
;----------------------------------------------------------------------------------------------------
 
 
select distinct into $outdev

  e.loc_facility_cd
 , loc = uar_get_code_display(e.loc_facility_cd)
, ea.alias
, type = uar_get_code_display(e.encntr_type_cd)
;, t1 = e.encntr_id
;, t2 = e.person_id
, t3 = ce.result_val
;, event = uar_get_code_display(ce.event_cd)
 
from encounter e, clinical_event ce, encntr_alias ea
 
plan e where e.encntr_type_cd in( 2555137051, 309308, 2555137035.00	)
	and e.loc_facility_cd in(2553765531, 2553765475, 2553765579)
 
join ea where ea.encntr_id = e.encntr_id
 
join ce where ce.encntr_id = e.encntr_id
	;and ce.event_cd = 21312453.00
 
;group by e.loc_facility_cd, ea.alias
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxrec = 1000
 

 
;----------------------------------------------------------------------------------------------------
 
 
 
 
end
go
 
 
 
 
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Aug 2021
	Solution:			Quality
	Source file name:	      cov_phq_midnight_census.prg
	Object name:		cov_phq_midnight_census
	Request#:			10984
	Program purpose:	      Midnight Census
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_phq_midnight_census:dba go
create program cov_phq_midnight_census:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Task Start Date" = "SYSDATE"
	, "Task End Date" = "SYSDATE"
	, "Select Facility" = 0
	, "Select Nurse Unit" = 0 

with OUTDEV, start_date, end_date, facility_list, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare opr_nu_var    = vc with noconstant("")
declare ecnt = i4 with noconstant(0)
declare tot_days_var = i4 with noconstant(0)
set tot_days_var = datetimecmp(cnvtdatetime($end_date), cnvtdatetime($start_date))

;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif

 
/**************************************************************
; Start Source Code Here
**************************************************************/
 
Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = f8
		2 encntrid = f8
		2 personid = f8
		2 unit = f8
		2 room = f8
		2 bed = f8
		2 fin = vc
		2 pat_type = vc
		2 pat_day = vc
		2 accomodat = vc
		2 service = vc
		2 admitdt = vc
		2 pat_name = vc
	)
 
 
Record days(
	1 list[*]
		2 dt_day = dq8
)
 
 
 
;---------------------------------------------------------------
;Calculate days from prompt
 
for(x = 1 to (tot_days_var + 1))
	call alterlist(days->list, x)
	set days->list[x].dt_day = datetimeadd(cnvtdatetime($start_date), (x-1))
	with nocounter
endfor
 
call echorecord(days)
 
;---------------------------------------------------------------
;Calculate days from prompt
 
select into $outdev
 
day_of_stay = cnvtdatetime(days->list[d.seq].dt_day)
, e.encntr_id, e.accommodation_cd, e.med_service_cd, e.reg_dt_tm, e.disch_dt_tm
, elh.loc_nurse_unit_cd, elh.loc_room_cd, elh.loc_bed_cd, elh.encntr_type_cd
, elh.beg_effective_dt_tm, elh.end_effective_dt_tm
 
from (dummyt d with seq = (size(days->list, 5)))
	, encounter e
	, encntr_loc_hist elh
 
plan d
 
join elh where(cnvtdatetime(days->list[d.seq].dt_day) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and operator(elh.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and elh.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and elh.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
	and elh.active_ind = 1
 
join e where e.encntr_id = elh.encntr_id
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
order by day_of_stay, e.encntr_id

Head report
	ecnt = 0
Head day_of_stay
	dycnt = 0
Detail
	ecnt += 1
	call alterlist(pat->plist, ecnt)
	pat->rec_cnt = ecnt
	pat->plist[ecnt].facility = e.loc_facility_cd
	pat->plist[ecnt].personid = e.person_id
	pat->plist[ecnt].encntrid = e.encntr_id
	pat->plist[ecnt].room = elh.loc_room_cd
	pat->plist[ecnt].unit = elh.loc_nurse_unit_cd
	pat->plist[ecnt].bed = elh.loc_bed_cd
	pat->plist[ecnt].pat_type = uar_get_code_display(elh.encntr_type_cd)
	pat->plist[ecnt].pat_day = format(day_of_stay, 'mm/dd/yyyy hh:mm:ss ;;q')
	pat->plist[ecnt].admitdt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;q')
	pat->plist[ecnt].accomodat = uar_get_code_display(e.accommodation_cd)
	pat->plist[ecnt].service = uar_get_code_display(e.med_service_cd)
 
with nocounter 

;------------------------------------------------------------------------------------------------------
;Get Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = pat->plist[d.seq].personid
	and p.active_ind = 1
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ea.encntr_id ,pat->plist[icnt].encntrid)
	while(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
		pat->plist[idx].fin = trim(ea.alias)
		idx = locateval(icnt ,(idx+1) ,size(pat->plist,5) ,ea.encntr_id ,pat->plist[icnt].encntrid)
	endwhile
 
with nocounter
 
call echorecord(pat)


;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
;---------------------------------------------------------------------------------------------


select into $outdev
	day_of_stay = trim(substring(1, 30, pat->plist[d1.seq].pat_day))
	, facility = uar_get_code_display(pat->plist[d1.seq].facility)
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 70, pat->plist[d1.seq].pat_name))
	;, encntrid = pat->plist[d1.seq].encntrid
	;, personid = pat->plist[d1.seq].personid
	, admit_dt = trim(substring(1, 30, pat->plist[d1.seq].admitdt))
	, nurse_unit = uar_get_code_display(pat->plist[d1.seq].unit)
	, room = uar_get_code_display(pat->plist[d1.seq].room)
	, bed = uar_get_code_display(pat->plist[d1.seq].bed)
	, patient_type = trim(substring(1, 50, pat->plist[d1.seq].pat_type))
	, accomodation = trim(substring(1, 100, pat->plist[d1.seq].accomodat))
	, med_service = trim(substring(1, 300, pat->plist[d1.seq].service))
 
from
	(dummyt   d1  with seq = size(pat->plist, 5))
 
plan d1
 
order by day_of_stay, facility, nurse_unit, room, bed, fin
 
with nocounter, separator=" ", format

#exitscript
 
end go
 


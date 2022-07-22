drop program cc_anes_controlled_report go
create program cc_anes_controlled_report
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility:" = 0
	, "Surgery Case Begin DT/TM" = ""
	, "Surgery Case End DT/TM" = ""
 
with OUTDEV, p_facility, p_start_date, p_end_date
 
 
;recordset will be used to pass report data to layout program
free record temp
record temp(
1 facility_disp = vc
1 start_date = vc
1 end_date = vc
1 rec_cnt = i4
1 rec[*]
	2 unit = vc
	2 room = vc
	2 bed = vc
	2 e_id = f8
	2 p_id = f8
	2 provider = vc
	2 pt_name = vc
	2 fin_nbr = vc
	2 gender = c1
	2 dob = vc
	2 birth_dt_tm = dq8
	2 age = vc
	2 age_yrs = i4
	2 ord_cnt = i4
	2 ord[*]
		3 admin_id = f8
		3 ord_amount = vc
		3 ord_disp = vc
		3 admin_dt_tm = dq8
)
 
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                           VARIABLE AND CONSTANTS
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
 
/*===============================================================================================================
                                          		CONSTANTS
===============================================================================================================*/
DECLARE C_NURSEUNIT_CD = F8 	WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",222,"NURSEUNIT"))
DECLARE C_FINNBR_CD = F8 		WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",319,"FIN NBR"))
DECLARE C_ORDERED_CD = F8 		WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"ORDERED"))
DECLARE C_PHARMACY_CD = F8 		WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",6000,"PHARMACY"))
DECLARE C_INERROR_CD  = F8 		WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("MEANING", 8, "INERROR"))
declare v_any_ind_3 = f8 with constant(parameter(3,1)),protect
 
 
/*===============================================================================================================
                                          		VARIABLES
===============================================================================================================*/
declare rec_counter = i4 with public, noconstant(0) ;a counter for loading the recordset
set num = 0
set temp->facility_disp = uar_get_code_description($p_facility)
set temp->start_date = $p_start_date
set temp->end_date = $p_end_date
 
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                               QUERY SECTION
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
 
/*===============================================================================================================
Query Encounters for the selected facility and units with an active medication order based on the orderables
	stored in the oc recordset. Load the patient demog and order info into the temp recordset
===============================================================================================================*/
SELECT INTO "nl:"
	unit = uar_get_code_display(e.loc_nurse_unit_cd)
	, room = uar_get_code_display(e.loc_room_cd)
	, bed = uar_get_code_display(e.loc_bed_cd)
	, p.name_full_formatted
	, p2.name_full_formatted
	, p3.name_full_formatted
	, sma.*
	, smi.ADMIN_START_DT_TM
 
FROM
	encounter   e
	, person   p
	, sa_medication_admin   sma
	, sa_med_admin_item   smi
	, sa_medication   sm
	, sa_ref_medication   sr
	, sa_anesthesia_record   sar
	, surgical_case   sc
	, med_identifier   mi
	, prsnl   p2
	, prsnl   p3
	, MED_DISPENSE   MD
 
plan e
where e.loc_facility_cd = $p_facility
  and e.active_ind = 1
  ;and (e.disch_dt_tm = null
;		or e.disch_dt_tm >= cnvtdatetime(curdate,curtime3))
join p where p.person_id = e.person_id
 
join sc
where sc.encntr_id = e.encntr_id  ; surgical case
  and sc.sched_start_dt_tm >= cnvtdatetime($p_start_date)
  and sc.sched_start_dt_tm  <= cnvtdatetime($p_end_date)
 
join p2
where p2.person_id = outerjoin(sc.anesth_prsnl_id)
 
join p3
where p3.person_id = outerjoin(sc.surgeon_prsnl_id)
 
join sar where sar.surgical_case_id = sc.surg_case_id  ; anesthesia record
join sm where sm.sa_anesthesia_record_id = sar.sa_anesthesia_record_id ; anesthesia medication
join sr where sr.sa_ref_medication_id = sm.sa_ref_medication_id ; anesthesia ref medication
join mi
where mi.item_id = sr.item_id  ; med identifier (formulary name)
  and mi.med_product_id = sr.med_product_id
  and mi.med_identifier_type_cd = value(uar_get_code_by("DISPLAYKEY", 11000, "DESCRIPTION"))
  and mi.active_ind = 1
;  and mi.item_id = 102658624
 
join sma
     where sma.sa_medication_id = sm.sa_medication_id  ; medication administration
       and sma.active_ind = 1 ;002
join smi
     where smi.sa_medication_admin_id = sma.sa_medication_admin_id  ; medication administration item
       and smi.active_ind = 1 ;002
 
join md
	where md.item_id = mi.item_id
	and md.legal_status_cd in (
	   2437,
       2438,
       2439,
       2440,
       2441)
 
ORDER BY
	unit
	, room
	, bed
	, p.name_full_formatted
	, e.encntr_id
	, sr.item_id
	, smi.sa_med_admin_item_id
 
head report
rec_counter = 0
dCurUOM = 0.0 ;002
nValidUOM = 0 ;002
 
head e.encntr_id
if (mod(rec_counter,10) = 0)
	stat = alterlist(temp->rec, rec_counter + 10)
endif
rec_counter = rec_counter + 1
call echo(build2("e.encntr_id=",e.encntr_id))
call echo(build2("p.name_full_formatted=",p.name_full_formatted))

temp->rec[rec_counter].e_id = e.encntr_id
temp->rec[rec_counter].p_id = p.person_id
temp->rec[rec_counter].pt_name = p.name_full_formatted
temp->rec[rec_counter].room = uar_get_code_display(e.loc_room_cd)
temp->rec[rec_counter].bed = uar_get_code_display(e.loc_bed_cd)
temp->rec[rec_counter].dob = format(p.birth_dt_tm, "mm/dd/yyyy;;d")
temp->rec[rec_counter].birth_dt_tm = p.birth_dt_tm
temp->rec[rec_counter].age = cnvtage(p.birth_dt_tm)
temp->rec[rec_counter].age_yrs = datetimediff(cnvtdatetime(curdate,curtime),p.birth_dt_tm,10)
temp->rec[rec_counter].gender = uar_get_code_display(p.sex_cd)
temp->rec[rec_counter].unit = uar_get_code_display(e.loc_nurse_unit_cd)
ord_cnt = 0
 
	if (p2.person_id > 0)
	temp->rec[rec_counter].provider = p2.name_full_formatted
	else
	temp->rec[rec_counter].provider = p3.name_full_formatted
	endif
 
head sr.item_id ; 003
dCurUOM = sma.dosage_unit_cd
nValidUOM = 1

call echo(build2("head sr.item_id"))
call echo(build2("-->dCurUOM=",dCurUOM))
call echo(build2("-->nValidUOM=",nValidUOM))
 
detail
call echo(build2("detail"))
call echo(build2("-->dCurUOM=",dCurUOM," and is != ",sma.dosage_unit_cd))

if(dCurUOM != sma.dosage_unit_cd)
	nValidUOM = 0
	call echo("NOT EQUAL")
endif
call echo(build2("-->nValidUOM=",nValidUOM))
 
foot sr.item_id  ; 003
if (mod(ord_cnt,10) = 0)
	stat = alterlist(temp->rec[rec_counter].ord, ord_cnt + 10)
endif
call echo(build2("foot sr.item_id"))
call echo(build2("-->dCurUOM=",dCurUOM))
call echo(build2("-->nValidUOM=",nValidUOM))
ord_cnt = ord_cnt + 1
temp->rec[rec_counter].ord[ord_cnt].admin_id = sma.sa_medication_admin_id
;002 temp->rec[rec_counter].ord[ord_cnt].ord_amount = cnvtstring(sum(smi.admin_dosage))
temp->rec[rec_counter].ord[ord_cnt].ord_disp = mi.value
temp->rec[rec_counter].ord[ord_cnt].admin_dt_tm = smi.admin_start_dt_tm
;002 - Start
;Verify that all of the given administrations were in the same unit of measure
if(nValidUOM = 0)
	call echo("--->inside nValidUOM = 0")
	temp->rec[rec_counter].ord[ord_cnt].ord_amount = "Unable to Calculate Dosage"
else
 	call echo("--->inside nValidUOM = 1 and building ord_amount")
	;if (smi.admin_dosage != null) ; 5/11/15
	temp->rec[rec_counter].ord[ord_cnt].ord_amount
		= concat(trim(cnvtstring(sum(smi.admin_dosage),7,2))," ",trim(uar_get_code_display(sma.dosage_unit_cd),3)," = ",\
		trim(cnvtstring(sum(smi.admin_amount),7,2))," ",trim(uar_get_code_display(sma.amount_unit_cd),3))
	;else
	;	temp->rec[rec_counter].ord[ord_cnt].ord_amount
	;	= concat(trim(cnvtstring(sum(smi.admin_amount)))," ",uar_get_code_display(sma.amount_unit_cd))
 
	;endif
 	call echo(build2("admin_dosage=",sum(smi.admin_dosage)))
endif
;002 - End
 
foot e.encntr_id
stat = alterlist(temp->rec[rec_counter].ord, ord_cnt)
temp->rec[rec_counter].ord_cnt = ord_cnt
 
foot report
stat = alterlist(temp->rec, rec_counter)
temp->rec_cnt = rec_counter
 
WITH nocounter
 
 
;get finnbr for the encounters loaded in the temp recordset
select into "nl:"
from (dummyt d with seq = temp->rec_cnt),
	encntr_alias ea
plan d
join ea where ea.encntr_id = temp->rec[d.seq].e_id
	and ea.encntr_alias_type_cd = C_FINNBR_CD
	and ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ea.active_ind = 1
order by d.seq, ea.beg_effective_dt_tm desc
 
head d.seq
temp->rec[d.seq].fin_nbr = cnvtalias(ea.alias, ea.alias_pool_cd)
 
with nocounter
 
call echorecord(temp)
 
 
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                               REPORT FORMATTING
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
 
EXECUTE PHA_ANESTH_MEDS_LO $OUTDEV
 
end
go

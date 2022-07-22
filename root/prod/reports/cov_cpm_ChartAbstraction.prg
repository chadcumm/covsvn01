/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Geetha Saravanan
	Date Written:		March'2018
	Solution:			Cerner Practice Management
	Source file name:	cov_cpm_ChartAbstraction.prg
	Object name:		cov_cpm_ChartAbstraction
 
	Request#:			1396
	Program purpose:	To get patients have been added to a schedule that need to have chart abstraction completed.
 
	Executing from:		Reporting Portal
 
 	Special Notes:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_cpm_ChartAbstraction:dba go
create program cov_cpm_ChartAbstraction:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Choose Clinics" = 0
 
with OUTDEV, start_datetime, end_datetime, clinic_list
 
 
/**************************************************************
; SUBROUTINES
**************************************************************/
;%i cust_script:cov_CommonLibrary.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;declare alias_poolcd_var     = f8 with constant(get_AliasPoolCode($facility)), protect
;declare facility_name_var    = vc with constant(uar_get_code_description($facility)),protect
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare initcap()            = c100
 
declare cerner_mrn_var = f8 with constant(uar_get_code_by("DISPLAY_KEY", 263, 'CERNERMRN')),protect  ;2554138271.00
declare prsnl_var      = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var   = f8 with constant(uar_get_code_by("CDF_MEANING", 88 , 'PRIMARY CARE')),protect  ;19944603.00
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD appt(
	1 plist[*]
		2 clinic      = vc
		2 pat_name    = vc
		2 pat_dob     = dq8
		2 pat_mrn     = vc
		2 app_type    = vc
		2 app_dt      = dq8
		2 Primary_md  = vc
		2 pat_comment = vc
)
 
 
select distinct into "NL:" ;$outdev
 
NAME = initcap(p.name_full_formatted)
,DOB = p.birth_dt_tm
,MRN = pa.alias
,Appt_Type = uar_get_code_display(se.appt_type_cd)
,Appt_dt_tm = sa.beg_dt_tm
,Primary_Resource = initcap(pr.name_full_formatted)
;,Department = uar_get_code_description(sa.appt_location_cd) 
,Department = uar_get_code_display(sa.appt_location_cd) 
,Comment = l2.long_text
 
from
person p
,person_alias pa
,prsnl pr
,person_prsnl_reltn ppr
,person_info pi
,long_text l2
,sch_appt sa
,sch_event se
,dummyt d ;to avoid clob data type runtime issue
 
/*
,(	(select cv.code_value, cv.description, cv.display_key ;Clinic List (only those are added in cerner)
		from code_value cv
		where cv.code_set = 220
		and cv.active_ind = 1
		and cv.cdf_meaning = 'AMBULATORY'
		and cv.display_key in(
			'CAETATHENS','CAETCROSSVILLE','CAETDECATUR','CAETLENOIR','CAETONEIDA','CAETPARKWEST','CAETTAVR','CTRREPRODMED',
			'CLAIBMEDASSOC','CLINTONFAMILY','NEUROHOSPITAL','CONVENIENTCARE','CROSSVILLE','CROSSFAIRFIELD','CROSSOBGYN','CROSSWALKIN',
			'CUMBNEUROLOGY','CUMBNEUROSURG','CUMBORTHO','CUMBSPEC310','CUMBSPEC350','ETORTHOPEDICS','ETUROLOGY','FAMCLINOAK',
			'FAMILYCARE1300','FAMILYCARE1320','FAMILYCAREWALK','FTLOUDOUNPC','FSNEUROSURFW','FSNEUROSURMOR','FSNEUROSURREG',
			'GREATSMOKIES','HAMBLENPRIMARY','HAMBPULMORRIS','HAMBPULTAZE','HAMBUROLOGY','HAMBUROLTAZE','HEALTHWORKSLAB','HEALTHWORKSRAD',
			'CLAIBCARD','INTMEDASSOC','INTMEDWEST','JTV','KINGSTONFAMILY','KINGSTONFAMILY','KNOXHRTCENTER','KNOXHRTGROUP','KNOXHRTHARR',
			'KNOXHRTJEFFCT','KNOXHRTMORRIS','KNOXHRTOR','KNOXHRTSEVIER','KNOXHRTSEYM','KNOXHRTTAZE','LAKECITY','LAKEWAYORTHO',
			'LECONTECARDIO','LECONTEPULMON','LECONTESURG','LENOIRMEDICAL','MCNEELEYFAMILY','MEDASSCCARTER','MORRISFAMILY','MTNVIEW'
			,'NEWHORIZON','ORGASTRO','ORINFECTIOUS','ORSURGEONS','OLIVERSPRINGS','PROMPTSOUTH','ROANECOUNTY','ROANEPULMONARY','ROANESLEEP',
			'ROANESURGGRP','JOEYROQUE','SEVIERCOUNTYWELLNESS','SMOKYMTNORTHO','SMG','SMGSOUTH','SURGICALASSOC','SURGASSCROGER',
			'MIRIAMTEDDER','TNBRAINKNOX','TNBRAINALCOA','TNBRAINSEVIER','TNBRAINWEST','TOPSIDEPHYS','UROSPETREG','UROSPETALCOA',
			'WESTLAKESURG'  )
		with sqltype("f8","vc","vc")
	)i
)
 
plan i
 
*/
 
plan sa where sa.appt_location_cd = $clinic_list ;i.code_value ;$clinic_list
	;and sa.beg_dt_tm between cnvtdatetime("01-MAR-2018 00:00:00") and cnvtdatetime("31-DEC-2018 23:59:00")
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and cnvtupper(sa.role_meaning) = 'PATIENT'
	and cnvtupper(sa.state_meaning) = 'CONFIRMED'
	and sa.active_ind = 1
 
join p where p.person_id = sa.person_id
	and p.active_ind = 1
 
join pa where pa.person_id = p.person_id
	and pa.alias_pool_cd = cerner_mrn_var
	and pa.active_ind = 1
 
join ppr where ppr.person_id = outerjoin(p.person_id)
	and ppr.person_prsnl_r_cd = outerjoin(prsnl_var) ;PCP
	and ppr.data_status_cd = outerjoin(25) ; Auth (Verified)
	and ppr.active_ind = outerjoin(1)
 
join pr where pr.person_id = outerjoin(ppr.prsnl_person_id)   ;PCP
	and pr.active_ind = outerjoin(1)
	and pr.physician_ind = outerjoin(1)
 
join pi where pi.person_id = outerjoin(p.person_id)
	and pi.info_type_cd = outerjoin(1169)
	and pi.active_ind = outerjoin(1)
;	and pi.long_text_id != 0
 
join l2 where l2.long_text_id = outerjoin(pi.long_text_id)
		and l2.active_ind = outerjoin(1)
 
join se where se.sch_event_id = outerjoin(sa.sch_event_id)
	and se.active_ind = outerjoin(1)
 
join d
 
order by sa.appt_location_cd, pa.alias, p.name_full_formatted, sa.beg_dt_tm, l2.long_text
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, MAXREC = 1000
 
 
;Populate appointment list into the Record Structure
Head report
 
cnt = 0
call alterlist(appt->plist, 10)
 
 
Detail
 	cnt = cnt + 1
	call alterlist(appt->plist, cnt)
 
	appt->plist[cnt].clinic = department
	appt->plist[cnt].pat_name = name
	appt->plist[cnt].pat_dob = dob
	appt->plist[cnt].pat_mrn = mrn
	appt->plist[cnt].app_type = appt_type
	appt->plist[cnt].app_dt = Appt_dt_tm
	appt->plist[cnt].Primary_md = primary_resource
	appt->plist[cnt].pat_comment = comment
 
foot report
 
	call alterlist(appt->plist, cnt)
 
with nocounter
 
;call echojson(appt,"rec.out", 0)
;call echorecord(docs)
 
end
go
 
 
 
 
/*
 
-- To Find Comment Text
select pa.alias, pa.person_id, l2.long_text
from person_alias pa, person_info pi, long_text l2
where pa.alias = "500005012"
and pi.person_id = pa.person_id
and l2.long_text_id = pi.long_text_id
and pi.info_type_cd = 1169
 
------
 
 
;CODE VALUES USED
 
 1115.00	Primary Care Physician	PCP
19944603.00 ;Physician - Adult Medicine	PRIMARY CARE
    1169.00	comment
 
 
;Clinics those are only added in Cerner
 CODE_VALUE		DESCRIPTION							DISPLAY_KEY
 2553455393.00	Cardiology Associates of East Tennessee TAVR	CAETTAVR
 2553455409.00	Centers for Reproductive Medicine & Pelvic Pain	CTRREPRODMED
 2553455425.00	Claiborne Cardiology Associates	CLAIBCARD
 2553455457.00	Clinton Family Physicians	CLINTONFAMILY
 2553455473.00	Covenant Health Convenient Care - Downtown	CONVENIENTCARE
 2553455489.00	Crossville Medical Group	CROSSVILLE
 2553028381.00	Cardiology Associates of East Tennessee Athens	CAETATHENS
 2553028431.00	Cardiology Associates of East Tennessee Decatur	CAETDECATUR
 2553028455.00	Surgical Associates of East TN	SURGICALASSOC
 2553028481.00	Roane Sleep Specialists	ROANESLEEP
 2553455505.00	Crossville Medical Group - Fairfield Glade	CROSSFAIRFIELD
 2553455521.00	Crossville Medical Group - Walk-in	CROSSWALKIN
 2553455537.00	Cumberland Neurosurgery and Spine Center	CUMBNEUROSURG
 2553455553.00	Cumberland Neurology Group	CUMBNEUROLOGY
 2553455569.00	Cumberland Orthopedics	CUMBORTHO
 2553455585.00	Cumberland Specialty Group 310	CUMBSPEC310
 2553455601.00	Cumberland Specialty Group 350	CUMBSPEC350
 2553455633.00	East Tennessee Urology	ETUROLOGY
 2553455649.00	Great Smokies Family Medicine	GREATSMOKIES
 2553455665.00	Knoxville Heart Group	KNOXHRTGROUP
 2553455681.00	Knoxville Heart Group Morristown	KNOXHRTMORRIS
 2553455697.00	Knoxville Heart Group Sevierville	KNOXHRTSEVIER
 2553455713.00	Knoxville Heart Group Seymour	KNOXHRTSEYM
 2553455729.00	Knoxville Heart Group Jeff City	KNOXHRTJEFFCT
 2553455745.00	Knoxville Heart Group Harrogate	KNOXHRTHARR
 2553455761.00	Knoxville Heart Group Tazewell	KNOXHRTTAZE
 2553455777.00	LeConte Cardiology Associates	LECONTECARDIO
 2553455793.00	LeConte Pulmonary & Critical Care Medicine	LECONTEPULMON
 2553455825.00	Exam Rm 1  Exam Rm 2  Exam Rm 3  LeConte Surgical Associates	LECONTESURG
 2553455841.00	Joey Edward Roque MD	JOEYROQUE
 2553455873.00	TN Brain and Spine Knox	TNBRAINKNOX
 2553455889.00	TN Brain and Spine Alcoa	TNBRAINALCOA
 2553455905.00	TN Brain and Spine Sevier	TNBRAINSEVIER
 2553455937.00	TN Brain and Spine West	TNBRAINWEST
 2553456001.00	Fort Sanders Neurosurgery and Spine Reg	FSNEUROSURREG
 2553456017.00	Fort Sanders Neurosurgery and Spine FSW	FSNEUROSURFW
 2553456033.00	Fort Sanders Neurosurgery and Spine Morris	FSNEUROSURMOR
 2553456065.00	Medical Associates of Carter	MEDASSCCARTER
 2553456081.00	Mountain View Family Medicine	MTNVIEW
 2553456097.00	New Horizon Medical Associates	NEWHORIZON
 2553456113.00	Southern Medical Group	SMG
 2553456129.00	Southern Medical Group South	SMGSOUTH
 2553456193.00	East Tennessee Orthopedics and Sports	ETORTHOPEDICS
 2553456225.00	FamilyCare Specialists 1300	FAMILYCARE1300
 2553456241.00	FamilyCare Specialists 1320	FAMILYCARE1320
 2553456257.00	FamilyCare Specialists Walkin	FAMILYCAREWALK
 2553456289.00	Hamblen Primary Care	HAMBLENPRIMARY
 2553456305.00	Hamblen Pulmonary Critical Care Morristown	HAMBPULMORRIS
 2553456321.00	Hamblen Pulmonary Critical Care Tazewell	HAMBPULTAZE
 2553456337.00	Hamblen Urology Clinic	HAMBUROLOGY
 2553456353.00	Hamblen Urology Clinic Tazewell	HAMBUROLTAZE
 2553456401.00	JTV Wellness Center	JTV
 2553456417.00	Kingston Family Practice	KINGSTONFAMILY
 2553456449.00	Knoxville Heart Center	KNOXHRTCENTER
 2553456465.00	Lake City Family Medicine	LAKECITY
 2553456481.00	Lenoir Medical Clinic	LENOIRMEDICAL
 2553456497.00	McNeeley Family Physicians	MCNEELEYFAMILY
 2553456529.00	Miriam B Tedder MD	MIRIAMTEDDER
 2553456545.00	Oak Ridge Gastroenterology Associates	ORGASTRO
 2553456561.00	Oak Ridge Infectious Disease	ORINFECTIOUS
 2553456593.00	Oak Ridge Surgeons, PC	ORSURGEONS
 2553456609.00	Oliver Springs Family Physicians	OLIVERSPRINGS
 2553456657.00	Ft Loudoun PC	FTLOUDOUNPC
 2553456705.00	Prompt Family Care South	PROMPTSOUTH
 2553456737.00	Roane County Family Practice	ROANECOUNTY
 2553456753.00	Roane Pulmonary Practice	ROANEPULMONARY
 2553028261.00	Cardiology Associates of East Tennessee Parkwest	CAETPARKWEST
 2553028291.00	Cardiology Associates of East Tennessee Lenoir City	CAETLENOIR
 2553028315.00	West Lake Surgical Associates	WESTLAKESURG
 2553028353.00	Surgical Associates of East TN Rogersville	SURGASSCROGER
 2557509319.00	Cardiology Associates of East Tennessee Crossville	CAETCROSSVILLE
 2557509395.00	Cardiology Associates of East Tennessee Oneida	CAETONEIDA
 2558810461.00	Crossville Medical Group - OBGYN	CROSSOBGYN
 2559325899.00	Knoxville Heart Group Oak Ridge	KNOXHRTOR
 2562470073.00	Roane Surgical Group	ROANESURGGRP
 2562704281.00	Covenant Neurohospitalists	NEUROHOSPITAL
 2562704963.00	Morristown Family Medicine	MORRISFAMILY
 
 
 */

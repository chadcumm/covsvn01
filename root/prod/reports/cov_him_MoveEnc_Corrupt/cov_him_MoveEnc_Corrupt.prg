/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/05/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_MoveEnc_Corrupt.prg
	Object name:		cov_him_MoveEnc_Corrupt
	Request #:			7966
 
	Program purpose:	Lists data that has been corrupted due to the
						Encounter Move feature.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_MoveEnc_Corrupt:dba go
create program cov_him_MoveEnc_Corrupt:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "CMRN" = "" 

with OUTDEV, start_datetime, end_datetime, cmrn
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare nooperation_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 327, "NOOPERATION"))
declare root_var					= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT"))
declare child_var					= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD"))
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))
declare mdoc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC"))
declare doc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))
declare num							= i4 with noconstant(0)


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record combine_data
record combine_data (
	1 cnt							= i4
	1 qual [*]
		2 person_combine_id			= f8
		2 cmb_dt_tm					= dq8
		
		2 from_person_id			= f8
		2 from_patient_name			= c100
		2 from_dob					= dq8
		2 from_dob_tz				= i4
		2 from_cmrn					= c20
			
		2 to_person_id				= f8
		2 to_patient_name			= c100
		2 to_dob					= dq8
		2 to_dob_tz					= i4
		2 to_cmrn					= c20

		2 dcnt							= i4
		2 details [*]
			3 person_combine_det_id		= f8
			3 entity_name				= c32
			3 entity_id					= f8
			3 attribute_name			= c32
			3 combine_action_cd			= f8
			3 combine_desc_cd			= f8
			3 updt_dt_tm				= dq8
		
		2 ecnt							= i4
		2 encounters [*]
			3 encntr_id					= f8
			3 encntr_class_cd			= f8
			3 encntr_type_cd			= f8
			3 encntr_status_cd			= f8
			3 active_ind				= i2
		
		2 acnt							= i4
		2 allergies [*]
			3 allergy_id				= f8
			3 substance_ftdesc			= c255
			3 substance_type_cd			= f8
			3 severity_cd				= f8
			3 reaction_class_cd			= f8
			3 reaction_status_cd		= f8
			3 reviewed_dt_tm			= dq8
			3 principle_type_cd			= f8
			3 contributor_system_cd		= f8
			3 source_string				= c255
			3 source_identifier			= c50
			3 source_vocabulary_cd		= f8
			3 concept_source_cd			= f8
			3 active_ind				= i2
		
		2 cecnt							= i4
		2 clinical_events [*]
			3 clinical_event_id			= f8
			3 encntr_id					= f8
			3 catalog_cd				= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 event_id					= f8
			3 parent_event_id			= f8
			3 event_end_dt_tm			= dq8
			3 performed_dt_tm			= dq8
			3 valid_until_dt_tm			= dq8
		
		2 diagcnt						= i4
		2 diagnoses [*]
			3 diagnosis_id				= f8
			3 diag_type_cd				= f8
			3 diag_priority				= i4
			3 beg_effective_dt_tm		= dq8
			3 end_effective_dt_tm		= dq8
			3 active_ind				= i2
		
		2 pcnt							= i4
		2 problems [*]
			3 problem_instance_id		= f8
			3 active_ind				= i2
		
		2 ocnt							= i4
		2 orders [*]
			3 order_id					= f8
			3 activity_type_cd			= f8
			3 catalog_cd				= f8
			3 catalog_type_cd			= f8
			3 dcp_clin_cat_cd			= f8
			3 current_start_dt_tm		= dq8
			3 orig_order_dt_tm			= dq8
			3 order_status_cd			= f8
			3 order_mnemonic			= c100
			3 clinical_display_line		= c255
			3 active_ind				= i2
)
 
 
/**************************************************************/ 
; select combine data
select into "nl:"
from 
	PERSON_COMBINE pc
	
	, (inner join PERSON p1 on p1.person_id = pc.from_person_id)
	
	, (inner join PERSON_ALIAS pa1 on pa1.person_id = p1.person_id
		and pa1.person_alias_type_cd = 2.00
		and pa1.active_ind = 1)
	
	, (inner join PERSON p2 on p2.person_id = pc.to_person_id)
	
	, (inner join PERSON_ALIAS pa2 on pa2.person_id = p2.person_id
		and pa2.person_alias_type_cd = 2.00
		and pa2.alias = $cmrn
		and pa2.active_ind = 1)
		
	, (inner join PERSON_COMBINE_DET pcd on pcd.person_combine_id = pc.person_combine_id
		and pcd.combine_action_cd != nooperation_var
		and pcd.entity_id > 0.0
		and pcd.active_ind = 1)
	
where
	pc.cmb_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and pc.active_ind = 1
	
order by
	pc.person_combine_id
	, pcd.person_combine_det_id
	
; populate record structure
head report
	cnt = 0
	dcnt = 0
	
head pc.person_combine_id
	cnt += 1
	
	call alterlist(combine_data->qual, cnt)
	
	combine_data->cnt 							= cnt
	combine_data->qual[cnt].person_combine_id	= pc.person_combine_id
	combine_data->qual[cnt].cmb_dt_tm			= pc.cmb_dt_tm
	
	combine_data->qual[cnt].from_person_id		= p1.person_id
	combine_data->qual[cnt].from_patient_name	= p1.name_full_formatted
	combine_data->qual[cnt].from_dob			= p1.birth_dt_tm
	combine_data->qual[cnt].from_dob			= p1.birth_tz
	combine_data->qual[cnt].from_cmrn			= pa1.alias
	
	combine_data->qual[cnt].to_person_id		= p2.person_id
	combine_data->qual[cnt].to_patient_name		= p2.name_full_formatted
	combine_data->qual[cnt].to_dob				= p2.birth_dt_tm
	combine_data->qual[cnt].to_dob				= p2.birth_tz
	combine_data->qual[cnt].to_cmrn				= pa2.alias
	
detail
	dcnt += 1
	
	call alterlist(combine_data->qual[cnt].details, dcnt)
	
	combine_data->qual[cnt].dcnt									= dcnt
	combine_data->qual[cnt].details[dcnt].person_combine_det_id		= pcd.person_combine_det_id
	combine_data->qual[cnt].details[dcnt].entity_name				= pcd.entity_name
	combine_data->qual[cnt].details[dcnt].entity_id					= pcd.entity_id
	combine_data->qual[cnt].details[dcnt].attribute_name			= pcd.attribute_name
	combine_data->qual[cnt].details[dcnt].combine_action_cd			= pcd.combine_action_cd
	combine_data->qual[cnt].details[dcnt].combine_desc_cd			= pcd.combine_desc_cd
	combine_data->qual[cnt].details[dcnt].updt_dt_tm				= pcd.updt_dt_tm	
	
with nocounter, time = 180
 
 
/**************************************************************/ 
; select encounter data
select into "nl:"
from 
	ENCOUNTER e
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "ENCOUNTER"

join e 
where
	e.encntr_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
; populate record structure
head report
	cnt = 0
	
head e.encntr_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].encounters, cnt)
	
	combine_data->qual[d1.seq].ecnt									= cnt
	combine_data->qual[d1.seq].encounters[cnt].encntr_id			= e.encntr_id
	combine_data->qual[d1.seq].encounters[cnt].encntr_class_cd		= e.encntr_class_cd
	combine_data->qual[d1.seq].encounters[cnt].encntr_type_cd		= e.encntr_type_cd
	combine_data->qual[d1.seq].encounters[cnt].encntr_status_cd		= e.encntr_status_cd
	combine_data->qual[d1.seq].encounters[cnt].active_ind			= e.active_ind
		
with nocounter, time = 180
 
 
/**************************************************************/ 
; select allergy data
select into "nl:"
from 
	ALLERGY a
	
	, (inner join NOMENCLATURE n on n.nomenclature_id = a.substance_nom_id)
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "ALLERGY"

join a 
where
	a.allergy_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
join n
	
; populate record structure
head report
	cnt = 0
	
head a.allergy_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].allergies, cnt)
	
	combine_data->qual[d1.seq].acnt										= cnt
	combine_data->qual[d1.seq].allergies[cnt].allergy_id				= a.allergy_id
	combine_data->qual[d1.seq].allergies[cnt].substance_ftdesc			= a.substance_ftdesc
	combine_data->qual[d1.seq].allergies[cnt].substance_type_cd			= a.substance_type_cd
	combine_data->qual[d1.seq].allergies[cnt].severity_cd				= a.severity_cd
	combine_data->qual[d1.seq].allergies[cnt].reaction_class_cd			= a.reaction_class_cd
	combine_data->qual[d1.seq].allergies[cnt].reaction_status_cd		= a.reaction_status_cd
	combine_data->qual[d1.seq].allergies[cnt].reviewed_dt_tm			= a.reviewed_dt_tm
	combine_data->qual[d1.seq].allergies[cnt].principle_type_cd			= n.principle_type_cd
	combine_data->qual[d1.seq].allergies[cnt].contributor_system_cd		= n.contributor_system_cd
	combine_data->qual[d1.seq].allergies[cnt].source_string				= n.source_string
	combine_data->qual[d1.seq].allergies[cnt].source_identifier			= n.source_identifier
	combine_data->qual[d1.seq].allergies[cnt].source_vocabulary_cd		= n.source_vocabulary_cd
	combine_data->qual[d1.seq].allergies[cnt].concept_source_cd			= n.concept_source_cd
	combine_data->qual[d1.seq].allergies[cnt].active_ind				= a.active_ind
		
with nocounter, time = 180
 
 
/**************************************************************/ 
; select clinical event data
select into "nl:"
from 
	CLINICAL_EVENT ce
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "CLINICAL_EVENT"

join ce 
where
	ce.clinical_event_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
; populate record structure
head report
	cnt = 0
	
head ce.clinical_event_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].clinical_events, cnt)
	
	combine_data->qual[d1.seq].cecnt										= cnt
	combine_data->qual[d1.seq].clinical_events[cnt].clinical_event_id		= ce.clinical_event_id
	combine_data->qual[d1.seq].clinical_events[cnt].encntr_id				= ce.encntr_id
	combine_data->qual[d1.seq].clinical_events[cnt].catalog_cd				= ce.catalog_cd
	combine_data->qual[d1.seq].clinical_events[cnt].event_cd				= ce.event_cd
	combine_data->qual[d1.seq].clinical_events[cnt].event_class_cd			= ce.event_class_cd
	combine_data->qual[d1.seq].clinical_events[cnt].event_id				= ce.event_id
	combine_data->qual[d1.seq].clinical_events[cnt].parent_event_id			= ce.parent_event_id
	combine_data->qual[d1.seq].clinical_events[cnt].event_end_dt_tm			= ce.event_end_dt_tm
	combine_data->qual[d1.seq].clinical_events[cnt].performed_dt_tm			= ce.performed_dt_tm
	combine_data->qual[d1.seq].clinical_events[cnt].valid_until_dt_tm		= ce.valid_until_dt_tm
		
with nocounter, time = 180
 
 
/**************************************************************/ 
; select diagnosis data
select into "nl:"
from 
	DIAGNOSIS d
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "DIAGNOSIS"

join d 
where
	d.diagnosis_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
; populate record structure
head report
	cnt = 0
	
head d.diagnosis_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].diagnoses, cnt)
	
	combine_data->qual[d1.seq].diagcnt									= cnt
	combine_data->qual[d1.seq].diagnoses[cnt].diagnosis_id				= d.diagnosis_id
	combine_data->qual[d1.seq].diagnoses[cnt].diag_type_cd				= d.diag_type_cd
	combine_data->qual[d1.seq].diagnoses[cnt].diag_priority				= d.diag_priority
	combine_data->qual[d1.seq].diagnoses[cnt].beg_effective_dt_tm		= d.beg_effective_dt_tm
	combine_data->qual[d1.seq].diagnoses[cnt].end_effective_dt_tm		= d.end_effective_dt_tm
	combine_data->qual[d1.seq].diagnoses[cnt].active_ind				= d.active_ind
		
with nocounter, time = 180
 
 
/**************************************************************/ 
; select problem data
select into "nl:"
from 
	PROBLEM p
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "PROBLEM"

join p 
where
	p.problem_instance_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
; populate record structure
head report
	cnt = 0
	
head p.problem_instance_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].problems, cnt)
	
	combine_data->qual[d1.seq].pcnt										= cnt
	combine_data->qual[d1.seq].problems[cnt].problem_instance_id		= p.problem_instance_id
	combine_data->qual[d1.seq].problems[cnt].active_ind					= p.active_ind
		
with nocounter, time = 180
 
 
/**************************************************************/ 
; select order data
select into "nl:"
from 
	ORDERS o
	
	, (dummyt d1 with seq = value(combine_data->cnt))
	
	, (dummyt d2 with seq = 1)
     
plan d1
where 
	maxrec(d2, combine_data->qual[d1.seq].dcnt)

join d2
where
	combine_data->qual[d1.seq].details[d2.seq].entity_name = "ORDERS"

join o 
where
	o.order_id = combine_data->qual[d1.seq].details[d2.seq].entity_id
	
; populate record structure
head report
	cnt = 0
	
head o.order_id
	cnt += 1
	
	call alterlist(combine_data->qual[d1.seq].orders, cnt)
	
	combine_data->qual[d1.seq].ocnt										= cnt
	combine_data->qual[d1.seq].orders[cnt].order_id						= o.order_id
	combine_data->qual[d1.seq].orders[cnt].activity_type_cd				= o.activity_type_cd
	combine_data->qual[d1.seq].orders[cnt].catalog_cd					= o.catalog_cd
	combine_data->qual[d1.seq].orders[cnt].catalog_type_cd				= o.catalog_type_cd
	combine_data->qual[d1.seq].orders[cnt].dcp_clin_cat_cd				= o.dcp_clin_cat_cd
	combine_data->qual[d1.seq].orders[cnt].current_start_dt_tm			= o.current_start_dt_tm
	combine_data->qual[d1.seq].orders[cnt].orig_order_dt_tm				= o.orig_order_dt_tm
	combine_data->qual[d1.seq].orders[cnt].order_status_cd				= o.order_status_cd
	combine_data->qual[d1.seq].orders[cnt].order_mnemonic				= o.order_mnemonic
	combine_data->qual[d1.seq].orders[cnt].clinical_display_line		= o.clinical_display_line
	combine_data->qual[d1.seq].orders[cnt].active_ind					= o.active_ind
		
with nocounter, time = 180


call echorecord(combine_data)
 
 
/**************************************************************/ 
; select data
;select into value($OUTDEV)
;	clinical_event_id			= combine_data->qual[d1.seq].clinical_events[d2.seq].clinical_event_id
;    , encntr_id					= combine_data->qual[d1.seq].clinical_events[d2.seq].encntr_id
;    , catalog					= uar_get_code_display(combine_data->qual[d1.seq].clinical_events[d2.seq].catalog_cd)
;    , event						= uar_get_code_display(combine_data->qual[d1.seq].clinical_events[d2.seq].event_cd)
;    , event_class				= uar_get_code_display(combine_data->qual[d1.seq].clinical_events[d2.seq].event_class_cd)
;    , event_id					= combine_data->qual[d1.seq].clinical_events[d2.seq].event_id
;    , parent_event_id			= combine_data->qual[d1.seq].clinical_events[d2.seq].parent_event_id
;    , result_dt_tm				= combine_data->qual[d1.seq].clinical_events[d2.seq].event_end_dt_tm ";;q"
;    , performed_dt_tm			= combine_data->qual[d1.seq].clinical_events[d2.seq].performed_dt_tm ";;q"
;    , valid_until_dt_tm			= combine_data->qual[d1.seq].clinical_events[d2.seq].valid_until_dt_tm ";;q"
;    
;from
;	(dummyt d1 with seq = value(combine_data->cnt))
;     
;	, (dummyt d2 with seq = 1)
;	
;plan d1
;where 
;	maxrec(d2, combine_data->qual[d1.seq].cecnt)
;
;join d2
;
;order by
;	combine_data->qual[d1.seq].clinical_events[d2.seq].clinical_event_id
;
;with nocounter, separator = " ", format, time = 180

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 

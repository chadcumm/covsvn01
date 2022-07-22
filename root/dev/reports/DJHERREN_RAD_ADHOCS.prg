/*=========================================*/
/* ADHOC QUERY FOR REPORT
/*=========================================*/
select distinct
	 facility		 = uar_get_code_description(e.loc_facility_cd)
	,modality        = uar_get_code_display(rg.child_service_resource_cd)
	,modality_subsec = uar_get_code_display(rg1.child_service_resource_cd)
	,modality_room   = uar_get_code_display(rg2.child_service_resource_cd)
	,pat_name  		 = p.name_full_formatted
	,accession_nbr   = cnvtacc(ce.accession_nbr)
	,procedure       = uar_get_code_display(re.service_resource_cd)
 	,order_dt        = o.complete_dt_tm
	,ord_status      = uar_get_code_display(o.exam_status_cd) ;(o.order_status_cd)
 	,encntr_id 		 = e.encntr_id
	,person_id 		 = p.person_id
 
from
	 ORDER_RADIOLOGY  o
	,TASK_ACTIVITY    ta
	,ENCOUNTER        e
	,PERSON           p
	,CLINICAL_EVENT   ce
	,CODE_VALUE	      cv
	,LOCATION         l
	,SERVICE_RESOURCE sr
;    ,RAD_EXAM_ROOM	  rer
    ,RAD_EXAM         re
    ,RESOURCE_GROUP   rg
	,RESOURCE_GROUP   rg1
	,RESOURCE_GROUP   rg2
;	,CODE_VALUE       cv1
 
plan o
	where o.complete_dt_tm between cnvtdatetime("01-JAN-2017 00:00:00") and cnvtdatetime("31-MAY-2018 23:59:59")
;		and o.catalog_type_cd = 2517 ;RADIOLOGY_VAR ;2517
		and o.exam_status_cd = 4224  ;RADCOMPLETED_VAR
 
join ta
	where ta.order_id = o.order_id
		and ta.encntr_id = o.encntr_id
		and not exists
			;QUERY TO PULL RADIOLOGY IMAGES
			(SELECT
				null
			FROM
				clinical_event ce2
			WHERE
				ce2.parent_event_id = ta.event_id
					AND ce2.encntr_id = ta.encntr_id
					AND ce2.person_id = o.person_id
					AND ce2.event_title_text = "IMAGE"
			)
 
join e
	where e.encntr_id = o.encntr_id
		and e.person_id = o.person_id
;		and e.loc_facility_cd = 2552503613 ;$FACILITY_PMPT
		and e.loc_facility_cd in (2553765291.00, 2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
 			2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00)
		and e.active_ind = 1
		and e.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
join ce
	where ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.order_id = o.order_id
;		and substring(6,2,ce.accession_nbr) not in ("CA", "CL", "NP","SC")
;		and ce.resource_cd = $EXAM_ROOM_PMPT
 
;join rer
;	where rer.service_resource_cd = sr.service_resource_cd
 
join cv
    where cv.cdf_meaning = "FACILITY"
;        and cv.code_value = 2552503613  ;$FACILITY_PMPT
        and cv.code_value in (2553765291.00, 2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
 			2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00)
        and cv.code_set = 220
        and cv.active_ind = 1
 
join l
    where l.location_cd = cv.code_value
        and l.active_ind = 1
 
join sr
    where sr.organization_id = l.organization_id
;        and sr.service_resource_type_cd = 835 ;dept_cd
;        and sr.active_ind = 1
 
join rg
	where rg.parent_service_resource_cd = sr.service_resource_cd  ;modality
;		and rg.child_service_resource_cd = 2553880161 ;$MODALITY_ROOM_PMPT
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd   ;modality sub-section
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;modality exam rooms
 
join re
	where re.order_id = o.order_id
		and re.service_resource_cd = rg2.child_service_resource_cd
 
;join cv1
;	where cv.code_value = rg2.child_service_resource_cd
;		and cv.cdf_meaning = "RADEXAMROOM"
 
order by facility, modality, pat_name, accession_nbr
 
 
/*=========================================*/
/* MODALITY */
/*=========================================*/
select into "/nfs/middle_fs/to_client_site/p0665/ClinicalNursing/InfectionControl/PAExports/djhTest.txt"
	 exam_rm = uar_get_code_display(rg.child_service_resource_cd)
    ,exam_rm_cd = rg1.child_service_resource_cd
from
	code_value cv
	, location l
	, service_resource sr
	, resource_group rg
	, resource_group rg1
	, resource_group rg2
	, code_value cv1
 
plan cv
	where cv.code_set = 220
		and cv.cdf_meaning = "FACILITY"
;		and cv.code_value =  2552503613.00
;       and cv.display_key = trim(cnvtupper($facility))
		and cv.active_ind = 1
 
join l
	where l.location_cd = cv.code_value
		and l.active_ind = 1
 
join sr
	where sr.organization_id = l.organization_id
   		and sr.service_resource_type_cd = 824 ;dept_cd
        and sr.active_ind = 1
 
join rg
	where rg.parent_service_resource_cd = sr.service_resource_cd  ;department
;		and rg.child_service_resource_cd =   2553880185.00 ;$IMG_ROOM_PMPT
		and rg.child_service_resource_cd in ( 2553880161.00,2553888027.00, 2562190813.00, 2553880101.00,
 		2553880445.00, 2553888051.00, 2556770119.00, 2553880209.00, 2553880421.00, 2553880185.00, 2553880309.00,
 		2562429337.00, 2553888089.00, 2556753835.00, 2553880247.00, 2553880341.00, 2553880381.00, 2553888003.00
)
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd   ;section
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;subsection which are the exam rooms
 
join cv1
	where cv1.code_value = rg2.child_service_resource_cd
		and cv1.cdf_meaning = "RADEXAMROOM"
 
 
/*======================================*/
/* CASCADING MODALITY, SUB-MODALITY,
/*======================================*/
select distinct
	facility = cv.description
	,modality = uar_get_code_display(rg.child_service_resource_cd)
;    ,section_cd = rg.child_service_resource_cd
    ,modality_subsection = uar_get_code_display(rg1.child_service_resource_cd)
    ,modality_room = uar_get_code_display(rg2.child_service_resource_cd)
from
	 code_value cv
	,location l
	,service_resource sr
	,resource_group rg
	,resource_group rg1
	,resource_group rg2
	,code_value cv1
 
plan cv
	where cv.code_set = 220
		and cv.cdf_meaning = "FACILITY"
;		and cv.code_value =  2552503613.00 ;$FACILITY_PMPT
		and cv.code_value in (2553765291.00, 2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
 			2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00)
 
		and cv.active_ind = 1
 
join l
	where l.location_cd = cv.code_value
		and l.active_ind = 1
 
join sr
	where sr.organization_id = l.organization_id
   		and sr.service_resource_type_cd = 824 ;dept_cd
;   		and sr.service_resource_cd =  2553880093.00 ;imaging
        and sr.active_ind = 1
 
join rg
	where rg.parent_service_resource_cd = sr.service_resource_cd  ;modality dept
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd   ;modality sub-section
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;modality exam rooms
 
join cv1
	where cv1.code_value = rg2.child_service_resource_cd
		and cv1.cdf_meaning = "RADEXAMROOM"
order by facility ,modality, modality_subsection, modality_room
 
 
 
 
 
 

/* SELECT FACILITY */
SELECT
    FACILITY_NAME = O.ORG_NAME
    ,L.LOCATION_CD
    ,o.organization_id
FROM
    PRSNL_ORG_RELTN   P
    , LOCATION   L
    , ORGANIZATION   O
PLAN p WHERE p.person_id = reqinfo -> updt_id        AND p.active_ind = 1        AND p.end_effective_dt_tm > sysdate
JOIN l WHERE l.organization_id = p.organization_id          AND l.location_type_cd = 783  ;(FACILITY)
JOIN o WHERE o.organization_id = l.organization_id
AND o.organization_id IN (3234038, 3144506, 3144501, 675844, 3144505, 3144499,3144502, 3144503, 3144504)
ORDER BY
    FACILITY_NAME
 
 
/* IMAGING ROOM */
select distinct
	 section = uar_get_code_display(rg.child_service_resource_cd)
    ,section_cd = rg.child_service_resource_cd
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
		and cv.code_value =  2552503613.00 ;$FACILITY_PMPT
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
	where rg.parent_service_resource_cd = sr.service_resource_cd  ;department
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd   ;section
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;subsection which are the exam rooms
 
join cv1
	where cv1.code_value = rg2.child_service_resource_cd
		and cv1.cdf_meaning = "RADEXAMROOM"
 
 
/* IMAGING EXAM ROOM */
select distinct
	 exam_rm = uar_get_code_display(rg1.child_service_resource_cd)
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
		and rg.child_service_resource_cd =   2553880185.00 ;$IMG_ROOM_PMPT
 
join rg1
	where rg1.parent_service_resource_cd = rg.child_service_resource_cd   ;section
 
join rg2
	where rg2.parent_service_resource_cd = rg1.child_service_resource_cd  ;subsection which are the exam rooms
 
join cv1
	where cv1.code_value = rg2.child_service_resource_cd
		and cv1.cdf_meaning = "RADEXAMROOM"
 
 

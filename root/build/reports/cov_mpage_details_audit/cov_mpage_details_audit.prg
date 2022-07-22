drop program cov_mpage_details_audit go
create program cov_mpage_details_audit

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

select into $OUTDEV
 Application = app.description
, Position_Display = evaluate(
  uar_get_code_display(v.position_cd)
  , " ", "-GLOBAL-"
  , uar_get_code_display(v.position_cd), uar_get_code_display(v.position_cd)
  )
, Tab_Name = n.pvc_value
, v.frame_type
, Report_Name = evaluate(
  n3.pvc_value
  , " ", "-Not Set-"
  , n3.pvc_value, n3.pvc_value
  )
, n3.name_value_prefs_id
, Report_Param = evaluate(
  n2.pvc_value
  , " ", "-Not Set-"
  , n2.pvc_value, n2.pvc_value
  )
, n2.name_value_prefs_id
    ,ViewPoint = mpv.viewpoint_name
    ,MPage = br.category_name
    ,Layout = evaluate(br.layout_flag,0,"Summary",1,"Workflow")
from
name_value_prefs n
, view_prefs v
, code_value cv
, application app
, name_value_prefs n2
, name_value_prefs n3
, detail_prefs dp
, mp_viewpoint_reltn mvr
, br_datamart_category br
, mp_viewpoint mpv
plan n where n.pvc_name = outerjoin("VIEW_CAPTION")
join v where n.parent_entity_id = v.view_prefs_id
and v.view_name IN ( "DISCERNRPT" , "MCDISCERNRPT")
join app where v.application_number = app.application_number
join cv where cv.code_value = v.position_cd
       and (
                     (
                     cv.active_ind = 1
                     and cv.display_key != "ZZ*"
                     )
              or cv.code_value = 0
              )
join dp where dp.application_number = v.application_number
and dp.position_cd = v.position_cd
and dp.view_name IN ( "DISCERNRPT" , "MCDISCERNRPT")
and dp.view_seq = v.view_seq
and dp.person_id = 0
join n2 where n2.parent_entity_id = outerjoin(dp.detail_prefs_id)
and n2.pvc_name = outerjoin("REPORT_PARAM")
join n3 where n3.parent_entity_id = dp.detail_prefs_id
and n3.pvc_name = "REPORT_NAME"
join mpv
    where mpv.active_ind = 1
    and operator(n2.pvc_value, 'REGEXPLIKE', mpv.viewpoint_name_key)
join mvr
    where mvr.mp_viewpoint_id = mpv.mp_viewpoint_id
join br
    where br.br_datamart_category_id = mvr.br_datamart_category_id
    and br.category_name in ("*") ;modify to filter by specific mpage
order by v.view_name, Application, Position_Display
with time = 120,format,seperator=" "
end go

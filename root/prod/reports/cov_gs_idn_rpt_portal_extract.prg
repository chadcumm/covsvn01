drop program cov_gs_idn_rpt_portal_extract go
create program cov_gs_idn_rpt_portal_extract
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime
 
free record qual
record qual
  ( 1 rpts[*]
      2 folder = c200
      2 report_name = c60
      2 report_type = c40
      2 ccl_object_name = c40
      2 rpt_desc = c1000
      ;2 runs_last_30 = i4
      2 report_run_dt = vc
      )
 
 
select into "nl:"

 folder = if(df3.da_folder_id > 0)
             concat(trim(df3.da_folder_name), " -> ", trim(df2.da_folder_name),  " -> ", trim(df.da_folder_name))
         elseif(df2.da_folder_id > 0)
             concat(trim(df2.da_folder_name),  " -> ", trim(df.da_folder_name))
         else
             trim(df.da_folder_name)
         endif

, report_name = if(trim(dfrr.report_alias_name) != null)
    		      trim(dfrr.report_alias_name)
              else
                  trim(dr.report_name)
              endif
              
, report_type = uar_get_code_display(dr.report_type_cd)
, ccl_object_name = if(dr.report_type_cd = 19176835.00)dr.report_name endif
, report_description = trim(replace(replace(dr.short_desc, char(10), " "), char(13)," "))
; ,runs_last_30_days = count(cra.object_name) over(partition by(cra.object_name))
, run_dt = cra.begin_dt_tm

from 

da_report dr
, da_folder_report_reltn dfrr
, da_folder df
, da_folder df2
, da_folder df3
, long_text lt
, ccl_report_audit cra
 
plan dr
join dfrr
where dfrr.da_report_id = dr.da_report_id
 
 
join df
where df.da_folder_id = dfrr.da_folder_id
and df.public_ind = 1
 
join df2
where df2.da_folder_id = outerjoin(df.parent_folder_id)
 
join df3
where df3.da_folder_id = outerjoin(df2.parent_folder_id)
 
join lt
where lt.long_text_id = outerjoin(dr.long_text_id)
 
join cra
where trim(cnvtupper(cra.object_name)) = outerjoin(trim(cnvtupper(dr.report_name)))
and cra.begin_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
;and cra.updt_dt_tm > outerjoin(cnvtdatetime(curdate-30, 0000))
 
order by folder, report_name, report_type, ccl_object_name, report_description, run_dt ;runs_last_30_days

head report
  cnt = 0
head folder
  null
head report_name
  run_cnt = 0
  cnt = cnt+1
  stat = alterlist(qual->rpts, cnt)
  qual->rpts[cnt]->folder = trim(folder)
  qual->rpts[cnt]->report_name = trim(report_name)
  qual->rpts[cnt]->report_type = trim(report_type)
  qual->rpts[cnt]->ccl_object_name = trim(ccl_object_name)
  qual->rpts[cnt]->rpt_desc = trim(report_description)
  qual->rpts[cnt]->report_run_dt = format(cra.begin_dt_tm, 'mm/dd/yyyy hh:mm ;;d')
  
detail
  run_cnt = run_cnt+1
foot report_name
  ;qual->rpts[cnt]->runs_last_30 = run_cnt-1
  run_cnt = 0
foot folder
  null
foot report
  null
with nocounter
 
 
select into $1
Folder =  qual->rpts[d.seq]->folder
,Report_name = qual->rpts[d.seq]->report_name
,Report_type = qual->rpts[d.seq]->report_type
,ccl_object_name = qual->rpts[d.seq]->ccl_object_name
,rpt_desc = qual->rpts[d.seq]->rpt_desc
;,runs_last_30_days = qual->rpts[d.seq]->runs_last_30
,run_dt_tm = qual->rpts[d.seq].report_run_dt
from
  (dummyt d with seq = value(size(qual->rpts, 5)))
plan d
with format, separator = " "
end go
 
 

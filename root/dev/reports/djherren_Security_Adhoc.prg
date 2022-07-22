 
/*************************************/
/* DUPLICATE CCL CHECK - GROUP 0 & 1 */
/*************************************/
select
	d.object_name
from
	 DPROTECT d
	,DPROTECT d2
plan d where d.object = "P"
	and d.group = 0
join d2 where d.object= d2.object
	and d.object_name = d2.object_name
	and d.group != d2.group
go
 
 
 
;djherren_DA2Security
 
/************************************************/
/* USER NAME, POSITION, CHANGED-BY, UPDATE-DATE */
/************************************************/
select
	 UPDATED = p.updt_dt_tm
	,USERNAME = P.USERNAME
	,USERFULLNAME = cnvtupper(P.NAME_FULL_FORMATTED)
	,POSITION = UAR_GET_CODE_DISPLAY(P.POSITION_CD)
	,DUSER = uar_get_code_display(pi.info_type_cd)
	,DACTIVE = pi.active_ind
	,CHANGED_BY = p1.name_full_formatted
;	,CURRENT_POSITION_CD = p.position_cd
;	,PERSON_ID = P.PERSON_ID
from
	 PRSNL P
	,PRSNL p1
plan p where p.active_ind = 1
	and p.position_cd != 0.00
join p1 where p1.person_id = p.updt_id
;	and pi.active_ind = 1
order by UPDATED DESC, USERFULLNAME
with format(date, ";;q")
 
 
 
/*************************/
/* POSITION CODE_VALUE # */
/*************************/
select distinct
	  position = uar_get_code_display(gs.security_group_cd)
	 ,pos_cd = gs.security_group_cd
;	 ,active_status = uar_get_code_display(gs.active_status_cd)
;	 ,gs.parent_entity_name
;	 ,gs.active_ind
from DA_GROUP_SECURITY gs
where gs.parent_entity_name = "DA_FOLDER"
;	and f.public_ind = 1
;	and gs.active_ind = 0
order by position, pos_cd
with nocounter, format, separator = " "
 
 
 
/*####################################################################################*/
 
/***************************/
/* FOLDERS BY THE POSITION */
/***************************/
select distinct
	 position = uar_get_code_display(gs.security_group_cd)
	,folder = cnvtupper(f.da_folder_name)
from DA_GROUP_SECURITY gs
	,(inner join DA_FOLDER f on f.da_folder_id = gs.parent_entity_id)
where 1=1 ;and gs.end_effective_dt_tm > sysdate
	and gs.security_group_cd =  2562494235.00   /*POSITION*/
;	and gs.active_ind = 1
	and f.public_ind = 1
;	and f.parent_folder_id = 0.00
order by position, folder, gs.security_group_cd
with maxrec=1000,time=15
 
 
 
/***************************/
/* POSITIONS BY THE FOLDER */
/***************************/
select ;distinct
	  folder = cnvtupper(f.da_folder_name)
	 ,position = uar_get_code_display(gs.security_group_cd)
from DA_GROUP_SECURITY gs
	,(inner join DA_FOLDER f on f.da_folder_id = gs.parent_entity_id)
where gs.end_effective_dt_tm > sysdate
;	and gs.security_group_cd =      181196459.00;   /*POSITION*/
	and gs.active_ind = 1
	and f.public_ind = 1
;	and f.parent_folder_id = 0.00
	and cnvtlower(f.da_folder_name) = "core*" ;"Long Term Care"
order by folder, position, gs.security_group_cd
with maxrec=1000,time=15
 
/*####################################################################################*/
 
 
 
/*********************/
/* PRSNL & POSTITION */
/*********************/
select distinct
 	 pid=pl.person_id
	,username = pl.username
	,name = cnvtupper(pl.name_full_formatted)
	,pos = uar_get_code_display(pl.position_cd)
;	,org = o.org_name
	,discernuser = if(pi.active_ind = 1) "*YES*" else "NO" endif
from PRSNL pl
;	,(inner join PRSNL_ORG_RELTN por on por.person_id = pl.person_id)
;	,(inner join ORGANIZATION o on o.organization_id = por.organization_id)
	,(left join PRSNL_INFO pi on pi.person_id = pl.person_id)
WHERE pl.position_cd != 0.00
	and pl.active_ind = 1
	and textlen(pl.username) > 1
	and pl.prsnl_type_cd = 906.00 ;USER
;	and pl.position_cd = 441.00 ;POSITION  DBA
;	and pi.info_type_cd = 19111828.00 ;DISCERN USER
;	and cnvtlower(pl.name_full_formatted) != "*cerner*"
order by
	pos, pl.name_full_formatted, pl.username, pl.person_id
with nocounter, format, separator = " ", time=60
 
 
 
/***************************/
/* USER COUNT BY POSTITION */
/***************************/
select distinct
	 position = uar_get_code_display(pl.position_cd)
 	,usercnt = count(pl.person_id) over(partition by pl.position_cd)
from PRSNL pl
where pl.position_cd != 0.00
	and pl.active_ind = 1
	and textlen(pl.username) > 1
	and pl.prsnl_type_cd = 906.00 ;USER
order by
	position
with nocounter, format, separator = " ", time=60
 
 
 
/***************/
/* FOLDER LIST */
/***************/
select distinct
	 folder = f.da_folder_name
	 ,f.*
from DA_FOLDER f
where f.public_ind = 1
;	and f.parent_folder_id = 0.00
order by folder
with maxrec=5000,time=15
 
 
 
/***********************/
/* FOLDERS AND REPORTS */
/***********************/
select distinct
	 foldername = f.da_folder_name
	,reportname = r.report_name
	,reportalias = fr.report_alias_name
	,reporttype =
		if(uar_get_code_display(r.report_type_cd) = "URL Report") "PowerInsight"
			elseif (substring(1,3,cnvtlower(r.report_name)) = "cov") "Custom CCL Report"
			else uar_get_code_display(r.report_type_cd)
		endif
from DA_FOLDER f
	,(inner join DA_FOLDER_REPORT_RELTN fr on fr.da_folder_id = f.da_folder_id)
	,(inner join DA_REPORT r on r.da_report_id = fr.da_report_id)
where 1=1
	and f.public_ind = 1
;	and f.da_folder_name = "Supplies"
;	and cnvtlower(r.report_name) = "*copy"
;	and cnvtlower(fr.report_alias_name) = "*over*"
order by foldername, reportname, r.da_report_id
with nocounter, format, separator = " ", time=30
 
 
 
/****************************************************/
/* SECURITY GROUPS - READ, WRITE, COPY, DELETE, ETC */
/****************************************************/
select distinct
	group = uar_get_code_display(us.security_assignment_cd)
from DA_USER_SECURITY us
order by group
with nocounter, format, separator = " ", maxrec=5000,time=15
 
 
 
/******************************/
/* CUSTOM DEVELOPMENT REPORTS */
/******************************/
select
	 foldername = f.da_folder_name
	,reportname = r.report_name
	,reporttype =
		if(uar_get_code_display(r.report_type_cd) = "URL Report") "PowerInsight"
			elseif (substring(1,3,cnvtlower(r.report_name)) = "cov") "CCL"
			else uar_get_code_display(r.report_type_cd)
		endif
from DA_FOLDER f
	,(inner join DA_FOLDER_REPORT_RELTN fr on fr.da_folder_id = f.da_folder_id)
	,(inner join DA_REPORT r on r.da_report_id = fr.da_report_id)
where f.public_ind = 1
and substring(1,3,cnvtlower(r.report_name)) = "cov"
order by foldername, reportname
with nocounter, format, separator = " ", time=30
 
 
 
/*********************/
/* RULES/ALERTS LIST */
/*********************/
select
	 Rule_Name = d.object_name
	,Update_Date = d.datestamp
	,Update_Time = d.timestamp
	,d.*
from
	dprotect d
where
	cnvtupper(d.source_name) LIKE "*.EKM"
;	d.object_name = "RX_RPT_AV_AUDIT_BY_ORDERABLE"
order by d.source_name
with maxrec=10000, time=30
 
 
 
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			    Steve Czubek
	Date Written:		October 2022
	Solution:
	Source file name:  	COV_AP_CORRECTED_REPORTS.prg
	Object name:		COV_AP_CORRECTED_REPORTS
	Request#:
 
	Program purpose:	PathNet AP Corrected Reports
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
10/11/22    Steve Czubek      		CR 12350 Convert from DA2 report and add facility prompt
 
******************************************************************************/
drop program COV_AP_CORRECTED_REPORTS:dba go
create program COV_AP_CORRECTED_REPORTS:dba
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Begin Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Facility" = 0
 
with OUTDEV, beg_dt, end_dt, facility
 
 
%i cust_script:SC_CPS_GET_PROMPT_LIST.inc
 
declare fac_parser = vc with protect, noconstant("1=1")
set fac_parser = GetPromptList(parameter2($facility), "e.loc_facility_cd")
 
 
declare CORRECTED = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 1305, "CORRECTED"))
declare CORRECTIONINITIATED = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 1305, "CORRECTIONINITIATED"))
declare CORRECTIONINPROCESS = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 1305, "CORRECTIONINPROCESS"))
declare VERIFICATIONINPROCESS = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 1305, "VERIFICATIONINPROCESS"))
declare VERIFY = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 21, "VERIFY"))
 
 
SELECT into $outdev
Last_Verification_Date_Time = format(ce.verified_dt_tm, "MM-DD-YYYY HH:MM")
,Service_Resource = uar_get_code_display(rt.service_resource_cd)
,Facility = uar_get_code_display(e.loc_facility_cd)
,Raw_Accession_Number = PC.ACCESSION_NBR
,Report_Procedure_Display = uar_get_code_display(CR.CATALOG_CD)
,Verification_Date_Time = format(cep.ACTION_DT_TM, "MM-DD-YYYY HH:MM")
,Verified_By_Name = cep_ps.name_full_formatted
,Last_Correct_Action_Type_Disp = uar_get_code_display(cr.status_cd)
,Case_Collection_Date_Time = format(pc.case_collect_dt_tm, "MM-DD-YYYY HH:MM")
,Formatted_Accession_Number = cnvtacc(pc.accession_nbr)
,Person_Name_Formatted = per.NAME_FULL_FORMATTED
,Main_Report_Complete_Date_Time = format(pc.main_report_cmplete_dt_tm, "MM-DD-YYYY HH:MM")
,Requesting_Physician_Name = req_ps.name_full_formatted
  ,Responsible_Pathologist_Name = res_pat_ps.name_full_formatted
  ,Responsible_Resident_Name = res_res_ps.name_full_formatted
  ,Report_Resp_Path_Name = rres_pat_ps.name_full_formatted
  ,Report_Resp_Resident_Name = rres_res_ps.name_full_formatted
  ,Last_Verified_By_Name = ce_ver_ps.name_full_formatted
  ,Prefix_Display = APP.PREFIX_NAME
  ,Case_Type_Display = uar_get_code_display(pc.case_type_cd)
FROM
    PERSON PER
  , PATHOLOGY_CASE PC
  , encounter e
  , prsnl req_ps
  , prsnl res_res_ps
  , prsnl res_pat_ps
  , AP_PREFIX APP
  , CASE_REPORT CR
  , CLINICAL_EVENT CE
  , prsnl ce_ver_ps
  , CE_EVENT_PRSNL cep
  , prsnl cep_ps
  , REPORT_TASK RT
  , prsnl rres_res_ps
  , prsnl rres_pat_ps
plan pc
    where pc.case_collect_dt_tm BETWEEN cnvtdatetime(concat($beg_dt, " 00:00"))
    and cnvtdatetime(concat($end_dt, " 23:59:59"))
    and pc.reserved_ind = 0
join e
    where e.encntr_id = pc.encntr_id
    and parser(fac_parser)
join req_ps
    where req_ps.person_id = pc.requesting_physician_id
join res_res_ps
    where res_res_ps.person_id = pc.responsible_resident_id
join res_pat_ps
    where res_pat_ps.person_id = pc.responsible_pathologist_id
join app
    where app.prefix_id = pc.prefix_id
join per
    where per.person_id = pc.person_id
join cr
    where cr.case_id = pc.case_id
    and cr.status_cd in (
                        CORRECTED
                        ,CORRECTIONINITIATED
                        ,CORRECTIONINPROCESS
                        ,VERIFICATIONINPROCESS)
join rt
    where rt.report_id = cr.report_id
join rres_res_ps
    where rres_res_ps.person_id = rt.responsible_resident_id
join rres_pat_ps
    where rres_pat_ps.person_id = rt.responsible_pathologist_id
join ce
    where cr.event_id = ce.event_id
    and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
join ce_ver_ps
    where ce_ver_ps.person_id = ce.verified_prsnl_id
join cep
    where cep.event_id = ce.event_id
    and cep.ACTION_TYPE_CD = VERIFY
    and cep.VALID_UNTIL_DT_TM  > cnvtdatetime(curdate, curtime)
join cep_ps
    where cep_ps.person_id = cep.action_prsnl_id
 
ORDER BY ce.verified_dt_tm
  , PC.ACCESSION_NBR
  , Report_Procedure_Display
  , cep.ACTION_DT_TM
  , Verified_By_Name
  , Last_Correct_Action_Type_Disp
  , pc.case_collect_dt_tm
  , pc.accession_nbr
  , per.NAME_FULL_FORMATTED
  , pc.main_report_cmplete_dt_tm
;  , omf_get_prsnl_full(pc.requesting_physician_id)
;  , omf_get_prsnl_full(pc.responsible_pathologist_id)
;  , omf_get_prsnl_full(pc.responsible_resident_id)
;  , omf_get_prsnl_full(rt.responsible_pathologist_id)
;  , omf_get_prsnl_full(rt.responsible_resident_id)
;  , omf_get_prsnl_full(ce.verified_prsnl_id)
;  , APP.PREFIX_NAME
;  , omf_get_cv_display(pc.case_type_cd)
with format, separator = " ", time = 200
 
end
go

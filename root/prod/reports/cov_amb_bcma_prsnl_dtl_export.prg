 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			David Baumgardner
	Date Written:		Jan '2022
	Solution:			Ambulatory/Pharmacy
	Source file name:	      cov_amb_bcma_prsnl_dtl_export.prg
	Object name:		cov_amb_bcma_pat_level_export
	Request#:			9552
	Program purpose:	      BCMA Compliance Detail - Patient level export to AStream
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------
********************************************************************************************************************/
 
drop program cov_amb_bcma_prsnl_dtl_export:DBA go
create program cov_amb_bcma_prsnl_dtl_export:DBA
 
prompt
	"Output file" = "MINE"
	, "Export to R2W" = 0
 
with OUTDEV, MonthExport
 
 
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
 
declare cnt1 = i4 with protect
 
declare ccnt = i4 with protect
declare ocnt = i4 with protect
declare full_cnt = i4 with protect
declare array_join_var = vc with protect
 
declare initcap()     = c100
declare opr_clinic_var    = vc with noconstant("")
declare num  = i4 with noconstant(0)
 
;create file functions for export to R2W
declare file_var						= vc with constant(build("cmg_corporate-"
					, "week_cov_amb_bcma_prsnl_detail.xls")) ;12/7/21 DWB
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;12/7/21 DWB
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;12/7/21 DWB
;\\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\ClinicalAncillary\Ambulatory\AmbBCMA
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/", file_var))
 
;create variables for the export for the week
declare week_file_var						= vc with noconstant("") ;12/7/21 DWB
;declare week_file_var						= vc with constant(build("cmg_corporate-"
;					, "week_cov_amb_bcma_pat_level.xls")) ;12/7/21 DWB
declare week_temppath_var = vc with noconstant("")
declare week_temppath2_var = vc with noconstant("")
;\\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\ClinicalAncillary\Ambulatory\AmbBCMA
declare week_filepath_var					= vc with noconstant("")
declare org_name							= vc with noconstant("")
;;declare week_filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;;															 	 "_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/",
;;															 	 week_file_var))
declare cmd								= vc with noconstant("") ;12/7/21 DWB
declare len								= i4 with noconstant(0) ;12/7/21 DWB
declare stat							= i4 with noconstant(0) ;12/7/21 DWB
set output_var = value(temppath_var)
 
if($monthExport)
	SET bdate = CNVTLOOKBEHIND("1,M",CNVTDATETIME(CURDATE - DAY(CURDATE),0))
	SET edate = CNVTDATETIME(CURDATE-DAY(CURDATE)-1,235959)
else
	SET bdate = CNVTDATETIME(CURDATE-7, 0)
	SET edate = CNVTDATETIME(CURDATE,235959)
endif
 
;----------------------------------------------------------------------------------------------
 
RECORD bcma_sum(
	1 report_ran_by = vc
	1 list[*]
		2 org_id = f8
		2 clinic = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
		2 prsnl_name = vc
		2 prsnl_role = vc
		2 pr_tot_med_given = f8
		2 pr_tot_med_scan = f8
		2 pr_tot_wrist_scan = f8
		2 pr_tot_compliance = f8
)
RECORD bcma_sum_full(
	1 report_ran_by = vc
	1 list[*]
		2 org_id = f8
		2 clinic = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
		2 prsnl_name = vc
		2 prsnl_role = vc
		2 pr_tot_med_given = f8
		2 pr_tot_med_scan = f8
		2 pr_tot_wrist_scan = f8
		2 pr_tot_compliance = f8
)
set full_cnt = 0
set stat = alterlist(bcma_sum_full->list,50)
 
record cmgOrgList (
  1 olist[*]
  	2 organization = f8
  	2 org_name = c100
)
/**************************************************************
; DVDev Start Coding
**************************************************************/
/*********************************
*  Build list of CMG clinics
***********************************/
SELECT *
FROM ORG_SET_ORG_R ORG_S_ORG_R,
	(inner join ORGANIZATION O on o.organization_id = ORG_S_ORG_R.organization_id)
WHERE ORG_S_ORG_R.org_set_id = 3875838.00
head report
    ccnt = 0
    stat = alterlist(cmgOrgList->olist,50)
detail
	ccnt = ccnt+1
	if(mod(ccnt,10)=1 and ccnt > 50)
		stat = alterlist(cmgOrgList->olist,ccnt+9)
	endif
	cmgOrgList->olist[ccnt].organization = ORG_S_ORG_R.organization_id
	cmgOrgList->olist[ccnt].org_name = O.org_name
foot report
	stat = alterlist(cmgOrgList->olist, ccnt)
with nocount
 
if($monthExport = 0)
for (cnt1=1 to ccnt)
	set org_id = cmgOrgList->olist[cnt1].organization
	set org_name = replace(trim(cmgOrgList->olist[cnt1].org_name),"-","")
	set org_name = replace(org_name," ","_")
	set week_file_var = build(org_name,"-week_bcma_prsnl_detail.xls")
 
	set week_temppath_var					= build("cer_temp:", cnvtlower(week_file_var))
	set week_temppath2_var					= build("$cer_temp/", cnvtlower(week_file_var))
	set week_filepath_var					= build("/cerner/w_custom/", cnvtlower(curdomain),
				"_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/", week_file_var)
 
	set week_output_var = value(week_temppath_var)
 
	execute cov_amb_bcma_prsnl_detail "MINE", bdate, edate, org_id
 
	select
 
	clinic = SUBSTRING(1, 100, BCMA_SUM->list[D1.SEQ].clinic)
	, FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
	, FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
	, FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
	, FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
	, PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
	, PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
	, PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
	, PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
	, PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
	, PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
	from
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
	plan d1
	order by clinic
	head report
		ocnt = 0
	detail
 		if(trim(clinic) != "")
			ocnt = ocnt+1
			full_cnt = full_cnt+1
			if(mod(full_cnt,10)=1 and full_cnt > 50)
				stat = alterlist(bcma_sum_full->list,full_cnt+9)
			endif
 
			bcma_sum_full->list[full_cnt].clinic = clinic
			bcma_sum_full->list[full_cnt].org_id = org_id
			bcma_sum_full->list[full_cnt].fac_tot_med_given = FAC_TOT_MED_GIVEN
			bcma_sum_full->list[full_cnt].fac_tot_med_scan = FAC_TOT_MED_SCAN
			bcma_sum_full->list[full_cnt].fac_tot_wrist_scan = FAC_TOT_WRIST_SCAN
			bcma_sum_full->list[full_cnt].fac_tot_compliance = FAC_TOT_COMPLIANCE
			bcma_sum_full->list[full_cnt].PRSNL_NAME = PRSNL_NAME
			bcma_sum_full->list[full_cnt].PRSNL_ROLE = PRSNL_ROLE
			bcma_sum_full->list[full_cnt].PR_TOT_MED_GIVEN = PR_TOT_MED_GIVEN
			bcma_sum_full->list[full_cnt].PR_TOT_MED_SCAN = PR_TOT_MED_SCAN
			bcma_sum_full->list[full_cnt].PR_TOT_WRIST_SCAN = PR_TOT_WRIST_SCAN
			bcma_sum_full->list[full_cnt].PR_TOT_COMPLIANCE = PR_TOT_COMPLIANCE
		endif
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	if(ocnt > 0)
		select into value(week_output_var)
 
		clinic = SUBSTRING(1, 100, BCMA_SUM->list[D1.SEQ].clinic)
		, FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
		, FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
		, FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
		, FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
		, PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
		, PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
		, PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
		, PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
		, PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
		, PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
		from
		(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
		plan d1
		order by clinic
		WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
		set cmd = build2("cp ", week_temppath2_var, " ", week_filepath_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
	endif
;	SET CURECHO = 3	; change level from 0 to 3
 
;	call echo(week_temppath2_var)
 
endfor
 
	set stat = alterlist(bcma_sum_full->list, full_cnt)
 
/*12/7/21 DWB export data for R2W*/
	select into value(output_var)
 
		clinic = SUBSTRING(1, 100, bcma_sum_full->list[D1.SEQ].clinic)
;	, ORG_ID = bcma_sum_full->list[D1.SEQ].org_id
	, FAC_TOT_MED_GIVEN = bcma_sum_full->list[D1.SEQ].fac_tot_med_given
	, FAC_TOT_MED_SCAN = bcma_sum_full->list[D1.SEQ].fac_tot_med_scan
	, FAC_TOT_WRIST_SCAN = bcma_sum_full->list[D1.SEQ].fac_tot_wrist_scan
	, FAC_TOT_COMPLIANCE = bcma_sum_full->list[D1.SEQ].fac_tot_compliance
	, PRSNL_NAME = SUBSTRING(1, 30, bcma_sum_full->list[D1.SEQ].prsnl_name)
	, PRSNL_ROLE = SUBSTRING(1, 30, bcma_sum_full->list[D1.SEQ].prsnl_role)
	, PR_TOT_MED_GIVEN = bcma_sum_full->list[D1.SEQ].pr_tot_med_given
	, PR_TOT_MED_SCAN = bcma_sum_full->list[D1.SEQ].pr_tot_med_scan
	, PR_TOT_WRIST_SCAN = bcma_sum_full->list[D1.SEQ].pr_tot_wrist_scan
	, PR_TOT_COMPLIANCE = bcma_sum_full->list[D1.SEQ].pr_tot_compliance
 
	from
	(DUMMYT   D1  WITH SEQ = SIZE(bcma_sum_full->list, 5))
 
	plan d1
 
	/*Non-Formulary Items
	WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
		and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
	*/
 
	order by clinic
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
;	call echo(build2(cmd, " : ", stat))
;	call echo(array_join_var)
;
else
 
	set month_file_var = build("cmg_corporate","-month_bcma_prsnl_detail.xls")
 
	set month_temppath_var					= build("cer_temp:", cnvtlower(month_file_var))
	set month_temppath2_var					= build("$cer_temp/", cnvtlower(month_file_var))
	set month_filepath_var					= build("/cerner/w_custom/", cnvtlower(curdomain),
				"_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/", month_file_var)
 
	set month_output_var = value(month_temppath_var)
 
EXECUTE cov_amb_bcma_prsnl_detail "MINE", bdate,edate,0.0
 
/*12/7/21 DWB export data for R2W*/
	select into value(month_output_var)
 
		clinic = SUBSTRING(1, 100, BCMA_SUM->list[D1.SEQ].clinic)
	, FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
	, FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
	, FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
	, FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
	, PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
	, PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
	, PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
	, PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
	, PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
	, PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
	from
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
	plan d1
 
	/*Non-Formulary Items
	WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
		and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
	*/
 
	order by clinic
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", month_temppath2_var, " ", month_filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
#exitscript
 
end go
 
 
 
 

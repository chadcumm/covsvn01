 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			David Baumgardner
	Date Written:		Dec'2021
	Solution:			Ambulatory/Pharmacy
	Source file name:	      cov_amb_bcma_pat_level_export.prg
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
12/7/2021	David Baumgardner	CR9552 - Adding this report to R2W using Astream.
********************************************************************************************************************/
 
drop program cov_amb_bcma_pat_level_export:DBA go
create program cov_amb_bcma_pat_level_export:DBA
 
prompt
	"Output file" = "MINE"
	, "Export to R2W" = 0
 
with OUTDEV, MonthExport
 
 
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
 
declare cnt1 = i4 with protect
declare array_join_var = vc with protect
 
declare initcap()     = c100
declare opr_clinic_var    = vc with noconstant("")
declare num  = i4 with noconstant(0)
 
;create file functions for export to R2W
declare file_var						= vc with constant(build("cmg_corporate-"
					, "month_cov_amb_bcma_pat_level.xls")) ;12/7/21 DWB
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;12/7/21 DWB
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;12/7/21 DWB
;\\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\ClinicalAncillary\Ambulatory\AmbBCMA
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/", file_var))
 
;create variables for the export for the week
if($monthExport)
declare week_file_var						= vc with constant(build("cmg_corporate-"
					, "month_cov_amb_bcma_pat_level.xls")) ;12/7/21 DWB
else
declare week_file_var						= vc with constant(build("cmg_corporate-"
					, "week_cov_amb_bcma_pat_level.xls")) ;12/7/21 DWB
endif
declare week_temppath_var					= vc with constant(build("cer_temp:", week_file_var)) ;12/7/21 DWB
declare week_temppath2_var					= vc with constant(build("$cer_temp/", week_file_var)) ;12/7/21 DWB
;\\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\ClinicalAncillary\Ambulatory\AmbBCMA
declare week_filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbBCMA/",
															 	 week_file_var))
declare cmd								= vc with noconstant("") ;12/7/21 DWB
declare len								= i4 with noconstant(0) ;12/7/21 DWB
declare stat							= i4 with noconstant(0) ;12/7/21 DWB
set output_var = value(temppath_var)
set week_output_var = value(week_temppath_var)
 
SET bdate = CNVTDATETIME(CURDATE-31, 0)
SET edate = CNVTDATETIME(CURDATE,235959)
 
;----------------------------------------------------------------------------------------------
Record bcma(
	1 plist[*]
		2 clinic = vc
		2 orgid = f8
		2 nurse_unit = vc
		2 prsnl_name = vc
		2 prsnl_position = vc
		2 fin = vc
		2 patient_name = vc
		2 medication = vc
		2 med_admin_dt = vc
		2 med_admin_eventid = f8
		2 medication_scanned = vc
		2 wristband_scanned = vc
		2 med_over_reason = vc
		2 armband_over_reason = vc
		2 med_admin_alertid = f8
		2 med_admin_count = i4
		2 result_status = vc
		2 source = vc
		2 eventid = f8
		2 orderid = f8
		2 catalogcd = f8
		2 non_bcma_med = vc
		2 order_mnemonic = vc
		2 itemid = f8
		2 charge_number = vc
)
 
record cmgOrgList (
  1 olist[*]
  	2 organization = f8
)
/**************************************************************
; DVDev Start Coding
**************************************************************/
/*********************************
*  Build list of CMG clinics
***********************************/
SELECT *
FROM ORG_SET_ORG_R ORG_S_ORG_R
WHERE ORG_S_ORG_R.org_set_id = 3875838.00
head report
    ocnt = 0
    stat = alterlist(cmgOrgList->olist,50)
	numx = 0
head ORG_S_ORG_R.organization_id
	ocnt = ocnt+1
	if(mod(ocnt,10)=1 and ocnt > 50)
		stat = alterlist(cmgOrgList->olist,ocnt+9)
	endif
	cmgOrgList->olist[ocnt].organization = ORG_S_ORG_R.organization_id
 
foot report
	stat = alterlist(cmgOrgList->olist, ocnt)
with nocount
set array_join_var = cmgOrgList->olist[1].organization
for (cnt1=2 to ocnt)
    set array_join_var = concat(array_join_var,",",cmgOrgList->olist[cnt1].organization)
endfor
 
;set array_join_var = ArrayJoin(cmgOrgList->olist,",","","")
 
 
/*Run the report data collection*/
/*EXECUTE COV_AMB_BCMA_PAT_LEVEL "MINE", bdate, edate,
value(     3162038.00,     3245330.00,     3162040.00,     3162035.00,     3245331.00,     3162034.00
,     3192034.00,     3192035.00,     3192036.00,     3192037.00,     3863285.00,     3192038.00
,     3192039.00,     3192063.00,     3192040.00,     1024423.00,     3853854.00,     3192041.00
,     3192042.00,     3263461.00,     3192043.00,     3852512.00,     3192045.00,     3192044.00
,     3192046.00,     3192047.00,     3192048.00,     3263466.00,     3192084.00,     3192083.00
,     3192085.00,     3192050.00,     3192086.00,     3192087.00,     3192088.00,     3192089.00
,     3192114.00,     3192074.00,     3192075.00,     3192073.00,     3815495.00,     3192051.00
,     3192091.00,     3192092.00,     3192093.00,     3192094.00,     3192095.00,     3363371.00
,     3363372.00,     3853675.00,     3192096.00,     3192097.00,     3192098.00,     3192099.00
,     3192100.00,     3192101.00,     3192052.00,     3192057.00,     3192056.00,     3192053.00
,     3278330.00,     3192054.00,     3192055.00,     3192058.00,     3814204.00,     3192102.00
,     3192116.00,     3192059.00,     3192060.00,     3192062.00,     3192103.00,     3192104.00
,     3192077.00,     3192106.00,     3242293.00,     3301968.00,     3192078.00,     3829177.00
,     3192079.00,     3192107.00,     3192108.00,     3192110.00,     3192111.00,     3192112.00
,     3772478.00,     3192118.00,     3192117.00,     3192119.00,     3192120.00,     3445671.00
,     3192072.00,     3853860.00,     3192064.00,     3192080.00,     3192081.00,     3162041.00
,     3162039.00,     3162037.00,     3192066.00,     3192068.00,     3192065.00,     3192067.00
,     3192069.00,     3192082.00,     3192071.00,     3192070.00,     3920488.00,     3162036.00
,     3875601.00,     3882278.00,     3333213.00,     3569289.00,     3333174.00,     3890014.00
,     3192090.00,     3569190.00)
 
/*12/7/21 DWB export data for R2W*/
/*	select into value(output_var)
 
		clinic = trim(substring(1, 300, bcma->plist[d1.seq].clinic))
		, personnel_name = trim(substring(1, 80, bcma->plist[d1.seq].prsnl_name))
		, personnel_position = trim(substring(1, 100, bcma->plist[d1.seq].prsnl_position))
		, fin = trim(substring(1, 10, bcma->plist[d1.seq].fin))
		, patient_name = trim(substring(1, 80, bcma->plist[d1.seq].patient_name))
		, medication = trim(substring(1, 300, bcma->plist[d1.seq].medication))
		, non_bcma_med = trim(substring(1, 5, bcma->plist[d1.seq].non_bcma_med))
		, charge_number = trim(substring(1, 10, bcma->plist[d1.seq].charge_number))
		, administered_dt_tm = trim(substring(1, 30, bcma->plist[d1.seq].med_admin_dt))
		, medication_scanned = trim(substring(1, 30, bcma->plist[d1.seq].medication_scanned))
		, wristband_scanned = trim(substring(1, 30, bcma->plist[d1.seq].wristband_scanned))
		, med_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].med_over_reason))
		, armband_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].armband_over_reason))
		, med_admin_count = bcma->plist[d1.seq].med_admin_count
		, result_status = trim(substring(1, 30, bcma->plist[d1.seq].result_status))
		, source = trim(substring(1, 30, bcma->plist[d1.seq].source))
		, orderid = bcma->plist[d1.seq].orderid
		, itemid = bcma->plist[d1.seq].itemid
		, catalog_cd = bcma->plist[d1.seq].catalogcd
 
	from
		(dummyt   d1  with seq = size(bcma->plist, 5))
 
	plan d1
 
	/*Non-Formulary Items
	WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
		and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
	*/
 
/*	order by clinic, personnel_position, personnel_name, medication
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
	call echo(array_join_var)*/
 
 
if($monthExport)
	SET bdate = CNVTLOOKBEHIND("1,M",CNVTDATETIME(CURDATE - DAY(CURDATE),0))
	SET edate = CNVTDATETIME(CURDATE-DAY(CURDATE)-1,235959)
else
	SET bdate = CNVTDATETIME(CURDATE-7, 0)
	SET edate = CNVTDATETIME(CURDATE,235959)
endif
/* run for past week*/
EXECUTE COV_AMB_BCMA_PAT_LEVEL "MINE", bdate,edate,
value(     3162038.00,     3245330.00,     3162040.00,     3162035.00,     3245331.00,     3162034.00
,     3192034.00,     3192035.00,     3192036.00,     3192037.00,     3863285.00,     3192038.00
,     3192039.00,     3192063.00,     3192040.00,     1024423.00,     3853854.00,     3192041.00
,     3192042.00,     3263461.00,     3192043.00,     3852512.00,     3192045.00,     3192044.00
,     3192046.00,     3192047.00,     3192048.00,     3263466.00,     3192084.00,     3192083.00
,     3192085.00,     3192050.00,     3192086.00,     3192087.00,     3192088.00,     3192089.00
,     3192114.00,     3192074.00,     3192075.00,     3192073.00,     3815495.00,     3192051.00
,     3192091.00,     3192092.00,     3192093.00,     3192094.00,     3192095.00,     3363371.00
,     3363372.00,     3853675.00,     3192096.00,     3192097.00,     3192098.00,     3192099.00
,     3192100.00,     3192101.00,     3192052.00,     3192057.00,     3192056.00,     3192053.00
,     3278330.00,     3192054.00,     3192055.00,     3192058.00,     3814204.00,     3192102.00
,     3192116.00,     3192059.00,     3192060.00,     3192062.00,     3192103.00,     3192104.00
,     3192077.00,     3192106.00,     3242293.00,     3301968.00,     3192078.00,     3829177.00
,     3192079.00,     3192107.00,     3192108.00,     3192110.00,     3192111.00,     3192112.00
,     3772478.00,     3192118.00,     3192117.00,     3192119.00,     3192120.00,     3445671.00
,     3192072.00,     3853860.00,     3192064.00,     3192080.00,     3192081.00,     3162041.00
,     3162039.00,     3162037.00,     3192066.00,     3192068.00,     3192065.00,     3192067.00
,     3192069.00,     3192082.00,     3192071.00,     3192070.00,     3920488.00,     3162036.00
,     3875601.00,     3882278.00,     3333213.00,     3569289.00,     3333174.00,     3890014.00
,     3192090.00,     3569190.00)
 
/*12/7/21 DWB export data for R2W*/
	select into value(week_output_var)
 
		clinic = trim(substring(1, 300, bcma->plist[d1.seq].clinic))
		, personnel_name = trim(substring(1, 80, bcma->plist[d1.seq].prsnl_name))
		, personnel_position = trim(substring(1, 100, bcma->plist[d1.seq].prsnl_position))
		, fin = trim(substring(1, 10, bcma->plist[d1.seq].fin))
		, patient_name = trim(substring(1, 80, bcma->plist[d1.seq].patient_name))
		, medication = trim(substring(1, 300, bcma->plist[d1.seq].medication))
		, non_bcma_med = trim(substring(1, 5, bcma->plist[d1.seq].non_bcma_med))
		, charge_number = trim(substring(1, 10, bcma->plist[d1.seq].charge_number))
		, administered_dt_tm = trim(substring(1, 30, bcma->plist[d1.seq].med_admin_dt))
		, medication_scanned = trim(substring(1, 30, bcma->plist[d1.seq].medication_scanned))
		, wristband_scanned = trim(substring(1, 30, bcma->plist[d1.seq].wristband_scanned))
		, med_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].med_over_reason))
		, armband_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].armband_over_reason))
		, med_admin_count = bcma->plist[d1.seq].med_admin_count
		, result_status = trim(substring(1, 30, bcma->plist[d1.seq].result_status))
		, source = trim(substring(1, 30, bcma->plist[d1.seq].source))
		, orderid = bcma->plist[d1.seq].orderid
		, itemid = bcma->plist[d1.seq].itemid
		, catalog_cd = bcma->plist[d1.seq].catalogcd
 
	from
		(dummyt   d1  with seq = size(bcma->plist, 5))
 
	plan d1
 
	/*Non-Formulary Items
	WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
		and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
	*/
 
	order by clinic, personnel_position, personnel_name, medication
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", week_temppath2_var, " ", week_filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
#exitscript
 
end go
 
 
 
 

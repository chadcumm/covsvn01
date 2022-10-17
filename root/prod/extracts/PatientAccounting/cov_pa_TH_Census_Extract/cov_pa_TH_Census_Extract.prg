/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/25/2022
	Solution:			Revenue Cycle - Patient Accounting
	Source file name:	cov_pa_TH_Census_Extract.prg
	Object name:		cov_pa_TH_Census_Extract
	Request #:			13529
 
	Program purpose:	Provides data for patients admitted to acute facilities.
 
	Executing from:		CCL
 
 	Special Notes:		Adopted from STAR SQL:
 							- QBCC_TEAM_HEALTH_CENSUS_RPT
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/

DROP PROGRAM cov_pa_TH_Census_Extract:dba GO
CREATE PROGRAM cov_pa_TH_Census_Extract:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file (used for testing by IT) 

with OUTDEV, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare start_datetime			= dq8 with noconstant(cnvtlookbehind("0, d", cnvtdatetime(curdate, 000000)))
declare end_datetime			= dq8 with noconstant(cnvtlookbehind("0, d", cnvtdatetime(curdate, 235959)))
declare day_datetime			= dq8 with noconstant(cnvtlookbehind("0, d", cnvtdatetime(curdate, 235959)))

declare alternate_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "ALTERNATE"))
declare inpatient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT"))
declare observation_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION"))
declare op_bed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED"))
declare covenant_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
declare email_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "EMAIL"))
declare phy_num_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare org_phy_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare attend_phy_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare admit_phy_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN"))
declare consult_phy_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "CONSULTINGPHYSICIAN"))
declare th_hospital_med_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 357, "TEAMHEALTHHOSPITALMED"))
declare provider_group_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 19189, "PROVIDERGROUP"))
 
declare num					= i4 with noconstant(0)

declare file_var			= vc with noconstant(build("team_census_", format(curdate, "yyyymmdd;;d"), ".txt"))

declare temppath_var		= vc with constant(build("cer_temp:", file_var))
declare temppath2_var		= vc with constant(build("$cer_temp/", file_var))

declare filepath_var		= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													 "_cust/to_client_site/RevenueCycle/PatientAccounting/", file_var))
															 
declare output_var			= vc with noconstant("")
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)


; define date values
if (validate(request->batch_selection) != 1)
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif


; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif

 
/**************************************************************
; DVDev Start Coding
**************************************************************/

free set prsnl_group_data
record prsnl_group_data (
	1 cnt							= i4
	1 list[*]
		2 prsnl_id					= f8
		2 prsnl_name				= c100
		2 prsnl_alias				= c10
)

free set enc_loc_data
record enc_loc_data (
	1 start_datetime				= vc
	1 end_datetime					= vc
	
	1 cnt							= i4
	1 list[*]
		2 encntr_loc_hist_id		= f8
		2 encntr_id					= f8
)

free set enc_data
record enc_data (
	1 cnt							= i4
	1 list [*]
		2 encntr_id					= f8
		2 encntr_loc_hist_id		= f8
		2 pat_type					= c4
		2 fac						= c2
		2 nurse_unit				= c4
		2 bed						= c3
		
		2 person_id					= f8
		2 patient_name				= c100
		2 fin						= c20
		2 mrn						= c20
		2 pat_email					= c100
		2 alt_phone					= c20
		
		2 attend_phy				= c100
		2 attend_phy_id				= c20
		2 admit_phy					= c100
		2 admit_phy_id				= c20
		2 admit_dt_tm				= dq8
		
		2 c_cnt						= i4
		2 consults [10]
			3 consult_phy			= c100
			3 consult_phy_id		= c20
)
 
 
/**************************************************************/
; save prompt data
set enc_loc_data->start_datetime	= format(start_datetime, "mm/dd/yyyy;;d")
set enc_loc_data->end_datetime		= format(end_datetime, "mm/dd/yyyy;;d")


/**************************************************************/
; select provider group data
select into "NL:"
from
	PRSNL_GROUP_RELTN pgr
	
	, (inner join PRSNL_GROUP pg on pg.prsnl_group_id = pgr.prsnl_group_id
		and pg.prsnl_group_class_cd = provider_group_var
		and pg.prsnl_group_type_cd = th_hospital_med_var)
	
	, (inner join PRSNL p on p.person_id = pgr.person_id)
	
	, (inner join PRSNL_ALIAS pa on pa.person_id = p.person_id
		and pa.prsnl_alias_type_cd = org_phy_var)
	
where 1 = 1
	and pgr.active_ind = 1
 
 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	call alterlist(prsnl_group_data->list, cnt)
 
	prsnl_group_data->cnt						= cnt
	prsnl_group_data->list[cnt].prsnl_id		= pgr.person_id
	prsnl_group_data->list[cnt].prsnl_name		= p.name_full_formatted
	prsnl_group_data->list[cnt].prsnl_alias		= pa.alias

with nocounter, time = 60

call echorecord(prsnl_group_data)

;go to exitscript


/**************************************************************/
; select encounter location history data
select into "NL:"	
from
	ENCNTR_LOC_HIST elh
	
where 1 = 1
	and elh.encntr_type_cd in (
		inpatient_var,
		observation_var,
		op_bed_var
	)
	and nullval(elh.loc_bed_cd, 0.0) > 0.0
	and cnvtdatetime(start_datetime) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
	and elh.active_ind = 1
 
 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	call alterlist(enc_loc_data->list, cnt)
 
	enc_loc_data->cnt								= cnt
	enc_loc_data->list[cnt].encntr_loc_hist_id		= elh.encntr_loc_hist_id
	enc_loc_data->list[cnt].encntr_id				= elh.encntr_id

with nocounter, time = 180

call echorecord(enc_loc_data)
 
 
;/**************************************************************/
;; select encounter flex history data
;select into "NL:"
;from
;	ENCNTR_FLEX_HIST efh
;	
;where
;	efh.activity_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
;	and efh.encntr_type_cd in (ed_var, quick_ed_var)
;	and efh.active_ind = 1
;	
;order by
;	efh.encntr_id
;	, efh.activity_dt_tm
;
;; populate record structure	
;head report
;	cnt = 0
;	
;head efh.encntr_id
;	cnt = cnt + 1
; 
;	call alterlist(enc_flex->list, cnt)
; 
;	enc_flex->cnt								= cnt		
;	enc_flex->list[cnt].encntr_flex_hist_id		= efh.encntr_flex_hist_id
;	enc_flex->list[cnt].encntr_id				= efh.encntr_id
;	enc_flex->list[cnt].person_id				= efh.person_id
;	enc_flex->list[cnt].loc_facility_cd			= efh.loc_facility_cd
;	enc_flex->list[cnt].activity_dt_tm			= efh.activity_dt_tm
;	enc_flex->list[cnt].reg_dt_tm				= efh.reg_dt_tm
;	
;with nocounter, time = 120
;
;;call echorecord(enc_flex)
; 
; 
;/**************************************************************/
;; select patient and pcp data
;select into "NL:"
;from
;	ENCNTR_FLEX_HIST efh
;	
;	, (inner join ENCOUNTER e on e.encntr_id = efh.encntr_id
;		and e.reg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
;		and e.active_ind = 1)
;		
;	, (left join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
;		and ea.encntr_alias_type_cd = fin_var
;		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
;		and ea.active_ind = 1)
;		
;	, (inner join PERSON p on p.person_id = e.person_id
;		and p.active_ind =1)
;	
;	, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
;		and cvo.alias in ("B", "F", "G", "L", "M", "P", "R", "S", "T")
;		and cvo.contributor_source_cd = covenant_var)
;		
;	, (inner join PERSON_PRSNL_RELTN ppr on ppr.person_id = e.person_id
;		and ppr.person_prsnl_r_cd = pcp_var
;		and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
;		and ppr.active_ind = 1)
;	
;	, (inner join PRSNL per on per.person_id = ppr.prsnl_person_id
;		and per.physician_ind = 1)
;		
;	, (inner join PRSNL_ALIAS pera on pera.person_id = per.person_id
;		and pera.prsnl_alias_type_cd = org_phy_var
;		and pera.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
;		and pera.active_ind = 1)
;		
;	; first practice site
;	, (inner join PRSNL_RELTN pr on pr.person_id = per.person_id
;		and pr.parent_entity_name = "PRACTICE_SITE"
;		and pr.active_ind = 1
;		and pr.parent_entity_id = (
;			select min(pr2.parent_entity_id)
;			from PRSNL_RELTN pr2
;			where
;				pr2.person_id = pr.person_id
;				and pr2.parent_entity_name = pr.parent_entity_name
;				and pr2.active_ind = pr.active_ind
;			group by
;				pr2.person_id
;		))
; 
;	, (inner join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
; 
;	, (inner join ORGANIZATION org on org.organization_id = ps.organization_id)
;		
;where
;	expand(num, 1, enc_flex->cnt, efh.encntr_flex_hist_id, enc_flex->list[num].encntr_flex_hist_id)
;	and expand(numcmg, 1, cmg_data->cnt, ps.practice_site_id, cmg_data->list[numcmg].practice_site_id)
;	
;order by
;	efh.encntr_flex_hist_id
;
;; populate record structure		
;head efh.encntr_flex_hist_id
;	idx = 0
;	
; 	idx = locateval(numx, 1, enc_flex->cnt, efh.encntr_flex_hist_id, enc_flex->list[numx].encntr_flex_hist_id)
; 	
; 	if (idx > 0)
;		enc_flex->list[idx].reason_for_visit		= e.reason_for_visit
;		
;		enc_flex->list[idx].patient_name			= p.name_full_formatted
;		enc_flex->list[idx].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
;		enc_flex->list[idx].fin						= ea.alias
;		enc_flex->list[idx].fac						= cvo.alias
;		enc_flex->list[idx].pcp						= per.name_full_formatted
;		enc_flex->list[idx].pcp_id					= pera.alias
;		enc_flex->list[idx].practice_site			= org.org_name
;	endif
;	
;with nocounter, expand = 1, time = 120
;
;call echorecord(enc_flex)
;
;
;/**************************************************************/
;; select data
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set modify filestream
;endif
;
;;017
;select if (validate(request->batch_selection) = 1 or $output_file = 1)
;	with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, compress, maxcol = 240
;else
;	with nocounter, nullreport, separator = " ", format, compress, maxcol = 240
;endif
; 
;into value(output_var)	
;	pcp_id						= trim(enc_flex->list[d1.seq].pcp_id, 3)
;	, pcp_name					= trim(enc_flex->list[d1.seq].pcp, 3)
;	, practice_site_display		= trim(enc_flex->list[d1.seq].practice_site, 3)
;	
;	, fac						= trim(enc_flex->list[d1.seq].fac, 3)
;	, fin						= trim(enc_flex->list[d1.seq].fin, 3)
;	, patient_name				= trim(enc_flex->list[d1.seq].patient_name, 3)
;	, dob						= format(enc_flex->list[d1.seq].dob, "mm/dd/yyyy;;d")
;	
;	, admit_dt_tm				= cnvtupper(build2(
;									format(enc_flex->list[d1.seq].reg_dt_tm, "mm/dd/yyyy;;d"), " ",
;									format(enc_flex->list[d1.seq].reg_dt_tm, "hh:mm;;s")))
;									
;	, reason_for_visit			= trim(enc_flex->list[d1.seq].reason_for_visit, 3)
;	, start_date				= enc_flex->start_date
;      
;from
;	(dummyt d1 with seq = value(enc_flex->cnt))
; 
;plan d1
;where
;	enc_flex->list[d1.seq].pcp_id not in ("10075", "10074", "10073", "UNPHY")
;	and isnumeric(enc_flex->list[d1.seq].pcp_id) = 1
; 
;order by
;	cnvtint(enc_flex->list[d1.seq].pcp_id)
;	, enc_flex->list[d1.seq].fac
;	, enc_flex->list[d1.seq].fin
;
;; format report output
;head report
;	fcnt = 0
;	pagenum = 0
; 
;head page
;	if (curpage = 1)
;		row + 1
;	endif
; 
;	pagenum = pagenum + 1
; 
;	col 0	"Date:"
;	col 6	dt = format(sysdate, "mm/dd/yyyy;;d"), dt
;	col 210	"Page:"
;	col 216	pagenum "####"
;	row + 1
; 
;	col 0	"Time:"
;	col 6	tm = cnvtupper(format(sysdate, "hh:mm:ss;;s")), tm
;	row + 1
; 
;	col 0	"Report:"
;	col 8	prog = curprog, prog
;	row + 2
; 
; 	if ($weekend_only)
; 		title = build2("ED Primary Care Physician Listing for Weekend Starting", " ", start_date)
; 	else
; 		title = build2("ED Primary Care Physician Listing for", " ", start_date)
; 	endif
; 	
;;	 	subtitle = facility_desc 
;	call center(title, 1, 240)
;;		row + 1
;;		call center(subtitle, 1, 233)
;	row + 2
; 
;head pcp_id
; 
;	col 0	"PHYSICIAN ID:"
;	col 15	pcp_id
;	col 25	pcpn = substring(1, 30, pcp_name), pcpn
;	row + 2
;	
;	col 0	"GROUP:"
;	col 7	practice_site_display
;	row + 2
; 
;	col 0	"Acct Nbr"
;	col 15	"Pt Name"
;	col 46	"Birthdate"
;	col 90	"Adm Dt/Tm"
;	col 115	"Adm DX"
;	row + 1
; 
;	col 0	s = fillstring(239, "-"), s
;	row + 2
; 
;detail	
;	if (row > 45)
;		break
;		
;		;001
;		col 0	"PHYSICIAN ID:"
;		col 15	pcp_id
;		col 25	pcpn = substring(1, 30, pcp_name), pcpn
;		row + 2
;		
;		col 0	"GROUP:"
;		col 7	practice_site_display
;		row + 2
;	 
;		col 0	"Acct Nbr"
;		col 15	"Pt Name"
;		col 46	"Birthdate"
;		col 90	"Adm Dt/Tm"
;		col 115	"Adm DX"
;		row + 1
;	 
;		col 0	s = fillstring(239, "-"), s
;		row + 2
;	endif
; 
;	col 0	fac
;	col 1	f = substring(1, 15, fin), f
;	col 15	pn = substring(1, 30, patient_name), pn
;	col 46	dob	
;	col 90	admit_dt_tm
;	col 115	rv = substring(1, 115, reason_for_visit), rv
;	row + 1
; 
;foot pcp_id
;	break
;
;with nocounter
;
; 
;; copy file to AStream
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
;	set len = size(trim(cmd))
; 
;	call dcl(cmd, len, stat)
;	call echo(build2(cmd, " : ", stat))
;endif


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript
 
END GO

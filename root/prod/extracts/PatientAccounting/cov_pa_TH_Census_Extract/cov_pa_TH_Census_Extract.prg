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
	, "Start Date" = "CURDATE"
	, "Output To File" = 0                   ;* Output to file (used for testing by IT) 

with OUTDEV, start_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare start_datetime			= dq8 with noconstant(cnvtlookbehind("0, d", cnvtdatetime(curdate, 000000)))

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
	
	1 cnt							= i4
	1 list[*]
		2 encntr_loc_hist_id		= f8
		2 encntr_id					= f8
		2 loc_facility_cd			= f8
		2 loc_nurse_unit_cd			= f8
		2 loc_room_cd				= f8
		2 loc_bed_cd				= f8
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
		2 room						= c4
		2 bed						= c3
		
		2 person_id					= f8
		2 patient_name				= c100
		2 fin						= c20
		2 mrn						= c20
		2 pat_email					= c100
		2 alt_phone					= c20
		
		2 admit_phy					= c100
		2 admit_phy_num				= c20
		2 admit_phy_qualifies		= i2
		2 admit_dt_tm				= dq8
		
		2 attend_phy				= c100
		2 attend_phy_num			= c20
		2 attend_phy_qualifies		= i2
		
		2 c_cnt							= i4
		2 consults [*]
			3 consult_phy				= c100
			3 consult_phy_num			= c20
			3 consult_phy_qualifies		= i2
)
 
 
/**************************************************************/
; save prompt data
set enc_loc_data->start_datetime	= format(start_datetime, "mm/dd/yyyy;;d")


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
	
where
	elh.encntr_type_cd in (
		inpatient_var,
		observation_var,
		op_bed_var
	)
	and nullval(elh.loc_bed_cd, 0.0) > 0.0
	and datetimetrunc(cnvtdatetime(start_datetime), "dd") between datetimetrunc(elh.beg_effective_dt_tm, "dd") and 
																  datetimetrunc(elh.end_effective_dt_tm, "dd")
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
	enc_loc_data->list[cnt].loc_facility_cd			= elh.loc_facility_cd
	enc_loc_data->list[cnt].loc_nurse_unit_cd		= elh.loc_nurse_unit_cd
	enc_loc_data->list[cnt].loc_room_cd				= elh.loc_room_cd
	enc_loc_data->list[cnt].loc_bed_cd				= elh.loc_bed_cd

with nocounter, time = 180

;call echorecord(enc_loc_data)
 
 
/**************************************************************/
; select encounter data
select into "NL:"
from
	ENCOUNTER e

	, (inner join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)

	, (inner join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var)
		
	, (inner join PERSON p on p.person_id = e.person_id)
	
	, (inner join CODE_VALUE_OUTBOUND cvoe on cvoe.code_value = e.encntr_type_cd
		and cvoe.contributor_source_cd = covenant_var)
	
	, (inner join CODE_VALUE_OUTBOUND cvof on cvof.code_value = enc_loc_data->list[d1.seq].loc_facility_cd
		and cvof.contributor_source_cd = covenant_var)
	
	, (inner join CODE_VALUE_OUTBOUND cvon on cvon.code_value = enc_loc_data->list[d1.seq].loc_nurse_unit_cd
		and cvon.contributor_source_cd = covenant_var)
	
	, (inner join CODE_VALUE_OUTBOUND cvor on cvor.code_value = enc_loc_data->list[d1.seq].loc_room_cd
		and cvor.contributor_source_cd = covenant_var)
	
	, (inner join CODE_VALUE_OUTBOUND cvob on cvob.code_value = enc_loc_data->list[d1.seq].loc_bed_cd
		and cvob.contributor_source_cd = covenant_var)
	
	; address
	, (left join ADDRESS a on a.parent_entity_id = p.person_id
		and a.parent_entity_name = "PERSON"
		and a.address_type_cd = email_var
		and a.street_addr in ("*@*.*")
		and a.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and a.active_ind = 1)
	
	; phone
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = alternate_var
		and ph.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ph.active_ind = 1)
		
	; admitting physician
	, (left join ENCNTR_PRSNL_RELTN epr_adm on epr_adm.encntr_id = e.encntr_id		
		and epr_adm.encntr_prsnl_r_cd = admit_phy_var
		and datetimetrunc(cnvtdatetime(start_datetime), "dd") between datetimetrunc(epr_adm.beg_effective_dt_tm, "dd") and 
																	  datetimetrunc(epr_adm.end_effective_dt_tm, "dd"))	
												 	
	, (left join PRSNL per_adm on per_adm.person_id = epr_adm.prsnl_person_id)
	
	, (left join PRSNL_ALIAS pera_adm on pera_adm.person_id = per_adm.person_id
		and pera_adm.prsnl_alias_type_cd = org_phy_var
		and pera_adm.alias_pool_cd = phy_num_var)
		
	; attending physician
	, (left join ENCNTR_PRSNL_RELTN epr_att on epr_att.encntr_id = e.encntr_id
		and epr_att.encntr_prsnl_r_cd = attend_phy_var
		and datetimetrunc(cnvtdatetime(start_datetime), "dd") between datetimetrunc(epr_att.beg_effective_dt_tm, "dd") and 
																	  datetimetrunc(epr_att.end_effective_dt_tm, "dd"))
												 
	, (left join PRSNL per_att on per_att.person_id = epr_att.prsnl_person_id)
	
	, (left join PRSNL_ALIAS pera_att on pera_att.person_id = per_att.person_id
		and pera_att.prsnl_alias_type_cd = org_phy_var
		and pera_att.alias_pool_cd = phy_num_var)
		
	; consulting physician
	, (left join ENCNTR_PRSNL_RELTN epr_con on epr_con.encntr_id = e.encntr_id
		and epr_con.encntr_prsnl_r_cd = consult_phy_var
		and datetimetrunc(cnvtdatetime(start_datetime), "dd") between datetimetrunc(epr_con.beg_effective_dt_tm, "dd") and 
																	  datetimetrunc(epr_con.end_effective_dt_tm, "dd"))
												 
	, (left join PRSNL per_con on per_con.person_id = epr_con.prsnl_person_id)
	
	, (left join PRSNL_ALIAS pera_con on pera_con.person_id = per_con.person_id
		and pera_con.prsnl_alias_type_cd = org_phy_var
		and pera_con.alias_pool_cd = phy_num_var)
	
	, (dummyt d1 with seq = value(enc_loc_data->cnt))
	
plan d1

join e	
where
	e.encntr_id = enc_loc_data->list[d1.seq].encntr_id
	and e.active_ind = 1

join eaf
join eam
join p
join cvoe
join cvof
join cvon
join cvor
join cvob
join a
join ph
join epr_adm
join per_adm
join pera_adm
join epr_att
join per_att
join pera_att
join epr_con
join per_con
join pera_con

order by
	e.encntr_id
	, epr_con.prsnl_person_id
	

; populate record structure	
head report
	cnt = 0
	
head e.encntr_id
	c_cnt = 0
	
	cnt = cnt + 1
 
	call alterlist(enc_data->list, cnt)
 
	enc_data->cnt								= cnt
	enc_data->list[cnt].encntr_id				= e.encntr_id
	enc_data->list[cnt].encntr_loc_hist_id		= enc_loc_data->list[d1.seq].encntr_loc_hist_id
	enc_data->list[cnt].pat_type				= build(cvoe.alias, cvof.alias)
	enc_data->list[cnt].fac						= cvof.alias
	enc_data->list[cnt].nurse_unit				= cvon.alias
	enc_data->list[cnt].room					= cvor.alias
	enc_data->list[cnt].bed						= cvob.alias
	
	enc_data->list[cnt].person_id				= e.person_id
	enc_data->list[cnt].patient_name			= p.name_full_formatted
	enc_data->list[cnt].fin						= build(cvof.alias, cnvtalias(eaf.alias, "##########"))
	enc_data->list[cnt].mrn						= build(cvof.alias, cnvtalias(eam.alias, "##########"))
	enc_data->list[cnt].pat_email				= a.street_addr
	enc_data->list[cnt].alt_phone				= cnvtphone(ph.phone_num, ph.phone_format_cd)
	
	enc_data->list[cnt].admit_phy				= per_adm.name_full_formatted
	enc_data->list[cnt].admit_phy_num			= pera_adm.alias
	
	enc_data->list[cnt].admit_phy_qualifies		= evaluate(locateval(num, 1, prsnl_group_data->cnt, 
													epr_adm.prsnl_person_id, prsnl_group_data->list[num].prsnl_id), 0, 0, 1)
	
	enc_data->list[cnt].admit_dt_tm				= evaluate(substring(1, 1, cvoe.alias), "I", 
													e.inpatient_admit_dt_tm, e.beg_effective_dt_tm)
													
	enc_data->list[cnt].attend_phy				= per_att.name_full_formatted
	enc_data->list[cnt].attend_phy_num			= pera_att.alias
	
	enc_data->list[cnt].attend_phy_qualifies	= evaluate(locateval(num, 1, prsnl_group_data->cnt, 
													epr_att.prsnl_person_id, prsnl_group_data->list[num].prsnl_id), 0, 0, 1)
													
head epr_con.prsnl_person_id
	if (epr_con.prsnl_person_id > 0.0)
		c_cnt = c_cnt + 1
		
		call alterlist(enc_data->list[cnt].consults, c_cnt)
		
		enc_data->list[cnt].c_cnt									= c_cnt
		enc_data->list[cnt].consults[c_cnt].consult_phy				= per_con.name_full_formatted
		enc_data->list[cnt].consults[c_cnt].consult_phy_num			= pera_con.alias
		enc_data->list[cnt].consults[c_cnt].consult_phy_qualifies	= evaluate(locateval(num, 1, prsnl_group_data->cnt, 
																		epr_con.prsnl_person_id, prsnl_group_data->list[num].prsnl_id), 0, 0, 1)
	endif
	
with nocounter, time = 120

call echorecord(enc_data)


/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, outerjoin = d1, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 796
else
	with nocounter, outerjoin = d1, nullreport, separator = " ", format, landscape, compress, maxcol = 796
endif
 
distinct into value(output_var)
	patient_name			= substring(1, 30, enc_data->list[d1.seq].patient_name)
	, fin					= substring(1, 15, enc_data->list[d1.seq].fin)
	, fac					= substring(1, 2, enc_data->list[d1.seq].fac)
	, mrn					= substring(1, 15, enc_data->list[d1.seq].mrn)
	, nurse_unit			= substring(1, 4, enc_data->list[d1.seq].nurse_unit)
	, bed					= substring(1, 3, enc_data->list[d1.seq].bed)
	, pat_type				= substring(1, 4, enc_data->list[d1.seq].pat_type)
	, attend_phy_num		= substring(1, 19, enc_data->list[d1.seq].attend_phy_num)
	, attend_phy			= substring(1, 30, enc_data->list[d1.seq].attend_phy)
	, admit_phy_num			= substring(1, 10, enc_data->list[d1.seq].admit_phy_num)
	, admit_phy				= substring(1, 26, enc_data->list[d1.seq].admit_phy)
	
	, admit_dt_tm			= substring(1, 19, build2(
								format(enc_data->list[d1.seq].admit_dt_tm, "mm/dd/yyyy;;d"), "@",
								cnvtupper(format(enc_data->list[d1.seq].admit_dt_tm, "hh:mm;;s"))
								))
	
	, pat_email				= substring(1, 60, enc_data->list[d1.seq].pat_email)
	, alt_phone				= substring(1, 13, enc_data->list[d1.seq].alt_phone)
      
from
	(dummyt d1 with seq = value(enc_data->cnt))
 
plan d1
where
	(
		enc_data->list[d1.seq].admit_phy_qualifies = 1 or
		enc_data->list[d1.seq].attend_phy_qualifies = 1
	)

order by
	fac
	, patient_name
	, fin
	, enc_data->list[d1.seq].admit_dt_tm
	, attend_phy_num
	, admit_phy_num
	

; format report output
head report
	pagenum = 0
 
head fac
	pagenum = pagenum + 1
 
	col 0	"Date:"
	col 6	dt = format(sysdate, "mm/dd/yyyy;;d"), dt	
	col 180	"Page:"
	col 186	pagenum ";l;"
	row + 1
 
	col 0	"Time:"
	col 6	tm = cnvtupper(format(sysdate, "hh:mm;;s")), tm
	row + 1
 
	col 0	"Report:"
	col 8	prog = curprog, prog
	row + 3

	col 0	"FACILITY:"
	col 10	fac
	row + 2

	col 0	"PAT_NAME"
	col 30	"PAT_ACCT_NBR"
	col 45	"FAC"
	col 60	"MED_REC1"
	col 75	"MED_REC2"
	col 90	"MED_REC3"
	col 105	"MED_REC4"
	col 120	"MED_REC5"
	col 135	"MED_REC6"
	col 150	"MED_REC7"
	col 165	"STATION_CD"
	col 177	"BED_NBR"
	col 186	"PAT_TYPE"
	col 196	"MED_LINK@ATTEND_PHY"
	col 217	"MED_LINK@ATTEND_PHY_NM"
	col 249	"ADM_PHY_CD"
	col 261	"ADM_PHY_NM"
	col 298	"ADM_DT_TM"
	col 309	"CNS_CD1"
	col 318	"CONSULT1"
	col 350	"CNS_CD2"
	col 359	"CONSULT2"
	col 391	"CNS_CD3"
	col 400	"CONSULT3"
	col 432	"CNS_CD4"
	col 441	"CONSULT4"
	col 473	"CNS_CD5"
	col 482	"CONSULT5"
	col 514	"CNS_CD6"
	col 523	"CONSULT6"
	col 555	"CNS_CD7"
	col 564	"CONSULT7"
	col 596	"CNS_CD8"
	col 605	"CONSULT8"
	col 637	"CNS_CD9"
	col 646	"CONSULT9"
	col 678	"CNS_CD10"
	col 688	"CONSULT10"
	col 720	"PAT_EMAIL"
	col 782	"ALT_PHONE"		
	row + 1

head patient_name
	null
	
head fin
	null
	
detail
	col 0	patient_name
	col 30	fin
	col 45	fac
	col 60	mrn
	col 165	nurse_unit
	col 177	bed
	col 186	pat_type
	col 196	attend_phy_num ";r;"
	col 217	attend_phy
	col 249	admit_phy_num ";r;"
	col 261	admit_phy
	col 288	admit_dt_tm
	col 720	pat_email
	col 782	alt_phone
	
	j = 0
	
	for (i = 1 to enc_data->list[d1.seq].c_cnt)
		if (enc_data->list[d1.seq].consults[i].consult_phy_qualifies = 1)
			j = j + 1
			
			if (j <= 10)
				c1 = 309 + ((j - 1) * 41)
				c2 = 318 + ((j - 1) * 41)
				
				col c1 c_phynum = substring(1, 7, enc_data->list[d1.seq].consults[i].consult_phy_num), c_phynum ";r;"
				col c2 c_phy = substring(1, 30, enc_data->list[d1.seq].consults[i].consult_phy), c_phy
			endif
		endif
	endfor
	
	row + 1
 
foot fac
	break

with nocounter

 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript
 
END GO


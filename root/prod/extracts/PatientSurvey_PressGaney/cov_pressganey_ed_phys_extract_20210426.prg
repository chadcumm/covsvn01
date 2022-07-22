/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		10/03/2018
	Solution:			Press Ganey Patient Surveys
	Source file name:	cov_press_ganey_ed_phys_extract.prg
	Object name:		cov_press_ganey_ed_phys_extract
	Request #:			3490
 
	Program purpose:	Pull All ED Provider data for Press Ganey extract in Star
 
	Executing from:		CCL
 
 	Special Notes:		Using code from cov_peri_AnesOpenTempo.prg by Todd
 	                    Blanchard at Covenant
 
 						Output files:
 							cov_press_ganey_ed_phys_extract.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
    1/28/2019   Dawn Greer, DBA         Removed the criteria for pulling just
                                        ED Mid Levels.  Pull all providers
    7/1/2019    Dawn Greer, DBA         CR 5329 - Removed criteria to limit to just
                                        emergency encounter types
                                        (e.encntr_type_cd = 309310.00 ;Emergency).
                                        Changed criteria to look at
                                        encounter.disch_dt_tm instead of
                                        encounter.reg_dt_tm.  Changed the JOINS
                                        from the criteria to the JOIN syntax
                                        Renamed program
                                        from cov_pressganeymidlevel_TEST.prg
                                        to cov_pressganey_ed_phys_TEST.prg
******************************************************************************/
DROP PROGRAM cov_pressganey_ed_phys_extract:DBA GO
CREATE PROGRAM cov_pressganey_ed_phys_extract:DBA
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"Output To File" = 0
 
WITH OUTDEV, output_file
 
/*****************************************************************************
  Declared Variables
******************************************************************************/
DECLARE crlf				= vc WITH constant(build(char(13),char(10)))
DECLARE cov_comma			= vc WITH constant(char(44))
DECLARE cov_quote      		= vc WITH constant(char(34))
 
DECLARE file_var			= vc WITH noconstant("cov_pressganey_ed_phys_extract_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(curdate),FORMAT(MONTH(curdate),"##;P0"),FORMAT(DAY(curdate),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("cer_temp:")
declare temppath2_var		= vc with noconstant("$cer_temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc with noconstant("")
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
/*****************************************************************************
  Record Structure
******************************************************************************/
 
RECORD press_ganey (
	1 output_cnt 				= i4
	1 list[*]
		2 finnbr				= vc		;Fin Nbr/Encounter Number
		2 fac_code				= vc 		;Covenant specific code for Facilities
		2 attend_phys_npi	 	= vc		;Attending Physician NPI
		2 attend_phys_name  	= vc		;Attending Physician Name
		2 provider_type     	= vc        ;Provider Type
		2 provider_specialty 	= vc		;Provider Specialty
		2 site_address_1   		= vc		;Site Address Line 1
		2 site_address_2	   	= vc		;Site Address Line 2
		2 site_city				= vc		;Site City
		2 site_state			= vc		;Site State
		2 site_zip				= vc		;Site Zip
)
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/PressGaney/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".csv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
/********************************************************************************
	Get Mid-Level/MD Physician Data on ED encounters
*********************************************************************************/
SELECT DISTINCT
	Attending_Physician_NPI = PAR.ALIAS
	, Attending_Physician_Name = P.NAME_FULL_FORMATTED
	, Provider_Type = UAR_GET_CODE_DISPLAY(P.POSITION_CD)
	, Provider_Specialty = UAR_GET_CODE_DISPLAY(PS.SPECIALTY_CD)
	, Site_Address_1 = A.STREET_ADDR
	, Site_Address_2 = A.STREET_ADDR2
	, Site_City = A.CITY
	, Site_State = A.STATE
	, Site_Zip = A.ZIPCODE
	, Finnbr = EA.ALIAS
	, Fac_Code = oa.alias
FROM
	ENCOUNTER E
	, (INNER JOIN CLINICAL_EVENT CE ON (ce.encntr_id = e.encntr_id
			AND ce.event_cd IN (2562149973.00 /*ED Provider Patient Seen Date/Time*/,
				2563539859.00 /*ED Provider Patient Seen Date/Time -Text*/,
				2562151631.00 /*ED Provider Patient Seen Form Complete*/,
				2562150159.00 /*ED Provider Pt Seen Date/Time - Form*/,
				2565155701.00 /*ED Provider Pt Seen Date/Time Form*/)
			AND ce.performed_dt_tm IN (SELECT MAX(c.performed_dt_tm) FROM clinical_event c
		WHERE c.event_cd IN (2562149973.00 /*ED Provider Patient Seen Date/Time*/,
			2563539859.00 /*ED Provider Patient Seen Date/Time -Text*/,
			2562151631.00 /*ED Provider Patient Seen Form Complete*/,
			2562150159.00 /*ED Provider Pt Seen Date/Time - Form*/,
			2565155701.00 /*ED Provider Pt Seen Date/Time Form*/)
		AND c.encntr_id = ce.encntr_id)
		))
	, (LEFT JOIN PRSNL P ON (ce.performed_prsnl_id = p.person_id))
	, (INNER JOIN PERSON PE ON (e.person_id = pe.person_id))
	, (INNER JOIN ENCNTR_ALIAS EA ON (e.encntr_id = ea.encntr_id
		AND ea.alias_pool_cd = 2554138251.00 ;STAR FIN
		))
	, (INNER JOIN PERSON_ALIAS PA ON (pa.person_id = pe.person_id
		AND pa.alias_pool_cd =  2554138243.00  ;CMRN
		))
	, (INNER JOIN PRSNL_ALIAS PAR ON (par.person_id = p.person_id
		AND par.alias_pool_cd = 26026547.00  ;NPI
		))
	, (LEFT JOIN ORGANIZATION O ON (o.organization_id = e.organization_id))
	, (LEFT JOIN ADDRESS A ON (a.parent_entity_id = o.organization_id
		AND a.address_type_cd = 754.00 ;Business
		))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN PS ON (ps.prsnl_id = p.person_id
		AND ps.active_ind = 1
		AND ps.primary_ind = 1
		))
	, (LEFT JOIN ORGANIZATION_ALIAS oa ON (o.organization_id = oa.organization_id
		AND oa.alias_pool_cd = 21808469.00 ;Client Code for Facility Code (F, B, S, etc.)
 		))
WHERE e.encntr_status_cd = 856.00   ;Discharged
AND e.disch_dt_tm >= cnvtlookbehind("14, d", cnvtdatetime(curdate, 000000))
AND e.disch_dt_tm <= cnvtlookbehind("8, d", cnvtdatetime(curdate, 235959))
ORDER BY e.disch_dt_tm
 
/****************************************************************************
	Populate Record structure
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(press_ganey->list, 100)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1 AND cnt > 100)
		CALL alterlist(press_ganey->list, cnt + 9)
	ENDIF
	press_ganey->list[cnt].finnbr = Finnbr
	press_ganey->list[cnt].fac_code = Fac_Code
	press_ganey->list[cnt].attend_phys_npi = Attending_Physician_NPI
	press_ganey->list[cnt].attend_phys_name = Attending_Physician_Name
	press_ganey->list[cnt].provider_type = Provider_Type
	press_ganey->list[cnt].provider_specialty = Provider_Specialty
	press_ganey->list[cnt].site_address_1 = Site_Address_1
	press_ganey->list[cnt].site_address_2 = Site_Address_2
	press_ganey->list[cnt].site_city = Site_City
	press_ganey->list[cnt].site_state = Site_State
	press_ganey->list[cnt].site_zip = Site_zip
 
FOOT REPORT
 	press_ganey->output_cnt = cnt
 	CALL alterlist(press_ganey->list, cnt)
 
WITH nocounter
 
/****************************************************************************
	Build Output
*****************************************************************************/
IF (press_ganey->output_cnt > 0)
 
	SELECT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = press_ganey->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build(cov_quote, "Finnbr", cov_quote, cov_comma,
						cov_quote, "Fac_Code", cov_quote, cov_comma,
						cov_quote, "Attending_Physician_NPI", cov_quote, cov_comma,
						cov_quote, "Attending_Physician_Name", cov_quote, cov_comma,
						cov_quote, "Provider_Type", cov_quote, cov_comma,
						cov_quote, "Provider_Specialty", cov_quote, cov_comma,
						cov_quote, "Site_Address_1", cov_quote, cov_comma,
						cov_quote, "Site_Address_2", cov_quote, cov_comma,
						cov_quote, "Site_City", cov_quote, cov_comma,
						cov_quote, "Site_State",cov_quote, cov_comma,
						cov_quote, "Site_Zip", cov_quote)
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						cov_quote, press_ganey->list[dt.seq].finnbr, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].fac_code, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].attend_phys_npi, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].attend_phys_name, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].provider_type, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].provider_specialty, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].site_address_1, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].site_address_2, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].site_city, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].site_state, cov_quote, cov_comma,
						cov_quote, press_ganey->list[dt.seq].site_zip, cov_quote)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		row + 1
 
	WITH nocounter, maxcol = 32000, format =stream, formfeed = none
ENDIF
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("cp ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
CALL echorecord(press_ganey)
 
END
GO
/***********************Change Log*************************

VERSION 	 DATE       ENGINEER            COMMENT

-------	 	-------    	-----------         ------------------------

1.0			6/20/2017	Brian Heits			Initial Release

2.0			3/8/2018	Ryan Gotsche		CR-XXXX - Modifications for MPage to pass IDs for AMB Patients

3.0			6/7/2018	Ryan Gotsche		CR-2253 - Display facility specific STAR MRNs for acute patients

4.0			6/18/2018	Ryan Gotsche		CR-2253 - New hidden fields (Physician indicator, Position, Encounter Type)

**************************************************************/

 

/***********************PROGRAM NOTES*************************

Description - This MPage is used to pass values to custom webpage.

;chs_tn.custpatpop

Tables Read: PERSON, PERSON_ALIAS, ENCOUNTER, ENCNTR_ALIAS

	ORGANIZATION, ORGANIZATION_ALIAS

 

Tables Updated: None

 

Scripts Executed: None

**************************************************************/


drop program cov_mp_get_patpop:dba go

create program cov_mp_get_patpop:dba

;cov_mp_get_patpop ^MINE^,17900388.0,113483135.0,16908168.0,^^,^^,441.0,681274.0

 

prompt 

	"Output to File/Printer/MINE" = "MINE"

	, "Patient ID:" = 0.00

	, "Encounter ID:" = 0.00

	, "Personnel ID:" = 0.00

	, "HTML File Name:" = ""

	, "HTML Backend Location:" = ""

	, "Provider Position Code:" = 0.00

	, "Patient Provider Relationship Code:" = 0.00

	, "Debug Indicator:" = 0 



with OUTDEV, PATIENTID, ENCOUNTERID, PERSONNELID, HTMLFILENAME, BACKENDLOC, 

	POSITIONCODE, PPRCODE, DEBUGIND

/**************************************************************

; DVDev DECLARED SUBROUTINES

**************************************************************/

declare GetPatientData( dummy=i4 ) = null with protect

declare GetHTML( dummy=i4 ) = gvc with protect

 

/**************************************************************

; DVDev DECLARED VARIABLES

**************************************************************/

free record RECORD_DATA

record RECORD_DATA (

	1 person_id = f8

	1 encntr_id = f8

	1 user_id = f8

	1 launch_url = vc

	1 ssn = vc

	1 next_gen_id = vc

	1 organization_id = f8

	1 facility = vc

	1 mrn = vc

	1 fin = vc

	1 cmrn = vc

	1 user

		2 user_name = vc

		2 name_first = vc

		2 name_last = vc

		2 physician_ind = i2 ;4.0

		2 user_position = vc ;v4.0

	1 encntr_type = vc ;v4.0

 

%i cclsource:status_block.inc

)

 

declare SSN_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"SSN"))
declare CMRN_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"CMRN"))
declare STAR_MRN_STR = vc with protect, constant("STARMRN")
declare STAR_FIN_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"STARFIN"))
declare ENCNTR_ORG_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"ENCOUNTERORG"))
declare STAR_FACILITY_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"STARFACILITYIDENTIFIER"))
declare NEXT_GEN_CD = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"NEXTGENPERSONID"))

declare CERNER_FIN_CD = F8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"CERNERFIN")) ;v2.0

declare 4_MRN = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2623")),protect ;v3.0

declare 4_CMRN = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2621")),protect ;v3.0

declare 4_SSN = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2626")),protect ;v3.0

declare 4_HISTMRN = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!15182")),protect ;v3.0

declare 263_MRN_CERN = f8 with protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",263,"CERNERMRN"));v3.0

/**************************************************************

; DVDev Start Coding

**************************************************************/

set record_data->status_data.status = "F"

set record_data->person_id = CNVTREAL($PATIENTID)

set record_data->encntr_id = CNVTREAL($ENCOUNTERID)

set record_data->user_id = CNVTREAL($PERSONNELID)

set record_data->launch_url = concat("http://covhppmodules.covhlth.net/ColdFusionApplications/"
				,"Cerner_PopulationGroupAlertPopulationGroupNoticeAlert.cfm")

if (record_data->person_id = 0.0 or record_data->encntr_id = 0.0 or record_data->user_id = 0.0)

	set record_data->status_data.subeventstatus[1].operationname = "launch"

	set record_data->status_data.subeventstatus[1].operationstatus = "F"

	set record_data->status_data.subeventstatus[1].targetobjectname = "1CHS_TN_FOREIGN_SYSTEM_LAUNCH"

	set record_data->status_data.subeventstatus[1].targetobjectvalue = "No patient id, encounter id, or launch URL found"

	go to exit_script

endif

call GetPatientData(0)

 

/**************************************************************

; DVDev DEFINED SUBROUTINES

**************************************************************/

subroutine GetPatientData( dummy )

	; getting user information
	SELECT into "nl:"
	FROM
		PRSNL   P
	plan p
		where p.person_id = record_data->user_id
		and p.active_ind = 1
	head report
		record_data->user.user_name = p.username
		record_data->user.name_first = p.name_first_key
		record_data->user.name_last = p.name_last_key
		record_data->physician_ind = p.physician_ind ;4.0
		record_data->user_position = build2(uar_get_code_display(p.position_cd));v4.0
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
	if (not CURQUAL)
		set record_data->status_data.subeventstatus[1].operationname = "select"
		set record_data->status_data.subeventstatus[1].operationstatus = "F"
		set record_data->status_data.subeventstatus[1].targetobjectname = ""
		set record_data->status_data.subeventstatus[1].targetobjectvalue = "No user information found"
		go to exit_script
	endif
 

	; getting patient information

	select into "nl:"
	from
		person p
		, encounter e
		, person_alias pa
		, org_alias_pool_reltn oa
	plan e

		where e.encntr_id = record_data->encntr_id

		and e.person_id = record_data->person_id

		and e.active_ind = 1

	join p

		where p.person_id = e.person_id

		and p.active_ind = 1

	join pa

		where pa.person_id = p.person_id

		and pa.active_ind = 1


	join oa ;v3.0 - Include the join to return the facility specific MRN.

		where oa.organization_id = e.organization_id

		and oa.alias_entity_alias_type_cd in (4_MRN,4_CMRN,4_SSN,4_HISTMRN) ;v3.0

		and oa.active_ind = 1

		and oa.end_effective_dt_tm > sysdate

		and (oa.alias_pool_cd = pa.alias_pool_cd) ;v3.0

	head report

		record_data->organization_id = e.organization_id

		record_data->encntr_type = build2(uar_get_code_display(e.encntr_type_cd)) ;v4.0

	detail

	
		if (pa.alias_pool_cd = CMRN_CD)

			record_data->cmrn = pa.alias

		endif

	with nocounter

	if (not CURQUAL)

		set record_data->status_data.subeventstatus[1].operationname = "select"

		set record_data->status_data.subeventstatus[1].operationstatus = "F"

		set record_data->status_data.subeventstatus[1].targetobjectname = ""

		set record_data->status_data.subeventstatus[1].targetobjectvalue = "No SSN, CMRN, MRN, or FIN found"

		go to exit_script

	endif

 

	; getting organization data

	SELECT into "nl:"

		org_type = EVALUATE2(

			if (o.alias_pool_cd = STAR_FACILITY_CD)

				1

			else

				0

			endif

		)

	FROM

		organization_alias   o

		, organization org

	plan o

		where o.organization_id = record_data->organization_id

		and o.alias_pool_cd in (ENCNTR_ORG_CD)

	join org

		where org.organization_id = o.organization_id

		and org.active_ind = 1

	order by

		org_type

	detail

		record_data->facility = o.alias

	with nocounter

	if (not CURQUAL)

		set record_data->status_data.subeventstatus[1].operationname = "select"

		set record_data->status_data.subeventstatus[1].operationstatus = "F"

		set record_data->status_data.subeventstatus[1].targetobjectname = ""

		set record_data->status_data.subeventstatus[1].targetobjectvalue = "No organization alias found"

		go to exit_script

	endif

 

	set record_data->status_data.status = "S"

end ;subroutine GetPatientData( dummy )

 

subroutine GetHTML( dummy )

	declare temp_html = gvc with protect, noconstant("")

	if (record_data->status_data.status = "F")

		set temp_html = BUILD2(

			"<html><body>",

			"<div style='font-weight:bold;color:#F00;'>MPage Error:",

				record_data->status_data.subeventstatus[1].targetobjectvalue,

			"</div>",

			"</body></html>"

		)

	else

		set temp_html = BUILD2(

		^<!DOCTYPE html public "-//W3C//DTD HTML 4.0//en">^,CHAR(10),CHAR(13),

		^<HTML>^,CHAR(10),CHAR(13),

		^<!-- ************************************************** -->^,CHAR(10),CHAR(13),

		^<!-- IFRAMES -->^,CHAR(10),CHAR(13),

		^<!-- ************************************************** -->^,CHAR(10),CHAR(13),

		^<IFRAME^,CHAR(10),CHAR(13),

		  ^NAME="iFrameCovForeignSystemLaunch" ^,CHAR(10),CHAR(13),

		  ^ID="iFrameCovForeignSystemLaunch" ^,CHAR(10),CHAR(13),

		  ^STYLE="position:fixed;background-color:white;top:0px;left:0px;width:100%;height:100%;" ^,CHAR(10),CHAR(13),

		  ^SCROLLING="AUTO" ^,CHAR(10),CHAR(13),

		  ^FRAMEBORDER="0" ^,CHAR(10),CHAR(13),

		  ^MARGINWIDTH="0" ^,CHAR(10),CHAR(13),

		  ^MARGINHEIGHT="0" ^,CHAR(10),CHAR(13),

		  ^SRC=""^,CHAR(10),CHAR(13),

		^></IFRAME>^,CHAR(10),CHAR(13),

		^<!-- **************************************** -->^,CHAR(10),CHAR(13),

		^<!-- SUBMIT FORM-->^,CHAR(10),CHAR(13),

		^<!-- **************************************** -->^,CHAR(10),CHAR(13),

		^<FORM^,CHAR(10),CHAR(13),

		  ^NAME="frmMain"^,CHAR(10),CHAR(13),

		  ^ID="frmMain"^,CHAR(10),CHAR(13),

		  ^ACTION="^,record_data->launch_url,^"^,CHAR(10),CHAR(13),

		  ^METHOD="POST"^,CHAR(10),CHAR(13),

		  ^TARGET="iFrameCovForeignSystemLaunch"^,CHAR(10),CHAR(13),

		^>^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strStaffUserName" VALUE="^,record_data->user.user_name,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strStaffNameFirst" VALUE="^,record_data->user.name_first,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strStaffNameLast" VALUE="^,record_data->user.name_last,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientSSN" VALUE="^,record_data->ssn,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientStarFacilty" VALUE="^,record_data->facility,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientStarMRN" VALUE="^,record_data->mrn,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientFin" VALUE="^,record_data->fin,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientCMRN" VALUE="^,record_data->cmrn,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="strPatientNextGen" VALUE="^,record_data->next_gen_id,^">^,CHAR(10),CHAR(13),

		  ^<INPUT TYPE="hidden" NAME="bStaffIsPhysician" VALUE="^,record_data->user.physician_ind,^">^,CHAR(10),CHAR(13), ;v4.0

		  ^<INPUT TYPE="hidden" NAME="strStaffCernerPosition" VALUE="^,record_data->user.user_position,^">^,CHAR(10),CHAR(13), ;v4.0

		  ^<INPUT TYPE="hidden" NAME="strPatientSetting" VALUE="^,record_data->encntr_type,^">^,CHAR(10),CHAR(13), ;v4.0

		^</FORM>^,CHAR(10),CHAR(13),

		^</HTML>^,CHAR(10),CHAR(13),

		^<SCRIPT TYPE="text/javascript">^,CHAR(10),CHAR(13),

		  ^/* SUBMIT FORM */^,CHAR(10),CHAR(13),

		  ^var objCtrl = document.getElementById("frmMain");^,CHAR(10),CHAR(13),

		  ^objCtrl.submit();^,CHAR(10),CHAR(13),

		^</SCRIPT>^

		)

	endif

	return (temp_html)

end ;subroutine GetHTML( dummy )

 

/**************************************************************

; DVDev EXIT SCRIPT

**************************************************************/

#exit_script

set _MEMORY_REPLY_STRING = GetHTML(0)

if (validate(debug_ind,0) = 1)

	call echorecord(record_data)

else

	free record record_data

endif

end

go

 

set debug_ind = 1 go

;1chs_tn_foreign_launch "MINE", 16580773.00, 110437614.00, 12321980.00 go

;personId, encntrId, userId, launchURL

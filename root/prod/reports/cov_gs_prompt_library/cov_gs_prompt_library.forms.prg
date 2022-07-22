/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author/Contributors:	Covenant Report Dev Team
	Source file name:		cov_PromptLibrary.forms
 
 	Purpose:			This is a library of Prompts that can be
						imported and used by any program.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Prompt Name       	Developer			Date		      Comment
 	----------------------------------------------------------------------------------------------------------
 	Start Date			Geetha Saravanan		11-20-2017	Start Date with no time
 	End Date			Geetha Saravanan		11-20-2017	End Date with no time
 	Facility			Geetha Saravanan		11-20-2017	Combo box - all facilities with default MMC,
 	Fin				Geetha Saravanan		11-20-2017	Fin/Visit number
 	Start Date/Time		Todd A. Blanchard		11-21-2017	Start Date with time
 	End Date/Time		Todd A. Blanchard		11-21-2017	End Date with time
 	Facility_list		Todd A. Blanchard		11-21-2017	Sorted by facility name - List box
 	Year                    Geetha Saravanan        09-07-2018  Year only calendar(custom script)
 	Quarter                 Geetha Saravanan        09-07-2018  Quarter(1 to 4) of the Year
 	Acute_facility_list     Geetha Saravanan        10-15-2018  Only acute facilities with ED - list box - based on facility code
 	Surgery Locations       Geetha Saravanan        01-10-2019  Surginet - Surgery locations - script specific
  	Acute_org_list          Geetha Saravanan        01-31-2019  Only acute organizations - list box - based on organization_id code
  	Nurse_Unit              Geetha Saravanan        01-31-2019  Only acute organizations - list box - based on organization_id code
 	Month				Geetha Saravanan        02-07-2019  All 12 months
 	Infusion center		Geetha Saravanan        05-01-2019  All Infusion centers
 	Location list		Geetha Saravanan        07-08-2019  All locations combined(acute and ambulatory)
 
******************************************************************************/
 
 
drop program cov_gs_prompt_library:DBA go
create program cov_gs_prompt_library:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 2552503613
	, "FIN" = ""
	, "Select Facility" = 0
	, "Quarter" = "q1"
	, "Year" = 0
	, "Select Facility" = 0
	, "Select Facility" = 0
	, "Select Surgery Location" = 0
	, "Select Nurse Unit" = 0
	, "Month" = 0
	, "Infusion Center" = 0
	, "Location" = 0
	, "Class Code" = 0
	, "Code Value" = ""
	, "Hospitals_clinics" = 0
	, "Generate File:" = 1
	, "nurse unit based on location cd" = 0 

with OUTDEV, start_date, end_date, start_datetime, end_datetime, facility, fin, 
	facility_list, quarter, year_prmt, acute_facility_list, org_list, surgery_locations, 
	nurse_unit, month, infusion_center, all_cov_facilities, class_code, code_value, 
	all_cov_facilities_clinics, to_file, nurse_unit1
 
end
go
 
 
 
 /*Facilities used in Prompt (Combo box)
 
	2552503635.00	FLMC	FACILITY	Fort Loudoun Medical Center
	21250403.00		FSR	FACILITY	Fort Sanders Regional Medical Center
	2552503653.00	LCMC	FACILITY	LeConte Medical Center
	2552503613.00	MMC	FACILITY	Methodist Medical Center
	2552503639.00	MHHS	FACILITY	Morristown-Hamblen Hospital Association
	2552503645.00	PW	FACILITY	Parkwest Medical Center
	2552503649.00	RMC	FACILITY	Roane Medical Center
    2553765291.00	CLMC	FACILITY	Claiborne Medical Center
    2552503657.00	CMC	FACILITY	Cumberland Medical Center, Inc
 
     2553765571.00	FSR Pat Neal
 
 
 
*/

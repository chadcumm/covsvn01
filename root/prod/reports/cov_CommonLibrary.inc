/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		12/08/2017
	Source file name:	cov_CommonLibrary.inc
 
	Purpose:			This is a library of common subroutines that can be
						used by any program.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Subroutine       	        Date	      Developer			Comment
 	------------------     ------------     --------------------  --------------------------------------
 	wrap					12-07-2017        Todd A. Blanchard
 	wrap2					12-07-2017        Todd A. Blanchard
 	wrap3					03-12-2018        Geetha Saravanan
 	get_AliasPoolCode		12-08-2017        Geetha Saravanan     Nested Subroutine
 	get_FacilityName		12-11-2017        Geetha Saravanan
 	get_FacilityCode		12-15-2017        Geetha Saravanan
 	get_ApptBookId			07-11-2018        Todd A. Blanchard
 	get_OrganizationId		07-11-2018        Todd A. Blanchard
 	get_ApptBookId			07-18-2018        Todd A. Blanchard    Fixed appt_book_id for FSR
 	get_ApptBookId			09-06-2018        Todd A. Blanchard    Added FSR West Diagnostic Center.
 	get_LocationCode		09-06-2018        Todd A. Blanchard    Added FSR West Diagnostic Center.
 	get_ApptBookId			10-29-2018        Todd A. Blanchard    Added MHHS Regional Diagnostic Center.
 	get_LocationCode		10-29-2018        Todd A. Blanchard    Added MHHS Regional Diagnostic Center.
 	get_ApptBookId			12-06-2021        Todd A. Blanchard    Added Covenant Health Diagnostics West.
 	get_LocationCode		12-06-2021        Todd A. Blanchard    Added Covenant Health Diagnostics West.
 
******************************************************************************/
 
 
; Wrap input values in double-quotes.
;
; Mainly used when generating output for .csv files.
SUBROUTINE (wrap(data = vc(value)) = vc)
 
	return(build(char(34), trim(data, 3), char(34)))
 
END
;----------------------------------------------------------------------------------------------------------------
 
; Trim input values and no special char at the end
 
SUBROUTINE (wrap1(data = vc(value)) = vc)
 
	return(trim(data, 3))
 
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Wrap input values in double-quotes and append a comma.
;
; Mainly used when generating output for .csv files.
SUBROUTINE (wrap2(data = vc(value)) = vc)
 
	return(build(char(34), trim(data, 3), char(34), char(44)))
 
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Input values seperated by pipe
;
; Mainly used when generating output for .csv files.
SUBROUTINE (wrap3(data = vc(value)) = vc)
 
	return(build(trim(data, 3),char(124)))
 
END
 
;----------------------------------------------------------------------------------------------------------------
 
; To get Alias_pool_cd by passing Facility code
; Alias pool code mostly used to get MRN from encntr_alias table
 
SUBROUTINE (get_AliasPoolCode(facility_code = vc(value)) = f8)
 
 	declare pool_cd_var = f8 with noconstant(0.0), protect
 	declare fcode_var   = vc with constant(get_FacilityName(facility_code)), protect
 
	select into "NL:"
	     cv1.code_value
	from code_value cv1
	where cv1.code_set = 263
		and cv1.active_ind = 1
		and substring(6,3,cv1.display) = "MRN"
		and substring(12,4,cv1.display) = fcode_var
	detail
		pool_cd_var = cv1.code_value
	with nocounter
 
	RETURN(pool_cd_var)
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Can be used to get facility Nemonic by passing facility code.
 
SUBROUTINE (get_FacilityName(fcode = vc(value)) = vc)
 
	declare facility_name_var = vc with noconstant(" "), protect
 
	select into "NL:"
	     cv1.display
	from code_value cv1
	where cv1.code_set =  220
	  	and cv1.active_ind = 1
	 	and cv1.code_value = cnvtreal(fcode)
		and cv1.cdf_meaning = "FACILITY"
	detail
	      facility_name_var = cv1.display
	with nocounter
 
	RETURN(facility_name_var)
END
 
 
;----------------------------------------------------------------------------------------------------------------
 
;Can be used to get Facility Code by passing Fin number
SUBROUTINE (get_FacilityCode(fin = vc(value)) = f8)
 
	declare fin_var  = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
	declare fac_code = f8 with noconstant(0)
 
	select into "NL:"
	  e.loc_facility_cd
	from encntr_alias ea, encounter e
	plan ea where ea.alias = fin
	     and ea.encntr_alias_type_cd = fin_var ; 1077
	join e where e.encntr_id = ea.encntr_id
 
	detail
	   fac_code = e.loc_facility_cd
 
	with nocounter
 
	RETURN(fac_code)
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Get Scheduling Appointment Book Id for specified Location Code
SUBROUTINE (get_ApptBookId(location_cd = f8(value)) = f8)
 
 	declare appt_book_id = f8 with noconstant(0.0)
 
	set appt_book_id = evaluate(location_cd,
		2552503635.00,	1644560.00,	; Fort Loudoun Medical Center
		21250403.00,	1651507.00,	; Fort Sanders Regional Medical Center
		2552503653.00,	1618674.00,	; LeConte Medical Center
		2552503613.00,	1639290.00,	; Methodist Medical Center
		2552503639.00,	1657840.00,	; Morristown-Hamblen Hospital Association
		2552503645.00,	1644785.00,	; Parkwest Medical Center
		2552503649.00,	1639334.00,	; Roane Medical Center
		2553765283.00,	1639316.00,	; MMC Cheyenne Outpatient Diagnostic Center
		2553765579.00,	1644848.00,	; Peninsula Behavioral Health
		2553765363.00,	1666627.00,	; FSR West Diagnostic Center
		2553765491.00,	1657868.00,	; MHHS Regional Diagnostic Center
		3612179491.00,	2172452.00,	; Covenant Health Diagnostics West
		0.0
		)
 
	RETURN(appt_book_id)
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Get Location Code for specified Appointment Book Id
SUBROUTINE (get_LocationCode(appt_book_id = f8(value)) = f8)
 
 	declare location_cd = f8 with noconstant(0.0)
 
	set location_cd = evaluate(appt_book_id,
		1644560.00,	2552503635.00,	; Fort Loudoun Medical Center
		1651507.00,	21250403.00,	; Fort Sanders Regional Medical Center
		1618674.00,	2552503653.00,	; LeConte Medical Center
		1639290.00,	2552503613.00,	; Methodist Medical Center
		1657840.00,	2552503639.00,	; Morristown-Hamblen Hospital Association
		1644785.00,	2552503645.00,	; Parkwest Medical Center
		1639334.00,	2552503649.00,	; Roane Medical Center
		1639316.00,	2553765283.00,	; MMC Cheyenne Outpatient Diagnostic Center
		1644848.00,	2553765579.00,	; Peninsula Behavioral Health
		1666627.00,	2553765363.00,	; FSR West Diagnostic Center
		1657868.00,	2553765491.00,	; MHHS Regional Diagnostic Center
		2172452.00,	3612179491.00,	; Covenant Health Diagnostics West
		0.0
		)
 
	RETURN(location_cd)
END
 
;----------------------------------------------------------------------------------------------------------------
 
; Get Organization Id for specified Location Code
SUBROUTINE (get_OrganizationId(location_cd = f8(value)) = f8)
 
 	declare organization_id = f8 with noconstant(0.0)
 
	select into "NL:"
		l.organization_id
	from
		LOCATION l
	where
		l.location_cd = location_cd
 
	detail
		organization_id = l.organization_id
 
	with nocounter, time = 30
 
	RETURN(organization_id)
END
 
;-----------------------------------------------------------------------------------------------------------------
 


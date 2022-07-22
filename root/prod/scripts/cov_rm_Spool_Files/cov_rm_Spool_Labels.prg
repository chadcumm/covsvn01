/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/12/2022
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_Spool_Labels.prg
	Object name:		cov_rm_Spool_Labels
	Request #:			?
 
	Program purpose:	Generates spool files to be routed to and processed by
						PatientWorks for labels.
 
	Executing from:		Registration
 
 	Special Notes:		Output files:
 							{fin}_cerner_labels.spl
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_Spool_Labels:DBA go
create program cov_rm_Spool_Labels:DBA

prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV


; call driver program
execute pmdbdocs_driver
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare fin_var				= vc with constant(pmdbdoc->patient_data.person.encounter.finnbr.fin_formatted)

declare file_var			= vc with constant(build(fin_var, "_cerner_labels", ".spl"))
declare temppath_var		= vc with constant(build("cer_temp:", file_var))

declare output_var			= vc with noconstant("")

declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
 
; define output value
;if (validate(request->batch_selection) = 1)
	set output_var = value(temppath_var)
;else
;	set output_var = value($OUTDEV)
;endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

/**************************************************************/
; build spool file
;if (validate(request->batch_selection) = 1)
	set modify filestream
;endif
; 
;select if (validate(request->batch_selection) = 1 or $output_file = 1)
;	with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 80
;else
;	with nocounter, nullreport, separator = " ", format, landscape, compress, maxcol = 80
;endif
;
;into value(output_var)

select into value(output_var)
	; line 0
	output_dest_name		= trim(substring(1, 10, od.description), 3)
	, form_name				= "PWLBL01"
	, print_dt_tm			= format(cnvtdatetime(curdate, curtime), "mm/dd/yy hh:mm;;q")
	
	; line 1
	, patient_name		= trim(substring(1, 24, pmdbdoc->patient_data.person.name_full_formatted), 3)
	, gender			= trim(substring(1, 1, pmdbdoc->patient_data.person.sex_disp), 3)
	, gender_desc		= trim(substring(1, 6, pmdbdoc->patient_data.person.sex_disp), 3)
	
	, birth_dt			= format(cnvtdatetimeutc(datetimezone(
							pmdbdoc->patient_data.person.birth_dt_tm, 
							pmdbdoc->patient_data.person.birth_tz), 1), "mm/dd/yy;;d")
							
	, age				= trim(substring(1, 3, pmdbdoc->patient_data.person.age), 3)
	, ssn				= trim(substring(1, 11, pmdbdoc->patient_data.person.ssn.alias), 3)
	, cmrn				= trim(substring(1, 8, pmdbdoc->patient_data.person.cmrn.alias), 3)
	
	; line 2
;	, address1		= trim(substring(1, 24, pmdbdoc->patient_data.person.home_address.street_addr), 3)
;	, city			= trim(substring(1, 9, pmdbdoc->patient_data.person.home_address.city), 3)
;	, state			= trim(substring(1, 2, pmdbdoc->patient_data.person.home_address.state), 3)
;	, zipcode		= trim(substring(1, 10, pmdbdoc->patient_data.person.home_address.zipcode), 3)
	
	; line 3
	, mrn			= trim(substring(1, 10, pmdbdoc->patient_data.person.mrn.mrn_formatted), 3)
	, phone			= trim(substring(1, 13, pmdbdoc->patient_data.person.home_phone.phone_formatted), 3)
	
	; line 4
	, language		= trim(substring(1, 18, pmdbdoc->patient_data.person.language_disp), 3)
	
	; line 5
	, fin				= trim(substring(1, 10, pmdbdoc->patient_data.person.language_disp), 3)
	, enc_type			= trim(substring(1, 2, pmdbdoc->patient_data.person.encounter.encntr_type_disp), 3) ; TODO: outbound alias
	, fac				= trim(substring(1, 1, pmdbdoc->patient_data.person.encounter.loc_facility_disp), 3) ; TODO: outbound alias
	, admit_dt			= trim(substring(1, 8, pmdbdoc->patient_data.person.encounter.reg_dt_tm), 3) ; TODO: date only
	, admit_tm			= trim(substring(1, 4, pmdbdoc->patient_data.person.encounter.reg_dt_tm), 3) ; TODO: time only
	, med_svc_cd		= trim(substring(1, 3, pmdbdoc->patient_data.person.encounter.med_service_cd), 3) ; TODO: outbound alias
	, med_svc_desc		= trim(substring(1, 21, pmdbdoc->patient_data.person.encounter.med_service_disp), 3)
	
	; line 6
	, rm_bed			= build2(substring(1, 3, pmdbdoc->patient_data.person.encounter.loc_room_disp), " - ", ; TODO: outbound alias
								 substring(1, 3, pmdbdoc->patient_data.person.encounter.loc_bed_disp)) ; TODO: outbound alias
							
	, nurse_unit		= trim(substring(1, 4, pmdbdoc->patient_data.person.encounter.loc_nurse_unit_disp), 3) ; TODO: outbound alias
		
	; line 9
	, admit_phy			= trim(substring(1, 18, pmdbdoc->patient_data.person.encounter.admitdoc.name_full_formatted), 3)
	, attend_phy		= trim(substring(1, 18, pmdbdoc->patient_data.person.encounter.attenddoc.name_full_formatted), 3)
	, primary_phy		= trim(substring(1, 23, pmdbdoc->patient_data.person.pcp.name_full_formatted), 3)
	
	; line 10
	, admit_diag		= trim(substring(1, 33, pmdbdoc->patient_data.person.encounter.diagnosis_01.nomenclature_id), 3)
	, med_comment		= trim(substring(1, 31, pmdbdoc->patient_data.person.encounter.diagnosis_01.nomenclature_id), 3)
	
	; line 13
	, fin_class			= trim(substring(1, 2, pmdbdoc->patient_data.person.encounter.financial_class_cd), 3) ; TODO: outbound alias
	
	; line 22
	, employee_name		= if (pmdbdoc->patient_data.person.employer_01.person_id > 0.0)
							trim(substring(1, 50, pmdbdoc->patient_data.person.name_full_formatted), 3)
						  endif
	
from
	OUTPUT_DEST od

	, (dummyt d with seq = 1)
	
plan d

join od
where
	od.output_dest_cd = request->destination[1].output_dest_cd
 
detail
	; line 0
	col 0	output_dest_name, ":", output_dest_name, ":", form_name, ",1"
	col 64	print_dt_tm
	row + 1
	
	; line 1
	col 1	patient_name
	col 31	gender
	col 33	gender_desc
	col 40	birth_dt
	col 49	age
	col 54	ssn
	col 67	cmrn
	row + 1
	
	; line 2
;	col 0 address1
;	col 50 city
;	col 60 state
;	col 63 zipcode
	row + 1
	
	; line 3
	col 0	mrn
	col 10	phone
	row + 1
	
	; line 4
	col 31	language
	row + 1
	
	; line 5
	col 0	fin
	col 13	enc_type
	col 15	fac
	col 17	admit_dt_tm
	col 26	admit_time
	col 35	medical_service_cd
	col 39	medical_service_desc
	row + 1
	
	; line 6
	col 0	rm_bed
	col 16	loc
	row + 1
	
	; line 7
	row + 1
	
	; line 8
	row + 1
	
	; line 9
	col 0	admit_phy
	col 19	attend_phy
	col 57	primary_phy
	row + 1
	
	; line 10
	row + 1
	
	; line 11
	row + 1
	
	; line 12
	row + 1
	
	; line 13
	col 0	fin_class
	row + 1
	
	; line 14
	row + 1
	
	; line 15
	row + 1
	
	; line 16
	row + 1
	
	; line 17
	row + 1
	
	; line 18
	row + 1
	
	; line 19
	row + 1
	
	; line 20
	row + 1
	
	; line 21
	row + 1
	
	; line 22
	col 0	employee_name
	row + 1
	
	; line 23
	row + 1
	
	; line 24
	row + 1
	
	; line 25
	row + 1
	
	; line 26
	row + 1
	
	; line 27
	col 0	ff = char(12), ff
 
;with nocounter

with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 80
 
  
; send file to print queue
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set cmd = build2("lpr -P ", output_var, " ", temppath_var)
;	set len = size(trim(cmd))
; 
;	call dcl(cmd, len, stat)
;	call echo(build2(cmd, " : ", stat))
;endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
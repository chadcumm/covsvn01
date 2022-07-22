/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/12/2022
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_Spool_Labels_NB.prg
	Object name:		cov_rm_Spool_Labels_NB
	Request #:			?
 
	Program purpose:	Generates spool files to be routed to and processed by
						PatientWorks for newborn labels.
 
	Executing from:		Registration
 
 	Special Notes:		Output files:
 							{fin}_cerner_labels.spl
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_Spool_Labels_NB:DBA go
create program cov_rm_Spool_Labels_NB:DBA

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

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

declare file_var			= vc with constant(build(fin_var, "_cerner_labels_nb", ".spl"))
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
	; line 1
	output_dest_name		= trim(substring(1, 10, od.description), 3)
	, form_name				= "PWNEWBORN"
	, print_dt_tm			= format(cnvtdatetime(curdate, curtime), "mm/dd/yy hh:mm;;q")
	
	; line 2
	, patient_name		= trim(substring(1, 20, pmdbdoc->patient_data.person.name_full_formatted), 3)
	, gender			= trim(substring(1, 1, pmdbdoc->patient_data.person.sex_disp), 3)
	, gender_desc		= trim(substring(1, 6, pmdbdoc->patient_data.person.sex_disp), 3)
	
	, birth_dt			= format(cnvtdatetimeutc(datetimezone(
							pmdbdoc->patient_data.person.birth_dt_tm, 
							pmdbdoc->patient_data.person.birth_tz), 1), "mm/dd/yy;;d")
							
	, age				= trim(substring(1, 4, pmdbdoc->patient_data.person.age), 3)
	, ssn				= trim(substring(1, 11, pmdbdoc->patient_data.person.ssn.alias), 3)
	, cmrn				= trim(substring(1, 8, pmdbdoc->patient_data.person.cmrn.alias), 3)
	
	; line 3
	, address1		= trim(substring(1, 25, pmdbdoc->patient_data.person.home_address.street_addr), 3)
	, address2		= trim(substring(1, 25, pmdbdoc->patient_data.person.home_address.street_addr2), 3)
	, city			= trim(substring(1, 18, pmdbdoc->patient_data.person.home_address.city), 3)
	, state			= trim(substring(1, 2, pmdbdoc->patient_data.person.home_address.state), 3)
	, zipcode		= trim(substring(1, 10, pmdbdoc->patient_data.person.home_address.zipcode), 3)
	
	; line 4
	; TODO: Continue here	
	
;	, fin			= substring(1, 10, pmdbdoc->patient_data.person.encounter.finnbr.fin_formatted)
	
from
	OUTPUT_DEST od

	, (dummyt d with seq = 1)
	
plan d

join od
where
	od.output_dest_cd = request->destination[1].output_dest_cd
 
detail
	; line 1
	col 0	output_dest_name, ":", output_dest_name, ":", form_name, ",1"
	col 64	print_dt_tm
	row + 1
	
	; line 2
;	col 0	"Line 2"
	col 0	" ", patient_name
	col 31	gender, " ", gender_desc
	col 40	birth_dt, " ", age
	col 54	ssn
	col 67	cmrn
	row + 1
	
	; line 3
;	col 0	"Line 3"
	col 0	address1
	col 25	address2
	col 50	city, ",", state, " ", zipcode
	row + 1
	
	; line 4
	col 0	"Line 4"
	row + 1
	
	; line 5
	col 0	"Line 5"
	row + 1
	
	; line 6
	col 0	"Line 6"
	row + 1
	
	; line 7
	col 0	"Line 7"
	row + 1
	
	; line 8
	col 0	"Line 8"
	row + 1
	
	; line 9
	col 0	"Line 9"
	row + 1
	
	; line 10
	col 0	"Line 10"
	row + 1
	
	; line 11
	col 0	"Line 11"
	row + 1
	
	; line 12
	col 0	"Line 12"
	row + 1
	
	; line 13
	col 0	"Line 13"
	row + 1
	
	; line 14
	col 0	"Line 14"
	row + 1
	
	; line 15
	col 0	"Line 15"
	row + 1
	
	; line 16
	col 0	"Line 16"
	row + 1
	
	; line 17
	col 0	"Line 17"
	row + 1
	
	; line 18
	col 0	"Line 18"
	row + 1
	
	; line 19
	col 0	"Line 19"
	row + 1
	
	; line 20
	col 0	"Line 20"
	row + 1
	
	; line 21
	col 0	"Line 21"
	row + 1
	
	; line 22
	col 0	"Line 22"
	row + 1
	
	; line 23
	col 0	"Line 23"
	row + 1
	
	; line 24
	col 0	"Line 24"
	row + 1
	
	; line 25
	col 0	"Line 25"
	row + 1
	
	; line 26
	col 0	"Line 26"
	row + 1
	
	; line 27
	col 0	"Line 27"
	row + 1
	
	; line 28
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
 

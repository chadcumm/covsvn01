drop program cov_transfer_meds_st go
create program cov_transfer_meds_st



if (not(validate(request,0)))
record request
	(
	  1 output_device = vc
	  1 script_name = vc
	  1 person_cnt = i4
	  1 person[*]
	    2 person_id        = f8
	  1 visit_cnt = i4
	  1 visit[*]
	    2 encntr_id        = f8
	  1 prsnl_cnt = i4
	  1 prsnl[*]
	    2 prsnl_id        = f8
	  1 nv_cnt = i4
	  1 nv[*]
	    2 pvc_name = vc
	    2 pvc_value = vc
	  1 batch_selection = vc
	)


if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif



;****************************************************************************
; BUILDING SCRIPT VARIABLES
;****************************************************************************
declare getStringFitLen(fitString = vc, cellWidth = f8,cellHeight = f8) = i4
declare person_id = f8 with protect
declare encntr_id = f8 with protect
declare printer_name = vc with protect
declare dummy_val = f8 with protect
declare num_allergies = i4 with protect
declare allergies_disp = vc with protect
declare room_bed = vc with protect
declare drug_details = vc with protect
declare allergy_list = vc with protect
declare allergy_list2 = vc with protect
declare secondstr = vc with protect
declare fit_length = i4 with protect
declare fit_length2 = i4 with protect
declare bGrow = i1 with protect, noconstant(1)
declare foot_rpt_flag = i1 with protect, noconstant(0)
declare errorCode = i2 with protect, noconstant(0)
 
;****************************************************************************
; SUCCESS CODES
;****************************************************************************
declare SUCCESS = i2 with protect, constant(0)
 
 
 
;****************************************************************************
; INVALID REQUEST ERRORS
;****************************************************************************
declare INVALID_PERSON_ID = i2 with protect, constant(1)
declare INVALID_ENCNTR_ID = i2 with protect, constant(2)
declare INVALID_PRINTER_NAME = i2 with protect, constant(3)
 
 
 
;****************************************************************************
; FAILED SCRIPTS
;****************************************************************************
declare FAILED_PATIENT_LOOKUP = i2 with protect, constant(4)
declare FAILED_PRINTER_LOOKUP = i2 with protect, constant(5)
 
 
 
 
;****************************************************************************
; STATUS/ERROR HANDLER
;****************************************************************************
declare StatusHandler("") = NULL
 
subroutine StatusHandler("")
	declare sErrMsg = vc with private
 
	if (errorCode = SUCCESS)
		set reply->status_data.status = "S"
	else
		case (errorCode)
			of (INVALID_PERSON_ID):
				set sErrMsg = "Invalid person_id"
			of (INVALID_ENCNTR_ID):
				set sErrMsg = "Invalid encntr_id"
			of (INVALID_PRINTER_NAME):
				set sErrMsg = "Invalid printer_name"
			of (FAILED_PATIENT_LOOKUP):
				set sErrMsg = "Patient lookup failed"
			of (FAILED_PRINTER_LOOKUP):
				set sErrMsg = "Printer lookup failed"
		endcase
 
		set reply->status_data->status = "F"
	    set reply->status_data->subeventstatus[1]->OperationStatus = "F"
	    set reply->status_data->subeventstatus[1]->TargetObjectValue = sErrMsg
	endif
end
 
 
;****************************************************************************
; CLEANUP RECORD STRUCTURES
;****************************************************************************
declare DestroyRecords("") = NULL
 
subroutine DestroyRecords("")
	if (validate(patientRec))
		free record patientRec
	endif
 
	if (validate(allergy))
		free record allergy
	endif
 
	if (validate(ordersRec))
		free record ordersRec
	endif
end

free set ordersRec
record ordersRec
(
  1 orders_list[*]
  	2 mnemonic              = vc
    2 clinical_display_line       = vc
    2 details[*]
  		3 indication				  = vc
    	3 last_admin_dt_tm            = vc
)
 
free set ordersRec
record ordersRec
(
	1 orders_list[*]
		2 order_id                      = f8
		2 rx_ind                = i2
		2 mnemonic		        = vc
		2 clinical_display_line		= vc
		2 order_flag			= i1
		2 details[*]
			3 indication		= vc
			3 last_admin_dt_tm	= vc
)


FREE RECORD drec
RECORD drec

(
1	line_cnt		=	i4
1	display_line	=	vc
1	line_qual[*]
	2	disp_line	=	vc
)

;RTF variables.
SET rhead   = concat('{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern Lucida Console;}}',
                  '{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134')
SET RH2r    = '\plain \f0 \fs18 \cb2 \pard\s10 '
SET RH2b    = '\plain \f0 \fs18 \b \cb2 \pard\s10 '
SET RH2bu   = '\plain \f0 \fs18 \b \ul \cb2 \pard\s10 '
SET RH2u    = '\plain \f0 \fs18 \u \cb2 \pard\s10 '
SET RH2i    = '\plain \f0 \fs18 \i \cb2 \pard\s10 '
SET REOL    = '\par '
SET Rtab    = '\tab '
SET wr      = '\plain \f0 \fs16 \cb2 '
SET ul      = '\ul '
SET wb      = '\plain \f0 \fs16 \b \cb2 '
SET wu      = '\plain \f0 \fs18 \ul \cb2 '
SET wi      = '\plain \f0 \fs18 \i \cb2 '
SET wbi     = '\plain \f0 \fs18 \b \i \cb2 '
SET wiu     = '\plain \f0 \fs18 \ul \i \cb2 '
SET wbiu    = '\plain \f0 \fs18 \b \ul \i \cb2 '
SET wbu     = '\plain \f0 \fs18 \b \ul \cb2 '
SET rtfeof  = '} '
SET bullet  = '\bullet '


;****************************************************************************
; BUILDING PATIENT REQUEST STRUCTURE
;****************************************************************************
%i cclsource:orm_rpt_meds_rec_requests.inc
set errorCode = BuildPatientRequest("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif
 
 
 
;****************************************************************************
; BUILDING PATIENT INFO
;****************************************************************************
%i cclsource:orm_rpt_meds_rec_patient_data.inc
set errorCode = LoadPatientInfo("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif
 
 
 
;****************************************************************************
; BUILDING OUTPATIENT ORDER LIST
;****************************************************************************
%i cclsource:orm_rpt_meds_rec_transfer_data.inc
set errorCode = LoadInpatOrdersOfPatient("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif

set idx = 1
set stat = alterlist(drec->line_qual, idx)
set drec->line_qual[idx].disp_line = CONCAT(rhead,rh2bu,"Discharge Medications",wr,reol)

for (idx=1 to size(drec->line_qual,5))
	set reply->text = concat(reply->text,drec->line_qual[idx].disp_line)
endfor

#exit_script
SET reply->text = CONCAT(reply->text, rtfeof)

call echorecord(request) 
call echorecord(reply)

end go


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
%i cclsource:orm_rpt_meds_rec_error_codes.inc
%i cclsource:orm_rpt_meds_rec_orders_record.inc 

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


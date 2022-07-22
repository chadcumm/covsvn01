drop program cov_transfer_medrec_st go
create program cov_transfer_medrec_st

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

free set 510001_REQUEST  
record 510001_REQUEST (
  1 person_id = f8   
  1 encounter_id = f8   
  1 override_org_security = i2   
  1 personnel_id = f8   
  1 diagnosis_ind = i2   
) 

free set 510001_REPLY 
record 510001_REPLY (
  1 transaction_status  
    2 success_ind = i2   
    2 debug_error_message = vc  
  1 home_medications [*]   
    2 order_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
  1 continued_medications [*]   
    2 proposal_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
  1 continued_non_medications [*]   
    2 proposal_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
    2 clinical_category_cd = f8   
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

select into "nl:"
from 
	encounter e
plan e
	where e.encntr_id = request->visit[1].encntr_id
detail
	510001_REQUEST->person_id 					= e.person_id  
	510001_REQUEST->encounter_id 				= e.encntr_id 
	510001_REQUEST->override_org_security 		= 1 
	510001_REQUEST->personnel_id 				= reqinfo->updt_id 
	510001_REQUEST->diagnosis_ind 				= 1 
with nocounter

call echorecord(510001_REQUEST)

if ((510001_REQUEST->person_id > 0.0) and (510001_REQUEST->encounter_id > 0.0))
	set stat = tdbexecute(600005, 500195, 510001, "REC", 510001_REQUEST, "REC", 510001_REPLY) 
endif

if ((510001_REPLY->transaction_status.success_ind = 1) and (size(510001_REPLY->continued_medications,5) > 0))
	set idx = 1
	set stat = alterlist(drec->line_qual, idx)
	set drec->line_qual[idx].disp_line = CONCAT(rhead,rh2bu,"Discharge Medications",wr,reol)
	for (i=1 to size(510001_REPLY->continued_medications,5))
		set idx = (idx + 1)
		set stat = alterlist(drec->line_qual, idx)
		set drec->line_qual[idx].disp_line = CONCAT(
														wb,
														510001_REPLY->continued_medications[i].order_name," ",
														wr,
														510001_REPLY->continued_medications[i].order_detail_line,
														REOL)
		;set idx = (idx + 1)
		;set stat = alterlist(drec->line_qual, idx)
		;set drec->line_qual[idx].disp_line = CONCAT(
		;												wr,
		;												"Ordering Physician:" ,
		;												510001_REPLY->continued_medications[i].ordering_physician,
		;												REOL)
		set idx = (idx + 1)
		set stat = alterlist(drec->line_qual, idx)
		set drec->line_qual[idx].disp_line = CONCAT(reol)
	endfor
else
	SELECT into 'nl:'
	FROM (dummyt d with seq = 1)
	HEAD REPORT
	 idx = 1
	 stat = alterlist(drec->line_qual, idx)
	 drec->line_qual[1].disp_line = CONCAT(rhead,wr,reol)
	WITH nocounter
endif

for (idx=1 to size(drec->line_qual,5))
	set reply->text = concat(reply->text,drec->line_qual[idx].disp_line)
endfor

#exit_script
SET reply->text = CONCAT(reply->text, rtfeof)

call echorecord(510001_reply) 
call echorecord(reply)

end go


/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		02/12/2020
	Solution:			
	Source file name:	cov_bbt_ops_wrapper.prg
	Object name:		cov_bbt_ops_wrapper
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	02/12/2020  Chad Cummings
******************************************************************************/

drop program cov_bbt_ops_wrapper:dba go
create program cov_bbt_ops_wrapper:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

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

call set_codevalues(null)
call check_ops(null)

/*
free record ops_request2 go

record ops_request2 (
  1 Output_Dist = c100  
  1 Batch_Selection = c100  
  1 Ops_Date = dq8   
  1 address_location_cd = f8   
  1 cur_owner_area_cd = f8   
  1 cur_inv_area_cd = f8   
) go


 
Free record ops_reply2 go
record ops_reply2 (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
*/

free set t_rec
record t_rec
(
	1 cnt		= i2
	1 qual[*]
	 2 batch_selection = vc
	 2 output_dest = vc
)

set t_rec->cnt = 7
set stat = alterlist(t_rec->qual,t_rec->cnt)

set t_rec->qual[1].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2554362747] INV[2554362755] LOC[2552503613] PATENCSTATUS[0]"
set t_rec->qual[1].output_dest 		= "cpt_b_revcycl_a_mfp" ;mmc_blab_bb_b_pln

set t_rec->qual[2].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2555024339] INV[2555024347] LOC[2552503649] PATENCSTATUS[0]"
set t_rec->qual[2].output_dest 		= "cpt_b_revcycl_a_mfp"	;rmc_1lab_bb_a_pln

set t_rec->qual[3].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2555140621] INV[2555140629] LOC[2552503645] PATENCSTATUS[0]"
set t_rec->qual[3].output_dest 		= "cpt_b_revcycl_a_mfp" ;pw_1lab_bb_d_pln

set t_rec->qual[4].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2555029307] INV[2555029315] LOC[2552503635] PATENCSTATUS[0]"
set t_rec->qual[4].output_dest 		= "cpt_b_revcycl_a_mfp"	;flmc_1lab_bb_c_pln

set t_rec->qual[5].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2553672881] INV[2553672889] LOC[21250403] PATENCSTATUS[1]"
set t_rec->qual[5].output_dest 		= "cpt_b_revcycl_a_mfp"	;fsr_llab_bb_e_pln

set t_rec->qual[6].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2555140639] INV[2555140647] LOC[2552503639] PATENCSTATUS[0]"
set t_rec->qual[6].output_dest 		= "cpt_b_revcycl_a_mfp"	;mhhs_1lab_bb_c_pln

set t_rec->qual[7].batch_selection 	= "MODE[UPDATE] SORT[NAME] OWN[2553645953] INV[2553672873] LOC[2552503653] PATENCSTATUS[0]"
set t_rec->qual[7].output_dest 		= "cpt_b_revcycl_a_mfp" ;lcmc_1lab_bb_b_pln

free record ops_request2 

record ops_request2 (
  1 Output_Dist = c100  
  1 Batch_Selection = c100  
  1 Ops_Date = dq8   
  1 address_location_cd = f8   
  1 cur_owner_area_cd = f8   
  1 cur_inv_area_cd = f8   
)
	
	
free record ops_reply2 
record ops_reply2 (
	1 ops_event = vc
%i cclsource:status_block.inc
	) 

for (i=1 to t_rec->cnt)
	
	set stat = initrec(ops_request2)
	set stat = initrec(ops_reply2)
	
	set ops_request2->batch_selection 	= t_rec->qual[i].batch_selection 
	set ops_request2->output_dist	 	= t_rec->qual[i].output_dest 
	set ops_request2->ops_date 			= cnvtdatetime(curdate+0,curtime3) 
	set reqinfo->updt_req 				= 225211

	execute cov_bbt_ops_batch_release with replace("REQUEST",OPS_REQUEST2), replace("REPLY",OPS_REPLY2) 
  
	call echorecord(ops_reply2) 

endfor
										
call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Running Report ************************************"))


call writeLog(build2("* END   Running Report ***********************************"))
call writeLog(build2("************************************************************"))

set reply->status_data.status = "S"

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
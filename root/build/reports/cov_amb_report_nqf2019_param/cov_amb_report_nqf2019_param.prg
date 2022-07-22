/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_amb_report_nqf2019_param.prg
	Object name:		cov_amb_report_nqf2019_param
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_amb_report_nqf2019_param:dba go
create program cov_amb_report_nqf2019_param:dba

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
  "Output to File/Printer/MINE" = "MINE" ,
  "Reporting Time Frame" = "YEAR" ,
  "Year" = "" ,
  "Start Date" = "CURDATE" ,
  "End Date" = "CURDATE" ,
  "Report Printing Options" = "SUM_PS" ,
  "Quality Measure" = "" ,
  "Organization" = - (1 ) ,
  "Filter EP List" = "ALL" ,
  "Eligible Provider" = 0 ,
  "Filter Measures" = "-1" ,
  "Quarter Start Date" = "" ,
  "QRDA Mode" = "NQF" ,
  "Report By" = "INDV"
  WITH outdev ,optinitiative ,year ,start_dt ,end_dt ,chksummaryonly ,lstmeasure ,orgfilter ,
  epfilter ,lsteligbleprovider ,brdefmeas ,dt_quarter_year ,qrdamode ,reportby
  */
  
free set t_rec
record t_rec
(
	1 cnt					= i4
	1 custom_code_set		= i4
	1 code_value_cnt		= i2
	1 code_value_qual[*]
	 2 code_value			= f8
	 2 npi					= vc
	 2 name					= vc
	1 merged
	 2 full_path			= vc
	 2 short_path			= vc
	 2 filename				= vc
	 2 command				= vc
	1 param_program			= vc
	1 report_program		= vc
	1 parser_param			= vc
	1 1_outdev				= vc
	1 2_optinitiative 		= vc
	1 3_year				= vc 
	1 4_start_dt			= vc
	1 5_end_dt				= vc
	1 6_chksummaryonly		= vc
	1 7_lstmeasure			= vc
	1 8_orgfilter			= i2
	1 9_epfilter			= vc
	1 10_lsteligbleprovider = vc
	1 11_brdefmeas			= vc
	1 12_dt_quarter_year	= vc
	1 13_qrdamode			= vc
	1 14_reportby			= vc 
	1 batch_size			= i2
	1 batch_cnt				= i2
	1 batch_qual[*]
	 2 batch_num			= i2
	 2 prov_cnt				= i2
	 2 prov_qual[*]
	  3 br_eligible_provider_id = f8
	1 prov_cnt				= i2
	1 prov_qual[*]
	 2 br_eligible_provider_id	= f8
	 2 npi					= vc
	 2 tax					= vc
	 2 person_id			= f8
	1 file_cnt				= i2
	1 file_qual[*]
	 2 filename				= vc
	 2 merge_command		= vc
	 2 remove_command		= vc
)

RECORD params (
    1 outdev = vc
    1 epfilter = vc
    1 orgfilter = i4
    1 optinitiative = vc
    1 year = vc
    1 start_dt = dq8
    1 end_dt = dq8
    1 quarter_year_month = vc
    1 brdefmeas = vc
    1 chksummaryonly = vc
    1 payerfilter = vc
    1 qrdamode = vc
    1 measure_cnt = i4
    1 measure_string = vc
    1 report_by = vc
    1 measures [* ]
      2 mean = vc
    1 grp_cnt = i4
    1 grps [* ]
      2 br_gpro_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 logical_domain_id = f8
      2 measure_cnt = i4
      2 measure_string = vc
      2 measures [* ]
        3 mean = vc
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 npi_nbr_txt = vc
      2 tax_id_nbr_txt = vc
      2 include_ind = i2
      2 name = vc
      2 logical_domain_id = f8
      2 measure_cnt = i4
      2 measure_string = vc
      2 measures [* ]
        3 mean = vc
  ) WITH public
  
;call addEmailLog("chad.cummings@covhlth.com")
;call addEmailLog("kswallow@CovHlth.com")


select into "nl:"
from 
	code_value_set cvs
plan cvs
	where cvs.definition = "MIPS Eligible Clinicians"
order by
	cvs.updt_dt_tm
detail
	t_rec->custom_code_set = cvs.code_set
with nocounter

select into "nl:"
from 
	code_value cv
plan cv
	where cv.code_set = t_rec->custom_code_set
	and   cv.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between cv.begin_effective_dt_tm and cv.end_effective_dt_tm
order by
	 cv.display
	,cv.definition
	,cv.code_value
head cv.code_value
	t_rec->code_value_cnt = (t_rec->code_value_cnt + 1)
	stat = alterlist(t_rec->code_value_qual,t_rec->code_value_cnt)
	t_rec->code_value_qual[t_rec->code_value_cnt].code_value = cv.code_value
	t_rec->code_value_qual[t_rec->code_value_cnt].npi = cv.definition
	t_rec->code_value_qual[t_rec->code_value_cnt].name = cv.display
with nocounter

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Build Parameters ***********************************"))

set t_rec->batch_size				= 300

set t_rec->report_program 			= ^lh_amb_ops_NQF2019_report^
set t_rec->param_program			= ^lh_amb_report_nqf2019_param^

set t_rec->1_outdev					= ^MINE^
set t_rec->2_optinitiative			= ^CUSTTF^
set t_rec->3_year					= ^^
;set t_rec->4_start_dt				= ^01-JAN-2020^
;set t_rec->5_end_dt				= ^31-DEC-2020^
set t_rec->4_start_dt				= ^01-JAN-2020^
;set t_rec->5_end_dt					= ^01-JUN-2020^
set t_rec->5_end_dt					= format(datetimefind(cnvtdatetime(CURDATE-1, 0),'D','B','E'),"DD-MMM-YYYY;;q")
set t_rec->6_chksummaryonly			= ^SUM_CSV^
set t_rec->7_lstmeasure				= concat(^value(^,
											^"MU_EC_0018_2019",^,
											^"MU_EC_0022_2019",^,
											^"MU_EC_0028_2019",^,
											^"MU_EC_0034_2019",^,
											^"MU_EC_0041_2019",^,
											^"MU_EC_0055_2019",^,
											^"MU_EC_0059_2019",^,
											^"MU_EC_0062_2019",^,
											^"MU_EC_0069_2019",^,
											^"MU_EC_0070_2019",^,
											^"MU_EC_0081_2019",^,
											^"MU_EC_0083_2019",^,
											^"MU_EC_0101_2019",^,
											^"MU_EC_0419_2019",^,
											^"MU_EC_0421_2019",^,
											^"MU_EC_2372_2019",^,
											^"MU_EC_CMS22_2019",^,
											^"MU_EC_CMS50_2019",^,
											^"MU_EC_CMS127_2019"^,
											^)^)
set t_rec->8_orgfilter				= -1
set t_rec->9_epfilter				= ^ALL^
set t_rec->10_lsteligbleprovider	= concat(^value(^,cnvtstring(-1),^)^)
set t_rec->11_brdefmeas				= ^-1^
set t_rec->12_dt_quarter_year		= ^^
set t_rec->13_qrdamode				= ^NQF^
set t_rec->14_reportby				= ^INDV^

set t_rec->merged.filename 		= concat("cov_nqf2019_ops_" ,format(cnvtdatetime(curdate,curtime3),"MMDDYYYY_HHMMSS;;q"),".csv")
set t_rec->merged.full_path 	= program_log->files.file_path
set t_rec->merged.short_path 	= "cclscratch:"
       
call writeLog(build2("* END   Build Parameters ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Providers ***********************************"))

select into "nl:"
from
	 br_eligible_provider bep
    ,prsnl p
    ,(dummyt d1 with seq=t_rec->code_value_cnt)
plan d1
join bep
	where bep.national_provider_nbr_txt = t_rec->code_value_qual[d1.seq].npi
join p
	where p.person_id = bep.provider_id
order by
	 p.name_full_formatted
	,bep.br_eligible_provider_id
head report
	cnt = 0
head bep.br_eligible_provider_id
	t_rec->prov_cnt = (t_rec->prov_cnt + 1)
	stat = alterlist(t_rec->prov_qual,t_rec->prov_cnt)
	t_rec->prov_qual[t_rec->prov_cnt].br_eligible_provider_id = bep.br_eligible_provider_id
	t_rec->prov_qual[t_rec->prov_cnt].npi = bep.national_provider_nbr_txt
	t_rec->prov_qual[t_rec->prov_cnt].tax = bep.tax_id_nbr_txt
	t_rec->prov_qual[t_rec->prov_cnt].person_id = p.person_id
foot report
	cnt = 0
with nocounter

call writeLog(build2("* END   Adding Providers ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Build Batches **************************************"))

if (t_rec->batch_cnt = 0)
	set t_rec->batch_cnt = (t_rec->batch_cnt + 1)
	set stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
endif
	
for (i=1 to t_rec->prov_cnt)
	set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = (t_rec->batch_qual[t_rec->batch_cnt].prov_cnt + 1)
	if (t_rec->batch_qual[t_rec->batch_cnt].prov_cnt > t_rec->batch_size)
		set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = t_rec->batch_size
		set t_rec->batch_cnt = (t_rec->batch_cnt + 1)
		set stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
		set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = 1
	endif
	set stat = alterlist(t_rec->batch_qual[t_rec->batch_cnt].prov_qual,t_rec->batch_qual[t_rec->batch_cnt].prov_cnt)
	set t_rec->batch_qual[t_rec->batch_cnt].prov_qual[t_rec->batch_qual[t_rec->batch_cnt].prov_cnt].br_eligible_provider_id 
		= t_rec->prov_qual[i].br_eligible_provider_id
endfor

call writeLog(build2("* START Build Batches **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Running Reports ************************************"))

for (i=1 to t_rec->batch_cnt)
 
 set t_rec->10_lsteligbleprovider	= concat(^value(^)
 for (j=1 to t_rec->batch_qual[i].prov_cnt)
  if (t_rec->batch_qual[i].prov_qual[j].br_eligible_provider_id > 0.0)
 	if (j=1)
 		set t_rec->10_lsteligbleprovider = concat(t_rec->10_lsteligbleprovider,cnvtstring(t_rec->batch_qual[i].prov_qual[j].
 		br_eligible_provider_id,20,2))
 	else
 		set t_rec->10_lsteligbleprovider = concat(t_rec->10_lsteligbleprovider,^,^,cnvtstring(t_rec->batch_qual[i].prov_qual[j].
 		br_eligible_provider_id,20,2))
 	endif 
  endif
 endfor
 set t_rec->10_lsteligbleprovider	= concat(t_rec->10_lsteligbleprovider,^)^)
 set t_rec->parser_param = concat(
						 			"execute "
									,trim(t_rec->param_program),					" "
									,"^",trim(t_rec->1_outdev),"^",					","
									,"^",trim(t_rec->2_optinitiative),"^",			","
									,"^",trim(t_rec->3_year),"^",					","
									,"^",trim(t_rec->4_start_dt),"^",				","
									,"^",trim(t_rec->5_end_dt),"^",					","
									,"^",trim(t_rec->6_chksummaryonly),"^",			","
									,trim(t_rec->7_lstmeasure),						","
									,trim(cnvtstring(t_rec->8_orgfilter)),			","
									,"^",trim(t_rec->9_epfilter),"^",				","
									,trim(t_rec->10_lsteligbleprovider),			","
									,"^",trim(t_rec->11_brdefmeas),"^",				","					
									,"^",trim(t_rec->12_dt_quarter_year),"^",		","
									,"^",trim(t_rec->13_qrdamode),"^",				","
									,"^",trim(t_rec->14_reportby),"^"				
									," go"
								)
 set trace server 1 
 call writeLog(build2("running-->",t_rec->parser_param))
 call parser(t_rec->parser_param)
	
 set stat = initrec(params)
 call parser(concat("execute ",t_rec->report_program," go"))
 set trace server 2
	
 call writeLog(build2("-->",cnvtrectojson(params))) 
	
 set t_rec->file_cnt = (t_rec->file_cnt + 1)
 set stat = alterlist(t_rec->file_qual,t_rec->file_cnt)
 set t_rec->file_qual[t_rec->file_cnt].filename = params->outdev
 call addAttachment(program_log->files.ccluserdir,params->outdev)

endfor


call writeLog(build2("* END   Running Reports ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Merging Files **************************************"))
if (t_rec->file_cnt > 0)
	for (i=1 to t_rec->file_cnt)
	 if (t_rec->file_qual[i].filename > " ")
		call writeLog(build2("->adding file:",t_rec->file_qual[i].filename))
		set t_rec->file_qual[i].merge_command = concat(
				^cat ^	,trim(program_log->files.ccluserdir),trim(t_rec->file_qual[i].filename)
						,^ >> ^
						,trim(t_rec->merged.full_path),trim(t_rec->merged.filename)
				)
		set t_rec->file_qual[i].remove_command = concat(
				^rm ^	,trim(program_log->files.ccluserdir),trim(t_rec->file_qual[i].filename)
				)
		call writeLog(build2("->merge command:",t_rec->file_qual[i].merge_command))
		call writeLog(build2("->remove command:",t_rec->file_qual[i].remove_command))
		call dcl(t_rec->file_qual[i].merge_command,size(trim(t_rec->file_qual[i].merge_command)),stat)
		;call dcl(t_rec->file_qual[i].remove_command,size(trim(t_rec->file_qual[i].remove_command)),stat)
	 endif
	endfor
	call addAttachment(t_rec->merged.full_path,t_rec->merged.filename)
endif	
call writeLog(build2("* END   Merging Files **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

if (validate(t_rec))
	call writeLog(build2(cnvtrectojson(t_rec))) 
endif
if (validate(request))
	call writeLog(build2(cnvtrectojson(request))) 
endif
if (validate(reqinfo))
	call writeLog(build2(cnvtrectojson(reqinfo))) 
endif
if (validate(reply))
	call writeLog(build2(cnvtrectojson(reply))) 
endif
if (validate(program_log))
	call writeLog(build2(cnvtrectojson(program_log)))
endif

#exit_script
call exitScript(null)
for (i=1 to t_rec->file_cnt)
 if (t_rec->file_qual[i].filename > " ")
	call dcl(t_rec->file_qual[i].remove_command,size(trim(t_rec->file_qual[i].remove_command)),stat)
 endif
endfor
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

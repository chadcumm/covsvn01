/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/22/2020
	Solution:				
	Source file name:	 	cov_provider_handoff_print.prg
	Object name:		   	cov_provider_handoff_print
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/22/2020  Chad Cummings			Initial Deployment
******************************************************************************/
drop program cov_provider_handoff_print go
create program cov_provider_handoff_print

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Simple or Detail" = 1
	, "Patient List" = 0
	, "Care Team" = 0 

with OUTDEV, REPORT_TYPE, PATIENT_LIST, CARE_TEAM 


declare debug_ind = i2 with noconstant(1) 

;execute mp_write_app_ini ^MINE^,16908168.0,'600005','Handoff_Print',^^,0 go
;execute MP_PHYS_HAND_PRINT_DRIVER ^MINE^,16908168.0,                0, 0, -1, ^^,1 go

free record t_rec
record t_rec
(
	1 person_id = f8
	1 application_num = i4
	1 section = vc
	1 parameters = vc
	1 filepath = vc
	1 output = vc
	1 detail_ind = i2
	1 server_ind = i2
	1 unified_content = vc
	1 web_server = vc 
)

set t_rec->person_id = reqinfo->updt_id
set t_rec->application_num = 600005
set t_rec->section = "Handoff_Print"
set t_rec->output = "cmc6.out"

set t_rec->filepath = "ccluserdir:handoff_print.json" 
set t_rec->filepath = "ccluserdir:handoff_det_print.json" 
;set t_rec->filepath = "ccluserdir:handoff_template_select.json" 
;set t_rec->filepath = "ccluserdir:cust_handoff_print.json" 

set t_rec->detail_ind = $REPORT_TYPE
set t_rec->server_ind = 1

if (t_rec->server_ind = 1)
	set t_rec->unified_content = "http://104.170.114.248/mpage-content/UnifiedContent"
	set t_rec->web_server = "http://104.170.114.248/mpage-content/c0665.chs_tn.cernerasp.com/"
endif

free set requestin 
declare line_in = vc 
free define rtl3 
define rtl3 is t_rec->filepath 
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter 

set stat = cnvtjsontorec(line_in) 
call echorecord(PRINT_OPTIONS)

set t_rec->parameters = line_in

declare detailFlag = f8 with public
declare printTemplate = vc with public
free record _memory_reply_string
declare _memory_reply_string = vc with public


execute mp_write_app_ini 
	 ^MINE^
	,value(t_rec->person_id)					;Provider ID
	,value(cnvtstring(t_rec->application_num))	;Application
	,value(t_rec->section)						;Section
	,value(t_rec->parameters)					;Param Data
	,1											;MPages Utilities EJS cache teamNamespace

/*
$OUTDEV :: "Output to File/Printer/MINE" :: "MINE"
$PERSONID :: "Person Id:" :: 0.0
$DETAILFLAG :: "Detail Flag:" :: ""
$CARETEAMLISTTYPE :: "Care Team List Type" :: 0
$CROSSENCOUNTERIPASS :: "Cross Encounter Ipass" :: 0
$GROUPTYPE :: "Group Type" :: "NONE"
$GETPATLOC :: "Retrieve Patient Location" :: 0
$OVERRIDEUNIFIEDCONTENT :: "Override Unified Content Path" :: ""
$OVERRIDEWEBSERVERURL :: "Override Worklist Content Path" :: ""
$I18NOVERRIDE :: "i18n Override" :: ""
$RETAINPRINTDATA :: "Retain print data from Application_ini" :: 0
*/

if (t_rec->detail_ind = 1)
	execute mp_phys_hand_print_driver 
	 ^MINE^
	,value(t_rec->person_id)		;"Person Id:" = 0.0
	,t_rec->detail_ind				;"Detail Flag:" = ""
	,0								;"Care Team List Type" = 0
	,-1								;"Cross Encounter Ipass" = 0
	,^^								;"Group Type" = "NONE"
	,1								;"Retrieve Patient Location" = 0
	,t_rec->unified_content	;"Override Unified Content Path" = "" 
	,t_rec->web_server		;"Override Worklist Content Path" = ""
	,^^
	,1
	
	call echo(build2("detailFlag=",detailFlag))
	call echo(build2("printTemplate=",printTemplate))
	call echo(build2("_memory_reply_string=",_memory_reply_string))

	free record putREQUEST
		record putREQUEST (
			1 source_dir = vc
			1 source_filename = vc
			1 nbrlines = i4
			1 line [*]
				2 lineData = vc
			1 OverFlowPage [*]
				2 ofr_qual [*]
					3 ofr_line = vc
			1 IsBlob = c1
			1 document_size = i4
			1 document = gvc
		)
 
		; Set parameters for displaying the file
		set putRequest->source_dir = $outdev
		;set putRequest->source_filename = t_rec->output
		set putRequest->IsBlob = "1"
		set putRequest->document = trim(_memory_reply_string)
		set putRequest->document_size = size(putRequest->document)
 
		;  Display the file.  This allows XmlCclRequest to receive the output
		execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
else
	execute mp_phys_hand_print_driver 
	 $OUTDEV
	,value(t_rec->person_id)		;"Person Id:" = 0.0
	,t_rec->detail_ind				;"Detail Flag:" = ""
	,0								;"Care Team List Type" = 0
	,-1								;"Cross Encounter Ipass" = 0
	,^^								;"Group Type" = "NONE"
	,1								;"Retrieve Patient Location" = 0
	,^^								;"Override Unified Content Path" = "" 
	,^^								;"Override Worklist Content Path" = ""
endif

call echorecord(t_reC)
end go

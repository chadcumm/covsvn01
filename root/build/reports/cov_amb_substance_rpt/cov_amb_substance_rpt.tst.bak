/*
;OPERATIONS -> sys_runccl (4903)

free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go

Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go

set request->batch_selection = "cov_amb_substance_rpt Crossville,FSR,PW" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go

execute sys_runccl go

call echorecord(reply) go

/*


free record request go
record request (
  1 program_name = vc
  1 query_command = vc
  1 output_device = vc
  1 Is_printer = i1
  1 Is_Odbc = i1
  1 IsBlob = i1
  1 params = vcl
  1 qual[*]
    2 parameter = vc
    2 data_type = i1
  1 blob_in = gvc
) go

set request->program_name = "CCL_TEMPLATE" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go

execute VCCL_RUN_PROGRAM go
*/
set debug_ind = 1 go
execute cov_amb_substance_lyt 
	;"MINE", VALUE("Crossville","Cross Fairfield","CROSS OBGYN","Cross Walk-in"), 
	; "01-OCT-2019 00:00:00", "29-OCT-2019 23:59:00"
; "MINE", VALUE("Fam Clin Oak"), "15-DEC-2019 00:00:00", "17-DEC-2019 23:59:00"
; ,1, 0
;"MINE", VALUE("Fam Clin Oak"), "11-DEC-2019 00:00:00", "16-DEC-2019 23:59:00", 0, 1, 0
"MINE", "S", VALUE("Southern Medical Group","Topside Phys"), "14-JAN-2021 00:00:00", "14-JAN-2021 23:59:00", 0
  go


/*
set debug_ind = 1 go
execute cov_amb_substance_rpt 
"MINE", "S", 
VALUE("CAET","CH Virtual Care","Claib Card"
,"Claib Med Assoc","Claib Pri Care","Clinton Family","Convenient Care"
,"Crossville","Ctr Reprod Med","Cumb Diabetes","Cumb Neurology"
,"Cumb Neurosurg","Cumb Ortho","Cumb Spec","ET Orthopedics"
,"ET Urology","ETCVS","Endocrine","FS Neurosur","FS Weight Nutr"
,"Fam Clin Oak","FamilyCare","Ft Loudoun PC","Great Smokies","Hamb Pul"
,"Hamb Urology","Hamblen Primary","HealthWorks","Hookman Card","Int Med Assoc"
,"Int Med West","JTV","Kingston Family","Knox Digest Con","Knox Hrt Center"
,"Knox Hrt Group","Knox Neuro Spec","Lakeway Ortho","LeConte Cardio","LeConte Pulmon"
,"LeConte Surg","Lenoir Medical","MORRIS FAMILY","McNeeley Family","Med Assc Carter"
,"Miriam Tedder","Mtn View","Neurohospital","New Horizon","OR Gastro","OR Surgeons"
,"OliverSprings","Parkway Neuro","Phys and Rehab","Pinnacle Neuro","Pkwy Card","Prompt"
,"ROANE SURG GRP","Roane County","Roane Pulmonary","Sevier Wellness","Smoky Mtn Ortho"
,"Southern Medical Group","Surgical Assoc","TN Brain","Topside Phys"
,"Uro Sp ET","West Lake Surg"), "01-JAN-2021 00:00:00", "31-JAN-2021 23:59:00", 0
go
*/

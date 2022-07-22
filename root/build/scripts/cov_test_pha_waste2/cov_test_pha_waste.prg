drop program cov_test_pha_waste2 go
create program cov_test_pha_waste2

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN


free record request 
free record reply 
 
record request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[3]
     2 id = f8
     2 action = vc     ; code set 21 cdf_meaning
     2 status = vc     ; code set 103 cdf_meanings
   1 mediaObjects[*]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
)
 
record reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
free set t_rec
record t_rec
(
	1 person_id = f8
	1 encntr_id = f8
	1 event_cd = f8
	1 ppr_cd = f8
	1 prsnl_id = f8
)
 
set t_Rec->prsnl_id = reqinfo->updt_id
;set t_rec->event_cd =     3713594.00 ;History and Physical
 
select into "nl:"
	 ea.alias
	,p.name_full_formatted
	,e.person_id
	,e.encntr_id
from
	encntr_alias ea
	,encounter e
	,person p
	,encntr_prsnl_reltn epr
plan ea
	where ea.alias = $FIN
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
join epr
	where epr.encntr_id = outerjoin(e.encntr_id)
	and   epr.prsnl_person_id = outerjoin(t_rec->prsnl_id)
detail
	t_rec->encntr_id = e.encntr_id
	t_rec->person_id = e.person_id
	t_rec->ppr_cd = epr.encntr_prsnl_r_cd

 
;	ALIAS	NAME_FULL_FORMATTED	PERSON_ID	ENCNTR_ID
;	1812900019	ZZZREGRESSION, HIM	   18245785.00	  114691850.00
 
;declare CURRENT_DATE_TIME = dq8 with constant(cnvtdatetime(curdate, curtime3)), protect
set request->service_dt_tm = cnvtdatetime(curdate, curtime3) ;
; cnvtdatetime ("01-MAY-2013") ;("29-APR-2013") ;cnvtdatetime(curdate, curtime3) ; cnvtdatetime ("08-MAR-2013 08:30:00")
;set request->mediaObjects[1]->display = 'Attachment 3A'
;set request->mediaObjects[1]->identifier = '{2a-1a-ea-b1-86-2c-4c-2e-80-43-fe-74-e2-f2-9d-37}'
;set request->mediaObjectGroups[1]->identifier = '{2a-1a-ea-b1-86-2c-4c-2e-80-43-fe-74-e2-f2-9d-37}'
;set request->mediaObjectGroups[1]->identifier = ''
 
set request->documenttype_key = 'PHARMACYWASTAGTEXT'
; DISCHARGESUMMARYBEENDOCUMENTED' ;DISCHARGESUMMARY' ; 1HRFIXEDBALANCETOTAL' ;code set 72  DISCHARGESUMMARY
; 3155230697.00	         72		Pharmacy Wastag-Text	PHARMACYWASTAGTEXT
set request->personId = t_rec->person_id
set request->encounterId =    t_rec->encntr_id
set request->title = nullterm('Pharmacy Wastage')
set request->notetext = nullterm("Waste Quantity: 0.3 EA")
set request->noteformat = '' ; code set 23 cdf_meaning
set request->personnel[1]->id =   t_Rec->prsnl_id
set request->personnel[1]->action = 'PERFORM'  ; perform code set 21 cdf_meaning
set request->personnel[1]->status = 'COMPLETED'  ; completed code set 103 cdf_meaning
set request->personnel[2]->id =  t_Rec->prsnl_id
set request->personnel[2]->action = 'SIGN' ; 107  ; perform code set 21
set request->personnel[2]->status = 'COMPLETED'  ; completed code set 103
set request->personnel[3]->id =    t_Rec->prsnl_id
set request->personnel[3]->action = 'VERIFY' ;112  ; perform code set 21
set request->personnel[3]->status = 'COMPLETED'  ; 653.00  ; completed code set 103

set request->publishAsNote=0 
set request->debug=1 
 
execute mmf_publish_ce 
call echorecord(reply) 

select into $OUTDEV
	 status=reply->status_data.status
	,event_id=reply->parentEventId
	,operation=reply->status_data.subeventstatus.OperationName
	,target=reply->status_data.subeventstatus.TargetObjectValue
from dummyt d1
with nocoutner,format,separator=" "


end go

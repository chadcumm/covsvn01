free set t_rec go
record t_rec
(
	1 person_id = f8
	1 encntr_id = f8
	1 event_cd = f8
	1 ppr_cd = f8
	1 prsnl_id = f8
	1 identifier = vc
) go

set t_Rec->prsnl_id = reqinfo->updt_id go
set t_rec->event_cd =     3713594.00 go ;History and Physical

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
	where ea.alias = "1812900019"
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
go

call echorecord(t_rec) go
;	ALIAS	NAME_FULL_FORMATTED	PERSON_ID	ENCNTR_ID
;	1812900019	ZZZREGRESSION, HIM	   18245785.00	  114691850.00

/*
Description of [dms_add_media_instance, 2600]
   protocol:     RR
   binding:      CPMScript
   modified by:  cerjrq [18 Oct 2011]
   
[request]
   filename        [String: Variable] ;full path to file
   contentType	   [String: Variable]
   mediaType       [String: Variable]
   name	           [String: Variable] ; name 
   personId       [Double]
   encounterId    [Double]

[reply]
   <dynamic>
*/
free record mmf_store_reply go
record mmf_store_reply
(
   1 identifier = vc ; unique identifier if successfully stored
%i cclsource:status_block.inc
) go

free set mmf_store_request go
record mmf_store_request
(
   1 filename = vc
   1 contentType = vc
   1 mediaType = vc
   1 name = vc
   1 personId = f8
   1 encounterId = f8
) go
set mmf_store_request->filename = "/cerner/d_b0665/ccluserdir/test.pdf" go

;set request->filename = "/cerner/d_b0665/ccluserdir/covambormreq04_1175739098.dat" go
set mmf_store_request->mediatype = "application/pdf" go
;set request->mediatype = "application/postscript" go
;set request->mediatype = "text/plain" go
set mmf_store_request->contenttype = "REQUISITIONS" go
set mmf_store_request->name = concat("Order Requisition ",trim(format(sysdate,";;q"))) go
set mmf_store_request->personid = t_rec->person_id go
set mmf_store_request->encounterid = t_rec->encntr_id go

call echorecord(request) go
execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request) , replace("REPLY",mmf_store_reply) go
set t_rec->identifier = mmf_store_reply->identifier go

/*
execute mp_clinical_note "MINE",t_rec->person_id,t_rec->encntr_id,
	t_rec->prsnl_id,"",
	t_rec->event_cd,concat("H&P WA ",format(sysdate,";;q")),t_rec->ppr_cd,0 go
execute pex_disp_pulse_gen_episode_doc "MINE",value(t_rec->identifier) go


execute mp_clinical_note "MINE",t_rec->person_id,t_rec->encntr_id,
	t_rec->prsnl_id,value(t_rec->identifier),
	t_rec->event_cd,concat("H&P WA ",format(sysdate,";;q")),t_rec->ppr_cd,1 go

execute mp_add_document 	^MINE^
						,	t_rec->person_id
						,	t_rec->prsnl_id
						,	t_rec->encntr_id
						,	t_rec->event_cd
						,	concat("H&P ",format(sysdate,";;q"))
						,	t_rec->identifier
						,	t_rec->ppr_cd go
						*/

call echo("ADDING CE") go
free record mmf_publish_ce_request go
free record mmf_publish_ce_reply go
 
record mmf_publish_ce_request
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
   1 mediaObjects[1]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
) go
 
record mmf_publish_ce_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
) go
set mmf_publish_ce_request->service_dt_tm = cnvtdatetime(curdate, curtime3) go  ;
; cnvtdatetime ("01-MAY-2013") go ;("29-APR-2013") go ;cnvtdatetime(curdate, curtime3) go ; cnvtdatetime ("08-MAR-2013 08:30:00") go
set mmf_publish_ce_request->mediaObjects[1]->display = Concat('Order Requisition ',trim(format(sysdate,";;q"))) go
set mmf_publish_ce_request->mediaObjects[1]->identifier = t_rec->identifier go
 
set mmf_publish_ce_request->documenttype_key = 'PHYSICIANORDER' go
set mmf_publish_ce_request->personId = t_rec->person_id go
set mmf_publish_ce_request->encounterId =  t_Rec->encntr_id go
set mmf_publish_ce_request->title = nullterm('Order Requisition')  go
set mmf_publish_ce_request->notetext = nullterm('The attached document is the order requisition') go
set mmf_publish_ce_request->noteformat = 'AS' go  ; code set 23 cdf_meaning go
set mmf_publish_ce_request->personnel[1]->id = 2.0 go
set mmf_publish_ce_request->personnel[1]->action = 'PERFORM' go  ; perform code set 21 cdf_meaning
set mmf_publish_ce_request->personnel[1]->status = 'COMPLETED' go   ; completed code set 103 cdf_meaning
set mmf_publish_ce_request->personnel[2]->id =    2.00  go
set mmf_publish_ce_request->personnel[2]->action = 'SIGN' go  ; 107  go ; perform code set 21
set mmf_publish_ce_request->personnel[2]->status = 'COMPLETED' go   ; completed code set 103
set mmf_publish_ce_request->personnel[3]->id =    2.00 go
set mmf_publish_ce_request->personnel[3]->action = 'VERIFY' go  ;112  go ; perform code set 21
set mmf_publish_ce_request->personnel[3]->status = 'COMPLETED' go   ; 653.00 go  ; completed code set 103
set mmf_publish_ce_request->publishAsNote=0  go;
set mmf_publish_ce_request->debug=1  go;
 
execute mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request), replace("REPLY",mmf_publish_ce_reply) go
call echorecord(mmf_publish_ce_reply) go

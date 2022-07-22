1)translate NDSC_GET_EXAM_INFO go
;*** Generated by TRANSLATE, verify before re-including (Debug:N, Optimize:N) ***
DROP PROGRAM ndsc_get_exam_info :dba GO
CREATE PROGRAM ndsc_get_exam_info :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "ExamID" = ""
  WITH outdev ,examid
 FREE RECORD examinfo
 RECORD examinfo (
   1 mnemonic = vc
   1 synonym_code = f8
   1 catalog_code = f8
   1 oe_format_id = f8
 )
 RECORD json (
   1 data = vc
 )
 DECLARE synonymid = f8 WITH public ,constant (cnvtreal ( $EXAMID ) )
 SELECT INTO "nl:"
  ocs.catalog_cd ,
  ocs.mnemonic ,
  ocs.oe_format_id ,
  ocs.synonym_id
  FROM (order_catalog_synonym ocs )
  WHERE (ocs.synonym_id = synonymid )
  AND (ocs.active_ind = 1 )
  ORDER BY ocs.catalog_cd
  DETAIL
   examinfo->mnemonic = ocs.mnemonic ,
   examinfo->synonym_code = ocs.synonym_id ,
   examinfo->catalog_code = ocs.catalog_cd ,
   examinfo->oe_format_id = ocs.oe_format_id
  WITH nocounter
 ;end select
 IF ((examinfo->mnemonic != "" ) )
  SET json->data = cnvtrectojson (examinfo ,2 )
  SET json->data = replace (json->data ,'{"examInfo":' ,"" ,0 )
  SET json->data = replace (json->data ,'{"EXAMINFO":' ,"" ,0 )
  SET json->data = replace (json->data ,'{"examinfo":' ,"" ,0 )
  SET json->data = trim (replace (json->data ,"}" ,"" ,2 ) ,3 )
 ELSE
  SET json->data = "No Results"
 ENDIF
 RECORD putrequest (
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line [* ]
     2 linedata = vc
   1 overflowpage [* ]
     2 ofr_qual [* ]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 SET putrequest->source_dir =  $OUTDEV
 SET putrequest->isblob = "1"
 SET putrequest->document = json->data
 SET putrequest->document_size = size (putrequest->document )
 EXECUTE eks_put_source WITH replace (request ,putrequest ) ,
 replace (reply ,putreply )
#exit_script
 FREE RECORD json
END GO
1)

191107:162527 CCUMMIN4_DVD11               Cost 0.00 Cpu 0.01 Ela 0.01 Dio   0 O0M0R0 P1R0
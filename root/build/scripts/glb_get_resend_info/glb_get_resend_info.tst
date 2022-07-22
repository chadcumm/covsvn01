free record 250194reply go
free record 250194request go
free 250194request go
record 250194request (
  1 accession = vc  
) go

set 250194request->accession = "000992020220001370" go

set stat = tdbexecute(250032,250143,250194,"REC",250194request,"REC",250194reply) go

call echorecord(250194reply) go


free record tempreq go
record tempreq
(
  1 insert_ind = c1
) go
 
set tempreq->insert_ind = "Y" go

execute dm_dbimport value("CCLUSERDIR:BED_IMP_REQ_ROUTING.CSV"), value("COV_IMP_REQ_ROUTING"), 10000
go

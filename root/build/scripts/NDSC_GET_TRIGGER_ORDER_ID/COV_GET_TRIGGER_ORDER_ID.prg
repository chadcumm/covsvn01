DROP PROGRAM COV_GET_TRIGGER_ORDER_ID :dba GO
CREATE PROGRAM COV_GET_TRIGGER_ORDER_ID :dba
 SET delim_pos = findstring (":" ,streksrepeatcount ,1 ,0 )
 IF ((delim_pos > 0 ) )
  SET idx = cnvtint (trim (substring (1 ,(delim_pos - 1 ) ,streksrepeatcount ) ,3 ) )
 ELSE
  SET idx = cnvtint (streksrepeatcount )
 ENDIF
 SET cclprogram_message = cnvtstring (request->orderlist[idx ].orderid )
 SET cclprogram_status = 1

set stat = alterlist(request->DIAGNOSISLIST,1)
set request->DIAGNOSISLIST[1].dx="13254519" 
free set t_rec	
record t_rec
(
	1 cnt			= i4
	1 filename_b    = vc
)


set t_rec->filename_b = concat("cclscratch:cs_eks_request_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")


if (validate(request))
	call echojson(request, t_rec->filename_b , 0) 
endif

#exit_script
END GO


DROP PROGRAM cov_get_rpt_fac_cd_list :dba GO
CREATE PROGRAM cov_get_rpt_fac_cd_list :dba
 EXECUTE rx_get_facs_for_prsnl_rr_incl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 IF (NOT (validate (reply ,0 ) ) )
  FREE RECORD reply
  RECORD reply (
    1 data [* ]
      2 buffer = vc
  )
 ENDIF
 SET stat = alterlist (prsnl_facs_req->qual ,1 )
 CALL echo (build ("User id --" ,reqinfo->updt_id ) )
 SET prsnl_facs_req->qual[1 ].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 CALL echo (build ("Size of facility list --" ,size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) )
  )
 CALL echorecord (prsnl_facs_reply )
 SELECT
  prsnl_facs_reply->qual[1 ].facility_list[d.seq ].facility_cd ,
  desc = cnvtupper (substring (1 ,75 ,prsnl_facs_reply->qual[1 ].facility_list[d.seq ].description )
   )
  FROM (dummyt d WITH seq = value (size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) ) )
  PLAN (d )
  ORDER BY desc
  HEAD REPORT
   delta = 1000 ,
   columntitle = concat (reportinfo (1 ) ,"$" ) ,
   count = 0 ,
   stat = alterlist (reply->data ,delta ) ,
   CALL echo (build ("info 1 --" ,reportinfo (1 ) ) )
  DETAIL
   count = (count + 1 ) ,
   IF ((mod (count ,delta ) = 1 ) ) stat = alterlist (reply->data ,(count + delta ) )
   ENDIF
   ,
   CALL echo (build ("Reportinfo2 --" ,reportinfo (2 ) ) ) ,
   CALL echo (build ("Facility cd --" ,prsnl_facs_reply->qual[1 ].facility_list[d.seq ].facility_cd
    ) ) ,
   reply->data[count ].buffer = concat (reportinfo (2 ) ,"$" )
  FOOT REPORT
   stat = alterlist (reply->data ,count )
  WITH maxrow = 1 ,reporthelp ,check ,format
 ;end select
 CALL echorecord (reply )
 FREE RECORD prsnl_facs_req
 FREE RECORD prsnl_facs_reply
 CALL echo ("Last Mod = 000" )
 CALL echo ("Mod Date = 03/01/2010" )
END GO

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   dcp_chk_active_preg.prg
  Object name:        dcp_chk_active_preg
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   01/10/2020  Chad Cummings			copied from Cerner standard script
002   01/10/2020  Chad Cummings			added section to look for PF documentation
******************************************************************************/
 
DROP PROGRAM dcp_chk_active_preg GO
CREATE PROGRAM dcp_chk_active_preg
 ;002 free record reply ;002
 RECORD reply (
   1 pregnancy_id = f8
   1 pregnancy_instance_id = f8
   1 onset_dt_tm = dq8
   1 onset_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD temprequest (
   1 patient_list [* ]
     2 patient_id = f8
     2 encntr_id = f8
   1 org_sec_override = i2
 )
 DECLARE stat = i4
 SET stat = alterlist (temprequest->patient_list ,1 )
 SET temprequest->patient_list[1 ].patient_id = request->patient_id
 IF ((validate (request->encntr_id ) = 0 ) )
  SET temprequest->patient_list[1 ].encntr_id = 0
 ELSE
  SET temprequest->patient_list[1 ].encntr_id = request->encntr_id
 ENDIF
 IF ((validate (request->org_sec_override ) = 0 ) )
  SET temprequest->org_sec_override = 0
 ELSE
  SET temprequest->org_sec_override = request->org_sec_override
 ENDIF
 SET reply->status_data.status = "F"

 IF ((request->patient_id = 0.0 ) )
  SET reply->status_data.status = "Z"
  GO TO script_end
 ENDIF
 
 call echo("starting dcp_chk_active_preg_list") ;002
 EXECUTE dcp_chk_active_preg_list WITH replace ("REQUEST" ,temprequest ) , replace ("REPLY" ,tempreply )
 call echo("ending dcp_chk_active_preg_list")	;002


 IF ((tempreply->status_data.status = "F" ) )
  CALL echo ("[FAIL]: DCP_CHK_ACTIVE_PREG_LIST failed" )
  SET reply->status_data.status = "F"
  GO TO script_end
 ELSEIF ((tempreply->status_data.status = "Z" ) )
  CALL echo ("[ZERO]: Active pregnancy could not be found" )
  SET reply->status_data.status = "Z"
  
  
  CALL echo ("[CHECKING]: Pregnancy Status documented as Confirmed positive" )
  
  select into "nl:"
  from
  	clinical_event ce
  plan ce
	where ce.person_id 			= request->patient_id
	and   ce.valid_until_dt_tm  >= cnvtdatetime(curdate, curtime3)
	and   ce.task_assay_cd in(
								value(uar_get_code_by("DISPLAY",14003,"Pregnancy Status"))
							)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.result_val 		in( 
										"Confirmed positive"
								  )
  order by
  	 ce.person_id
  	,ce.event_cd
  	,ce.event_end_dt_tm desc
  head report
  	stat = 0
  head ce.event_cd
  	if (ce.result_val = "Confirmed positive")
  		reply->status_data.status = "S"
  	endif
  with nocounter
 
  GO TO script_end
 ENDIF
 IF ((tempreply->patient_list[1 ].pregnancy_id >= 0 ) )
  SET reply->pregnancy_id = tempreply->patient_list[1 ].pregnancy_id
  SET reply->pregnancy_instance_id = tempreply->patient_list[1 ].pregnancy_instance_id
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   pb.onset_dt_tm ,
   p.person_id ,
   pi.problem_id ,
   pi.person_id ,
   pb.person_id ,
   pb.onset_tz
   FROM (person p ),
    (pregnancy_instance pi ),
    (problem pb )
   PLAN (p
    WHERE (p.person_id = request->patient_id ) )
    JOIN (pi
    WHERE (p.person_id = pi.person_id )
    AND (pi.pregnancy_id = reply->pregnancy_id )
    AND (pi.active_ind = 1 )
    AND (pi.historical_ind = 0 ) )
    JOIN (pb
    WHERE (p.person_id = pb.person_id )
    AND (pi.problem_id = pb.problem_id )
    AND (pb.problem_type_flag = 2 )
    AND (pb.active_ind = 1 ) )
   HEAD REPORT
    reply->onset_dt_tm = pb.onset_dt_tm ,
    reply->onset_tz = pb.onset_tz
   WITH nocounter
  ;end select
 ENDIF
#script_end

;002 start TESTING PATIENT
;SET reply->pregnancy_id 			= 149326134
;SET reply->pregnancy_instance_id 	= 149326134
;SET reply->status_data.status 		= "S"
;set reply->onset_dt_tm 				= cnvtdatetime("2018-12-13 05:00:00.00")
;set reply->onset_tz 				= 126
;002 end TESTING PATIENT


;002 start

/*
>>>Begin EchoRecord REPLY   ;REPLY
 1 PREGNANCY_ID=F8   {149326134.0000000000                    }
 1 PREGNANCY_INSTANCE_ID=F8   {149326134.0000000000                    }
 1 ONSET_DT_TM=DQ8   {69095988000000000    (2018-12-13 05:00:00.00) utc(1)}
 1 ONSET_TZ= I4   {126}
 1 STATUS_DATA
  2 STATUS=C1   {S}
  2 SUBEVENTSTATUS[1]
   3 OPERATIONNAME=C25   {}
   3 OPERATIONSTATUS=C1   {}
   3 TARGETOBJECTNAME=C25   {}
   3 TARGETOBJECTVALUE=VC0   {}
>>>End EchoRecord REPLY Varchar=1, Varlist=0, Fixsize=88, Varsize=88
*/

;002 end

set file_name = concat("cclscratch:dcp_preg_",trim(format(sysdate,"yyyymmddhhmmss;;d")),".dat")
call echojson(reqinfo,file_name)

END GO

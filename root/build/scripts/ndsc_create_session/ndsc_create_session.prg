1)translate ndsc_create_session go
;*** Generated by TRANSLATE, verify before re-including (Debug:N, Optimize:N) ***
DROP PROGRAM ndsc_create_session :dba GO
CREATE PROGRAM ndsc_create_session :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "BASEURL" = "" ,
  "USERNAME" = "" ,
  "PASSWORD" = "" ,
  "FILEPATH" = ""
  WITH outdev ,baseurl ,username ,password ,filepath
 EXECUTE ndsc_common_utility
 EXECUTE ndsc_careselect_api
 DECLARE filepath = vc
 SET filepath =  $FILEPATH
 FREE RECORD ndsclog
 RECORD ndsclog (
   1 message = vc
 ) WITH persistscript
 IF ((filepath != "" ) )
  SET ndsclog->message = build2 ("START Current DateTime " ,format (cnvtdatetime (curdate ,curtime3
     ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
  CALL echojson (ndsclog ,filepath ,1 )
  CALL echojson (request ,filepath ,1 )
  CALL echojson (reqinfo ,filepath ,1 )
 ENDIF
 DECLARE constprimarymnemonictypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6011 ,"PRIMARY"
   ) )
 DECLARE constactivestatuscode = f8 WITH constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
 DECLARE constcompletedtypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"COMPLETED" ) )
 DECLARE constradiologytypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6000 ,"RADIOLOGY" ) )
 DECLARE constpharmacytypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6000 ,"PHARMACY" ) )
 DECLARE constlabtypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6000 ,"GENERAL LAB" ) )
 DECLARE constpatientcaretypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,6000 ,"NURS" ) )
 DECLARE constmrntypecd = f8 WITH constant (uar_get_code_by ("MEANING" ,4 ,"MRN" ) )
 DECLARE stat = i4 WITH noconstant (0 )
 DECLARE strage = vc WITH noconstant ("" )
 DECLARE problemcount = i4 WITH noconstant (0 )
 DECLARE diagnosiscount = i4 WITH noconstant (0 )
 DECLARE orderhistorycount = i4 WITH noconstant (0 )
 DECLARE flowsheetcount = i4 WITH noconstant (0 )
 DECLARE priormedcount = i4 WITH noconstant (0 )
 DECLARE orderdiagnosiscount = i4 WITH noconstant (0 )
 DECLARE administeredmedcount = i4 WITH noconstant (0 )
 DECLARE resultcount = i4 WITH noconstant (0 )
 DECLARE allergycount = i4 WITH noconstant (0 )
 DECLARE str = vc WITH noconstant ("" )
 DECLARE notfnd = vc WITH constant ("<not_found>" )
 DECLARE num = i4 WITH noconstant (1 )
 DECLARE cr = vc WITH noconstant ("," )
 DECLARE qualifiedcount = i4 WITH noconstant (0 )
 DECLARE startindex = i4 WITH noconstant (1 )
 DECLARE catalogmeaning = vc WITH noconstant ("" )
 DECLARE catalogname = vc WITH noconstant ("" )
 DECLARE sessionsvalid = i4 WITH noconstant (0 )
 DECLARE jsonstring = vc WITH noconstant ("" )
 DECLARE jrec = i4 WITH noconstant (0 )
 DECLARE freetextrfevalue = vc WITH noconstant ("" )
 DECLARE dropdownrfevalue = vc WITH noconstant ("" )
 DECLARE orderdetails = vc WITH noconstant ("" )
 DECLARE webserviceusername = vc
 SET webserviceusername =  $USERNAME
 DECLARE webservicepassword = vc
 SET webservicepassword =  $PASSWORD
 DECLARE webservicetoken = vc
 SET webservicetoken = base64_encode (build2 (webserviceusername ,":" ,webservicepassword ) )
 DECLARE baseurl = vc
 SET baseurl =  $BASEURL
 DECLARE strtest = vc
 SET strtest = cnvtrectojson (request )
 FREE RECORD careselectsessioncreationrequest
 RECORD careselectsessioncreationrequest (
   1 patient
     2 gender = vc
     2 ageinyears = i4
     2 class = vc
   1 pointofcare
     2 department
       3 pointofcareid = vc
       3 name = vc
       3 typeid = vc
       3 typename = vc
     2 location
       3 pointofcareid = vc
       3 name = vc
     2 servicearea
       3 pointofcareid = vc
       3 name = vc
     2 organization
       3 pointofcareid = vc
       3 name = vc
   1 encounterdiagnoses [* ]
     2 codes [* ]
       3 codesystem = vc
       3 code = vc
     2 problemname = vc
     2 entereddatetime = vc
     2 startdatetime = vc
     2 enddatetime = vc
     2 status = vc
   1 problemlist [* ]
     2 codes [* ]
       3 codesystem = vc
       3 code = vc
     2 problemname = vc
     2 entereddatetime = vc
     2 startdatetime = vc
     2 enddatetime = vc
     2 status = vc
   1 orderhistory [* ]
     2 codes [* ]
       3 codesystem = vc
       3 code = vc
     2 name = vc
     2 effectivedatetime = vc
     2 componentresults [* ]
       3 codes [* ]
         4 codesystem = vc
         4 code = vc
       3 componentname = vc
       3 effectivedatetime = vc
       3 resultvalue = vc
       3 resultunit = vc
       3 referencerange = vc
       3 status = vc
     2 ordertype = vc
     2 referenceid = vc
     2 narrative = vc
     2 impression = vc
   1 allergies [* ]
     2 codes [* ]
       3 codesystem = vc
       3 code = vc
     2 allergenname = vc
     2 entereddatetime = vc
     2 severity = vc
     2 reactions = vc
     2 status = vc
     2 comments = vc
   1 requestedorders [* ]
     2 orderinformation
       3 orderid = vc
       3 orderinguser
         4 userid = vc
         4 username = vc
         4 providerid = vc
       3 orderingprovider
         4 providerid = vc
         4 firstname = vc
         4 lastname = vc
         4 npi = vc
         4 specialtycode = vc
         4 specialtyname = vc
       3 authorizingprovider
         4 providerid = vc
         4 firstname = vc
         4 lastname = vc
         4 npi = vc
         4 specialtycode = vc
         4 specialtyname = vc
       3 orderspecificquestions [* ]
         4 questionid = vc
         4 description = vc
         4 answer
           5 answerid = vc
           5 answertext = vc
           5 comment = vc
         4 fieldtype = i4
       3 orderdiagnoses [* ]
         4 codes [* ]
           5 codesystem = vc
           5 code = vc
         4 problemname = vc
         4 entereddatetime = vc
         4 startdatetime = vc
         4 enddatetime = vc
         4 status = vc
       3 indicationmodeidentifier = vc
     2 freetextreasonforexam = vc
     2 examid = vc
   1 effectivetime = vc
 ) WITH persistscript
 FREE RECORD session_info
 RECORD session_info (
   1 patient_info
     2 patientmrn = vc
     2 patientbirthdate = vc
     2 patientgender = vc
     2 patientname = vc
     2 patientage = vc
   1 orders [* ]
     2 answeredquestions [* ]
       3 oefieldid = f8
       3 oefieldvalue = f8
       3 oefielddisplayvalue = vc
       3 oefielddttmvalue = vc
       3 oefieldmeaning = vc
     2 orderid = vc
     2 dsn = vc
     2 examid = vc
   1 token = vc
   1 baseurl = vc
   1 siteid = vc
 ) WITH persistscript
 FREE RECORD configuration
 RECORD configuration (
   1 modalitylist [* ]
     2 modalitymeaning = vc
 ) WITH persistscript
 IF ((filepath != "" ) )
  SET ndsclog->message = build2 ("ABOUT TO GET CONFIGS " ,format (cnvtdatetime (curdate ,curtime3 ) ,
    "HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
  CALL echojson (ndsclog ,filepath ,1 )
 ENDIF
 DECLARE configurations = vc
 SET configurations = getconfigs (baseurl ,webservicetoken )
 SET jsonstring = build2 ('{"configs":' ,configurations ,"}" )
 SET jrec = cnvtjsontorec (jsonstring )
 DECLARE rfequestionid = vc
 DECLARE orderdiagnosisquestionid = vc
 DECLARE modalities = vc
 DECLARE rfedropdownquestionid = vc
 SET rfequestionid = configs->configuration.cernerrfequestionid
 SET orderdiagnosisquestionid = configs->configuration.cernerorderdiagnosisquestionid
 SET modalities = configs->configuration.cernermodalitylist
 SET rfedropdownquestionid = configs->configuration.cernerrfedropdownquestionid
 IF ((filepath != "" ) )
  CALL echojson (configs ,filepath ,1 )
  SET ndsclog->message = build2 ("Modalities " ,modalities ," " ,format (cnvtdatetime (curdate ,
     curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,
    "##;RP0" ) )
  CALL echojson (ndsclog ,filepath ,1 )
 ENDIF
 SET str = piece (modalities ,cr ,num ,notfnd )
 WHILE ((str != notfnd ) )
  SET stat = alterlist (configuration->modalitylist ,num )
  SET configuration->modalitylist[num ].modalitymeaning = str
  SET num = (num + 1 )
  SET str = piece (modalities ,cr ,num ,notfnd )
 ENDWHILE
 IF ((num = 1 ) )
  SET stat = alterlist (configuration->modalitylist ,num )
  SET configuration->modalitylist[num ].modalitymeaning = modalities
 ENDIF
 SET session_info->token = webservicetoken
 SET session_info->baseurl = baseurl
 SET num = 0
 FOR (i = 1 TO size (request->orderlist ,5 ) )
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("Order# " ,i ," " ,format (cnvtdatetime (curdate ,curtime3 ) ,
     "HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  SELECT INTO "NL:"
   FROM (order_catalog oc )
   WHERE (oc.catalog_cd = request->orderlist[i ].catalog_code )
   DETAIL
    catalogmeaning = uar_get_code_meaning (oc.activity_subtype_cd ) ,
    catalogname = uar_get_code_display (oc.catalog_cd )
   WITH nocounter
  ;end select
  SET orderdetails = build2 ("OrderId: " ,cnvtstring (request->orderlist[i ].orderid ) ,
   " , SynonymId: " ,cnvtstring (request->orderlist[i ].synonym_code ) ," , CatalogCd: " ,cnvtstring
   (request->orderlist[i ].catalog_code ) ," , Name: " ,catalogname ," , Modality: " ,catalogmeaning
   )
  IF ((filepath != "" ) )
   SET ndsclog->message = orderdetails
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  DECLARE resultval = i4
  SET resultval = locateval (num ,startindex ,size (configuration->modalitylist ,5 ) ,catalogmeaning
   ,configuration->modalitylist[num ].modalitymeaning )
  IF ((resultval != 0 ) )
   IF ((filepath != "" ) )
    SET ndsclog->message = build2 ("Order# " ,i ," Passed Modality Check " ,format (cnvtdatetime (
       curdate ,curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (
       curtime3 ) ,"##;RP0" ) )
    CALL echojson (ndsclog ,filepath ,1 )
   ENDIF
   SET freetextrfevalue = ""
   SET dropdownrfevalue = ""
   SET orderdiagnosiscount = 0
   SET qualifiedcount = (qualifiedcount + 1 )
   SET stat = alterlist (careselectsessioncreationrequest->requestedorders ,qualifiedcount )
   SET stat = alterlist (session_info->orders ,qualifiedcount )
   SET session_info->orders[qualifiedcount ].orderid = cnvtstring (request->orderlist[i ].orderid )
   SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.orderid =
   cnvtstring (request->orderlist[i ].orderid )
   IF ((configs->configuration.cernercachekeyexam != "" )
   AND (cnvtlower (configs->configuration.cernercachekeyexam ) = "true" ) )
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
    indicationmodeidentifier = build2 (trim (cnvtstring (request->person_id ) ,3 ) ,"-" ,trim (
      cnvtstring (request->encntr_id ) ,3 ) ,"-" ,trim (cnvtstring (reqinfo->updt_id ) ,3 ) )
   ELSE
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
    indicationmodeidentifier = build2 (trim (cnvtstring (request->person_id ) ,3 ) ,"-" ,trim (
      cnvtstring (request->encntr_id ) ,3 ) ,"-" ,trim (cnvtstring (reqinfo->updt_id ) ,3 ) ,"-" ,
     trim (cnvtstring (request->orderlist[i ].synonym_code ) ,3 ) )
   ENDIF
   SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
   orderinguser.userid = cnvtstring (reqinfo->updt_id )
   SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].examid = cnvtstring (
    request->orderlist[i ].synonym_code )
   SET session_info->orders[qualifiedcount ].examid = cnvtstring (request->orderlist[i ].synonym_code
     )
   SELECT INTO "NL:"
    FROM (prsnl p )
    WHERE (p.person_id = reqinfo->updt_id )
    DETAIL
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.orderinguser
     .username = trim (p.username ,3 )
    WITH nocounter
   ;end select
   SELECT
    providerid = cnvtstring (p.person_id ) ,
    firstname = p.name_first ,
    lastname = p.name_last ,
    specialtycode = cnvtstring (p.position_cd ) ,
    specialtyname = uar_get_code_display (p.position_cd ) ,
    npi = pa.alias
    FROM (prsnl p ),
     (prsnl_alias pa )
    PLAN (p
     WHERE (p.person_id = request->orderlist[i ].physician ) )
     JOIN (pa
     WHERE (pa.person_id = outerjoin (p.person_id ) ) )
    DETAIL
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.providerid = providerid ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.firstname = firstname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.lastname = lastname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.specialtycode = specialtycode ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.specialtyname = specialtyname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     orderingprovider.npi = npi ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.providerid = providerid ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.firstname = firstname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.lastname = lastname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.specialtycode = specialtycode ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.specialtyname = specialtyname ,
     careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
     authorizingprovider.npi = npi ,
     IF ((providerid = cnvtstring (reqinfo->updt_id ) ) ) careselectsessioncreationrequest->
      requestedorders[qualifiedcount ].orderinformation.orderinguser.providerid = providerid
     ENDIF
    WITH nocounter
   ;end select
   FOR (j = 1 TO size (request->orderlist[i ].detaillist ,5 ) )
    SET stat = alterlist (careselectsessioncreationrequest->requestedorders[qualifiedcount ].
     orderinformation.orderspecificquestions ,j )
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
    orderspecificquestions[j ].questionid = cnvtstring (request->orderlist[i ].detaillist[j ].
     oefieldid )
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
    orderspecificquestions[j ].answer.answerid = cnvtstring (request->orderlist[i ].detaillist[j ].
     oefieldvalue )
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
    orderspecificquestions[j ].answer.answertext = request->orderlist[i ].detaillist[j ].
    oefielddisplayvalue
    SET stat = alterlist (session_info->orders[qualifiedcount ].answeredquestions ,j )
    SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefieldid = request->orderlist[i
    ].detaillist[j ].oefieldid
    SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefieldvalue = request->
    orderlist[i ].detaillist[j ].oefieldvalue
    SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefielddisplayvalue = request->
    orderlist[i ].detaillist[j ].oefielddisplayvalue
    SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefieldmeaning = request->
    orderlist[i ].detaillist[j ].oefieldmeaning
    IF ((request->orderlist[i ].detaillist[j ].oefielddttmvalue > 0 ) )
     SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefielddttmvalue = format (
      cnvtdatetimeutc (request->orderlist[i ].detaillist[j ].oefielddttmvalue ,0 ) ,
      "yyyyMMddhhmmss;;d" )
    ELSE
     SET session_info->orders[qualifiedcount ].answeredquestions[j ].oefielddttmvalue = "0"
    ENDIF
    IF ((cnvtstring (request->orderlist[i ].detaillist[j ].oefieldid ) = orderdiagnosisquestionid )
    )
     SET orderdiagnosiscount = (orderdiagnosiscount + 1 )
     SELECT
      name = n.source_string ,
      enteredtime = format (d.beg_effective_dt_tm ,"MM-DD-YYYY" ) ,
      starttime = format (d.active_status_dt_tm ,"MM-DD-YYYY" ) ,
      endtime = format (d.end_effective_dt_tm ,"MM-DD-YYYY" ) ,
      status = uar_get_code_display (d.active_status_cd ) ,
      code = n.source_identifier ,
      source = uar_get_code_display (n.source_vocabulary_cd )
      FROM (diagnosis d ),
       (nomenclature n )
      PLAN (d
       WHERE (d.person_id = request->person_id )
       AND (d.encntr_id = request->encntr_id )
       AND (d.nomenclature_id = request->orderlist[i ].detaillist[j ].oefieldvalue ) )
       JOIN (n
       WHERE (n.nomenclature_id = d.nomenclature_id ) )
      ORDER BY d.beg_effective_dt_tm DESC
      HEAD d.diagnosis_id
       stat = alterlist (careselectsessioncreationrequest->requestedorders[qualifiedcount ].
        orderinformation.orderdiagnoses ,orderdiagnosiscount ) ,careselectsessioncreationrequest->
       requestedorders[qualifiedcount ].orderinformation.orderdiagnoses[orderdiagnosiscount ].
       problemname = name ,careselectsessioncreationrequest->requestedorders[qualifiedcount ].
       orderinformation.orderdiagnoses[orderdiagnosiscount ].entereddatetime = enteredtime ,
       careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
       orderdiagnoses[orderdiagnosiscount ].startdatetime = starttime ,
       careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
       orderdiagnoses[orderdiagnosiscount ].enddatetime = endtime ,careselectsessioncreationrequest->
       requestedorders[qualifiedcount ].orderinformation.orderdiagnoses[orderdiagnosiscount ].status
       = status ,stat = alterlist (careselectsessioncreationrequest->requestedorders[qualifiedcount ]
        .orderinformation.orderdiagnoses[orderdiagnosiscount ].codes ,1 ) ,
       careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
       orderdiagnoses[orderdiagnosiscount ].codes.codesystem = source ,
       careselectsessioncreationrequest->requestedorders[qualifiedcount ].orderinformation.
       orderdiagnoses[orderdiagnosiscount ].codes.code = code
      WITH nocounter
     ;end select
    ENDIF
    IF ((cnvtstring (request->orderlist[i ].detaillist[j ].oefieldid ) = rfequestionid ) )
     SET freetextrfevalue = request->orderlist[i ].detaillist[j ].oefielddisplayvalue
    ENDIF
    IF ((cnvtstring (request->orderlist[i ].detaillist[j ].oefieldid ) = rfedropdownquestionid ) )
     SET dropdownrfevalue = request->orderlist[i ].detaillist[j ].oefielddisplayvalue
    ENDIF
   ENDFOR
   IF ((freetextrfevalue != "" ) )
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].freetextreasonforexam =
    freetextrfevalue
   ELSE
    SET careselectsessioncreationrequest->requestedorders[qualifiedcount ].freetextreasonforexam =
    dropdownrfevalue
   ENDIF
  ELSE
   IF ((filepath != "" ) )
    SET ndsclog->message = build2 ("Order# " ,i ," Did not pass modality check " ,format (
      cnvtdatetime (curdate ,curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (
      mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
    CALL echojson (ndsclog ,filepath ,1 )
   ENDIF
   SET request->orderlist[i ].actiontypecd = 0.00
  ENDIF
 ENDFOR
 IF ((qualifiedcount != 0 ) )
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("" ,qualifiedcount ," Orders Qualified for Decision Support " ,
    format (cnvtdatetime (curdate ,curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (
     mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  SELECT
   facility_code = cnvtstring (e.loc_facility_cd ) ,
   encounter_display = uar_get_code_display (e.encntr_type_cd ) ,
   department_cd = cnvtstring (e.loc_nurse_unit_cd ) ,
   department_name = uar_get_code_display (e.loc_nurse_unit_cd ) ,
   facility_name = uar_get_code_display (e.loc_facility_cd )
   FROM (encounter e )
   WHERE (e.encntr_id = request->encntr_id )
   DETAIL
    careselectsessioncreationrequest->pointofcare.location.pointofcareid = facility_code ,
    careselectsessioncreationrequest->patient.class = encounter_display ,
    careselectsessioncreationrequest->pointofcare.department.pointofcareid = department_cd ,
    careselectsessioncreationrequest->pointofcare.department.name = department_name ,
    careselectsessioncreationrequest->pointofcare.location.name = facility_name ,
    session_info->siteid = facility_code
   WITH nocounter
  ;end select
  SET modify = cnvtage (1 ,1 ,1 )
  SELECT
   age = cnvtage (p.birth_dt_tm ) ,
   gender = cnvtcap (trim (uar_get_code_display (p.sex_cd ) ,3 ) ) ,
   full_name = p.name_full_formatted ,
   mrn = pa.alias ,
   birth_dt_tm = format (p.birth_dt_tm ,"DD-MMM-YYYY;;D" ) ,
   gender = uar_get_code_display (p.sex_cd )
   FROM (person p ),
    (person_alias pa )
   PLAN (p
    WHERE (p.person_id = request->person_id ) )
    JOIN (pa
    WHERE (p.person_id = pa.person_id )
    AND (pa.person_alias_type_cd = constmrntypecd ) )
   DETAIL
    strage = age ,
    strage = cnvtupper (strage ) ,
    IF ((findstring ("YEARS" ,strage ) = 0 ) ) careselectsessioncreationrequest->patient.ageinyears
     = 0
    ELSE careselectsessioncreationrequest->patient.ageinyears = textlen (strage ) ,
     careselectsessioncreationrequest->patient.ageinyears = (careselectsessioncreationrequest->
     patient.ageinyears - 6 ) ,careselectsessioncreationrequest->patient.ageinyears = cnvtint (
      substring (1 ,careselectsessioncreationrequest->patient.ageinyears ,strage ) )
    ENDIF
    ,careselectsessioncreationrequest->patient.gender = gender ,
    IF ((careselectsessioncreationrequest->patient.gender != "Male" )
    AND (careselectsessioncreationrequest->patient.gender != "Female" ) )
     careselectsessioncreationrequest->patient.gender = "Unknown"
    ENDIF
    ,session_info->patient_info.patientname = full_name ,
    session_info->patient_info.patientmrn = mrn ,
    session_info->patient_info.patientbirthdate = birth_dt_tm ,
    session_info->patient_info.patientgender = gender ,
    session_info->patient_info.patientage = age
   WITH nocounter
  ;end select
  SELECT
   name = n.source_string ,
   enteredtime = format (d.beg_effective_dt_tm ,"MM-DD-YYYY" ) ,
   starttime = format (d.active_status_dt_tm ,"MM-DD-YYYY" ) ,
   endtime = format (d.end_effective_dt_tm ,"MM-DD-YYYY" ) ,
   status = uar_get_code_display (d.active_status_cd ) ,
   code = n.source_identifier ,
   source = uar_get_code_display (n.source_vocabulary_cd )
   FROM (diagnosis d ),
    (nomenclature n )
   PLAN (d
    WHERE (d.person_id = request->person_id )
    AND (d.encntr_id = request->encntr_id )
    AND (d.updt_dt_tm > cnvtdatetime ((curdate - 60 ) ,curtime ) ) )
    JOIN (n
    WHERE (n.nomenclature_id = d.nomenclature_id ) )
   ORDER BY d.beg_effective_dt_tm DESC
   HEAD d.diagnosis_id
    diagnosiscount = (diagnosiscount + 1 ) ,stat = alterlist (careselectsessioncreationrequest->
     encounterdiagnoses ,diagnosiscount ) ,careselectsessioncreationrequest->encounterdiagnoses[
    diagnosiscount ].problemname = name ,careselectsessioncreationrequest->encounterdiagnoses[
    diagnosiscount ].entereddatetime = enteredtime ,careselectsessioncreationrequest->
    encounterdiagnoses[diagnosiscount ].startdatetime = starttime ,careselectsessioncreationrequest->
    encounterdiagnoses[diagnosiscount ].enddatetime = endtime ,careselectsessioncreationrequest->
    encounterdiagnoses[diagnosiscount ].status = status ,stat = alterlist (
     careselectsessioncreationrequest->encounterdiagnoses[diagnosiscount ].codes ,1 ) ,
    careselectsessioncreationrequest->encounterdiagnoses[diagnosiscount ].codes.codesystem = source ,
    careselectsessioncreationrequest->encounterdiagnoses[diagnosiscount ].codes.code = code
   WITH nocounter
  ;end select
  SELECT
   name = n.source_string ,
   enteredtime = format (p.beg_effective_dt_tm ,"MM-DD-YYYY" ) ,
   starttime = format (p.active_status_dt_tm ,"MM-DD-YYYY" ) ,
   endtime = format (p.end_effective_dt_tm ,"MM-DD-YYYY" ) ,
   status = uar_get_code_display (p.active_status_cd ) ,
   code = n.source_identifier ,
   source = uar_get_code_display (n.source_vocabulary_cd )
   FROM (problem p ),
    (nomenclature n )
   PLAN (p
    WHERE (p.person_id = request->person_id )
    AND (p.updt_dt_tm > cnvtdatetime ((curdate - 60 ) ,curtime ) ) )
    JOIN (n
    WHERE (n.nomenclature_id = p.nomenclature_id ) )
   ORDER BY p.beg_effective_dt_tm DESC
   HEAD p.problem_id
    problemcount = (problemcount + 1 ) ,stat = alterlist (careselectsessioncreationrequest->
     problemlist ,problemcount ) ,careselectsessioncreationrequest->problemlist[problemcount ].
    problemname = name ,careselectsessioncreationrequest->problemlist[problemcount ].entereddatetime
    = enteredtime ,careselectsessioncreationrequest->problemlist[problemcount ].startdatetime =
    starttime ,careselectsessioncreationrequest->problemlist[problemcount ].enddatetime = endtime ,
    careselectsessioncreationrequest->problemlist[problemcount ].status = status ,stat = alterlist (
     careselectsessioncreationrequest->problemlist[problemcount ].codes ,1 ) ,
    careselectsessioncreationrequest->problemlist[problemcount ].codes.codesystem = source ,
    careselectsessioncreationrequest->problemlist[problemcount ].codes.code = code
   WITH nocounter
  ;end select
  SELECT
   orderid = cnvtstring (o.order_id ) ,
   name = uar_get_code_display (o.catalog_cd ) ,
   effective_time = format (o.orig_order_dt_tm ,"MM-DD-YYYY" ) ,
   catalog_code = cnvtstring (o.catalog_cd ) ,
   type = uar_get_code_display (o.catalog_type_cd ) ,
   catalog_type = uar_get_code_display (o.catalog_type_cd ) ,
   status = uar_get_code_display (o.order_status_cd )
   FROM (orders o )
   PLAN (o
    WHERE (o.person_id = request->person_id )
    AND (o.order_status_cd = constcompletedtypecd )
    AND (o.updt_dt_tm > cnvtdatetime ((curdate - 60 ) ,curtime ) )
    AND (o.catalog_type_cd != constlabtypecd ) )
   ORDER BY o.catalog_type_cd ,
    o.order_id
   HEAD o.order_id
    resultcount = 0 ,orderhistorycount = (orderhistorycount + 1 ) ,stat = alterlist (
     careselectsessioncreationrequest->orderhistory ,orderhistorycount ) ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].name = name ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].effectivedatetime =
    effective_time ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].ordertype =
    type ,stat = alterlist (careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes
     ,1 ) ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes.code =
    catalog_code ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes.codesystem
     = "Cerner Catalog Code" ,stat = alterlist (careselectsessioncreationrequest->orderhistory[
     orderhistorycount ].componentresults ,1 ) ,stat = alterlist (careselectsessioncreationrequest->
     orderhistory[orderhistorycount ].componentresults[1 ].codes ,1 ) ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[1 ].
    componentname = name ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[1 ].status = status ,careselectsessioncreationrequest->orderhistory[
    orderhistorycount ].componentresults[1 ].effectivedatetime = effective_time ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[1 ].codes.
    code = catalog_code ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[1 ].codes.codesystem = "Cerner Catalog Code"
   WITH nocounter
  ;end select
  SELECT
   orderid = cnvtstring (o.order_id ) ,
   name = uar_get_code_display (o.catalog_cd ) ,
   effective_time = format (o.orig_order_dt_tm ,"MM-DD-YYYY" ) ,
   catalog_code = cnvtstring (o.catalog_cd ) ,
   type = uar_get_code_display (o.catalog_type_cd ) ,
   catalog_type = uar_get_code_display (o.catalog_type_cd ) ,
   task_assay = uar_get_code_display (r.task_assay_cd ) ,
   source = r.concept_cki ,
   restultid = r.result_id ,
   resultstatus = uar_get_code_display (r.result_status_cd ) ,
   status = uar_get_code_display (o.order_status_cd ) ,
   event_reason = re.event_reason ,
   numeric_value = cnvtstring (pr.numeric_raw_value ) ,
   string_value = pr.result_value_alpha ,
   unit = uar_get_code_display (pr.units_cd )
   FROM (orders o ),
    (result r ),
    (result_event re ),
    (perform_result pr )
   PLAN (o
    WHERE (o.person_id = request->person_id )
    AND (o.order_status_cd = constcompletedtypecd )
    AND (o.updt_dt_tm > cnvtdatetime ((curdate - 60 ) ,curtime ) )
    AND (o.catalog_type_cd = constlabtypecd ) )
    JOIN (r
    WHERE (r.order_id = outerjoin (o.order_id ) ) )
    JOIN (re
    WHERE (re.result_id = outerjoin (r.result_id ) ) )
    JOIN (pr
    WHERE (pr.perform_result_id = outerjoin (re.perform_result_id ) ) )
   ORDER BY o.order_id ,
    r.result_id
   HEAD o.order_id
    resultcount = 1 ,orderhistorycount = (orderhistorycount + 1 ) ,stat = alterlist (
     careselectsessioncreationrequest->orderhistory ,orderhistorycount ) ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].name = name ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].effectivedatetime =
    effective_time ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].ordertype =
    type ,stat = alterlist (careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes
     ,1 ) ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes.code =
    catalog_code ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].codes.codesystem
     = "Cerner Catalog Code" ,stat = alterlist (careselectsessioncreationrequest->orderhistory[
     orderhistorycount ].componentresults ,1 ) ,stat = alterlist (careselectsessioncreationrequest->
     orderhistory[orderhistorycount ].componentresults[1 ].codes ,1 ) ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[1 ].
    componentname = name ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[1 ].status = status ,careselectsessioncreationrequest->orderhistory[
    orderhistorycount ].componentresults[1 ].effectivedatetime = effective_time ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[1 ].codes.
    code = catalog_code ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[1 ].codes.codesystem = "Cerner Catalog Code"
   HEAD r.result_id
    resultcount = (resultcount + 1 ) ,stat = alterlist (careselectsessioncreationrequest->
     orderhistory[orderhistorycount ].componentresults ,resultcount ) ,stat = alterlist (
     careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[resultcount
     ].codes ,1 ) ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[resultcount ].componentname = task_assay ,careselectsessioncreationrequest->
    orderhistory[orderhistorycount ].componentresults[resultcount ].status = resultstatus ,
    careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[resultcount ]
    .effectivedatetime = effective_time ,
    IF ((string_value = "" ) ) careselectsessioncreationrequest->orderhistory[orderhistorycount ].
     componentresults[resultcount ].resultvalue = numeric_value
    ELSE careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[
     resultcount ].resultvalue = string_value
    ENDIF
    ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].componentresults[resultcount
    ].resultunit = unit ,careselectsessioncreationrequest->orderhistory[orderhistorycount ].
    componentresults[resultcount ].codes.code = catalog_code ,careselectsessioncreationrequest->
    orderhistory[orderhistorycount ].componentresults[resultcount ].codes.codesystem =
    "Cerner Catalog Code"
   WITH nocounter
  ;end select
  SELECT
   allergyname = a.substance_ftdesc ,
   nomenclaturename = n.source_string ,
   severity = uar_get_code_display (a.severity_cd ) ,
   status = uar_get_code_display (a.active_status_cd ) ,
   reaction = uar_get_code_display (a.reaction_class_cd ) ,
   time = format (a.beg_effective_dt_tm ,"MM-DD-YYYY" ) ,
   code = n.source_identifier ,
   codesource = uar_get_code_display (n.source_vocabulary_cd )
   FROM (allergy a ),
    (nomenclature n )
   PLAN (a
    WHERE (a.person_id = request->person_id ) )
    JOIN (n
    WHERE (n.nomenclature_id = outerjoin (a.substance_nom_id ) ) )
   ORDER BY a.allergy_id DESC ,
    a.active_status_cd
   HEAD a.allergy_id
    allergycount = (allergycount + 1 ) ,stat = alterlist (careselectsessioncreationrequest->allergies
      ,allergycount ) ,
    IF ((((n.source_string = "" ) ) OR ((n.source_string = null ) )) )
     careselectsessioncreationrequest->allergies[allergycount ].allergenname = allergyname
    ELSE careselectsessioncreationrequest->allergies[allergycount ].allergenname = nomenclaturename
    ENDIF
    ,careselectsessioncreationrequest->allergies[allergycount ].entereddatetime = time ,
    careselectsessioncreationrequest->allergies[allergycount ].severity = severity ,
    careselectsessioncreationrequest->allergies[allergycount ].reactions = reaction ,
    careselectsessioncreationrequest->allergies[allergycount ].status = status ,stat = alterlist (
     careselectsessioncreationrequest->allergies[allergycount ].codes ,1 ) ,
    careselectsessioncreationrequest->allergies[allergycount ].codes[1 ].code = code ,
    careselectsessioncreationrequest->allergies[allergycount ].codes[1 ].codesystem = codesource
   WITH nocounter
  ;end select
  SET careselectsessioncreationrequest->effectivetime = format (cnvtdatetime (curdate ,curtime3 ) ,
   "yyyy-MM-ddThh:mm:ss;;d" )
  DECLARE strsessionjson = vc
  SET strsessionjson = cnvtrectojson (careselectsessioncreationrequest ,2 )
  SET strsessionjson = replace (strsessionjson ,'{"CareSelectSessionCreationRequest":' ,"" ,0 )
  SET strsessionjson = replace (strsessionjson ,'{"CARESELECTSESSIONCREATIONREQUEST":' ,"" ,0 )
  SET strsessionjson = replace (strsessionjson ,'{"careselectsessioncreationrequest":' ,"" ,0 )
  SET strsessionjson = trim (replace (strsessionjson ,"}" ,"" ,2 ) ,3 )
  DECLARE sessionsapiresponse = vc
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("About to call Create Sessions " ,format (cnvtdatetime (curdate ,
      curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,
     "##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  IF ((filepath != "" ) )
   CALL echojson (careselectsessioncreationrequest ,filepath ,1 )
  ENDIF
  SET sessionsapiresponse = createsessions (strsessionjson ,baseurl ,webservicetoken )
  IF ((sessionsapiresponse != "" ) )
   DECLARE jsonstring = vc
   SET jsonstring = build2 ('{"response":' ,sessionsapiresponse ,"}" )
   DECLARE jrec = i4
   SET jrec = cnvtjsontorec (jsonstring )
   IF ((filepath != "" ) )
    CALL echojson (response ,filepath ,1 )
   ENDIF
   FOR (i = 1 TO size (response->responses ,5 ) )
    IF ((response->responses[i ].careselectsession.sessionid != "" ) )
     SET sessionsvalid = 1
     SET session_info->orders[i ].dsn = response->responses[i ].careselectsession.sessionid
    ENDIF
   ENDFOR
  ELSE
   IF ((filepath != "" ) )
    SET ndsclog->message = build2 ("CREATE SESSION REQUEST FAILED " ,format (cnvtdatetime (curdate ,
       curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,
      "##;RP0" ) )
    CALL echojson (ndsclog ,filepath ,1 )
   ENDIF
  ENDIF
 ELSE
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("No Orders Qualified for Decision Support " ,format (cnvtdatetime (
      curdate ,curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (
      curtime3 ) ,"##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
 ENDIF
 IF ((sessionsvalid = 1 ) )
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("Session Response Valid " ,format (cnvtdatetime (curdate ,curtime3
      ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  DECLARE strsessioninfojson = vc
  SET strsessioninfojson = cnvtrectojson (session_info ,2 )
  SET strsessioninfojson = replace (strsessioninfojson ,'{"Session_Info":' ,"" ,0 )
  SET strsessioninfojson = replace (strsessioninfojson ,'{"SESSION_INFO":' ,"" ,0 )
  SET strsessioninfojson = replace (strsessioninfojson ,'{"session_info":' ,"" ,0 )
  SET strsessioninfojson = trim (replace (strsessioninfojson ,"}" ,"" ,2 ) ,3 )
  IF ((filepath != "" ) )
   CALL echojson (session_info ,filepath ,1 )
  ENDIF
  SET log_accessionid = link_accessionid
  SET log_orderid = link_orderid
  SET log_encntrid = link_encntrid
  SET log_personid = link_personid
  SET log_taskassaycd = link_taskassaycd
  SET log_clineventid = link_clineventid
  SET log_tname = link_tname
  SET log_misc1 = strsessioninfojson
  SET retval = 100
 ELSE
  IF ((filepath != "" ) )
   SET ndsclog->message = build2 ("Session Response NOT Valid " ,format (cnvtdatetime (curdate ,
      curtime3 ) ,"HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,
     "##;RP0" ) )
   CALL echojson (ndsclog ,filepath ,1 )
  ENDIF
  SET retval = 0
 ENDIF
 IF ((filepath != "" ) )
  SET ndsclog->message = build2 ("END DateTime " ,format (cnvtdatetime (curdate ,curtime3 ) ,
    "HH:MM:SS;;D" ) ,"." ,format (mpages_common_runtime_gethundredsec (curtime3 ) ,"##;RP0" ) )
  CALL echojson (ndsclog ,filepath ,1 )
 ENDIF
#exit_script
END GO
1)

191107:153732 CCUMMIN4_DVD11               Cost 0.00 Cpu 0.01 Ela 0.01 Dio   0 O0M0R0 P1R0

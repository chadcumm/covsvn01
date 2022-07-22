/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/22/2020
  Solution:           
  Source file name:   cov_rx_rpt_ssi.prg
  Object name:        cov_rx_rpt_ssi
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   06/10/2020  Chad Cummings			Translated original script (rx_rpt_ssi)
001   06/10/2020  Chad Cummings			updated to output grid
******************************************************************************/
	
DROP PROGRAM cov_rx_rpt_ssi :dba GO
CREATE PROGRAM cov_rx_rpt_ssi :dba
 PROMPT
  "Enter MINE/CRT/printer/file:" = "Mine" ,
  "Search by Non Formulary/Template Non Formulary/Investigational:" = "" ,
  "Enter the facility (* for all):" = "" ,
  "Enter the START date range (mmddyyyy hhmm)  FROM :" = "SYSDATE" ,
  "                           (mmddyyyy hhmm)    TO :" = "SYSDATE" ,
  "Select status(s) for report:" = ""
  WITH outdev ,searchtype ,facility ,startdate ,stopdate ,status
 DECLARE ball = i2 WITH protect ,noconstant (0 )
 DECLARE bactive = i2 WITH protect ,noconstant (0 )
 DECLARE bdc = i2 WITH protect ,noconstant (0 )
 DECLARE bcancel = i2 WITH protect ,noconstant (0 )
 DECLARE sstatus = vc WITH protect ,noconstant (" " )
 DECLARE start_dt = q8
 DECLARE nstart_tm = i2 WITH protect ,noconstant (0 )
 DECLARE stop_dt = q8
 DECLARE nstop_tm = i2 WITH protect ,noconstant (0 )
 DECLARE ssearch_string = vc WITH protect ,noconstant (" " )
 DECLARE bhit_report = i2 WITH protect ,noconstant (0 )
 DECLARE ningred_cnt = i2 WITH protect ,noconstant (0 )
 DECLARE idx = i4 WITH protect ,noconstant (0 )
 DECLARE ordcnt = i4 WITH protect ,noconstant (0 )
 DECLARE medcnt = i4 WITH protect ,noconstant (0 )
 DECLARE nindex = i4 WITH protect ,noconstant (0 )
 DECLARE nactual_size = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_size = i2 WITH protect ,constant (50 )
 DECLARE nexpand_total = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_start = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_stop = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand = i2 WITH protect ,noconstant (0 )
 DECLARE nfacilitycounter = i2 WITH protect ,noconstant (0 )
 DECLARE nfacactualsize = i4 WITH protect ,noconstant (0 )
 DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE ord_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE bjustprinted = i2 WITH protect ,noconstant (0 )
 DECLARE bdone_with_encntr = i2 WITH protect ,noconstant (0 )
 DECLARE bprint_patient_info = i2 WITH protect ,noconstant (0 )
 DECLARE new_model_check = i2 WITH protect ,noconstant (0 )
 DECLARE dose = vc WITH protect ,noconstant (" " )
 DECLARE disp_str = vc WITH protect ,noconstant (" " )
 DECLARE disp_vol = vc WITH protect ,noconstant (" " )
 DECLARE i18nhandle = i4 WITH protect ,noconstant (0 )
 DECLARE h = i4 WITH protect ,noconstant (0 )
 DECLARE status_string = vc WITH protect ,noconstant (" " )
 DECLARE rundate_string = vc WITH protect ,noconstant (" " )
 DECLARE page_string = vc WITH protect ,noconstant (" " )
 DECLARE facility_string = vc WITH protect ,noconstant (" " )
 DECLARE daterange_string = vc WITH protect ,noconstant (" " )
 DECLARE location_string = vc WITH protect ,noconstant (" " )
 DECLARE drugstatus_string = vc WITH protect ,noconstant (" " )
 DECLARE roombed_string = vc WITH protect ,noconstant (" " )
 DECLARE medication_string = vc WITH protect ,noconstant (" " )
 DECLARE startdatetime = vc WITH protect ,noconstant (" " )
 DECLARE stopdatetime = vc WITH protect ,noconstant (" " )
 DECLARE orders_string = vc WITH protect ,noconstant (" " )
 DECLARE spcialstatus_report = vc WITH protect ,noconstant (" " )
 DECLARE nonformulary_string = vc WITH protect ,noconstant (" " )
 DECLARE nonformlaryitem_str = vc WITH protect ,noconstant (" " )
 DECLARE investidrug_str = vc WITH protect ,noconstant (" " )
 DECLARE nonformitembydef_str = vc WITH protect ,noconstant (" " )
 SET h = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 SET status_string = uar_i18ngetmessage (i18nhandle ,"key1" ,"Status == " )
 SET rundate_string = uar_i18ngetmessage (i18nhandle ,"key2" ," Run Date:" )
 SET page_string = uar_i18ngetmessage (i18nhandle ,"key3" ," Page: " )
 SET facility_string = uar_i18ngetmessage (i18nhandle ,"key4" ,"Facility:" )
 SET daterange_string = uar_i18ngetmessage (i18nhandle ,"key5" ,"Date Range......." )
 SET location_string = uar_i18ngetmessage (i18nhandle ,"key6" ,"Location:" )
 SET drugstatus_string = uar_i18ngetmessage (i18nhandle ,"key7" ,"Drug Status......:" )
 SET roombed_string = uar_i18ngetmessage (i18nhandle ,"key8" ,"Room-Bed/Patient:" )
 SET medication_string = uar_i18ngetmessage (i18nhandle ,"key9" ,"Medication" )
 SET startdatetime = uar_i18ngetmessage (i18nhandle ,"key10" ,"Start Dt/Tm" )
 SET stopdatetime = uar_i18ngetmessage (i18nhandle ,"key11" ,"Stop Dt/Tm" )
 SET orders_string = uar_i18ngetmessage (i18nhandle ,"key12" ,"Order#" )
 SET spcialstatus_report = uar_i18ngetmessage (i18nhandle ,"key13" ,"Special Status Report" )
 SET nonformulary_string = uar_i18ngetmessage (i18nhandle ,"key14" ,"Non Formulary Items  " )
 SET nonformlaryitem_str = uar_i18ngetmessage (i18nhandle ,"key15" ,"Template Non Formulary Items" )
 SET investidrug_str = uar_i18ngetmessage (i18nhandle ,"key16" ,"Investigational Drugs" )
 SET nonformitembydef_str = uar_i18ngetmessage (i18nhandle ,"key17" ,
  "Non Formulary Items (by Default)" )
 DECLARE dqutcdatetime = dq8 WITH protect ,constant (cnvtdatetime (curdate ,curtime ) )
 DECLARE dformulary_status = f8 WITH protect ,noconstant (0.0 )
 DECLARE streatmentperiod = vc WITH protect ,noconstant ("" )
 DECLARE ntreatmentperiod = i2 WITH protect ,noconstant (0 )
 DECLARE slabeldescwtreatmentperiod = vc WITH protect ,noconstant ("" )
 DECLARE cfinnbr = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) )
 DECLARE cgeneric = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"GENERIC_NAME" ) )
 DECLARE clabel = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) )
 DECLARE cordered2 = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"ORDERED" ) )
 DECLARE cordered = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,14281 ,"ORDERED" ) )
 DECLARE ccanceled = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"CANCELED" ) )
 DECLARE csuspended = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"SUSPENDED" ) )
 DECLARE csoft = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4009 ,"SOFT" ) )
 DECLARE cfuture = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"FUTURE" ) )
 DECLARE cdiscontinued = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"DISCONTINUED"
   ) )
 DECLARE ccompleted = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"COMPLETED" ) )
 DECLARE cvoided = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"VOIDED" ) )
 DECLARE cdeleted = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"DELETED" ) )
 DECLARE conhold = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,14281 ,"ONHOLD" ) )
 DECLARE cpending = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"PENDING" ) )
 DECLARE cincomplete = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"INCOMPLETE" ) )
 DECLARE ctrans = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"TRANS/CANCEL" ) )
 DECLARE cvoid = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6004 ,"VOIDEDWRSLT" ) )
 DECLARE crxmnemonic = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6011 ,"RXMNEMONIC" ) )
 DECLARE cmeddef = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11001 ,"MED_DEF" ) )
 DECLARE activity_type = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,106 ,"PHARMACY" ) )
 DECLARE cformulary = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4512 ,"FORMULARY" ) )
 DECLARE cinvestigat = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4512 ,"INVESTIGAT" ) )
 DECLARE cnonformulary = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4512 ,"NONFORMULARY"
   ) )
 DECLARE ctnf = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4512 ,"TNF" ) )
 DECLARE csystem = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSTEM" ) )
 DECLARE csyspkgtyp = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ) )
 DECLARE cinpatient = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) )
 DECLARE cdispense = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4063 ,"DISPENSE" ) )
 DECLARE cformat = c50 WITH protect ,constant (fillstring (50 ,"#" ) )
 SET bhit_report = 0
 SET start_dt = cnvtdate (trim (substring (1 ,8 , $STARTDATE ) ) )
 SET nstart_tm = cnvtint (trim (substring (10 ,4 , $STARTDATE ) ) )
 SET stop_dt = cnvtdate (trim (substring (1 ,8 , $STOPDATE ) ) )
 SET nstop_tm = cnvtint (trim (substring (10 ,4 , $STOPDATE ) ) )
 CALL echo (build ("start dt --" ,start_dt ) )
 IF (("ALL" =  $STATUS ) )
  SET ball = 1
  SET sstatus = "ALL"
  CALL echo ("Setting all ind" )
 ENDIF
 IF (("Active/Suspend" =  $STATUS ) )
  SET bactive = 1
  SET sstatus = concat (trim (sstatus ) ,"Active/Suspend" )
  CALL echo ("Setting active ind" )
 ENDIF
 IF (("Discontinue/Completed" =  $STATUS ) )
  SET bdc = 1
  SET sstatus = concat (trim (sstatus ) ,"Discontinue/Completed" )
  CALL echo ("Setting dc ind" )
 ENDIF
 IF (("Canceled/Voided" =  $STATUS ) )
  SET bcancel = 1
  SET sstatus = concat (trim (sstatus ) ,"Canceled/Voided" )
  CALL echo ("Setting cancel ind" )
 ENDIF
 CALL echo (build ("Status ==" ,sstatus ) )
 IF (NOT (validate (reply ,0 ) ) )
  CALL echo ("Defining record structure" )
  RECORD reply (
    1 status_data
      2 status = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE utcdatetime ((ddatetime = vc ) ,(lindex = i4 ) ,(bshowtz = i2 ) ,(sformat = vc ) ) = vc
 DECLARE utcshorttz ((lindex = i4 ) ) = vc
 DECLARE sutcdatetime = vc WITH protect ,noconstant (" " )
 DECLARE dutcdatetime = f8 WITH protect ,noconstant (0.0 )
 DECLARE cutc = i2 WITH protect ,constant (curutc )
 SUBROUTINE  utcdatetime (sdatetime ,lindex ,bshowtz ,sformat )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewdatetime = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = vc WITH protect ,constant ("ZZZ" )
  IF ((lindex > 0 ) )
   SET lnewindex = lindex
  ENDIF
  SET snewdatetime = datetimezoneformat (sdatetime ,lnewindex ,sformat )
  IF ((cutc = 1 )
  AND (bshowtz = 1 ) )
   IF ((size (trim (snewdatetime ) ) > 0 ) )
    SET snewdatetime = concat (snewdatetime ," " ,datetimezoneformat (sdatetime ,lnewindex ,
      ctime_zone_format ) )
   ENDIF
  ENDIF
  SET snewdatetime = trim (snewdatetime )
  RETURN (snewdatetime )
 END ;Subroutine
 SUBROUTINE  utcshorttz (lindex )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewshorttz = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = i2 WITH protect ,constant (7 )
  IF ((cutc = 1 ) )
   IF ((lindex > 0 ) )
    SET lnewindex = lindex
   ENDIF
   SET snewshorttz = datetimezonebyindex (lnewindex ,offset ,daylight ,ctime_zone_format )
  ENDIF
  SET snewshorttz = trim (snewshorttz )
  RETURN (snewshorttz )
 END ;Subroutine
 RECORD errors (
   1 err_cnt = i4
   1 err [* ]
     2 err_code = i4
     2 err_msg = vc
 )
 SET errcode = 1
 SET errmsg = fillstring (132 ," " )
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 SET firsttime = 1
 SET qualified = 0
 SET i = 0
 SET cntr = 0
 RECORD internal (
   1 select_desc = c30
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
   1 output_device_s = c30
   1 orderid = f8
   1 personid = f8
   1 encntrid = f8
   1 alt_sel_cat_id = f8
   1 item_id = f8
 )
 IF ((((start_dt = 0 ) ) OR ((stop_dt = 0 ) )) )
  CALL echo ("Unable to resolve dates - exiting" )
  GO TO exit_script
 ENDIF
 SET internal->begin_dt_tm = cnvtdatetime (start_dt ,nstart_tm )
 SET internal->end_dt_tm = cnvtdatetime (stop_dt ,nstop_tm )
 RECORD orderrec (
   1 qual [* ]
     2 item_id = f8
     2 synonym_id = f8
   1 orderlist [* ]
     2 tnf_description = vc
     2 sort_label_desc = vc
     2 sort_generic_name = vc
     2 orderid = f8
     2 drug_qualified = c1
     2 deptmiscline = c255
     2 name = c30
     2 med_rec = c30
     2 fin_nbr = c30
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 encntr_id = f8
     2 loc_s = c30
     2 loc_room_s = c10
     2 loc_bed_s = c10
     2 facility = c30
     2 order_status = f8
     2 all_unverified_ind = i2
     2 qualified = c1
     2 formulary_status = f8
     2 comp_sequence = i4
     2 generic_name = vc
     2 actionlist [* ]
       3 actionsequence = i4
       3 actiontypecd = f8
       3 communicationtypecd = f8
       3 orderproviderid = f8
       3 orderdttm = dq8
       3 contributorsystemcd = f8
       3 orderlocncd = f8
       3 actionpersonnelid = f8
       3 effectivedttm = dq8
       3 actiondttm = dq8
       3 needsverifyflag = i2
       3 deptstatuscd = f8
       3 actionrejectedind = i2
       3 detaillist [* ]
         4 orderid = f8
         4 actionsequence = i4
         4 detailsequence = i4
         4 oefieldid = f8
         4 oefieldvalue = f8
         4 oefielddisplayvalue = vc
         4 oefielddttmvalue = dq8
         4 oefieldtz = i4
         4 oefieldmeaning = vc
         4 oefieldmeaningid = f8
         4 valuerequiredind = i2
         4 groupseq = i4
         4 fieldseq = i4
         4 modifiedind = i2
       3 subcomponentlist [* ]
         4 sccompsequence = i4
         4 sccatalogcd = f8
         4 scgcrcode = i4
         4 sccatalogtypecd = f8
         4 scsynonymid = f8
         4 scordermnemonic = vc
         4 scorderdetaildisplayline = vc
         4 scoeformatid = f8
         4 scstrength = f8
         4 scstrengthunit = f8
         4 scvolume = f8
         4 scvolumeunit = f8
         4 scfreetextdose = vc
         4 scivseq = i4
         4 scmultumid = vc
         4 scgenericname = vc
         4 scbrandname = vc
         4 sclabeldesc = vc
         4 scfrequency = f8
     2 person_id = f8
 )
 SET ccost = 2004.00
 SET ccomponentcost = 2005.00
 SET cdispensefromloc = 2006.00
 SET cdispensecategory = 2007.00
 SET ccomponentdispensecategory = 2008.00
 SET cfreq = 2011.00
 SET ccomponentfreq = 2012.00
 SET civfreq = 2013.00
 SET cdrugform = 2014.00
 SET cdispenseqty = 2015.00
 SET crefillqty = 2016.00
 SET cdaw = 2017.00
 SET csamplesgiven = 2018.00
 SET csampleqty = 2019.00
 SET cnextdispensedttm = 2024.00
 SET cpharmnotes = 2028.00
 SET cnotetype = 2029.00
 SET cparvalue = 2032.00
 SET cphysician = 2033.00
 SET cprinter = 2039.00
 SET crate = 2043.00
 SET ccomponentrate = 2044.00
 SET ccollroute = 2045.00
 SET croute = 2050.00
 SET ccomponentroute = 2046.00
 SET cstartbag = 2047.00
 SET ccomponentstartbag = 2048.00
 SET cstopbag = 2053.00
 SET cstoptype = 2055.00
 SET cstrengthdose = 2056.00
 SET cstrengthdoseunit = 2057.00
 SET cvolumedose = 2058.00
 SET cvolumedoseunit = 2059.00
 SET ctotalvolume = 2060.00
 SET cduration = 2061.00
 SET cdurationunit = 2062.00
 SET cfreetxtdose = 2063.00
 SET cinfuseoverunit = 2064.00
 SET cinfuseover = 118.00
 SET cstopdttm = 2073.00
 SET cdiluentid = 2065.00
 SET cdiluentvol = 2066.00
 SET cschprn = 2037.00
 SET ctreatmentperiod = 3524.00
 CALL echo ("Last Mod = 001" )
 CALL echo ("Mod Date = 12/01/2009" )
 CALL echo ("---END PHA_OE_FIELD_CONST.INC---" )
 SET crepl = 2068.00
 SET creplunit = 2069.00
 SET cordertype = 2070.00
 SET ctitrate = 2078.00
 SET medcnt = 0
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "TEMPLATE NON FORMULARY" ) )
  SET dformulary_status = ctnf
 ELSEIF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "NON FORMULARY" ) )
  SET dformulary_status = cnonformulary
 ELSEIF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "INVESTIGATIONAL" ) )
  SET dformulary_status = cinvestigat
 ENDIF
 EXECUTE rx_get_facs_for_prsnl_rr_incl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 SET stat = alterlist (prsnl_facs_req->qual ,1 )
 CALL echo (build ("Reqinfo->updt_id --" ,reqinfo->updt_id ) )
 CALL echo (build ("curuser --" ,curuser ) )
 SET prsnl_facs_req->qual[1 ].username = trim (curuser )
 SET prsnl_facs_req->qual[1 ].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 CALL echo (build ("Size of facility list in prg--" ,size (prsnl_facs_reply->qual[1 ].facility_list ,
    5 ) ) )
 FREE RECORD facility_list
 RECORD facility_list (
   1 qual [* ]
     2 facility_cd = f8
 )
 SET stat = alterlist (facility_list->qual ,value (size (prsnl_facs_reply->qual[1 ].facility_list ,5
    ) ) )
 FOR (x = 1 TO size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) )
  CALL echo (build ("Checking facility --" ,trim (format (prsnl_facs_reply->qual[1 ].facility_list[x
      ].facility_cd ,cformat ) ,3 ) ) )
  CALL echo (build ("against --" , $FACILITY ) )
  IF ((trim (format (prsnl_facs_reply->qual[1 ].facility_list[x ].facility_cd ,cformat ) ,3 ) =
   $FACILITY ) )
   SET nfacilitycounter = (nfacilitycounter + 1 )
   SET facility_list->qual[nfacilitycounter ].facility_cd = prsnl_facs_reply->qual[1 ].facility_list[
   x ].facility_cd
  ENDIF
 ENDFOR
 SET stat = alterlist (facility_list->qual ,nfacilitycounter )
 SET nfacactualsize = size (facility_list->qual ,5 )
 CALL echo (build ("nFacActualSize --" ,nfacactualsize ) )
 IF ((nfacactualsize = 0 ) )
  CALL echo ("*** User does not have access to facility selection ***" )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM (dm_prefs dmp )
  WHERE (dmp.application_nbr = 300000 )
  AND (dmp.person_id = 0 )
  AND (dmp.pref_domain = "PHARMNET-INPATIENT" )
  AND (dmp.pref_section = "FRMLRYMGMT" )
  AND (dmp.pref_name = "NEW MODEL" )
  DETAIL
   IF ((dmp.pref_nbr = 1 ) ) new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo ("*** Getting item ids ***" )
 CALL echo (build ("Searching for " , $SEARCHTYPE ," items, code value: " ,dformulary_status ) )
 IF ((new_model_check = 0 ) )
  SELECT INTO "NL:"
   md.item_id
   FROM (medication_definition md )
   WHERE ((md.formulary_status_cd + 0 ) = dformulary_status )
   AND (md.item_id > 0 )
   ORDER BY md.item_id
   HEAD REPORT
    medcnt = 0
   HEAD md.item_id
    medcnt = (medcnt + 1 ) ,
    IF ((medcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(medcnt + 10 ) )
    ENDIF
    ,orderrec->qual[medcnt ].item_id = md.item_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   md.item_id
   FROM (med_def_flex mdf ),
    (med_flex_object_idx mfoi ),
    (med_dispense md )
   PLAN (mdf
    WHERE (mdf.pharmacy_type_cd = cinpatient )
    AND ((mdf.flex_type_cd + 0 ) = csyspkgtyp ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
    AND (mfoi.flex_object_type_cd = cdispense )
    AND (mfoi.sequence = 1 )
    AND (mfoi.parent_entity_id > 0 )
    AND (mfoi.active_ind = 1 ) )
    JOIN (md
    WHERE (md.med_dispense_id = mfoi.parent_entity_id )
    AND ((md.formulary_status_cd + 0 ) = dformulary_status ) )
   ORDER BY md.item_id
   HEAD REPORT
    medcnt = 0
   HEAD md.item_id
    medcnt = (medcnt + 1 ) ,
    IF ((medcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(medcnt + 10 ) )
    ENDIF
    ,orderrec->qual[medcnt ].item_id = mdf.item_id
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist (orderrec->qual ,medcnt )
 RECORD orderlist (
   1 data [* ]
     2 order_id = f8
     2 formulary_status = f8
     2 comp_sequence = i4
     2 tnf_description = vc
     2 tnf_count = i4
     2 scorderdetaildisplayline = vc
     2 scstrength = f8
     2 scstrengthunit = f8
     2 scvolume = f8
     2 scvolumeunit = f8
     2 scfreetextdose = vc
     2 scgenericname = vc
     2 scbrandname = vc
     2 sclabeldesc = vc
     2 scfrequency = f8
 )
 SET idx = 0
 SET xdx = 0
 SET ydx = 0
 SET zdx = 0
 SET y = 0
 SET cntr = size (orderrec->qual ,5 )
 CALL echo ("made it to this point" )
 CALL echo (build ("Search type --" , $SEARCHTYPE ) )
 SET nactual_size = size (orderrec->qual ,5 )
 SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
 SET nexpand_start = 1
 SET nexpand_stop = 50
 SET stat = alterlist (orderrec->qual ,nexpand_total )
 FOR (x = (nactual_size + 1 ) TO nexpand_total )
  SET orderrec->qual[x ].item_id = orderrec->qual[nactual_size ].item_id
 ENDFOR
 CALL echo ("*** Getting list of order ids ***" )
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "TEMPLATE NON FORMULARY" ) )
  CALL echo ("In TNF search" )
  SELECT DISTINCT INTO "NL:"
   op.order_id ,
   oi.comp_sequence ,
   oi.freq_cd ,
   oi.order_detail_display_line ,
   oi.strength ,
   oi.strength_unit ,
   oi.volume ,
   oi.volume_unit ,
   oi.freetext_dose ,
   dfacilityareacd =
   IF ((o.encntr_id > 0 ) ) e.loc_facility_cd
   ELSE od.future_loc_facility_cd
   ENDIF
   FROM (orders o ),
    (order_product op ),
    (order_ingredient oi ),
    (template_nonformulary tn ),
    (order_dispense od ),
    (encounter e ),
    (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) )
   PLAN (d
    WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
    AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
    JOIN (o
    WHERE (o.template_order_id = 0 )
    AND (o.current_start_dt_tm BETWEEN cnvtdatetime (internal->begin_dt_tm ) AND cnvtdatetime (
     internal->end_dt_tm ) )
    AND ((o.activity_type_cd + 0 ) = activity_type )
    AND ((o.template_order_flag + 0 ) IN (0 ,
    1 ) )
    AND (((ball = 1 ) ) OR ((((bactive = 1 )
    AND ((o.order_status_cd + 0 ) IN (cordered ,
    cordered2 ,
    conhold ,
    csoft ,
    cfuture ,
    csuspended ) ) ) OR ((((bdc = 1 )
    AND ((o.order_status_cd + 0 ) IN (cdiscontinued ,
    cpending ,
    ctrans ,
    ccompleted ) ) ) OR ((bcancel = 1 )
    AND ((o.order_status_cd + 0 ) IN (cvoided ,
    cdeleted ,
    cvoid ,
    cincomplete ,
    ccanceled ) ) )) )) )) )
    JOIN (op
    WHERE (op.order_id = (o.order_id + 0 ) )
    AND (op.action_sequence > 0 )
    AND (op.ingred_sequence > 0 )
    AND (op.item_id >= 0 ) )
    JOIN (tn
    WHERE (tn.tnf_id = (op.tnf_id + 0 ) )
    AND expand (nexpand ,nexpand_start ,nexpand_stop ,(tn.shell_item_id + 0 ) ,orderrec->qual[
     nexpand ].item_id ) )
    JOIN (od
    WHERE (od.order_id = o.order_id ) )
    JOIN (e
    WHERE (((e.encntr_id = (o.encntr_id + 0 ) )
    AND (((cnvtdatetime (internal->begin_dt_tm ) BETWEEN e.beg_effective_dt_tm AND e
    .end_effective_dt_tm ) ) OR ((cnvtdatetime (internal->end_dt_tm ) BETWEEN e.beg_effective_dt_tm
    AND e.end_effective_dt_tm ) ))
    AND ((e.active_ind + 0 ) = 1 ) ) OR ((e.encntr_id = 0 )
    AND ((o.encntr_id + 0 ) = 0 ) )) )
    JOIN (oi
    WHERE (oi.order_id = (op.order_id + 0 ) )
    AND (op.action_sequence = oi.action_sequence )
    AND ((op.ingred_sequence + 0 ) = oi.comp_sequence ) )
   ORDER BY op.order_id
   HEAD REPORT
    idx = 0 ,
    CALL echo ("Head report TNF" )
   DETAIL
    IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].
     facility_cd ) > 0 ) ) idx = (idx + 1 ) ,
     CALL echo (build ("Qualifying order id --" ,op.order_id ) ) ,
     IF ((idx > size (orderlist->data ,5 ) ) ) stat = alterlist (orderlist->data ,(idx + 10 ) )
     ENDIF
     ,orderlist->data[idx ].order_id = op.order_id ,orderlist->data[idx ].formulary_status =
     dformulary_status ,orderlist->data[idx ].tnf_description = tn.description ,orderlist->data[idx ]
     .comp_sequence = oi.comp_sequence ,orderlist->data[idx ].scfrequency = oi.freq_cd ,orderlist->
     data[idx ].scorderdetaildisplayline = oi.order_detail_display_line ,orderlist->data[idx ].
     scstrength = round (oi.strength ,4 ) ,orderlist->data[idx ].scstrengthunit = oi.strength_unit ,
     orderlist->data[idx ].scvolume = round (oi.volume ,2 ) ,orderlist->data[idx ].scvolumeunit = oi
     .volume_unit ,orderlist->data[idx ].scfreetextdose = oi.freetext_dose
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  CALL echo ("In NF/INV search" )
  SELECT DISTINCT INTO "NL:"
   op.order_id ,
   e.loc_facility_cd ,
   dfacilityareacd =
   IF ((o.encntr_id > 0 ) ) e.loc_facility_cd
   ELSE od.future_loc_facility_cd
   ENDIF
   FROM (orders o ),
    (order_product op ),
    (order_dispense od ),
    (encounter e ),
    (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) )
   PLAN (d
    WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
    AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
    JOIN (o
    WHERE (o.template_order_id = 0 )
    AND (o.current_start_dt_tm BETWEEN cnvtdatetime (internal->begin_dt_tm ) AND cnvtdatetime (
     internal->end_dt_tm ) )
    AND ((o.activity_type_cd + 0 ) = activity_type )
    AND ((o.template_order_flag + 0 ) IN (0 ,
    1 ) )
    AND (((ball = 1 ) ) OR ((((bactive = 1 )
    AND ((o.order_status_cd + 0 ) IN (cordered ,
    cordered2 ,
    conhold ,
    csoft ,
    cfuture ,
    csuspended ) ) ) OR ((((bdc = 1 )
    AND ((o.order_status_cd + 0 ) IN (cdiscontinued ,
    cpending ,
    ctrans ,
    ccompleted ) ) ) OR ((bcancel = 1 )
    AND ((o.order_status_cd + 0 ) IN (cvoided ,
    cdeleted ,
    cvoid ,
    cincomplete ,
    ccanceled ) ) )) )) )) )
    JOIN (op
    WHERE (op.order_id = (o.order_id + 0 ) )
    AND (op.action_sequence > 0 )
    AND (op.ingred_sequence > 0 )
    AND expand (nexpand ,nexpand_start ,nexpand_stop ,op.item_id ,orderrec->qual[nexpand ].item_id )
    )
    JOIN (od
    WHERE (od.order_id = o.order_id ) )
    JOIN (e
    WHERE (((e.encntr_id = (o.encntr_id + 0 ) )
    AND (((cnvtdatetime (internal->begin_dt_tm ) BETWEEN e.beg_effective_dt_tm AND e
    .end_effective_dt_tm ) ) OR ((cnvtdatetime (internal->end_dt_tm ) BETWEEN e.beg_effective_dt_tm
    AND e.end_effective_dt_tm ) ))
    AND ((e.active_ind + 0 ) = 1 ) ) OR ((e.encntr_id = 0 )
    AND ((o.encntr_id + 0 ) = 0 ) )) )
   ORDER BY op.order_id
   HEAD REPORT
    idx = 0
   DETAIL
    IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].
     facility_cd ) > 0 ) ) idx = (idx + 1 ) ,
     IF ((idx > size (orderlist->data ,5 ) ) ) stat = alterlist (orderlist->data ,(idx + 10 ) )
     ENDIF
     ,
     CALL echo (build ("Qualifying order id --" ,op.order_id ) ) ,orderlist->data[idx ].order_id = op
     .order_id ,orderlist->data[idx ].formulary_status = dformulary_status
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist (orderlist->data ,idx )
 CALL echo (build ("Order list size ==" ,size (orderlist->data ,5 ) ) )
 SET ordcnt = 0
 SET oacnt = 0
 SET oicnt = 0
 SET occnt = 0
 SET addedcomp = 0
 SET nactual_size = size (orderlist->data ,5 )
 SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
 SET nexpand_start = 1
 SET nexpand_stop = 50
 SET stat = alterlist (orderlist->data ,nexpand_total )
 FOR (x = (nactual_size + 1 ) TO nexpand_total )
  SET orderlist->data[x ].order_id = orderlist->data[nactual_size ].order_id
 ENDFOR
 CALL echo ("Getting detail information for each order" )
 IF ((new_model_check = 0 ) )
  CALL echo ("Old Formulary" )
  SELECT INTO "NL:"
   o.order_id ,
   ordactseq = concat (cnvtstring (o.order_id ) ,cnvtstring (o.last_action_sequence ) ) ,
   ordsubseq = concat (cnvtstring (oi.order_id ) ,cnvtstring (oi.action_sequence ) ,cnvtstring (oi
     .comp_sequence ) ) ,
   oihit = decode (oi.comp_sequence ,oi.comp_sequence ,0 ) ,
   orddetseq = concat (cnvtstring (od.order_id ) ,cnvtstring (od.action_sequence ) ,cnvtstring (od
     .detail_sequence ) ) ,
   odhit = decode (od.detail_sequence ,od.detail_sequence ,0 ) ,
   op_hit = decode (op.seq ,1 ,0 ) ,
   loc_bed_s = uar_get_code_display (e.loc_bed_cd ) ,
   loc_s = uar_get_code_display (e.loc_nurse_unit_cd ) ,
   prod_name = substring (1 ,30 ,oii.value ) ,
   loc_room_s = uar_get_code_description (e.loc_room_cd ) ,
   facility_area = uar_get_code_display (e.loc_facility_cd ) ,
   e.loc_facility_cd ,
   e.encntr_id ,
   ea.alias ,
   ea.alias_pool_cd ,
   o.order_status_cd ,
   o.last_action_sequence ,
   o.projected_stop_dt_tm ,
   o.projected_stop_tz ,
   o.current_start_dt_tm ,
   o.current_start_tz ,
   o.dept_misc_line ,
   o.order_status_cd ,
   p.name_full_formatted ,
   od.order_id ,
   od.action_sequence ,
   od.detail_sequence ,
   od.oe_field_id ,
   od.oe_field_value ,
   od.oe_field_display_value ,
   od.oe_field_meaning_id ,
   od.oe_field_meaning ,
   od.oe_field_dt_tm_value ,
   od.oe_field_tz ,
   oi.comp_sequence ,
   oi.freq_cd ,
   oi.catalog_cd ,
   oi.catalog_type_cd ,
   oi.synonym_id ,
   oi.order_mnemonic ,
   oi.order_detail_display_line ,
   oi.strength ,
   oi.strength_unit ,
   oi.volume ,
   oi.volume_unit ,
   oi.freetext_dose ,
   oi.iv_seq ,
   oii.identifier_type_cd ,
   oii.value ,
   op.item_id
   FROM (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) ),
    (orders o ),
    (order_ingredient oi ),
    (order_detail od ),
    (order_product op ),
    (object_identifier_index oii ),
    (person p ),
    (encounter e ),
    (encntr_alias ea ),
    (dummyt do4 WITH seq = 1 ),
    (dummyt do1 WITH seq = 1 ),
    (dummyt do2 WITH seq = 1 )
   PLAN (d
    WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
    AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
    JOIN (o
    WHERE expand (nexpand ,nexpand_start ,nexpand_stop ,o.order_id ,orderlist->data[nexpand ].
     order_id ) )
    JOIN (p
    WHERE (p.person_id = (o.person_id + 0 ) ) )
    JOIN (e
    WHERE (e.encntr_id = (o.encntr_id + 0 ) ) )
    JOIN (do4 )
    JOIN (ea
    WHERE (ea.encntr_id = (e.encntr_id + 0 ) )
    AND ((ea.encntr_alias_type_cd + 0 ) = cfinnbr )
    AND ((ea.active_ind + 0 ) = 1 )
    AND ((ea.beg_effective_dt_tm + 0 ) <= cnvtdatetime (curdate ,curtime ) )
    AND ((ea.end_effective_dt_tm + 0 ) >= cnvtdatetime (curdate ,curtime ) ) )
    JOIN (do1
    WHERE (do1.seq = 1 ) )
    JOIN (od
    WHERE (od.order_id = (o.order_id + 0 ) )
    AND ((od.oe_field_meaning_id + 0 ) IN (cfreq ,
    crate ,
    croute ,
    cinfuseoverunit ,
    cinfuseover ,
    cschprn ,
    crepl ,
    creplunit ,
    cordertype ,
    ctitrate ) ) )
    JOIN (oi
    WHERE (oi.order_id = (o.order_id + 0 ) )
    AND (oi.action_sequence = (o.last_ingred_action_sequence + 0 ) ) )
    JOIN (do2 )
    JOIN (op
    WHERE (op.order_id = (oi.order_id + 0 ) )
    AND (op.action_sequence = (oi.action_sequence + 0 ) )
    AND (op.ingred_sequence = (oi.comp_sequence + 0 ) ) )
    JOIN (oii
    WHERE (oii.object_id = (op.item_id + 0 ) )
    AND (oii.generic_object = 0 )
    AND ((oii.identifier_type_cd + 0 ) IN (clabel ,
    cgeneric ) )
    AND ((oii.primary_ind + 0 ) = 1 ) )
   ORDER BY o.order_id ,
    ordactseq ,
    ordsubseq ,
    orddetseq
   HEAD REPORT
    cnt2 = 0 ,
    stat = alterlist (orderrec->orderlist ,0 )
   HEAD o.order_id
    CALL echo (build ("Head order id --" ,o.order_id ) ) ,
    CALL echo (build ("e loc fac --" ,e.loc_facility_cd ) ) ,
    IF ((locateval (x ,1 ,nfacactualsize ,e.loc_facility_cd ,facility_list->qual[x ].facility_cd ) >
    0 ) ) temp_status = uar_get_code_display (o.order_status_cd ) ,medcnt = value (size (orderlist->
       data ,5 ) ) ,qualified = 1 ,ordcnt = (ordcnt + 1 ) ,
     IF ((ordcnt > size (orderrec->orderlist ,5 ) ) ) stat = alterlist (orderrec->orderlist ,(ordcnt
       + 10 ) )
     ENDIF
     ,orderrec->orderlist[ordcnt ].orderid = o.order_id ,orderrec->orderlist[ordcnt ].
     projected_stop_dt_tm = cnvtdatetime (o.projected_stop_dt_tm ) ,orderrec->orderlist[ordcnt ].
     projected_stop_tz = o.projected_stop_tz ,orderrec->orderlist[ordcnt ].current_start_dt_tm =
     cnvtdatetime (o.current_start_dt_tm ) ,orderrec->orderlist[ordcnt ].current_start_tz = o
     .current_start_tz ,orderrec->orderlist[ordcnt ].loc_s = substring (1 ,30 ,loc_s ) ,orderrec->
     orderlist[ordcnt ].loc_room_s = substring (1 ,10 ,loc_room_s ) ,orderrec->orderlist[ordcnt ].
     loc_bed_s = substring (1 ,10 ,loc_bed_s ) ,orderrec->orderlist[ordcnt ].facility = substring (1
      ,30 ,facility_area ) ,orderrec->orderlist[ordcnt ].name = p.name_full_formatted ,orderrec->
     orderlist[ordcnt ].deptmiscline = o.dept_misc_line ,orderrec->orderlist[ordcnt ].fin_nbr =
     cnvtalias (ea.alias ,ea.alias_pool_cd ) ,orderrec->orderlist[ordcnt ].order_status = o
     .order_status_cd ,orderrec->orderlist[ordcnt ].all_unverified_ind = 1 ,orderrec->orderlist[
     ordcnt ].encntr_id = e.encntr_id ,oacnt = 0 ,oicnt = 0
    ENDIF
   HEAD ordactseq
    IF ((locateval (x ,1 ,nfacactualsize ,e.loc_facility_cd ,facility_list->qual[x ].facility_cd ) >
    0 ) )
     CALL echo (build ("Head ordActseq --" ,ordactseq ) ) ,qualified = 1 ,orderrec->orderlist[ordcnt
     ].qualified = "Y" ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "TEMPLATE NON FORMULARY" ) ) nindex = locateval (x ,1 ,
       nactual_size ,o.order_id ,orderlist->data[x ].order_id ) ,orderrec->orderlist[ordcnt ].
      tnf_description = orderlist->data[nindex ].tnf_description ,orderrec->orderlist[ordcnt ].
      comp_sequence = orderlist->data[nindex ].comp_sequence ,orderrec->orderlist[ordcnt ].
      formulary_status = orderlist->data[nindex ].formulary_status ,orderrec->orderlist[ordcnt ].
      drug_qualified = "Y"
     ENDIF
     ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) IN ("INVESTIGATIONAL" ,
     "NON FORMULARY" ) ) ) orderrec->orderlist[ordcnt ].drug_qualified = "Y"
     ENDIF
     ,oacnt = (oacnt + 1 ) ,stat = alterlist (orderrec->orderlist[ordcnt ].actionlist ,oacnt ) ,
     orderrec->orderlist[ordcnt ].actionlist[1 ].actionsequence = o.last_action_sequence ,orderrec->
     orderlist[ordcnt ].actionlist[1 ].deptstatuscd = orderrec->orderlist[ordcnt ].order_status ,
     oicnt = 0 ,odcnt = 0 ,addedcomp = 0
    ENDIF
   HEAD orddetseq
    IF ((locateval (x ,1 ,nfacactualsize ,e.loc_facility_cd ,facility_list->qual[x ].facility_cd ) >
    0 ) )
     CALL echo (build ("Head ordDetSeq --" ,orddetseq ) ) ,
     CALL echo (build ("odHit --" ,odhit ) ) ,
     IF ((odhit > 0 ) )
      CALL echo (build ("storing --" ,od.oe_field_meaning ) ) ,odcnt = (odcnt + 1 ) ,stat =
      alterlist (orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist ,odcnt ) ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].orderid = od.order_id ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].actionsequence = od.action_sequence ,
      orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].detailsequence = od
      .detail_sequence ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefieldid
      = od.oe_field_id ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].
      oefieldvalue = od.oe_field_value ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[
      odcnt ].oefielddisplayvalue = od.oe_field_display_value ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].detaillist[odcnt ].oefieldmeaningid = od.oe_field_meaning_id ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefieldmeaning = od.oe_field_meaning ,
      orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefielddttmvalue = od
      .oe_field_dt_tm_value ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].
      oefieldtz = od.oe_field_tz
     ENDIF
    ENDIF
   DETAIL
    IF ((locateval (x ,1 ,nfacactualsize ,e.loc_facility_cd ,facility_list->qual[x ].facility_cd ) >
    0 ) ) i = 0 ,
     CALL echo ("Detail" ) ,
     CALL echo (build ("oiHit --" ,oihit ) ) ,
     IF ((oihit > 0 ) ) oicnt = oi.comp_sequence ,stat = alterlist (orderrec->orderlist[ordcnt ].
       actionlist[oacnt ].subcomponentlist ,oicnt ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].sccompsequence = oi.comp_sequence ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].subcomponentlist[oicnt ].scfrequency = oi.freq_cd ,orderrec->orderlist[
      ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].sccatalogcd = oi.catalog_cd ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].sccatalogtypecd = oi
      .catalog_type_cd ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].
      scsynonymid = oi.synonym_id ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[
      oicnt ].scordermnemonic = oi.order_mnemonic ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].scorderdetaildisplayline = oi.order_detail_display_line ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scstrength = round (oi.strength
       ,4 ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scstrengthunit
      = oi.strength_unit ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].
      scvolume = round (oi.volume ,2 ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].scvolumeunit = oi.volume_unit ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].subcomponentlist[oicnt ].scfreetextdose = oi.freetext_dose ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scivseq = oi.iv_seq ,
      CALL echo (build ("op_hit --" ,op_hit ) ) ,
      IF ((op_hit > 0 ) ) temp_idx = oi.comp_sequence ,
       IF ((cnvtupper (trim ( $SEARCHTYPE ) ) IN ("INVESTIGATIONAL" ,
       "NON FORMULARY" ) )
       AND (oii.identifier_type_cd = clabel ) )
        FOR (i = 1 TO cntr )
         IF ((op.item_id = orderrec->qual[i ].item_id ) ) orderrec->orderlist[ordcnt ].
          sort_label_desc = substring (1 ,50 ,oii.value ) ,i = cntr
         ENDIF
        ENDFOR
       ENDIF
       ,
       CALL echo (build ("oii identifier_type_cd --" ,oii.identifier_type_cd ) ) ,
       CALL echo (build ("cGeneric --" ,cgeneric ) ) ,
       IF ((oii.identifier_type_cd = cgeneric ) ) orderrec->orderlist[ordcnt ].actionlist[oacnt ].
        subcomponentlist[temp_idx ].scgenericname = substring (1 ,50 ,oii.value )
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,check ,outerjoin = do4 ,outerjoin = ea ,dontcare = ea ,outerjoin = do1 ,outerjoin
    = do2
  ;end select
 ELSE
  CALL echo ("New Formulary" )
  SELECT INTO "NL:"
   o.order_id ,
   ordactseq = concat (cnvtstring (o.order_id ) ,cnvtstring (o.last_action_sequence ) ) ,
   ordsubseq = concat (cnvtstring (oi.order_id ) ,cnvtstring (oi.action_sequence ) ,cnvtstring (oi
     .comp_sequence ) ) ,
   oihit = decode (oi.comp_sequence ,oi.comp_sequence ,0 ) ,
   orddetseq = concat (cnvtstring (od.order_id ) ,cnvtstring (od.action_sequence ) ,cnvtstring (od
     .detail_sequence ) ) ,
   odhit = decode (od.detail_sequence ,od.detail_sequence ,0 ) ,
   op_hit = decode (op.seq ,1 ,0 ) ,
   prod_name = substring (1 ,30 ,mi.value ) ,
   o.order_status_cd ,
   o.projected_stop_dt_tm ,
   o.projected_stop_tz ,
   o.current_start_dt_tm ,
   o.current_start_tz ,
   o.dept_misc_line ,
   o.last_action_sequence ,
   e.encntr_id ,
   e.loc_facility_cd ,
   ea.alias ,
   ea.alias_pool_cd ,
   p.name_full_formatted ,
   od.order_id ,
   od.action_sequence ,
   od.detail_sequence ,
   od.oe_field_id ,
   od.oe_field_value ,
   od.oe_field_display_value ,
   od.oe_field_meaning_id ,
   od.oe_field_meaning ,
   od.oe_field_dt_tm_value ,
   od.oe_field_tz ,
   oi.comp_sequence ,
   oi.freq_cd ,
   oi.catalog_cd ,
   oi.catalog_type_cd ,
   oi.synonym_id ,
   oi.order_mnemonic ,
   oi.order_detail_display_line ,
   oi.strength ,
   oi.strength_unit ,
   oi.volume ,
   oi.volume_unit ,
   oi.freetext_dose ,
   oi.iv_seq ,
   mi.med_identifier_type_cd ,
   mi.value ,
   mi.med_identifier_type_cd ,
   op.item_id ,
   loc_s =
   IF ((o.encntr_id > 0 ) ) uar_get_code_description (e.loc_nurse_unit_cd )
   ELSE uar_get_code_description (odsp.future_loc_nurse_unit_cd )
   ENDIF
   ,facility_area =
   IF ((o.encntr_id > 0 ) ) uar_get_code_display (e.loc_facility_cd )
   ELSE uar_get_code_display (odsp.future_loc_facility_cd )
   ENDIF
   ,loc_bed_s =
   IF ((o.encntr_id > 0 ) ) uar_get_code_display (e.loc_bed_cd )
   ELSE ""
   ENDIF
   ,loc_room_s =
   IF ((o.encntr_id > 0 ) ) uar_get_code_display (e.loc_room_cd )
   ELSE ""
   ENDIF
   ,dfacilityareacd =
   IF ((o.encntr_id > 0 ) ) e.loc_facility_cd
   ELSE odsp.future_loc_facility_cd
   ENDIF
   FROM (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) ),
    (orders o ),
    (order_dispense odsp ),
    (order_ingredient oi ),
    (order_detail od ),
    (order_product op ),
    (med_identifier mi ),
    (person p ),
    (encounter e ),
    (encntr_alias ea ),
    (dummyt do4 WITH seq = 1 ),
    (dummyt do1 WITH seq = 1 ),
    (dummyt do2 WITH seq = 1 )
   PLAN (d
    WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
    AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
    JOIN (o
    WHERE expand (nexpand ,nexpand_start ,nexpand_stop ,o.order_id ,orderlist->data[nexpand ].
     order_id ) )
    JOIN (odsp
    WHERE (odsp.order_id = o.order_id ) )
    JOIN (p
    WHERE (p.person_id = (o.person_id + 0 ) ) )
    JOIN (e
    WHERE (e.encntr_id = (o.encntr_id + 0 ) ) )
    JOIN (do4 )
    JOIN (ea
    WHERE (ea.encntr_id = (e.encntr_id + 0 ) )
    AND ((ea.encntr_alias_type_cd + 0 ) = cfinnbr )
    AND ((ea.active_ind + 0 ) = 1 )
    AND ((ea.beg_effective_dt_tm + 0 ) <= cnvtdatetime (curdate ,curtime ) )
    AND ((ea.end_effective_dt_tm + 0 ) >= cnvtdatetime (curdate ,curtime ) ) )
    JOIN (do1
    WHERE (do1.seq = 1 ) )
    JOIN (od
    WHERE (od.order_id = (o.order_id + 0 ) )
    AND ((od.oe_field_meaning_id + 0 ) IN (cfreq ,
    crate ,
    croute ,
    cinfuseoverunit ,
    cinfuseover ,
    cschprn ,
    crepl ,
    creplunit ,
    cordertype ,
    ctitrate ,
    ctreatmentperiod ) ) )
    JOIN (oi
    WHERE (oi.order_id = (o.order_id + 0 ) )
    AND (oi.action_sequence = (o.last_ingred_action_sequence + 0 ) ) )
    JOIN (do2 )
    JOIN (op
    WHERE (op.order_id = (oi.order_id + 0 ) )
    AND (op.action_sequence = (oi.action_sequence + 0 ) )
    AND (op.ingred_sequence = (oi.comp_sequence + 0 ) ) )
    JOIN (mi
    WHERE (mi.item_id = (op.item_id + 0 ) )
    AND (mi.med_product_id = 0 )
    AND (mi.med_identifier_type_cd IN (clabel ,
    cgeneric ) )
    AND ((mi.flex_type_cd + 0 ) = csystem )
    AND ((mi.pharmacy_type_cd + 0 ) = cinpatient )
    AND ((mi.primary_ind + 0 ) = 1 ) )
   ORDER BY o.order_id ,
    ordactseq ,
    ordsubseq ,
    orddetseq
   HEAD REPORT
    cnt2 = 0 ,
    stat = alterlist (orderrec->orderlist ,0 )
   HEAD o.order_id
    CALL echo (build ("Head order id --" ,o.order_id ) ) ,
    CALL echo (build ("e loc fac --" ,dfacilityareacd ) ) ,
    IF ((locateval (x ,1 ,nfacactualsize ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0
    ) ) temp_status = uar_get_code_display (o.order_status_cd ) ,medcnt = value (size (orderlist->
       data ,5 ) ) ,qualified = 1 ,ordcnt = (ordcnt + 1 ) ,
     IF ((ordcnt > size (orderrec->orderlist ,5 ) ) ) stat = alterlist (orderrec->orderlist ,(ordcnt
       + 10 ) )
     ENDIF
     ,orderrec->orderlist[ordcnt ].orderid = o.order_id ,orderrec->orderlist[ordcnt ].
     projected_stop_dt_tm = cnvtdatetime (o.projected_stop_dt_tm ) ,orderrec->orderlist[ordcnt ].
     projected_stop_tz = o.projected_stop_tz ,orderrec->orderlist[ordcnt ].current_start_dt_tm =
     cnvtdatetime (o.current_start_dt_tm ) ,orderrec->orderlist[ordcnt ].current_start_tz = o
     .current_start_tz ,orderrec->orderlist[ordcnt ].loc_s = substring (1 ,30 ,loc_s ) ,orderrec->
     orderlist[ordcnt ].loc_room_s = substring (1 ,10 ,loc_room_s ) ,orderrec->orderlist[ordcnt ].
     loc_bed_s = substring (1 ,10 ,loc_bed_s ) ,orderrec->orderlist[ordcnt ].facility = substring (1
      ,30 ,facility_area ) ,orderrec->orderlist[ordcnt ].name = p.name_full_formatted ,orderrec->
     orderlist[ordcnt ].deptmiscline = o.dept_misc_line ,orderrec->orderlist[ordcnt ].fin_nbr =
     cnvtalias (ea.alias ,ea.alias_pool_cd ) ,orderrec->orderlist[ordcnt ].order_status = o
     .order_status_cd ,orderrec->orderlist[ordcnt ].all_unverified_ind = 1 ,orderrec->orderlist[
     ordcnt ].encntr_id = e.encntr_id ,orderrec->orderlist[ordcnt ].person_id = o.person_id ,oacnt =
     0 ,oicnt = 0
    ENDIF
   HEAD ordactseq
    IF ((locateval (x ,1 ,nfacactualsize ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0
    ) )
     CALL echo (build ("Head ordActseq --" ,ordactseq ) ) ,qualified = 1 ,orderrec->orderlist[ordcnt
     ].qualified = "Y" ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "TEMPLATE NON FORMULARY" ) ) nindex = locateval (x ,1 ,
       nactual_size ,o.order_id ,orderlist->data[x ].order_id ) ,orderrec->orderlist[ordcnt ].
      tnf_description = orderlist->data[nindex ].tnf_description ,orderrec->orderlist[ordcnt ].
      comp_sequence = orderlist->data[nindex ].comp_sequence ,orderrec->orderlist[ordcnt ].
      formulary_status = orderlist->data[nindex ].formulary_status ,orderrec->orderlist[ordcnt ].
      drug_qualified = "Y"
     ENDIF
     ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) IN ("INVESTIGATIONAL" ,
     "NON FORMULARY" ) ) ) orderrec->orderlist[ordcnt ].drug_qualified = "Y"
     ENDIF
     ,oacnt = (oacnt + 1 ) ,stat = alterlist (orderrec->orderlist[ordcnt ].actionlist ,oacnt ) ,
     orderrec->orderlist[ordcnt ].actionlist[1 ].actionsequence = o.last_action_sequence ,orderrec->
     orderlist[ordcnt ].actionlist[1 ].deptstatuscd = orderrec->orderlist[ordcnt ].order_status ,
     oicnt = 0 ,odcnt = 0 ,addedcomp = 0
    ENDIF
   HEAD orddetseq
    IF ((locateval (x ,1 ,nfacactualsize ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0
    ) )
     CALL echo (build ("Head ordActseq --" ,orddetseq ) ) ,
     CALL echo (build ("odHit --" ,odhit ) ) ,
     IF ((odhit > 0 ) )
      CALL echo (build ("storing --" ,od.oe_field_meaning ) ) ,odcnt = (odcnt + 1 ) ,stat =
      alterlist (orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist ,odcnt ) ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].orderid = od.order_id ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].actionsequence = od.action_sequence ,
      orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].detailsequence = od
      .detail_sequence ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefieldid
      = od.oe_field_id ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].
      oefieldvalue = od.oe_field_value ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[
      odcnt ].oefielddisplayvalue = od.oe_field_display_value ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].detaillist[odcnt ].oefieldmeaningid = od.oe_field_meaning_id ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefieldmeaning = od.oe_field_meaning ,
      orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].oefielddttmvalue = od
      .oe_field_dt_tm_value ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].detaillist[odcnt ].
      oefieldtz = od.oe_field_tz
     ENDIF
    ENDIF
   DETAIL
    IF ((locateval (x ,1 ,nfacactualsize ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0
    ) )
     CALL echo ("detail" ) ,
     CALL echo (build ("oiHit --" ,oihit ) ) ,i = 0 ,
     IF ((oihit > 0 ) ) oicnt = oi.comp_sequence ,stat = alterlist (orderrec->orderlist[ordcnt ].
       actionlist[oacnt ].subcomponentlist ,oicnt ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].sccompsequence = oi.comp_sequence ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].subcomponentlist[oicnt ].scfrequency = oi.freq_cd ,orderrec->orderlist[
      ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].sccatalogcd = oi.catalog_cd ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].sccatalogtypecd = oi
      .catalog_type_cd ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].
      scsynonymid = oi.synonym_id ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[
      oicnt ].scordermnemonic = oi.order_mnemonic ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].scorderdetaildisplayline = oi.order_detail_display_line ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scstrength = round (oi.strength
       ,4 ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scstrengthunit
      = oi.strength_unit ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].
      scvolume = round (oi.volume ,2 ) ,orderrec->orderlist[ordcnt ].actionlist[oacnt ].
      subcomponentlist[oicnt ].scvolumeunit = oi.volume_unit ,orderrec->orderlist[ordcnt ].
      actionlist[oacnt ].subcomponentlist[oicnt ].scfreetextdose = oi.freetext_dose ,orderrec->
      orderlist[ordcnt ].actionlist[oacnt ].subcomponentlist[oicnt ].scivseq = oi.iv_seq ,
      IF ((op_hit > 0 ) ) temp_idx = oi.comp_sequence ,
       IF ((cnvtupper (trim ( $SEARCHTYPE ) ) IN ("INVESTIGATIONAL" ,
       "NON FORMULARY" ) )
       AND (mi.med_identifier_type_cd = clabel ) )
        FOR (i = 1 TO cntr )
         IF ((op.item_id = orderrec->qual[i ].item_id ) ) orderrec->orderlist[ordcnt ].
          sort_label_desc = substring (1 ,50 ,mi.value ) ,i = cntr
         ENDIF
        ENDFOR
       ENDIF
       ,
       CALL echo (build ("mi med_identifier_type_cd --" ,mi.med_identifier_type_cd ) ) ,
       CALL echo (build ("cGeneric --" ,cgeneric ) ) ,
       IF ((mi.med_identifier_type_cd = cgeneric ) ) orderrec->orderlist[ordcnt ].actionlist[oacnt ].
        subcomponentlist[temp_idx ].scgenericname = substring (1 ,50 ,mi.value )
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,check ,outerjoin = do4 ,outerjoin = ea ,dontcare = ea ,outerjoin = do1 ,outerjoin
    = do2
  ;end select
 ENDIF
 SET stat = alterlist (orderrec->orderlist ,ordcnt )
 CALL echo (build ("Order Rec size ==" ,size (orderrec->orderlist ,5 ) ) )
 SET printfile = "cer_print:rxssi.dat"
 CALL echo ("Entering output join" )

 SELECT
  IF ((cnvtupper (trim ( $OUTDEV ) ) != "MINE" ) )
   WITH dio = postscript ,maxrow = 46 ,maxcol = 300 ,counter ,format ,format = variable ,nullreport
  ELSE
  ENDIF
  INTO  $OUTDEV
  facility_area = orderrec->orderlist[d.seq ].facility ,
  loc_s = orderrec->orderlist[d.seq ].loc_s ,
  room_s = orderrec->orderlist[d.seq ].loc_room_s ,
  bed_s = orderrec->orderlist[d.seq ].loc_bed_s ,
  fin_nbr = orderrec->orderlist[d.seq ].fin_nbr ,
  name = orderrec->orderlist[d.seq ].name ,
  encntr = orderrec->orderlist[d.seq ].encntr_id ,
  dpersonid = orderrec->orderlist[d.seq ].person_id,
  order_id = orderrec->orderlist[d.seq ].orderid ,
  gen_name = orderrec->orderlist[d.seq ].sort_label_desc ,
  tnf_desc = orderrec->orderlist[d.seq ].tnf_description ,
  order_status = uar_Get_code_display(orderrec->orderlist[d.seq ].order_status),
  current_start_dt_tm = format(orderrec->orderlist[d.seq ].current_start_dt_tm,";;q") ,
  projected_stop_dt_tm = format(orderrec->orderlist[d.seq ].projected_stop_dt_tm,";;q")
  FROM (dummyt d WITH seq = value (size (orderrec->orderlist ,5 ) ) )
  PLAN (d
   WHERE (orderrec->orderlist[d.seq ].qualified = "Y" )
   AND (orderrec->orderlist[d.seq ].drug_qualified = "Y" ) )
  ORDER BY facility_area ,	
   loc_s ,
   dpersonid ,
   encntr ,
   gen_name ,
   order_id
 
  WITH nocounter ,maxcol = 300 ,nullreport ,format ,format = variable
 ;end select
#exit_script
 CALL echo ("Last Mod = 016" )
 CALL echo ("Mod Date = 03/01/2012" )
END GO

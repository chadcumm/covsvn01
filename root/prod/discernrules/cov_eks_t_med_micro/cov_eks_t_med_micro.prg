/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/22/2020
  Solution:           
  Source file name:   cov_eks_t_med_micro.prg
  Object name:        cov_eks_t_med_micro
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   02/22/2020  Chad Cummings			Initial Release
******************************************************************************/
DROP PROGRAM cov_eks_t_med_micro :dba GO
CREATE PROGRAM cov_eks_t_med_micro :dba

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 date_time	= vc
	1 filename_a      = vc
	1 filename_b    = vc
	1 filename_c = vc
	1 filename_d = vc
	1 filename_e = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)

set t_Rec->date_time = trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d"))

set t_rec->filename_a = concat("cclscratch:med_micro_","medicationlist",".dat")
set t_rec->filename_b = concat("cclscratch:med_micro_","medication_cd",".dat")
set t_rec->filename_c = concat("cclscratch:med_micro_","",".dat")
set t_rec->filename_d = concat("cclscratch:med_micro_","",".dat")

 DECLARE msg = vc WITH protect
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim (eks_common->cur_module_name )
 SET eksmodule = trim (ttemp )
 FREE SET ttemp
 SET ttemp = trim (eks_common->event_name )
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF (NOT ((validate (eksdata->tqual ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual ,"Z" ) = "Z" ) ) )
  FREE SET templatetype
  IF ((conclude > 0 ) )
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt + evokecnt )
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo (concat ("****  " ,format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,
    "hh:mm:ss.cc;3;m" ) ,"     Module:  " ,trim (eksmodule ) ,"  ****" ) ,1 ,0 )
 IF ((validate (tname ,"Y" ) = "Y" )
 AND (validate (tname ,"Z" ) = "Z" ) )
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,")           Event:  " ,trim (eksevent ) ,"         Request number:  " ,cnvtstring (
      eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning an Evoke Template" ,"           Event:  " ,trim (eksevent
      ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ELSE
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,"):  " ,trim (tname ) ,"       Event:  " ,trim (eksevent ) ,"         Request number:  " ,
     cnvtstring (eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning Evoke Template:  " ,trim (tname ) ,"       Event:  " ,
     trim (eksevent ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ENDIF
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******  Beginning of Program eks_t_med_micro  *********" ) ,1 ,0 )
 DECLARE parsearguments ((strvararg = vc ) ,(strdelimiter = vc ) ,(result = vc (ref ) ) ) = null
 RECORD event_set_namelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD sourcelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD organismlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD medicationlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD chart_flaglist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD suscept_detaillist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD qual_valuelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 DECLARE any_event_set_name = i2
 DECLARE any_source = i2
 DECLARE any_organism = i2
 DECLARE any_antibiotic = i2
 DECLARE opt_time_qual_text = vc
 DECLARE opt_time_value_num = i4
 DECLARE time_ind = i2
 DECLARE spindexlink = vc
 DECLARE idx1 = i4 WITH protect
 DECLARE idx2 = i4 WITH protect
 DECLARE idx3 = i4 WITH protect
 DECLARE idx4 = i4 WITH protect
 DECLARE idx5 = i4 WITH protect
 DECLARE idx6 = i4 WITH protect
 DECLARE idx7 = i4 WITH protect
 DECLARE chart_flag1 = i2 WITH protect
 DECLARE chart_flag2 = i2 WITH protect
 RECORD source_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 RECORD organism_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 RECORD antibiotic_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
     2 order_dt_tm = dq8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD suscept_detail_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 RECORD qual_value_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 RECORD medication_cd (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
     2 order_id = f8
     2 order_dt_tm = dq8
 )
 RECORD clinical_event_id (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 RECORD order_id (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
     2 comp_seq = i4
 )
 RECORD tmpmisc (
   1 count = i2
   1 items [25 ]
     2 value = c1024
 )
 DECLARE timecheck ((cd = f8 ) ,(dt = f8 ) ) = i2
 RECORD tmprec (
   1 cnt = i4
   1 qual [* ]
     2 fval1 = f8
     2 fval2 = f8
     2 ival1 = i4
     2 ival2 = i4
     2 dt = dq8
 ) WITH protect
 DECLARE i = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE lqual = vc WITH protect
 DECLARE starttime3 = f8 WITH private
 SET starttime3 = curtime3
 SET eksinx = eks_common->event_repeat_index
 SET personid = event->qual[eksinx ].person_id
 IF ((personid <= 0 ) )
  SET msg = "There is no personid set up in the event"
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SET encntrid = event->qual[eksinx ].encntr_id
 SET tmpcurdttm = cnvtdatetime (curdate ,curtime3 )
 IF ((validate (opt_med ,"Z" ) = "Z" )
 AND (validate (opt_med ,"Y" ) = "Y" ) )
  SET msg = "OPT_MED parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_med
  EXECUTE eks_t_parse_list WITH replace (reply ,medicationlist )
  FREE SET orig_param
  SET any_antibiotic = 0
  IF ((medicationlist->cnt <= 0 ) )
   CALL echo ("No medications are specified in OPT_MED parameter!" )
   SET medication_cd->cnt = 0
  ELSE
   SET medication_cd->cnt = medicationlist->cnt
   SET stat = alterlist (medication_cd->qual ,medication_cd->cnt )
   FOR (i = 1 TO medicationlist->cnt )
    IF ((trim (medicationlist->qual[i ].display ) = "*ANY" ) )
     IF ((medicationlist->cnt > 1 ) )
      SET msg = "'*ANY' must be the only entry in the list for OPT_MED."
      SET retval = - (1 )
      GO TO endprogram
     ELSE
      SET any_antibiotic = 1
     ENDIF
    ELSE
     SET medication_cd->qual[i ].value = cnvtreal (medicationlist->qual[i ].value )
     SET medication_cd->qual[i ].order_dt_tm = tmpcurdttm
     SET medication_cd->qual[i ].order_id = 0
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((validate (event_set_name ,"Z" ) = "Z" )
 AND (validate (event_set_name ,"Y" ) = "Y" ) )
  SET msg = "EVENT_SET_NAME parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = event_set_name
  EXECUTE eks_t_parse_list WITH replace (reply ,event_set_namelist )
  FREE SET orig_param
  IF ((event_set_namelist->cnt <= 0 ) )
   SET msg = "No EVENT_SET_NAMEs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   SET any_event_set_name = 0
   CALL echo ("Convert code values into event_set_names." )
   FOR (i = 1 TO event_set_namelist->cnt )
    IF ((trim (event_set_namelist->qual[i ].value ) = "*ANY_EVENT_SET_NAME" ) )
     IF ((event_set_namelist->cnt > 1 ) )
      SET msg = "'*ANY_EVENT_SET_NAME' must be the only entry in the list for EVENT_SET_NAME."
      SET retval = - (1 )
      GO TO endprogram
     ELSE
      SET any_event_set_name = 1
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((validate (source ,"Z" ) = "Z" )
 AND (validate (source ,"Y" ) = "Y" ) )
  SET msg = "SOURCE parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = source
  EXECUTE eks_t_parse_list WITH replace (reply ,sourcelist )
  FREE SET orig_param
  IF ((sourcelist->cnt <= 0 ) )
   SET msg = "No SOURCEs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   SET any_source = 0
   SET source_cd->cnt = sourcelist->cnt
   SET stat = alterlist (source_cd->qual ,source_cd->cnt )
   FOR (i = 1 TO sourcelist->cnt )
    IF ((trim (sourcelist->qual[i ].display ) = "*ANY_SOURCE" ) )
     IF ((sourcelist->cnt > 1 ) )
      SET msg = "'*ANY_SOURCE' must be the only entry in the list for SOURCE."
      SET retval = - (1 )
      GO TO endprogram
     ELSE
      SET any_source = 1
     ENDIF
    ELSE
     SET source_cd->qual[i ].value = cnvtreal (sourcelist->qual[i ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((validate (organism ,"Z" ) = "Z" )
 AND (validate (organism ,"Y" ) = "Y" ) )
  SET msg = "ORGANISM parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = organism
  EXECUTE eks_t_parse_list WITH replace (reply ,organismlist )
  FREE SET orig_param
  IF ((organismlist->cnt <= 0 ) )
   SET msg = "No ORGANISMs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   SET any_organism = 0
   SET organism_cd->cnt = organismlist->cnt
   SET stat = alterlist (organism_cd->qual ,organism_cd->cnt )
   FOR (i = 1 TO organismlist->cnt )
    IF ((trim (organismlist->qual[i ].display ) = "*ANY_ORGANISM" ) )
     IF ((organismlist->cnt > 1 ) )
      SET msg = "'*ANY_ORGANISM' must be the only entry in the list for ORGANISM."
      SET retval = - (1 )
      GO TO endprogram
     ELSE
      SET any_organism = 1
     ENDIF
    ELSE
     SET organism_cd->qual[i ].value = cnvtreal (organismlist->qual[i ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((validate (chart_flag ,"Z" ) = "Z" )
 AND (validate (chart_flag ,"Y" ) = "Y" ) )
  SET msg = "CHART_FLAG parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = chart_flag
  EXECUTE eks_t_parse_list WITH replace (reply ,chart_flaglist )
  FREE SET orig_param
  IF ((chart_flaglist->cnt <= 0 ) )
   SET msg = "No CHART_FLAGs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   FOR (i = 1 TO chart_flaglist->cnt )
    IF (NOT ((cnvtlower (trim (chart_flaglist->qual[i ].value ) ) IN ("chartable" ,
    "non chartable" ) ) ) )
     SET msg = concat ("Invalid entry of '" ,trim (chart_flag ) ,"' in CHART_FLAG parameter." )
     SET retval = - (1 )
     GO TO endprogram
    ELSE
     IF ((cnvtlower (trim (chart_flaglist->qual[i ].value ) ) = "chartable" ) )
      SET chart_flag1 = 1
     ENDIF
    ENDIF
   ENDFOR
   IF ((chart_flaglist->cnt = 1 ) )
    SET chart_flag2 = chart_flag1
   ENDIF
  ENDIF
 ENDIF
 IF ((validate (suscept_detail ,"Z" ) = "Z" )
 AND (validate (suscept_detail ,"Y" ) = "Y" ) )
  SET msg = "SUSCEPT_DETAIL parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = suscept_detail
  EXECUTE eks_t_parse_list WITH replace (reply ,suscept_detaillist )
  FREE SET orig_param
  IF ((suscept_detaillist->cnt <= 0 ) )
   SET msg = "No SUSCEPT_DETAILs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   SET suscept_detail_cd->cnt = suscept_detaillist->cnt
   SET stat = alterlist (suscept_detail_cd->qual ,suscept_detail_cd->cnt )
   FOR (i = 1 TO suscept_detaillist->cnt )
    SET suscept_detail_cd->qual[i ].value = cnvtreal (suscept_detaillist->qual[i ].value )
   ENDFOR
  ENDIF
 ENDIF
 IF ((validate (qual ,"Z" ) = "Z" )
 AND (validate (qual ,"Y" ) = "Y" ) )
  SET msg = "QUAL parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET lqual = cnvtlower (trim (qual ) )
  IF (NOT ((lqual IN ("is" ,
  "is not" ) ) ) )
   SET msg = concat ("Invalid entry of '" ,trim (qual ) ,"' in QUAL parameter." )
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((validate (qual_value ,"Z" ) = "Z" )
 AND (validate (qual_value ,"Y" ) = "Y" ) )
  SET msg = "QUAL_VALUE parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = qual_value
  EXECUTE eks_t_parse_list WITH replace (reply ,qual_valuelist )
  FREE SET orig_param
  IF ((qual_valuelist->cnt <= 0 ) )
   SET msg = "No QUAL_VALUEs were specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   SET qual_value_cd->cnt = qual_valuelist->cnt
   SET stat = alterlist (qual_value_cd->qual ,qual_value_cd->cnt )
   FOR (i = 1 TO qual_valuelist->cnt )
    SET qual_value_cd->qual[i ].value = cnvtreal (qual_valuelist->qual[i ].value )
   ENDFOR
  ENDIF
 ENDIF
 CALL echo ("Checking time range." )
 IF ((validate (opt_time_qual ,"Z" ) = "Z" )
 AND (validate (opt_time_qual ,"Y" ) = "Y" ) )
  SET msg = "OPT_TIME_QUAL parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET opt_time_qual_text = cnvtlower (trim (opt_time_qual ) )
  SET time_ind = 1
  IF ((((opt_time_qual_text = "" ) ) OR ((opt_time_qual_text = "<undefined>" ) )) )
   SET time_ind = 0
  ELSEIF (NOT ((opt_time_qual_text IN ("less than" ,
  "greater than" ,
  "within" ,
  "outside" ) ) ) )
   SET msg = concat ("Invalid entry of " ,trim (opt_time_qual ) ," in OPT_TIME_QUAL parameter." )
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((validate (opt_time_value ,"Z" ) = "Z" )
 AND (validate (opt_time_value ,"Y" ) = "Y" ) )
  SET msg = "OPT_TIME_VALUE parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET opt_time_value_num = 0
  IF ((((trim (opt_time_value ) = "<undefined>" ) ) OR ((trim (opt_time_value ) = "" ) )) )
   IF ((time_ind = 1 ) )
    SET msg = concat ("OPT_TIME_QUAL is specified but OPT_TIME_VALUE is not used." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   SET time_ind = 0
  ELSEIF (isnumeric (trim (opt_time_value ) ) )
   SET opt_time_value_num = cnvtint (trim (opt_time_value ) )
  ELSE
   SET msg = concat ("Invalid entry of " ,trim (opt_time_value ) ," in OPT_TIME_VALUE parameter." )
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((validate (opt_time_unit ,"Z" ) = "Z" )
 AND (validate (opt_time_unit ,"Y" ) = "Y" ) )
  SET msg = "OPT_TIME_UNIT parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  IF ((trim (opt_time_unit ) > "" )
  AND (trim (opt_time_unit ) != "<undefined>" )
  AND (time_ind = 0 ) )
   SET msg = "OPT_TIME_UNIT is specified but OPT_TIME_VALUE is not used."
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((trim (opt_time_unit ) = "" ) ) OR ((trim (opt_time_unit ) = "<undefined>" ) ))
  AND (time_ind = 1 ) )
   SET msg = "OPT_TIME_UNIT is not specified."
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((time_ind = 1 )
  AND NOT ((cnvtlower (trim (opt_time_unit ) ) IN ("minutes" ,
  "hours" ,
  "days" ) ) ) )
   SET msg = concat ("Invalid entry of " ,trim (opt_time_unit ) ," in OPT_TIME_UNIT parameter." )
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((time_ind = 1 ) )
   IF ((cnvtlower (trim (opt_time_unit ) ) = "minutes" ) )
    SET interval_type = "MIN"
   ELSEIF ((cnvtlower (trim (opt_time_unit ) ) = "hours" ) )
    SET interval_type = "H"
   ELSE
    SET interval_type = "D"
   ENDIF
   SET time_interval = concat (trim (opt_time_value ) ,interval_type )
  ELSE
   SET time_interval = "0D"
  ENDIF
 ENDIF
 IF ((time_ind = 0 ) )
  CALL echo ("Time range is not specified." )
 ELSE
  CALL echo (concat ("Time range is " ,opt_time_qual_text ," " ,trim (cnvtstring (opt_time_value_num
      ) ) ," " ,trim (opt_time_unit ) ) )
 ENDIF
 IF ((validate (opt_link ,"Z" ) = "Z" )
 AND (validate (opt_link ,"Y" ) = "Y" ) )
  SET msg = "OPT_LINK parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET nlink = cnvtint (opt_link )
  CALL echo (concat ("Link value is " ,opt_link ) )
  IF ((nlink <= 0 )
  AND (medicationlist->cnt <= 0 )
  AND (any_antibiotic = 0 ) )
   SET msg = "Either OPT_LINK or OPT_MED should be instantiated!"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((nlink <= 0 ) )
   CALL echo ("Link is not specified!" )
  ELSE
   SET personid = eksdata->tqual[tcurindex ].qual[nlink ].person_id
   SET encntrid = eksdata->tqual[tcurindex ].qual[nlink ].encntr_id
   SET misc_len = size (eksdata->tqual[tcurindex ].qual[nlink ].data ,5 )
   IF ((misc_len <= 0 ) )
    SET msg = "MISC record is not found."
    SET retval = 0
    GO TO endprogram
   ELSE
    CALL echo (concat ("Size of MISC structure - " ,cnvtstring (size (eksdata->tqual[tcurindex ].
        qual[nlink ].data ,5 ) ) ) )
    CALL echo ("Content of MISC structure:" )
    FOR (i = 1 TO size (eksdata->tqual[tcurindex ].qual[nlink ].data ,5 ) )
     CALL echo (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc )
    ENDFOR
    SET header_found = 0
    SET clinical_event_id->cnt = 0
    FOR (i = 1 TO misc_len )
     IF ((substring (1 ,1 ,trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) ) = "<" ) )
      IF ((cnvtupper (trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) ) = "<SPINDEX>"
      ) )
       SET header_found = 1
       CALL echo ("<SPINDEX> is found in MISC structure." )
      ELSEIF ((cnvtupper (trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) ) =
      "<ORDER_ID>" ) )
       SET header_found = 2
       CALL echo ("<ORDER_ID> is found in MISC structure." )
      ELSEIF ((cnvtupper (trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) ) =
      "<CLINICAL_EVENT_ID>" ) )
       SET header_found = 3
       CALL echo ("<CLINICAL_EVENT_ID> is found in MISC structure." )
      ELSE
       SET header_found = 0
      ENDIF
     ELSE
      IF ((header_found = 1 ) )
       SET pipepos = findstring ("|" ,eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ,1 )
       IF ((pipepos > 0 ) )
        SET spindexlink = substring (1 ,(pipepos - 1 ) ,eksdata->tqual[tcurindex ].qual[nlink ].data[
         i ].misc )
       ELSE
        SET spindexlink = eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc
       ENDIF
       CALL parsearguments (spindexlink ,":" ,tmpmisc )
       IF ((tmpmisc->count > 0 ) )
        SET medication_cd->cnt = (medication_cd->cnt + 1 )
        SET stat = alterlist (medication_cd->qual ,medication_cd->cnt )
        IF ((tmpmisc->count = 1 )
        AND isnumeric (trim (tmpmisc->items[1 ].value ) ) )
         SET tmpindex1 = cnvtint (trim (tmpmisc->items[1 ].value ) )
         SET tmpindex2 = 0
         SET medication_cd->qual[medication_cd->cnt ].value = request->orderlist[tmpindex1 ].
         catalog_code
         SET medication_cd->qual[medication_cd->cnt ].order_id = request->orderlist[tmpindex1 ].
         orderid
         SET medication_cd->qual[medication_cd->cnt ].order_dt_tm = tmpcurdttm
        ELSEIF ((tmpmisc->count = 2 )
        AND isnumeric (trim (tmpmisc->items[1 ].value ) )
        AND isnumeric (trim (tmpmisc->items[2 ].value ) ) )
         SET tmpindex1 = cnvtint (trim (tmpmisc->items[1 ].value ) )
         SET tmpindex2 = cnvtint (trim (tmpmisc->items[2 ].value ) )
         SET medication_cd->qual[medication_cd->cnt ].value = request->orderlist[tmpindex1 ].
         ingredientlist[tmpindex2 ].catalogcd
         SET medication_cd->qual[medication_cd->cnt ].order_id = request->orderlist[tmpindex1 ].
         orderid
         SET medication_cd->qual[medication_cd->cnt ].order_dt_tm = tmpcurdttm
        ELSE
         SET msg = concat ("Invalid data in MISC field - " ,eksdata->tqual[tcurindex ].qual[nlink ].
          data[i ].misc )
         SET retval = - (1 )
         GO TO endprogram
        ENDIF
       ELSE
        SET msg = "MISC field doesn't contain any data!"
        SET retval = - (1 )
        GO TO endprogram
       ENDIF
      ELSEIF ((header_found = 2 ) )
       CALL parsearguments (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ,":" ,tmpmisc )
       IF ((tmpmisc->count > 0 )
       AND isnumeric (trim (tmpmisc->items[1 ].value ) ) )
        SET order_id->cnt = (order_id->cnt + 1 )
        SET stat = alterlist (order_id->qual ,order_id->cnt )
        SET order_id->qual[order_id->cnt ].value = cnvtreal (trim (tmpmisc->items[1 ].value ) )
        SET order_id->qual[order_id->cnt ].comp_seq = cnvtint (trim (tmpmisc->items[2 ].value ) )
       ENDIF
      ELSEIF ((header_found = 3 ) )
       CALL echo (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc )
       IF (isnumeric (trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) )
       AND (cnvtreal (trim (eksdata->tqual[tcurindex ].qual[nlink ].data[i ].misc ) ) > 0 ) )
        SET clinical_event_id->cnt = (clinical_event_id->cnt + 1 )
        SET stat = alterlist (clinical_event_id->qual ,clinical_event_id->cnt )
        SET clinical_event_id->qual[clinical_event_id->cnt ].value = cnvtreal (trim (eksdata->tqual[
          tcurindex ].qual[nlink ].data[i ].misc ) )
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 IF ((medication_cd->cnt > 0 ) )
  SET stat = alterlist (tmprec->qual ,medication_cd->cnt )
  FOR (idx1 = 1 TO medication_cd->cnt )
   IF ((medication_cd->qual[idx1 ].value > 0 )
   AND (medication_cd->qual[idx1 ].order_id > 0 ) )
    SET tmprec->cnt = (tmprec->cnt + 1 )
    SET tmprec->qual[tmprec->cnt ].fval1 = medication_cd->qual[idx1 ].order_id
   ENDIF
  ENDFOR
  SET stat = alterlist (tmprec->qual ,tmprec->cnt )
  IF ((tmprec->cnt > 0 ) )
   SELECT INTO "nl:"
    FROM (orders o )
    WHERE expand (idx1 ,1 ,tmprec->cnt ,o.order_id ,tmprec->qual[idx1 ].fval1 )
    DETAIL
     pos = locateval (idx2 ,1 ,medication_cd->cnt ,o.order_id ,medication_cd->qual[idx2 ].order_id )
     ,
     WHILE ((pos > 0 ) )
      medication_cd->qual[pos ].order_dt_tm = cnvtdatetime (o.orig_order_dt_tm ) ,pos = locateval (
       idx2 ,(pos + 1 ) ,medication_cd->cnt ,o.order_id ,medication_cd->qual[idx2 ].order_id )
     ENDWHILE
    WITH expand = 1 ,nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((order_id->cnt > 0 ) )
  SELECT INTO "nl:"
   FROM (orders o )
   WHERE expand (idx1 ,1 ,order_id->cnt ,o.order_id ,order_id->qual[idx1 ].value ,0 ,order_id->qual[
    idx1 ].comp_seq )
   DETAIL
    medication_cd->cnt = (medication_cd->cnt + 1 ) ,
    stat = alterlist (medication_cd->qual ,medication_cd->cnt ) ,
    medication_cd->qual[medication_cd->cnt ].value = o.catalog_cd ,
    medication_cd->qual[medication_cd->cnt ].order_dt_tm = cnvtdatetime (o.orig_order_dt_tm ) ,
    medication_cd->qual[medication_cd->cnt ].order_id = o.order_id
   WITH nocounter ,expand = 1
  ;end select
  SET tmprec->cnt = 0
  SET stat = alterlist (tmprec->qual ,order_id->cnt )
  FOR (idx1 = 1 TO order_id->cnt )
   IF ((order_id->qual[idx1 ].value > 0 )
   AND (order_id->qual[idx1 ].comp_seq > 0 ) )
    SET tmprec->cnt = (tmprec->cnt + 1 )
    SET tmprec->qual[tmprec->cnt ].fval1 = order_id->qual[idx1 ].value
    SET tmprec->qual[tmprec->cnt ].ival1 = order_id->qual[idx1 ].comp_seq
   ENDIF
  ENDFOR
  SET stat = alterlist (tmprec->qual ,tmprec->cnt )
  IF ((tmprec->cnt > 0 ) )
   SET action_sequence_flag = 0
   SELECT INTO "nl:"
    FROM (order_ingredient oi ),
     (orders o )
    PLAN (oi
     WHERE expand (idx1 ,1 ,order_id->cnt ,oi.order_id ,tmprec->qual[idx1 ].fval1 ,oi.comp_sequence ,
      tmprec->qual[idx1 ].ival1 ) )
     JOIN (o
     WHERE (o.order_id = oi.order_id ) )
    ORDER BY oi.order_id ,
     oi.action_sequence DESC
    HEAD oi.order_id
     action_sequence_flag = 0
    DETAIL
     IF ((action_sequence_flag = 0 ) ) medication_cd->cnt = (medication_cd->cnt + 1 ) ,stat =
      alterlist (medication_cd->qual ,medication_cd->cnt ) ,medication_cd->qual[medication_cd->cnt ].
      value = oi.catalog_cd ,medication_cd->qual[medication_cd->cnt ].order_dt_tm = cnvtdatetime (o
       .orig_order_dt_tm ) ,medication_cd->qual[medication_cd->cnt ].order_id = o.order_id ,
      CALL echo (oi.action_sequence ) ,
      CALL echo (oi.comp_sequence )
     ENDIF
    FOOT  oi.action_sequence
     action_sequence_flag = 1
    WITH expand = 1 ,nocounter
   ;end select
  ELSE
   CALL echo ("No orders with ingredients (comp_seq > 0) were found." )
  ENDIF
 ENDIF
 IF ((clinical_event_id->cnt > 0 ) )
  SELECT INTO "nl:"
   FROM (clinical_event ce ),
    (orders o )
   PLAN (ce
    WHERE expand (idx1 ,1 ,clinical_event_id->cnt ,ce.clinical_event_id ,clinical_event_id->qual[
     idx1 ].value )
    AND (ce.order_id != 0 )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (o
    WHERE (o.order_id = ce.order_id )
    AND (o.catalog_cd != 0 )
    AND (o.active_ind > 0 ) )
   DETAIL
    medication_cd->cnt = (medication_cd->cnt + 1 ) ,
    stat = alterlist (medication_cd->qual ,medication_cd->cnt ) ,
    medication_cd->qual[medication_cd->cnt ].value = o.catalog_cd ,
    medication_cd->qual[medication_cd->cnt ].order_dt_tm = cnvtdatetime (o.orig_order_dt_tm ) ,
    medication_cd->qual[medication_cd->cnt ].order_id = o.order_id
   WITH expand = 1 ,nocounter
  ;end select
 ENDIF
 CALL echo ("List of medications:" )
 FOR (i = 1 TO medication_cd->cnt )
  CALL echo (concat ("Catalog_cd = " ,trim (cnvtstring (medication_cd->qual[i ].value ,25 ,1 ) ) ,
    " , " ,"Order_dt_tm = " ,format (medication_cd->qual[i ].order_dt_tm ,";;Q" ) ," , " ,
    "Order_id = " ,trim (cnvtstring (medication_cd->qual[i ].order_id ,25 ,1 ) ) ) )
 ENDFOR
 SET antibiotic_cd->cnt = 0
 IF ((medication_cd->cnt > 0 )
 AND (any_antibiotic = 0 ) )
  SELECT INTO "nl:"
   FROM (eks_micro_med_r emm )
   WHERE expand (idx1 ,1 ,medication_cd->cnt ,emm.catalog_cd ,medication_cd->qual[idx1 ].value )
   AND (emm.active_ind != 0 )
   DETAIL
    pos = locateval (idx2 ,1 ,medication_cd->cnt ,emm.catalog_cd ,medication_cd->qual[idx2 ].value )
    ,
    WHILE ((pos > 0 ) )
     antibiotic_cd->cnt = (antibiotic_cd->cnt + 1 ) ,stat = alterlist (antibiotic_cd->qual ,
      antibiotic_cd->cnt ) ,antibiotic_cd->qual[antibiotic_cd->cnt ].value = emm.antibiotic_cd ,
     antibiotic_cd->qual[antibiotic_cd->cnt ].order_dt_tm = medication_cd->qual[pos ].order_dt_tm ,
     IF ((time_ind = 1 ) ) antibiotic_cd->qual[antibiotic_cd->cnt ].beg_dt_tm = cnvtlookbehind (
       time_interval ,medication_cd->qual[pos ].order_dt_tm ) ,antibiotic_cd->qual[antibiotic_cd->cnt
       ].end_dt_tm = cnvtlookahead (time_interval ,medication_cd->qual[pos ].order_dt_tm )
     ELSE antibiotic_cd->qual[antibiotic_cd->cnt ].beg_dt_tm = medication_cd->qual[pos ].order_dt_tm
     ,antibiotic_cd->qual[antibiotic_cd->cnt ].end_dt_tm = medication_cd->qual[pos ].order_dt_tm
     ENDIF
     ,
     CALL echo (concat ("antibiotic_cd->" ,cnvtstring (emm.antibiotic_cd ,25 ,1 ) ) ) ,
     CALL echo (concat ("Beg_dt_tm = " ,format (antibiotic_cd->qual[antibiotic_cd->cnt ].beg_dt_tm ,
       ";;Q" ) ," , " ,"End_dt_tm = " ,format (antibiotic_cd->qual[antibiotic_cd->cnt ].end_dt_tm ,
       ";;Q" ) ) ) ,pos = locateval (idx2 ,(pos + 1 ) ,medication_cd->cnt ,emm.catalog_cd ,
      medication_cd->qual[idx2 ].value )
    ENDWHILE
   WITH nocounter
  ;end select
 ELSEIF ((any_antibiotic = 1 ) )
  SET antibiotic_cd->cnt = 1
  SET stat = alterlist (antibiotic_cd->qual ,antibiotic_cd->cnt )
  SET antibiotic_cd->qual[antibiotic_cd->cnt ].value = 0.00
  SET antibiotic_cd->qual[antibiotic_cd->cnt ].order_dt_tm = tmpcurdttm
  IF ((time_ind = 1 ) )
   SET antibiotic_cd->qual[antibiotic_cd->cnt ].beg_dt_tm = cnvtlookbehind (time_interval ,
    tmpcurdttm )
   SET antibiotic_cd->qual[antibiotic_cd->cnt ].end_dt_tm = cnvtlookahead (time_interval ,tmpcurdttm
    )
  ELSE
   SET antibiotic_cd->qual[antibiotic_cd->cnt ].beg_dt_tm = tmpcurdttm
   SET antibiotic_cd->qual[antibiotic_cd->cnt ].end_dt_tm = tmpcurdttm
  ENDIF
 ELSE
  SET msg = "No pharmacy orderables are found in OPT_MED parameter or linked template."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 IF ((antibiotic_cd->cnt > 0 ) )
  CALL echo (concat ("Number of antibiotic codes found: " ,trim (cnvtstring (antibiotic_cd->cnt ) )
    ) )
 ELSE
  SET msg = "Antibiotic codes are not found in cross reference table."
  SET retval = 0
  GO TO endprogram
 ENDIF
 SET expmaxcnt = 50
 SET expind = 0
 IF ((((organism_cd->cnt > expmaxcnt ) ) OR ((((antibiotic_cd->cnt > expmaxcnt ) ) OR ((((
 suscept_detail_cd->cnt > expmaxcnt ) ) OR ((((qual_value_cd->cnt > expmaxcnt ) ) OR ((source_cd->cnt
  > expmaxcnt ) )) )) )) )) )
  SET expind = 1
 ENDIF
 SET nstart = 1
 SET cnt = 0
 SELECT
  IF ((any_antibiotic > 0 )
  AND (any_organism > 0 )
  AND (any_source > 0 )
  AND (lqual = "is" ) )
   PLAN (ce
    WHERE (ce.person_id = personid )
    AND (ce.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
    JOIN (cm
    WHERE (cm.event_id = ce.event_id )
    AND (cm.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
    JOIN (cs
    WHERE (cs.event_id = cm.event_id )
    AND (cs.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) )
    AND (cs.micro_seq_nbr = cm.micro_seq_nbr )
    AND expand (idx3 ,1 ,suscept_detail_cd->cnt ,cs.detail_susceptibility_cd ,suscept_detail_cd->
     qual[idx3 ].value )
    AND (cs.chartable_flag IN (chart_flag1 ,
    chart_flag2 ) )
    AND expand (idx4 ,1 ,qual_value_cd->cnt ,cs.result_cd ,qual_value_cd->qual[idx4 ].value ) )
    JOIN (csc
    WHERE (csc.event_id = cs.event_id )
    AND (csc.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
  ELSEIF ((any_antibiotic <= 0 )
  AND (any_organism > 0 )
  AND (any_source > 0 )
  AND (lqual = "is" ) )
   PLAN (ce
    WHERE (ce.person_id = personid )
    AND (ce.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
    JOIN (cm
    WHERE (cm.event_id = ce.event_id )
    AND (cm.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
    JOIN (cs
    WHERE (cs.event_id = cm.event_id )
    AND (cs.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) )
    AND (cs.micro_seq_nbr = cm.micro_seq_nbr )
    AND expand (idx2 ,1 ,antibiotic_cd->cnt ,cs.antibiotic_cd ,antibiotic_cd->qual[idx2 ].value )
    AND expand (idx3 ,1 ,suscept_detail_cd->cnt ,cs.detail_susceptibility_cd ,suscept_detail_cd->
     qual[idx3 ].value )
    AND (cs.chartable_flag IN (chart_flag1 ,
    chart_flag2 ) )
    AND expand (idx4 ,1 ,qual_value_cd->cnt ,cs.result_cd ,qual_value_cd->qual[idx4 ].value ) )
    JOIN (csc
    WHERE (csc.event_id = cs.event_id )
    AND (csc.valid_until_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
  ELSE
   PLAN (ce
    WHERE (ce.person_id = personid )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (cm
    WHERE (cm.event_id = ce.event_id )
    AND (cm.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (((any_organism > 0 ) ) OR (expand (idx1 ,1 ,organism_cd->cnt ,cm.organism_cd ,organism_cd->
     qual[idx1 ].value ) )) )
    JOIN (cs
    WHERE (cs.event_id = cm.event_id )
    AND (cs.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (cs.micro_seq_nbr = cm.micro_seq_nbr )
    AND (((any_antibiotic > 0 ) ) OR (expand (idx2 ,1 ,antibiotic_cd->cnt ,cs.antibiotic_cd ,
     antibiotic_cd->qual[idx2 ].value ) ))
    AND expand (idx3 ,1 ,suscept_detail_cd->cnt ,cs.detail_susceptibility_cd ,suscept_detail_cd->
     qual[idx3 ].value )
    AND (cs.chartable_flag IN (chart_flag1 ,
    chart_flag2 ) )
    AND (((lqual = "is" )
    AND expand (idx4 ,1 ,qual_value_cd->cnt ,cs.result_cd ,qual_value_cd->qual[idx4 ].value ) ) OR ((
    lqual = "is not" )
    AND NOT (expand (idx5 ,1 ,qual_value_cd->cnt ,cs.result_cd ,qual_value_cd->qual[idx5 ].value ) )
    )) )
    JOIN (csc
    WHERE (csc.event_id = cs.event_id )
    AND (csc.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (((any_source > 0 ) ) OR (expand (idx6 ,1 ,source_cd->cnt ,csc.source_type_cd ,source_cd->
     qual[idx6 ].value ) )) )
  ENDIF
  DISTINCT INTO "nl:"
  cs.event_id ,
  cs.micro_seq_nbr ,
  cm.organism_cd ,
  cs.antibiotic_cd ,
  cs.suscep_seq_nbr
  FROM (clinical_event ce ),
   (ce_microbiology cm ),
   (ce_susceptibility cs ),
   (ce_specimen_coll csc )
  ORDER BY cs.event_id ,
   cs.micro_seq_nbr ,
   cm.organism_cd ,
   cs.antibiotic_cd ,
   cs.suscep_seq_nbr
  HEAD REPORT
   mem_ind = 0 ,
   stat = alterlist (eksdata->tqual[tcurindex ].qual[curindex ].data ,1 ) ,
   eksdata->tqual[tcurindex ].qual[curindex ].data[1 ].misc = "<SUSCEPTIBILITY>" ,
   cnt = 1
  DETAIL
   FOR (e_cnt = 1 TO event_set_namelist->cnt )
    mem_ind = 0 ,
    IF ((any_event_set_name = 0 ) )
     IF ((trim (event_set_namelist->qual[e_cnt ].value ) = trim (event_set_namelist->qual[e_cnt ].
      display ) ) ) stat = uar_is_in_eventset (nullterm (trim (event_set_namelist->qual[e_cnt ].
         display ) ) ,ce.event_cd ,mem_ind ,1 )
     ELSE stat = uar_is_in_eventset (nullterm (trim (concat (char (6 ) ,event_set_namelist->qual[
          e_cnt ].value ) ) ) ,ce.event_cd ,mem_ind ,1 )
     ENDIF
     ,
     IF ((stat > 0 ) )
      CALL echo (concat ("UAR status = " ,trim (cnvtstring (stat ) ) ) )
     ENDIF
    ENDIF
    ,
    IF ((((mem_ind > 0 ) ) OR ((any_event_set_name > 0 ) )) )
     IF ((((time_ind = 0 ) ) OR (timecheck (cs.antibiotic_cd ,ce.event_end_dt_tm ) )) ) cnt = (cnt +
      1 ) ,stat = alterlist (eksdata->tqual[tcurindex ].qual[curindex ].data ,cnt ) ,eksdata->tqual[
      tcurindex ].qual[curindex ].data[cnt ].misc = concat (trim (cnvtstring (cs.event_id ,25 ,1 ) )
       ,":" ,trim (cnvtstring (cs.micro_seq_nbr ) ) ,":" ,trim (cnvtstring (cm.organism_cd ,25 ,1 )
        ) ,":" ,trim (cnvtstring (cs.antibiotic_cd ,25 ,1 ) ) ,":" ,trim (cnvtstring (cs
         .suscep_seq_nbr ) ) ) ,
      CALL echo (concat ("Match found for " ,trim (event_set_namelist->qual[e_cnt ].value ) ," <" ,
       eksdata->tqual[tcurindex ].qual[curindex ].data[cnt ].misc ,">" ) ) ,
      CALL echo (concat ("Event end date/time = " ,format (ce.event_end_dt_tm ,";;Q" ) ) )
     ENDIF
    ENDIF
   ENDFOR
  WITH nocounter ,expand = value (expind )
 ;end select
 IF ((cnt > 1 ) )
  CALL echo (eksdata->tqual[tcurindex ].qual[curindex ].data[1 ].misc )
  CALL echo ("event_id : micro_seq_nbr : organism_cd : antibiotic_cd : suscep_seq_nbr" )
  FOR (i = 2 TO size (eksdata->tqual[tcurindex ].qual[curindex ].data ,5 ) )
   CALL echo (eksdata->tqual[tcurindex ].qual[curindex ].data[i ].misc )
  ENDFOR
  SET eksdata->tqual[tcurindex ].qual[curindex ].cnt = cnt
  SET retval = 100
  SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = personid
  SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = encntrid
  SET eksdata->tqual[tcurindex ].qual[curindex ].order_id = 0.0
  SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = 0.0
  SET eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id = 0.0
  SET msg = concat ("Found " ,trim (cnvtstring ((cnt - 1 ) ) ) ,
   " microbiology results matching specified criteria." )
 ELSE
  SET retval = 0
  SET msg = "No qualifying microbiology results found."
  SET retval = 0
  GO TO endprogram
 ENDIF
#endprogram
 SET msg = concat (msg ," (" ,trim (format (((curtime3 - starttime3 ) / 100 ) ,"#####.##" ) ,3 ) ,
  " s)" )
/*  
if (validate(medicationlist))
	call echojson(medicationlist, t_rec->filename_a , 0) 
endif

if (validate(medication_cd))
	call echojson(medication_cd, t_rec->filename_b , 0) 
endif
*/
 
 IF ((tcurindex > 0 )
 AND (curindex > 0 ) )
  IF ((retval != 100 ) )
   SET accessionid = 0.0
   SET orderid = 0.0
   SET ekstaskassaycd = 0.0
   SET eks_ceid = 0.0
   SET rev_inc = "708"
   SET ininc = "eks_set_eksdata"
   IF ((accessionid = 0 ) )
    IF ((orderid != 0 ) )
     SELECT INTO "NL:"
      a.accession_id
      FROM (accession_order_r a )
      WHERE (a.order_id = orderid )
      AND (a.primary_flag = 0 )
      DETAIL
       accessionid = a.accession_id
      WITH nocounter
     ;end select
    ELSEIF (NOT ((validate (accession ,"Y" ) = "Y" )
    AND (validate (accession ,"Z" ) = "Z" ) ) )
     IF ((textlen (trim (accession ) ) > 0 ) )
      SELECT INTO "NL:"
       a.accession_id
       FROM (accession_order_r a )
       WHERE (a.accession = accession )
       DETAIL
        accessionid = a.accession_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF ((personid = 0 ) )
    FREE SET temp
    IF ((orderid > 0 ) )
     SELECT
      *
      FROM (orders o )
      WHERE (o.order_id = orderid )
      DETAIL
       personid = o.person_id
      WITH nocounter
     ;end select
    ELSEIF ((encntrid > 0 ) )
     SELECT
      *
      FROM (encounter en )
      WHERE (en.encntr_id = encntrid )
      DETAIL
       personid = en.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (NOT ((validate (temp ,"Y" ) = "Y" )
    AND (validate (temp ,"Z" ) = "Z" ) ) )
     SELECT INTO "nl:"
      o.person_id
      FROM (orders o )
      WHERE parser (temp )
      DETAIL
       personid = o.person_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET eksdata->tqual[tcurindex ].qual[curindex ].accession_id = accessionid
   SET eksdata->tqual[tcurindex ].qual[curindex ].order_id = orderid
   SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = encntrid
   SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = personid
   IF (NOT ((validate (ekstaskassaycd ,0 ) = 0 )
   AND (validate (ekstaskassaycd ,1 ) = 1 ) ) )
    SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = ekstaskassaycd
   ELSE
    SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = 0
   ENDIF
   IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Y" ) = "Y" )
   AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Z" ) = "Z" ) ) )
    IF ((trim (eksdata->tqual[tcurindex ].qual[curindex ].template_name ) = "" )
    AND NOT ((validate (tname ,"Y" ) = "Y" )
    AND (validate (tname ,"Z" ) = "Z" ) ) )
     SET eksdata->tqual[tcurindex ].qual[curindex ].template_name = tname
    ENDIF
   ENDIF
   IF (NOT ((validate (eksce_id ,0 ) = 0 )
   AND (validate (eksce_id ,1 ) = 1 ) ) )
    IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,0 ) = 0 )
    AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,1 ) = 1 ) ) )
     SET eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id = eksce_id
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF ((retval = - (1 ) ) )
   SET retval = 0
  ENDIF
 ENDIF
 SET eksdata->tqual[tcurindex ].qual[curindex ].logging = msg
 CALL echo (msg )
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******  End of Program eks_t_med_micro  *********" ) ,1 ,0 )
 SUBROUTINE  eks_calcdatetime (param1 ,param2 ,param3 ,param4 )
  FREE SET ininc
  SET ininc = "eks_calcdatetime_sub"
  SET newdttm = startdttm
  IF ((cnvtreal (number ) = 0 ) )
   CALL echo (concat ("Number is 0, returning current date/time:" ,format (newdttm ,";;q" ) ) ,1 ,0
    )
   RETURN (100 )
  ENDIF
  CASE (cnvtupper (qualifier ) )
   OF "HUNDREDTHS" :
    SET qualifier_adj = "hun"
   OF "SECONDS" :
    SET qualifier_adj = "s"
   OF "MINUTES" :
    SET qualifier_adj = "min"
   OF "HOURS" :
    SET qualifier_adj = "h"
   OF "DAYS" :
    SET qualifier_adj = "d"
   OF "WEEKS" :
    SET qualifier_adj = "w"
   OF "MONTHS" :
    SET qualifier_adj = "m"
   OF "YEARS" :
    SET qualifier_adj = "y"
  ENDCASE
  SET interval = build (number ,qualifier_adj )
  FREE SET dirway
  IF ((way = "F" ) )
   SET dirway = "Forwards"
   SET newdttm = cnvtlookahead (interval ,cnvtdatetime (startdttm ) )
  ELSE
   SET dirway = "Back"
   SET newdttm = cnvtlookbehind (interval ,cnvtdatetime (startdttm ) )
  ENDIF
  CALL echo (concat ("pmw temp output - interval: " ,interval ) ,1 ,0 )
  CALL echo (concat ("Start date/time      : " ,format (startdttm ,";;q" ) ) ,1 ,10 )
  CALL echo (concat (dirway ," " ,build (number ) ," " ,qualifier ," sets" ) ,1 ,10 )
  CALL echo (concat ("Adjusted date/time as: " ,format (newdttm ,";;q" ) ) ,1 ,10 )
  IF ((way = "F" ) )
   SET adjdate = cnvtdate2 (format (startdttm ,"YYYYMMDD;;D" ) ,"YYYYMMDD" )
   CALL echo (build ("Curdate:" ,curdate ) ,1 ,0 )
   CALL echo (build ("Adjdate:" ,adjdate ) ,1 ,0 )
   IF ((adjdate = curdate ) )
    IF ((newdttm < cnvtdatetime (curdate ,curtime2 ) ) )
     CALL echo ("Future date is today, but time is less than now." ,1 ,10 )
    ENDIF
   ELSE
    IF ((adjdate < curdate ) )
     CALL echo ("Future date less than today." ,1 ,10 )
    ENDIF
    CALL echo (" " ,1 ,10 )
   ENDIF
  ENDIF
  RETURN (newdttm )
 END ;Subroutine
 SUBROUTINE  parsearguments (strvararg ,strdelimiter ,result )
  RECORD tempargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  SET startpos = 1
  SET endpos = size (trim (strvararg ) ,1 )
  SET delim = trim (strdelimiter )
  IF (NOT ((delim > "" ) ) )
   SET delim = ":"
  ENDIF
  SET tempargs->count = 0
  WHILE ((startpos <= endpos ) )
   SET delpos = findstring (delim ,strvararg ,startpos )
   IF ((delpos <= 0 ) )
    SET delpos = (endpos + 1 )
   ENDIF
   SET tempargs->count = (tempargs->count + 1 )
   SET tempargs->items[tempargs->count ].value = substring (startpos ,(delpos - startpos ) ,
    strvararg )
   SET startpos = (delpos + 1 )
  ENDWHILE
  IF ((tempargs->count > 25 ) )
   SET tempargs->count = 25
  ENDIF
  SET result = tempargs
 END ;Subroutine
 SUBROUTINE  timecheck (cd ,dt )
  DECLARE pos = i4 WITH private
  DECLARE i = i4 WITH private
  FOR (i = 1 TO antibiotic_cd->cnt )
   IF ((((antibiotic_cd->qual[i ].value = 0 ) ) OR ((cd = antibiotic_cd->qual[i ].value ) )) )
    IF ((opt_time_qual_text = "less than" ) )
     IF ((dt < cnvtdatetime (antibiotic_cd->qual[i ].beg_dt_tm ) ) )
      RETURN (i )
     ENDIF
    ELSEIF ((opt_time_qual_text = "greater than" ) )
     IF ((dt > cnvtdatetime (antibiotic_cd->qual[i ].end_dt_tm ) ) )
      RETURN (i )
     ENDIF
    ELSEIF ((opt_time_qual_text = "within" ) )
     IF ((dt >= cnvtdatetime (antibiotic_cd->qual[i ].beg_dt_tm ) )
     AND (dt <= cnvtdatetime (antibiotic_cd->qual[i ].end_dt_tm ) ) )
      RETURN (i )
     ENDIF
    ELSEIF ((opt_time_qual_text = "outside" ) )
     IF ((((dt < cnvtdatetime (antibiotic_cd->qual[i ].beg_dt_tm ) ) ) OR ((dt > cnvtdatetime (
      antibiotic_cd->qual[i ].end_dt_tm ) ) )) )
      RETURN (i )
     ENDIF
    ELSE
     IF ((dt > cnvtdatetime ("01-JAN-1800 00:00:00" ) ) )
      RETURN (i )
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
  RETURN (0 )
 END ;Subroutine
END GO

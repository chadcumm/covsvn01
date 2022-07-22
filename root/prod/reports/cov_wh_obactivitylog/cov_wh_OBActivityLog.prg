/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:		        CERNER (PCM_ACTIVITY_LOG_TABLE.prg)
	Date Written:		January 2019
	Solution:			Womens Health
	Source file name:	cov_wh_OBActivityLog.prg
	Object name:		cov_wh_OBActivityLog
	Request#:			CR3533 - Break/Fix of Cerner Rpt.
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Copied/Modified from "PCM_ACTIVITY_LOG_TABLE.prg"
 
/*****************************************************************************
  	GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  	Mod Date      Developer           Comment
  	----------	  ---------------	  ----------------------------------------
  	01-2019       Dan Herren          CR3533 Added Scripts for Prompts.
 
******************************************************************************/
DROP PROGRAM cov_wh_OBActivityLog :dba GO
CREATE PROGRAM cov_wh_OBActivityLog :dba
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Name" = "Maternity Activity Log"
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Tracking Group" = 0
	, "Location View" = 0
	, "Sort Order (Optional)" = 0
	, "Nurse Unit (Optional)" = 0
	, "Reason for Visit" = 0 

with OUTDEV, REPNAME, STARTDATE, ENDDATE, TRACKGROUPCD, LOCVIEW, SORTORDER, 
	NURSEUNIT, REASONVISIT   
 EXECUTE reportrtl
 DECLARE stat = i4 WITH noconstant (0 )
 DECLARE totalpatcount = i4 WITH noconstant (0 )
 DECLARE sortorder = i2 WITH noconstant (0 )
 DECLARE f_trackgroupcd = f8 WITH noconstant (0.0 )
 SET f_trackgroupcd =  $TRACKGROUPCD
 DECLARE auth = f8 WITH protect ,noconstant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE altered = f8 WITH protect ,noconstant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE modified = f8 WITH protect ,noconstant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE all_reason_flag = i4 WITH protect ,noconstant (0 )
 DECLARE aridx = i4 WITH protect ,noconstant (0 )
 DECLARE rvidx = i4 WITH protect ,noconstant (0 )
 FREE RECORD nomen
 RECORD nomen (
   1 rec [* ]
     2 nomenclature_id = f8
   1 cnt = i4
 )
 FREE RECORD reas
 RECORD reas (
   1 rec [* ]
     2 code_value = f8
   1 cnt = i4
 )
 SELECT INTO "nl:"
  FROM (nomenclature n )
  PLAN (n
   WHERE (n.nomenclature_id IN ( $REASONVISIT ) )
   AND (n.nomenclature_id > 0 ) )
  ORDER BY n.nomenclature_id
  HEAD REPORT
   nid_cnt = 0
  HEAD n.nomenclature_id
   nid_cnt = (nid_cnt + 1 ) ,stat = alterlist (nomen->rec ,nid_cnt ) ,nomen->rec[nid_cnt ].
   nomenclature_id = n.nomenclature_id
  FOOT REPORT
   nomen->cnt = nid_cnt
  WITH nocounter
 ;end select
 IF ((size (nomen->rec ,5 ) = 0 ) )
  SET all_reason_flag = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (code_value cv )
  PLAN (cv
   WHERE (cv.code_set = 72 )
   AND (cv.concept_cki = "CERNER!6CAB2CA7-C8E0-433C-8C32-1D78CDB76855" ) )
  ORDER BY cv.code_value
  HEAD REPORT
   cv_cnt = 0
  HEAD cv.code_value
   cv_cnt = (cv_cnt + 1 ) ,stat = alterlist (reas->rec ,cv_cnt ) ,reas->rec[cv_cnt ].code_value = cv
   .code_value
  FOOT REPORT
   reas->cnt = cv_cnt
  WITH nocounter
 ;end select
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE cclbuildhlink ((vcprog = vc ) ,(vcparams = vc ) ,(nviewtype = i2 ) ,(vcdescription = vc ) )
 = vc WITH protect
 DECLARE cclbuildapplink ((nmode = i2 ) ,(vcappname = vc ) ,(vcparams = vc ) ,(vcdescription = vc )
  ) = vc WITH protect
 DECLARE cclbuildweblink ((vcaddress = vc ) ,(nmode = i2 ) ,(vcdescription = vc ) ) = vc WITH
 protect
 DECLARE layoutquery (dummy ) = null WITH protect
 DECLARE __layoutquery (dummy ) = null WITH protect
 DECLARE layoutqueryhtml ((ndummy = i2 ) ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE fieldname00 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname00abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname00html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname01 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname01abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname01html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname02 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname02abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname02html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname03 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname03abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname03html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname04 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname04abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname04html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname05 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname05abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname05html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname06 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname06abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname06html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname07 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname07abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname07html ((dummy = i2 ) ) = null WITH protect
 DECLARE fieldname08 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE fieldname08abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE fieldname08html ((dummy = i2 ) ) = null WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant (0 ) ,protect
 DECLARE _yoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xoffset = f8 WITH noconstant (0.0 ) ,protect
 RECORD _htmlfileinfo (
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_offset = i4
   1 file_dir = i4
 ) WITH protect
 SET _htmlfileinfo->file_desc = 0
 DECLARE _htmlfilestat = i4 WITH noconstant (0 ) ,protect
 DECLARE _bgeneratehtml = i1 WITH noconstant (evaluate (validate (request->output_device ,"N" ) ,
   "MINE" ,1 ,'"MINE"' ,1 ,0 ) ) ,protect
 DECLARE rpt_render = i2 WITH constant (0 ) ,protect
 DECLARE _crlf = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE rpt_calcheight = i2 WITH constant (1 ) ,protect
 DECLARE _yshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _sendto = vc WITH noconstant ("" ) ,protect
 DECLARE _rpterr = i2 WITH noconstant (0 ) ,protect
 DECLARE _rptstat = i2 WITH noconstant (0 ) ,protect
 DECLARE _oldfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _oldpen = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummyfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummypen = i4 WITH noconstant (0 ) ,protect
 DECLARE _fdrawheight = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _rptpage = i4 WITH noconstant (0 ) ,protect
 DECLARE _diotype = i2 WITH noconstant (8 ) ,protect
 DECLARE _outputtype = i2 WITH noconstant (rpt_postscript ) ,protect
 DECLARE _times80 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times8b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times12b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times16b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen0s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c16711680 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c255 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 SUBROUTINE  cclbuildhlink (vcprogname ,vcparams ,nwindow ,vcdescription )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   SET vcreturn = build (^<a href='javascript:CCLLINK("^ ,vcprogname ,'","' ,vcparams ,'",' ,nwindow
    ,")'>" ,vcdescription ,"</a>" )
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  cclbuildapplink (nmode ,vcappname ,vcparams ,vcdescription )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   SET vcreturn = build ("<a href='javascript:APPLINK(" ,nmode ,',"' ,vcappname ,'","' ,vcparams ,
    ^")'>^ ,vcdescription ,"</a>" )
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  cclbuildweblink (vcaddress ,nmode ,vcdescription )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   IF ((nmode = 1 ) )
    SET vcreturn = build ("<a href='" ,vcaddress ,"'>" ,vcdescription ,"</a>" )
   ELSE
    SET vcreturn = build ("<a href='" ,vcaddress ,"' target='_blank'>" ,vcdescription ,"</a>" )
   ENDIF
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  layoutquery (dummy )
  CALL initializereport (0 )
  CALL __layoutquery (0 )
  CALL finalizereport (_sendto )
 END ;Subroutine
 SUBROUTINE  __layoutquery (dummy )
  SELECT INTO "NL:"
   patient_data_acuity_str = substring (1 ,20 ,output_data->patient_data[dtrs1.seq ].acuity ) ,
   patient_data_admit_mode = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].admit_mode ) ,
   patient_data_admitting_physician = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    admitting_physician ) ,
   patient_data_arrive_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    arrive_date_time ) ,
   patient_data_attending_physician = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    attending_physician ) ,
   patient_data_birth_date = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].birth_date ) ,
   patient_data_checkout_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    checkout_date_time ) ,
   patient_data_checkin_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    checkin_date_time ) ,
   patient_data_discharge_disposition = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    discharge_disposition ) ,
   patient_data_discharge_to_location = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    discharge_to_location ) ,
   patient_data_disch_diagnosis = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    disch_diagnosis ) ,
   patient_data_fin = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].fin ) ,
   patient_data_mrn = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].mrn ) ,
   patient_data_name_full_formatted = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    name_full_formatted ) ,
   patient_data_reason_for_visit = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    reason_for_visit ) ,
   patient_data_registration_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    registration_date_time ) ,
   patient_data_sex = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].sex ) ,
   patient_data_visit_age = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].visit_age ) ,
   totalpatients = size (output_data->patient_data ,5 ) ,
   patient_data_tracking_checkin_id = output_data->patient_data[dtrs1.seq ].tracking_checkin_id ,
   report_data_report_title = substring (1 ,30 ,output_data->report_data.report_title ) ,
   report_data_report_date = substring (1 ,100 ,output_data->report_data.report_date ) ,
   report_data_report_generation_name = substring (1 ,30 ,output_data->report_data.
    report_generation_name ) ,
   patient_data_los_checkin = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].los_checkin ) ,
   patient_data_primary_provider = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    primary_provider ) ,
   patient_data_secondary_provider = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    secondary_provider ) ,
   patient_data_primary_nurse = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].primary_nurse
     ) ,
   patient_data_secondary_nurse = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    secondary_nurse ) ,
   report_data_track_group_display = substring (1 ,30 ,output_data->report_data.track_group_display
    ) ,
   report_data_report_generation_date = substring (1 ,30 ,output_data->report_data.
    report_generation_date ) ,
   trkgrp_trkgrpcd = output_data->report_data.track_group_cd ,
   patient_data_los_loc = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].los_location ) ,
   patient_data_sortingfield = substring (1 ,100 ,output_data->patient_data[dtrs1.seq ].sorting_field
     ) ,
   report_data_report_nurseunit_name = output_data->report_data.report_nurseunit_name ,
   patient_data_visitid = output_data->patient_data[dtrs1.seq ].visit_id ,
   patient_data_personid = output_data->patient_data[dtrs1.seq ].person_id ,
   patient_data_ega = output_data->patient_data[dtrs1.seq ].ega ,
   patient_data_edd = output_data->patient_data[dtrs1.seq ].edd
   FROM (dummyt d1 ),
    (dummyt dtrs1 WITH seq = value (size (output_data->patient_data ,5 ) ) )
   ORDER BY patient_data_sortingfield
   HEAD REPORT
    _d0 = patient_data_admit_mode ,
    _d1 = patient_data_admitting_physician ,
    _d2 = patient_data_birth_date ,
    _d3 = patient_data_checkout_date_time ,
    _d4 = patient_data_checkin_date_time ,
    _d5 = patient_data_discharge_disposition ,
    _d6 = patient_data_discharge_to_location ,
    _d7 = patient_data_disch_diagnosis ,
    _d8 = patient_data_fin ,
    _d9 = patient_data_mrn ,
    _d10 = patient_data_name_full_formatted ,
    _d11 = patient_data_reason_for_visit ,
    _d12 = patient_data_visit_age ,
    _d13 = report_data_report_title ,
    _d14 = patient_data_los_checkin ,
    _d15 = patient_data_primary_provider ,
    _d16 = patient_data_primary_nurse ,
    _d17 = patient_data_visitid ,
    _d18 = patient_data_personid ,
    _d19 = patient_data_ega ,
    _d20 = patient_data_edd ,
    _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom ) ,
    _fenddetail = (_fenddetail - fieldname08 (rpt_calcheight ) ) ,
    _fdrawheight = fieldname00 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname01 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname02 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname03 (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname00 (rpt_render ) ,
    _fdrawheight = fieldname01 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname02 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname03 (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname01 (rpt_render ) ,
    _fdrawheight = fieldname02 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname03 (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname02 (rpt_render ) ,
    _fdrawheight = fieldname03 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname03 (rpt_render )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname04 (rpt_render ) ,
    dummy_val = fieldname05 (rpt_render )
   HEAD patient_data_sortingfield
    row + 0
   DETAIL
    _fdrawheight = fieldname06 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + fieldname07 (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = fieldname06 (rpt_render ) ,
    _fdrawheight = fieldname07 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = fieldname07 (rpt_render )
   FOOT  patient_data_sortingfield
    row + 0
   FOOT PAGE
    _yhold = _yoffset ,
    _yoffset = _fenddetail ,
    dummy_val = fieldname08 (rpt_render ) ,
    _yoffset = _yhold
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  layoutqueryhtml (ndummy )
  DECLARE rpt_pageofpage = vc WITH noconstant ("Page 1 of 1" ) ,protect
  SELECT INTO "NL:"
   patient_data_acuity_str = substring (1 ,20 ,output_data->patient_data[dtrs1.seq ].acuity ) ,
   patient_data_admit_mode = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].admit_mode ) ,
   patient_data_admitting_physician = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    admitting_physician ) ,
   patient_data_arrive_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    arrive_date_time ) ,
   patient_data_attending_physician = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    attending_physician ) ,
   patient_data_birth_date = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].birth_date ) ,
   patient_data_checkout_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    checkout_date_time ) ,
   patient_data_checkin_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    checkin_date_time ) ,
   patient_data_discharge_disposition = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    discharge_disposition ) ,
   patient_data_discharge_to_location = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    discharge_to_location ) ,
   patient_data_disch_diagnosis = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    disch_diagnosis ) ,
   patient_data_fin = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].fin ) ,
   patient_data_mrn = substring (1 ,15 ,output_data->patient_data[dtrs1.seq ].mrn ) ,
   patient_data_name_full_formatted = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    name_full_formatted ) ,
   patient_data_reason_for_visit = substring (1 ,60 ,output_data->patient_data[dtrs1.seq ].
    reason_for_visit ) ,
   patient_data_registration_date_time = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    registration_date_time ) ,
   patient_data_sex = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].sex ) ,
   patient_data_visit_age = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].visit_age ) ,
   totalpatients = size (output_data->patient_data ,5 ) ,
   patient_data_tracking_checkin_id = output_data->patient_data[dtrs1.seq ].tracking_checkin_id ,
   report_data_report_title = substring (1 ,30 ,output_data->report_data.report_title ) ,
   report_data_report_date = substring (1 ,100 ,output_data->report_data.report_date ) ,
   report_data_report_generation_name = substring (1 ,30 ,output_data->report_data.
    report_generation_name ) ,
   patient_data_los_checkin = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].los_checkin ) ,
   patient_data_primary_provider = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    primary_provider ) ,
   patient_data_secondary_provider = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    secondary_provider ) ,
   patient_data_primary_nurse = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].primary_nurse
     ) ,
   patient_data_secondary_nurse = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].
    secondary_nurse ) ,
   report_data_track_group_display = substring (1 ,30 ,output_data->report_data.track_group_display
    ) ,
   report_data_report_generation_date = substring (1 ,30 ,output_data->report_data.
    report_generation_date ) ,
   trkgrp_trkgrpcd = output_data->report_data.track_group_cd ,
   patient_data_los_loc = substring (1 ,30 ,output_data->patient_data[dtrs1.seq ].los_location ) ,
   patient_data_sortingfield = substring (1 ,100 ,output_data->patient_data[dtrs1.seq ].sorting_field
     ) ,
   report_data_report_nurseunit_name = output_data->report_data.report_nurseunit_name ,
   patient_data_visitid = output_data->patient_data[dtrs1.seq ].visit_id ,
   patient_data_personid = output_data->patient_data[dtrs1.seq ].person_id ,
   patient_data_ega = output_data->patient_data[dtrs1.seq ].ega ,
   patient_data_edd = output_data->patient_data[dtrs1.seq ].edd
   FROM (dummyt d1 ),
    (dummyt dtrs1 WITH seq = value (size (output_data->patient_data ,5 ) ) )
   ORDER BY patient_data_sortingfield
   HEAD REPORT
    _d0 = patient_data_admit_mode ,
    _d1 = patient_data_admitting_physician ,
    _d2 = patient_data_birth_date ,
    _d3 = patient_data_checkout_date_time ,
    _d4 = patient_data_checkin_date_time ,
    _d5 = patient_data_discharge_disposition ,
    _d6 = patient_data_discharge_to_location ,
    _d7 = patient_data_disch_diagnosis ,
    _d8 = patient_data_fin ,
    _d9 = patient_data_mrn ,
    _d10 = patient_data_name_full_formatted ,
    _d11 = patient_data_reason_for_visit ,
    _d12 = patient_data_visit_age ,
    _d13 = report_data_report_title ,
    _d14 = patient_data_los_checkin ,
    _d15 = patient_data_primary_provider ,
    _d16 = patient_data_primary_nurse ,
    _d17 = patient_data_visitid ,
    _d18 = patient_data_personid ,
    _d19 = patient_data_ega ,
    _d20 = patient_data_edd ,
    _htmlfileinfo->file_buf = build2 ("<STYLE>" ,
     "table {border-collapse: collapse; empty-cells: show;  border: 0.000in none #000000;  }" ,
     ".FieldName000 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: solid solid none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 16pt Times;" ," " ," color: #000000;" ," background: #ffff00;" ,
     " text-align: center;" ," vertical-align: top;}" ,
     ".FieldName010 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #c0c0c0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName011 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #c0c0c0;" ,
     " text-align: right;" ," vertical-align: top;}" ,
     ".FieldName021 { border-width: 0.000in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #c0c0c0;" ,
     " text-align: center;" ," vertical-align: top;}" ,
     ".FieldName030 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #c0c0c0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName031 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #c0c0c0;" ,
     " text-align: right;" ," vertical-align: top;}" ,
     ".FieldName040 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName041 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042 { border-width: 0.014in; border-color: #ff0000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName043 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.050in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName046 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName049 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName050 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName051 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName052 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName053 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.050in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName055 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName056 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName059 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 8pt Times;" ," " ," color: #000000;" ," background: #00ffff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName060 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName061 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName062 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," background: #ffffff;" ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName063 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.050in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName064 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName065 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName066 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName068 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.050in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName069 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none solid none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName070 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName071 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName073 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.050in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName075 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName076 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," background: #ffffff;" ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName078 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName079 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none solid solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   8pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName080 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #ff8080;" ,
     " text-align: center;" ," vertical-align: top;}" ,"</STYLE>" ) ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<table width='100%'><caption>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = build2 ("<colgroup span=14>" ,"<col width=151/>" ,"<col width=75/>" ,
     "<col width=62/>" ,"<col width=88/>" ,"<col width=1/>" ,"<col width=98/>" ,"<col width=25/>" ,
     "<col width=39/>" ,"<col width=24/>" ,"<col width=153/>" ,"<col width=61/>" ,"<col width=48/>" ,
     "<col width=113/>" ,"<col width=95/>" ,"</colgroup>" ) ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<thead>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    dummy_val = fieldname00html (0 ) ,
    dummy_val = fieldname01html (0 ) ,
    dummy_val = fieldname02html (0 ) ,
    dummy_val = fieldname03html (0 ) ,
    dummy_val = fieldname04html (0 ) ,
    dummy_val = fieldname05html (0 ) ,
    _htmlfileinfo->file_buf = "</thead>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<tbody>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   DETAIL
    dummy_val = fieldname06html (0 ) ,
    dummy_val = fieldname07html (0 )
   FOOT REPORT
    _htmlfileinfo->file_buf = "</tbody>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<tfoot>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    dummy_val = fieldname08html (0 ) ,
    _htmlfileinfo->file_buf = "</tfoot>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "</table>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  pagebreak (dummy )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE  finalizereport (ssendreport )
  IF (_htmlfileinfo->file_desc )
   SET _htmlfileinfo->file_buf = "</html>"
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   SET _htmlfilestat = cclio ("CLOSE" ,_htmlfileinfo )
  ELSE
   SET _rptpage = uar_rptendpage (_hreport )
   SET _rptstat = uar_rptendreport (_hreport )
   DECLARE sfilename = vc WITH noconstant (trim (ssendreport ) ) ,private
   DECLARE bprint = i2 WITH noconstant (0 ) ,private
   IF ((textlen (sfilename ) > 0 ) )
    SET bprint = checkqueue (sfilename )
    IF (bprint )
     EXECUTE cpm_create_file_name "RPT" ,
     "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile (_hreport ,nullterm (sfilename ) )
   IF (bprint )
    SET spool value (sfilename ) value (ssendreport ) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant (0 ) ,protect
   DECLARE _errcnt = i2 WITH noconstant (0 ) ,protect
   SET _errorfound = uar_rptfirsterror (_hreport ,rpterror )
   WHILE ((_errorfound = rpt_errorfound )
   AND (_errcnt < 512 ) )
    SET _errcnt = (_errcnt + 1 )
    SET stat = alterlist (rpterrors->errors ,_errcnt )
    SET rpterrors->errors[_errcnt ].m_severity = rpterror->m_severity
    SET rpterrors->errors[_errcnt ].m_text = rpterror->m_text
    SET rpterrors->errors[_errcnt ].m_source = rpterror->m_source
    SET _errorfound = uar_rptnexterror (_hreport ,rpterror )
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport (_hreport )
  ENDIF
 END ;Subroutine
 SUBROUTINE  fieldname00 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname00abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname00abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.310000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = 0.313
   SET _oldfont = uar_rptsetfont (_hreport ,_times16b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_yellow )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (report_data_report_title ,char (0 )
     ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname00html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName000' colspan='14'>" ,
   report_data_report_title ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname01 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname01abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname01abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE __generationdate = vc WITH noconstant (build (output_data->report_data.
    report_generation_date ,char (0 ) ) ) ,protect
  DECLARE __trackgroup = vc WITH noconstant (build (output_data->report_data.track_group_display ,
    char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.750 )
   SET rptsd->m_width = 5.500
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__generationdate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__trackgroup )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.750 ) ,offsety ,(offsetx + 4.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname01html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName010' colspan='7'>" ,output_data
   ->report_data.track_group_display ,"</td>" ,"<td class='FieldName011' colspan='7'>" ,output_data->
   report_data.report_generation_date ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname02 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname02abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname02abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.240000 ) ,private
  DECLARE __generationuser = vc WITH noconstant (build (output_data->report_data.
    report_generation_name ,char (0 ) ) ) ,protect
  DECLARE __summary = vc WITH noconstant (build (cclbuildhlink ("fnrpt_dashboard_table" ,build (
      "MINE," ,"^" ,"Summary" ,"^," , $TRACKGROUPCD ,",^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,
       $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->summary ) ,char (0 ) ) ) ,protect
  DECLARE __report_data_report_nurseunit_name = vc WITH noconstant (build (output_data->report_data.
    report_nurseunit_name ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 4.875
   SET rptsd->m_height = 0.240
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__generationuser )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.521 )
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = 0.240
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__summary )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 3.771
   SET rptsd->m_height = 0.240
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__report_data_report_nurseunit_name )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.521 ) ,offsety ,(offsetx + 3.521 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.375 ) ,offsety ,(offsetx + 5.375 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname02html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName010' colspan='5'>" ,output_data
   ->report_data.report_nurseunit_name ,"</td>" ,"<td class='FieldName021' colspan='4'>" ,
   cclbuildhlink ("fnrpt_dashboard_table" ,build ("MINE," ,"^" ,"Summary" ,"^," , $TRACKGROUPCD ,
     ",^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->
    summary ) ,"</td>" ,"<td class='FieldName011' colspan='5'>" ,output_data->report_data.
   report_generation_name ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname03 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname03abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname03abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.240000 ) ,private
  DECLARE __totaled = vc WITH noconstant (build (report_labels->total_pats ,char (0 ) ) ) ,protect
  DECLARE __reportdate = vc WITH noconstant (build (output_data->report_data.report_date ,char (0 )
    ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.521 )
   SET rptsd->m_width = 2.729
   SET rptsd->m_height = 0.240
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__totaled )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 7.771
   SET rptsd->m_height = 0.240
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__reportdate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.521 ) ,offsety ,(offsetx + 7.521 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname03html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName030' colspan='11'>" ,output_data
   ->report_data.report_date ,"</td>" ,"<td class='FieldName031' colspan='3'>" ,report_labels->
   total_pats ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname04 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname04abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname04abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE __dischloc = vc WITH noconstant (build (report_labels->discharge ,char (0 ) ) ) ,protect
  DECLARE __admphys = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"9" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->admitting ) ,char (0 ) ) ) ,protect
  DECLARE __edphysician = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"7" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->ed_physician ) ,char (0 ) ) ) ,protect
  DECLARE __rfv24 = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"5" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->rfv ) ,char (0 ) ) ) ,protect
  DECLARE __arrivalmod = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"6" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->arrival_mode ) ,char (0 ) ) ) ,protect
  DECLARE __checkindate = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"3" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->checkin_date ) ,char (0 ) ) ) ,protect
  DECLARE __age = vc WITH noconstant (build (report_labels->age_gender ,char (0 ) ) ) ,protect
  DECLARE __mrncell = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"12" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->mrn ) ,char (0 ) ) ) ,protect
  DECLARE __egacell = vc WITH noconstant (build (report_labels->ega ,char (0 ) ) ) ,protect
  DECLARE __cellname = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"1" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->person_name ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 40
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 9.125 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times8b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__dischloc )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__admphys )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 36
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.906 )
   SET rptsd->m_width = 1.094
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__edphysician )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.135 )
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__rfv24 )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__arrivalmod )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.510 )
   SET rptsd->m_width = 0.990
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__checkindate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.625 )
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__age )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.010 )
   SET rptsd->m_width = 0.615
   SET rptsd->m_height = 0.260
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c255 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__mrncell )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.260 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__egacell )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cellname )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.260 ) ,offsety ,(offsetx + 1.260 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.010 ) ,offsety ,(offsetx + 2.010 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.625 ) ,offsety ,(offsetx + 2.625 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.510 ) ,offsety ,(offsetx + 3.510 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.500 ) ,offsety ,(offsetx + 4.500 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.135 ) ,offsety ,(offsetx + 5.135 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.906 ) ,offsety ,(offsetx + 6.906 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.000 ) ,offsety ,(offsetx + 8.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.125 ) ,offsety ,(offsetx + 9.125 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname04html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName040' colspan='1'>" ,
   cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,
     "^,^" , $ENDDATE ,"^," ,"1" ,"," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->person_name
    ) ,"</td>" ,"<td class='FieldName041' colspan='1'>" ,report_labels->ega ,"</td>" ,
   "<td class='FieldName042' colspan='1'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,
     "^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"12" ,"," , $LOCVIEW ,"," ,
      $NURSEUNIT ) ,1 ,report_labels->mrn ) ,"</td>" ,"<td class='FieldName043' colspan='1'>" ,
   report_labels->age_gender ,"</td>" ,"<td class='FieldName041' colspan='2'>" ,cclbuildhlink (
    "cov_wh_OBActivityLog" ,build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" ,
      $ENDDATE ,"^," ,"3" ,"," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->checkin_date ) ,
   "</td>" ,"<td class='FieldName041' colspan='2'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,build (
     "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"6" ,"," , $LOCVIEW ,
     "," , $NURSEUNIT ) ,1 ,report_labels->arrival_mode ) ,"</td>" ,
   "<td class='FieldName046' colspan='2'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,
     "^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"5" ,"," , $LOCVIEW ,"," ,
      $NURSEUNIT ) ,1 ,report_labels->rfv ) ,"</td>" ,"<td class='FieldName046' colspan='2'>" ,
   cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,
     "^,^" , $ENDDATE ,"^," ,"7" ,"," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->ed_physician
    ) ,"</td>" ,"<td class='FieldName043' colspan='1'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,
    build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"9" ,"," ,
      $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->admitting ) ,"</td>" ,
   "<td class='FieldName049' colspan='1'>" ,report_labels->discharge ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname05 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname05abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname05abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE __disposition = vc WITH noconstant (build (report_labels->disposition ,char (0 ) ) ) ,
  protect
  DECLARE __primarynur = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"10" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->primary_nurse ) ,char (0 ) ) ) ,protect
  DECLARE __diagnosis = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"11" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->diagnosis ) ,char (0 ) ) ) ,protect
  DECLARE __checkoutdate = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build
     ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"4" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->checkout_date ) ,char (0 ) ) ) ,protect
  DECLARE __birthdat = vc WITH noconstant (build (cclbuildhlink ("cov_wh_OBActivityLog" ,build (
      "MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"8" ,"," , $LOCVIEW ,
      "," , $NURSEUNIT ) ,1 ,report_labels->birth_date ) ,char (0 ) ) ) ,protect
  DECLARE __cellfin = vc WITH noconstant (build (report_labels->fin ,char (0 ) ) ) ,protect
  DECLARE __eddcell = vc WITH noconstant (build (report_labels->edd ,char (0 ) ) ) ,protect
  DECLARE __los = vc WITH noconstant (build (report_labels->los_checkin ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 9.125 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times8b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__disposition )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.906 )
   SET rptsd->m_width = 1.094
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__primarynur )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.135 )
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__diagnosis )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 40
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.521 )
   SET rptsd->m_width = 0.979
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__checkoutdate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.625 )
   SET rptsd->m_width = 0.896
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__birthdat )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.010 )
   SET rptsd->m_width = 0.615
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cellfin )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 40
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.260 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__eddcell )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_aqua )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__los )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.260 ) ,offsety ,(offsetx + 1.260 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.010 ) ,offsety ,(offsetx + 2.010 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.625 ) ,offsety ,(offsetx + 2.625 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.521 ) ,offsety ,(offsetx + 3.521 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.500 ) ,offsety ,(offsetx + 4.500 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.135 ) ,offsety ,(offsetx + 5.135 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.906 ) ,offsety ,(offsetx + 6.906 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.000 ) ,offsety ,(offsetx + 8.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.125 ) ,offsety ,(offsetx + 9.125 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname05html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName050' colspan='1'>" ,
   report_labels->los_checkin ,"</td>" ,"<td class='FieldName051' colspan='1'>" ,report_labels->edd ,
   "</td>" ,"<td class='FieldName052' colspan='1'>" ,report_labels->fin ,"</td>" ,
   "<td class='FieldName053' colspan='2'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,
     "^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"8" ,"," , $LOCVIEW ,"," ,
      $NURSEUNIT ) ,1 ,report_labels->birth_date ) ,"</td>" ,"<td class='FieldName051' colspan='1'>"
   ,cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,
     "^,^" , $ENDDATE ,"^," ,"4" ,"," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->checkout_date
     ) ,"</td>" ,"<td class='FieldName055' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName056' colspan='2'>" ,cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,
     "^" , $REPNAME ,"^," ,"^" , $STARTDATE ,"^,^" , $ENDDATE ,"^," ,"11" ,"," , $LOCVIEW ,"," ,
      $NURSEUNIT ) ,1 ,report_labels->diagnosis ) ,"</td>" ,"<td class='FieldName055' colspan='2'>" ,
   cclbuildhlink ("cov_wh_OBActivityLog" ,build ("MINE," ,"^" , $REPNAME ,"^," ,"^" , $STARTDATE ,
     "^,^" , $ENDDATE ,"^," ,"10" ,"," , $LOCVIEW ,"," , $NURSEUNIT ) ,1 ,report_labels->
    primary_nurse ) ,"</td>" ,"<td class='FieldName052' colspan='1'>" ,"" ,"</td>" ,
   "<td class='FieldName059' colspan='1'>" ,report_labels->disposition ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname06 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname06abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname06abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.270000 ) ,private
  DECLARE __checkindatetm = vc WITH noconstant (build (cclbuildhlink ("fnrpt_pat_summary" ,build (
      f_trackgroupcd ,"," ,patient_data_visitid ) ,1 ,patient_data_checkin_date_time ) ,char (0 ) )
   ) ,protect
  DECLARE __name = vc WITH noconstant (build (cclbuildhlink ("fnrpt_open_chart" ,build (
      patient_data_personid ,"," ,patient_data_visitid ) ,1 ,patient_data_name_full_formatted ) ,
    char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 9.125 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_times80 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c16711680 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_discharge_to_location ,
     char (0 ) ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_admitting_physician ,
     char (0 ) ) )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.906 )
   SET rptsd->m_width = 1.094
   SET rptsd->m_height = 0.271
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_primary_provider ,char
     (0 ) ) )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.135 )
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_reason_for_visit ,char
     (0 ) ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_admit_mode ,char (0 )
     ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.521 )
   SET rptsd->m_width = 0.979
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__checkindatetm )
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.625 )
   SET rptsd->m_width = 0.896
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_visit_age ,char (0 ) )
    )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.010 )
   SET rptsd->m_width = 0.615
   SET rptsd->m_height = 0.271
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_white )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_mrn ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.260 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.271
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c16711680 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_ega ,char (0 ) ) )
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = 0.271
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__name )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.260 ) ,offsety ,(offsetx + 1.260 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.010 ) ,offsety ,(offsetx + 2.010 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.625 ) ,offsety ,(offsetx + 2.625 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.521 ) ,offsety ,(offsetx + 3.521 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.500 ) ,offsety ,(offsetx + 4.500 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.135 ) ,offsety ,(offsetx + 5.135 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.906 ) ,offsety ,(offsetx + 6.906 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.000 ) ,offsety ,(offsetx + 8.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.125 ) ,offsety ,(offsetx + 9.125 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname06html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName060' colspan='1'>" ,
   cclbuildhlink ("fnrpt_open_chart" ,build (patient_data_personid ,"," ,patient_data_visitid ) ,1 ,
    patient_data_name_full_formatted ) ,"</td>" ,"<td class='FieldName061' colspan='1'>" ,
   patient_data_ega ,"</td>" ,"<td class='FieldName062' colspan='1'>" ,patient_data_mrn ,"</td>" ,
   "<td class='FieldName063' colspan='2'>" ,patient_data_visit_age ,"</td>" ,
   "<td class='FieldName064' colspan='1'>" ,cclbuildhlink ("fnrpt_pat_summary" ,build (
     f_trackgroupcd ,"," ,patient_data_visitid ) ,1 ,patient_data_checkin_date_time ) ,"</td>" ,
   "<td class='FieldName065' colspan='2'>" ,patient_data_admit_mode ,"</td>" ,
   "<td class='FieldName066' colspan='2'>" ,patient_data_reason_for_visit ,"</td>" ,
   "<td class='FieldName065' colspan='2'>" ,patient_data_primary_provider ,"</td>" ,
   "<td class='FieldName068' colspan='1'>" ,patient_data_admitting_physician ,"</td>" ,
   "<td class='FieldName069' colspan='1'>" ,patient_data_discharge_to_location ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname07 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname07abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname07abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 9.125 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times80 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c16711680 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_discharge_disposition ,
     char (0 ) ) )
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.906 )
   SET rptsd->m_width = 1.094
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_primary_nurse ,char (0
      ) ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.135 )
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = 0.260
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,rpt_white )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_disch_diagnosis ,char (
      0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.521 )
   SET rptsd->m_width = 0.979
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_checkout_date_time ,
     char (0 ) ) )
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.625 )
   SET rptsd->m_width = 0.896
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_birth_date ,char (0 )
     ) )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.010 )
   SET rptsd->m_width = 0.615
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_fin ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.260 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_edd ,char (0 ) ) )
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (patient_data_los_checkin ,char (0 )
     ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.260 ) ,offsety ,(offsetx + 1.260 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.010 ) ,offsety ,(offsetx + 2.010 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.625 ) ,offsety ,(offsetx + 2.625 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.521 ) ,offsety ,(offsetx + 3.521 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.500 ) ,offsety ,(offsetx + 4.500 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.135 ) ,offsety ,(offsetx + 5.135 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.906 ) ,offsety ,(offsetx + 6.906 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.000 ) ,offsety ,(offsetx + 8.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.125 ) ,offsety ,(offsetx + 9.125 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname07html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName070' colspan='1'>" ,
   patient_data_los_checkin ,"</td>" ,"<td class='FieldName071' colspan='1'>" ,patient_data_edd ,
   "</td>" ,"<td class='FieldName071' colspan='1'>" ,patient_data_fin ,"</td>" ,
   "<td class='FieldName073' colspan='2'>" ,patient_data_birth_date ,"</td>" ,
   "<td class='FieldName071' colspan='1'>" ,patient_data_checkout_date_time ,"</td>" ,
   "<td class='FieldName075' colspan='2'>" ,"" ,"</td>" ,"<td class='FieldName076' colspan='2'>" ,
   patient_data_disch_diagnosis ,"</td>" ,"<td class='FieldName071' colspan='2'>" ,
   patient_data_primary_nurse ,"</td>" ,"<td class='FieldName078' colspan='1'>" ,"" ,"</td>" ,
   "<td class='FieldName079' colspan='1'>" ,patient_data_discharge_disposition ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  fieldname08 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname08abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  fieldname08abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE __totalpatients = vc WITH noconstant (build (report_labels->total_qual_pats ,char (0 ) ) )
  ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = bor (bor (rpt_sdbottomborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + - (0.250 ) )
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (255 ,128 ,128 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__totalpatients )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + 0.000 ) ,(offsetx +
    10.250 ) ,(offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,offsety ,(offsetx + - (0.250 ) ) ,(
    offsety + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 10.250 ) ,offsety ,(offsetx + 10.250 ) ,(offsety
    + sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.250 ) ) ,(offsety + sectionheight ) ,(
    offsetx + 10.250 ) ,(offsety + sectionheight ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  fieldname08html (dummy )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName080' colspan='14'>" ,
   report_labels->total_qual_pats ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  IF ((_bgeneratehtml = 1 ) )
   SET _htmlfileinfo->file_name = _sendto
   SET _htmlfileinfo->file_buf = "w+b"
   SET _htmlfilestat = cclio ("OPEN" ,_htmlfileinfo )
   SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSE
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "cov_wh_OBActivityLog"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport (rptreport ,_outputtype ,rpt_inches )
   SET _rpterr = uar_rptseterrorlevel (_hreport ,rpt_error )
   SET _rptstat = uar_rptstartreport (_hreport )
   SET _rptpage = uar_rptstartpage (_hreport )
  ENDIF
  CALL _createfonts (0 )
  CALL _createpens (0 )
 END ;Subroutine
 SUBROUTINE  _createfonts (dummy )
  SET rptfont->m_recsize = 50
  SET rptfont->m_fontname = rpt_times
  SET rptfont->m_pointsize = 10
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET rptfont->m_underline = rpt_off
  SET rptfont->m_strikethrough = rpt_off
  SET rptfont->m_rgbcolor = rpt_black
  SET _times100 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 16
  SET rptfont->m_bold = rpt_on
  SET _times16b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 12
  SET _times12b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 8
  SET _times8b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_bold = rpt_off
  SET _times80 = uar_rptcreatefont (_hreport ,rptfont )
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen14s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.000
  SET _pen0s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_rgbcolor = rpt_red
  SET _pen14s0c255 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_rgbcolor = rpt_blue
  SET _pen14s0c16711680 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 DECLARE pat_count = i4 WITH noconstant (0 )
 DECLARE disch_cd = f8
 DECLARE rfv_cd = f8
 DECLARE admitdoc_cd = f8
 DECLARE attnddoc_cd = f8
 DECLARE refdoc_cd = f8
 DECLARE trkcommenttype = f8
 DECLARE acuitycd = f8
 DECLARE regstatuscd = f8
 DECLARE specialtycd = f8
 DECLARE teamcd = f8
 DECLARE pcpdoc_cd = f8
 DECLARE space_pos = i4
 DECLARE cut_pos = i4
 DECLARE age = vc
 DECLARE new_age = vc
 DECLARE user_name = vc
 DECLARE provsrc = f8 WITH noconstant (0.0 )
 DECLARE prvrelncd = f8
 DECLARE len = i4
 DECLARE comp_pref = vc
 DECLARE comp_name_unq = vc
 DECLARE counter = i4 WITH noconstant (0 )
 DECLARE counter1 = i4 WITH noconstant (0 )
 DECLARE counter2 = i4 WITH noconstant (0 )
 RECORD output_data (
   1 total_los = vc
   1 report_data
     2 report_title = vc
     2 facility_cd = f8
     2 facility_display = vc
     2 track_group_cd = f8
     2 track_group_display = vc
     2 report_date = vc
     2 start_date = vc
     2 end_date = vc
     2 report_generation_date = vc
     2 report_generation_id = f8
     2 report_generation_name = vc
     2 report_nurseunit_name = vc
     2 criteria = vc
     2 report_parameters [* ]
       3 parameter_type = f8
       3 parameter_value = vc
   1 patient_data [* ]
     2 ega = vc
     2 edd = vc
     2 current_location_display = vc
     2 sorting_field = vc
     2 accompanied_by = vc
     2 acuity = vc
     2 admit_mode = vc
     2 admitting_physician = vc
     2 admit_source = vc
     2 arrive_date_time = vc
     2 visit_id = f8
     2 attending_physician = vc
     2 avl = vc
     2 birth_date = vc
     2 checkout_date_time = vc
     2 checkout_date = vc
     2 checkout_time = vc
     2 checkin_date_time = vc
     2 checkin_date = vc
     2 checkin_time = vc
     2 chief_complaint = vc
     2 coded_by = vc
     2 coded_by_id = f8
     2 coded_dt_tm = vc
     2 comment1 = vc
     2 comment2 = vc
     2 comment3 = vc
     2 comment4 = vc
     2 comment5 = vc
     2 comment6 = vc
     2 comment7 = vc
     2 comment8 = vc
     2 comment9 = vc
     2 comment10 = vc
     2 depart_date_time = vc
     2 discharge_disposition = vc
     2 discharge_to_location = vc
     2 discharge_date_time = vc
     2 current_age = vc
     2 disch_diagnosis = vc
     2 encounter_comment = vc
     2 encntr_id = f8
     2 encounter_type = vc
     2 family_present = vc
     2 fin = vc
     2 financial_class = vc
     2 form_status = vc
     2 isolation = vc
     2 los = vc
     2 los_checkin = vc
     2 los_checkin_hours = vc
     2 los_hours = vc
     2 los_location = vc
     2 medical_service = vc
     2 mrn = vc
     2 name_full_formatted = vc
     2 order_id = f8
     2 order_display = vc
     2 order_result_display = vc
     2 indvordercnt = i4
     2 pcp = vc
     2 person_id = f8
     2 prearrival_type = vc
     2 primary_provider = vc
     2 secondary_provider = vc
     2 primary_nurse = vc
     2 secondary_nurse = vc
     2 reason_for_visit = vc
     2 referring_comment = vc
     2 referring_physician = vc
     2 referring_source = vc
     2 registration_provider = vc
     2 registration_status = vc
     2 registration_date_time = vc
     2 security_vip = vc
     2 sex = vc
     2 specialty = vc
     2 ssn = vc
     2 team = vc
     2 track_group_cd = cv
     2 track_group = vc
     2 tracking_checkin_id = f8
     2 tracking_comment1 = vc
     2 tracking_comment2 = vc
     2 tracking_comment3 = vc
     2 tracking_comment4 = vc
     2 tracking_comment5 = vc
     2 tracking_comment6 = vc
     2 tracking_comment7 = vc
     2 tracking_comment8 = vc
     2 tracking_comment9 = vc
     2 tracking_comment10 = vc
     2 tracking_id = f8
     2 tvl = vc
     2 visit_age = vc
     2 documentation_status = vc
     2 region_cd = f8
     2 disaster_name = c30
     2 pa_type = vc
     2 pa_eta = vc
     2 pa_ta = vc
     2 pa_user = vc
     2 pa_ref_source = vc
     2 radiologist = vc
     2 event_id = f8
     2 note_title = vc
     2 checkout_update_name = vc
     2 disch_action_reason = vc
     2 clinician = vc
     2 nurse = vc
     2 num_pat_seen = i4
     2 num_pat_admitted = i4
     2 num_pat_disch = i4
     2 admit_pat_info = vc
     2 disch_pat_info = vc
     2 interval_median = vc
     2 interval_max = vc
     2 interval_avg = vc
     2 ed_physician = vc
     2 ed_reviewer = vc
     2 discrepancy = vc
     2 cardiologist = vc
     2 proc_dt_tm = vc
     2 acknowledged_ind = i2
     2 location_info [* ]
       3 arrival_date = vc
       3 location_nurse_cd = vc
       3 location_room_cd = vc
       3 location_bed_cd = vc
       3 location_updated_by = vc
     2 event_info [* ]
       3 event_name = vc
       3 event_status_display = vc
       3 request_date_time = vc
       3 request_time = vc
       3 start_date_time = vc
       3 start_time = vc
       3 complete_date_time = vc
       3 complete_time = vc
     2 provider_info [* ]
       3 provider_name = vc
       3 provider_role = vc
       3 assign_date_time = vc
       3 unassign_date_time = vc
   1 tracking_loc [* ]
     2 location_cd = f8
     2 location_value = vc
   1 results [* ]
     2 event_display = vc
     2 result_display = vc
   1 orders [* ]
     2 order_display = vc
     2 order_result_display = vc
     2 hna_order_mnemonic = vc
     2 orig_ord_date = vc
     2 doc_name = vc
     2 status_display = vc
     2 start_date = vc
     2 catalog_type_display = vc
     2 catalog_type_cd = f8
     2 start_date = vc
     2 stop_date = vc
   1 view_wet_read = vc
   1 track_group_cd = f8
 )
 RECORD acuities (
   1 total = i4
   1 acuity [* ]
     2 censuscnt = i4
     2 acuitystr = c50
     2 average = f8
 )
 RECORD events (
   1 total = i4
   1 firsteventdisplay = vc
   1 secondeventdisplay = vc
   1 avgtime = vc
   1 eventtime [* ]
     2 starttime = vc
     2 endtime = vc
     2 numberofpatients = i4
     2 averagetime = vc
 )
 RECORD orders (
   1 total = i4
   1 orderdisplay = vc
   1 avgtime = vc
   1 ordertime [* ]
     2 starttime = vc
     2 endtime = vc
     2 numberofpatients = i4
     2 averagetime = vc
 )
 RECORD emsstruct (
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 patientcount = vc
 )
 RECORD dispostruct (
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 dispostring = vc
     2 interval_total = i2
     2 startcount = i2
     2 endcount = i2
     2 averagetime = vc
     2 dispo [* ]
       3 starttime = vc
       3 endtime = vc
       3 dispositiondisplay = vc
       3 patientcount = i2
 )
 RECORD topproblemsstruct (
   1 tvlgroup [* ]
     2 tvl = c255
     2 totallos = f8
     2 tvlpatcount = i4
     2 rfvgroup [* ]
       3 tvldisplay = c255
       3 rfv = c255
       3 numberrfv = c255
       3 percentrfv = c255
       3 minlos = c255
       3 minlosf = f8
       3 avelos = c255
       3 totallos = f8
       3 maxlos = c255
       3 maxlosf = f8
       3 sortingfield = c255
   1 total_number = c255
   1 total_percent = c255
   1 total_min_los = c255
   1 total_ave_los = c255
   1 total_max_los = c255
   1 disposition = c255
   1 statistics = c255
 )
 RECORD diagchiefcomp (
   1 qual [* ]
     2 starttime = vc
     2 endtime = vc
     2 intervalpatcount = i4
     2 diagnosis [* ]
       3 diagnosiscnt = i4
       3 diagccdisplay = vc
       3 nomenclatureid = f8
 )
 RECORD dispodetailstruct (
   1 dispo [* ]
     2 starttime = vc
     2 endtime = vc
     2 dispositiondisplay = vc
     2 dispositioncd = f8
     2 patientcount = i2
     2 encntr_id = f8
     2 averagetime = vc
 )
 RECORD dashboard (
   1 totalpatients = i4
   1 totallos = i4
   1 avglos = vc
   1 highestlos = i4
   1 highestlostrackingid = f8
   1 bedcount = i4
   1 waitroomcount = i4
   1 lwbsdispocount = i4
   1 dispo1count = i4
   1 dispo1name = vc
   1 dispo2name = vc
   1 dispo3name = vc
   1 dispo4name = vc
   1 dispo2count = i4
   1 dispo3count = i4
   1 dispo4count = i4
   1 eventpair1time = vc
   1 eventpair2time = vc
   1 eventpair3time = vc
   1 eventpair4time = vc
   1 eventpair1name = vc
   1 eventpair2name = vc
   1 eventpair3name = vc
   1 eventpair4name = vc
   1 bed_status [* ]
     2 bed_status = vc
     2 bed_status_cnt = i4
     2 bed_status_cd = f8
   1 acuities [* ]
     2 acuity_desc = vc
     2 acuity_cnt = i4
     2 acuity_cd = f8
 )
 RECORD totals (
   1 total = i4
   1 avgtime = vc
   1 alllos = i4
   1 admittotals = i4
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 starttimeformat = vc
     2 endtimeformat = vc
     2 patientcount = i4
     2 intervalhour = i4
     2 averagetime = vc
     2 startcount = i2
     2 endcount = i2
     2 total_los = i4
     2 admittedcount = i4
 )
 RECORD topdiagnosis (
   1 total = i4
   1 diagnosis [* ]
     2 nomenclatureid = f8
     2 display = vc
     2 diagnosiscnt = i4
 )
 FREE RECORD dcp_request
 RECORD dcp_request (
   1 patient_list [* ]
     2 patient_id = f8
   1 pregnancy_list [* ]
     2 pregnancy_id = f8
 )
 DECLARE pri_doc_role = f8 WITH noconstant (0.0 )
 DECLARE sec_doc_role = f8 WITH noconstant (0.0 )
 DECLARE pri_nur_role = f8 WITH noconstant (0.0 )
 DECLARE sec_nur_role = f8 WITH noconstant (0.0 )
 DECLARE prvrole_assoc = f8 WITH noconstant (0.0 )
 DECLARE comp_name_unique = vc
 DECLARE attnddoc_cd = f8 WITH noconstant (0.0 )
 DECLARE admitdoc_cd = f8 WITH noconstant (0.0 )
 DECLARE refdoc_cd = f8 WITH noconstant (0.0 )
 DECLARE rfv_cd = f8 WITH noconstant (0.0 )
 DECLARE disch_cd = f8 WITH noconstant (0.0 )
 DECLARE regstatuscd = f8 WITH noconstant (0.0 )
 DECLARE disch_cd = f8 WITH noconstant (0.0 )
 DECLARE trkcommenttype = f8 WITH noconstant (0.0 )
 DECLARE acuitycd = f8 WITH noconstant (0.0 )
 DECLARE specialtycd = f8 WITH noconstant (0.0 )
 DECLARE teamcd = f8 WITH noconstant (0.0 )
 DECLARE pcpdoc_cd = f8 WITH noconstant (0.0 )
 DECLARE provsrc = f8 WITH noconstant (0.0 )
 DECLARE comp_pref = vc
 DECLARE len = i4 WITH noconstant (0 )
 DECLARE counter = i4 WITH noconstant (0 )
 DECLARE counter1 = i4 WITH noconstant (0 )
 DECLARE counter2 = i4 WITH noconstant (0 )
 SET stat = uar_get_meaning_by_codeset (17 ,"DISCHARGE" ,1 ,disch_cd )
 SET stat = uar_get_meaning_by_codeset (17 ,"RFV" ,1 ,rfv_cd )
 SET stat = uar_get_meaning_by_codeset (333 ,"ADMITDOC" ,1 ,admitdoc_cd )
 SET stat = uar_get_meaning_by_codeset (333 ,"ATTENDDOC" ,1 ,attnddoc_cd )
 SET stat = uar_get_meaning_by_codeset (333 ,"REFERDOC" ,1 ,refdoc_cd )
 SET stat = uar_get_meaning_by_codeset (355 ,"TRACKCOMMENT" ,1 ,trkcommenttype )
 SET stat = uar_get_meaning_by_codeset (16409 ,"ACUITY" ,1 ,acuitycd )
 SET stat = uar_get_meaning_by_codeset (16409 ,"REGSTAT" ,1 ,regstatuscd )
 SET stat = uar_get_meaning_by_codeset (16409 ,"SPECIALTY" ,1 ,specialtycd )
 SET stat = uar_get_meaning_by_codeset (16409 ,"TEAM" ,1 ,teamcd )
 SET stat = uar_get_meaning_by_codeset (331 ,"PCP" ,1 ,pcpdoc_cd )
 SET stat = uar_get_meaning_by_codeset (19009 ,"PSFENABLED" ,1 ,provsrc )
 SELECT INTO "nl:"
  FROM (location loc ),
   (organization o ),
   (track_group tg )
  PLAN (tg
   WHERE (tg.tracking_group_cd =  $TRACKGROUPCD )
   AND (tg.child_table = "TRACK_ASSOC" ) )
   JOIN (loc
   WHERE (loc.location_cd = tg.parent_value )
   AND (loc.active_ind = 1 ) )
   JOIN (o
   WHERE (o.organization_id = loc.organization_id ) )
  DETAIL
   output_data->report_data.facility_display = o.org_name
  WITH nocounter ,maxrec = 1
 ;end select
 IF ((provsrc != 0.0 ) )
  SET prvrole_assoc = 0.0
  SET stat = uar_get_meaning_by_codeset (20500 ,"PRVROLEASSOC" ,1 ,prvrole_assoc )
  SET comp_pref = fillstring (30 ,"" )
  SET comp_name_unique = fillstring (30 ,"" )
  SET comp_name_unique = concat (trim (cnvtstring ( $TRACKGROUPCD ) ) ,";" ,trim (cnvtstring (
     prvrole_assoc ) ) )
  SELECT INTO "nl:"
   FROM (track_prefs tp )
   WHERE (tp.comp_name_unq = comp_name_unique )
   DETAIL
    comp_pref = tp.comp_pref
   WITH nocounter
  ;end select
  SET len = textlen (comp_pref )
  SET counter = findstring (";" ,comp_pref )
  SET pri_doc_role = cnvtreal (substring (1 ,(counter - 1 ) ,comp_pref ) )
  SET counter1 = findstring (";" ,comp_pref ,(counter + 1 ) )
  SET sec_doc_role = cnvtreal (substring ((counter + 1 ) ,(counter1 - (counter + 1 ) ) ,comp_pref )
   )
  SET counter2 = findstring (";" ,comp_pref ,(counter1 + 1 ) )
  SET pri_nur_role = cnvtreal (substring ((counter1 + 1 ) ,(counter2 - (counter1 + 1 ) ) ,comp_pref
    ) )
  SET sec_nur_role = cnvtreal (substring ((counter2 + 1 ) ,(len - counter2 ) ,comp_pref ) )
 ENDIF
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 SET output_data->report_data.report_title =  $REPNAME
 SET output_data->report_data.track_group_display = uar_i18nbuildmessage (i18nhandle ,"fn_TrkGroup" ,
  "For: %1" ,"s" ,nullterm (trim (uar_get_code_description ( $TRACKGROUPCD ) ) ) )
 SET output_data->report_data.report_generation_date = uar_i18nbuildmessage (i18nhandle ,
  "fn_GenReportDate" ,"Printed At: %1" ,"s" ,nullterm (concat (format (curdate ,"@SHORTDATE" ) ,
    "  " ,format (curtime3 ,"@TIMENOSECONDS" ) ) ) )
 SELECT INTO "nl:"
  FROM (prsnl p )
  WHERE (p.person_id = reqinfo->updt_id )
  DETAIL
   output_data->report_data.report_generation_name = uar_i18nbuildmessage (i18nhandle ,"fn_GenName" ,
    "Printed By: %1" ,"s" ,nullterm (p.name_full_formatted ) )
  WITH nocounter
 ;end select
 IF (( $NURSEUNIT = 0 ) )
  DECLARE bedcount = i4
  DECLARE bedpatcount = i4
  DECLARE pt_count = i4
  DECLARE emptybed = i4
  DECLARE waitpatcount = i4
  DECLARE cocount = i4
  DECLARE copatcount = i4
  DECLARE heldbedstatus = i4
  DECLARE waitcount = i4
  RECORD requestcopy (
    1 view_id = f8
  )
  RECORD reply2 (
    1 qual [* ]
      2 code = f8
      2 desc = cv
      2 cdf = cv
      2 status = cv
      2 status_cd = f8
      2 pt_count = i2
      2 held_for = vc
      2 held_count = i2
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
  RECORD locview (
    1 totalbedcount = i4
    1 totalbedpatcount = i4
    1 totalwrcount = i4
    1 totalwrpatcount = i4
    1 bunkedbeds = vc
    1 emptybedcount = i4
    1 heldbedcount = i4
    1 prearrivalcount = i4
    1 emptybeds = vc
    1 bed [* ]
      2 bedname = vc
      2 bedcount = i4
      2 bunked = i2
      2 loc_cd = f8
    1 wait [* ]
      2 roomname = vc
      2 roomcount = i4
      2 loc_cd = f8
    1 checkout [* ]
      2 roomname = vc
      2 roomcount = i4
      2 loc_cd = f8
  )
  DECLARE expandindex = i4 WITH noconstant (0 )
  DECLARE loccount = i4 WITH noconstant (0 )
  SET requestcopy->view_id =  $LOCVIEW
  EXECUTE trkcsp_get_load_locview WITH replace (reply ,reply2 ) ,
  replace (request ,requestcopy )
  SET loccount = size (reply2->qual ,5 )
  DECLARE bedcount = i4 WITH noconstant (0 )
  DECLARE bedpatcount = i4 WITH noconstant (0 )
  DECLARE pt_count = i4 WITH noconstant (0 )
  DECLARE emptybed = i4 WITH noconstant (0 )
  DECLARE waitpatcount = i4 WITH noconstant (0 )
  DECLARE cocount = i4 WITH noconstant (0 )
  DECLARE copatcount = i4 WITH noconstant (0 )
  DECLARE heldbedstatus = i4 WITH noconstant (0 )
  DECLARE waitcount = i4 WITH noconstant (0 )
  IF ((size (reply2->qual ,5 ) > 0 ) )
   SELECT INTO "nl:"
    FROM (dummyt d WITH seq = size (reply2->qual ,5 ) )
    DETAIL
     IF ((reply2->qual[d.seq ].cdf = "BED" ) ) bedcount = (bedcount + 1 ) ,bedpatcount = (
      bedpatcount + reply2->qual[d.seq ].pt_count ) ,stat = alterlist (locview->bed ,bedcount ) ,
      locview->bed[bedcount ].bedname = reply2->qual[d.seq ].desc ,locview->bed[bedcount ].bedcount
      = reply2->qual[d.seq ].pt_count ,locview->bed[bedcount ].loc_cd = reply2->qual[d.seq ].code
     ELSEIF ((reply2->qual[d.seq ].cdf = "WAITROOM" ) ) waitcount = (waitcount + 1 ) ,stat =
      alterlist (locview->wait ,waitcount ) ,waitpatcount = (waitpatcount + reply2->qual[d.seq ].
      pt_count ) ,locview->wait[waitcount ].roomname = reply2->qual[d.seq ].desc ,locview->wait[
      waitcount ].roomcount = reply2->qual[d.seq ].pt_count ,locview->wait[waitcount ].loc_cd =
      reply2->qual[d.seq ].code
     ELSEIF ((reply2->qual[d.seq ].cdf = "CHECKOUT" ) ) cocount = (cocount + 1 ) ,stat = alterlist (
       locview->checkout ,cocount ) ,copatcount = (copatcount + reply2->qual[d.seq ].pt_count ) ,
      locview->checkout[cocount ].roomname = reply2->qual[d.seq ].desc ,locview->checkout[cocount ].
      roomcount = reply2->qual[d.seq ].pt_count ,locview->checkout[cocount ].loc_cd = reply2->qual[d
      .seq ].code
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET output_data->report_data.report_nurseunit_name = trim (uar_get_code_description (cnvtreal (
      $LOCVIEW ) ) )
 ELSE
  SET output_data->report_data.report_nurseunit_name = trim (uar_get_code_description (cnvtreal (
      $NURSEUNIT ) ) )
 ENDIF
 SET output_data->report_data.report_nurseunit_name = uar_i18nbuildmessage (i18nhandle ,
  "fn_NurseUnit" ,"Location: %1" ,"s" ,nullterm (output_data->report_data.report_nurseunit_name ) )
 DECLARE date_range_size = f8 WITH noconstant (0.0 )
 DECLARE sbegin = vc WITH noconstant
 DECLARE send = vc WITH noconstant
 SET date_range_size = datetimediff (cnvtdatetime ( $ENDDATE ) ,cnvtdatetime ( $STARTDATE ) )
 SET sbegin = uar_i18nbuildmessage (i18nhandle ,"fn_GenStartDate" ,"From: %1" ,"s" ,nullterm (
   format (cnvtdatetime ( $STARTDATE ) ,"@SHORTDATETIMENOSEC" ) ) )
 SET send = uar_i18nbuildmessage (i18nhandle ,"fn_GenEndDate" ,"To: %1" ,"s" ,nullterm (format (
    cnvtdatetime ( $ENDDATE ) ,"@SHORTDATETIMENOSEC" ) ) )
 SET output_data->report_data.start_date = sbegin
 SET output_data->report_data.end_date = send
 SET output_data->report_data.report_date = trim (concat (sbegin ,"&nbsp;&nbsp;" ,send ) )
 DECLARE totalpats = i4 WITH persistscript ,noconstant (0 )
 SELECT INTO "nl:"
  FROM (tracking_checkin tc ),
   (tracking_item ti ),
   (encounter e ),
   (person p )
  PLAN (tc
   WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
   AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
   AND ((tc.tracking_group_cd + 0 ) =  $TRACKGROUPCD )
   AND ((tc.active_ind + 0 ) = 1 ) )
   JOIN (ti
   WHERE (ti.tracking_id = tc.tracking_id )
   AND (ti.active_ind = 1 ) )
   JOIN (p
   WHERE (p.person_id = ti.person_id )
   AND (p.active_ind = 1 ) )
   JOIN (e
   WHERE (e.encntr_id = ti.encntr_id )
   AND (e.active_ind = 1 ) )
  ORDER BY tc.tracking_id
  HEAD tc.tracking_id
   totalpats = (totalpats + 1 )
  WITH nocounter
 ;end select
 DECLARE checkoutdispositionexists = i2 WITH noconstant (0 )
 SELECT INTO "nl:"
  FROM (user_tab_columns utc )
  WHERE (utc.table_name = "TRACKING_CHECKIN" )
  AND (utc.column_name = "CHECKOUT_DISPOSITION_CD" )
  DETAIL
   checkoutdispositionexists = 1
  WITH nocounter
 ;end select
 DECLARE calclos (timedbl ,patientcount ) = cv
 FREE RECORD report_labels
 RECORD report_labels (
   1 summary = vc
   1 total_pats = vc
   1 person_name = vc
   1 mrn = vc
   1 age_gender = vc
   1 checkin_date = vc
   1 rfv = vc
   1 ed_physician = vc
   1 admitting = vc
   1 arrival_mode = vc
   1 los_checkin = vc
   1 fin = vc
   1 birth_date = vc
   1 primary_nurse = vc
   1 acuity = vc
   1 diagnosis = vc
   1 checkout_date = vc
   1 discharge = vc
   1 disposition = vc
   1 total_qual_pats = vc
   1 ega = vc
   1 edd = vc
 )
 DECLARE debugger = vc
 IF ((all_reason_flag = 1 ) )
  SET debugger = "a"
  SELECT
   IF ((cnvtreal ( $NURSEUNIT ) > 0.0 ) )
    FROM (tracking_checkin tc ),
     (tracking_item ti ),
     (person p ),
     (encounter e ),
     (track_reference t ),
     (tracking_locator tl )
    PLAN (tc
     WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
     AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
     AND ((tc.tracking_group_cd + 0 ) = cnvtreal ( $TRACKGROUPCD ) )
     AND ((tc.active_ind + 0 ) = 1 ) )
     JOIN (ti
     WHERE (ti.tracking_id = tc.tracking_id )
     AND ((ti.active_ind + 0 ) = 1 ) )
     JOIN (e
     WHERE (e.encntr_id = ti.encntr_id )
     AND ((e.active_ind + 0 ) = 1 ) )
     JOIN (p
     WHERE (p.person_id = ti.person_id )
     AND ((p.active_ind + 0 ) = 1 ) )
     JOIN (t
     WHERE (t.tracking_ref_id = tc.acuity_level_id ) )
     JOIN (tl
     WHERE (tl.tracking_id = tc.tracking_id )
     AND ((tl.loc_nurse_unit_cd + 0 ) = cnvtreal ( $NURSEUNIT ) ) )
   ELSE
    FROM (tracking_checkin tc ),
     (tracking_item ti ),
     (person p ),
     (encounter e ),
     (track_reference t ),
     (tracking_locator tl )
    PLAN (tc
     WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
     AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
     AND ((tc.tracking_group_cd + 0 ) = cnvtreal ( $TRACKGROUPCD ) )
     AND ((tc.active_ind + 0 ) = 1 ) )
     JOIN (ti
     WHERE (ti.tracking_id = tc.tracking_id ) )
     JOIN (e
     WHERE (e.encntr_id = ti.encntr_id )
     AND ((e.active_ind + 0 ) = 1 ) )
     JOIN (p
     WHERE (p.person_id = ti.person_id )
     AND ((p.active_ind + 0 ) = 1 ) )
     JOIN (t
     WHERE (t.tracking_ref_id = tc.acuity_level_id ) )
     JOIN (tl
     WHERE (tl.tracking_id = tc.tracking_id )
     AND ((expand (expandindex ,1 ,bedcount ,(tl.loc_bed_cd + 0 ) ,locview->bed[expandindex ].loc_cd
      ) ) OR (((expand (expandindex ,1 ,waitcount ,(tl.loc_room_cd + 0 ) ,locview->wait[expandindex ]
      .loc_cd ) ) OR (expand (expandindex ,1 ,cocount ,(tl.loc_room_cd + 0 ) ,locview->checkout[
      expandindex ].loc_cd ) )) )) )
   ENDIF
   INTO "nl:"
   ORDER BY tc.tracking_id
   HEAD REPORT
    pat_count = 0 ,
    age = fillstring (12 ," " ) ,
    space_pos = 0
   HEAD tc.tracking_id
    pat_count = (pat_count + 1 ) ,
    IF ((pat_count > size (output_data->patient_data ,5 ) ) ) stat = alterlist (output_data->
      patient_data ,(pat_count + 100 ) ) ,stat = alterlist (dcp_request->patient_list ,(pat_count +
      100 ) )
    ENDIF
    ,
    IF ((cnvtint ( $SORTORDER ) = 1 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (p.name_full_formatted )
    ELSEIF ((cnvtint ( $SORTORDER ) = 2 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (t.description )
    ELSEIF ((cnvtint ( $SORTORDER ) = 3 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkin_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 4 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkout_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 5 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkin_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 6 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (uar_get_code_display (e.admit_mode_cd ) )
    ELSEIF ((cnvtint ( $SORTORDER ) = 8 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (p.birth_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSE output_data->patient_data[pat_count ].sorting_field = format (tc.checkin_dt_tm ,
      "YYYYMMDDHHMMSSCC;;D" )
    ENDIF
    ,output_data->patient_data[pat_count ].name_full_formatted = trim (p.name_full_formatted ) ,
    output_data->patient_data[pat_count ].visit_id = e.encntr_id ,output_data->patient_data[
    pat_count ].person_id = p.person_id ,dcp_request->patient_list[pat_count ].patient_id = p
    .person_id ,output_data->patient_data[pat_count ].tracking_id = tc.tracking_id ,output_data->
    patient_data[pat_count ].sex = uar_get_code_display (p.sex_cd ) ,output_data->patient_data[
    pat_count ].birth_date = format (p.birth_dt_tm ,"@SHORTDATE" ) ,age = trim (cnvtage (p
      .birth_dt_tm ,tc.checkin_dt_tm ,1 ) ) ,space_pos = findstring (" " ,age ,1 ,1 ) ,
    IF ((space_pos > 0 ) ) cut_pos = (space_pos + 1 ) ,new_age = substring (1 ,cut_pos ,age ) ,
     output_data->patient_data[pat_count ].visit_age = new_age
    ELSE output_data->patient_data[pat_count ].visit_age = age
    ENDIF
    ,output_data->patient_data[pat_count ].admit_mode = uar_get_code_display (e.admit_mode_cd ) ,
    output_data->patient_data[pat_count ].arrive_date_time = concat (format (e.arrive_dt_tm ,
      "@SHORTDATE" ) ," " ,format (e.arrive_dt_tm ,"@TIMENOSECONDS" ) ) ,
    IF ((checkoutdispositionexists = 1 ) ) output_data->patient_data[pat_count ].
     discharge_disposition = uar_get_code_display (validate (tc.checkout_disposition_cd ,0.0 ) )
    ELSE output_data->patient_data[pat_count ].discharge_disposition = uar_get_code_display (e
      .disch_disposition_cd )
    ENDIF
    ,output_data->patient_data[pat_count ].discharge_to_location = uar_get_code_display (e
     .disch_to_loctn_cd ) ,output_data->patient_data[pat_count ].discharge_date_time = concat (
     format (e.disch_dt_tm ,"@SHORTDATE" ) ," " ,format (e.disch_dt_tm ,"@TIMENOSECONDS" ) ) ,
    output_data->patient_data[pat_count ].encntr_id = e.encntr_id ,output_data->patient_data[
    pat_count ].mrn = "not valued" ,output_data->patient_data[pat_count ].registration_date_time =
    concat (format (e.reg_dt_tm ,"@SHORTDATE" ) ," " ,format (e.reg_dt_tm ,"@TIMENOSECONDS" ) ) ,
    output_data->patient_data[pat_count ].checkin_date = format (tc.checkin_dt_tm ,"@SHORTDATE" ) ,
    output_data->patient_data[pat_count ].checkin_time = format (tc.checkin_dt_tm ,"@TIMENOSECONDS"
     ) ,output_data->patient_data[pat_count ].checkin_date_time = concat (output_data->patient_data[
     pat_count ].checkin_date ," " ,output_data->patient_data[pat_count ].checkin_time ) ,
    IF ((tc.checkout_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) output_data->patient_data[
     pat_count ].checkout_date = format (tc.checkout_dt_tm ,"@SHORTDATE" ) ,output_data->
     patient_data[pat_count ].checkout_time = format (tc.checkout_dt_tm ,"@TIMENOSECONDS" )
    ELSE output_data->patient_data[pat_count ].checkout_date = "Not checked out"
    ENDIF
    ,output_data->patient_data[pat_count ].checkout_date_time = concat (output_data->patient_data[
     pat_count ].checkout_date ," " ,output_data->patient_data[pat_count ].checkout_time ) ,
    output_data->patient_data[pat_count ].family_present = uar_get_code_display (tc
     .family_present_cd ) ,
    IF ((tc.checkout_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) output_data->patient_data[
     pat_count ].los_checkin = calclos (((cnvtdatetime (tc.checkout_dt_tm ) - cnvtdatetime (tc
       .checkin_dt_tm ) ) / 600000000 ) ,1 )
    ELSE output_data->patient_data[pat_count ].los_checkin = calclos (((cnvtdatetime (curdate ,
       curtime3 ) - cnvtdatetime (tc.checkin_dt_tm ) ) / 600000000 ) ,1 )
    ENDIF
    ,output_data->patient_data[pat_count ].tracking_checkin_id = tc.tracking_checkin_id ,output_data
    ->patient_data[pat_count ].track_group = trim (uar_get_code_display (tc.tracking_group_cd ) ) ,
    output_data->patient_data[pat_count ].track_group_cd = cnvtstring (cnvtint (tc.tracking_group_cd
      ) ) ,output_data->patient_data[pat_count ].acuity = t.description
   FOOT REPORT
    stat = alterlist (output_data->patient_data ,pat_count ) ,
    stat = alterlist (dcp_request->patient_list ,pat_count )
   WITH nocounter
  ;end select
 ELSE
  SET debugger = concat (debugger ,"b" )
  SELECT
   IF ((cnvtreal ( $NURSEUNIT ) > 0.0 ) )
    FROM (tracking_checkin tc ),
     (tracking_item ti ),
     (person p ),
     (encounter e ),
     (clinical_event ce ),
     (ce_coded_result cer ),
     (track_reference t ),
     (tracking_locator tl )
    PLAN (tc
     WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
     AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
     AND ((tc.tracking_group_cd + 0 ) = cnvtreal ( $TRACKGROUPCD ) )
     AND ((tc.active_ind + 0 ) = 1 ) )
     JOIN (ti
     WHERE (ti.tracking_id = tc.tracking_id )
     AND ((ti.active_ind + 0 ) = 1 ) )
     JOIN (e
     WHERE (e.encntr_id = ti.encntr_id )
     AND ((e.active_ind + 0 ) = 1 ) )
     JOIN (ce
     WHERE (ce.encntr_id = e.encntr_id )
     AND (ce.result_status_cd IN (auth ,
     altered ,
     modified ) )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND expand (rvidx ,1 ,reas->cnt ,ce.event_cd ,reas->rec[rvidx ].code_value ) )
     JOIN (cer
     WHERE (cer.event_id = ce.event_id )
     AND (cer.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND expand (aridx ,1 ,nomen->cnt ,cer.nomenclature_id ,nomen->rec[aridx ].nomenclature_id ) )
     JOIN (p
     WHERE (p.person_id = ti.person_id )
     AND ((p.active_ind + 0 ) = 1 ) )
     JOIN (t
     WHERE (t.tracking_ref_id = tc.acuity_level_id ) )
     JOIN (tl
     WHERE (tl.tracking_id = tc.tracking_id )
     AND ((tl.loc_nurse_unit_cd + 0 ) = cnvtreal ( $NURSEUNIT ) ) )
   ELSE
    FROM (tracking_checkin tc ),
     (tracking_item ti ),
     (person p ),
     (encounter e ),
     (clinical_event ce ),
     (ce_coded_result cer ),
     (track_reference t ),
     (tracking_locator tl )
    PLAN (tc
     WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
     AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
     AND ((tc.tracking_group_cd + 0 ) = cnvtreal ( $TRACKGROUPCD ) )
     AND ((tc.active_ind + 0 ) = 1 ) )
     JOIN (ti
     WHERE (ti.tracking_id = tc.tracking_id ) )
     JOIN (e
     WHERE (e.encntr_id = ti.encntr_id )
     AND ((e.active_ind + 0 ) = 1 ) )
     JOIN (ce
     WHERE (ce.encntr_id = e.encntr_id )
     AND (ce.result_status_cd IN (auth ,
     altered ,
     modified ) )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND expand (rvidx ,1 ,reas->cnt ,ce.event_cd ,reas->rec[rvidx ].code_value ) )
     JOIN (cer
     WHERE (cer.event_id = ce.event_id )
     AND (cer.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND expand (aridx ,1 ,nomen->cnt ,cer.nomenclature_id ,nomen->rec[aridx ].nomenclature_id ) )
     JOIN (p
     WHERE (p.person_id = ti.person_id )
     AND ((p.active_ind + 0 ) = 1 ) )
     JOIN (t
     WHERE (t.tracking_ref_id = tc.acuity_level_id ) )
     JOIN (tl
     WHERE (tl.tracking_id = tc.tracking_id )
     AND ((expand (expandindex ,1 ,bedcount ,(tl.loc_bed_cd + 0 ) ,locview->bed[expandindex ].loc_cd
      ) ) OR (((expand (expandindex ,1 ,waitcount ,(tl.loc_room_cd + 0 ) ,locview->wait[expandindex ]
      .loc_cd ) ) OR (expand (expandindex ,1 ,cocount ,(tl.loc_room_cd + 0 ) ,locview->checkout[
      expandindex ].loc_cd ) )) )) )
   ENDIF
   INTO "nl:"
   ORDER BY tc.tracking_id ,
    ce.event_end_dt_tm DESC
   HEAD REPORT
    pat_count = 0 ,
    age = fillstring (12 ," " ) ,
    space_pos = 0
   HEAD tc.tracking_id
    pat_count = (pat_count + 1 ) ,
    IF ((pat_count > size (output_data->patient_data ,5 ) ) ) stat = alterlist (output_data->
      patient_data ,(pat_count + 100 ) ) ,stat = alterlist (dcp_request->patient_list ,(pat_count +
      100 ) )
    ENDIF
    ,
    IF ((cnvtint ( $SORTORDER ) = 1 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (p.name_full_formatted )
    ELSEIF ((cnvtint ( $SORTORDER ) = 2 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (t.description )
    ELSEIF ((cnvtint ( $SORTORDER ) = 3 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkin_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 4 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkout_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 5 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (tc.checkin_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSEIF ((cnvtint ( $SORTORDER ) = 6 ) ) output_data->patient_data[pat_count ].sorting_field =
     cnvtupper (uar_get_code_display (e.admit_mode_cd ) )
    ELSEIF ((cnvtint ( $SORTORDER ) = 8 ) ) output_data->patient_data[pat_count ].sorting_field =
     format (p.birth_dt_tm ,"YYYYMMDDHHMMSSCC;;D" )
    ELSE output_data->patient_data[pat_count ].sorting_field = format (tc.checkin_dt_tm ,
      "YYYYMMDDHHMMSSCC;;D" )
    ENDIF
    ,output_data->patient_data[pat_count ].name_full_formatted = trim (p.name_full_formatted ) ,
    output_data->patient_data[pat_count ].visit_id = e.encntr_id ,output_data->patient_data[
    pat_count ].person_id = p.person_id ,dcp_request->patient_list[pat_count ].patient_id = p
    .person_id ,output_data->patient_data[pat_count ].tracking_id = tc.tracking_id ,output_data->
    patient_data[pat_count ].sex = uar_get_code_display (p.sex_cd ) ,output_data->patient_data[
    pat_count ].birth_date = format (p.birth_dt_tm ,"@SHORTDATE" ) ,age = trim (cnvtage (p
      .birth_dt_tm ,tc.checkin_dt_tm ,1 ) ) ,space_pos = findstring (" " ,age ,1 ,1 ) ,
    IF ((space_pos > 0 ) ) cut_pos = (space_pos + 1 ) ,new_age = substring (1 ,cut_pos ,age ) ,
     output_data->patient_data[pat_count ].visit_age = new_age
    ELSE output_data->patient_data[pat_count ].visit_age = age
    ENDIF
    ,output_data->patient_data[pat_count ].admit_mode = uar_get_code_display (e.admit_mode_cd ) ,
    output_data->patient_data[pat_count ].arrive_date_time = concat (format (e.arrive_dt_tm ,
      "@SHORTDATE" ) ," " ,format (e.arrive_dt_tm ,"@TIMENOSECONDS" ) ) ,
    IF ((checkoutdispositionexists = 1 ) ) output_data->patient_data[pat_count ].
     discharge_disposition = uar_get_code_display (validate (tc.checkout_disposition_cd ,0.0 ) )
    ELSE output_data->patient_data[pat_count ].discharge_disposition = uar_get_code_display (e
      .disch_disposition_cd )
    ENDIF
    ,output_data->patient_data[pat_count ].discharge_to_location = uar_get_code_display (e
     .disch_to_loctn_cd ) ,output_data->patient_data[pat_count ].discharge_date_time = concat (
     format (e.disch_dt_tm ,"@SHORTDATE" ) ," " ,format (e.disch_dt_tm ,"@TIMENOSECONDS" ) ) ,
    output_data->patient_data[pat_count ].encntr_id = e.encntr_id ,output_data->patient_data[
    pat_count ].mrn = "not valued" ,output_data->patient_data[pat_count ].registration_date_time =
    concat (format (e.reg_dt_tm ,"@SHORTDATE" ) ," " ,format (e.reg_dt_tm ,"@TIMENOSECONDS" ) ) ,
    output_data->patient_data[pat_count ].checkin_date = format (tc.checkin_dt_tm ,"@SHORTDATE" ) ,
    output_data->patient_data[pat_count ].checkin_time = format (tc.checkin_dt_tm ,"@TIMENOSECONDS"
     ) ,output_data->patient_data[pat_count ].checkin_date_time = concat (output_data->patient_data[
     pat_count ].checkin_date ," " ,output_data->patient_data[pat_count ].checkin_time ) ,
    IF ((tc.checkout_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) output_data->patient_data[
     pat_count ].checkout_date = format (tc.checkout_dt_tm ,"@SHORTDATE" ) ,output_data->
     patient_data[pat_count ].checkout_time = format (tc.checkout_dt_tm ,"@TIMENOSECONDS" )
    ELSE output_data->patient_data[pat_count ].checkout_date = "Not checked out"
    ENDIF
    ,output_data->patient_data[pat_count ].checkout_date_time = concat (output_data->patient_data[
     pat_count ].checkout_date ," " ,output_data->patient_data[pat_count ].checkout_time ) ,
    output_data->patient_data[pat_count ].family_present = uar_get_code_display (tc
     .family_present_cd ) ,
    IF ((tc.checkout_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) output_data->patient_data[
     pat_count ].los_checkin = calclos (((cnvtdatetime (tc.checkout_dt_tm ) - cnvtdatetime (tc
       .checkin_dt_tm ) ) / 600000000 ) ,1 )
    ELSE output_data->patient_data[pat_count ].los_checkin = calclos (((cnvtdatetime (curdate ,
       curtime3 ) - cnvtdatetime (tc.checkin_dt_tm ) ) / 600000000 ) ,1 )
    ENDIF
    ,output_data->patient_data[pat_count ].tracking_checkin_id = tc.tracking_checkin_id ,output_data
    ->patient_data[pat_count ].track_group = trim (uar_get_code_display (tc.tracking_group_cd ) ) ,
    output_data->patient_data[pat_count ].track_group_cd = cnvtstring (cnvtint (tc.tracking_group_cd
      ) ) ,output_data->patient_data[pat_count ].acuity = t.description ,output_data->patient_data[
    pat_count ].reason_for_visit = trim (ce.result_val )
   FOOT REPORT
    stat = alterlist (output_data->patient_data ,pat_count ) ,
    stat = alterlist (dcp_request->patient_list ,pat_count )
   WITH nocounter
  ;end select
 ENDIF
 IF ((all_reason_flag = 1 ) )
  SELECT INTO "nl:"
   FROM (clinical_event ce ),
    (dummyt d WITH seq = size (output_data->patient_data ,5 ) )
   PLAN (d )
    JOIN (ce
    WHERE (ce.encntr_id = output_data->patient_data[d.seq ].visit_id )
    AND expand (rvidx ,1 ,reas->cnt ,ce.event_cd ,reas->rec[rvidx ].code_value )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY d.seq ,
    ce.event_end_dt_tm DESC
   HEAD d.seq
    output_data->patient_data[d.seq ].reason_for_visit = ce.result_val
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE dcp_get_final_ega WITH replace ("REQUEST" ,dcp_request ) ,
 replace ("REPLY" ,dcp_reply )
 SET modify = nopredeclare
 DECLARE zerodayscaption = vc
 DECLARE dayscaption = vc
 DECLARE oneweekcaption = vc
 DECLARE weekscaption = vc
 DECLARE fractionweekscaption = vc
 SET zerodayscaption = uar_i18ngetmessage (i18nhandle ,"cap6" ,"0 days" )
 SET dayscaption = uar_i18ngetmessage (i18nhandle ,"cap7" ," days" )
 SET oneweekcaption = uar_i18ngetmessage (i18nhandle ,"cap8" ,"1 week" )
 SET weekscaption = uar_i18ngetmessage (i18nhandle ,"cap9" ," weeks" )
 SET fractionweekscaption = uar_i18ngetmessage (i18nhandle ,"cap10" ,"/7 weeks" )
 FOR (output_pt_cnt = 1 TO size (output_data->patient_data ,5 ) )
  FOR (dcp_pt_cnt = 1 TO size (dcp_reply->gestation_info ,5 ) )
   IF ((output_data->patient_data[output_pt_cnt ].person_id = dcp_reply->gestation_info[dcp_pt_cnt ].
   person_id ) )
    SET output_data->patient_data[output_pt_cnt ].edd = format (dcp_reply->gestation_info[dcp_pt_cnt
     ].est_delivery_date ,"@SHORTDATE" )
    IF ((dcp_reply->gestation_info[dcp_pt_cnt ].delivered_ind > 0 ) )
     IF ((dcp_reply->gestation_info[dcp_pt_cnt ].gest_age_at_delivery <= 0 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = zerodayscaption
     ELSEIF ((dcp_reply->gestation_info[dcp_pt_cnt ].gest_age_at_delivery < 7 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = build (dcp_reply->gestation_info[
       dcp_pt_cnt ].gest_age_at_delivery ,dayscaption )
     ELSEIF ((dcp_reply->gestation_info[dcp_pt_cnt ].gest_age_at_delivery = 7 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = oneweekcaption
     ELSEIF ((mod (dcp_reply->gestation_info[dcp_pt_cnt ].gest_age_at_delivery ,7 ) = 0 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = build ((dcp_reply->gestation_info[
       dcp_pt_cnt ].gest_age_at_delivery / 7 ) ,weekscaption )
     ELSE
      SET output_data->patient_data[output_pt_cnt ].ega = concat (trim (cnvtstring ((dcp_reply->
         gestation_info[dcp_pt_cnt ].gest_age_at_delivery / 7 ) ) ) ," " ,trim (cnvtstring (mod (
          dcp_reply->gestation_info[dcp_pt_cnt ].gest_age_at_delivery ,7 ) ) ) ,fractionweekscaption
       )
     ENDIF
    ELSE
     IF ((dcp_reply->gestation_info[dcp_pt_cnt ].current_gest_age <= 0 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = zerodayscaption
     ELSEIF ((dcp_reply->gestation_info[dcp_pt_cnt ].current_gest_age < 7 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = build (dcp_reply->gestation_info[
       dcp_pt_cnt ].current_gest_age ,dayscaption )
     ELSEIF ((dcp_reply->gestation_info[dcp_pt_cnt ].current_gest_age = 7 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = oneweekcaption
     ELSEIF ((mod (dcp_reply->gestation_info[dcp_pt_cnt ].current_gest_age ,7 ) = 0 ) )
      SET output_data->patient_data[output_pt_cnt ].ega = build ((dcp_reply->gestation_info[
       dcp_pt_cnt ].current_gest_age / 7 ) ,weekscaption )
     ELSE
      SET output_data->patient_data[output_pt_cnt ].ega = concat (trim (cnvtstring ((dcp_reply->
         gestation_info[dcp_pt_cnt ].current_gest_age / 7 ) ) ) ," " ,trim (cnvtstring (mod (
          dcp_reply->gestation_info[dcp_pt_cnt ].current_gest_age ,7 ) ) ) ,fractionweekscaption )
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 IF (( $TRACKGROUPCD > 0.0 ) )
  SET output_data->track_group_cd = cnvtreal ( $TRACKGROUPCD )
 ENDIF
 DECLARE actual_size = i4 WITH noconstant (size (output_data->patient_data ,5 ) )
 DECLARE expand_size = i4 WITH noconstant (50 )
 DECLARE expand_total = i4 WITH noconstant ((ceil ((cnvtreal (actual_size ) / expand_size ) ) *
  expand_size ) )
 DECLARE expand_index = i4 WITH noconstant (0 )
 IF ((actual_size > 0 ) )
  DECLARE tempcnt = i4 WITH noconstant (0 )
  SET stat = alterlist (output_data->patient_data ,expand_total )
  FOR (tempcnt = (actual_size + 1 ) TO expand_total )
   SET output_data->patient_data[tempcnt ].person_id = output_data->patient_data[actual_size ].
   person_id
   SET output_data->patient_data[tempcnt ].encntr_id = output_data->patient_data[actual_size ].
   encntr_id
   SET output_data->patient_data[tempcnt ].tracking_id = output_data->patient_data[actual_size ].
   tracking_id
   SET output_data->patient_data[tempcnt ].tracking_checkin_id = output_data->patient_data[
   actual_size ].tracking_checkin_id
  ENDFOR
 ENDIF
 CALL echo ("fnrpt_get_aliases.inc" )
 DECLARE p_alias_type_cd_mrn = f8
 DECLARE p_alias_type_cd_ssn = f8
 DECLARE e_alias_type_cd_fin = f8
 DECLARE e_alias_type_cd_mrn = f8
 SET p_alias_type_cd_mrn = uar_get_code_by ("MEANING" ,4 ,"MRN" )
 SET p_alias_type_cd_ssn = uar_get_code_by ("MEANING" ,4 ,"SSN" )
 SET e_alias_type_cd_fin = uar_get_code_by ("MEANING" ,319 ,"FIN NBR" )
 SET e_alias_type_cd_mrn = uar_get_code_by ("MEANING" ,319 ,"MRN" )
 IF ((actual_size > 0 ) )
  SELECT INTO "nl:"
   FROM (person_alias pa ),
    (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
   PLAN (d )
    JOIN (pa
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,pa
     .person_id ,output_data->patient_data[expand_index ].person_id )
    AND (pa.person_alias_type_cd IN (p_alias_type_cd_mrn ,
    p_alias_type_cd_ssn ) ) )
   DETAIL
    lvindex = locateval (expand_index ,1 ,actual_size ,pa.person_id ,output_data->patient_data[
     expand_index ].person_id ) ,
    WHILE ((lvindex > 0 ) )
     IF ((pa.person_alias_type_cd = p_alias_type_cd_mrn ) ) output_data->patient_data[lvindex ].mrn
      = trim (cnvtalias (pa.alias ,pa.alias_pool_cd ) )
     ELSE output_data->patient_data[lvindex ].ssn = trim (cnvtalias (pa.alias ,pa.alias_pool_cd ) )
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,pa.person_id ,output_data->
      patient_data[expand_index ].person_id )
    ENDWHILE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (encntr_alias ea ),
    (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
   PLAN (d )
    JOIN (ea
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,ea
     .encntr_id ,output_data->patient_data[expand_index ].encntr_id )
    AND (ea.encntr_alias_type_cd IN (e_alias_type_cd_fin ,
    e_alias_type_cd_mrn ) ) )
   DETAIL
    lvindex = locateval (expand_index ,1 ,actual_size ,ea.encntr_id ,output_data->patient_data[
     expand_index ].encntr_id ) ,
    WHILE ((lvindex > 0 ) )
     IF ((ea.encntr_alias_type_cd = e_alias_type_cd_mrn ) ) output_data->patient_data[lvindex ].mrn
      = trim (cnvtalias (ea.alias ,ea.alias_pool_cd ) )
     ELSE output_data->patient_data[lvindex ].fin = trim (cnvtalias (ea.alias ,ea.alias_pool_cd ) )
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,ea.encntr_id ,output_data->
      patient_data[expand_index ].encntr_id )
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 CALL echo ("fnrpt_get_rfv_and_diag.inc" )
 IF ((actual_size > 0 ) )
  SELECT INTO "nl:"
   FROM (diagnosis diag ),
    (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
   PLAN (d )
    JOIN (diag
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,diag
     .encntr_id ,output_data->patient_data[expand_index ].encntr_id )
    AND ((diag.end_effective_dt_tm + 0 ) > cnvtdatetime (curdate ,curtime3 ) ) )
   DETAIL
    lvindex = locateval (expand_index ,1 ,actual_size ,diag.encntr_id ,output_data->patient_data[
     expand_index ].encntr_id ) ,
    WHILE ((lvindex > 0 ) )
     IF ((diag.diag_type_cd = rfv_cd ) )
      IF ((output_data->patient_data[lvindex ].reason_for_visit != null ) ) output_data->
       patient_data[lvindex ].reason_for_visit = concat (output_data->patient_data[lvindex ].
        reason_for_visit ,", " ,trim (diag.diagnosis_display ) )
      ELSE output_data->patient_data[lvindex ].reason_for_visit = trim (diag.diagnosis_display )
      ENDIF
     ELSE
      IF ((output_data->patient_data[lvindex ].disch_diagnosis != null ) ) output_data->patient_data[
       lvindex ].disch_diagnosis = concat (output_data->patient_data[lvindex ].disch_diagnosis ,", "
        ,trim (diag.diagnosis_display ) )
      ELSE output_data->patient_data[lvindex ].disch_diagnosis = trim (diag.diagnosis_display )
      ENDIF
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,diag.encntr_id ,output_data->
      patient_data[expand_index ].encntr_id )
    ENDWHILE
   WITH nocounter
  ;end select
  CALL echo ("Test" )
  SELECT INTO "nl:"
   FROM (encounter e ),
    (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
   PLAN (d )
    JOIN (e
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,e
     .encntr_id ,output_data->patient_data[expand_index ].encntr_id ) )
   DETAIL
    lvindex = locateval (expand_index ,1 ,actual_size ,e.encntr_id ,output_data->patient_data[
     expand_index ].encntr_id ) ,
    WHILE ((lvindex > 0 ) )
     IF ((output_data->patient_data[lvindex ].reason_for_visit = null ) ) output_data->patient_data[
      lvindex ].reason_for_visit = e.reason_for_visit
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,e.encntr_id ,output_data->
      patient_data[expand_index ].encntr_id )
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 CALL echo ("fnrpt_get_providers.inc" )
 DECLARE provider_count = i4 WITH noconstant (0 )
 IF ((actual_size > 0 ) )
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value ((expand_total / expand_size ) ) ),
    (encntr_prsnl_reltn epr ),
    (prsnl p )
   PLAN (d )
    JOIN (epr
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,epr
     .encntr_id ,output_data->patient_data[expand_index ].encntr_id )
    AND (epr.encntr_prsnl_r_cd IN (admitdoc_cd ,
    attnddoc_cd ,
    refdoc_cd ) )
    AND ((epr.prsnl_person_id + 0 ) > 0.0 ) )
    JOIN (p
    WHERE (p.person_id = epr.prsnl_person_id ) )
   DETAIL
    lvindex = locateval (expand_index ,1 ,actual_size ,epr.encntr_id ,output_data->patient_data[
     expand_index ].encntr_id ) ,
    WHILE ((lvindex > 0 ) )
     IF ((epr.encntr_prsnl_r_cd = admitdoc_cd ) ) output_data->patient_data[lvindex ].
      admitting_physician = p.name_full_formatted
     ELSEIF ((epr.encntr_prsnl_r_cd = attnddoc_cd ) ) output_data->patient_data[lvindex ].
      attending_physician = p.name_full_formatted
     ELSEIF ((epr.encntr_prsnl_r_cd = refdoc_cd ) ) output_data->patient_data[lvindex ].
      referring_physician = p.name_full_formatted
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,epr.encntr_id ,output_data->
      patient_data[expand_index ].encntr_id )
    ENDWHILE
   WITH nocounter
  ;end select
  IF ((provsrc != 0 ) )
   SELECT
    IF ((output_data->track_group_cd > 0.0 ) )
     FROM (dummyt d WITH seq = value ((expand_total / expand_size ) ) ),
      (tracking_checkin tc ),
      (tracking_prv_reln tpr ),
      (tracking_prsnl tp ),
      (track_reference tr ),
      (prsnl p )
     PLAN (d )
      JOIN (tc
      WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,tc
       .tracking_checkin_id ,output_data->patient_data[expand_index ].tracking_checkin_id ) )
      JOIN (tpr
      WHERE (tpr.tracking_id = tc.tracking_id ) )
      JOIN (p
      WHERE (p.person_id = tpr.tracking_provider_id ) )
      JOIN (tp
      WHERE (tp.person_id = tpr.tracking_provider_id )
      AND (tp.tracking_prsnl_task_id > 0 )
      AND ((tp.tracking_group_cd + 0 ) = output_data->track_group_cd ) )
      JOIN (tr
      WHERE (tr.tracking_ref_id = tp.tracking_prsnl_task_id ) )
    ELSE
     FROM (dummyt d WITH seq = value ((expand_total / expand_size ) ) ),
      (tracking_checkin tc ),
      (tracking_prv_reln tpr ),
      (tracking_prsnl tp ),
      (track_reference tr ),
      (prsnl p )
     PLAN (d )
      JOIN (tc
      WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,tc
       .tracking_checkin_id ,output_data->patient_data[expand_index ].tracking_checkin_id ) )
      JOIN (tpr
      WHERE (tpr.tracking_id = tc.tracking_id ) )
      JOIN (p
      WHERE (p.person_id = tpr.tracking_provider_id ) )
      JOIN (tp
      WHERE (tp.person_id = tpr.tracking_provider_id )
      AND (tp.tracking_prsnl_task_id > 0 ) )
      JOIN (tr
      WHERE (tr.tracking_ref_id = tp.tracking_prsnl_task_id ) )
    ENDIF
    INTO "nl:"
    ORDER BY tpr.assign_dt_tm DESC
    DETAIL
     lvindex = locateval (expand_index ,1 ,actual_size ,tc.tracking_checkin_id ,output_data->
      patient_data[expand_index ].tracking_checkin_id ) ,
     WHILE ((lvindex > 0 ) )
      provider_count = (provider_count + 1 ) ,stat = alterlist (output_data->patient_data[lvindex ].
       provider_info ,provider_count ) ,
      IF ((tp.tracking_prsnl_task_id = pri_doc_role ) )
       IF ((output_data->patient_data[lvindex ].primary_provider = "" ) ) output_data->patient_data[
        lvindex ].primary_provider = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].primary_provider = concat (output_data->patient_data[
         lvindex ].primary_provider ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((tp.tracking_prsnl_task_id = sec_doc_role ) )
       IF ((output_data->patient_data[lvindex ].secondary_provider = "" ) ) output_data->
        patient_data[lvindex ].secondary_provider = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].secondary_provider = concat (output_data->
         patient_data[lvindex ].secondary_provider ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((tp.tracking_prsnl_task_id = pri_nur_role ) )
       IF ((output_data->patient_data[lvindex ].primary_nurse = "" ) ) output_data->patient_data[
        lvindex ].primary_nurse = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].primary_nurse = concat (output_data->patient_data[
         lvindex ].primary_nurse ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((tp.tracking_prsnl_task_id = sec_nur_role ) )
       IF ((output_data->patient_data[lvindex ].secondary_nurse = "" ) ) output_data->patient_data[
        lvindex ].secondary_nurse = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].secondary_nurse = concat (output_data->patient_data[
         lvindex ].secondary_nurse ,"; " ,p.name_full_formatted )
       ENDIF
      ENDIF
      ,output_data->patient_data[lvindex ].provider_info[provider_count ].provider_name = p
      .name_full_formatted ,output_data->patient_data[lvindex ].provider_info[provider_count ].
      provider_role = tr.display ,output_data->patient_data[lvindex ].provider_info[provider_count ].
      assign_date_time = format (tpr.assign_dt_tm ,"@SHORTDATETIME" ) ,
      IF ((tpr.unassign_dt_tm < cnvtdatetime ("31-DEC-2100" ) ) ) output_data->patient_data[lvindex ]
       .provider_info[provider_count ].unassign_date_time = format (tpr.unassign_dt_tm ,
        "@SHORTDATETIME" )
      ELSE output_data->patient_data[lvindex ].provider_info[provider_count ].unassign_date_time =
       ""
      ENDIF
      ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,tc.tracking_checkin_id ,
       output_data->patient_data[expand_index ].tracking_checkin_id )
     ENDWHILE
    WITH nocounter
   ;end select
  ELSE
   SELECT
    IF ((output_data->track_group_cd > 0.0 ) )
     FROM (dummyt d WITH seq = value ((expand_total / expand_size ) ) ),
      (tracking_checkin tc ),
      (prsnl p ),
      (tracking_prsnl tp )
     PLAN (d )
      JOIN (tc
      WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,tc
       .tracking_checkin_id ,output_data->patient_data[expand_index ].tracking_checkin_id ) )
      JOIN (p
      WHERE (p.person_id IN (tc.primary_doc_id ,
      tc.secondary_doc_id ,
      tc.primary_nurse_id ,
      tc.secondary_nurse_id ) ) )
      JOIN (tp
      WHERE (tp.person_id = p.person_id )
      AND ((tp.tracking_group_cd + 0 ) = output_data->track_group_cd ) )
    ELSE
     FROM (dummyt d WITH seq = value ((expand_total / expand_size ) ) ),
      (tracking_checkin tc ),
      (prsnl p ),
      (tracking_prsnl tp )
     PLAN (d )
      JOIN (tc
      WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,tc
       .tracking_checkin_id ,output_data->patient_data[expand_index ].tracking_checkin_id ) )
      JOIN (p
      WHERE (p.person_id IN (tc.primary_doc_id ,
      tc.secondary_doc_id ,
      tc.primary_nurse_id ,
      tc.secondary_nurse_id ) ) )
      JOIN (tp
      WHERE (tp.person_id = p.person_id )
      AND ((tp.tracking_group_cd + 0 ) = tc.tracking_group_cd ) )
    ENDIF
    INTO "nl:"
    DETAIL
     lvindex = locateval (expand_index ,1 ,actual_size ,tc.tracking_checkin_id ,output_data->
      patient_data[expand_index ].tracking_checkin_id ) ,
     WHILE ((lvindex > 0 ) )
      provider_count = (provider_count + 1 ) ,stat = alterlist (output_data->patient_data[lvindex ].
       provider_info ,provider_count ) ,
      IF ((p.person_id = tc.primary_doc_id ) ) output_data->patient_data[lvindex ].provider_info[
       provider_count ].provider_name = p.name_full_formatted ,output_data->patient_data[lvindex ].
       provider_info[provider_count ].provider_role = uar_i18ngetmessage (i18nhandle ,
        "fn_PrimaryPhysician" ,"Primary Physician" ) ,
       IF ((output_data->patient_data[lvindex ].primary_provider = "" ) ) output_data->patient_data[
        lvindex ].primary_provider = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].primary_provider = concat (output_data->patient_data[
         lvindex ].primary_provider ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((p.person_id = tc.secondary_doc_id ) ) output_data->patient_data[lvindex ].
       provider_info[provider_count ].provider_name = p.name_full_formatted ,output_data->
       patient_data[lvindex ].provider_info[provider_count ].provider_role = uar_i18ngetmessage (
        i18nhandle ,"fn_SecondaryPhysician" ,"Secondary Physician" ) ,
       IF ((output_data->patient_data[lvindex ].secondary_provider = "" ) ) output_data->
        patient_data[lvindex ].secondary_provider = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].secondary_provider = concat (output_data->
         patient_data[lvindex ].secondary_provider ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((p.person_id = tc.primary_nurse_id ) ) output_data->patient_data[lvindex ].
       provider_info[provider_count ].provider_name = p.name_full_formatted ,output_data->
       patient_data[lvindex ].provider_info[provider_count ].provider_role = uar_i18ngetmessage (
        i18nhandle ,"fn_PrimaryNurse" ,"Primary Nurse" ) ,
       IF ((output_data->patient_data[lvindex ].primary_nurse = "" ) ) output_data->patient_data[
        lvindex ].primary_nurse = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].primary_nurse = concat (output_data->patient_data[
         lvindex ].primary_nurse ,"; " ,p.name_full_formatted )
       ENDIF
      ELSEIF ((p.person_id = tc.secondary_nurse_id ) ) output_data->patient_data[lvindex ].
       provider_info[provider_count ].provider_name = p.name_full_formatted ,output_data->
       patient_data[lvindex ].provider_info[provider_count ].provider_role = uar_i18ngetmessage (
        i18nhandle ,"fn_SecondaryNurse" ,"Secondary Nurse" ) ,
       IF ((output_data->patient_data[lvindex ].secondary_nurse = "" ) ) output_data->patient_data[
        lvindex ].secondary_nurse = p.name_full_formatted
       ELSE output_data->patient_data[lvindex ].secondary_nurse = concat (output_data->patient_data[
         lvindex ].secondary_nurse ,"; " ,p.name_full_formatted )
       ENDIF
      ENDIF
      ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,tc.tracking_checkin_id ,
       output_data->patient_data[expand_index ].tracking_checkin_id )
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 DECLARE location_in_dt = q8
 DECLARE location_out_dt = q8
 DECLARE lostimediff = i4 WITH noconstant (0 )
 DECLARE dateset = i4 WITH noconstant (0 )
 IF ((actual_size > 0 )
 AND ( $NURSEUNIT > 0 ) )
  SELECT INTO "nl:"
   FROM (tracking_locator tl ),
    (tracking_checkin tc ),
    (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
   PLAN (d )
    JOIN (tc
    WHERE expand (expand_index ,(((d.seq - 1 ) * expand_size ) + 1 ) ,(d.seq * expand_size ) ,tc
     .tracking_id ,output_data->patient_data[expand_index ].tracking_id )
    AND ((tc.tracking_group_cd + 0 ) =  $TRACKGROUPCD ) )
    JOIN (tl
    WHERE (tl.tracking_id = tc.tracking_id )
    AND ((tl.loc_nurse_unit_cd + 0 ) =  $NURSEUNIT ) )
   ORDER BY tl.locator_create_date DESC ,
    tl.arrive_dt_tm DESC ,
    tl.tracking_id DESC
   HEAD tl.tracking_id
    lvindex = locateval (expand_index ,1 ,actual_size ,tc.tracking_id ,output_data->patient_data[
     expand_index ].tracking_id ) ,
    WHILE ((lvindex > 0 ) )
     location_in_dt = tl.arrive_dt_tm ,
     IF ((tl.depart_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) location_out_dt = tl.depart_dt_tm
     ELSE location_out_dt = cnvtdatetime (curdate ,curtime3 )
     ENDIF
     ,
     IF ((location_out_dt > location_in_dt ) ) lostimediff = datetimediff (location_out_dt ,
       location_in_dt ,4 ) ,output_data->patient_data[lvindex ].los_location = calclos (lostimediff ,
       1 )
     ELSE lostimediff = datetimediff (cnvtdatetime (curdate ,curtime3 ) ,location_in_dt ,4 ) ,
      output_data->patient_data[lvindex ].los_location = calclos (lostimediff ,1 )
     ENDIF
     ,lvindex = locateval (expand_index ,(lvindex + 1 ) ,actual_size ,tc.tracking_id ,output_data->
      patient_data[expand_index ].tracking_id )
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist (output_data->patient_data ,actual_size )
 DECLARE calclos ((time_minutes = i4 ) ,(patient_cnt = i4 ) ) = vc
 SUBROUTINE  calclos (time_minutes ,patient_cnt )
  DECLARE hours = i4 WITH noconstant (0 )
  DECLARE minutes = i4 WITH noconstant (0 )
  IF ((patient_cnt > 0 ) )
   SET time_minutes = (time_minutes / patient_cnt )
  ENDIF
  SET hours = (time_minutes / 60 )
  SET minutes = mod (time_minutes ,60 )
  IF ((hours < 100 ) )
   RETURN (concat (" " ,format (trim (cnvtstring (hours ) ) ,"##;P0" ) ,":" ,format (trim (
      cnvtstring (minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 1000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"###;P0" ) ,":" ,format (trim (cnvtstring (
       minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 10000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"####;P0" ) ,":" ,format (trim (cnvtstring (
       minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 100000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"#####;P0" ) ,":" ,format (trim (cnvtstring (
       minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 1000000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"######;P0" ) ,":" ,format (trim (cnvtstring
      (minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 10000000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"#######;P0" ) ,":" ,format (trim (
      cnvtstring (minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 100000000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"########;P0" ) ,":" ,format (trim (
      cnvtstring (minutes ) ) ,"##;P0" ) ) )
  ELSEIF ((hours < 1000000000 ) )
   RETURN (concat (format (trim (cnvtstring (hours ) ) ,"#########;P0" ) ,":" ,format (trim (
      cnvtstring (minutes ) ) ,"##;P0" ) ) )
  ENDIF
 END ;Subroutine
 CALL echo ("after include" )
 IF ((cnvtint ( $SORTORDER ) = 5 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].
    reason_for_visit )
  ENDFOR
 ELSEIF ((cnvtint ( $SORTORDER ) = 7 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].
    primary_provider )
  ENDFOR
 ELSEIF ((cnvtint ( $SORTORDER ) = 9 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].
    admitting_physician )
  ENDFOR
 ELSEIF ((cnvtint ( $SORTORDER ) = 10 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].
    primary_nurse )
  ENDFOR
 ELSEIF ((cnvtint ( $SORTORDER ) = 11 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].
    disch_diagnosis )
  ENDFOR
 ELSEIF ((cnvtint ( $SORTORDER ) = 12 ) )
  FOR (i = 1 TO pat_count )
   SET output_data->patient_data[i ].sorting_field = cnvtupper (output_data->patient_data[i ].mrn )
  ENDFOR
 ENDIF
 SET totalpatcount = size (output_data->patient_data ,5 )
 SET sortorder = 1
 SET report_labels->total_pats = uar_i18nbuildmessage (i18nhandle ,"fn_TotalPatients" ,
  "Total Patients = %1" ,"i" ,totalpats )
 SET report_labels->total_qual_pats = uar_i18nbuildmessage (i18nhandle ,"fn_TotalQualPats" ,
  "Patients who Qualify = %1" ,"i" ,totalpatcount )
 SET report_labels->person_name = uar_i18ngetmessage (i18nhandle ,"fn_Name" ,"Patient Name" )
 SET report_labels->mrn = uar_i18ngetmessage (i18nhandle ,"fn_MRN" ,"MRN" )
 SET report_labels->age_gender = uar_i18ngetmessage (i18nhandle ,"fn_Age" ,"Age" )
 SET report_labels->ega = uar_i18ngetmessage (i18nhandle ,"fn_EGA" ,"EGA" )
 SET report_labels->edd = uar_i18ngetmessage (i18nhandle ,"fn_EDD" ,"EDD" )
 SET report_labels->checkin_date = uar_i18ngetmessage (i18nhandle ,"fn_Checkin" ,"Checkin Date" )
 SET report_labels->rfv = uar_i18ngetmessage (i18nhandle ,"fn_RFV" ,"Reason For Visit" )
 SET report_labels->ed_physician = uar_i18ngetmessage (i18nhandle ,"fn_EDPhys" ,"Primary Physician"
  )
 SET report_labels->admitting = uar_i18ngetmessage (i18nhandle ,"fn_AdmitPhys" ,"Admit Physician" )
 SET report_labels->arrival_mode = uar_i18ngetmessage (i18nhandle ,"fn_ArrivalMode" ,"Arrival Mode"
  )
 SET report_labels->los_checkin = uar_i18ngetmessage (i18nhandle ,"fn_LOSCheckin" ,"LOS(checkin)" )
 SET report_labels->fin = uar_i18ngetmessage (i18nhandle ,"fn_FIN" ,"FIN" )
 SET report_labels->birth_date = uar_i18ngetmessage (i18nhandle ,"fn_BirthDate" ,"Birth Date" )
 SET report_labels->primary_nurse = uar_i18ngetmessage (i18nhandle ,"fn_PrimNurse" ,"Primary Nurse"
  )
 SET report_labels->acuity = uar_i18ngetmessage (i18nhandle ,"fn_Acuity" ,"Acuity" )
 SET report_labels->diagnosis = uar_i18ngetmessage (i18nhandle ,"fn_Diagnosis" ,"Diagnosis" )
 SET report_labels->checkout_date = uar_i18ngetmessage (i18nhandle ,"fn_CheckoutDate" ,
  "Checkout Date" )
 SET report_labels->discharge = uar_i18ngetmessage (i18nhandle ,"fn_Discharge" ,"Discharge Loc" )
 SET report_labels->disposition = uar_i18ngetmessage (i18nhandle ,"fn_Disposition" ,"Disposition" )
 SET report_labels->summary = uar_i18ngetmessage (i18nhandle ,"fn_Summary" ,"Summary" )
 DECLARE htmlfileind = i4 WITH noconstant (0 )
 SET _sendto =  $OUTDEV
 CALL initializereport (0 )
 IF (validate (_htmlfileinfo ) )
  SET htmlfileind = _htmlfileinfo->file_desc
 ELSEIF (validate (_htmlfilehandle ) )
  SET htmlfileind = _htmlfilehandle
 ENDIF
 IF ((htmlfileind = 0 ) )
  IF ((checkfun (cnvtupper ("__LayoutQuery" ) ) = 7 ) )
   CALL __layoutquery (0 )
  ELSEIF ((checkfun (cnvtupper ("LayoutSection0" ) ) = 7 ) )
   SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom )
   IF (((_yoffset + layoutsection0 (1 ) ) > _fenddetail ) )
    CALL pagebreak (0 )
   ENDIF
   CALL layoutsection0 (0 )
  ENDIF
 ELSE
  IF ((checkfun (cnvtupper ("LayoutQueryHTML" ) ) = 7 ) )
   CALL layoutqueryhtml (0 )
  ELSEIF ((checkfun (cnvtupper ("FieldName0HTML" ) ) = 7 ) )
   CALL fieldname0html (0 )
  ENDIF
 ENDIF
 CALL finalizereport (_sendto )
END GO
 

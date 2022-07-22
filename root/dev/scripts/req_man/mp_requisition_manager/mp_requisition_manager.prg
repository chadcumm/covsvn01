;REMOVE ITEMS MARKED WITH REMOVE
DROP PROGRAM mp_requisition_manager :dba GO
CREATE PROGRAM mp_requisition_manager :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Personnel ID:" = 0.00 ,
  "Provider Position Code:" = 0.00 ,
  "Executable in Context:" = "" ,
  "Device Location:" = "" ,
  "Static Content Location:" = ""
  WITH outdev ,personnelid ,positioncode ,executableincontext ,devicelocation ,staticcontentlocation
 FREE RECORD criterion
 RECORD criterion (
   1 prsnl_id = f8
   1 executable = vc
   1 static_content = vc
   1 position_cd = f8
   1 ppr_cd = f8
   1 debug_ind = i2
   1 help_file_local_ind = i2
   1 category_mean = vc
   1 locale_id = vc
   1 device_location = vc
   1 pwx_help_link = vc
   1 pwx_reflab_help_link = vc
   1 pwx_patient_summ_prg = vc
   1 pwx_task_list_disp = i2
   1 pwx_reflab_list_disp = i2
   1 pwx_tab_pref_found = i2
   1 pwx_tab_pref = vc
   1 pwx_adv_print = i2
   1 loc_pref_found = i2
   1 loc_pref_id = vc
   1 loc_list [* ]
     2 org_name = vc
     2 org_id = f8
   1 vpref [* ]
     2 view_caption = vc
     2 view_seq = i2
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reportid_rec
 RECORD reportid_rec (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 FREE RECORD viewpointinfo_rec
 RECORD viewpointinfo_rec (
   1 viewpoint_name = vc
   1 cnt = i4
   1 views [* ]
     2 view_name = vc
     2 view_sequence = i4
     2 view_cat_mean = vc
 )
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
 DECLARE current_time_zone = i4 WITH constant (datetimezonebyname (curtimezone ) ) ,protect
 DECLARE ending_date_time = dq8 WITH constant (cnvtdatetime ("31-DEC-2100" ) ) ,protect
 DECLARE bind_cnt = i4 WITH constant (50 ) ,protect
 DECLARE lower_bound_date = vc WITH constant ("01-JAN-1800 00:00:00.00" ) ,protect
 DECLARE upper_bound_date = vc WITH constant ("31-DEC-2100 23:59:59.99" ) ,protect
 DECLARE codelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnllistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE phonelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE code_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE phone_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_cnt = i4 WITH noconstant (0 ) ,protect
 DECLARE mpc_ap_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_doc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mdoc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_rad_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_txt_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_num_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_immun_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_med_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_date_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_done_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mbo_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_procedure_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_grp_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE eventclasscdpopulated = i2 WITH protect ,noconstant (0 )
 DECLARE log_program_name = vc WITH protect ,noconstant ("" )
 DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
 DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
 DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
 DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
 DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
 DECLARE hsys = i4 WITH protect ,noconstant (0 )
 DECLARE sysstat = i4 WITH protect ,noconstant (0 )
 DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
 DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
 DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle ()
 SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
 DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
 DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
 DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
 DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
 DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
 DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
 DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
 DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name
   ) ) > " " ) )) )
  SET log_override_ind = 1
 ENDIF

%i cust_script:mp_requisition_manager.inc

 ;SET log_program_name = "AMB_CUST_ORG_TASK_DRIVER"

 DECLARE vcjsreqs = vc WITH protect ,noconstant ("" )
 declare vcjsmpage = vc WITH protect ,noconstant ("" )
 Declare vcjscore = vc with protect, noconstant("")
 Declare vcjsfoundation = vc with protect, noconstant("")
 DECLARE vcjsrenderfunc = vc WITH protect ,noconstant ("" )
 Declare vcjsmanager = vc with protect, noconstant("")
 Declare vcjsbootstrapmultiselectmin = vc with protect, noconstant("")
 Declare vcjsbootstrap = vc with protect, noconstant("")
 Declare vcjscontextmenu = vc with protect, noconstant("")
 Declare vcjsmodal = vc with protect, noconstant("")
 Declare vcjsjson = vc with protect, noconstant("")
 DECLARE vcjsdate = vc WITH protect ,noconstant ("" )
 
 DECLARE vccssreqs = vc WITH protect ,noconstant ("" )
 DECLARE vccsbootstrapmultiselectmin = vc WITH protect ,noconstant ("" )
 DECLARE vccsbootstrap = vc WITH protect ,noconstant ("" )
 
 DECLARE vcjsjquery = vc WITH protect ,noconstant ("" )
 DECLARE vcjsjqueryui = vc WITH protect ,noconstant ("" )
 

 DECLARE vcpagelayout = vc WITH protect ,noconstant ("" )
 DECLARE vcstaticcontent = vc WITH protect ,noconstant ("" )
 DECLARE lstat = i4 WITH protect ,noconstant (0 )
 DECLARE z = i4 WITH private ,noconstant (0 )
 DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
 DECLARE position_bedrock_settings = i2
 DECLARE user_pref_string = vc
 DECLARE user_pref_found = i2
 DECLARE localefilename = vc WITH noconstant ("" ) ,protect
 DECLARE localeobjectname = vc WITH noconstant ("" ) ,protect
 DECLARE temp_string = vc
 
 SET criterion->prsnl_id =  $PERSONNELID
 SET criterion->executable =  $EXECUTABLEINCONTEXT
 SET criterion->position_cd =  $POSITIONCODE
 SET criterion->locale_id = ""
 SET criterion->static_content =  $STATICCONTENTLOCATION
 SET criterion->device_location =  $DEVICELOCATION
 CALL getbedrocksettings ( $POSITIONCODE )
 
 IF ((position_bedrock_settings = 0 ) )
  CALL getbedrocksettings (0.00 )
 ENDIF
 
 CALL gatherlocations ( $PERSONNELID )
 CALL gatheruserprefs ( $PERSONNELID ,"PWX_MPAGE_ORG_TASK_LIST_LOCS" )
 
 IF ((user_pref_found = 1 ) )
  SET criterion->loc_pref_found = 1
  SET criterion->loc_pref_id = user_pref_string
 ENDIF
 CALL gatherviewprefs ( $POSITIONCODE )
 CALL checkcriterion (null )
 CALL getlocaledata (null )
 CALL gatheruserprefs ( $PERSONNELID ,"PWX_MPAGE_MULTI_TASK_TAB_PREF" )
 
 IF ((user_pref_found = 1 ) )
  SET criterion->pwx_tab_pref_found = 1
  SET criterion->pwx_tab_pref = user_pref_string
 ENDIF
 
 CALL generatestaticcontentreqs (null )
 CALL generatepagehtml (null )

SUBROUTINE  generatestaticcontentreqs (null )
  CALL log_message ("In GenerateStaticContentReqs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
 SET vcjsreqs = build2 ('<script type="text/javascript" src="'
 	,criterion->static_content ,"/js/locale/" ,localefilename ,'.js"></script>' )
 
 set vcjsmpage = build2('<script type="text/javascript" src="'
 	,'http://104.170.114.248/discern/c0665.chs_tn.cernerasp.com/script/mpage.js"','</script>' )
 
 SET vccssreqs = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\manager.css" />' )
 
 set vcjsfoundation = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\foundation.js"></script>' )
 
 set vcjsmanager = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\manager.js"></script>' )
 
 set vcjsbootstrapmultiselectmin = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\bootstrap-multiselect.min.js"></script>' )

 set vcjsbootstrap = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\bootstrap.min.js"></script>' )

 set vcjscontextmenu = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery.contextMenu.min.js"></script>' ) 	

 set vcjsdate = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\date.js"></script>' )	

 set vcjscore = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\core.js"></script>' )
 	
 SET vccsbootstrapmultiselectmin = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\bootstrap-multiselect.min.css" />' ) 	
 
 SET vccsbootstrap = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\bootstrap.min.css" />' ) 
 	

 set vcjsjqueryui = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery-ui.min.js"></script>' )
 	
 set vcjsjquery = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery-3.5.1.min.js"></script>' )	
 	
 set vcjsjquery =build2( ^<script src="https://code.jquery.com/jquery-1.12.4.js" ^,
 			^integrity="sha256-Qw82+bXyGq6MydymqBxNPYTaUXXq7c8v3CwiYwLLNXU=" ^,
 			^crossorigin="anonymous"></script>^)

 set vcjsmodal = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\modal.js"></script>' )	

 set vcjsjson = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\json2.js"></script>' )	
 	 	
  IF ((criterion->pwx_tab_pref_found = 1 ) )
   IF ((criterion->pwx_tab_pref = "ORDERTASKS" ) )
    SET vcjsrenderfunc = "javascript:RenderPWxFrame();"
   ELSEIF ((criterion->pwx_tab_pref = "REFLABS" ) )
    SET vcjsrenderfunc = "javascript:RenderPWxRefLabFrame();"
   ENDIF
  ELSE
   SET vcjsrenderfunc = "javascript:RenderPWxFrame();"
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (build2 ("js requirements: " ,vcjsreqs ) )
  ENDIF
  CALL log_message (build ("Exit GenerateStaticContentReqs(), Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine

SUBROUTINE  generatepagehtml (null )
  CALL log_message ("In GeneratePageHTML()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET _memory_reply_string =
  	build2 (
  	
	 ^<!DOCTYPE html>^
	,^<html>^ 
	,^<head>^
	,^<meta http-equiv="Content-Type" ^
	,^content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,CCLLINKPOPUP,CCLNEWSESSIONWINDOW" name="discern"/>^
	,^<meta http-equiv="X-UA-Compatible" content="IE=10">^  
	,vccssreqs 
	;,vccsbootstrapmultiselectmin
	;,vccsbootstrap
	,vcjsreqs
	,vcjscore
	,vcjsjson
	,vcjsdate
	,vcjsmodal
	,vcjsfoundation
	;,vcjsjquery
	;,vcjsjqueryui
	;,vcjscontextmenu
	;,vcjsbootstrap
	;,vcjsbootstrapmultiselectmin
	,vcjsmanager
	,^<script src="http://code.jquery.com/jquery-migrate-1.4.1.js"></script>^
	;,^<script src="https://code.jquery.com/jquery-migrate-3.3.2.js"></script>^
	,^<script type="text/javascript">^
	,^ var m_criterionJSON = '^ ,replace(cnvtrectojson (criterion),^'^ ,^\'^),^';^ 
	,^	var CERN_static_content = "^,criterion->static_content,^";^
	,^</script>^,^</head>^
	,^<body onload="^,vcjsrenderfunc ,^">^
	;,^<body>^
	,^<div id="pwx_frame_head"></div>^
	,^<div id="pwx_frame_filter_content"></div>^
	,^<div id="pwx_frame_content"></div>^
	,^</body>^
	,^</html>^

)
  
  CALL echo (_memory_reply_string )
  CALL log_message (build ("Exit GeneratePageHTML(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
#exit_script
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (criterion )
 ENDIF
END GO

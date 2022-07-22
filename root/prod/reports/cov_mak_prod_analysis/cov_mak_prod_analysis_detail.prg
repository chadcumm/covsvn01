/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		02/25/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_mak_prod_analysis_detail.prg
	Object name:		cov_mak_prod_analysis_detail
	Request #:			8333
 
	Program purpose:	Lists deficiency details.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_mak_prod_analysis_detail GO
CREATE PROGRAM cov_mak_prod_analysis_detail
 prompt 
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Start Date Range (Analysis Date)" = "CURDATE"
	, "End Date Range (Analysis date)" = "CURDATE"
	, "User Name(s)" = 0
	, "Task Queue(s)" = 0
	, "Group By Facility" = 1
	, "Report or Grid" = 1 

with OUTDEV, ORGANIZATIONS, STARTDATERANGE, ENDDATERANGE, USERNAMES, TASKQUEUES, 
	GROUP_BY_FACILITY, REPORT_GRID
 EXECUTE reportrtl
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE cclbuildhlink ((vcprog = vc ) ,(vcparams = vc ) ,(nviewtype = i2 ) ,(vcdescription = vc ) )
 = vc WITH protect
 DECLARE cclbuildapplink ((nmode = i2 ) ,(vcappname = vc ) ,(vcparams = vc ) ,(vcdescription = vc )
  ) = vc WITH protect
 DECLARE cclbuildweblink ((vcaddress = vc ) ,(nmode = i2 ) ,(vcdescription = vc ) ) = vc WITH
 protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant (0 ) ,protect
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
 DECLARE _hi18nhandle = i4 WITH noconstant (0 ) ,protect
 DECLARE rpt_render = i2 WITH constant (0 ) ,protect
 DECLARE _crlf = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE rpt_calcheight = i2 WITH constant (1 ) ,protect
 DECLARE _yshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _sendto = vc WITH noconstant ( $OUTDEV ) ,protect
 DECLARE _rpterr = i2 WITH noconstant (0 ) ,protect
 DECLARE _rptstat = i2 WITH noconstant (0 ) ,protect
 DECLARE _oldfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _oldpen = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummyfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummypen = i4 WITH noconstant (0 ) ,protect
 DECLARE _fdrawheight = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _rptpage = i4 WITH noconstant (0 ) ,protect
 DECLARE _diotype = i2 WITH noconstant (8 ) ,protect
 DECLARE _outputtype = i2 WITH noconstant (rpt_pdf ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen13s0c0 = i4 WITH noconstant (0 ) ,protect
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
 SUBROUTINE  initializereport (dummy )
  IF ((_bgeneratehtml = 1 ) )
   SET _htmlfileinfo->file_name = _sendto
   SET _htmlfileinfo->file_buf = "w+b"
   SET _htmlfilestat = cclio ("OPEN" ,_htmlfileinfo )
   SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSE
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "COV_MAK_PROD_ANALYSIS_DETAIL"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning (p.printer_type_cd )
    FROM (output_dest o ),
     (device d ),
     (printer p )
    PLAN (o
     WHERE (cnvtupper (o.name ) = cnvtupper (trim (_sendto ) ) ) )
     JOIN (d
     WHERE (d.device_cd = o.device_cd ) )
     JOIN (p
     WHERE (p.device_cd = d.device_cd ) )
    DETAIL
     CASE (cnvtint (p_printer_type_cdf ) )
      OF 8 :
      OF 26 :
      OF 29 :
       _outputtype = rpt_postscript ,
       _xdiv = 72 ,
       _ydiv = 72
      OF 16 :
      OF 20 :
      OF 24 :
       _outputtype = rpt_zebra ,
       _xdiv = 203 ,
       _ydiv = 203
      OF 32 :
      OF 18 :
      OF 19 :
      OF 27 :
      OF 31 :
       _outputtype = rpt_intermec ,
       _xdiv = 203 ,
       _ydiv = 203
      ELSE _xdiv = 1 ,
       _ydiv = 1
     ENDCASE
     ,_diotype = cnvtint (p_printer_type_cdf ) ,
     _sendto = d.name ,
     IF ((_xdiv > 1 ) ) rptreport->m_horzprintoffset = (cnvtreal (o.label_xpos ) / _xdiv )
     ENDIF
     ,
     IF ((_xdiv > 1 ) ) rptreport->m_vertprintoffset = (cnvtreal (o.label_ypos ) / _ydiv )
     ENDIF
    WITH nocounter
   ;end select
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
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen13s0c0 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit (_hi18nhandle ,curprog ,"" ,curcclrev )
 CALL initializereport (0 )
 
 IF ($REPORT_GRID = 0)
	 SET _bishtml = validate (_htmlfileinfo->file_desc ,0 )
	 IF ((_bishtml != 0 ) )
	  SET _htmlfileinfo->file_buf = build2 ("<STYLE>" ,
	   "table {border-collapse: collapse; empty-cells: show;   }" ,"</STYLE>" )
	  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
	 ENDIF
	 SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom )
	 IF (( $7 = 1 ) )
	  SET _bsubreport = 1
	  EXECUTE cov_mak_prod_analysis_det_grp $1, $2, $3, $4, $5, $6, $8
	  SET _bsubreport = 0
	 ENDIF
	 IF (( $7 = 0 ) )
	  SET _bsubreport = 1
	  EXECUTE cov_mak_prod_analysis_det_ngrp $1, $2, $3, $4, $5, $6, $8
	  SET _bsubreport = 0
	 ENDIF
	 IF ((_bishtml != 0 ) )
	  SET _htmlfileinfo->file_buf = ""
	 ENDIF
	 
	 CALL finalizereport (_sendto )
 ELSE
	 IF (( $7 = 1 ) )
	  EXECUTE cov_mak_prod_analysis_det_grp $1, $2, $3, $4, $5, $6, $8
	 ENDIF
	 IF (( $7 = 0 ) )
	  EXECUTE cov_mak_prod_analysis_det_ngrp $1, $2, $3, $4, $5, $6, $8
	 ENDIF
 ENDIF
 
END GO

DROP PROGRAM uhs_pha_ord_verify_tat_lo GO
CREATE PROGRAM uhs_pha_ord_verify_tat_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD tat (
   1 facility = vc
   1 report_type = i4
   1 beg_dt_tm = vc
   1 end_dt_tm = vc
   1 rpttot_cnt = i4
   1 rpttot_tot_tm = f8
   1 rpttot_avg_tm = i4
   1 hr_qual [24 ]
     2 cnt = i4
     2 tot_tm = f8
     2 avg_tm = i4
   1 phd_cnt = i4
   1 phd_qual [* ]
     2 phd_name = vc
     2 phdtot_cnt = i4
     2 phdtot_tot_tm = f8
     2 phdtot_avg_tm = i4
     2 hr_qual [24 ]
       3 cnt = i4
       3 tot_tm = f8
       3 avg_tm = i4
 )
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE query1 (dummy ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE headreportsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headreportsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagefacility ((ncalc = i2 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH
 protect
 DECLARE headpagefacilityabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headpagesection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagesectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagesection1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagesection1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailreporttotals ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailreporttotalsabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE footpagesection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE footpagesectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant (0 ) ,protect
 DECLARE _yoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xoffset = f8 WITH noconstant (0.0 ) ,protect
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
 DECLARE _remfacility = i4 WITH noconstant (1 ) ,protect
 DECLARE _bholdcontinue = i2 WITH noconstant (0 ) ,protect
 DECLARE _bcontheadpagefacility = i2 WITH noconstant (0 ) ,protect
 DECLARE _times8b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times80 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10bi0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times12bi0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times8bi0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times14b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s1c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE d_cnt = i4 WITH protect
 DECLARE prev_date = c10 WITH protect
 DECLARE prev_provider = c50 WITH protect
 DECLARE new_page = i4 WITH protect
 SUBROUTINE  query1 (dummy )
  SELECT
   phd_qual_phd_name = substring (1 ,255 ,tat->phd_qual[d1.seq ].phd_name ) ,
   phd_qual_phdtot_cnt = tat->phd_qual[d1.seq ].phdtot_cnt ,
   phd_qual_phdtot_avg_tm = tat->phd_qual[d1.seq ].phdtot_avg_tm ,
   phd_qual_phdtot_touch_avg_tm = tat->phd_qual[d1.seq ].phdtot_touch_avg_tm
   FROM (dummyt d1 WITH seq = value (size (tat->phd_qual ,5 ) ) )
   PLAN (d1 )
   HEAD REPORT
    _d0 = d1.seq ,
    _d1 = phd_qual_phd_name ,
    _d2 = phd_qual_phdtot_cnt ,
    _d3 = phd_qual_phdtot_avg_tm ,
    _d4 = phd_qual_phdtot_touch_avg_tm ,
    _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom ) ,
    _fenddetail = (_fenddetail - footpagesection (rpt_calcheight ) )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
    ,_bcontheadpagefacility = 0 ,
    dummy_val = headpagefacility (rpt_render ,((rptreport->m_pagewidth - rptreport->m_marginbottom )
     - _yoffset ) ,_bcontheadpagefacility ) ,
    dummy_val = headpagesection (rpt_render ) ,
    dummy_val = headpagesection1 (rpt_render ) ,
    new_page = 1
   DETAIL
    d_cnt = (d_cnt + 1 ) ,
    new_page = 0 ,
    _fdrawheight = detailsection (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailsection (rpt_render ) ,
    _fdrawheight = detailreporttotals (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailreporttotals (rpt_render )
   FOOT PAGE
    _yhold = _yoffset ,
    _yoffset = _fenddetail ,
    dummy_val = footpagesection (rpt_render ) ,
    _yoffset = _yhold
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  pagebreak (dummy )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE  finalizereport (ssendreport )
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
   SET spool value (sfilename ) value (ssendreport ) WITH deleted ,dio = value (_diotype )
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
 END ;Subroutine
 SUBROUTINE  headreportsection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headreportsectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headreportsectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.060000 ) ,private
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagefacility (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagefacilityabs (ncalc ,_xoffset ,_yoffset ,maxheight ,bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagefacilityabs (ncalc ,offsetx ,offsety ,maxheight ,bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_facility = f8 WITH noconstant (0.0 ) ,private
  DECLARE __facility = vc WITH noconstant (build2 (tat->facility ,char (0 ) ) ) ,protect
  IF ((bcontinue = 0 ) )
   SET _remfacility = 1
  ENDIF
  SET rptsd->m_flags = 29
  SET rptsd->m_borders = rpt_sdnoborders
  SET rptsd->m_padding = rpt_sdnoborders
  SET rptsd->m_paddingwidth = 0.000
  SET rptsd->m_linespacing = rpt_single
  SET rptsd->m_rotationangle = 0
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.000 )
  ENDIF
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 10.000
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldfont = uar_rptsetfont (_hreport ,_times14b0 )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
  SET _holdremfacility = _remfacility
  IF ((_remfacility > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_remfacility ,((size (
       __facility ) - _remfacility ) + 1 ) ,__facility ) ) )
   SET drawheight_facility = rptsd->m_height
   IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
    SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
   ENDIF
   IF ((rptsd->m_drawlength = 0 ) )
    SET _remfacility = 0
   ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (_remfacility ,((size (__facility ) -
      _remfacility ) + 1 ) ,__facility ) ) ) ) )
    SET _remfacility = (_remfacility + rptsd->m_drawlength )
   ELSE
    SET _remfacility = 0
   ENDIF
   SET growsum = (growsum + _remfacility )
  ENDIF
  SET rptsd->m_flags = 28
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.000 )
  ENDIF
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 10.000
  SET rptsd->m_height = drawheight_facility
  IF ((ncalc = rpt_render )
  AND (_holdremfacility > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_holdremfacility ,((
      size (__facility ) - _holdremfacility ) + 1 ) ,__facility ) ) )
  ELSE
   SET _remfacility = _holdremfacility
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  IF ((growsum > 0 ) )
   SET bcontinue = 1
  ELSE
   SET bcontinue = 0
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagesection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagesectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagesectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.040000 ) ,private
  DECLARE __daterange = vc WITH noconstant (build2 (build2 (trim (tat->beg_dt_tm ) ,"  --  " ,trim (
      tat->end_dt_tm ) ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + - (0.062 ) )
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__daterange )
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont (_hreport ,_times14b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Pharmacy Order Verify TAT" ,char (
      0 ) ) )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 0.500 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _dummyfont = uar_rptsetfont (_hreport ,_times8b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0000" ,_crlf ,"0059" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 0.896 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0100 " ,_crlf ,"0159" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 1.302 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0200 " ,_crlf ,"0259" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 1.698 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0300 " ,_crlf ,"0359" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 3.302 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0700 " ,_crlf ,"0759" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 2.896 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0600 " ,_crlf ,"0659" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 2.500 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0500 " ,_crlf ,"0559" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 2.104 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0400 " ,_crlf ,"0459" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 6.104 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1400" ,_crlf ,"1459" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1000" ,_crlf ,"1059" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 4.104 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0900" ,_crlf ,"0959" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 3.698 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("0800" ,_crlf ,"0859" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 5.698 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1300" ,_crlf ,"1359" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 5.302 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1200" ,_crlf ,"1259" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 4.896 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1100" ,_crlf ,"1159" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 9.302 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("2200" ,_crlf ,"2259" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 8.896 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("2100" ,_crlf ,"2159" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 9.698 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("2300" ,_crlf ,"2359" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 8.104 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1900" ,_crlf ,"1959" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 7.698 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1800" ,_crlf ,"1859" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 7.302 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1700" ,_crlf ,"1759" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 6.896 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1600" ,_crlf ,"1659" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 6.500 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("1500" ,_crlf ,"1559" ) ,
     char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.688 )
   SET rptsd->m_x = (offsetx + 8.500 )
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.302
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat ("2000" ,_crlf ,"2059" ) ,
     char (0 ) ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.964 ) ,(offsetx + 10.000 )
    ,(offsety + 0.964 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 1.026 ) ,(offsetx + 10.000 )
    ,(offsety + 1.026 ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagesection1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagesection1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagesection1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  IF (NOT ((tat->phd_cnt = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont (_hreport ,_times12bi0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("No Data Qualified for Report" ,
     char (0 ) ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailsection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailsectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailsectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.940000 ) ,private
  DECLARE __cnt_1 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[1 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __avg_tm_1 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[1 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __cnt_2 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[2 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __avg_tm_2 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[2 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_12 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[12 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_11 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[11 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_10 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[10 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_9 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[9 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_8 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[8 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_7 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[7 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_6 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[6 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_5 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[5 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_4 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[4 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_3 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[3 ].avg_tm ,char (
     0 ) ) ) ,protect
  DECLARE __avg_tm_14 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[14 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_15 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[15 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_16 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[16 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_17 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[17 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_18 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[18 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_13 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[13 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_20 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[20 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_21 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[21 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_22 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[22 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_23 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[23 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_24 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[24 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __avg_tm_19 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[19 ].avg_tm ,char
    (0 ) ) ) ,protect
  DECLARE __cnt_3 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[3 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_4 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[4 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_5 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[5 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_6 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[6 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_24 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[24 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_23 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[23 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_22 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[22 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_21 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[21 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_20 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[20 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_19 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[19 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_18 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[18 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_17 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[17 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_16 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[16 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_15 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[15 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_14 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[14 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_13 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[13 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_12 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[12 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_11 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[11 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_10 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[10 ].cnt ,char (0 )
    ) ) ,protect
  DECLARE __cnt_9 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[9 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_8 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[8 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __cnt_7 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[7 ].cnt ,char (0 ) )
   ) ,protect
  DECLARE __phd_qual_phdtot_cnt = vc WITH noconstant (build2 (build2 ("Total Count: " ,format (
      phd_qual_phdtot_cnt ,"#####" ) ) ,char (0 ) ) ) ,protect
  DECLARE __phd_qual_phdtot_avg_tm = vc WITH noconstant (build2 (build2 ("Total Avg Time: " ,format (
      phd_qual_phdtot_avg_tm ,"#####" ) ) ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_1 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[1 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_2 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[2 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_12 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[12 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_11 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[11 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_10 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[10 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_9 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[9 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_8 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[8 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_7 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[7 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_6 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[6 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_5 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[5 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_4 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[4 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_3 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[3 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_14 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[14 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_15 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[15 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_16 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[16 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_17 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[17 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_18 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[18 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_13 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[13 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_20 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[20 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_21 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[21 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_22 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[22 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_23 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[23 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_24 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[24 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_19 = vc WITH noconstant (build2 (tat->phd_qual[d1.seq ].hr_qual[19 ].
    touch_avg_tm ,char (0 ) ) ) ,protect
  DECLARE __phd_qual_phdtot_avg_tm49 = vc WITH noconstant (build2 (build2 ("Touch Avg Time: " ,
     format (phd_qual_phdtot_touch_avg_tm ,"#####" ) ) ,char (0 ) ) ) ,protect
  IF (NOT ((tat->report_type = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.750
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (phd_qual_phd_name ,char (0 ) ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times80 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_1 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_1 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_2 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_2 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_12 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_11 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_10 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_9 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_8 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_7 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_6 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_5 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_4 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_3 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_14 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_15 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_16 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_17 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_18 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_13 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_20 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_21 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_22 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_23 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_24 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_19 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_3 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_4 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_5 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_6 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_24 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_23 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_22 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_21 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_20 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_19 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_18 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_17 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_16 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_15 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_14 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_13 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_12 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_11 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_10 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_9 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_8 )
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_7 )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Count:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Total Avg:" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s1c0 )
   IF ((d_cnt != tat->phd_cnt ) )
    SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.500 ) ,(offsety + 0.776 ) ,(offsetx + 9.500 )
     ,(offsety + 0.776 ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_cnt )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.500 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_avg_tm )
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times80 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_1 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_2 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_12 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_11 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_10 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_9 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_8 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_7 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_6 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_5 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_4 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_3 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_14 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_15 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_16 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_17 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_18 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_13 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_20 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_21 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_22 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_23 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_24 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_19 )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Touch Avg:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.938 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_avg_tm49 )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailreporttotals (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailreporttotalsabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailreporttotalsabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.220000 ) ,private
  DECLARE __cnt_1 = vc WITH noconstant (build2 (tat->hr_qual[1 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_1 = vc WITH noconstant (build2 (tat->hr_qual[1 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __cnt_2 = vc WITH noconstant (build2 (tat->hr_qual[2 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_2 = vc WITH noconstant (build2 (tat->hr_qual[2 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_12 = vc WITH noconstant (build2 (tat->hr_qual[12 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_11 = vc WITH noconstant (build2 (tat->hr_qual[11 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_10 = vc WITH noconstant (build2 (tat->hr_qual[10 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_9 = vc WITH noconstant (build2 (tat->hr_qual[9 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_8 = vc WITH noconstant (build2 (tat->hr_qual[8 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_7 = vc WITH noconstant (build2 (tat->hr_qual[7 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_6 = vc WITH noconstant (build2 (tat->hr_qual[6 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_5 = vc WITH noconstant (build2 (tat->hr_qual[5 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_4 = vc WITH noconstant (build2 (tat->hr_qual[4 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_3 = vc WITH noconstant (build2 (tat->hr_qual[3 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_14 = vc WITH noconstant (build2 (tat->hr_qual[14 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_15 = vc WITH noconstant (build2 (tat->hr_qual[15 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_16 = vc WITH noconstant (build2 (tat->hr_qual[16 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_17 = vc WITH noconstant (build2 (tat->hr_qual[17 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_18 = vc WITH noconstant (build2 (tat->hr_qual[18 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_13 = vc WITH noconstant (build2 (tat->hr_qual[13 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_20 = vc WITH noconstant (build2 (tat->hr_qual[20 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_21 = vc WITH noconstant (build2 (tat->hr_qual[21 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_22 = vc WITH noconstant (build2 (tat->hr_qual[22 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_23 = vc WITH noconstant (build2 (tat->hr_qual[23 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_24 = vc WITH noconstant (build2 (tat->hr_qual[24 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __avg_tm_19 = vc WITH noconstant (build2 (tat->hr_qual[19 ].avg_tm ,char (0 ) ) ) ,protect
  DECLARE __cnt_3 = vc WITH noconstant (build2 (tat->hr_qual[3 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_4 = vc WITH noconstant (build2 (tat->hr_qual[4 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_5 = vc WITH noconstant (build2 (tat->hr_qual[5 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_6 = vc WITH noconstant (build2 (tat->hr_qual[6 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_24 = vc WITH noconstant (build2 (tat->hr_qual[24 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_23 = vc WITH noconstant (build2 (tat->hr_qual[23 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_22 = vc WITH noconstant (build2 (tat->hr_qual[22 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_21 = vc WITH noconstant (build2 (tat->hr_qual[21 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_20 = vc WITH noconstant (build2 (tat->hr_qual[20 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_19 = vc WITH noconstant (build2 (tat->hr_qual[19 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_18 = vc WITH noconstant (build2 (tat->hr_qual[18 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_17 = vc WITH noconstant (build2 (tat->hr_qual[17 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_16 = vc WITH noconstant (build2 (tat->hr_qual[16 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_15 = vc WITH noconstant (build2 (tat->hr_qual[15 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_14 = vc WITH noconstant (build2 (tat->hr_qual[14 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_13 = vc WITH noconstant (build2 (tat->hr_qual[13 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_12 = vc WITH noconstant (build2 (tat->hr_qual[12 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_11 = vc WITH noconstant (build2 (tat->hr_qual[11 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_10 = vc WITH noconstant (build2 (tat->hr_qual[10 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_9 = vc WITH noconstant (build2 (tat->hr_qual[9 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_8 = vc WITH noconstant (build2 (tat->hr_qual[8 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __cnt_7 = vc WITH noconstant (build2 (tat->hr_qual[7 ].cnt ,char (0 ) ) ) ,protect
  DECLARE __phd_qual_phdtot_cnt = vc WITH noconstant (build2 (build2 ("Total Count: " ,format (tat->
      rpttot_cnt ,"#####" ) ) ,char (0 ) ) ) ,protect
  DECLARE __phd_qual_phdtot_avg_tm = vc WITH noconstant (build2 (build2 ("Total Avg Time: " ,format (
      tat->rpttot_avg_tm ,"#####" ) ) ,char (0 ) ) ) ,protect
  DECLARE __touch_avg_tm_17 = vc WITH noconstant (build2 (tat->hr_qual[17 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_18 = vc WITH noconstant (build2 (tat->hr_qual[18 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_20 = vc WITH noconstant (build2 (tat->hr_qual[20 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_21 = vc WITH noconstant (build2 (tat->hr_qual[21 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_22 = vc WITH noconstant (build2 (tat->hr_qual[22 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_23 = vc WITH noconstant (build2 (tat->hr_qual[23 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_24 = vc WITH noconstant (build2 (tat->hr_qual[24 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_19 = vc WITH noconstant (build2 (tat->hr_qual[19 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_2 = vc WITH noconstant (build2 (tat->hr_qual[2 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_12 = vc WITH noconstant (build2 (tat->hr_qual[12 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_11 = vc WITH noconstant (build2 (tat->hr_qual[11 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_10 = vc WITH noconstant (build2 (tat->hr_qual[10 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_9 = vc WITH noconstant (build2 (tat->hr_qual[9 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_8 = vc WITH noconstant (build2 (tat->hr_qual[8 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_7 = vc WITH noconstant (build2 (tat->hr_qual[7 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_6 = vc WITH noconstant (build2 (tat->hr_qual[6 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_5 = vc WITH noconstant (build2 (tat->hr_qual[5 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_4 = vc WITH noconstant (build2 (tat->hr_qual[4 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_3 = vc WITH noconstant (build2 (tat->hr_qual[3 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __touch_avg_tm_14 = vc WITH noconstant (build2 (tat->hr_qual[14 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_15 = vc WITH noconstant (build2 (tat->hr_qual[15 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_16 = vc WITH noconstant (build2 (tat->hr_qual[16 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_13 = vc WITH noconstant (build2 (tat->hr_qual[13 ].touch_avg_tm ,char (0 )
    ) ) ,protect
  DECLARE __touch_avg_tm_1 = vc WITH noconstant (build2 (tat->hr_qual[1 ].touch_avg_tm ,char (0 ) )
   ) ,protect
  DECLARE __phd_qual_phdtot_avg_tm49 = vc WITH noconstant (build2 (build2 ("Touch Avg Time: " ,
     format (tat->rpttot_touch_avg_tm ,"#####" ) ) ,char (0 ) ) ) ,protect
  IF (NOT ((d_cnt = tat->phd_cnt ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont (_hreport ,_times80 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_1 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_1 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_2 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_2 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_12 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_11 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_10 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_9 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_8 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_7 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_6 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_5 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_4 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_3 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_14 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_15 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_16 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_17 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_18 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_13 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_20 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_21 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_22 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_23 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_24 )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__avg_tm_19 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_3 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_4 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_5 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_6 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_24 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_23 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_22 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_21 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_20 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_19 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_18 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_17 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_16 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_15 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_14 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_13 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_12 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_11 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_10 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_9 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_8 )
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__cnt_7 )
   IF ((tat->report_type = 0 )
   AND (new_page = 0 ) )
    SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.047 ) ,(offsetx + 10.000
     ) ,(offsety + 0.047 ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.125 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Report Totals" ,char (0 ) ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times80 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Count:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.625 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Total Avg:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.125 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_cnt )
   SET rptsd->m_y = (offsety + 0.125 )
   SET rptsd->m_x = (offsetx + 8.500 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_avg_tm )
   IF ((tat->report_type = 0 )
   AND (new_page = 0 ) )
    SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.089 ) ,(offsetx + 10.000
     ) ,(offsety + 0.089 ) )
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times80 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_17 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_18 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 7.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_20 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_21 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_22 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 8.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_23 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 9.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_24 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_19 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_2 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_12 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_11 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 3.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_10 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 3.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_9 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_8 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.583 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_7 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 2.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_6 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 1.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_5 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 1.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_4 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_3 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 5.375 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_14 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_15 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 6.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_16 )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.979 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_13 )
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + - (0.125 ) )
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Touch Avg:" ,char (0 ) ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.177 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__touch_avg_tm_1 )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.125 )
   SET rptsd->m_x = (offsetx + 6.938 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__phd_qual_phdtot_avg_tm49 )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  footpagesection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = footpagesectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  footpagesectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.590000 ) ,private
  DECLARE __rundate = vc WITH noconstant (build2 (concat ("Date/Time Run:  " ,format (cnvtdatetime (
       curdate ,curtime ) ,"mm/dd/yyyy hh:mm;;d" ) ) ,char (0 ) ) ) ,protect
  DECLARE __printed_by = vc WITH noconstant (build2 (concat ("Printed by:  " ,trim (cnvtstring (
       reqinfo->updt_id ) ) ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 7.375 )
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont (_hreport ,_times80 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__rundate )
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (rpt_pageofpage ,char (0 ) ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.214 ) ,(offsetx + 10.000 )
    ,(offsety + 0.214 ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.417 )
   SET rptsd->m_x = (offsetx + 7.500 )
   SET rptsd->m_width = 2.521
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__printed_by )
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety + 0.063 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.146
   SET _dummyfont = uar_rptsetfont (_hreport ,_times8bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (
     "*** Average TAT times are calculated in minutes ***" ,char (0 ) ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.250 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times80 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("PHA_ORD_VERIFY_TAT" ,char (0 ) )
    )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  SET rptreport->m_recsize = 100
  SET rptreport->m_reportname = "UHS_PHA_ORD_VERIFY_TAT_LO"
  SET rptreport->m_pagewidth = 8.50
  SET rptreport->m_pageheight = 11.00
  SET rptreport->m_orientation = rpt_landscape
  SET rptreport->m_marginleft = 0.50
  SET rptreport->m_marginright = 0.50
  SET rptreport->m_margintop = 0.30
  SET rptreport->m_marginbottom = 0.30
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
     OF 42 :
      _outputtype = rpt_zebra300 ,
      _xdiv = 300 ,
      _ydiv = 300
     OF 43 :
      _outputtype = rpt_zebra600 ,
      _xdiv = 600 ,
      _ydiv = 600
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
  SET rptfont->m_pointsize = 14
  SET rptfont->m_bold = rpt_on
  SET _times14b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET _times10b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 8
  SET _times8b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 12
  SET rptfont->m_italic = rpt_on
  SET _times12bi0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET _times10bi0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 8
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET _times80 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_bold = rpt_on
  SET rptfont->m_italic = rpt_on
  SET _times8bi0 = uar_rptcreatefont (_hreport ,rptfont )
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen14s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penstyle = 1
  SET _pen14s1c0 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 CALL initializereport (0 )
 CALL query1 (0 )
 CALL finalizereport (_sendto )
;#end
END GO


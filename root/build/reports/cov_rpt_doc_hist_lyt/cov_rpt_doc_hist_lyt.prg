DROP PROGRAM cov_rpt_doc_hist_lyt GO
CREATE PROGRAM cov_rpt_doc_hist_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Blob Handle" = ""
  WITH outdev ,blobhandle
 EXECUTE reportrtl
 RECORD batch_lyt (
   1 batch_details [* ]
     2 module_name = vc
     2 ascent_user = vc
     2 ac_start_dt_tm = dq8
     2 ac_end_dt_tm = dq8
     2 blob_handle = vc
     2 cdi_queue_cd = f8
     2 action_type = vc
     2 reason_cd = f8
     2 perf_prsnl_id = f8
     2 action_dt_tm = dq8
     2 batch_name = vc
     2 patient_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 ax_appid = i4
     2 ax_docid = i4
     2 blob_type = vc
     2 blob_ref_id = f8
     2 page_cnt = i4
     2 external_batch_ident = i4
     2 perf_prsnl_name = vc
     2 create_dt_tm = dq8
     2 change_description [* ]
       3 change = vc
       3 action_sequence = i4
     2 parent_entity_alias = vc
     2 ac_ind = i2
     2 doc_type = vc
     2 version = vc
     2 result_status_cd = f8
     2 trans_log_id = f8
     2 doc_type_alias = vc
     2 subject = vc
     2 parent_aliases [* ]
       3 name_1 = vc
       3 value_1 = vc
       3 codeval_1 = f8
       3 name_2 = vc
       3 value_2 = vc
       3 codeval_2 = f8
     2 version_nbr = f8
     2 event_id = f8
 )
 EXECUTE cdi_rpt_doc_hist_drvr  $BLOBHANDLE
 call echorecord(batch_lyt)
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE batch_query (dummy ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE headreportsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headreportsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headreportsection1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headreportsection1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsection ((ncalc = i2 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsection1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsection1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ) = f8 WITH protect
 DECLARE headparent_alias_rowsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headparent_alias_rowsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH
 protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection2 ((ncalc = i2 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsection2 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_trans_log_idsection2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection3 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_action_dt_tmsection3abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ) = f8 WITH protect
 DECLARE headchange_description_action_sequencesection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headchange_description_action_sequencesectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety
  = f8 ) ) = f8 WITH protect
 DECLARE detailsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailsection1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailsection1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE footbatch_lyt_batch_details_trans_log_idsection ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE footbatch_lyt_batch_details_trans_log_idsectionabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(
  offsety = f8 ) ) = f8 WITH protect
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
 DECLARE _rembatch_lyt_batch_details_cdi_queue_cd_disp = i4 WITH noconstant (1 ) ,protect
 DECLARE _bholdcontinue = i2 WITH noconstant (0 ) ,protect
 DECLARE _bcontheadbatch_lyt_batch_details_trans_log_idsection = i2 WITH noconstant (0 ) ,protect
 DECLARE _rembatch_lyt_batch_details_perf_prsnl_name = i4 WITH noconstant (1 ) ,protect
 DECLARE _rembatch_lyt_batch_details_action_dt_tm = i4 WITH noconstant (1 ) ,protect
 DECLARE _rembatch_lyt_batch_details_reason_cd_disp = i4 WITH noconstant (1 ) ,protect
 DECLARE _rembatch_lyt_batch_details_action_type = i4 WITH noconstant (1 ) ,protect
 DECLARE _bcontheadbatch_lyt_batch_details_action_dt_tmsection2 = i2 WITH noconstant (0 ) ,protect
 DECLARE _times10bi0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times16bi0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c12632256 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 SUBROUTINE  batch_query (dummy )
  SELECT
   IF ((size (batch_lyt->batch_details ,5 ) > 0 ) )
    PLAN (dtrs1
     WHERE maxrec (d1 ,size (batch_lyt->batch_details[dtrs1.seq ].change_description ,5 ) )
     AND maxrec (d3 ,size (batch_lyt->batch_details[dtrs1.seq ].parent_aliases ,5 ) ) )
     JOIN (d1 )
     JOIN (d3 )
   ELSE
    PLAN (dtrs1
     WHERE maxrec (d1 ,1 )
     AND maxrec (d3 ,1 ) )
     JOIN (d1 )
     JOIN (d3 )
   ENDIF
   INTO outdev
   batch_lyt_batch_details_trans_log_id = batch_lyt->batch_details[dtrs1.seq ].trans_log_id ,
   batch_lyt_batch_details_module_name = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    module_name ) ,
   batch_lyt_batch_details_ascent_user = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    ascent_user ) ,
   batch_lyt_batch_details_ac_start_dt_tm = batch_lyt->batch_details[dtrs1.seq ].ac_start_dt_tm ,
   batch_lyt_batch_details_ac_end_dt_tm = batch_lyt->batch_details[dtrs1.seq ].ac_end_dt_tm ,
   batch_lyt_batch_details_ac_ind = batch_lyt->batch_details[dtrs1.seq ].ac_ind ,
   batch_lyt_batch_details_blob_handle = substring (1 ,60 ,batch_lyt->batch_details[dtrs1.seq ].
    blob_handle ) ,
   batch_lyt_batch_details_version = substring (1 ,15 ,batch_lyt->batch_details[dtrs1.seq ].version
    ) ,
   batch_lyt_batch_details_cdi_queue_cd = batch_lyt->batch_details[dtrs1.seq ].cdi_queue_cd ,
   batch_lyt_batch_details_action_type = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    action_type ) ,
   batch_lyt_batch_details_reason_cd = batch_lyt->batch_details[dtrs1.seq ].reason_cd ,
   batch_lyt_batch_details_result_status_cd = batch_lyt->batch_details[dtrs1.seq ].result_status_cd ,
   batch_lyt_batch_details_perf_prsnl_id = batch_lyt->batch_details[dtrs1.seq ].perf_prsnl_id ,
   batch_lyt_batch_details_action_dt_tm = batch_lyt->batch_details[dtrs1.seq ].action_dt_tm ,
   batch_lyt_batch_details_batch_name = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    batch_name ) ,
   batch_lyt_batch_details_doc_type = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].doc_type
     ) ,
   batch_lyt_batch_details_patient_name = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    patient_name ) ,
   batch_lyt_batch_details_encntr_id = batch_lyt->batch_details[dtrs1.seq ].encntr_id ,
   batch_lyt_batch_details_person_id = batch_lyt->batch_details[dtrs1.seq ].person_id ,
   batch_lyt_batch_details_ax_appid = batch_lyt->batch_details[dtrs1.seq ].ax_appid ,
   batch_lyt_batch_details_ax_docid = batch_lyt->batch_details[dtrs1.seq ].ax_docid ,
   batch_lyt_batch_details_blob_type = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    blob_type ) ,
   batch_lyt_batch_details_blob_ref_id = batch_lyt->batch_details[dtrs1.seq ].blob_ref_id ,
   batch_lyt_batch_details_page_cnt = batch_lyt->batch_details[dtrs1.seq ].page_cnt ,
   batch_lyt_batch_details_external_batch_ident = batch_lyt->batch_details[dtrs1.seq ].
   external_batch_ident ,
   batch_lyt_batch_details_perf_prsnl_name = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    perf_prsnl_name ) ,
   change_description_change = substring (1 ,60 ,batch_lyt->batch_details[dtrs1.seq ].
    change_description[d1.seq ].change ) ,
   batch_details_parent_entity_alias = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    parent_entity_alias ) ,
   batch_lyt_batch_details_subject = substring (1 ,60 ,batch_lyt->batch_details[dtrs1.seq ].subject
    ) ,
   batch_lyt_batch_details_doc_type_alias = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].
    doc_type_alias ) ,
   change_description_action_sequence = batch_lyt->batch_details[dtrs1.seq ].change_description[d1
   .seq ].action_sequence ,
   parent_aliases_name_1 = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].parent_aliases[d3
    .seq ].name_1 ) ,
   parent_aliases_value_1 = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].parent_aliases[d3
    .seq ].value_1 ) ,
   parent_aliases_name_2 = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].parent_aliases[d3
    .seq ].name_2 ) ,
   parent_aliases_value_2 = substring (1 ,30 ,batch_lyt->batch_details[dtrs1.seq ].parent_aliases[d3
    .seq ].value_2 ) ,
   parent_alias_row = d3.seq ,
   max_parent_alias_row = size (batch_lyt->batch_details[dtrs1.seq ].parent_aliases ,5 ) ,
   batch_lyt_batch_details_trans_log_id2 = batch_lyt->batch_details[dtrs1.seq ].trans_log_id ,
   batch_lyt_batch_details_version_nbr = batch_lyt->batch_details[dtrs1.seq ].version_nbr
   FROM (dummyt dtrs1 WITH seq = value (size (batch_lyt->batch_details ,5 ) ) ),
    (dummyt d1 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 )
   ORDER BY batch_lyt_batch_details_version_nbr ,
    batch_lyt_batch_details_blob_handle ,
    batch_lyt_batch_details_action_dt_tm ,
    batch_lyt_batch_details_trans_log_id ,
    parent_alias_row ,
    batch_lyt_batch_details_trans_log_id2 ,
    change_description_action_sequence
   HEAD REPORT
    _d0 = batch_lyt_batch_details_module_name ,
    _d1 = batch_lyt_batch_details_ascent_user ,
    _d2 = batch_lyt_batch_details_ac_start_dt_tm ,
    _d3 = batch_lyt_batch_details_ac_end_dt_tm ,
    _d4 = batch_lyt_batch_details_ac_ind ,
    _d5 = batch_lyt_batch_details_blob_handle ,
    _d6 = batch_lyt_batch_details_version ,
    _d7 = batch_lyt_batch_details_cdi_queue_cd ,
    _d8 = batch_lyt_batch_details_action_type ,
    _d9 = batch_lyt_batch_details_reason_cd ,
    _d10 = batch_lyt_batch_details_result_status_cd ,
    _d11 = batch_lyt_batch_details_action_dt_tm ,
    _d12 = batch_lyt_batch_details_batch_name ,
    _d13 = batch_lyt_batch_details_doc_type ,
    _d14 = batch_lyt_batch_details_patient_name ,
    _d15 = batch_lyt_batch_details_ax_appid ,
    _d16 = batch_lyt_batch_details_ax_docid ,
    _d17 = batch_lyt_batch_details_blob_type ,
    _d18 = batch_lyt_batch_details_blob_ref_id ,
    _d19 = batch_lyt_batch_details_page_cnt ,
    _d20 = batch_lyt_batch_details_perf_prsnl_name ,
    _d21 = change_description_change ,
    _d22 = batch_details_parent_entity_alias ,
    _d23 = batch_lyt_batch_details_subject ,
    _d24 = batch_lyt_batch_details_doc_type_alias ,
    _d25 = parent_aliases_name_1 ,
    _d26 = parent_aliases_value_1 ,
    _d27 = parent_aliases_name_2 ,
    _d28 = parent_aliases_value_2 ,
    _d29 = parent_alias_row ,
    _d30 = max_parent_alias_row ,
    _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom ) ,
    _fenddetail = (_fenddetail - footpagesection (rpt_calcheight ) ) ,
    _fdrawheight = headreportsection (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      headreportsection1 (rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pageheight - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = headreportsection (rpt_render ) ,
    ihnamcnt = 0 ,
    _fdrawheight = headreportsection1 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pageheight - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = headreportsection1 (rpt_render )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
   HEAD batch_lyt_batch_details_version_nbr
    row + 0
   HEAD batch_lyt_batch_details_blob_handle
    row + 0
   HEAD batch_lyt_batch_details_action_dt_tm
    row + 0
   HEAD batch_lyt_batch_details_trans_log_id
    _bcontheadbatch_lyt_batch_details_trans_log_idsection = 0 ,bfirsttime = 1 ,
    WHILE ((((_bcontheadbatch_lyt_batch_details_trans_log_idsection = 1 ) ) OR ((bfirsttime = 1 ) ))
    )
     _bholdcontinue = _bcontheadbatch_lyt_batch_details_trans_log_idsection ,_fdrawheight =
     headbatch_lyt_batch_details_trans_log_idsection (rpt_calcheight ,(_fenddetail - _yoffset ) ,
      _bholdcontinue ) ,
     IF ((((_bholdcontinue = 1 ) ) OR ((_fdrawheight > 0 ) )) )
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
       headbatch_lyt_batch_details_trans_log_idsection1 (rpt_calcheight ) )
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
       headbatch_lyt_batch_details_action_dt_tmsection1 (rpt_calcheight ) )
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
       detailsection1 (rpt_calcheight ) )
      ENDIF
     ENDIF
     ,
     IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
      BREAK
     ELSEIF ((_bholdcontinue = 1 )
     AND (_bcontheadbatch_lyt_batch_details_trans_log_idsection = 0 ) )
      BREAK
     ENDIF
     ,dummy_val = headbatch_lyt_batch_details_trans_log_idsection (rpt_render ,(_fenddetail -
      _yoffset ) ,_bcontheadbatch_lyt_batch_details_trans_log_idsection ) ,bfirsttime = 0
    ENDWHILE
    ,_fdrawheight = headbatch_lyt_batch_details_trans_log_idsection1 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      headbatch_lyt_batch_details_action_dt_tmsection1 (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      detailsection1 (rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = headbatch_lyt_batch_details_trans_log_idsection1 (rpt_render ) ,_fdrawheight =
    headbatch_lyt_batch_details_action_dt_tmsection1 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      detailsection1 (rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = headbatch_lyt_batch_details_action_dt_tmsection1 (rpt_render ) ,
    IF ((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) ihnamcnt
     = (ihnamcnt + 1 )
    ENDIF
    ,_fdrawheight = detailsection1 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailsection1 (rpt_render )
   HEAD parent_alias_row
    _fdrawheight = headparent_alias_rowsection (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = headparent_alias_rowsection (rpt_render )
   HEAD batch_lyt_batch_details_trans_log_id2
    _bcontheadbatch_lyt_batch_details_action_dt_tmsection2 = 0 ,bfirsttime = 1 ,
    WHILE ((((_bcontheadbatch_lyt_batch_details_action_dt_tmsection2 = 1 ) ) OR ((bfirsttime = 1 )
    )) )
     _bholdcontinue = _bcontheadbatch_lyt_batch_details_action_dt_tmsection2 ,_fdrawheight =
     headbatch_lyt_batch_details_action_dt_tmsection2 (rpt_calcheight ,(_fenddetail - _yoffset ) ,
      _bholdcontinue ) ,
     IF ((((_bholdcontinue = 1 ) ) OR ((_fdrawheight > 0 ) )) )
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
       headbatch_lyt_batch_details_trans_log_idsection2 (rpt_calcheight ) )
      ENDIF
     ENDIF
     ,
     IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
      BREAK
     ELSEIF ((_bholdcontinue = 1 )
     AND (_bcontheadbatch_lyt_batch_details_action_dt_tmsection2 = 0 ) )
      BREAK
     ENDIF
     ,dummy_val = headbatch_lyt_batch_details_action_dt_tmsection2 (rpt_render ,(_fenddetail -
      _yoffset ) ,_bcontheadbatch_lyt_batch_details_action_dt_tmsection2 ) ,bfirsttime = 0
    ENDWHILE
    ,_fdrawheight = headbatch_lyt_batch_details_trans_log_idsection2 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = headbatch_lyt_batch_details_trans_log_idsection2 (rpt_render )
   HEAD change_description_action_sequence
    row + 0
   DETAIL
    _fdrawheight = detailsection (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailsection (rpt_render )
   FOOT  change_description_action_sequence
    row + 0
   FOOT  batch_lyt_batch_details_trans_log_id2
    row + 0
   FOOT  parent_alias_row
    row + 0
   FOOT  batch_lyt_batch_details_trans_log_id
    _fdrawheight = footbatch_lyt_batch_details_trans_log_idsection (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = footbatch_lyt_batch_details_trans_log_idsection (rpt_render )
   FOOT  batch_lyt_batch_details_action_dt_tm
    row + 0
   FOOT  batch_lyt_batch_details_blob_handle
    row + 0
   FOOT  batch_lyt_batch_details_version_nbr
    row + 0
   FOOT PAGE
    _yhold = _yoffset ,
    _yoffset = _fenddetail ,
    dummy_val = footpagesection (rpt_render ) ,
    _yoffset = _yhold
   WITH nocounter ,separator = " " ,format ,nullreport
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
   SET spool value (sfilename ) value (ssendreport ) WITH deleted ,dio = _diotype
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
  DECLARE sectionheight = f8 WITH noconstant (0.940000 ) ,private
  DECLARE __rptblobhandle = vc WITH noconstant (build2 (build ("for Blob Handle '" , $BLOBHANDLE ,
     "'" ) ,char (0 ) ) ) ,protect
  DECLARE __rptbatchname = vc WITH noconstant (build2 (build ("Batch Name: " ,
     batch_lyt_batch_details_batch_name ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.750 )
   SET rptsd->m_width = 6.000
   SET rptsd->m_height = 0.573
   SET _oldfont = uar_rptsetfont (_hreport ,_times16bi0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (concat (
      "ProVision Document Imaging" ,_crlf ,"Document History Report" ) ,char (0 ) ) )
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.750 )
   SET rptsd->m_width = 6.000
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__rptblobhandle )
   SET rptsd->m_y = (offsety + 0.740 )
   SET rptsd->m_x = (offsetx + 0.750 )
   SET rptsd->m_width = 6.000
   SET rptsd->m_height = 0.198
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__rptbatchname )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headreportsection1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headreportsection1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headreportsection1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.340000 ) ,private
  IF (NOT ((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) < 4 )
  AND (size (trim (batch_lyt_batch_details_batch_name ) ) = 0 )
  AND (size (trim (batch_lyt_batch_details_blob_handle ) ) = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.156 )
   SET rptsd->m_x = (offsetx + 2.250 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.198
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) < 4 )
   AND (size (trim (batch_lyt_batch_details_batch_name ) ) = 0 )
   AND (size (trim (batch_lyt_batch_details_blob_handle ) ) = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("NO RECORDS FOUND" ,char (0 ) ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsection (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_trans_log_idsectionabs (ncalc ,_xoffset ,_yoffset ,maxheight ,
   bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsectionabs (ncalc ,offsetx ,offsety ,maxheight ,
  bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.190000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_batch_lyt_batch_details_cdi_queue_cd_disp = f8 WITH noconstant (0.0 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (ihnamcnt < 1 ) )
   DECLARE __batch_lyt_batch_details_cdi_queue_cd_disp = vc WITH noconstant (build2 (
     IF ((trim (batch_lyt_batch_details_action_type ) = "Receive" ) ) concat (trim (
        uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) ," (PRELIMINARY)" )
     ELSE trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) )
     ENDIF
     ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size
  (trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (ihnamcnt < 1 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((bcontinue = 0 ) )
   SET _rembatch_lyt_batch_details_cdi_queue_cd_disp = 1
  ENDIF
  SET rptsd->m_flags = 5
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
  SET rptsd->m_width = 2.313
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (ihnamcnt < 1 ) )
   SET _holdrembatch_lyt_batch_details_cdi_queue_cd_disp =
   _rembatch_lyt_batch_details_cdi_queue_cd_disp
   IF ((_rembatch_lyt_batch_details_cdi_queue_cd_disp > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _rembatch_lyt_batch_details_cdi_queue_cd_disp ,((size (
        __batch_lyt_batch_details_cdi_queue_cd_disp ) -
       _rembatch_lyt_batch_details_cdi_queue_cd_disp ) + 1 ) ,
       __batch_lyt_batch_details_cdi_queue_cd_disp ) ) )
    SET drawheight_batch_lyt_batch_details_cdi_queue_cd_disp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
     SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
    ENDIF
    IF ((rptsd->m_drawlength = 0 ) )
     SET _rembatch_lyt_batch_details_cdi_queue_cd_disp = 0
    ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (
       _rembatch_lyt_batch_details_cdi_queue_cd_disp ,((size (
        __batch_lyt_batch_details_cdi_queue_cd_disp ) -
       _rembatch_lyt_batch_details_cdi_queue_cd_disp ) + 1 ) ,
       __batch_lyt_batch_details_cdi_queue_cd_disp ) ) ) ) )
     SET _rembatch_lyt_batch_details_cdi_queue_cd_disp = (
     _rembatch_lyt_batch_details_cdi_queue_cd_disp + rptsd->m_drawlength )
    ELSE
     SET _rembatch_lyt_batch_details_cdi_queue_cd_disp = 0
    ENDIF
    SET growsum = (growsum + _rembatch_lyt_batch_details_cdi_queue_cd_disp )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_cdi_queue_cd_disp = 0
   SET _holdrembatch_lyt_batch_details_cdi_queue_cd_disp =
   _rembatch_lyt_batch_details_cdi_queue_cd_disp
  ENDIF
  SET rptsd->m_flags = 4
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.000 )
  ENDIF
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 2.313
  SET rptsd->m_height = drawheight_batch_lyt_batch_details_cdi_queue_cd_disp
  IF ((ncalc = rpt_render )
  AND (_holdrembatch_lyt_batch_details_cdi_queue_cd_disp > 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (ihnamcnt < 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _holdrembatch_lyt_batch_details_cdi_queue_cd_disp ,((size (
        __batch_lyt_batch_details_cdi_queue_cd_disp ) -
       _holdrembatch_lyt_batch_details_cdi_queue_cd_disp ) + 1 ) ,
       __batch_lyt_batch_details_cdi_queue_cd_disp ) ) )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_cdi_queue_cd_disp =
   _holdrembatch_lyt_batch_details_cdi_queue_cd_disp
  ENDIF
  SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
  SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
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
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsection1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_trans_log_idsection1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsection1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (size (trim (batch_lyt_batch_details_version ) ) > 0 )
  AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((trim
  (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
  AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
   DECLARE __batch_lyt_batch_details_version = vc WITH noconstant (build2 (uar_i18ngetmessage (0 ,
      "vers" ,batch_lyt_batch_details_version ) ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size
  (trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (size (trim (batch_lyt_batch_details_version ) ) > 0 )
  AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((trim
  (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
  AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c12632256 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (size (trim (batch_lyt_batch_details_version ) ) > 0 )
   AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
   trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
   AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
    SET _rptstat = uar_rptrect (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,7.490 ,0.188 ,
     rpt_fill ,uar_rptencodecolor (192 ,192 ,192 ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (size (trim (batch_lyt_batch_details_version ) ) > 0 )
   AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
   trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
   AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_version )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_action_dt_tmsection1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.750000 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_doc_type2 = vc WITH noconstant (build2 (
     IF ((((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
     trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
     AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) ))
     AND (batch_lyt_batch_details_doc_type = null ) ) "N/A"
     ELSE batch_lyt_batch_details_doc_type
     ENDIF
     ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_patient_name2 = vc WITH noconstant (build2 (
     IF ((((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
     trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
     AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) ))
     AND (batch_lyt_batch_details_patient_name = null ) ) "N/A"
     ELSE batch_lyt_batch_details_patient_name
     ENDIF
     ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_blob_type2 = vc WITH noconstant (build2 (
     IF ((((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
     trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
     AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) ))
     AND (trim (batch_lyt_batch_details_blob_type ) = null ) ) "N/A"
     ELSE trim (batch_lyt_batch_details_blob_type )
     ENDIF
     ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __bathc_lyt_datch_details_blob_ref_id = vc WITH noconstant (build2 (
     IF ((((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
     trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
     AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) ))
     AND (batch_lyt_batch_details_blob_ref_id < 1 ) ) "N/A"
     ELSE trim (cnvtstring (batch_lyt_batch_details_blob_ref_id ) )
     ENDIF
     ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size
  (trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (ihnamcnt < 1 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c12632256 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _rptstat = uar_rptrect (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,7.490 ,0.750 ,
     rpt_fill ,uar_rptencodecolor (192 ,192 ,192 ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Document Type:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_doc_type2 )
   ENDIF
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient Name:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_patient_name2 )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Parent ID:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Parent Alias:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (batch_details_parent_entity_alias
      ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Parent Type:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_blob_type2 )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__bathc_lyt_datch_details_blob_ref_id )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Subject:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (batch_lyt_batch_details_subject ,
      char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Doc Type Alias:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (
      batch_lyt_batch_details_doc_type_alias ,char (0 ) ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headparent_alias_rowsection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headparent_alias_rowsectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headparent_alias_rowsectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF ((size (trim (parent_aliases_name_1 ) ) > 1 )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
   DECLARE __parent_aliases_name_1 = vc WITH noconstant (build2 (build (parent_aliases_name_1 ,":" )
     ,char (0 ) ) ) ,protect
  ENDIF
  IF ((size (trim (parent_aliases_name_2 ) ) > 1 )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
   DECLARE __parent_aliases_name_2 = vc WITH noconstant (build2 (build (parent_aliases_name_2 ,":" )
     ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((size (trim (parent_aliases_name_1 ) ) > 1 )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c12632256 )
   SET _rptstat = uar_rptrect (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,7.490 ,0.188 ,
    rpt_fill ,uar_rptencodecolor (192 ,192 ,192 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((size (trim (parent_aliases_name_1 ) ) > 1 )
   AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__parent_aliases_name_1 )
   ENDIF
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (parent_aliases_value_1 ,char (0 )
      ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   IF ((size (trim (parent_aliases_name_2 ) ) > 1 )
   AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__parent_aliases_name_2 )
   ENDIF
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (parent_aliases_value_2 ,char (0 )
      ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection2 (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_action_dt_tmsection2abs (ncalc ,_xoffset ,_yoffset ,maxheight
   ,bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection2abs (ncalc ,offsetx ,offsety ,maxheight
  ,bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.570000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_batch_lyt_batch_details_perf_prsnl_name = f8 WITH noconstant (0.0 ) ,private
  DECLARE drawheight_batch_lyt_batch_details_action_dt_tm = f8 WITH noconstant (0.0 ) ,private
  DECLARE drawheight_batch_lyt_batch_details_reason_cd_disp = f8 WITH noconstant (0.0 ) ,private
  DECLARE drawheight_batch_lyt_batch_details_action_type = f8 WITH noconstant (0.0 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_perf_prsnl_name = vc WITH noconstant (build2 (trim (
      batch_lyt_batch_details_perf_prsnl_name ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) )) )
   DECLARE __batch_lyt_batch_details_action_dt_tm = vc WITH noconstant (build2 (format (
      batch_lyt_batch_details_action_dt_tm ,"@SHORTDATETIME" ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_reason_cd_disp = vc WITH noconstant (build2 (trim (
      uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_page_cnt = vc WITH noconstant (build2 (cnvtstring (
      batch_lyt_batch_details_page_cnt ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   DECLARE __batch_lyt_batch_details_action_type = vc WITH noconstant (build2 (trim (
      batch_lyt_batch_details_action_type ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" )
  AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((trim
  (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
  AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
   DECLARE __batch_lyt_batch_details_result_status_cd9 = vc WITH noconstant (build2 (trim (
      uar_get_code_display (batch_lyt_batch_details_result_status_cd ) ) ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((parent_alias_row = max_parent_alias_row )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((bcontinue = 0 ) )
   SET _rembatch_lyt_batch_details_perf_prsnl_name = 1
   SET _rembatch_lyt_batch_details_action_dt_tm = 1
   SET _rembatch_lyt_batch_details_reason_cd_disp = 1
   SET _rembatch_lyt_batch_details_action_type = 1
  ENDIF
  SET rptsd->m_flags = 5
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
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   SET _holdrembatch_lyt_batch_details_perf_prsnl_name = _rembatch_lyt_batch_details_perf_prsnl_name
   IF ((_rembatch_lyt_batch_details_perf_prsnl_name > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _rembatch_lyt_batch_details_perf_prsnl_name ,((size (
        __batch_lyt_batch_details_perf_prsnl_name ) - _rembatch_lyt_batch_details_perf_prsnl_name )
       + 1 ) ,__batch_lyt_batch_details_perf_prsnl_name ) ) )
    SET drawheight_batch_lyt_batch_details_perf_prsnl_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
     SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
    ENDIF
    IF ((rptsd->m_drawlength = 0 ) )
     SET _rembatch_lyt_batch_details_perf_prsnl_name = 0
    ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (
       _rembatch_lyt_batch_details_perf_prsnl_name ,((size (
        __batch_lyt_batch_details_perf_prsnl_name ) - _rembatch_lyt_batch_details_perf_prsnl_name )
       + 1 ) ,__batch_lyt_batch_details_perf_prsnl_name ) ) ) ) )
     SET _rembatch_lyt_batch_details_perf_prsnl_name = (_rembatch_lyt_batch_details_perf_prsnl_name
     + rptsd->m_drawlength )
    ELSE
     SET _rembatch_lyt_batch_details_perf_prsnl_name = 0
    ENDIF
    SET growsum = (growsum + _rembatch_lyt_batch_details_perf_prsnl_name )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_perf_prsnl_name = 0
   SET _holdrembatch_lyt_batch_details_perf_prsnl_name = _rembatch_lyt_batch_details_perf_prsnl_name
  ENDIF
  SET rptsd->m_flags = 5
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.188 )
  ENDIF
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) )) )
   SET _holdrembatch_lyt_batch_details_action_dt_tm = _rembatch_lyt_batch_details_action_dt_tm
   IF ((_rembatch_lyt_batch_details_action_dt_tm > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _rembatch_lyt_batch_details_action_dt_tm ,((size (__batch_lyt_batch_details_action_dt_tm ) -
       _rembatch_lyt_batch_details_action_dt_tm ) + 1 ) ,__batch_lyt_batch_details_action_dt_tm ) )
     )
    SET drawheight_batch_lyt_batch_details_action_dt_tm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
     SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
    ENDIF
    IF ((rptsd->m_drawlength = 0 ) )
     SET _rembatch_lyt_batch_details_action_dt_tm = 0
    ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (
       _rembatch_lyt_batch_details_action_dt_tm ,((size (__batch_lyt_batch_details_action_dt_tm ) -
       _rembatch_lyt_batch_details_action_dt_tm ) + 1 ) ,__batch_lyt_batch_details_action_dt_tm ) )
     ) ) )
     SET _rembatch_lyt_batch_details_action_dt_tm = (_rembatch_lyt_batch_details_action_dt_tm + rptsd
     ->m_drawlength )
    ELSE
     SET _rembatch_lyt_batch_details_action_dt_tm = 0
    ENDIF
    SET growsum = (growsum + _rembatch_lyt_batch_details_action_dt_tm )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_action_dt_tm = 0
   SET _holdrembatch_lyt_batch_details_action_dt_tm = _rembatch_lyt_batch_details_action_dt_tm
  ENDIF
  SET rptsd->m_flags = 5
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.375 )
  ENDIF
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   SET _holdrembatch_lyt_batch_details_reason_cd_disp = _rembatch_lyt_batch_details_reason_cd_disp
   IF ((_rembatch_lyt_batch_details_reason_cd_disp > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _rembatch_lyt_batch_details_reason_cd_disp ,((size (__batch_lyt_batch_details_reason_cd_disp
        ) - _rembatch_lyt_batch_details_reason_cd_disp ) + 1 ) ,
       __batch_lyt_batch_details_reason_cd_disp ) ) )
    SET drawheight_batch_lyt_batch_details_reason_cd_disp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
     SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
    ENDIF
    IF ((rptsd->m_drawlength = 0 ) )
     SET _rembatch_lyt_batch_details_reason_cd_disp = 0
    ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (
       _rembatch_lyt_batch_details_reason_cd_disp ,((size (__batch_lyt_batch_details_reason_cd_disp
        ) - _rembatch_lyt_batch_details_reason_cd_disp ) + 1 ) ,
       __batch_lyt_batch_details_reason_cd_disp ) ) ) ) )
     SET _rembatch_lyt_batch_details_reason_cd_disp = (_rembatch_lyt_batch_details_reason_cd_disp +
     rptsd->m_drawlength )
    ELSE
     SET _rembatch_lyt_batch_details_reason_cd_disp = 0
    ENDIF
    SET growsum = (growsum + _rembatch_lyt_batch_details_reason_cd_disp )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_reason_cd_disp = 0
   SET _holdrembatch_lyt_batch_details_reason_cd_disp = _rembatch_lyt_batch_details_reason_cd_disp
  ENDIF
  SET rptsd->m_flags = 5
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.188 )
  ENDIF
  SET rptsd->m_x = (offsetx + 4.500 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) )
   SET _holdrembatch_lyt_batch_details_action_type = _rembatch_lyt_batch_details_action_type
   IF ((_rembatch_lyt_batch_details_action_type > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _rembatch_lyt_batch_details_action_type ,((size (__batch_lyt_batch_details_action_type ) -
       _rembatch_lyt_batch_details_action_type ) + 1 ) ,__batch_lyt_batch_details_action_type ) ) )
    SET drawheight_batch_lyt_batch_details_action_type = rptsd->m_height
    IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
     SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
    ENDIF
    IF ((rptsd->m_drawlength = 0 ) )
     SET _rembatch_lyt_batch_details_action_type = 0
    ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (
       _rembatch_lyt_batch_details_action_type ,((size (__batch_lyt_batch_details_action_type ) -
       _rembatch_lyt_batch_details_action_type ) + 1 ) ,__batch_lyt_batch_details_action_type ) ) )
    ) )
     SET _rembatch_lyt_batch_details_action_type = (_rembatch_lyt_batch_details_action_type + rptsd->
     m_drawlength )
    ELSE
     SET _rembatch_lyt_batch_details_action_type = 0
    ENDIF
    SET growsum = (growsum + _rembatch_lyt_batch_details_action_type )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_action_type = 0
   SET _holdrembatch_lyt_batch_details_action_type = _rembatch_lyt_batch_details_action_type
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("User:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.000 )
  ENDIF
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = drawheight_batch_lyt_batch_details_perf_prsnl_name
  IF ((ncalc = rpt_render )
  AND (_holdrembatch_lyt_batch_details_perf_prsnl_name > 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _holdrembatch_lyt_batch_details_perf_prsnl_name ,((size (
        __batch_lyt_batch_details_perf_prsnl_name ) -
       _holdrembatch_lyt_batch_details_perf_prsnl_name ) + 1 ) ,
       __batch_lyt_batch_details_perf_prsnl_name ) ) )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_perf_prsnl_name = _holdrembatch_lyt_batch_details_perf_prsnl_name
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.188 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Date/Time:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.188 )
  ENDIF
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = drawheight_batch_lyt_batch_details_action_dt_tm
  IF ((ncalc = rpt_render )
  AND (_holdrembatch_lyt_batch_details_action_dt_tm > 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) )) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _holdrembatch_lyt_batch_details_action_dt_tm ,((size (__batch_lyt_batch_details_action_dt_tm
        ) - _holdrembatch_lyt_batch_details_action_dt_tm ) + 1 ) ,
       __batch_lyt_batch_details_action_dt_tm ) ) )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_action_dt_tm = _holdrembatch_lyt_batch_details_action_dt_tm
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.375 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Reason:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.375 )
  ENDIF
  SET rptsd->m_x = (offsetx + 1.000 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = drawheight_batch_lyt_batch_details_reason_cd_disp
  IF ((ncalc = rpt_render )
  AND (_holdrembatch_lyt_batch_details_reason_cd_disp > 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _holdrembatch_lyt_batch_details_reason_cd_disp ,((size (
        __batch_lyt_batch_details_reason_cd_disp ) - _holdrembatch_lyt_batch_details_reason_cd_disp
       ) + 1 ) ,__batch_lyt_batch_details_reason_cd_disp ) ) )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_reason_cd_disp = _holdrembatch_lyt_batch_details_reason_cd_disp
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 3.500 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Pages:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 4.500 )
  SET rptsd->m_width = 1.688
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_page_cnt )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.188 )
  SET rptsd->m_x = (offsetx + 3.500 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Action:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  IF (bcontinue )
   SET rptsd->m_y = offsety
  ELSE
   SET rptsd->m_y = (offsety + 0.188 )
  ENDIF
  SET rptsd->m_x = (offsetx + 4.500 )
  SET rptsd->m_width = 1.813
  SET rptsd->m_height = drawheight_batch_lyt_batch_details_action_type
  IF ((ncalc = rpt_render )
  AND (_holdrembatch_lyt_batch_details_action_type > 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (
       _holdrembatch_lyt_batch_details_action_type ,((size (__batch_lyt_batch_details_action_type )
       - _holdrembatch_lyt_batch_details_action_type ) + 1 ) ,__batch_lyt_batch_details_action_type
       ) ) )
   ENDIF
  ELSE
   SET _rembatch_lyt_batch_details_action_type = _holdrembatch_lyt_batch_details_action_type
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_y = (offsety + 0.375 )
  SET rptsd->m_x = (offsetx + 3.500 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" )
   AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
   trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
   AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Status:" ,char (0 ) ) )
   ENDIF
  ENDIF
  SET rptsd->m_flags = 4
  SET rptsd->m_y = (offsety + 0.375 )
  SET rptsd->m_x = (offsetx + 4.500 )
  SET rptsd->m_width = 1.938
  SET rptsd->m_height = 0.198
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" )
   AND (((trim (uar_get_code_display (batch_lyt_batch_details_cdi_queue_cd ) ) = "HNAM" ) ) OR ((
   trim (uar_get_code_display (batch_lyt_batch_details_reason_cd ) ) = "Submit" )
   AND (trim (batch_lyt_batch_details_action_type ) = "Submit" ) )) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,
     __batch_lyt_batch_details_result_status_cd9 )
   ENDIF
  ENDIF
  SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
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
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsection2 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_trans_log_idsection2abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_trans_log_idsection2abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
   DECLARE __batch_lyt_batch_details_ax_appid = vc WITH noconstant (build2 (cnvtstring (
      batch_lyt_batch_details_ax_appid ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
   DECLARE __batch_lyt_batch_details_ax_docid = vc WITH noconstant (build2 (cnvtstring (
      batch_lyt_batch_details_ax_docid ) ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((parent_alias_row = max_parent_alias_row )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 )
  AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) ) )
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
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.198
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("AX App ID:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.000 )
   SET rptsd->m_width = 1.813
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_ax_appid )
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.500 )
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("AX Doc ID:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.500 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.198
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 )
   AND (trim (batch_lyt_batch_details_action_type ) != "Receive" ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_ax_docid )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection3 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headbatch_lyt_batch_details_action_dt_tmsection3abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headbatch_lyt_batch_details_action_dt_tmsection3abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF (NOT ((parent_alias_row = max_parent_alias_row )
  AND (size (trim (change_description_change ) ) > 0 )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 0 ) ) )
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
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.198
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((size (trim (change_description_change ) ) > 0 )
   AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Description:" ,char (0 ) ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headchange_description_action_sequencesection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headchange_description_action_sequencesectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headchange_description_action_sequencesectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.060000 ) ,private
  IF (NOT ((parent_alias_row = max_parent_alias_row ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
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
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF (NOT ((parent_alias_row = max_parent_alias_row )
  AND (size (trim (change_description_change ,1 ) ) > 0 ) ) )
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
   SET rptsd->m_x = (offsetx + 0.375 )
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = 0.198
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((size (trim (change_description_change ) ) > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (change_description_change ,char (
       0 ) ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailsection1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailsection1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailsection1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.630000 ) ,private
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 1 ) )
   DECLARE __batch_lyt_batch_details_module_name = vc WITH noconstant (build2 (trim (
      batch_lyt_batch_details_module_name ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 1 ) )
   DECLARE __batch_lyt_batch_details_ascent_user = vc WITH noconstant (build2 (trim (
      batch_lyt_batch_details_ascent_user ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 1 ) )
   DECLARE __batch_lyt_batch_details_ac_start_dt_tm = vc WITH noconstant (build2 (format (
      batch_lyt_batch_details_ac_start_dt_tm ,"@SHORTDATETIME" ) ,char (0 ) ) ) ,protect
  ENDIF
  IF ((batch_lyt_batch_details_ac_end_dt_tm < cnvtdatetime (curdate ,curtime ) )
  AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
   trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 1 ) )
   DECLARE __batch_lyt_batch_details_ac_end_dt_tm = vc WITH noconstant (build2 (format (
      batch_lyt_batch_details_ac_end_dt_tm ,"@SHORTDATETIME" ) ,char (0 ) ) ) ,protect
  ENDIF
  IF (NOT ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size
  (trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
    batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
  AND (batch_lyt_batch_details_ac_ind = 1 ) ) )
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
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_module_name )
   ENDIF
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("User:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Start Date/Time:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 3.750 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("End Date/Time:" ,char (0 ) ) )
   ENDIF
   SET rptsd->m_y = (offsety + 0.188 )
   SET rptsd->m_x = (offsetx + 1.125 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_ascent_user )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 1.125 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_ac_start_dt_tm
     )
   ENDIF
   SET rptsd->m_y = (offsety + 0.375 )
   SET rptsd->m_x = (offsetx + 4.875 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   IF ((batch_lyt_batch_details_ac_end_dt_tm < cnvtdatetime (curdate ,curtime ) )
   AND (((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 1 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__batch_lyt_batch_details_ac_end_dt_tm )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c12632256 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) )) )
    SET _rptstat = uar_rptline (_hreport ,(offsetx + - (0.062 ) ) ,(offsety + 0.595 ) ,(offsetx +
     7.438 ) ,(offsety + 0.595 ) )
   ENDIF
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  footbatch_lyt_batch_details_trans_log_idsection (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = footbatch_lyt_batch_details_trans_log_idsectionabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  footbatch_lyt_batch_details_trans_log_idsectionabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.060000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c12632256 )
   IF ((((size (trim (cnvtstring (batch_lyt_batch_details_action_dt_tm ) ) ) > 4 ) ) OR ((((size (
    trim (batch_lyt_batch_details_batch_name ) ) > 0 ) ) OR ((size (trim (
     batch_lyt_batch_details_blob_handle ) ) > 0 ) )) ))
   AND (batch_lyt_batch_details_ac_ind = 0 ) )
    SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.032 ) ,(offsetx + 7.500 )
     ,(offsety + 0.032 ) )
   ENDIF
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
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
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  DECLARE __rptdate = vc WITH noconstant (build2 (build (format (sysdate ,"@WEEKDAYNAME;;D" ) ,"," ,
     format (sysdate ,"@LONGDATE;;D" ) ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont (_hreport ,_times10bi0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__rptdate )
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.000 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.250
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (rpt_pageofpage ,char (0 ) ) )
   SET _dummyfont = uar_rptsetfont (_hreport ,_oldfont )
   SET _dummypen = uar_rptsetpen (_hreport ,_oldpen )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  SET rptreport->m_recsize = 100
  SET rptreport->m_reportname = "CDI_RPT_DOC_HIST_LYT"
  SET rptreport->m_pagewidth = 8.50
  SET rptreport->m_pageheight = 11.00
  SET rptreport->m_orientation = rpt_portrait
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
  SET rptfont->m_italic = rpt_on
  SET _times16bi0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET _times10bi0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_italic = rpt_off
  SET _times10b0 = uar_rptcreatefont (_hreport ,rptfont )
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen14s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_rgbcolor = uar_rptencodecolor (192 ,192 ,192 )
  SET _pen14s0c12632256 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 CALL initializereport (0 )
 CALL batch_query (0 )
 CALL finalizereport (_sendto )
END GO

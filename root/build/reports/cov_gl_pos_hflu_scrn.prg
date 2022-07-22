DROP PROGRAM cov_gl_pos_hflu_scrn GO
CREATE PROGRAM cov_gl_pos_hflu_scrn
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Select Facility" = 0 ,
  "Select Begin Date/time" = "SYSDATE" ,
  "Select End Date/Time" = "SYSDATE"
  WITH outdev ,facility ,begdate ,enddate
 RECORD a (
   1 rec_cnt = i4
   1 qual [* ]
     2 unit = vc
     2 tottestsperunit = i4
     2 totpostestsperunit = i4
     2 pospercperunit = vc
     2 ordcnt = i4
     2 ordqual [* ]
       3 room = vc
       3 bed = vc
       3 loc = vc
       3 personid = f8
       3 encntrid = f8
       3 name = vc
       3 mrn = vc
       3 fin = vc
       3 orderid = f8
       3 ordname = vc
       3 orddttm = vc
       3 accessionnbr = vc
       3 colldttm = vc
       3 recdttm = vc
       3 printflg = i2
       3 rescnt = i4
       3 resqual [* ]
         4 eventid = f8
         4 eventdsp = vc
         4 eventcd = f8
         4 result = vc
         4 normalrng = vc
 )
 DECLARE hfluordcatcd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,200 ,
   "RAPIDINFLUENZAABSCREEN" ) ) ,protect
 DECLARE cancelcd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,6004 ,"CANCELED" ) ) ,protect
 DECLARE mrn = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,4 ,"MRN" ) ) ,protect
 DECLARE fin = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,319 ,"FINNBR" ) ) ,protect
 CALL echo (build ("hfluordcatcd :" ,hfluordcatcd ) )
 CALL echo (build ("cancelcd :" ,cancelcd ) )
 CALL echo (build ("mrn :" ,mrn ) )
 CALL echo (build ("fin :" ,fin ) )
 SELECT INTO "nl:"
  unit = uar_get_code_display (e.loc_nurse_unit_cd ) ,
  room = uar_get_code_display (e.loc_room_cd ) ,
  bed = uar_get_code_display (e.loc_bed_cd )
  FROM (orders o ),
   (encounter e ),
   (person p ),
   (encntr_alias ea ),
   (person_alias pa )
  PLAN (o
   WHERE (o.catalog_cd = hfluordcatcd )
   AND (o.orig_order_dt_tm BETWEEN cnvtdatetime ( $BEGDATE ) AND cnvtdatetime ( $ENDDATE ) )
   AND (o.order_status_cd != cancelcd ) )
   JOIN (e
   WHERE (o.encntr_id = e.encntr_id )
   AND (e.loc_facility_cd =  $FACILITY )
   AND (e.active_ind = 1 ) )
   JOIN (p
   WHERE (e.person_id = p.person_id )
   AND (p.active_ind = 1 ) )
   JOIN (ea
   WHERE (e.encntr_id = ea.encntr_id )
   AND (ea.encntr_alias_type_cd = fin )
   AND (ea.active_ind = 1 )
   AND (ea.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 0" ) ) )
   JOIN (pa
   WHERE (p.person_id = pa.person_id )
   AND (pa.person_alias_type_cd = mrn )
   AND (pa.active_ind = 1 )
   AND (pa.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 0" ) ) )
  ORDER BY unit ,
   room ,
   bed
  HEAD REPORT
   cnt = 0
  HEAD unit
   cnt = (cnt + 1 ) ,
   IF ((((mod (cnt ,10 ) = 1 ) ) OR ((cnt = 1 ) )) ) stat = alterlist (a->qual ,(cnt + 9 ) )
   ENDIF
   ,a->qual[cnt ].unit = unit ,a->rec_cnt = cnt ,ocnt = 0
  HEAD o.order_id
   ocnt = (ocnt + 1 ) ,
   IF ((((mod (ocnt ,10 ) = 1 ) ) OR ((ocnt = 1 ) )) ) stat = alterlist (a->qual[cnt ].ordqual ,(
     ocnt + 9 ) )
   ENDIF
   ,a->qual[cnt ].ordqual[ocnt ].personid = p.person_id ,a->qual[cnt ].ordqual[ocnt ].encntrid = e
   .encntr_id ,a->qual[cnt ].ordqual[ocnt ].name = trim (p.name_full_formatted ) ,a->qual[cnt ].
   ordqual[ocnt ].mrn = trim (pa.alias ) ,a->qual[cnt ].ordqual[ocnt ].fin = trim (ea.alias ) ,a->
   qual[cnt ].ordqual[ocnt ].room = uar_get_code_display (e.loc_room_cd ) ,a->qual[cnt ].ordqual[
   ocnt ].bed = uar_get_code_display (e.loc_bed_cd ) ,a->qual[cnt ].ordqual[ocnt ].loc = build (a->
    qual[cnt ].unit ," " ,a->qual[cnt ].ordqual[ocnt ].room ,"/" ,a->qual[cnt ].ordqual[ocnt ].bed )
   ,a->qual[cnt ].ordqual[ocnt ].ordname = trim (o.hna_order_mnemonic ) ,a->qual[cnt ].ordqual[ocnt ]
   .orderid = o.order_id ,a->qual[cnt ].ordqual[ocnt ].orddttm = format (o.orig_order_dt_tm ,
    "MM/DD/YYYY HH:MM;;Q" ) ,a->qual[cnt ].ordcnt = ocnt
  FOOT  unit
   a->qual[cnt ].tottestsperunit = a->qual[cnt ].ordcnt ,stat = alterlist (a->qual[cnt ].ordqual ,
    ocnt )
  FOOT REPORT
   stat = alterlist (a->qual ,cnt )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = a->rec_cnt ),
   (dummyt d2 WITH seq = 1 ),
   (clinical_event ce ),
   (ce_specimen_coll csc )
  PLAN (d
   WHERE maxrec (d2 ,a->qual[d.seq ].ordcnt ) )
   JOIN (d2 )
   JOIN (ce
   WHERE (a->qual[d.seq ].ordqual[d2.seq ].orderid = ce.order_id )
   AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 0" ) ) )
   JOIN (csc
   WHERE (ce.event_id = csc.event_id )
   AND (csc.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 0" ) ) )
  HEAD ce.encntr_id
   cnt = 0
  DETAIL
   cnt = (cnt + 1 ) ,
   IF ((((mod (cnt ,10 ) = 1 ) ) OR ((cnt = 1 ) )) ) stat = alterlist (a->qual[d.seq ].ordqual[d2
     .seq ].resqual ,(cnt + 9 ) )
   ENDIF
   ,a->qual[d.seq ].ordqual[d2.seq ].resqual[cnt ].eventcd = ce.event_cd ,
   a->qual[d.seq ].ordqual[d2.seq ].resqual[cnt ].eventdsp = uar_get_code_display (ce.event_cd ) ,
   a->qual[d.seq ].ordqual[d2.seq ].resqual[cnt ].eventid = ce.event_id ,
   a->qual[d.seq ].ordqual[d2.seq ].resqual[cnt ].result = trim (ce.result_val ) ,
   a->qual[d.seq ].ordqual[d2.seq ].accessionnbr = cnvtacc (ce.accession_nbr ) ,
   a->qual[d.seq ].ordqual[d2.seq ].colldttm = format (csc.collect_dt_tm ,"mm/dd/yyyy hh:mm;;q" ) ,
   a->qual[d.seq ].ordqual[d2.seq ].recdttm = format (csc.recvd_dt_tm ,"mm/dd/yyyy hh:mm;;q" ) ,
   a->qual[d.seq ].ordqual[d2.seq ].resqual[cnt ].normalrng = ce.normal_low ,
   a->qual[d.seq ].ordqual[d2.seq ].rescnt = cnt ,
   IF ((ce.result_val = "Positive" ) ) a->qual[d.seq ].ordqual[d2.seq ].printflg = 1 ,a->qual[d.seq ]
    .totpostestsperunit = (a->qual[d.seq ].totpostestsperunit + 1 )
   ENDIF
  FOOT  ce.encntr_id
   stat = alterlist (a->qual[d.seq ].ordqual[d2.seq ].resqual ,cnt )
  WITH nocounter
 ;end select
 FOR (i = 1 TO a->rec_cnt )
  SET a->qual[i ].pospercperunit = build2 (cnvtstring (((cnvtreal (a->qual[i ].totpostestsperunit )
    / cnvtreal (a->qual[i ].tottestsperunit ) ) * 100 ) ,3 ,2 ) ," %" )
 ENDFOR
 CALL echorecord (a )
#exitscript
END GO


DROP PROGRAM pfs_rehab_ot_goals :dba GO
CREATE PROGRAM pfs_rehab_ot_goals :dba
 SET rhead = concat ("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}" ,
  "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134" )
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\plain \f0 \fs18 \cb2 "
 SET wb = "\plain \f0 \fs18 \b \cb2 "
 SET wbi = "\plain \f0 \fs18 \b \i \cb2 "
 SET ws = "\plain \f0 \fs18 \strike \cb2"
 SET hi = "\pard\fi-2340\li2340 "
 SET wbu = "\plain \f0 \fs18 \ul \b \cb2 "
 SET rtfeof = "}"
 FREE RECORD out
 RECORD out (
   1 eat [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 stat = vc
     2 cmt = vc
   1 grm [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 stat = vc
     2 cmt = vc
   1 ubd [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 stat = vc
     2 cmt = vc
   1 lbd [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 stat = vc
     2 cmt = vc
   1 bath [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 stat = vc
     2 cmt = vc
   1 toil [* ]
     2 desc = vc
     2 act = vc
     2 ast = vc
     2 equip = vc
     2 equip2 = vc
     2 stat = vc
     2 cmt = vc
   1 cog [* ]
     2 act = vc
     2 desc = vc
     2 det = vc
     2 stat = vc
     2 cmt = vc
   1 iadl [* ]
     2 act = vc
     2 desc = vc
     2 ast = vc
     2 det = vc
     2 stat = vc
     2 cmt = vc
   1 otbal [* ]
     2 desc = vc
     2 type = vc
     2 ast = vc
     2 dev = vc
     2 ltm = vc
     2 rat = vc
     2 stat = vc
     2 cmt = vc
   1 oth [* ]
     2 goal = vc
     2 stat = vc
     2 cmt = vc
 )
 DECLARE ce_event_end_dt_tm = dq8 WITH public
 DECLARE first_dttm = c1 WITH public ,noconstant (" " )
 DECLARE auth = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE modified = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) ) ,protect
 DECLARE altered = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) ) ,protect
 DECLARE eat_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10748" ) )
 DECLARE eat_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10749" ) )
 DECLARE eat_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10750" ) )
 DECLARE eat_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10751" ) )
 DECLARE eat_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10752" ) )
 DECLARE eat_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10753" ) )
 DECLARE eat_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10754" ) )
 DECLARE eat_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10755" ) )
 DECLARE eat_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10756" ) )
 DECLARE eat_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10757" ) )
 DECLARE eat_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10758" ) )
 DECLARE eat_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10759" ) )
 DECLARE eat_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10760" ) )
 DECLARE eat_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10761" ) )
 DECLARE eat_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10762" ) )
 DECLARE eat_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10763" ) )
 DECLARE eat_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10764" ) )
 DECLARE eat_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10765" ) )
 DECLARE eat_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10766" ) )
 DECLARE eat_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10767" ) )
 DECLARE eat_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10768" ) )
 DECLARE eat_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10769" ) )
 DECLARE eat_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10770" ) )
 DECLARE eat_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10771" ) )
 DECLARE eat_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10772" ) )
 DECLARE eat_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10773" ) )
 DECLARE eat_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10774" ) )
 DECLARE eat_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10775" ) )
 DECLARE eat_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10776" ) )
 DECLARE eat_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10777" ) )
 DECLARE eat_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10778" ) )
 DECLARE eat_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10779" ) )
 DECLARE eat_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10780" ) )
 DECLARE eat_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10781" ) )
 DECLARE eat_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10782" ) )
 DECLARE eat_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10783" ) )
 DECLARE eat_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10784" ) )
 DECLARE eat_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10785" ) )
 DECLARE eat_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10786" ) )
 DECLARE eat_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10787" ) )
 DECLARE eat_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10788" ) )
 DECLARE eat_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10789" ) )
 DECLARE eat_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10790" ) )
 DECLARE eat_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10791" ) )
 DECLARE eat_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10792" ) )
 DECLARE eat_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10793" ) )
 DECLARE eat_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10794" ) )
 DECLARE eat_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10795" ) )
 DECLARE grm_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10796" ) )
 DECLARE grm_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10797" ) )
 DECLARE grm_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10798" ) )
 DECLARE grm_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10799" ) )
 DECLARE grm_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10800" ) )
 DECLARE grm_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10801" ) )
 DECLARE grm_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10802" ) )
 DECLARE grm_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10803" ) )
 DECLARE grm_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10804" ) )
 DECLARE grm_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10805" ) )
 DECLARE grm_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10806" ) )
 DECLARE grm_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10807" ) )
 DECLARE grm_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10808" ) )
 DECLARE grm_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10809" ) )
 DECLARE grm_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10810" ) )
 DECLARE grm_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10811" ) )
 DECLARE grm_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10812" ) )
 DECLARE grm_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10813" ) )
 DECLARE grm_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10814" ) )
 DECLARE grm_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10815" ) )
 DECLARE grm_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10816" ) )
 DECLARE grm_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10817" ) )
 DECLARE grm_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10818" ) )
 DECLARE grm_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10819" ) )
 DECLARE grm_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10820" ) )
 DECLARE grm_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10821" ) )
 DECLARE grm_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10822" ) )
 DECLARE grm_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10823" ) )
 DECLARE grm_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10824" ) )
 DECLARE grm_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10825" ) )
 DECLARE grm_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10826" ) )
 DECLARE grm_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10827" ) )
 DECLARE grm_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10828" ) )
 DECLARE grm_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10829" ) )
 DECLARE grm_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10830" ) )
 DECLARE grm_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10831" ) )
 DECLARE grm_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10832" ) )
 DECLARE grm_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10833" ) )
 DECLARE grm_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10834" ) )
 DECLARE grm_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10835" ) )
 DECLARE grm_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10836" ) )
 DECLARE grm_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10837" ) )
 DECLARE grm_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10838" ) )
 DECLARE grm_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10839" ) )
 DECLARE grm_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10840" ) )
 DECLARE grm_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10841" ) )
 DECLARE grm_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10842" ) )
 DECLARE grm_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10843" ) )
 DECLARE ubd_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10844" ) )
 DECLARE ubd_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10845" ) )
 DECLARE ubd_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10846" ) )
 DECLARE ubd_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10847" ) )
 DECLARE ubd_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10848" ) )
 DECLARE ubd_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10849" ) )
 DECLARE ubd_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10850" ) )
 DECLARE ubd_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10851" ) )
 DECLARE ubd_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10852" ) )
 DECLARE ubd_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10853" ) )
 DECLARE ubd_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10854" ) )
 DECLARE ubd_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10855" ) )
 DECLARE ubd_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10856" ) )
 DECLARE ubd_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10857" ) )
 DECLARE ubd_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10858" ) )
 DECLARE ubd_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10859" ) )
 DECLARE ubd_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10860" ) )
 DECLARE ubd_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10861" ) )
 DECLARE ubd_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10862" ) )
 DECLARE ubd_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10863" ) )
 DECLARE ubd_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10864" ) )
 DECLARE ubd_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10865" ) )
 DECLARE ubd_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10866" ) )
 DECLARE ubd_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10867" ) )
 DECLARE ubd_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10868" ) )
 DECLARE ubd_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10869" ) )
 DECLARE ubd_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10870" ) )
 DECLARE ubd_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10871" ) )
 DECLARE ubd_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10872" ) )
 DECLARE ubd_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10873" ) )
 DECLARE ubd_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10874" ) )
 DECLARE ubd_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10875" ) )
 DECLARE ubd_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10876" ) )
 DECLARE ubd_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10877" ) )
 DECLARE ubd_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10878" ) )
 DECLARE ubd_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10879" ) )
 DECLARE ubd_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10880" ) )
 DECLARE ubd_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10881" ) )
 DECLARE ubd_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10882" ) )
 DECLARE ubd_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10883" ) )
 DECLARE ubd_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10884" ) )
 DECLARE ubd_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10885" ) )
 DECLARE ubd_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10886" ) )
 DECLARE ubd_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10887" ) )
 DECLARE ubd_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10888" ) )
 DECLARE ubd_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10889" ) )
 DECLARE ubd_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10890" ) )
 DECLARE ubd_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10891" ) )
 DECLARE lbd_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10892" ) )
 DECLARE lbd_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10893" ) )
 DECLARE lbd_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10894" ) )
 DECLARE lbd_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10895" ) )
 DECLARE lbd_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10896" ) )
 DECLARE lbd_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10897" ) )
 DECLARE lbd_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10898" ) )
 DECLARE lbd_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10899" ) )
 DECLARE lbd_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10900" ) )
 DECLARE lbd_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10901" ) )
 DECLARE lbd_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10902" ) )
 DECLARE lbd_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10903" ) )
 DECLARE lbd_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10904" ) )
 DECLARE lbd_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10905" ) )
 DECLARE lbd_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10906" ) )
 DECLARE lbd_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10907" ) )
 DECLARE lbd_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10908" ) )
 DECLARE lbd_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10909" ) )
 DECLARE lbd_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10910" ) )
 DECLARE lbd_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10911" ) )
 DECLARE lbd_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10912" ) )
 DECLARE lbd_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10913" ) )
 DECLARE lbd_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10914" ) )
 DECLARE lbd_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10915" ) )
 DECLARE lbd_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10916" ) )
 DECLARE lbd_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10917" ) )
 DECLARE lbd_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10918" ) )
 DECLARE lbd_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10919" ) )
 DECLARE lbd_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10920" ) )
 DECLARE lbd_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10921" ) )
 DECLARE lbd_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10922" ) )
 DECLARE lbd_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10923" ) )
 DECLARE lbd_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10924" ) )
 DECLARE lbd_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10925" ) )
 DECLARE lbd_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10926" ) )
 DECLARE lbd_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10927" ) )
 DECLARE lbd_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10928" ) )
 DECLARE lbd_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10929" ) )
 DECLARE lbd_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10930" ) )
 DECLARE lbd_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10931" ) )
 DECLARE lbd_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10932" ) )
 DECLARE lbd_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10933" ) )
 DECLARE lbd_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10934" ) )
 DECLARE lbd_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10935" ) )
 DECLARE lbd_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10936" ) )
 DECLARE lbd_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10937" ) )
 DECLARE lbd_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10938" ) )
 DECLARE lbd_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10939" ) )
 DECLARE bath_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10940" ) )
 DECLARE bath_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10941" ) )
 DECLARE bath_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10942" ) )
 DECLARE bath_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10943" ) )
 DECLARE bath_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10944" ) )
 DECLARE bath_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10945" ) )
 DECLARE bath_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10946" ) )
 DECLARE bath_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10947" ) )
 DECLARE bath_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10948" ) )
 DECLARE bath_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10949" ) )
 DECLARE bath_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10950" ) )
 DECLARE bath_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10951" ) )
 DECLARE bath_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10952" ) )
 DECLARE bath_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10953" ) )
 DECLARE bath_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10954" ) )
 DECLARE bath_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10955" ) )
 DECLARE bath_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10956" ) )
 DECLARE bath_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10957" ) )
 DECLARE bath_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10958" ) )
 DECLARE bath_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10959" ) )
 DECLARE bath_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10960" ) )
 DECLARE bath_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10961" ) )
 DECLARE bath_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10962" ) )
 DECLARE bath_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10963" ) )
 DECLARE bath_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10964" ) )
 DECLARE bath_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10965" ) )
 DECLARE bath_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10966" ) )
 DECLARE bath_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10967" ) )
 DECLARE bath_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10968" ) )
 DECLARE bath_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10969" ) )
 DECLARE bath_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10970" ) )
 DECLARE bath_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10971" ) )
 DECLARE bath_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10972" ) )
 DECLARE bath_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10973" ) )
 DECLARE bath_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10974" ) )
 DECLARE bath_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10975" ) )
 DECLARE bath_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10976" ) )
 DECLARE bath_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10977" ) )
 DECLARE bath_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10978" ) )
 DECLARE bath_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10979" ) )
 DECLARE bath_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10980" ) )
 DECLARE bath_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10981" ) )
 DECLARE bath_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10982" ) )
 DECLARE bath_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10983" ) )
 DECLARE bath_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10984" ) )
 DECLARE bath_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10985" ) )
 DECLARE bath_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10986" ) )
 DECLARE bath_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10987" ) )
 DECLARE toil_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10988" ) )
 DECLARE toil_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10989" ) )
 DECLARE toil_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10990" ) )
 DECLARE toil_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10991" ) )
 DECLARE totr_g1_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10992" ) )
 DECLARE toil_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10993" ) )
 DECLARE toil_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10994" ) )
 DECLARE toil_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10995" ) )
 DECLARE toil_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10996" ) )
 DECLARE toil_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10997" ) )
 DECLARE toil_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10998" ) )
 DECLARE totr_g2_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10999" ) )
 DECLARE toil_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11000" ) )
 DECLARE toil_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11001" ) )
 DECLARE toil_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11002" ) )
 DECLARE toil_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11003" ) )
 DECLARE toil_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11004" ) )
 DECLARE toil_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11005" ) )
 DECLARE totr_g3_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11006" ) )
 DECLARE toil_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11007" ) )
 DECLARE toil_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11008" ) )
 DECLARE toil_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11009" ) )
 DECLARE toil_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11010" ) )
 DECLARE toil_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11011" ) )
 DECLARE toil_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11012" ) )
 DECLARE totr_g4_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11013" ) )
 DECLARE toil_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11014" ) )
 DECLARE toil_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11015" ) )
 DECLARE toil_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11016" ) )
 DECLARE toil_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11017" ) )
 DECLARE toil_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11018" ) )
 DECLARE toil_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11019" ) )
 DECLARE totr_g5_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11020" ) )
 DECLARE toil_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11021" ) )
 DECLARE toil_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11022" ) )
 DECLARE toil_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11023" ) )
 DECLARE toil_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11024" ) )
 DECLARE toil_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11025" ) )
 DECLARE toil_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11026" ) )
 DECLARE totr_g6_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11027" ) )
 DECLARE toil_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11028" ) )
 DECLARE toil_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11029" ) )
 DECLARE toil_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11030" ) )
 DECLARE toil_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11031" ) )
 DECLARE toil_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11032" ) )
 DECLARE toil_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11033" ) )
 DECLARE totr_g7_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11034" ) )
 DECLARE toil_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11035" ) )
 DECLARE toil_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11036" ) )
 DECLARE toil_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11037" ) )
 DECLARE toil_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11038" ) )
 DECLARE toil_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11039" ) )
 DECLARE toil_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11040" ) )
 DECLARE totr_g8_equip = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11041" ) )
 DECLARE toil_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11042" ) )
 DECLARE toil_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11043" ) )
 DECLARE cog_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11044" ) )
 DECLARE cog_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13173" ) )
 DECLARE cog_g1_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11045" ) )
 DECLARE cog_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11046" ) )
 DECLARE cog_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11047" ) )
 DECLARE cog_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11048" ) )
 DECLARE cog_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13174" ) )
 DECLARE cog_g2_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11049" ) )
 DECLARE cog_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11050" ) )
 DECLARE cog_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11051" ) )
 DECLARE cog_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11052" ) )
 DECLARE cog_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13175" ) )
 DECLARE cog_g3_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11053" ) )
 DECLARE cog_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11054" ) )
 DECLARE cog_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11055" ) )
 DECLARE cog_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11056" ) )
 DECLARE cog_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13176" ) )
 DECLARE cog_g4_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11057" ) )
 DECLARE cog_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11058" ) )
 DECLARE cog_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11059" ) )
 DECLARE cog_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11060" ) )
 DECLARE cog_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13177" ) )
 DECLARE cog_g5_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11061" ) )
 DECLARE cog_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11062" ) )
 DECLARE cog_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11063" ) )
 DECLARE cog_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11064" ) )
 DECLARE cog_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13178" ) )
 DECLARE cog_g6_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11065" ) )
 DECLARE cog_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11066" ) )
 DECLARE cog_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11067" ) )
 DECLARE cog_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11068" ) )
 DECLARE cog_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13179" ) )
 DECLARE cog_g7_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11069" ) )
 DECLARE cog_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11070" ) )
 DECLARE cog_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11071" ) )
 DECLARE cog_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11072" ) )
 DECLARE cog_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13180" ) )
 DECLARE cog_g8_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11073" ) )
 DECLARE cog_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11074" ) )
 DECLARE cog_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11075" ) )
 DECLARE iadl_g1_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11076" ) )
 DECLARE iadl_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13181" ) )
 DECLARE iadl_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13182" ) )
 DECLARE iadl_g1_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11077" ) )
 DECLARE iadl_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11078" ) )
 DECLARE iadl_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11079" ) )
 DECLARE iadl_g2_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11080" ) )
 DECLARE iadl_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13183" ) )
 DECLARE iadl_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13184" ) )
 DECLARE iadl_g2_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11081" ) )
 DECLARE iadl_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11082" ) )
 DECLARE iadl_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11083" ) )
 DECLARE iadl_g3_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11084" ) )
 DECLARE iadl_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13185" ) )
 DECLARE iadl_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13186" ) )
 DECLARE iadl_g3_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11085" ) )
 DECLARE iadl_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11086" ) )
 DECLARE iadl_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11087" ) )
 DECLARE iadl_g4_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11088" ) )
 DECLARE iadl_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13187" ) )
 DECLARE iadl_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13188" ) )
 DECLARE iadl_g4_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11089" ) )
 DECLARE iadl_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11090" ) )
 DECLARE iadl_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11091" ) )
 DECLARE iadl_g5_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11092" ) )
 DECLARE iadl_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13189" ) )
 DECLARE iadl_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13190" ) )
 DECLARE iadl_g5_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11093" ) )
 DECLARE iadl_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11094" ) )
 DECLARE iadl_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11095" ) )
 DECLARE iadl_g6_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11096" ) )
 DECLARE iadl_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13191" ) )
 DECLARE iadl_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13192" ) )
 DECLARE iadl_g6_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11097" ) )
 DECLARE iadl_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11098" ) )
 DECLARE iadl_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11099" ) )
 DECLARE iadl_g7_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11100" ) )
 DECLARE iadl_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13193" ) )
 DECLARE iadl_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13194" ) )
 DECLARE iadl_g7_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11101" ) )
 DECLARE iadl_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11102" ) )
 DECLARE iadl_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11103" ) )
 DECLARE iadl_g8_act = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11104" ) )
 DECLARE iadl_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13195" ) )
 DECLARE iadl_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!13196" ) )
 DECLARE iadl_g8_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11105" ) )
 DECLARE iadl_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11106" ) )
 DECLARE iadl_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11107" ) )
 DECLARE otbal_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11470" ) )
 DECLARE otbal_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11471" ) )
 DECLARE otbal_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11472" ) )
 DECLARE otbal_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11473" ) )
 DECLARE otbal_g1_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11474" ) )
 DECLARE otbal_g2_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11475" ) )
 DECLARE otbal_g3_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11476" ) )
 DECLARE otbal_g4_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11477" ) )
 DECLARE otbal_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11478" ) )
 DECLARE otbal_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11479" ) )
 DECLARE otbal_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11480" ) )
 DECLARE otbal_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11481" ) )
 DECLARE otbal_g1_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11482" ) )
 DECLARE otbal_g2_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11483" ) )
 DECLARE otbal_g3_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11484" ) )
 DECLARE otbal_g4_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11485" ) )
 DECLARE otbal_g1_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11486" ) )
 DECLARE otbal_g2_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11487" ) )
 DECLARE otbal_g3_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11488" ) )
 DECLARE otbal_g4_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11489" ) )
 DECLARE otbal_g1_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11490" ) )
 DECLARE otbal_g2_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11491" ) )
 DECLARE otbal_g3_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11492" ) )
 DECLARE otbal_g4_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11493" ) )
 DECLARE otbal_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11494" ) )
 DECLARE otbal_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11495" ) )
 DECLARE otbal_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11496" ) )
 DECLARE otbal_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11497" ) )
 DECLARE otbal_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11625" ) )
 DECLARE otbal_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11626" ) )
 DECLARE otbal_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11627" ) )
 DECLARE otbal_g5_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11628" ) )
 DECLARE otbal_g5_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11629" ) )
 DECLARE otbal_g5_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11630" ) )
 DECLARE otbal_g5_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11631" ) )
 DECLARE otbal_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11632" ) )
 DECLARE otbal_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11633" ) )
 DECLARE otbal_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11634" ) )
 DECLARE otbal_g6_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11635" ) )
 DECLARE otbal_g6_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11636" ) )
 DECLARE otbal_g6_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11637" ) )
 DECLARE otbal_g6_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11638" ) )
 DECLARE otbal_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11639" ) )
 DECLARE otbal_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11640" ) )
 DECLARE otbal_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11641" ) )
 DECLARE otbal_g7_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11642" ) )
 DECLARE otbal_g7_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11643" ) )
 DECLARE otbal_g7_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11644" ) )
 DECLARE otbal_g7_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11645" ) )
 DECLARE otbal_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11646" ) )
 DECLARE otbal_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11647" ) )
 DECLARE otbal_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11648" ) )
 DECLARE otbal_g8_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11649" ) )
 DECLARE otbal_g8_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11650" ) )
 DECLARE otbal_g8_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11651" ) )
 DECLARE otbal_g8_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11652" ) )
 DECLARE otbal_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12122" ) )
 DECLARE otbal_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12124" ) )
 DECLARE otbal_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12126" ) )
 DECLARE otbal_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12128" ) )
 DECLARE otbal_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12130" ) )
 DECLARE otbal_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12132" ) )
 DECLARE otbal_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12134" ) )
 DECLARE otbal_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12136" ) )
 DECLARE oth_g1 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11414" ) )
 DECLARE oth_g2 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11415" ) )
 DECLARE oth_g3 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11416" ) )
 DECLARE oth_g4 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11417" ) )
 DECLARE oth_g5 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11418" ) )
 DECLARE oth_g6 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11419" ) )
 DECLARE oth_g7 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11420" ) )
 DECLARE oth_g8 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11421" ) )
 DECLARE oth_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11422" ) )
 DECLARE oth_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11423" ) )
 DECLARE oth_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11424" ) )
 DECLARE oth_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11425" ) )
 DECLARE oth_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11426" ) )
 DECLARE oth_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11427" ) )
 DECLARE oth_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11428" ) )
 DECLARE oth_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11429" ) )
 DECLARE oth_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11438" ) )
 DECLARE oth_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11439" ) )
 DECLARE oth_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11440" ) )
 DECLARE oth_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11441" ) )
 DECLARE oth_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11442" ) )
 DECLARE oth_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11443" ) )
 DECLARE oth_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11444" ) )
 DECLARE oth_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11445" ) )
 DECLARE pat_id = f8 WITH noconstant (0 ) ,protect
 DECLARE ent_id = f8 WITH noconstant (0 ) ,protect
 SELECT INTO "nl:"
  FROM (encounter e )
  WHERE (e.encntr_id = request->visit[1 ].encntr_id )
  DETAIL
   pat_id = e.person_id ,
   ent_id = e.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_stat_first =
  IF ((ce.event_cd IN (eat_g1_stat ,
  eat_g2_stat ,
  eat_g3_stat ,
  eat_g4_stat ,
  eat_g5_stat ,
  eat_g6_stat ,
  eat_g7_stat ,
  eat_g8_stat ,
  grm_g1_stat ,
  grm_g2_stat ,
  grm_g3_stat ,
  grm_g4_stat ,
  grm_g5_stat ,
  grm_g6_stat ,
  grm_g7_stat ,
  grm_g8_stat ,
  ubd_g1_stat ,
  ubd_g2_stat ,
  ubd_g3_stat ,
  ubd_g4_stat ,
  ubd_g5_stat ,
  ubd_g6_stat ,
  ubd_g7_stat ,
  ubd_g8_stat ,
  lbd_g1_stat ,
  lbd_g2_stat ,
  lbd_g3_stat ,
  lbd_g4_stat ,
  lbd_g5_stat ,
  lbd_g6_stat ,
  lbd_g7_stat ,
  lbd_g8_stat ,
  bath_g1_stat ,
  bath_g2_stat ,
  bath_g3_stat ,
  bath_g4_stat ,
  bath_g5_stat ,
  bath_g6_stat ,
  bath_g7_stat ,
  bath_g8_stat ,
  toil_g1_stat ,
  toil_g2_stat ,
  toil_g3_stat ,
  toil_g4_stat ,
  toil_g5_stat ,
  toil_g6_stat ,
  toil_g7_stat ,
  toil_g8_stat ,
  cog_g1_stat ,
  cog_g2_stat ,
  cog_g3_stat ,
  cog_g4_stat ,
  cog_g5_stat ,
  cog_g6_stat ,
  cog_g7_stat ,
  cog_g8_stat ,
  iadl_g1_stat ,
  iadl_g2_stat ,
  iadl_g3_stat ,
  iadl_g4_stat ,
  iadl_g5_stat ,
  iadl_g6_stat ,
  iadl_g7_stat ,
  iadl_g8_stat ,
  otbal_g1_stat ,
  otbal_g2_stat ,
  otbal_g3_stat ,
  otbal_g4_stat ,
  otbal_g5_stat ,
  otbal_g6_stat ,
  otbal_g7_stat ,
  otbal_g8_stat ,
  oth_g1_stat ,
  oth_g2_stat ,
  oth_g3_stat ,
  oth_g4_stat ,
  oth_g5_stat ,
  oth_g6_stat ,
  oth_g7_stat ,
  oth_g8_stat ) ) ) 0
  ELSE 1
  ENDIF
  FROM (clinical_event ce )
  PLAN (ce
   WHERE (ce.encntr_id = ent_id )
   AND (ce.person_id = pat_id )
   AND (((ce.event_cd IN (eat_g1_desc ,
   eat_g1_act ,
   eat_g1_ast ,
   eat_g1_equip ,
   eat_g1_stat ,
   eat_g1_cmt ,
   eat_g2_desc ,
   eat_g2_act ,
   eat_g2_ast ,
   eat_g2_equip ,
   eat_g2_stat ,
   eat_g2_cmt ,
   eat_g3_desc ,
   eat_g3_act ,
   eat_g3_ast ,
   eat_g3_equip ,
   eat_g3_stat ,
   eat_g3_cmt ,
   eat_g4_desc ,
   eat_g4_act ,
   eat_g4_ast ,
   eat_g4_equip ,
   eat_g4_stat ,
   eat_g4_cmt ,
   eat_g5_desc ,
   eat_g5_act ,
   eat_g5_ast ,
   eat_g5_equip ,
   eat_g5_stat ,
   eat_g5_cmt ,
   eat_g6_desc ,
   eat_g6_act ,
   eat_g6_ast ,
   eat_g6_equip ,
   eat_g6_stat ,
   eat_g6_cmt ,
   eat_g7_desc ,
   eat_g7_act ,
   eat_g7_ast ,
   eat_g7_equip ,
   eat_g7_stat ,
   eat_g7_cmt ,
   eat_g8_desc ,
   eat_g8_act ,
   eat_g8_ast ,
   eat_g8_equip ,
   eat_g8_stat ,
   eat_g8_cmt ,
   grm_g1_desc ,
   grm_g1_act ,
   grm_g1_ast ,
   grm_g1_equip ,
   grm_g1_stat ,
   grm_g1_cmt ,
   grm_g2_desc ,
   grm_g2_act ,
   grm_g2_ast ,
   grm_g2_equip ,
   grm_g2_stat ,
   grm_g2_cmt ,
   grm_g3_desc ,
   grm_g3_act ,
   grm_g3_ast ,
   grm_g3_equip ,
   grm_g3_stat ,
   grm_g3_cmt ,
   grm_g4_desc ,
   grm_g4_act ,
   grm_g4_ast ,
   grm_g4_equip ,
   grm_g4_stat ,
   grm_g4_cmt ,
   grm_g5_desc ,
   grm_g5_act ,
   grm_g5_ast ,
   grm_g5_equip ,
   grm_g5_stat ,
   grm_g5_cmt ,
   grm_g6_desc ,
   grm_g6_act ,
   grm_g6_ast ,
   grm_g6_equip ,
   grm_g6_stat ,
   grm_g6_cmt ,
   grm_g7_desc ,
   grm_g7_act ,
   grm_g7_ast ,
   grm_g7_equip ,
   grm_g7_stat ,
   grm_g7_cmt ,
   grm_g8_desc ,
   grm_g8_act ,
   grm_g8_ast ,
   grm_g8_equip ,
   grm_g8_stat ,
   grm_g8_cmt ,
   ubd_g1_desc ,
   ubd_g1_act ,
   ubd_g1_ast ,
   ubd_g1_equip ,
   ubd_g1_stat ,
   ubd_g1_cmt ,
   ubd_g2_desc ,
   ubd_g2_act ,
   ubd_g2_ast ,
   ubd_g2_equip ,
   ubd_g2_stat ,
   ubd_g2_cmt ,
   ubd_g3_desc ,
   ubd_g3_act ,
   ubd_g3_ast ,
   ubd_g3_equip ,
   ubd_g3_stat ,
   ubd_g3_cmt ,
   ubd_g4_desc ,
   ubd_g4_act ,
   ubd_g4_ast ,
   ubd_g4_equip ,
   ubd_g4_stat ,
   ubd_g4_cmt ,
   ubd_g5_desc ,
   ubd_g5_act ,
   ubd_g5_ast ,
   ubd_g5_equip ,
   ubd_g5_stat ,
   ubd_g5_cmt ,
   ubd_g6_desc ,
   ubd_g6_act ,
   ubd_g6_ast ,
   ubd_g6_equip ,
   ubd_g6_stat ,
   ubd_g6_cmt ,
   ubd_g7_desc ,
   ubd_g7_act ,
   ubd_g7_ast ,
   ubd_g7_equip ,
   ubd_g7_stat ,
   ubd_g7_cmt ,
   ubd_g8_desc ,
   ubd_g8_act ,
   ubd_g8_ast ,
   ubd_g8_equip ,
   ubd_g8_stat ,
   ubd_g8_cmt ,
   lbd_g1_desc ,
   lbd_g1_act ,
   lbd_g1_ast ,
   lbd_g1_equip ,
   lbd_g1_stat ,
   lbd_g1_cmt ,
   lbd_g2_desc ,
   lbd_g2_act ,
   lbd_g2_ast ,
   lbd_g2_equip ,
   lbd_g2_stat ,
   lbd_g2_cmt ,
   lbd_g3_desc ,
   lbd_g3_act ,
   lbd_g3_ast ,
   lbd_g3_equip ,
   lbd_g3_stat ,
   lbd_g3_cmt ,
   lbd_g4_desc ,
   lbd_g4_act ,
   lbd_g4_ast ,
   lbd_g4_equip ,
   lbd_g4_stat ,
   lbd_g4_cmt ,
   lbd_g5_desc ,
   lbd_g5_act ,
   lbd_g5_ast ,
   lbd_g5_equip ,
   lbd_g5_stat ,
   lbd_g5_cmt ,
   lbd_g6_desc ,
   lbd_g6_act ,
   lbd_g6_ast ,
   lbd_g6_equip ,
   lbd_g6_stat ,
   lbd_g6_cmt ,
   lbd_g7_desc ,
   lbd_g7_act ,
   lbd_g7_ast ,
   lbd_g7_equip ,
   lbd_g7_stat ,
   lbd_g7_cmt ,
   lbd_g8_desc ,
   lbd_g8_act ,
   lbd_g8_ast ,
   lbd_g8_equip ,
   lbd_g8_stat ,
   lbd_g8_cmt ) ) ) OR ((((ce.event_cd IN (bath_g1_desc ,
   bath_g1_act ,
   bath_g1_ast ,
   bath_g1_equip ,
   bath_g1_stat ,
   bath_g1_cmt ,
   bath_g2_desc ,
   bath_g2_act ,
   bath_g2_ast ,
   bath_g2_equip ,
   bath_g2_stat ,
   bath_g2_cmt ,
   bath_g3_desc ,
   bath_g3_act ,
   bath_g3_ast ,
   bath_g3_equip ,
   bath_g3_stat ,
   bath_g3_cmt ,
   bath_g4_desc ,
   bath_g4_act ,
   bath_g4_ast ,
   bath_g4_equip ,
   bath_g4_stat ,
   bath_g4_cmt ,
   bath_g5_desc ,
   bath_g5_act ,
   bath_g5_ast ,
   bath_g5_equip ,
   bath_g5_stat ,
   bath_g5_cmt ,
   bath_g6_desc ,
   bath_g6_act ,
   bath_g6_ast ,
   bath_g6_equip ,
   bath_g6_stat ,
   bath_g6_cmt ,
   bath_g7_desc ,
   bath_g7_act ,
   bath_g7_ast ,
   bath_g7_equip ,
   bath_g7_stat ,
   bath_g7_cmt ,
   bath_g8_desc ,
   bath_g8_act ,
   bath_g8_ast ,
   bath_g8_equip ,
   bath_g8_stat ,
   bath_g8_cmt ,
   toil_g1_desc ,
   toil_g1_act ,
   toil_g1_ast ,
   toil_g1_equip ,
   totr_g1_equip ,
   toil_g1_stat ,
   toil_g1_cmt ,
   toil_g2_desc ,
   toil_g2_act ,
   toil_g2_ast ,
   toil_g2_equip ,
   totr_g2_equip ,
   toil_g2_stat ,
   toil_g2_cmt ,
   toil_g3_desc ,
   toil_g3_act ,
   toil_g3_ast ,
   toil_g3_equip ,
   totr_g3_equip ,
   toil_g3_stat ,
   toil_g3_cmt ,
   toil_g4_desc ,
   toil_g4_act ,
   toil_g4_ast ,
   toil_g4_equip ,
   totr_g4_equip ,
   toil_g4_stat ,
   toil_g4_cmt ,
   toil_g5_desc ,
   toil_g5_act ,
   toil_g5_ast ,
   toil_g5_equip ,
   totr_g5_equip ,
   toil_g5_stat ,
   toil_g5_cmt ,
   toil_g6_desc ,
   toil_g6_act ,
   toil_g6_ast ,
   toil_g6_equip ,
   totr_g6_equip ,
   toil_g6_stat ,
   toil_g6_cmt ,
   toil_g7_desc ,
   toil_g7_act ,
   toil_g7_ast ,
   toil_g7_equip ,
   totr_g7_equip ,
   toil_g7_stat ,
   toil_g7_cmt ,
   toil_g8_desc ,
   toil_g8_act ,
   toil_g8_ast ,
   toil_g8_equip ,
   totr_g8_equip ,
   toil_g8_stat ,
   toil_g8_cmt ,
   cog_g1_act ,
   cog_g1_desc ,
   cog_g1_det ,
   cog_g1_stat ,
   cog_g1_cmt ,
   cog_g2_act ,
   cog_g2_desc ,
   cog_g2_det ,
   cog_g2_stat ,
   cog_g2_cmt ,
   cog_g3_act ,
   cog_g3_desc ,
   cog_g3_det ,
   cog_g3_stat ,
   cog_g3_cmt ,
   cog_g4_act ,
   cog_g4_desc ,
   cog_g4_det ,
   cog_g4_stat ,
   cog_g4_cmt ,
   cog_g5_act ,
   cog_g5_desc ,
   cog_g5_det ,
   cog_g5_stat ,
   cog_g5_cmt ,
   cog_g6_act ,
   cog_g6_desc ,
   cog_g6_det ,
   cog_g6_stat ,
   cog_g6_cmt ,
   cog_g7_act ,
   cog_g7_desc ,
   cog_g7_det ,
   cog_g7_stat ,
   cog_g7_cmt ,
   cog_g8_act ,
   cog_g8_desc ,
   cog_g8_det ,
   cog_g8_stat ,
   cog_g8_cmt ,
   iadl_g1_act ,
   iadl_g1_desc ,
   iadl_g1_ast ,
   iadl_g1_det ,
   iadl_g1_stat ,
   iadl_g1_cmt ,
   iadl_g2_act ,
   iadl_g2_desc ,
   iadl_g2_ast ,
   iadl_g2_det ,
   iadl_g2_stat ,
   iadl_g2_cmt ,
   iadl_g3_act ,
   iadl_g3_desc ,
   iadl_g3_ast ,
   iadl_g3_det ,
   iadl_g3_stat ,
   iadl_g3_cmt ,
   iadl_g4_act ,
   iadl_g4_desc ,
   iadl_g4_ast ,
   iadl_g4_det ,
   iadl_g4_stat ,
   iadl_g4_cmt ,
   iadl_g5_act ,
   iadl_g5_desc ,
   iadl_g5_ast ,
   iadl_g5_det ,
   iadl_g5_stat ,
   iadl_g5_cmt ,
   iadl_g6_act ,
   iadl_g6_desc ,
   iadl_g6_ast ,
   iadl_g6_det ,
   iadl_g6_stat ,
   iadl_g6_cmt ,
   iadl_g7_act ,
   iadl_g7_desc ,
   iadl_g7_ast ,
   iadl_g7_det ,
   iadl_g7_stat ,
   iadl_g7_cmt ,
   iadl_g8_act ,
   iadl_g8_desc ,
   iadl_g8_ast ,
   iadl_g8_det ,
   iadl_g8_stat ,
   iadl_g8_cmt ) ) ) OR ((ce.event_cd IN (otbal_g1_desc ,
   otbal_g2_desc ,
   otbal_g3_desc ,
   otbal_g4_desc ,
   otbal_g1_type ,
   otbal_g2_type ,
   otbal_g3_type ,
   otbal_g4_type ,
   otbal_g1_ast ,
   otbal_g2_ast ,
   otbal_g3_ast ,
   otbal_g4_ast ,
   otbal_g1_dev ,
   otbal_g2_dev ,
   otbal_g3_dev ,
   otbal_g4_dev ,
   otbal_g1_ltm ,
   otbal_g2_ltm ,
   otbal_g3_ltm ,
   otbal_g4_ltm ,
   otbal_g1_rat ,
   otbal_g2_rat ,
   otbal_g3_rat ,
   otbal_g4_rat ,
   otbal_g1_cmt ,
   otbal_g2_cmt ,
   otbal_g3_cmt ,
   otbal_g4_cmt ,
   otbal_g5_ast ,
   otbal_g5_cmt ,
   otbal_g5_desc ,
   otbal_g5_dev ,
   otbal_g5_ltm ,
   otbal_g5_rat ,
   otbal_g5_type ,
   otbal_g6_ast ,
   otbal_g6_cmt ,
   otbal_g6_desc ,
   otbal_g6_dev ,
   otbal_g6_ltm ,
   otbal_g6_rat ,
   otbal_g6_type ,
   otbal_g7_ast ,
   otbal_g7_cmt ,
   otbal_g7_desc ,
   otbal_g7_dev ,
   otbal_g7_ltm ,
   otbal_g7_rat ,
   otbal_g7_type ,
   otbal_g8_ast ,
   otbal_g8_cmt ,
   otbal_g8_desc ,
   otbal_g8_dev ,
   otbal_g8_ltm ,
   otbal_g8_rat ,
   otbal_g8_type ,
   otbal_g1_stat ,
   otbal_g2_stat ,
   otbal_g3_stat ,
   otbal_g4_stat ,
   otbal_g5_stat ,
   otbal_g6_stat ,
   otbal_g7_stat ,
   otbal_g8_stat ,
   oth_g1 ,
   oth_g2 ,
   oth_g3 ,
   oth_g4 ,
   oth_g5 ,
   oth_g6 ,
   oth_g7 ,
   oth_g8 ,
   oth_g1_stat ,
   oth_g2_stat ,
   oth_g3_stat ,
   oth_g4_stat ,
   oth_g5_stat ,
   oth_g6_stat ,
   oth_g7_stat ,
   oth_g8_stat ,
   oth_g1_cmt ,
   oth_g2_cmt ,
   oth_g3_cmt ,
   oth_g4_cmt ,
   oth_g5_cmt ,
   oth_g6_cmt ,
   oth_g7_cmt ,
   oth_g8_cmt ) ) )) ))
   AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (ce.result_status_cd IN (auth ,
   modified ,
   altered ) )
   AND (ce.event_tag != "Date\Time Correction" )
   AND (ce.event_end_dt_tm >= cnvtdatetime ((curdate - 42 ) ,curtime3 ) ) )
  ORDER BY ce.event_end_dt_tm DESC ,
   ce.parent_event_id ,
   sort_stat_first ,
   ce.event_cd
  HEAD REPORT
   stat = alterlist (out->eat ,8 ) ,
   stat = alterlist (out->grm ,8 ) ,
   stat = alterlist (out->ubd ,8 ) ,
   stat = alterlist (out->lbd ,8 ) ,
   stat = alterlist (out->bath ,8 ) ,
   stat = alterlist (out->toil ,8 ) ,
   stat = alterlist (out->cog ,8 ) ,
   stat = alterlist (out->iadl ,8 ) ,
   stat = alterlist (out->otbal ,8 ) ,
   stat = alterlist (out->oth ,8 ) ,
   first_dttm = "Y"
  HEAD ce.event_end_dt_tm
   IF ((first_dttm = "Y" ) ) ce_event_end_dt_tm = ce.event_end_dt_tm
   ENDIF
  HEAD ce.parent_event_id
   skip_flag = "N"
  DETAIL
   IF ((first_dttm = "Y" ) )
    IF ((sort_stat_first = 0 )
    AND (cnvtupper (ce.result_val ) IN ("GOAL MET" ,
    "DISCONTINUE" ) ) ) skip_flag = "Y"
    ENDIF
    ,
    IF ((skip_flag = "N" ) )
     IF ((ce.event_cd IN (eat_g1_desc ,
     eat_g1_act ,
     eat_g1_ast ,
     eat_g1_equip ,
     eat_g1_stat ,
     eat_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g2_desc ,
     eat_g2_act ,
     eat_g2_ast ,
     eat_g2_equip ,
     eat_g2_stat ,
     eat_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g3_desc ,
     eat_g3_act ,
     eat_g3_ast ,
     eat_g3_equip ,
     eat_g3_stat ,
     eat_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g4_desc ,
     eat_g4_act ,
     eat_g4_ast ,
     eat_g4_equip ,
     eat_g4_stat ,
     eat_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g5_desc ,
     eat_g5_act ,
     eat_g5_ast ,
     eat_g5_equip ,
     eat_g5_stat ,
     eat_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g6_desc ,
     eat_g6_act ,
     eat_g6_ast ,
     eat_g6_equip ,
     eat_g6_stat ,
     eat_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g7_desc ,
     eat_g7_act ,
     eat_g7_ast ,
     eat_g7_equip ,
     eat_g7_stat ,
     eat_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (eat_g8_desc ,
     eat_g8_act ,
     eat_g8_ast ,
     eat_g8_equip ,
     eat_g8_stat ,
     eat_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF eat_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].desc = trim (ce.result_val )
        ENDIF
       OF eat_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].act = trim (ce.result_val )
        ENDIF
       OF eat_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].ast = trim (ce.result_val )
        ENDIF
       OF eat_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].equip = trim (ce.result_val )
        ENDIF
       OF eat_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].stat = trim (ce.result_val )
        ENDIF
       OF eat_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->eat[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->eat[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g1_desc ,
     grm_g1_act ,
     grm_g1_ast ,
     grm_g1_equip ,
     grm_g1_stat ,
     grm_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g2_desc ,
     grm_g2_act ,
     grm_g2_ast ,
     grm_g2_equip ,
     grm_g2_stat ,
     grm_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g3_desc ,
     grm_g3_act ,
     grm_g3_ast ,
     grm_g3_equip ,
     grm_g3_stat ,
     grm_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g4_desc ,
     grm_g4_act ,
     grm_g4_ast ,
     grm_g4_equip ,
     grm_g4_stat ,
     grm_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g5_desc ,
     grm_g5_act ,
     grm_g5_ast ,
     grm_g5_equip ,
     grm_g5_stat ,
     grm_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g6_desc ,
     grm_g6_act ,
     grm_g6_ast ,
     grm_g6_equip ,
     grm_g6_stat ,
     grm_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g7_desc ,
     grm_g7_act ,
     grm_g7_ast ,
     grm_g7_equip ,
     grm_g7_stat ,
     grm_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (grm_g8_desc ,
     grm_g8_act ,
     grm_g8_ast ,
     grm_g8_equip ,
     grm_g8_stat ,
     grm_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF grm_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].desc = trim (ce.result_val )
        ENDIF
       OF grm_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].act = trim (ce.result_val )
        ENDIF
       OF grm_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].ast = trim (ce.result_val )
        ENDIF
       OF grm_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].equip = trim (ce.result_val )
        ENDIF
       OF grm_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].stat = trim (ce.result_val )
        ENDIF
       OF grm_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->grm[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->grm[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g1_desc ,
     ubd_g1_act ,
     ubd_g1_ast ,
     ubd_g1_equip ,
     ubd_g1_stat ,
     ubd_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g2_desc ,
     ubd_g2_act ,
     ubd_g2_ast ,
     ubd_g2_equip ,
     ubd_g2_stat ,
     ubd_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g3_desc ,
     ubd_g3_act ,
     ubd_g3_ast ,
     ubd_g3_equip ,
     ubd_g3_stat ,
     ubd_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g4_desc ,
     ubd_g4_act ,
     ubd_g4_ast ,
     ubd_g4_equip ,
     ubd_g4_stat ,
     ubd_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g5_desc ,
     ubd_g5_act ,
     ubd_g5_ast ,
     ubd_g5_equip ,
     ubd_g5_stat ,
     ubd_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g6_desc ,
     ubd_g6_act ,
     ubd_g6_ast ,
     ubd_g6_equip ,
     ubd_g6_stat ,
     ubd_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g7_desc ,
     ubd_g7_act ,
     ubd_g7_ast ,
     ubd_g7_equip ,
     ubd_g7_stat ,
     ubd_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (ubd_g8_desc ,
     ubd_g8_act ,
     ubd_g8_ast ,
     ubd_g8_equip ,
     ubd_g8_stat ,
     ubd_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF ubd_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].desc = trim (ce.result_val )
        ENDIF
       OF ubd_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].act = trim (ce.result_val )
        ENDIF
       OF ubd_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].ast = trim (ce.result_val )
        ENDIF
       OF ubd_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].equip = trim (ce.result_val )
        ENDIF
       OF ubd_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].stat = trim (ce.result_val )
        ENDIF
       OF ubd_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->ubd[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->ubd[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g1_desc ,
     lbd_g1_act ,
     lbd_g1_ast ,
     lbd_g1_equip ,
     lbd_g1_stat ,
     lbd_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g2_desc ,
     lbd_g2_act ,
     lbd_g2_ast ,
     lbd_g2_equip ,
     lbd_g2_stat ,
     lbd_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g3_desc ,
     lbd_g3_act ,
     lbd_g3_ast ,
     lbd_g3_equip ,
     lbd_g3_stat ,
     lbd_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g4_desc ,
     lbd_g4_act ,
     lbd_g4_ast ,
     lbd_g4_equip ,
     lbd_g4_stat ,
     lbd_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g5_desc ,
     lbd_g5_act ,
     lbd_g5_ast ,
     lbd_g5_equip ,
     lbd_g5_stat ,
     lbd_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g6_desc ,
     lbd_g6_act ,
     lbd_g6_ast ,
     lbd_g6_equip ,
     lbd_g6_stat ,
     lbd_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g7_desc ,
     lbd_g7_act ,
     lbd_g7_ast ,
     lbd_g7_equip ,
     lbd_g7_stat ,
     lbd_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (lbd_g8_desc ,
     lbd_g8_act ,
     lbd_g8_ast ,
     lbd_g8_equip ,
     lbd_g8_stat ,
     lbd_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF lbd_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].desc = trim (ce.result_val )
        ENDIF
       OF lbd_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].act = trim (ce.result_val )
        ENDIF
       OF lbd_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].ast = trim (ce.result_val )
        ENDIF
       OF lbd_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].equip = trim (ce.result_val )
        ENDIF
       OF lbd_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].stat = trim (ce.result_val )
        ENDIF
       OF lbd_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->lbd[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->lbd[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g1_desc ,
     bath_g1_act ,
     bath_g1_ast ,
     bath_g1_equip ,
     bath_g1_stat ,
     bath_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g2_desc ,
     bath_g2_act ,
     bath_g2_ast ,
     bath_g2_equip ,
     bath_g2_stat ,
     bath_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g3_desc ,
     bath_g3_act ,
     bath_g3_ast ,
     bath_g3_equip ,
     bath_g3_stat ,
     bath_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g4_desc ,
     bath_g4_act ,
     bath_g4_ast ,
     bath_g4_equip ,
     bath_g4_stat ,
     bath_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g5_desc ,
     bath_g5_act ,
     bath_g5_ast ,
     bath_g5_equip ,
     bath_g5_stat ,
     bath_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g6_desc ,
     bath_g6_act ,
     bath_g6_ast ,
     bath_g6_equip ,
     bath_g6_stat ,
     bath_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g7_desc ,
     bath_g7_act ,
     bath_g7_ast ,
     bath_g7_equip ,
     bath_g7_stat ,
     bath_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bath_g8_desc ,
     bath_g8_act ,
     bath_g8_ast ,
     bath_g8_equip ,
     bath_g8_stat ,
     bath_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF bath_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].desc = trim (ce.result_val )
        ENDIF
       OF bath_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].act = trim (ce.result_val )
        ENDIF
       OF bath_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].ast = trim (ce.result_val )
        ENDIF
       OF bath_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].equip = trim (ce.result_val )
        ENDIF
       OF bath_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].stat = trim (ce.result_val )
        ENDIF
       OF bath_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bath[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bath[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g1_desc ,
     toil_g1_act ,
     toil_g1_ast ,
     toil_g1_equip ,
     totr_g1_equip ,
     toil_g1_stat ,
     toil_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g1_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g2_desc ,
     toil_g2_act ,
     toil_g2_ast ,
     toil_g2_equip ,
     totr_g2_equip ,
     toil_g2_stat ,
     toil_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g2_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g3_desc ,
     toil_g3_act ,
     toil_g3_ast ,
     toil_g3_equip ,
     totr_g3_equip ,
     toil_g3_stat ,
     toil_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g3_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g4_desc ,
     toil_g4_act ,
     toil_g4_ast ,
     toil_g4_equip ,
     totr_g4_equip ,
     toil_g4_stat ,
     toil_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g4_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g5_desc ,
     toil_g5_act ,
     toil_g5_ast ,
     toil_g5_equip ,
     totr_g5_equip ,
     toil_g5_stat ,
     toil_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g5_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g6_desc ,
     toil_g6_act ,
     toil_g6_ast ,
     toil_g6_equip ,
     totr_g6_equip ,
     toil_g6_stat ,
     toil_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g6_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g7_desc ,
     toil_g7_act ,
     toil_g7_ast ,
     toil_g7_equip ,
     totr_g7_equip ,
     toil_g7_stat ,
     toil_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g7_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (toil_g8_desc ,
     toil_g8_act ,
     toil_g8_ast ,
     toil_g8_equip ,
     totr_g8_equip ,
     toil_g8_stat ,
     toil_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF toil_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].desc = trim (ce.result_val )
        ENDIF
       OF toil_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].act = trim (ce.result_val )
        ENDIF
       OF toil_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].ast = trim (ce.result_val )
        ENDIF
       OF toil_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].equip = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].equip = trim (ce.result_val )
        ENDIF
       OF totr_g8_equip :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].equip2 = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].equip2 = trim (ce.result_val )
        ENDIF
       OF toil_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].stat = trim (ce.result_val )
        ENDIF
       OF toil_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->toil[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->toil[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g1_act ,
     cog_g1_desc ,
     cog_g1_det ,
     cog_g1_stat ,
     cog_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[1 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[1 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g1_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[1 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[1 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[1 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g2_act ,
     cog_g2_desc ,
     cog_g2_det ,
     cog_g2_stat ,
     cog_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[2 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[2 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g2_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[2 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[2 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[2 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g3_act ,
     cog_g3_desc ,
     cog_g3_det ,
     cog_g3_stat ,
     cog_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[3 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[3 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g3_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[3 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[3 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[3 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g4_act ,
     cog_g4_desc ,
     cog_g4_det ,
     cog_g4_stat ,
     cog_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[4 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[4 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g4_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[4 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[4 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[4 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g5_act ,
     cog_g5_desc ,
     cog_g5_det ,
     cog_g5_stat ,
     cog_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[5 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[5 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g5_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[5 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[5 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[5 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g6_act ,
     cog_g6_desc ,
     cog_g6_det ,
     cog_g6_stat ,
     cog_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[6 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[6 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g6_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[6 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[6 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[6 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g7_act ,
     cog_g7_desc ,
     cog_g7_det ,
     cog_g7_stat ,
     cog_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[7 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[7 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g7_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[7 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[7 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[7 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (cog_g8_act ,
     cog_g8_desc ,
     cog_g8_det ,
     cog_g8_stat ,
     cog_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF cog_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[8 ].act = trim (ce.result_val )
        ENDIF
       OF cog_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[8 ].desc = trim (ce.result_val )
        ENDIF
       OF cog_g8_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[8 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[8 ].det = trim (ce.result_val )
        ENDIF
       OF cog_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[8 ].stat = trim (ce.result_val )
        ENDIF
       OF cog_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->cog[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->cog[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g1_act ,
     iadl_g1_desc ,
     iadl_g1_ast ,
     iadl_g1_det ,
     iadl_g1_stat ,
     iadl_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g1_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g1_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g2_act ,
     iadl_g2_desc ,
     iadl_g2_ast ,
     iadl_g2_det ,
     iadl_g2_stat ,
     iadl_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g2_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g2_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g3_act ,
     iadl_g3_desc ,
     iadl_g3_ast ,
     iadl_g3_det ,
     iadl_g3_stat ,
     iadl_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g3_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g3_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g4_act ,
     iadl_g4_desc ,
     iadl_g4_ast ,
     iadl_g4_det ,
     iadl_g4_stat ,
     iadl_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g4_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g4_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g5_act ,
     iadl_g5_desc ,
     iadl_g5_ast ,
     iadl_g5_det ,
     iadl_g5_stat ,
     iadl_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g5_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g5_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g6_act ,
     iadl_g6_desc ,
     iadl_g6_ast ,
     iadl_g6_det ,
     iadl_g6_stat ,
     iadl_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g6_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g6_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g7_act ,
     iadl_g7_desc ,
     iadl_g7_ast ,
     iadl_g7_det ,
     iadl_g7_stat ,
     iadl_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g7_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g7_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (iadl_g8_act ,
     iadl_g8_desc ,
     iadl_g8_ast ,
     iadl_g8_det ,
     iadl_g8_stat ,
     iadl_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF iadl_g8_act :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].act = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].act = trim (ce.result_val )
        ENDIF
       OF iadl_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].desc = trim (ce.result_val )
        ENDIF
       OF iadl_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].ast = trim (ce.result_val )
        ENDIF
       OF iadl_g8_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].det = trim (ce.result_val )
        ENDIF
       OF iadl_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].stat = trim (ce.result_val )
        ENDIF
       OF iadl_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->iadl[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->iadl[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g1_desc ,
     otbal_g1_type ,
     otbal_g1_ast ,
     otbal_g1_dev ,
     otbal_g1_ltm ,
     otbal_g1_rat ,
     otbal_g1_stat ,
     otbal_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g1_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g1_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g1_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g1_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g2_desc ,
     otbal_g2_type ,
     otbal_g2_ast ,
     otbal_g2_dev ,
     otbal_g2_ltm ,
     otbal_g2_rat ,
     otbal_g2_stat ,
     otbal_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g2_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g2_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g2_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g2_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g3_desc ,
     otbal_g3_type ,
     otbal_g3_ast ,
     otbal_g3_dev ,
     otbal_g3_ltm ,
     otbal_g3_rat ,
     otbal_g3_stat ,
     otbal_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g3_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g3_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g3_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g3_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g4_desc ,
     otbal_g4_type ,
     otbal_g4_ast ,
     otbal_g4_dev ,
     otbal_g4_ltm ,
     otbal_g4_rat ,
     otbal_g4_stat ,
     otbal_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g4_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g4_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g4_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g4_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g5_desc ,
     otbal_g5_type ,
     otbal_g5_ast ,
     otbal_g5_dev ,
     otbal_g5_ltm ,
     otbal_g5_rat ,
     otbal_g5_stat ,
     otbal_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g5_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g5_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g5_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g5_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g6_desc ,
     otbal_g6_type ,
     otbal_g6_ast ,
     otbal_g6_dev ,
     otbal_g6_ltm ,
     otbal_g6_rat ,
     otbal_g6_stat ,
     otbal_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g6_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g6_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g6_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g6_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g7_desc ,
     otbal_g7_type ,
     otbal_g7_ast ,
     otbal_g7_dev ,
     otbal_g7_ltm ,
     otbal_g7_rat ,
     otbal_g7_stat ,
     otbal_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g7_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g7_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g7_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g7_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (otbal_g8_desc ,
     otbal_g8_type ,
     otbal_g8_ast ,
     otbal_g8_dev ,
     otbal_g8_ltm ,
     otbal_g8_rat ,
     otbal_g8_stat ,
     otbal_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF otbal_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].desc = trim (ce.result_val )
        ENDIF
       OF otbal_g8_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].type = trim (ce.result_val )
        ENDIF
       OF otbal_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].ast = trim (ce.result_val )
        ENDIF
       OF otbal_g8_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].dev = trim (ce.result_val )
        ENDIF
       OF otbal_g8_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].ltm = trim (ce.result_val )
        ENDIF
       OF otbal_g8_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].rat = trim (ce.result_val )
        ENDIF
       OF otbal_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].stat = trim (ce.result_val )
        ENDIF
       OF otbal_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->otbal[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->otbal[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g1 ,
     oth_g1_stat ,
     oth_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g1 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[1 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[1 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[1 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g2 ,
     oth_g2_stat ,
     oth_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g2 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[2 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[2 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[2 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g3 ,
     oth_g3_stat ,
     oth_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g3 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[3 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[3 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[3 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g4 ,
     oth_g4_stat ,
     oth_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g4 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[4 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[4 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[4 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g5 ,
     oth_g5_stat ,
     oth_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g5 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[5 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[5 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[5 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g6 ,
     oth_g6_stat ,
     oth_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g6 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[6 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[6 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[6 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g7 ,
     oth_g7_stat ,
     oth_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g7 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[7 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[7 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[7 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (oth_g8 ,
     oth_g8_stat ,
     oth_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF oth_g8 :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[8 ].goal = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[8 ].goal = trim (ce.result_val )
        ENDIF
       OF oth_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[8 ].stat = trim (ce.result_val )
        ENDIF
       OF oth_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->oth[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->oth[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce.event_end_dt_tm
   IF ((first_dttm = "Y" ) ) first_dttm = "N"
   ENDIF
  WITH nocounter
 ;end select
 IF ((curqual = 0 ) )
  SET reply->text = concat (reply->text ,rhead ,wbu ,"OT Short Term Goals" ,wr ,reol ,reol ,wr ,
   "No qualifying data available" ,reol )
  GO TO exit_script
 ENDIF
 SET reply->text = concat (reply->text ,rhead ,wbu ,"OT Short Term Goals" ,reol ,reol )
 SET reply->text = concat (reply->text ,wr ,format (ce_event_end_dt_tm ,"MM/DD/YYYY;;D" ) ,reol )
 FOR (a = 1 TO 8 )
  IF ((((out->eat[a ].act > "" ) ) OR ((((out->eat[a ].desc > "" ) ) OR ((((out->eat[a ].ast > "" )
  ) OR ((((out->eat[a ].equip > "" ) ) OR ((((out->eat[a ].stat > "" ) ) OR ((out->eat[a ].cmt > ""
  ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Eating Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->eat[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->eat[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->eat[a ].desc )
    ENDIF
   ENDIF
   IF ((out->eat[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->eat[a ].ast )
    ENDIF
   ENDIF
   IF ((out->eat[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->eat[a ].equip )
    ENDIF
   ENDIF
   IF ((out->eat[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->eat[a ].stat )
    ENDIF
   ENDIF
   IF ((out->eat[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->eat[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->eat[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->grm[a ].act > "" ) ) OR ((((out->grm[a ].desc > "" ) ) OR ((((out->grm[a ].ast > "" )
  ) OR ((((out->grm[a ].equip > "" ) ) OR ((((out->grm[a ].stat > "" ) ) OR ((out->grm[a ].cmt > ""
  ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Grooming Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->grm[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->grm[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->grm[a ].desc )
    ENDIF
   ENDIF
   IF ((out->grm[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->grm[a ].ast )
    ENDIF
   ENDIF
   IF ((out->grm[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->grm[a ].equip )
    ENDIF
   ENDIF
   IF ((out->grm[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->grm[a ].stat )
    ENDIF
   ENDIF
   IF ((out->grm[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->grm[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->grm[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->ubd[a ].act > "" ) ) OR ((((out->ubd[a ].desc > "" ) ) OR ((((out->ubd[a ].ast > "" )
  ) OR ((((out->ubd[a ].equip > "" ) ) OR ((((out->ubd[a ].stat > "" ) ) OR ((out->ubd[a ].cmt > ""
  ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Upper Body Dressing Goal #" ,cnvtstring (a ,1 ,0 ,l )
    ,":" )
   IF ((out->ubd[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->ubd[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->ubd[a ].desc )
    ENDIF
   ENDIF
   IF ((out->ubd[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->ubd[a ].ast )
    ENDIF
   ENDIF
   IF ((out->ubd[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->ubd[a ].equip )
    ENDIF
   ENDIF
   IF ((out->ubd[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->ubd[a ].stat )
    ENDIF
   ENDIF
   IF ((out->ubd[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->ubd[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->ubd[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->lbd[a ].act > "" ) ) OR ((((out->lbd[a ].desc > "" ) ) OR ((((out->lbd[a ].ast > "" )
  ) OR ((((out->lbd[a ].equip > "" ) ) OR ((((out->lbd[a ].stat > "" ) ) OR ((out->lbd[a ].cmt > ""
  ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Lower Body Dressing Goal #" ,cnvtstring (a ,1 ,0 ,l )
    ,":" )
   IF ((out->lbd[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->lbd[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->lbd[a ].desc )
    ENDIF
   ENDIF
   IF ((out->lbd[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->lbd[a ].ast )
    ENDIF
   ENDIF
   IF ((out->lbd[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->lbd[a ].equip )
    ENDIF
   ENDIF
   IF ((out->lbd[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->lbd[a ].stat )
    ENDIF
   ENDIF
   IF ((out->lbd[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->lbd[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->lbd[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->bath[a ].act > "" ) ) OR ((((out->bath[a ].desc > "" ) ) OR ((((out->bath[a ].ast > ""
  ) ) OR ((((out->bath[a ].equip > "" ) ) OR ((((out->bath[a ].stat > "" ) ) OR ((out->bath[a ].cmt
  > "" ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Bathing Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->bath[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->bath[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bath[a ].desc )
    ENDIF
   ENDIF
   IF ((out->bath[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bath[a ].ast )
    ENDIF
   ENDIF
   IF ((out->bath[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bath[a ].equip )
    ENDIF
   ENDIF
   IF ((out->bath[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bath[a ].stat )
    ENDIF
   ENDIF
   IF ((out->bath[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bath[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bath[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->toil[a ].act > "" ) ) OR ((((out->toil[a ].desc > "" ) ) OR ((((out->toil[a ].ast > ""
  ) ) OR ((((out->toil[a ].equip > "" ) ) OR ((((out->toil[a ].equip2 > "" ) ) OR ((((out->toil[a ].
  stat > "" ) ) OR ((out->toil[a ].cmt > "" ) )) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Toileting and Transfers Goal #" ,cnvtstring (a ,1 ,0 ,
     l ) ,":" )
   IF ((out->toil[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->toil[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].desc )
    ENDIF
   ENDIF
   IF ((out->toil[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].ast )
    ENDIF
   ENDIF
   IF ((out->toil[a ].equip > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].equip )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].equip )
    ENDIF
   ENDIF
   IF ((out->toil[a ].equip2 > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].equip2 )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].equip2 )
    ENDIF
   ENDIF
   IF ((out->toil[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].stat )
    ENDIF
   ENDIF
   IF ((out->toil[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->toil[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->toil[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->cog[a ].act > "" ) ) OR ((((out->cog[a ].desc > "" ) ) OR ((((out->cog[a ].det > "" )
  ) OR ((((out->cog[a ].stat > "" ) ) OR ((out->cog[a ].cmt > "" ) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Cognition/Vision/Perception Goal #" ,cnvtstring (a ,1
     ,0 ,l ) ,":" )
   IF ((out->cog[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->cog[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->cog[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->cog[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->cog[a ].desc )
    ENDIF
   ENDIF
   IF ((out->cog[a ].det > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->cog[a ].det )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->cog[a ].det )
    ENDIF
   ENDIF
   IF ((out->cog[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->cog[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->cog[a ].stat )
    ENDIF
   ENDIF
   IF ((out->cog[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->cog[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->cog[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->iadl[a ].act > "" ) ) OR ((((out->iadl[a ].desc > "" ) ) OR ((((out->iadl[a ].ast > ""
  ) ) OR ((((out->iadl[a ].det > "" ) ) OR ((((out->iadl[a ].stat > "" ) ) OR ((out->iadl[a ].cmt >
  "" ) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"IADL Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->iadl[a ].act > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].act )
    SET first = "N"
   ENDIF
   IF ((out->iadl[a ].desc > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].desc )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->iadl[a ].desc )
    ENDIF
   ENDIF
   IF ((out->iadl[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->iadl[a ].ast )
    ENDIF
   ENDIF
   IF ((out->iadl[a ].det > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].det )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->iadl[a ].det )
    ENDIF
   ENDIF
   IF ((out->iadl[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->iadl[a ].stat )
    ENDIF
   ENDIF
   IF ((out->iadl[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->iadl[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->iadl[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->otbal[a ].desc > "" ) ) OR ((((out->otbal[a ].type > "" ) ) OR ((((out->otbal[a ].ast
  > "" ) ) OR ((((out->otbal[a ].dev > "" ) ) OR ((((out->otbal[a ].ltm > "" ) ) OR ((((out->otbal[a
  ].rat > "" ) ) OR ((((out->otbal[a ].stat > "" ) ) OR ((out->otbal[a ].cmt > "" ) )) )) )) )) ))
  )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Balance Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->otbal[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->otbal[a ].type > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].type )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].type )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].ast )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].dev > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].dev )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].dev )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].ltm > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].ltm )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].ltm )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].rat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].rat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].rat )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].stat )
    ENDIF
   ENDIF
   IF ((out->otbal[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->otbal[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->otbal[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->oth[a ].goal > "" ) ) OR ((((out->oth[a ].stat > "" ) ) OR ((out->oth[a ].cmt > "" )
  )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Other Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->oth[a ].goal > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->oth[a ].goal )
    SET first = "N"
   ENDIF
   IF ((out->oth[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->oth[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->oth[a ].stat )
    ENDIF
   ENDIF
   IF ((out->oth[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->oth[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->oth[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
#exit_script
 SET reply->text = concat (reply->text ,rtfeof )
 SET script_version = "005 02/16/2017 NT5990"
END GO
 

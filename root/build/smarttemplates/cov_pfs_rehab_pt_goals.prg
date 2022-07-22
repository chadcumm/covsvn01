DROP PROGRAM cov_pfs_rehab_pt_goals :dba GO
CREATE PROGRAM cov_pfs_rehab_pt_goals :dba
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
   1 bdm [* ]
     2 desc = vc
     2 lvl = vc
     2 add = vc
     2 stat = vc
     2 cmt = vc
   1 tfr [* ]
     2 desc = vc
     2 lvl = vc
     2 dev = vc
     2 stat = vc
     2 cmt = vc
   1 amb [* ]
     2 desc = vc
     2 lvl = vc
     2 dist = vc
     2 dev = vc
     2 stat = vc
     2 cmt = vc
   1 wcm [* ]
     2 desc = vc
     2 lvl = vc
     2 dist = vc
     2 det = vc
     2 stat = vc
     2 cmt = vc
   1 bal [* ]
     2 desc = vc
     2 ast = vc
     2 type = vc
     2 dev = vc
     2 ltm = vc
     2 rat = vc
     2 stat = vc
     2 cmt = vc
   1 oth [* ]
     2 goal = vc
     2 stat = vc
     2 cmt = vc
   1 rom[*]
   	 2 desc	=	vc
   	 2 astlvl =	vc
   	 2 rng	=	vc
   	 2 rat  = vc
   	 2 tmfrm = vc
   	 2 stat = vc
   	 2 dtmet = vc
   	 2 comm = vc
 )
 DECLARE ce_event_end_dt_tm = dq8 WITH public
 DECLARE first_dttm = c1 WITH public ,noconstant (" " )
 DECLARE auth = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE modified = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) ) ,protect
 DECLARE altered = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) ) ,protect
 DECLARE bdm_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11158" ) )
 DECLARE bdm_g1_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11159" ) )
 DECLARE bdm_g1_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11160" ) )
 DECLARE bdm_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11161" ) )
 DECLARE bdm_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11310" ) )
 DECLARE bdm_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11162" ) )
 DECLARE bdm_g2_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11163" ) )
 DECLARE bdm_g2_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11164" ) )
 DECLARE bdm_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11165" ) )
 DECLARE bdm_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11311" ) )
 DECLARE bdm_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11166" ) )
 DECLARE bdm_g3_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11167" ) )
 DECLARE bdm_g3_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11168" ) )
 DECLARE bdm_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11169" ) )
 DECLARE bdm_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11312" ) )
 DECLARE bdm_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11170" ) )
 DECLARE bdm_g4_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11171" ) )
 DECLARE bdm_g4_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11172" ) )
 DECLARE bdm_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11173" ) )
 DECLARE bdm_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11313" ) )
 DECLARE bdm_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11174" ) )
 DECLARE bdm_g5_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11175" ) )
 DECLARE bdm_g5_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11176" ) )
 DECLARE bdm_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11177" ) )
 DECLARE bdm_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11314" ) )
 DECLARE bdm_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11178" ) )
 DECLARE bdm_g6_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11179" ) )
 DECLARE bdm_g6_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11180" ) )
 DECLARE bdm_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11181" ) )
 DECLARE bdm_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11315" ) )
 DECLARE bdm_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11182" ) )
 DECLARE bdm_g7_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11183" ) )
 DECLARE bdm_g7_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11184" ) )
 DECLARE bdm_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11185" ) )
 DECLARE bdm_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11316" ) )
 DECLARE bdm_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11186" ) )
 DECLARE bdm_g8_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11187" ) )
 DECLARE bdm_g8_add = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11188" ) )
 DECLARE bdm_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11189" ) )
 DECLARE bdm_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11317" ) )
 DECLARE tfr_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11190" ) )
 DECLARE tfr_g1_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11191" ) )
 DECLARE tfr_g1_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11192" ) )
 DECLARE tfr_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11193" ) )
 DECLARE tfr_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11318" ) )
 DECLARE tfr_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11194" ) )
 DECLARE tfr_g2_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11195" ) )
 DECLARE tfr_g2_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11196" ) )
 DECLARE tfr_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11197" ) )
 DECLARE tfr_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11319" ) )
 DECLARE tfr_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11198" ) )
 DECLARE tfr_g3_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11199" ) )
 DECLARE tfr_g3_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11200" ) )
 DECLARE tfr_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11201" ) )
 DECLARE tfr_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11320" ) )
 DECLARE tfr_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11202" ) )
 DECLARE tfr_g4_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11203" ) )
 DECLARE tfr_g4_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11204" ) )
 DECLARE tfr_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11205" ) )
 DECLARE tfr_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11321" ) )
 DECLARE tfr_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11206" ) )
 DECLARE tfr_g5_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11207" ) )
 DECLARE tfr_g5_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11208" ) )
 DECLARE tfr_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11209" ) )
 DECLARE tfr_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11322" ) )
 DECLARE tfr_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11210" ) )
 DECLARE tfr_g6_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11211" ) )
 DECLARE tfr_g6_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11212" ) )
 DECLARE tfr_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11213" ) )
 DECLARE tfr_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11323" ) )
 DECLARE tfr_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11214" ) )
 DECLARE tfr_g7_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11215" ) )
 DECLARE tfr_g7_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11216" ) )
 DECLARE tfr_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11217" ) )
 DECLARE tfr_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11324" ) )
 DECLARE tfr_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11218" ) )
 DECLARE tfr_g8_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11219" ) )
 DECLARE tfr_g8_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11220" ) )
 DECLARE tfr_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11221" ) )
 DECLARE tfr_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11325" ) )
 DECLARE amb_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11222" ) )
 DECLARE amb_g1_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11223" ) )
 DECLARE amb_g1_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11224" ) )
 DECLARE amb_g1_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11225" ) )
 DECLARE amb_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11226" ) )
 DECLARE amb_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11326" ) )
 DECLARE amb_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11227" ) )
 DECLARE amb_g2_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11228" ) )
 DECLARE amb_g2_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11229" ) )
 DECLARE amb_g2_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11230" ) )
 DECLARE amb_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11231" ) )
 DECLARE amb_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11327" ) )
 DECLARE amb_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11232" ) )
 DECLARE amb_g3_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11233" ) )
 DECLARE amb_g3_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11234" ) )
 DECLARE amb_g3_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11235" ) )
 DECLARE amb_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11236" ) )
 DECLARE amb_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11328" ) )
 DECLARE amb_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11237" ) )
 DECLARE amb_g4_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11238" ) )
 DECLARE amb_g4_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11239" ) )
 DECLARE amb_g4_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11240" ) )
 DECLARE amb_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11241" ) )
 DECLARE amb_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11329" ) )
 DECLARE amb_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11242" ) )
 DECLARE amb_g5_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11243" ) )
 DECLARE amb_g5_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11244" ) )
 DECLARE amb_g5_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11245" ) )
 DECLARE amb_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11246" ) )
 DECLARE amb_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11330" ) )
 DECLARE amb_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11247" ) )
 DECLARE amb_g6_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11248" ) )
 DECLARE amb_g6_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11249" ) )
 DECLARE amb_g6_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11250" ) )
 DECLARE amb_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11251" ) )
 DECLARE amb_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11331" ) )
 DECLARE amb_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11252" ) )
 DECLARE amb_g7_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11253" ) )
 DECLARE amb_g7_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11254" ) )
 DECLARE amb_g7_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11255" ) )
 DECLARE amb_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11256" ) )
 DECLARE amb_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11332" ) )
 DECLARE amb_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11257" ) )
 DECLARE amb_g8_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11258" ) )
 DECLARE amb_g8_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11259" ) )
 DECLARE amb_g8_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11260" ) )
 DECLARE amb_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11261" ) )
 DECLARE amb_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11333" ) )
 DECLARE wcm_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11262" ) )
 DECLARE wcm_g1_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11263" ) )
 DECLARE wcm_g1_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11264" ) )
 DECLARE wcm_g1_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14140" ) )
 DECLARE wcm_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11265" ) )
 DECLARE wcm_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11334" ) )
 DECLARE wcm_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11266" ) )
 DECLARE wcm_g2_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11267" ) )
 DECLARE wcm_g2_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11268" ) )
 DECLARE wcm_g2_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14141" ) )
 DECLARE wcm_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11269" ) )
 DECLARE wcm_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11335" ) )
 DECLARE wcm_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11270" ) )
 DECLARE wcm_g3_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11271" ) )
 DECLARE wcm_g3_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11272" ) )
 DECLARE wcm_g3_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14142" ) )
 DECLARE wcm_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11273" ) )
 DECLARE wcm_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11336" ) )
 DECLARE wcm_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11274" ) )
 DECLARE wcm_g4_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11275" ) )
 DECLARE wcm_g4_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11276" ) )
 DECLARE wcm_g4_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14143" ) )
 DECLARE wcm_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11277" ) )
 DECLARE wcm_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11337" ) )
 DECLARE wcm_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11278" ) )
 DECLARE wcm_g5_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11279" ) )
 DECLARE wcm_g5_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11280" ) )
 DECLARE wcm_g5_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14144" ) )
 DECLARE wcm_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11281" ) )
 DECLARE wcm_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11338" ) )
 DECLARE wcm_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11282" ) )
 DECLARE wcm_g6_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11283" ) )
 DECLARE wcm_g6_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11284" ) )
 DECLARE wcm_g6_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14145" ) )
 DECLARE wcm_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11285" ) )
 DECLARE wcm_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11339" ) )
 DECLARE wcm_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11286" ) )
 DECLARE wcm_g7_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11287" ) )
 DECLARE wcm_g7_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11288" ) )
 DECLARE wcm_g7_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14146" ) )
 DECLARE wcm_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11289" ) )
 DECLARE wcm_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11340" ) )
 DECLARE wcm_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11290" ) )
 DECLARE wcm_g8_lvl = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11291" ) )
 DECLARE wcm_g8_dist = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11292" ) )
 DECLARE wcm_g8_det = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14147" ) )
 DECLARE wcm_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11293" ) )
 DECLARE wcm_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11341" ) )
 DECLARE bal_g1_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11498" ) )
 DECLARE bal_g2_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11499" ) )
 DECLARE bal_g3_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11500" ) )
 DECLARE bal_g4_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11501" ) )
 DECLARE bal_g1_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11502" ) )
 DECLARE bal_g2_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11503" ) )
 DECLARE bal_g3_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11504" ) )
 DECLARE bal_g4_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11505" ) )
 DECLARE bal_g1_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11506" ) )
 DECLARE bal_g2_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11507" ) )
 DECLARE bal_g3_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11508" ) )
 DECLARE bal_g4_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11509" ) )
 DECLARE bal_g1_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11510" ) )
 DECLARE bal_g2_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11511" ) )
 DECLARE bal_g3_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11512" ) )
 DECLARE bal_g4_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11513" ) )
 DECLARE bal_g1_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11514" ) )
 DECLARE bal_g2_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11515" ) )
 DECLARE bal_g3_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11516" ) )
 DECLARE bal_g4_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11517" ) )
 DECLARE bal_g1_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11518" ) )
 DECLARE bal_g2_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11519" ) )
 DECLARE bal_g3_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11520" ) )
 DECLARE bal_g4_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11521" ) )
 DECLARE bal_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11522" ) )
 DECLARE bal_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11523" ) )
 DECLARE bal_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11524" ) )
 DECLARE bal_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11525" ) )
 DECLARE bal_g5_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11573" ) )
 DECLARE bal_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11574" ) )
 DECLARE bal_g5_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11575" ) )
 DECLARE bal_g5_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11576" ) )
 DECLARE bal_g5_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11577" ) )
 DECLARE bal_g5_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11578" ) )
 DECLARE bal_g5_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11579" ) )
 DECLARE bal_g6_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11580" ) )
 DECLARE bal_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11581" ) )
 DECLARE bal_g6_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11582" ) )
 DECLARE bal_g6_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11583" ) )
 DECLARE bal_g6_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11584" ) )
 DECLARE bal_g6_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11585" ) )
 DECLARE bal_g6_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11586" ) )
 DECLARE bal_g7_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11587" ) )
 DECLARE bal_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11588" ) )
 DECLARE bal_g7_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11589" ) )
 DECLARE bal_g7_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11590" ) )
 DECLARE bal_g7_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11591" ) )
 DECLARE bal_g7_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11592" ) )
 DECLARE bal_g7_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11593" ) )
 DECLARE bal_g8_ast = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11594" ) )
 DECLARE bal_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11595" ) )
 DECLARE bal_g8_desc = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11596" ) )
 DECLARE bal_g8_dev = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11597" ) )
 DECLARE bal_g8_ltm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11598" ) )
 DECLARE bal_g8_rat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11599" ) )
 DECLARE bal_g8_type = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11600" ) )
 DECLARE bal_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12138" ) )
 DECLARE bal_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12140" ) )
 DECLARE bal_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12142" ) )
 DECLARE bal_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12144" ) )
 DECLARE bal_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12146" ) )
 DECLARE bal_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12148" ) )
 DECLARE bal_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12150" ) )
 DECLARE bal_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12152" ) )
 DECLARE oth_g1 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11294" ) )
 DECLARE oth_g1_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11295" ) )
 DECLARE oth_g1_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11342" ) )
 DECLARE oth_g2 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11296" ) )
 DECLARE oth_g2_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11297" ) )
 DECLARE oth_g2_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11343" ) )
 DECLARE oth_g3 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11298" ) )
 DECLARE oth_g3_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11299" ) )
 DECLARE oth_g3_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11344" ) )
 DECLARE oth_g4 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11300" ) )
 DECLARE oth_g4_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11301" ) )
 DECLARE oth_g4_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11345" ) )
 DECLARE oth_g5 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11302" ) )
 DECLARE oth_g5_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11303" ) )
 DECLARE oth_g5_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11346" ) )
 DECLARE oth_g6 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11304" ) )
 DECLARE oth_g6_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11305" ) )
 DECLARE oth_g6_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11347" ) )
 DECLARE oth_g7 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11306" ) )
 DECLARE oth_g7_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11307" ) )
 DECLARE oth_g7_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11348" ) )
 DECLARE oth_g8 = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11308" ) )
 DECLARE oth_g8_stat = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11309" ) )
 DECLARE oth_g8_cmt = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!11349" ) )
 
 ;CR951 Updates Below
 DECLARE rom_g1_desc = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'ROMGOAL1DESCRIPTOR')), PROTECT
 DECLARE rom_g1_astlvl = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'ROMGOAL1ASSISTLEVEL')), PROTECT
 
 
 
 CALL ECHO(BUILD('rom_g1_desc :', rom_g1_desc))
 CALL ECHO(BUILD('rom_g1_astlvl :', rom_g1_astlvl))
 
; GO TO exit_script
 
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
  IF ((ce.event_cd IN (bdm_g1_stat ,
  bdm_g2_stat ,
  bdm_g3_stat ,
  bdm_g4_stat ,
  bdm_g5_stat ,
  bdm_g6_stat ,
  bdm_g7_stat ,
  bdm_g8_stat ,
  tfr_g1_stat ,
  tfr_g2_stat ,
  tfr_g3_stat ,
  tfr_g4_stat ,
  tfr_g5_stat ,
  tfr_g6_stat ,
  tfr_g7_stat ,
  tfr_g8_stat ,
  amb_g1_stat ,
  amb_g2_stat ,
  amb_g3_stat ,
  amb_g4_stat ,
  amb_g5_stat ,
  amb_g6_stat ,
  amb_g7_stat ,
  amb_g8_stat ,
  wcm_g1_stat ,
  wcm_g2_stat ,
  wcm_g3_stat ,
  wcm_g4_stat ,
  wcm_g5_stat ,
  wcm_g6_stat ,
  wcm_g7_stat ,
  wcm_g8_stat ,
  bal_g1_stat ,
  bal_g2_stat ,
  bal_g3_stat ,
  bal_g4_stat ,
  bal_g5_stat ,
  bal_g6_stat ,
  bal_g7_stat ,
  bal_g8_stat ,
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
   AND (((ce.event_cd IN (bdm_g1_desc ,
   bdm_g1_lvl ,
   bdm_g1_add ,
   bdm_g1_stat ,
   bdm_g1_cmt ,
   bdm_g2_desc ,
   bdm_g2_lvl ,
   bdm_g2_add ,
   bdm_g2_stat ,
   bdm_g2_cmt ,
   bdm_g3_desc ,
   bdm_g3_lvl ,
   bdm_g3_add ,
   bdm_g3_stat ,
   bdm_g3_cmt ,
   bdm_g4_desc ,
   bdm_g4_lvl ,
   bdm_g4_add ,
   bdm_g4_stat ,
   bdm_g4_cmt ,
   bdm_g5_desc ,
   bdm_g5_lvl ,
   bdm_g5_add ,
   bdm_g5_stat ,
   bdm_g5_cmt ,
   bdm_g6_desc ,
   bdm_g6_lvl ,
   bdm_g6_add ,
   bdm_g6_stat ,
   bdm_g6_cmt ,
   bdm_g7_desc ,
   bdm_g7_lvl ,
   bdm_g7_add ,
   bdm_g7_stat ,
   bdm_g7_cmt ,
   bdm_g8_desc ,
   bdm_g8_lvl ,
   bdm_g8_add ,
   bdm_g8_stat ,
   bdm_g8_cmt ,
   tfr_g1_desc ,
   tfr_g1_lvl ,
   tfr_g1_dev ,
   tfr_g1_stat ,
   tfr_g1_cmt ,
   tfr_g2_desc ,
   tfr_g2_lvl ,
   tfr_g2_dev ,
   tfr_g2_stat ,
   tfr_g2_cmt ,
   tfr_g3_desc ,
   tfr_g3_lvl ,
   tfr_g3_dev ,
   tfr_g3_stat ,
   tfr_g3_cmt ,
   tfr_g4_desc ,
   tfr_g4_lvl ,
   tfr_g4_dev ,
   tfr_g4_stat ,
   tfr_g4_cmt ,
   tfr_g5_desc ,
   tfr_g5_lvl ,
   tfr_g5_dev ,
   tfr_g5_stat ,
   tfr_g5_cmt ,
   tfr_g6_desc ,
   tfr_g6_lvl ,
   tfr_g6_dev ,
   tfr_g6_stat ,
   tfr_g6_cmt ,
   tfr_g7_desc ,
   tfr_g7_lvl ,
   tfr_g7_dev ,
   tfr_g7_stat ,
   tfr_g7_cmt ,
   tfr_g8_desc ,
   tfr_g8_lvl ,
   tfr_g8_dev ,
   tfr_g8_stat ,
   tfr_g8_cmt ,
   amb_g1_desc ,
   amb_g1_lvl ,
   amb_g1_dist ,
   amb_g1_dev ,
   amb_g1_stat ,
   amb_g1_cmt ,
   amb_g2_desc ,
   amb_g2_lvl ,
   amb_g2_dist ,
   amb_g2_dev ,
   amb_g2_stat ,
   amb_g2_cmt ,
   amb_g3_desc ,
   amb_g3_lvl ,
   amb_g3_dist ,
   amb_g3_dev ,
   amb_g3_stat ,
   amb_g3_cmt ,
   amb_g4_desc ,
   amb_g4_lvl ,
   amb_g4_dist ,
   amb_g4_dev ,
   amb_g4_stat ,
   amb_g4_cmt ,
   amb_g5_desc ,
   amb_g5_lvl ,
   amb_g5_dist ,
   amb_g5_dev ,
   amb_g5_stat ,
   amb_g5_cmt ,
   amb_g6_desc ,
   amb_g6_lvl ,
   amb_g6_dist ,
   amb_g6_dev ,
   amb_g6_stat ,
   amb_g6_cmt ,
   amb_g7_desc ,
   amb_g7_lvl ,
   amb_g7_dist ,
   amb_g7_dev ,
   amb_g7_stat ,
   amb_g7_cmt ,
   amb_g8_desc ,
   amb_g8_lvl ,
   amb_g8_dist ,
   amb_g8_dev ,
   amb_g8_stat ,
   amb_g8_cmt ,
   wcm_g1_desc ,
   wcm_g1_lvl ,
   wcm_g1_dist ,
   wcm_g1_det ,
   wcm_g1_stat ,
   wcm_g1_cmt ,
   wcm_g2_desc ,
   wcm_g2_lvl ,
   wcm_g2_dist ,
   wcm_g2_det ,
   wcm_g2_stat ,
   wcm_g2_cmt ,
   wcm_g3_desc ,
   wcm_g3_lvl ,
   wcm_g3_dist ,
   wcm_g3_det ,
   wcm_g3_stat ,
   wcm_g3_cmt ,
   wcm_g4_desc ,
   wcm_g4_lvl ,
   wcm_g4_dist ,
   wcm_g4_det ,
   wcm_g4_stat ,
   wcm_g4_cmt ,
   wcm_g5_desc ,
   wcm_g5_lvl ,
   wcm_g5_dist ,
   wcm_g5_det ,
   wcm_g5_stat ,
   wcm_g5_cmt ,
   wcm_g6_desc ,
   wcm_g6_lvl ,
   wcm_g6_dist ,
   wcm_g6_det ,
   wcm_g6_stat ,
   wcm_g6_cmt ,
   wcm_g7_desc ,
   wcm_g7_lvl ,
   wcm_g7_dist ,
   wcm_g7_det ,
   wcm_g7_stat ,
   wcm_g7_cmt ,
   wcm_g8_desc ,
   wcm_g8_lvl ,
   wcm_g8_dist ,
   wcm_g8_det ,
   wcm_g8_stat ,
   wcm_g8_cmt ) ) ) OR ((ce.event_cd IN (bal_g1_desc ,
   bal_g1_type ,
   bal_g1_ast ,
   bal_g1_dev ,
   bal_g1_ltm ,
   bal_g1_rat ,
   bal_g1_stat ,
   bal_g1_cmt ,
   bal_g2_desc ,
   bal_g2_type ,
   bal_g2_ast ,
   bal_g2_dev ,
   bal_g2_ltm ,
   bal_g2_rat ,
   bal_g2_stat ,
   bal_g2_cmt ,
   bal_g3_desc ,
   bal_g3_type ,
   bal_g3_ast ,
   bal_g3_dev ,
   bal_g3_ltm ,
   bal_g3_rat ,
   bal_g3_stat ,
   bal_g3_cmt ,
   bal_g4_desc ,
   bal_g4_type ,
   bal_g4_ast ,
   bal_g4_dev ,
   bal_g4_ltm ,
   bal_g4_rat ,
   bal_g4_stat ,
   bal_g4_cmt ,
   bal_g5_desc ,
   bal_g5_type ,
   bal_g5_ast ,
   bal_g5_dev ,
   bal_g5_ltm ,
   bal_g5_rat ,
   bal_g5_stat ,
   bal_g5_cmt ,
   bal_g6_desc ,
   bal_g6_type ,
   bal_g6_ast ,
   bal_g6_dev ,
   bal_g6_ltm ,
   bal_g6_rat ,
   bal_g6_stat ,
   bal_g6_cmt ,
   bal_g7_desc ,
   bal_g7_type ,
   bal_g7_ast ,
   bal_g7_dev ,
   bal_g7_ltm ,
   bal_g7_rat ,
   bal_g7_stat ,
   bal_g7_cmt ,
   bal_g8_desc ,
   bal_g8_type ,
   bal_g8_ast ,
   bal_g8_dev ,
   bal_g8_ltm ,
   bal_g8_rat ,
   bal_g8_stat ,
   bal_g8_cmt ,
   oth_g1 ,
   oth_g1_stat ,
   oth_g1_cmt ,
   oth_g2 ,
   oth_g2_stat ,
   oth_g2_cmt ,
   oth_g3 ,
   oth_g3_stat ,
   oth_g3_cmt ,
   oth_g4 ,
   oth_g4_stat ,
   oth_g4_cmt ,
   oth_g5 ,
   oth_g5_stat ,
   oth_g5_cmt ,
   oth_g6 ,
   oth_g6_stat ,
   oth_g6_cmt ,
   oth_g7 ,
   oth_g7_stat ,
   oth_g7_cmt ,
   oth_g8 ,
   oth_g8_stat ,
   oth_g8_cmt,
   rom_g1_desc ,
   rom_g1_astlvl  ) ) ))
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
   stat = alterlist (out->bdm ,8 ) ,
   stat = alterlist (out->tfr ,8 ) ,
   stat = alterlist (out->amb ,8 ) ,
   stat = alterlist (out->wcm ,8 ) ,
   stat = alterlist (out->bal ,8 ) ,
   stat = alterlist (out->oth ,8 ) ,
   STAT = alterlist(out->rom,3)
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
     IF ((ce.event_cd IN (bdm_g1_desc ,
     bdm_g1_lvl ,
     bdm_g1_add ,
     bdm_g1_stat ,
     bdm_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[1 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g1_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[1 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[1 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g1_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[1 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[1 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[1 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g2_desc ,
     bdm_g2_lvl ,
     bdm_g2_add ,
     bdm_g2_stat ,
     bdm_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[2 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g2_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[2 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[2 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g2_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[2 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[2 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[2 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g3_desc ,
     bdm_g3_lvl ,
     bdm_g3_add ,
     bdm_g3_stat ,
     bdm_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[3 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g3_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[3 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[3 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g3_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[3 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[3 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[3 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g4_desc ,
     bdm_g4_lvl ,
     bdm_g4_add ,
     bdm_g4_stat ,
     bdm_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[4 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g4_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[4 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[4 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g4_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[4 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[4 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[4 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g5_desc ,
     bdm_g5_lvl ,
     bdm_g5_add ,
     bdm_g5_stat ,
     bdm_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[5 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g5_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[5 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[5 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g5_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[5 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[5 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[5 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g6_desc ,
     bdm_g6_lvl ,
     bdm_g6_add ,
     bdm_g6_stat ,
     bdm_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[6 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g6_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[6 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[6 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g6_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[6 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[6 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[6 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g7_desc ,
     bdm_g7_lvl ,
     bdm_g7_add ,
     bdm_g7_stat ,
     bdm_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[7 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g7_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[7 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[7 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g7_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[7 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[7 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[7 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bdm_g8_desc ,
     bdm_g8_lvl ,
     bdm_g8_add ,
     bdm_g8_stat ,
     bdm_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF bdm_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[8 ].desc = trim (ce.result_val )
        ENDIF
       OF bdm_g8_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[8 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[8 ].lvl = trim (ce.result_val )
        ENDIF
       OF bdm_g8_add :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[8 ].add = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[8 ].add = trim (ce.result_val )
        ENDIF
       OF bdm_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[8 ].stat = trim (ce.result_val )
        ENDIF
       OF bdm_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bdm[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bdm[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g1_desc ,
     tfr_g1_lvl ,
     tfr_g1_dev ,
     tfr_g1_stat ,
     tfr_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[1 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g1_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[1 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[1 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g1_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[1 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[1 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[1 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g2_desc ,
     tfr_g2_lvl ,
     tfr_g2_dev ,
     tfr_g2_stat ,
     tfr_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[2 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g2_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[2 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[2 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g2_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[2 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[2 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[2 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g3_desc ,
     tfr_g3_lvl ,
     tfr_g3_dev ,
     tfr_g3_stat ,
     tfr_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[3 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g3_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[3 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[3 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g3_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[3 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[3 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[3 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g4_desc ,
     tfr_g4_lvl ,
     tfr_g4_dev ,
     tfr_g4_stat ,
     tfr_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[4 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g4_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[4 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[4 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g4_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[4 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[4 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[4 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g5_desc ,
     tfr_g5_lvl ,
     tfr_g5_dev ,
     tfr_g5_stat ,
     tfr_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[5 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g5_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[5 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[5 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g5_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[5 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[5 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[5 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g6_desc ,
     tfr_g6_lvl ,
     tfr_g6_dev ,
     tfr_g6_stat ,
     tfr_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[6 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g6_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[6 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[6 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g6_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[6 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[6 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[6 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g7_desc ,
     tfr_g7_lvl ,
     tfr_g7_dev ,
     tfr_g7_stat ,
     tfr_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[7 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g7_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[7 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[7 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g7_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[7 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[7 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[7 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (tfr_g8_desc ,
     tfr_g8_lvl ,
     tfr_g8_dev ,
     tfr_g8_stat ,
     tfr_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF tfr_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[8 ].desc = trim (ce.result_val )
        ENDIF
       OF tfr_g8_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[8 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[8 ].lvl = trim (ce.result_val )
        ENDIF
       OF tfr_g8_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[8 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[8 ].dev = trim (ce.result_val )
        ENDIF
       OF tfr_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[8 ].stat = trim (ce.result_val )
        ENDIF
       OF tfr_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->tfr[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->tfr[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g1_desc ,
     amb_g1_lvl ,
     amb_g1_dist ,
     amb_g1_dev ,
     amb_g1_stat ,
     amb_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g1_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g1_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g1_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g2_desc ,
     amb_g2_lvl ,
     amb_g2_dist ,
     amb_g2_dev ,
     amb_g2_stat ,
     amb_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g2_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g2_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g2_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g3_desc ,
     amb_g3_lvl ,
     amb_g3_dist ,
     amb_g3_dev ,
     amb_g3_stat ,
     amb_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g3_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g3_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g3_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g4_desc ,
     amb_g4_lvl ,
     amb_g4_dist ,
     amb_g4_dev ,
     amb_g4_stat ,
     amb_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g4_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g4_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g4_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g5_desc ,
     amb_g5_lvl ,
     amb_g5_dist ,
     amb_g5_dev ,
     amb_g5_stat ,
     amb_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g5_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g5_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g5_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g6_desc ,
     amb_g6_lvl ,
     amb_g6_dist ,
     amb_g6_dev ,
     amb_g6_stat ,
     amb_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g6_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g6_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g6_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g7_desc ,
     amb_g7_lvl ,
     amb_g7_dist ,
     amb_g7_dev ,
     amb_g7_stat ,
     amb_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g7_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g7_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g7_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (amb_g8_desc ,
     amb_g8_lvl ,
     amb_g8_dist ,
     amb_g8_dev ,
     amb_g8_stat ,
     amb_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF amb_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].desc = trim (ce.result_val )
        ENDIF
       OF amb_g8_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].lvl = trim (ce.result_val )
        ENDIF
       OF amb_g8_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].dist = trim (ce.result_val )
        ENDIF
       OF amb_g8_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].dev = trim (ce.result_val )
        ENDIF
       OF amb_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].stat = trim (ce.result_val )
        ENDIF
       OF amb_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->amb[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->amb[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g1_desc ,
     wcm_g1_lvl ,
     wcm_g1_dist ,
     wcm_g1_det ,
     wcm_g1_stat ,
     wcm_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g1_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g1_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g1_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g2_desc ,
     wcm_g2_lvl ,
     wcm_g2_dist ,
     wcm_g2_det ,
     wcm_g2_stat ,
     wcm_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g2_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g2_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g2_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g3_desc ,
     wcm_g3_lvl ,
     wcm_g3_dist ,
     wcm_g3_det ,
     wcm_g3_stat ,
     wcm_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g3_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g3_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g3_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g4_desc ,
     wcm_g4_lvl ,
     wcm_g4_dist ,
     wcm_g4_det ,
     wcm_g4_stat ,
     wcm_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g4_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g4_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g4_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g5_desc ,
     wcm_g5_lvl ,
     wcm_g5_dist ,
     wcm_g5_det ,
     wcm_g5_stat ,
     wcm_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g5_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g5_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g5_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g6_desc ,
     wcm_g6_lvl ,
     wcm_g6_dist ,
     wcm_g6_det ,
     wcm_g6_stat ,
     wcm_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g6_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g6_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g6_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g7_desc ,
     wcm_g7_lvl ,
     wcm_g7_dist ,
     wcm_g7_det ,
     wcm_g7_stat ,
     wcm_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g7_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g7_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g7_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (wcm_g8_desc ,
     wcm_g8_lvl ,
     wcm_g8_dist ,
     wcm_g8_det ,
     wcm_g8_stat ,
     wcm_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF wcm_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].desc = trim (ce.result_val )
        ENDIF
       OF wcm_g8_lvl :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].lvl = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].lvl = trim (ce.result_val )
        ENDIF
       OF wcm_g8_dist :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].dist = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].dist = trim (ce.result_val )
        ENDIF
       OF wcm_g8_det :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].det = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].det = trim (ce.result_val )
        ENDIF
       OF wcm_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].stat = trim (ce.result_val )
        ENDIF
       OF wcm_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->wcm[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->wcm[8 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g1_desc ,
     bal_g1_ast ,
     bal_g1_type ,
     bal_g1_dev ,
     bal_g1_ltm ,
     bal_g1_rat ,
     bal_g1_stat ,
     bal_g1_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g1_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g1_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g1_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g1_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g1_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g1_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g1_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g1_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[1 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[1 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g2_desc ,
     bal_g2_ast ,
     bal_g2_type ,
     bal_g2_dev ,
     bal_g2_ltm ,
     bal_g2_rat ,
     bal_g2_stat ,
     bal_g2_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g2_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g2_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g2_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g2_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g2_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g2_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g2_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g2_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[2 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[2 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g3_desc ,
     bal_g3_ast ,
     bal_g3_type ,
     bal_g3_dev ,
     bal_g3_ltm ,
     bal_g3_rat ,
     bal_g3_stat ,
     bal_g3_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g3_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g3_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g3_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g3_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g3_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g3_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g3_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g3_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[3 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[3 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g4_desc ,
     bal_g4_ast ,
     bal_g4_type ,
     bal_g4_dev ,
     bal_g4_ltm ,
     bal_g4_rat ,
     bal_g4_stat ,
     bal_g4_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g4_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g4_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g4_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g4_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g4_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g4_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g4_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g4_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[4 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[4 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g5_desc ,
     bal_g5_ast ,
     bal_g5_type ,
     bal_g5_dev ,
     bal_g5_ltm ,
     bal_g5_rat ,
     bal_g5_stat ,
     bal_g5_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g5_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g5_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g5_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g5_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g5_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g5_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g5_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g5_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[5 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[5 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g6_desc ,
     bal_g6_ast ,
     bal_g6_type ,
     bal_g6_dev ,
     bal_g6_ltm ,
     bal_g6_rat ,
     bal_g6_stat ,
     bal_g6_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g6_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g6_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g6_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g6_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g6_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g6_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g6_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g6_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[6 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[6 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g7_desc ,
     bal_g7_ast ,
     bal_g7_type ,
     bal_g7_dev ,
     bal_g7_ltm ,
     bal_g7_rat ,
     bal_g7_stat ,
     bal_g7_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g7_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g7_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g7_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g7_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g7_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g7_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g7_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g7_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[7 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[7 ].cmt = trim (ce.result_val )
        ENDIF
      ENDCASE
     ENDIF
     ,
     IF ((ce.event_cd IN (bal_g8_desc ,
     bal_g8_ast ,
     bal_g8_type ,
     bal_g8_dev ,
     bal_g8_ltm ,
     bal_g8_rat ,
     bal_g8_stat ,
     bal_g8_cmt ) ) )
      CASE (ce.event_cd )
       OF bal_g8_desc :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].desc = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].desc = trim (ce.result_val )
        ENDIF
       OF bal_g8_ast :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].ast = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].ast = trim (ce.result_val )
        ENDIF
       OF bal_g8_type :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].type = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].type = trim (ce.result_val )
        ENDIF
       OF bal_g8_dev :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].dev = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].dev = trim (ce.result_val )
        ENDIF
       OF bal_g8_ltm :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].ltm = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].ltm = trim (ce.result_val )
        ENDIF
       OF bal_g8_rat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].rat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].rat = trim (ce.result_val )
        ENDIF
       OF bal_g8_stat :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].stat = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].stat = trim (ce.result_val )
        ENDIF
       OF bal_g8_cmt :
        IF ((ce.result_status_cd IN (altered ,
        modified ) ) ) out->bal[8 ].cmt = concat (trim (ce.result_val ) ," (modified)" )
        ELSE out->bal[8 ].cmt = trim (ce.result_val )
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
     
     if (ce.event_cd IN (rom_g1_desc, rom_g1_astlvl ))
     	
     	CASE (ce.event_cd)
     		OF (rom_g1_desc):
     			OUT->rom[1].desc = trim(CE.result_val)
     			
     		OF (rom_g1_astlvl):
     			out->rom[1].astlvl = TRIM(ce.result_val)
     	ENDCASE
     
     
     endif
     
    ENDIF
   ENDIF
  FOOT  ce.event_end_dt_tm
   IF ((first_dttm = "Y" ) ) first_dttm = "N"
   ENDIF
  WITH nocounter
  
  CALL ECHORECORD(out)
  GO TO exit_script
 ;end select
 IF ((curqual = 0 ) )
  SET reply->text = concat (reply->text ,rhead ,wbu ,"PT Short Term Goals" ,wr ,reol ,reol ,wr ,
   "No qualifying data available" ,reol )
  GO TO exit_script
 ENDIF
 SET reply->text = concat (reply->text ,rhead ,wbu ,"PT Short Term Goals" ,reol ,reol )
 SET reply->text = concat (reply->text ,wr ,format (ce_event_end_dt_tm ,"MM/DD/YYYY;;D" ) ,reol )
 FOR (a = 1 TO 8 )
  IF ((((out->bdm[a ].desc > "" ) ) OR ((((out->bdm[a ].lvl > "" ) ) OR ((((out->bdm[a ].add > "" )
  ) OR ((((out->bdm[a ].stat > "" ) ) OR ((out->bdm[a ].cmt > "" ) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Bed Mobility Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->bdm[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->bdm[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->bdm[a ].lvl > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bdm[a ].lvl )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bdm[a ].lvl )
    ENDIF
   ENDIF
   IF ((out->bdm[a ].add > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bdm[a ].add )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bdm[a ].add )
    ENDIF
   ENDIF
   IF ((out->bdm[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bdm[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bdm[a ].stat )
    ENDIF
   ENDIF
   IF ((out->bdm[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bdm[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bdm[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->tfr[a ].desc > "" ) ) OR ((((out->tfr[a ].lvl > "" ) ) OR ((((out->tfr[a ].dev > "" )
  ) OR ((((out->tfr[a ].stat > "" ) ) OR ((out->tfr[a ].cmt > "" ) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Transfer Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->tfr[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->tfr[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->tfr[a ].lvl > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->tfr[a ].lvl )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->tfr[a ].lvl )
    ENDIF
   ENDIF
   IF ((out->tfr[a ].dev > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->tfr[a ].dev )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->tfr[a ].dev )
    ENDIF
   ENDIF
   IF ((out->tfr[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->tfr[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->tfr[a ].stat )
    ENDIF
   ENDIF
   IF ((out->tfr[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->tfr[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->tfr[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->amb[a ].desc > "" ) ) OR ((((out->amb[a ].lvl > "" ) ) OR ((((out->amb[a ].dist > "" )
  ) OR ((((out->amb[a ].dev > "" ) ) OR ((((out->amb[a ].stat > "" ) ) OR ((out->amb[a ].cmt > "" )
  )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Ambulation Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->amb[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->amb[a ].lvl > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].lvl )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->amb[a ].lvl )
    ENDIF
   ENDIF
   IF ((out->amb[a ].dist > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].dist )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->amb[a ].dist )
    ENDIF
   ENDIF
   IF ((out->amb[a ].dev > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].dev )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->amb[a ].dev )
    ENDIF
   ENDIF
   IF ((out->amb[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->amb[a ].stat )
    ENDIF
   ENDIF
   IF ((out->amb[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->amb[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->amb[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->wcm[a ].desc > "" ) ) OR ((((out->wcm[a ].lvl > "" ) ) OR ((((out->wcm[a ].dist > "" )
  ) OR ((((out->wcm[a ].det > "" ) ) OR ((((out->wcm[a ].stat > "" ) ) OR ((out->wcm[a ].cmt > "" )
  )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Wheelchair Management Goal #" ,cnvtstring (a ,1 ,0 ,l
     ) ,":" )
   IF ((out->wcm[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->wcm[a ].lvl > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].lvl )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->wcm[a ].lvl )
    ENDIF
   ENDIF
   IF ((out->wcm[a ].dist > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].dist )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->wcm[a ].dist )
    ENDIF
   ENDIF
   IF ((out->wcm[a ].det > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].det )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->wcm[a ].det )
    ENDIF
   ENDIF
   IF ((out->wcm[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->wcm[a ].stat )
    ENDIF
   ENDIF
   IF ((out->wcm[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->wcm[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->wcm[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->bal[a ].desc > "" ) ) OR ((((out->bal[a ].ast > "" ) ) OR ((((out->bal[a ].type > "" )
  ) OR ((((out->bal[a ].dev > "" ) ) OR ((((out->bal[a ].ltm > "" ) ) OR ((((out->bal[a ].rat > "" )
  ) OR ((((out->bal[a ].stat > "" ) ) OR ((out->bal[a ].cmt > "" ) )) )) )) )) )) )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Balance Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
   IF ((out->bal[a ].desc > "" ) )
    SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].desc )
    SET first = "N"
   ENDIF
   IF ((out->bal[a ].ast > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].ast )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].ast )
    ENDIF
   ENDIF
   IF ((out->bal[a ].type > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].type )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].type )
    ENDIF
   ENDIF
   IF ((out->bal[a ].dev > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].dev )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].dev )
    ENDIF
   ENDIF
   IF ((out->bal[a ].ltm > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].ltm )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].ltm )
    ENDIF
   ENDIF
   IF ((out->bal[a ].rat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].rat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].rat )
    ENDIF
   ENDIF
   IF ((out->bal[a ].stat > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].stat )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].stat )
    ENDIF
   ENDIF
   IF ((out->bal[a ].cmt > "" ) )
    IF ((first = "Y" ) )
     SET reply->text = concat (reply->text ," " ,wr ,out->bal[a ].cmt )
     SET first = "N"
    ELSE
     SET reply->text = concat (reply->text ,"; " ,out->bal[a ].cmt )
    ENDIF
   ENDIF
   SET reply->text = concat (reply->text ,reol )
  ENDIF
 ENDFOR
 FOR (a = 1 TO 8 )
  IF ((((out->oth[a ].goal > "" ) ) OR ((((out->oth[a ].stat > "" ) ) OR ((out->oth[a ].cmt > "" )
  )) )) )
   SET first = "Y"
   SET reply->text = concat (reply->text ,wb ,"Other PT Goal #" ,cnvtstring (a ,1 ,0 ,l ) ,":" )
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
 
 FOR (a = 1 to 3)
 
 	SET first = "Y"
 	SET reply->text = CONCAT(reply->text," ", wr,"ROM Goals")
 	SET reply->text = CONCAT(reply->text," ", wr, out->rom[a].desc)
 	SET reply->text = CONCAT(reply->text," ", wr, out->rom[a].astlvl)
 	SET reply->text = CONCAT(reply->text, reol)
 
 	
 ENDFOR
#exit_script
 SET reply->text = concat (reply->text ,rtfeof )
 SET script_version = "004 05/17/2017 NT5990"
END GO
 
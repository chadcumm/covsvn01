/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/29/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sch_rptstd_rca_det_report.prg
	Object name:		cov_sch_rptstd_rca_det_report
	Request #:			2069
 
	Program purpose:	Provides data for:
							Single Location Schedule Detail
							Multiple Resources Schedule Detail
 
	Executing from:		Scheduling Appointment Book Reports
 
 	Special Notes:		Called by Scheduling Reports (schreportexe.exe).
 						Translated and customized from Cerner program
 						sch_rptstd_rca_detail_report.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001 08/29/2018	Todd A. Blanchard		Added scheduled order details.
002 09/20/2018	Todd A. Blanchard		Added scheduled auth and ordering physician data.
003 09/21/2018	Todd A. Blanchard		Added encounter auth data.
004 10/30/2018	Todd A. Blanchard		Adjusted logic for order details.
005 02/10/2021	Todd A. Blanchard		Adjusted logic for order details.
 
******************************************************************************/
 
DROP PROGRAM cov_sch_rptstd_rca_det_report:dba GO
CREATE PROGRAM cov_sch_rptstd_rca_det_report:dba
 DECLARE s_uar_crmbeginapp ((s_app = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmbegintask ((s_happ = i4 ) ,(s_task = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmbeginreq ((s_htask = i4 ) ,(s_param = i4 ) ,(s_req = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmperform ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmendreq ((s_hstep = i4 (ref ) ) ) = null
 DECLARE s_uar_crmendtask ((s_htask = i4 (ref ) ) ) = null
 DECLARE s_uar_crmendapp ((s_happ = i4 (ref ) ) ) = null
 DECLARE s_uar_echo_object ((s_hobject = i4 ) ) = null
 DECLARE s_uar_crmgetrequest ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmgetreply ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmperformas ((s_hstep = i4 ) ,(s_option = i4 ) ,(s_service = vc ) ) = i4
 
 ;001
 DECLARE confirmed_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
 DECLARE checkedin_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CHECKEDIN"))
 DECLARE order_status_future_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
 DECLARE order_status_ordered_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
 DECLARE order_status_completed_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "COMPLETED"))
 DECLARE attach_type_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
 DECLARE attach_state_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE"))
 ;
 
 ;003
 DECLARE authorization_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 14949, "AUTHORIZATION"))
 ;
 
 SUBROUTINE  s_uar_crmbeginapp (s_app ,s_option )
  DECLARE s_happ = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbeginapp (s_app ,s_happ )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbeginapp (" ,s_app ,"," ,s_option ,") returned [" ,
      my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbeginapp (" ,s_app ,"," ,s_option ,") returned [" ,my_stat ,
       "]" ) )
   ENDCASE
  ENDIF
  RETURN (s_happ )
 END ;Subroutine
 SUBROUTINE  s_uar_crmbegintask (s_happ ,s_task ,s_option )
  DECLARE s_htask = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbegintask (s_happ ,s_task ,s_htask )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbegintask (" ,s_happ ,"," ,s_task ,"," ,s_option ,
      ") returned [" ,my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbegintask (" ,s_happ ,"," ,s_task ,"," ,s_option ,
       ") returned [" ,my_stat ,"]" ) )
   ENDCASE
  ENDIF
  RETURN (s_htask )
 END ;Subroutine
 SUBROUTINE  s_uar_crmbeginreq (s_htask ,s_param ,s_req ,s_option )
  DECLARE s_hstep = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbeginreq (s_htask ,s_param ,s_req ,s_hstep )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbeginreq (" ,s_htask ,"," ,s_param ,"," ,s_req ,"," ,
      s_option ,") returned [" ,my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbeginreq (" ,s_htask ,"," ,s_param ,"," ,s_req ,"," ,
       s_option ,") returned [" ,my_stat ,"]" ) )
   ENDCASE
  ENDIF
  RETURN (s_hstep )
 END ;Subroutine
 SUBROUTINE  s_uar_crmperform (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmperform (s_hstep )
   IF (my_stat )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmperform (" ,s_hstep ,"," ,s_option ,") returned [" ,
       my_stat ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmperform (" ,s_hstep ,"," ,s_option ,") returned [" ,
        my_stat ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (my_stat )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmperformas (s_hstep ,s_option ,s_service )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmperformas (s_hstep ,s_service )
   IF (my_stat )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmperformas (" ,s_hstep ,"," ,s_option ,") returned ["
       ,my_stat ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmperformas (" ,s_hstep ,"," ,s_option ,") returned [" ,
        my_stat ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (my_stat )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmgetrequest (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE s_hrequest = i4 WITH protect ,noconstant (0 )
   SET s_hrequest = uar_crmgetrequest (s_hstep )
   IF ((s_hrequest = 0 ) )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmgetrequest (" ,s_hstep ,"," ,s_option ,
       ") returned [" ,s_hrequest ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmgetrequest (" ,s_hstep ,"," ,s_option ,") returned [" ,
        s_hrequest ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (s_hrequest )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmgetreply (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE s_hreply = i4 WITH protect ,noconstant (0 )
   SET s_hreply = uar_crmgetreply (s_hstep )
   IF ((s_hreply = 0 ) )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmgetreply (" ,s_hstep ,"," ,s_option ,") returned [" ,
       s_hreply ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmgetreply (" ,s_hstep ,"," ,s_option ,") returned [" ,
        s_hreply ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (s_hreply )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendreq (s_hstep )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendreq (s_hstep )
   SET s_hstep = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendtask (s_htask )
  IF ((s_htask > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendtask (s_htask )
   SET s_htask = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendapp (s_happ )
  IF ((s_happ > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendapp (s_happ )
   SET s_happ = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_echo_object (s_hobject )
  IF ((s_hobject > 0 ) )
   CALL uar_oen_dump_object (s_hobject )
  ENDIF
 END ;Subroutine
 IF (NOT (validate (get_locgroup_exp_request ,0 ) ) )
  RECORD get_locgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_reply ,0 ) ) )
  RECORD get_locgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 location_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_request ,0 ) ) )
  RECORD get_res_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 res_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_reply ,0 ) ) )
  RECORD get_res_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 res_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 resource_cd = f8
        3 mnemonic = vc
        3 description = vc
        3 quota = i4
        3 person_id = f8
        3 id_disp = vc
        3 res_type_flag = i2
        3 active_ind = i2
  )
 ENDIF
 IF ((validate (eem_font_metrics_helvetica_rec_ ,- (99 ) ) = - (99 ) ) )
  DECLARE eem_font_metrics_helvetica_rec_ = i2 WITH public ,constant (1 )
  FREE SET format_text
  RECORD format_text (
    1 output_string_cnt = i2
    1 output_string [* ]
      2 string = vc
      2 x_offset = i4
      2 bold = i2
  )
  FREE SET metrics_h
  RECORD metrics_h (
    1 helvetica_cnt = i2
    1 helvetica [* ]
      2 size = i2
    1 helvetica_bold_cnt = i2
    1 helvetica_bold [* ]
      2 size = i2
  )
 ENDIF
 IF ((validate (eem_font_metrics_helvetica_ ,- (99 ) ) = - (99 ) ) )
  DECLARE eem_font_metrics_helvetica_ = i2 WITH public ,constant (1 )
  DECLARE cpitopoints ((cpisize = i2 ) ) = i2
  DECLARE stringwidthhelvetica ((input_string = vc ) ,(cpi = i2 ) ,(bold = i2 ) ) = i4
  DECLARE centerstringhelvetica ((input_string = vc ) ,(cpi = i2 ) ,(x_start = i2 ) ,(x_end = i2 ) ,(
   bold = i2 ) ) = i2
  DECLARE wordwraphelvetica ((input_string = vc ) ,(cpi = i2 ) ,(line_width = i2 ) ,(bold_start = i2
   ) ) = i2
  DECLARE inputstrlen = i4 WITH public ,noconstant (0 )
  DECLARE fontpoints = i4 WITH public ,noconstant (0 )
  DECLARE widthline = i4 WITH public ,noconstant (0 )
  DECLARE widthtotal = i4 WITH public ,noconstant (0 )
  DECLARE widthstring = i4 WITH public ,noconstant (0 )
  DECLARE widthword = i4 WITH public ,noconstant (0 )
  DECLARE widthchar = i2 WITH public ,noconstant (0 )
  DECLARE widthspace = i4 WITH public ,noconstant (0 )
  DECLARE spacecnt = i2 WITH public ,noconstant (0 )
  DECLARE asciinum = i2 WITH public ,noconstant (0 )
  DECLARE endword = i4 WITH public ,noconstant (1 )
  DECLARE startsubstr = i4 WITH public ,noconstant (1 )
  DECLARE endlastline = i2 WITH public ,noconstant (0 )
  DECLARE endlastlinepts = i4 WITH public ,noconstant (0 )
  DECLARE state = i2 WITH public ,noconstant (0 )
  DECLARE cnt = i4 WITH public ,noconstant (1 )
  DECLARE bold = i2 WITH public ,noconstant (0 )
  DECLARE boldstart = i4 WITH public ,noconstant (0 )
  DECLARE nonboldstart = i4 WITH public ,noconstant (0 )
  DECLARE temp_indx = i4 WITH public ,noconstant (0 )
  IF ((validate (eem_font_metrics_helvetica_rec_ ,- (99 ) ) = - (99 ) ) )
   DECLARE eem_font_metrics_helvetica_rec_ = i2 WITH public ,constant (1 )
   FREE SET format_text
   RECORD format_text (
     1 output_string_cnt = i2
     1 output_string [* ]
       2 string = vc
       2 x_offset = i4
       2 bold = i2
   )
   FREE SET metrics_h
   RECORD metrics_h (
     1 helvetica_cnt = i2
     1 helvetica [* ]
       2 size = i2
     1 helvetica_bold_cnt = i2
     1 helvetica_bold [* ]
       2 size = i2
   )
  ENDIF
  SET format_text->output_string_cnt = 0
  SET metrics_h->helvetica_cnt = 253
  SET stat = alterlist (metrics_h->helvetica ,metrics_h->helvetica_cnt )
  FOR (temp_indx = 1 TO 31 )
   SET metrics_h->helvetica[temp_indx ].size = 0
  ENDFOR
  SET metrics_h->helvetica[32 ].size = 278
  SET metrics_h->helvetica[33 ].size = 278
  SET metrics_h->helvetica[34 ].size = 355
  SET metrics_h->helvetica[35 ].size = 556
  SET metrics_h->helvetica[36 ].size = 556
  SET metrics_h->helvetica[37 ].size = 889
  SET metrics_h->helvetica[38 ].size = 667
  SET metrics_h->helvetica[39 ].size = 222
  SET metrics_h->helvetica[40 ].size = 333
  SET metrics_h->helvetica[41 ].size = 333
  SET metrics_h->helvetica[42 ].size = 389
  SET metrics_h->helvetica[43 ].size = 584
  SET metrics_h->helvetica[44 ].size = 278
  SET metrics_h->helvetica[45 ].size = 333
  SET metrics_h->helvetica[46 ].size = 278
  SET metrics_h->helvetica[47 ].size = 278
  SET metrics_h->helvetica[48 ].size = 556
  SET metrics_h->helvetica[49 ].size = 556
  SET metrics_h->helvetica[50 ].size = 556
  SET metrics_h->helvetica[51 ].size = 556
  SET metrics_h->helvetica[52 ].size = 556
  SET metrics_h->helvetica[53 ].size = 556
  SET metrics_h->helvetica[54 ].size = 556
  SET metrics_h->helvetica[55 ].size = 556
  SET metrics_h->helvetica[56 ].size = 556
  SET metrics_h->helvetica[57 ].size = 556
  SET metrics_h->helvetica[58 ].size = 278
  SET metrics_h->helvetica[59 ].size = 278
  SET metrics_h->helvetica[60 ].size = 584
  SET metrics_h->helvetica[61 ].size = 584
  SET metrics_h->helvetica[62 ].size = 584
  SET metrics_h->helvetica[63 ].size = 556
  SET metrics_h->helvetica[64 ].size = 1015
  SET metrics_h->helvetica[65 ].size = 667
  SET metrics_h->helvetica[66 ].size = 667
  SET metrics_h->helvetica[67 ].size = 722
  SET metrics_h->helvetica[68 ].size = 722
  SET metrics_h->helvetica[69 ].size = 667
  SET metrics_h->helvetica[70 ].size = 611
  SET metrics_h->helvetica[71 ].size = 778
  SET metrics_h->helvetica[72 ].size = 722
  SET metrics_h->helvetica[73 ].size = 278
  SET metrics_h->helvetica[74 ].size = 500
  SET metrics_h->helvetica[75 ].size = 667
  SET metrics_h->helvetica[76 ].size = 556
  SET metrics_h->helvetica[77 ].size = 833
  SET metrics_h->helvetica[78 ].size = 722
  SET metrics_h->helvetica[79 ].size = 778
  SET metrics_h->helvetica[80 ].size = 667
  SET metrics_h->helvetica[81 ].size = 778
  SET metrics_h->helvetica[82 ].size = 722
  SET metrics_h->helvetica[83 ].size = 667
  SET metrics_h->helvetica[84 ].size = 611
  SET metrics_h->helvetica[85 ].size = 722
  SET metrics_h->helvetica[86 ].size = 667
  SET metrics_h->helvetica[87 ].size = 944
  SET metrics_h->helvetica[88 ].size = 667
  SET metrics_h->helvetica[89 ].size = 667
  SET metrics_h->helvetica[90 ].size = 611
  SET metrics_h->helvetica[91 ].size = 278
  SET metrics_h->helvetica[92 ].size = 278
  SET metrics_h->helvetica[93 ].size = 278
  SET metrics_h->helvetica[94 ].size = 469
  SET metrics_h->helvetica[95 ].size = 556
  SET metrics_h->helvetica[96 ].size = 222
  SET metrics_h->helvetica[97 ].size = 556
  SET metrics_h->helvetica[98 ].size = 556
  SET metrics_h->helvetica[99 ].size = 500
  SET metrics_h->helvetica[100 ].size = 556
  SET metrics_h->helvetica[101 ].size = 556
  SET metrics_h->helvetica[102 ].size = 278
  SET metrics_h->helvetica[103 ].size = 556
  SET metrics_h->helvetica[104 ].size = 556
  SET metrics_h->helvetica[105 ].size = 222
  SET metrics_h->helvetica[106 ].size = 222
  SET metrics_h->helvetica[107 ].size = 500
  SET metrics_h->helvetica[108 ].size = 222
  SET metrics_h->helvetica[109 ].size = 833
  SET metrics_h->helvetica[110 ].size = 556
  SET metrics_h->helvetica[111 ].size = 556
  SET metrics_h->helvetica[112 ].size = 556
  SET metrics_h->helvetica[113 ].size = 556
  SET metrics_h->helvetica[114 ].size = 333
  SET metrics_h->helvetica[115 ].size = 500
  SET metrics_h->helvetica[116 ].size = 278
  SET metrics_h->helvetica[117 ].size = 556
  SET metrics_h->helvetica[118 ].size = 500
  SET metrics_h->helvetica[119 ].size = 722
  SET metrics_h->helvetica[120 ].size = 500
  SET metrics_h->helvetica[121 ].size = 500
  SET metrics_h->helvetica[122 ].size = 500
  SET metrics_h->helvetica[123 ].size = 334
  SET metrics_h->helvetica[124 ].size = 260
  SET metrics_h->helvetica[125 ].size = 334
  SET metrics_h->helvetica[126 ].size = 584
  FOR (temp_indx = 127 TO 160 )
   SET metrics_h->helvetica[temp_indx ].size = 0
  ENDFOR
  SET metrics_h->helvetica[161 ].size = 333
  SET metrics_h->helvetica[162 ].size = 556
  SET metrics_h->helvetica[163 ].size = 556
  SET metrics_h->helvetica[164 ].size = 0
  SET metrics_h->helvetica[165 ].size = 556
  SET metrics_h->helvetica[166 ].size = 0
  SET metrics_h->helvetica[167 ].size = 556
  SET metrics_h->helvetica[168 ].size = 556
  SET metrics_h->helvetica[169 ].size = 611
  SET metrics_h->helvetica[170 ].size = 333
  SET metrics_h->helvetica[171 ].size = 556
  SET metrics_h->helvetica[172 ].size = 0
  SET metrics_h->helvetica[173 ].size = 0
  SET metrics_h->helvetica[174 ].size = 0
  SET metrics_h->helvetica[175 ].size = 0
  SET metrics_h->helvetica[176 ].size = 0
  SET metrics_h->helvetica[177 ].size = 556
  SET metrics_h->helvetica[178 ].size = 556
  SET metrics_h->helvetica[179 ].size = 556
  SET metrics_h->helvetica[180 ].size = 278
  SET metrics_h->helvetica[181 ].size = 0
  SET metrics_h->helvetica[182 ].size = 537
  SET metrics_h->helvetica[183 ].size = 350
  SET metrics_h->helvetica[184 ].size = 222
  SET metrics_h->helvetica[185 ].size = 333
  SET metrics_h->helvetica[186 ].size = 333
  SET metrics_h->helvetica[187 ].size = 556
  SET metrics_h->helvetica[188 ].size = 1000
  SET metrics_h->helvetica[189 ].size = 1000
  SET metrics_h->helvetica[190 ].size = 0
  SET metrics_h->helvetica[191 ].size = 611
  SET metrics_h->helvetica[192 ].size = 667
  SET metrics_h->helvetica[193 ].size = 667
  SET metrics_h->helvetica[194 ].size = 667
  SET metrics_h->helvetica[195 ].size = 667
  SET metrics_h->helvetica[196 ].size = 667
  SET metrics_h->helvetica[197 ].size = 667
  SET metrics_h->helvetica[198 ].size = 1000
  SET metrics_h->helvetica[199 ].size = 722
  SET metrics_h->helvetica[200 ].size = 667
  SET metrics_h->helvetica[201 ].size = 667
  SET metrics_h->helvetica[202 ].size = 667
  SET metrics_h->helvetica[203 ].size = 667
  SET metrics_h->helvetica[204 ].size = 278
  SET metrics_h->helvetica[205 ].size = 278
  SET metrics_h->helvetica[206 ].size = 278
  SET metrics_h->helvetica[207 ].size = 278
  SET metrics_h->helvetica[208 ].size = 0
  SET metrics_h->helvetica[209 ].size = 722
  SET metrics_h->helvetica[210 ].size = 778
  SET metrics_h->helvetica[211 ].size = 778
  SET metrics_h->helvetica[212 ].size = 778
  SET metrics_h->helvetica[213 ].size = 778
  SET metrics_h->helvetica[214 ].size = 778
  SET metrics_h->helvetica[215 ].size = 0
  SET metrics_h->helvetica[216 ].size = 0
  SET metrics_h->helvetica[217 ].size = 722
  SET metrics_h->helvetica[218 ].size = 722
  SET metrics_h->helvetica[219 ].size = 722
  SET metrics_h->helvetica[220 ].size = 722
  SET metrics_h->helvetica[221 ].size = 0
  SET metrics_h->helvetica[222 ].size = 0
  SET metrics_h->helvetica[223 ].size = 0
  SET metrics_h->helvetica[224 ].size = 556
  SET metrics_h->helvetica[225 ].size = 556
  SET metrics_h->helvetica[226 ].size = 556
  SET metrics_h->helvetica[227 ].size = 556
  SET metrics_h->helvetica[228 ].size = 556
  SET metrics_h->helvetica[229 ].size = 556
  SET metrics_h->helvetica[230 ].size = 0
  SET metrics_h->helvetica[231 ].size = 0
  SET metrics_h->helvetica[232 ].size = 556
  SET metrics_h->helvetica[233 ].size = 556
  SET metrics_h->helvetica[234 ].size = 556
  SET metrics_h->helvetica[235 ].size = 556
  SET metrics_h->helvetica[236 ].size = 222
  SET metrics_h->helvetica[237 ].size = 222
  SET metrics_h->helvetica[238 ].size = 222
  SET metrics_h->helvetica[239 ].size = 222
  SET metrics_h->helvetica[240 ].size = 0
  SET metrics_h->helvetica[241 ].size = 556
  SET metrics_h->helvetica[242 ].size = 556
  SET metrics_h->helvetica[243 ].size = 556
  SET metrics_h->helvetica[244 ].size = 556
  SET metrics_h->helvetica[245 ].size = 556
  SET metrics_h->helvetica[246 ].size = 556
  SET metrics_h->helvetica[247 ].size = 0
  SET metrics_h->helvetica[248 ].size = 556
  SET metrics_h->helvetica[249 ].size = 556
  SET metrics_h->helvetica[250 ].size = 556
  SET metrics_h->helvetica[251 ].size = 556
  SET metrics_h->helvetica[252 ].size = 556
  SET metrics_h->helvetica[253 ].size = 500
  SET metrics_h->helvetica_bold_cnt = 253
  SET stat = alterlist (metrics_h->helvetica_bold ,metrics_h->helvetica_bold_cnt )
  FOR (temp_indx = 1 TO 31 )
   SET metrics_h->helvetica_bold[temp_indx ].size = 0
  ENDFOR
  SET metrics_h->helvetica_bold[32 ].size = 278
  SET metrics_h->helvetica_bold[33 ].size = 333
  SET metrics_h->helvetica_bold[34 ].size = 474
  SET metrics_h->helvetica_bold[35 ].size = 556
  SET metrics_h->helvetica_bold[36 ].size = 556
  SET metrics_h->helvetica_bold[37 ].size = 889
  SET metrics_h->helvetica_bold[38 ].size = 722
  SET metrics_h->helvetica_bold[39 ].size = 278
  SET metrics_h->helvetica_bold[40 ].size = 333
  SET metrics_h->helvetica_bold[41 ].size = 333
  SET metrics_h->helvetica_bold[42 ].size = 389
  SET metrics_h->helvetica_bold[43 ].size = 584
  SET metrics_h->helvetica_bold[44 ].size = 278
  SET metrics_h->helvetica_bold[45 ].size = 333
  SET metrics_h->helvetica_bold[46 ].size = 278
  SET metrics_h->helvetica_bold[47 ].size = 278
  SET metrics_h->helvetica_bold[48 ].size = 556
  SET metrics_h->helvetica_bold[49 ].size = 556
  SET metrics_h->helvetica_bold[50 ].size = 556
  SET metrics_h->helvetica_bold[51 ].size = 556
  SET metrics_h->helvetica_bold[52 ].size = 556
  SET metrics_h->helvetica_bold[53 ].size = 556
  SET metrics_h->helvetica_bold[54 ].size = 556
  SET metrics_h->helvetica_bold[55 ].size = 556
  SET metrics_h->helvetica_bold[56 ].size = 556
  SET metrics_h->helvetica_bold[57 ].size = 556
  SET metrics_h->helvetica_bold[58 ].size = 333
  SET metrics_h->helvetica_bold[59 ].size = 333
  SET metrics_h->helvetica_bold[60 ].size = 584
  SET metrics_h->helvetica_bold[61 ].size = 584
  SET metrics_h->helvetica_bold[62 ].size = 584
  SET metrics_h->helvetica_bold[63 ].size = 611
  SET metrics_h->helvetica_bold[64 ].size = 975
  SET metrics_h->helvetica_bold[65 ].size = 722
  SET metrics_h->helvetica_bold[66 ].size = 722
  SET metrics_h->helvetica_bold[67 ].size = 722
  SET metrics_h->helvetica_bold[68 ].size = 722
  SET metrics_h->helvetica_bold[69 ].size = 667
  SET metrics_h->helvetica_bold[70 ].size = 611
  SET metrics_h->helvetica_bold[71 ].size = 778
  SET metrics_h->helvetica_bold[72 ].size = 722
  SET metrics_h->helvetica_bold[73 ].size = 278
  SET metrics_h->helvetica_bold[74 ].size = 556
  SET metrics_h->helvetica_bold[75 ].size = 722
  SET metrics_h->helvetica_bold[76 ].size = 611
  SET metrics_h->helvetica_bold[77 ].size = 833
  SET metrics_h->helvetica_bold[78 ].size = 722
  SET metrics_h->helvetica_bold[79 ].size = 778
  SET metrics_h->helvetica_bold[80 ].size = 667
  SET metrics_h->helvetica_bold[81 ].size = 778
  SET metrics_h->helvetica_bold[82 ].size = 722
  SET metrics_h->helvetica_bold[83 ].size = 667
  SET metrics_h->helvetica_bold[84 ].size = 611
  SET metrics_h->helvetica_bold[85 ].size = 722
  SET metrics_h->helvetica_bold[86 ].size = 667
  SET metrics_h->helvetica_bold[87 ].size = 944
  SET metrics_h->helvetica_bold[88 ].size = 667
  SET metrics_h->helvetica_bold[89 ].size = 667
  SET metrics_h->helvetica_bold[90 ].size = 611
  SET metrics_h->helvetica_bold[91 ].size = 333
  SET metrics_h->helvetica_bold[92 ].size = 278
  SET metrics_h->helvetica_bold[93 ].size = 333
  SET metrics_h->helvetica_bold[94 ].size = 584
  SET metrics_h->helvetica_bold[95 ].size = 556
  SET metrics_h->helvetica_bold[96 ].size = 278
  SET metrics_h->helvetica_bold[97 ].size = 556
  SET metrics_h->helvetica_bold[98 ].size = 611
  SET metrics_h->helvetica_bold[99 ].size = 556
  SET metrics_h->helvetica_bold[100 ].size = 611
  SET metrics_h->helvetica_bold[101 ].size = 556
  SET metrics_h->helvetica_bold[102 ].size = 333
  SET metrics_h->helvetica_bold[103 ].size = 611
  SET metrics_h->helvetica_bold[104 ].size = 611
  SET metrics_h->helvetica_bold[105 ].size = 278
  SET metrics_h->helvetica_bold[106 ].size = 278
  SET metrics_h->helvetica_bold[107 ].size = 556
  SET metrics_h->helvetica_bold[108 ].size = 278
  SET metrics_h->helvetica_bold[109 ].size = 889
  SET metrics_h->helvetica_bold[110 ].size = 611
  SET metrics_h->helvetica_bold[111 ].size = 611
  SET metrics_h->helvetica_bold[112 ].size = 611
  SET metrics_h->helvetica_bold[113 ].size = 611
  SET metrics_h->helvetica_bold[114 ].size = 389
  SET metrics_h->helvetica_bold[115 ].size = 556
  SET metrics_h->helvetica_bold[116 ].size = 333
  SET metrics_h->helvetica_bold[117 ].size = 611
  SET metrics_h->helvetica_bold[118 ].size = 556
  SET metrics_h->helvetica_bold[119 ].size = 778
  SET metrics_h->helvetica_bold[120 ].size = 556
  SET metrics_h->helvetica_bold[121 ].size = 556
  SET metrics_h->helvetica_bold[122 ].size = 500
  SET metrics_h->helvetica_bold[123 ].size = 389
  SET metrics_h->helvetica_bold[124 ].size = 280
  SET metrics_h->helvetica_bold[125 ].size = 389
  SET metrics_h->helvetica_bold[126 ].size = 584
  FOR (temp_indx = 127 TO 160 )
   SET metrics_h->helvetica_bold[temp_indx ].size = 0
  ENDFOR
  SET metrics_h->helvetica_bold[161 ].size = 333
  SET metrics_h->helvetica_bold[162 ].size = 556
  SET metrics_h->helvetica_bold[163 ].size = 556
  SET metrics_h->helvetica_bold[164 ].size = 0
  SET metrics_h->helvetica_bold[165 ].size = 556
  SET metrics_h->helvetica_bold[166 ].size = 0
  SET metrics_h->helvetica_bold[167 ].size = 556
  SET metrics_h->helvetica_bold[168 ].size = 556
  SET metrics_h->helvetica_bold[169 ].size = 238
  SET metrics_h->helvetica_bold[170 ].size = 500
  SET metrics_h->helvetica_bold[171 ].size = 556
  SET metrics_h->helvetica_bold[172 ].size = 0
  SET metrics_h->helvetica_bold[173 ].size = 0
  SET metrics_h->helvetica_bold[174 ].size = 0
  SET metrics_h->helvetica_bold[175 ].size = 0
  SET metrics_h->helvetica_bold[176 ].size = 0
  SET metrics_h->helvetica_bold[177 ].size = 556
  SET metrics_h->helvetica_bold[178 ].size = 556
  SET metrics_h->helvetica_bold[179 ].size = 556
  SET metrics_h->helvetica_bold[180 ].size = 278
  SET metrics_h->helvetica_bold[181 ].size = 0
  SET metrics_h->helvetica_bold[182 ].size = 556
  SET metrics_h->helvetica_bold[183 ].size = 350
  SET metrics_h->helvetica_bold[184 ].size = 0
  SET metrics_h->helvetica_bold[185 ].size = 500
  SET metrics_h->helvetica_bold[186 ].size = 500
  SET metrics_h->helvetica_bold[187 ].size = 556
  SET metrics_h->helvetica_bold[188 ].size = 1000
  SET metrics_h->helvetica_bold[189 ].size = 1000
  SET metrics_h->helvetica_bold[190 ].size = 0
  SET metrics_h->helvetica_bold[191 ].size = 611
  SET metrics_h->helvetica_bold[192 ].size = 722
  SET metrics_h->helvetica_bold[193 ].size = 722
  SET metrics_h->helvetica_bold[194 ].size = 722
  SET metrics_h->helvetica_bold[195 ].size = 722
  SET metrics_h->helvetica_bold[196 ].size = 722
  SET metrics_h->helvetica_bold[197 ].size = 722
  SET metrics_h->helvetica_bold[198 ].size = 1000
  SET metrics_h->helvetica_bold[199 ].size = 722
  SET metrics_h->helvetica_bold[200 ].size = 667
  SET metrics_h->helvetica_bold[201 ].size = 667
  SET metrics_h->helvetica_bold[202 ].size = 667
  SET metrics_h->helvetica_bold[203 ].size = 667
  SET metrics_h->helvetica_bold[204 ].size = 278
  SET metrics_h->helvetica_bold[205 ].size = 278
  SET metrics_h->helvetica_bold[206 ].size = 278
  SET metrics_h->helvetica_bold[207 ].size = 278
  SET metrics_h->helvetica_bold[208 ].size = 0
  SET metrics_h->helvetica_bold[209 ].size = 722
  SET metrics_h->helvetica_bold[210 ].size = 778
  SET metrics_h->helvetica_bold[211 ].size = 778
  SET metrics_h->helvetica_bold[212 ].size = 778
  SET metrics_h->helvetica_bold[213 ].size = 778
  SET metrics_h->helvetica_bold[214 ].size = 778
  SET metrics_h->helvetica_bold[215 ].size = 0
  SET metrics_h->helvetica_bold[216 ].size = 0
  SET metrics_h->helvetica_bold[217 ].size = 722
  SET metrics_h->helvetica_bold[218 ].size = 722
  SET metrics_h->helvetica_bold[219 ].size = 722
  SET metrics_h->helvetica_bold[220 ].size = 722
  SET metrics_h->helvetica_bold[221 ].size = 0
  SET metrics_h->helvetica_bold[222 ].size = 0
  SET metrics_h->helvetica_bold[223 ].size = 0
  SET metrics_h->helvetica_bold[224 ].size = 556
  SET metrics_h->helvetica_bold[225 ].size = 556
  SET metrics_h->helvetica_bold[226 ].size = 556
  SET metrics_h->helvetica_bold[227 ].size = 556
  SET metrics_h->helvetica_bold[228 ].size = 556
  SET metrics_h->helvetica_bold[229 ].size = 556
  SET metrics_h->helvetica_bold[230 ].size = 0
  SET metrics_h->helvetica_bold[231 ].size = 0
  SET metrics_h->helvetica_bold[232 ].size = 556
  SET metrics_h->helvetica_bold[233 ].size = 556
  SET metrics_h->helvetica_bold[234 ].size = 556
  SET metrics_h->helvetica_bold[235 ].size = 556
  SET metrics_h->helvetica_bold[236 ].size = 278
  SET metrics_h->helvetica_bold[237 ].size = 278
  SET metrics_h->helvetica_bold[238 ].size = 278
  SET metrics_h->helvetica_bold[239 ].size = 278
  SET metrics_h->helvetica_bold[240 ].size = 0
  SET metrics_h->helvetica_bold[241 ].size = 611
  SET metrics_h->helvetica_bold[242 ].size = 611
  SET metrics_h->helvetica_bold[243 ].size = 611
  SET metrics_h->helvetica_bold[244 ].size = 611
  SET metrics_h->helvetica_bold[245 ].size = 611
  SET metrics_h->helvetica_bold[246 ].size = 611
  SET metrics_h->helvetica_bold[247 ].size = 0
  SET metrics_h->helvetica_bold[248 ].size = 611
  SET metrics_h->helvetica_bold[249 ].size = 611
  SET metrics_h->helvetica_bold[250 ].size = 611
  SET metrics_h->helvetica_bold[251 ].size = 611
  SET metrics_h->helvetica_bold[252 ].size = 611
  SET metrics_h->helvetica_bold[253 ].size = 556
  SUBROUTINE  cpitopoints (cpisize )
   DECLARE pointsize = i2
   SET pointsize = floor (((120.0 / cpisize ) + 0.5 ) )
   RETURN (pointsize )
  END ;Subroutine
  SUBROUTINE  stringwidthhelvetica (input_string ,cpi ,bold )
   IF ((cpi > 0 ) )
    SET fontpoints = floor (((120.0 / cpi ) + 0.5 ) )
   ELSE
    SET fontpoints = 0
   ENDIF
   SET inputstrlen = textlen (input_string )
   SET widthtotal = 0
   FOR (temp_indx = 1 TO inputstrlen )
    SET asciinum = ichar (substring (temp_indx ,1 ,input_string ) )
    IF ((asciinum <= 253 ) )
     IF ((bold = 0 ) )
      SET widthtotal = (widthtotal + (fontpoints * metrics_h->helvetica[asciinum ].size ) )
     ELSE
      SET widthtotal = (widthtotal + (fontpoints * metrics_h->helvetica_bold[asciinum ].size ) )
     ENDIF
    ENDIF
   ENDFOR
   SET widthtotal = floor (((widthtotal / 1000.0 ) + 0.5 ) )
   RETURN (widthtotal )
  END ;Subroutine
  SUBROUTINE  centerstringhelvetica (input_string ,cpi ,x_start ,x_end ,bold_start )
   IF ((cpi > 0 ) )
    SET fontpoints = floor (((120.0 / cpi ) + 0.5 ) )
   ELSE
    SET fontpoints = 0
   ENDIF
   SET inputstrlen = textlen (input_string )
   SET widthline = ((x_end - x_start ) * 1000 )
   SET widthtotal = 0
   SET widthstring = 0
   SET startsubstr = 1
   SET bold = bold_start
   SET format_text->output_string_cnt = 0
   IF ((widthline > (1015 * fontpoints ) )
   AND (fontpoints <= 120 ) )
    SET cnt = 1
    WHILE ((cnt <= inputstrlen ) )
     SET asciinum = ichar (substring (cnt ,1 ,input_string ) )
     IF ((((asciinum < 32 ) ) OR ((asciinum > 253 ) )) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      SET cnt = (cnt - 1 )
     ELSEIF ((asciinum = 187 ) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      IF ((bold = 0 )
      AND (widthstring > 0 ) )
       SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
       IF ((mod (format_text->output_string_cnt ,10 ) = 1 ) )
        SET stat = alterlist (format_text->output_string ,(format_text->output_string_cnt + 9 ) )
       ENDIF
       SET format_text->output_string[format_text->output_string_cnt ].string = notrim (substring (
         startsubstr ,(cnt - startsubstr ) ,input_string ) )
       SET format_text->output_string[format_text->output_string_cnt ].bold = bold
       SET format_text->output_string[format_text->output_string_cnt ].x_offset = widthtotal
       SET widthtotal = (widthtotal + widthstring )
       SET widthstring = 0
       SET startsubstr = cnt
      ENDIF
      SET bold = 1
      SET cnt = (cnt - 1 )
     ELSEIF ((asciinum = 171 ) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      IF ((bold = 1 )
      AND (widthstring > 0 ) )
       SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
       IF ((mod (format_text->output_string_cnt ,10 ) = 1 ) )
        SET stat = alterlist (format_text->output_string ,(format_text->output_string_cnt + 9 ) )
       ENDIF
       SET format_text->output_string[format_text->output_string_cnt ].string = notrim (substring (
         startsubstr ,(cnt - startsubstr ) ,input_string ) )
       SET format_text->output_string[format_text->output_string_cnt ].bold = bold
       SET format_text->output_string[format_text->output_string_cnt ].x_offset = widthtotal
       SET widthtotal = (widthtotal + widthstring )
       SET widthstring = 0
       SET startsubstr = cnt
      ENDIF
      SET bold = 0
      SET cnt = (cnt - 1 )
     ELSE
      IF ((bold = 0 ) )
       SET widthstring = (widthstring + (fontpoints * metrics_h->helvetica[asciinum ].size ) )
      ELSE
       SET widthstring = (widthstring + (fontpoints * metrics_h->helvetica_bold[asciinum ].size ) )
      ENDIF
     ENDIF
     SET cnt = (cnt + 1 )
    ENDWHILE
   ENDIF
   IF ((widthstring > 0 ) )
    SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
    SET stat = alterlist (format_text->output_string ,format_text->output_string_cnt )
    SET format_text->output_string[format_text->output_string_cnt ].string = substring (startsubstr ,
     ((inputstrlen - startsubstr ) + 1 ) ,input_string )
    SET format_text->output_string[format_text->output_string_cnt ].bold = bold
    SET format_text->output_string[format_text->output_string_cnt ].x_offset = widthtotal
   ENDIF
   SET widthtotal = (widthtotal + widthstring )
   SET startsubstr = floor (((x_start + ((widthline - widthtotal ) / 2.0 ) ) + 0.5 ) )
   IF ((startsubstr <= 0 ) )
    SET startsubstr = x_start
   ENDIF
   FOR (temp_indx = 1 TO format_text->output_string_cnt )
    SET format_text->output_string[temp_indx ].x_offset = floor ((((format_text->output_string[
     temp_indx ].x_offset + startsubstr ) / 1000.0 ) + 0.5 ) )
   ENDFOR
   RETURN (floor (((startsubstr / 1000.0 ) + 0.5 ) ) )
  END ;Subroutine
  SUBROUTINE  wordwraphelvetica (input_string ,cpi ,line_width ,bold_start )
   IF ((cpi > 0 ) )
    SET fontpoints = floor (((120.0 / cpi ) + 0.5 ) )
   ELSE
    SET fontpoints = 0
   ENDIF
   SET inputstrlen = textlen (input_string )
   SET widthline = (line_width * 1000 )
   SET widthtotal = 0
   SET widthword = 0
   SET widthspace = 0
   SET spacecnt = 0
   SET endword = 1
   SET startsubstr = 1
   SET endlastline = 1
   SET endlastlinepts = 0
   SET state = 0
   SET bold = bold_start
   SET boldstart = 0
   SET nonboldstart = 0
   SET format_text->output_string_cnt = 0
   IF ((widthline > (1015 * fontpoints ) )
   AND (fontpoints <= 120 ) )
    SET cnt = 1
    WHILE ((cnt <= inputstrlen ) )
     SET asciinum = ichar (substring (cnt ,1 ,input_string ) )
     IF ((((asciinum < 32 ) ) OR ((asciinum > 253 ) )) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      SET cnt = (cnt - 1 )
     ELSEIF ((asciinum = 187 ) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      IF ((bold = 0 ) )
       SET boldstart = cnt
       IF (((widthword + widthspace ) > 0 ) )
        SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
        IF ((mod (format_text->output_string_cnt ,10 ) = 1 ) )
         SET stat = alterlist (format_text->output_string ,(format_text->output_string_cnt + 9 ) )
        ENDIF
        SET format_text->output_string[format_text->output_string_cnt ].string = notrim (substring (
          startsubstr ,(cnt - startsubstr ) ,input_string ) )
        SET format_text->output_string[format_text->output_string_cnt ].bold = bold
        SET format_text->output_string[format_text->output_string_cnt ].x_offset = floor (((
         endlastlinepts / 1000.0 ) + 0.5 ) )
        IF ((state = 0 ) )
         SET endlastlinepts = (widthtotal + widthspace )
        ELSE
         SET endlastlinepts = ((widthtotal + widthspace ) + widthword )
        ENDIF
        SET startsubstr = cnt
       ENDIF
       SET bold = 1
      ENDIF
      SET cnt = (cnt - 1 )
     ELSEIF ((asciinum = 171 ) )
      SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
        inputstrlen - cnt ) ,input_string ) )
      SET inputstrlen = (inputstrlen - 1 )
      IF ((bold = 1 ) )
       SET nonboldstart = cnt
       IF (((widthword + widthspace ) > 0 ) )
        SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
        IF ((mod (format_text->output_string_cnt ,10 ) = 1 ) )
         SET stat = alterlist (format_text->output_string ,(format_text->output_string_cnt + 9 ) )
        ENDIF
        SET format_text->output_string[format_text->output_string_cnt ].string = notrim (substring (
          startsubstr ,(cnt - startsubstr ) ,input_string ) )
        SET format_text->output_string[format_text->output_string_cnt ].bold = bold
        SET format_text->output_string[format_text->output_string_cnt ].x_offset = floor (((
         endlastlinepts / 1000.0 ) + 0.5 ) )
        IF ((state = 0 ) )
         SET endlastlinepts = (widthtotal + widthspace )
        ELSE
         SET endlastlinepts = ((widthtotal + widthspace ) + widthword )
        ENDIF
        SET startsubstr = cnt
       ENDIF
       SET bold = 0
      ENDIF
      SET cnt = (cnt - 1 )
     ELSEIF ((asciinum = 32 ) )
      IF ((state = 1 ) )
       SET state = 0
       SET spacecnt = 0
       SET widthtotal = ((widthtotal + widthspace ) + widthword )
       SET widthspace = 0
       SET endword = cnt
      ENDIF
      SET spacecnt = (spacecnt + 1 )
      IF ((bold = 1 ) )
       SET widthspace = (widthspace + (fontpoints * metrics_h->helvetica_bold[asciinum ].size ) )
      ELSE
       SET widthspace = (widthspace + (fontpoints * metrics_h->helvetica[asciinum ].size ) )
      ENDIF
     ELSE
      IF ((state = 0 ) )
       SET state = 1
       SET widthword = 0
      ENDIF
      IF ((bold = 1 ) )
       SET widthchar = (fontpoints * metrics_h->helvetica_bold[asciinum ].size )
      ELSE
       SET widthchar = (fontpoints * metrics_h->helvetica[asciinum ].size )
      ENDIF
      IF ((widthchar = 0 ) )
       SET input_string = concat (substring (1 ,(cnt - 1 ) ,input_string ) ,substring ((cnt + 1 ) ,(
         inputstrlen - cnt ) ,input_string ) )
       SET inputstrlen = (inputstrlen - 1 )
       SET cnt = (cnt - 1 )
      ELSE
       SET widthword = (widthword + widthchar )
       IF ((((widthtotal + widthspace ) + widthword ) >= widthline ) )
        IF ((endlastline = endword ) )
         SET endword = cnt
        ENDIF
        IF (((endword - startsubstr ) > 0 ) )
         SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
         IF ((mod (format_text->output_string_cnt ,10 ) = 1 ) )
          SET stat = alterlist (format_text->output_string ,(format_text->output_string_cnt + 9 ) )
         ENDIF
         IF ((endlastlinepts = 0 ) )
          SET format_text->output_string[format_text->output_string_cnt ].string = trim (substring (
            startsubstr ,(endword - startsubstr ) ,input_string ) ,3 )
         ELSE
          SET format_text->output_string[format_text->output_string_cnt ].string = substring (
           startsubstr ,(endword - startsubstr ) ,input_string )
         ENDIF
         IF ((endword = cnt ) )
          SET startsubstr = cnt
          SET widthword = widthchar
         ELSE
          SET startsubstr = (endword + spacecnt )
         ENDIF
         SET format_text->output_string[format_text->output_string_cnt ].x_offset = floor (((
          endlastlinepts / 1000.0 ) + 0.5 ) )
         SET format_text->output_string[format_text->output_string_cnt ].bold = bold
        ENDIF
        SET endlastline = endword
        SET endlastlinepts = 0
        SET widthtotal = 0
        SET widthspace = 0
       ENDIF
      ENDIF
     ENDIF
     SET cnt = (cnt + 1 )
    ENDWHILE
    SET format_text->output_string_cnt = (format_text->output_string_cnt + 1 )
    SET stat = alterlist (format_text->output_string ,format_text->output_string_cnt )
    SET format_text->output_string[format_text->output_string_cnt ].string = substring (startsubstr ,
     ((inputstrlen - startsubstr ) + 1 ) ,input_string )
    SET format_text->output_string[format_text->output_string_cnt ].x_offset = floor (((
     endlastlinepts / 1000.0 ) + 0.5 ) )
    SET format_text->output_string[format_text->output_string_cnt ].bold = bold
   ENDIF
  END ;Subroutine
 ENDIF
 FREE SET t_record
 RECORD t_record (
   1 resource_cd = f8
   1 location_cd = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 locgroup_id = f8
   1 res_group_id = f8
   1 location_qual_cnt = i4
   1 location_qual [* ]
     2 location_cd = f8
   1 resource_qual_cnt = i4
   1 resource_qual [* ]
     2 resource_cd = f8
     2 person_id = f8
 )
 IF ((request->call_echo_ind = 1 ) )
  CALL echorecord (request )
 ENDIF
 FOR (i_input = 1 TO size (request->qual ,5 ) )
  CASE (trim (request->qual[i_input ].oe_field_meaning ) )
   OF "RESOURCE" :
    SET t_record->resource_cd = request->qual[i_input ].oe_field_value
   OF "BEGDTTM" :
    SET t_record->beg_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
   OF "ENDDTTM" :
    SET t_record->end_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
   OF "RESGROUP" :
    SET t_record->res_group_id = request->qual[i_input ].oe_field_value
   OF "LOCATION" :
    SET t_record->location_cd = request->qual[i_input ].oe_field_value
   OF "LOCGROUP" :
    SET t_record->locgroup_id = request->qual[i_input ].oe_field_value
  ENDCASE
 ENDFOR
 DECLARE script_name = vc WITH protect ,constant ("sch_rpt_rca_loc_res_appt_list" )
 DECLARE dash_line = c129 WITH public ,constant (fillstring (128 ,"-" ) )
 DECLARE happ = i4 WITH protect ,noconstant (0 )
 DECLARE htask = i4 WITH protect ,noconstant (0 )
 DECLARE hstep = i4 WITH protect ,noconstant (0 )
 DECLARE hreply = i4 WITH protect ,noconstant (0 )
 DECLARE hrequest = i4 WITH protect ,noconstant (0 )
 DECLARE hqual = i4 WITH protect ,noconstant (0 )
 DECLARE hschedqual = i4 WITH protect ,noconstant (0 )
 DECLARE happtqual = i4 WITH protect ,noconstant (0 )
 DECLARE xlinewidth = i2 WITH public ,constant (680 )
 DECLARE cpi = i2 WITH public ,noconstant (15 )
 DECLARE lexpandcount = i4 WITH noconstant (0 )
 DECLARE pos = i4 WITH noconstant (0 ) ,public
 DECLARE num = i4 WITH noconstant (0 ) ,public
 FREE SET t_reply
 RECORD t_reply (
   1 reply [* ]
     2 resourcecd = f8
     2 locationcd = f8
     2 resourcename = vc
     2 appointmentdate = dq8
     2 appointmentdur = i4
     2 appointmentlocation = vc
     2 appointmenttype = vc
     2 visitreason = vc
     2 appointmentstatus = vc
     2 appointmentcomment = vc
     2 encounternumber = vc
     2 referringphysician = vc
     2 primaryinsurancepayer = vc
     2 primaryinsurancehealthplan = vc
     2 patientname = vc
     2 patientdateofbirth = vc
     2 patientage = vc
     2 birthtz = i4
     2 mrn = vc
     2 patientgender = vc
     2 patienthomephone = vc
     2 patientworkphone = vc
     2 patientworkext = vc
     2 patientmobliephone = vc
     2 datelong = i4
     2 personid = f8
 
     ;002
     2 auth_nbr = vc
     2 ordering_physician = vc
 
     ;001
     2 procedures[*]
		3	order_id				= f8
		3	order_mnemonic			= c75
     ;
 )
 IF ((t_record->locgroup_id > 0 ) )
  SET get_locgroup_exp_request->security_ind = 1
  SET get_locgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_locgroup_exp_request->qual ,get_locgroup_exp_reply->qual_cnt )
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].sch_object_id = t_record->
  locgroup_id
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_locgroup_exp
  FOR (i_input = 1 TO get_locgroup_exp_reply->qual_cnt )
   SET t_record->location_qual_cnt = get_locgroup_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->location_qual ,t_record->location_qual_cnt )
   FOR (j_input = 1 TO t_record->location_qual_cnt )
    SET t_record->location_qual[j_input ].location_cd = get_locgroup_exp_reply->qual[i_input ].qual[
    j_input ].location_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->location_qual_cnt = 0
  IF ((t_record->location_cd > 0 ) )
   SET t_record->location_qual_cnt = 1
   SET stat = alterlist (t_record->location_qual ,t_record->location_qual_cnt )
   SET t_record->location_qual[1 ].location_cd = t_record->location_cd
  ENDIF
 ENDIF
 IF ((t_record->res_group_id > 0 ) )
  SET get_res_group_exp_request->call_echo_ind = 0
  SET get_res_group_exp_request->security_ind = 1
  SET get_res_group_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_res_group_exp_request->qual ,get_res_group_exp_reply->qual_cnt )
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].res_group_id = t_record->
  res_group_id
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_res_group_exp
  FOR (i_input = 1 TO get_res_group_exp_reply->qual_cnt )
   SET t_record->resource_qual_cnt = get_res_group_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->resource_qual ,t_record->resource_qual_cnt )
   FOR (j_input = 1 TO t_record->resource_qual_cnt )
    SET t_record->resource_qual[j_input ].resource_cd = get_res_group_exp_reply->qual[i_input ].qual[
    j_input ].resource_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->resource_qual_cnt = 0
  IF ((t_record->resource_cd > 0 ) )
   SET t_record->resource_qual_cnt = 1
   SET stat = alterlist (t_record->resource_qual ,t_record->resource_qual_cnt )
   SET t_record->resource_qual[1 ].resource_cd = t_record->resource_cd
  ENDIF
 ENDIF
 EXECUTE crmrtl
 EXECUTE srvrtl
 SET crmstatus = uar_crmbeginapp (5000 ,happ )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin app failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin app(130000) failed with status: " ,cnvtstring (crmstatus ) )
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask (happ ,3202004 ,htask )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin task failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin task(130001) failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq (htask ,"" ,650941 ,hstep )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin req failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin req(650941) failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendtask (htask )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET hrequest = uar_crmgetrequest (hstep )
 FOR (i_loc = 1 TO t_record->location_qual_cnt )
  SET hqual = uar_srvadditem (hrequest ,"locations" )
  SET stat = uar_srvsetdouble (hqual ,"location_cd" ,t_record->location_qual[i_loc ].location_cd )
 ENDFOR
 FOR (i_res = 1 TO t_record->resource_qual_cnt )
  SET hqual = uar_srvadditem (hrequest ,"resources" )
  SET stat = uar_srvsetdouble (hqual ,"resource_cd" ,t_record->resource_qual[i_res ].resource_cd )
 ENDFOR
 SET stat = uar_srvsetdate (hrequest ,"beg_dt_tm" ,cnvtdatetime (t_record->beg_dt_tm ) )
 SET stat = uar_srvsetdate (hrequest ,"end_dt_tm" ,cnvtdatetime (t_record->end_dt_tm ) )
 SET crmstatus = uar_crmperform (hstep )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Perform failed(650941) with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Perform failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendreq (hstep )
  SET stat = uar_crmendtask (htask )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET hreply = uar_crmgetreply (hstep )
 SET reply_cnt = uar_srvgetitemcount (hreply ,"report_details" )
 SET stat = alterlist (t_reply->reply ,reply_cnt )
 FOR (reply_idx = 0 TO (reply_cnt - 1 ) )
  SET replyitem = (reply_idx + 1 )
  SET hreport_details = uar_srvgetitem (hreply ,"report_details" ,reply_idx )
  SET t_reply->reply[replyitem ].resourcename = uar_srvgetstringptr (hreport_details ,"resourceName"
   )
  SET stat = uar_srvgetdate (hreport_details ,"appointmentDate" ,t_reply->reply[replyitem ].
   appointmentdate )
  SET t_reply->reply[replyitem ].appointmentdur = uar_srvgetlong (hreport_details ,"appointmentDur"
   )
  SET t_reply->reply[replyitem ].appointmentlocation = uar_srvgetstringptr (hreport_details ,
   "appointmentLocation" )
  SET t_reply->reply[replyitem ].appointmenttype = uar_srvgetstringptr (hreport_details ,
   "appointmentType" )
  SET t_reply->reply[replyitem ].visitreason = uar_srvgetstringptr (hreport_details ,"visitReason" )
  SET t_reply->reply[replyitem ].appointmentstatus = uar_srvgetstringptr (hreport_details ,
   "appointmentStatus" )
  SET t_reply->reply[replyitem ].appointmentcomment = uar_srvgetstringptr (hreport_details ,
   "appointmentComment" )
  SET t_reply->reply[replyitem ].encounternumber = uar_srvgetstringptr (hreport_details ,
   "encounterNumber" )
  SET t_reply->reply[replyitem ].referringphysician = uar_srvgetstringptr (hreport_details ,
   "referringPhysician" )
  SET t_reply->reply[replyitem ].primaryinsurancepayer = uar_srvgetstringptr (hreport_details ,
   "primaryInsurancePayer" )
  SET t_reply->reply[replyitem ].primaryinsurancehealthplan = uar_srvgetstringptr (hreport_details ,
   "primaryInsuranceHealthPlan" )
  SET t_reply->reply[replyitem ].patientname = uar_srvgetstringptr (hreport_details ,"patientName" )
  SET t_reply->reply[replyitem ].personid = uar_srvgetdouble (hreport_details ,"personId" )
  SET t_reply->reply[replyitem ].patientdateofbirth = uar_srvgetstringptr (hreport_details ,
   "patientDateOfBirth" )
  SET t_reply->reply[replyitem ].patientage = uar_srvgetstringptr (hreport_details ,"patientAge" )
  SET t_reply->reply[replyitem ].birthtz = uar_srvgetlong (hreport_details ,"birthTz" )
  SET t_reply->reply[replyitem ].mrn = uar_srvgetstringptr (hreport_details ,"mrn" )
  SET t_reply->reply[replyitem ].patientgender = uar_srvgetstringptr (hreport_details ,
   "patientGender" )
  SET t_reply->reply[replyitem ].patienthomephone = uar_srvgetstringptr (hreport_details ,
   "patientHomePhone" )
  SET t_reply->reply[replyitem ].patientworkphone = uar_srvgetstringptr (hreport_details ,
   "patientWorkPhone" )
  SET t_reply->reply[replyitem ].patientworkext = uar_srvgetstringptr (hreport_details ,
   "patientWorkExt" )
  SET t_reply->reply[replyitem ].patientmobliephone = uar_srvgetstringptr (hreport_details ,
   "patientMobliePhone" )
  SET t_reply->reply[replyitem ].resourcecd = uar_srvgetdouble (hreport_details ,"resourceCd" )
  SET t_reply->reply[replyitem ].locationcd = uar_srvgetdouble (hreport_details ,"locationCd" )
  SET t_reply->reply[replyitem ].datelong = cnvtdate (cnvtdatetime (t_reply->reply[replyitem ].
    appointmentdate ) )
 ENDFOR
 SET stat = uar_crmendreq (hstep )
 SET stat = uar_crmendtask (htask )
 SET stat = uar_crmendapp (happ )
 ; get person data ;001
 SELECT INTO "nl:"
  FROM (person p )
  WHERE expand (lexpandcount ,1 ,reply_cnt ,p.person_id ,t_reply->reply[lexpandcount ].personid )
  DETAIL
   pos = locateval (num ,1 ,size (t_reply->reply ,5 ) ,p.person_id ,t_reply->reply[num ].personid ) ,
   WHILE ((pos > 0 ) )
    IF ((p.abs_birth_dt_tm != null ) ) t_reply->reply[pos ].patientdateofbirth = format (p
      .abs_birth_dt_tm ,";4;D" )
    ENDIF
    ,pos = locateval (num ,(pos + 1 ) ,size (t_reply->reply ,5 ) ,p.person_id ,t_reply->reply[num ].
     personid )
   ENDWHILE
  WITH nocounter
 ;end select
 
 
 ; get order data ;001
 SELECT INTO "nl:"
 FROM
	SCH_APPT sa
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.sch_state_cd = attach_state_var
		and sea.order_status_cd in (
			order_status_future_var
			, order_status_ordered_var
			, order_status_completed_var
		)
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
 WHERE
	sa.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and expand (lexpandcount ,1 ,reply_cnt ,
	  	sa.person_id ,t_reply->reply[lexpandcount ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[lexpandcount ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[lexpandcount ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[lexpandcount ].appointmentdate ;004 ;005
;	  	uar_get_code_display(sev.appt_type_cd) ,t_reply->reply[lexpandcount ].appointmenttype ;004 ;005
  	)
 	
 
 head sa.person_id
 	null ;005
 
 head sa.appt_location_cd
 	null ;005
 
 head sar.resource_cd
 	null ;005
 	
 head sev.appt_type_cd ;004
 	null ;005
 	
 head sa.beg_dt_tm ;004 ;005
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, reply_cnt,
	  	sa.person_id ,t_reply->reply[numx ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[numx ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[numx ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[numx ].appointmentdate , ;004 ;005
	  	uar_get_code_display(sev.appt_type_cd) ,t_reply->reply[numx ].appointmenttype ;004 ;005
	)
 
 detail
	if (idx > 0)
;		if (cnvtdate(o.current_start_dt_tm) = cnvtdate(t_reply->reply[idx].appointmentdate)) ;005
		if (o.current_start_dt_tm = sa.beg_dt_tm) ;005
			cntx = cntx + 1
 
			call alterlist(t_reply->reply[idx].procedures, cntx) ;005
 
			t_reply->reply[idx].procedures[cntx].order_id = nullval(o.order_id, 0.0)
			t_reply->reply[idx].procedures[cntx].order_mnemonic = nullval(trim(o.order_mnemonic, 3), " ")
		endif
	endif
 
 WITH nocounter, expand = 1
 ;end select
 
 
 ; get scheduled appointment auth data ;002
 SELECT INTO "nl:"
 FROM
	SCH_APPT sa
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.active_ind = 1)
 
	, (inner join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = sed.oe_field_id)
 
	, (inner join OE_FIELD_MEANING ofm on ofm.oe_field_meaning_id = oef.oe_field_meaning_id
		and ofm.oe_field_meaning in ("SCHEDAUTHNBR")
		)
 
 WHERE
	sa.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and expand (lexpandcount ,1 ,reply_cnt ,
	  	sa.person_id ,t_reply->reply[lexpandcount ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[lexpandcount ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[lexpandcount ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[lexpandcount ].appointmentdate
  	)
 
 head sa.person_id
 	call echo("")
 
 head sa.appt_location_cd
 	call echo("")
 
 head sar.resource_cd
 	call echo("")
 
 head sa.beg_dt_tm
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(t_reply->reply, 5),
	  	sa.person_id ,t_reply->reply[numx ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[numx ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[numx ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[numx ].appointmentdate
	)
 
	if (idx > 0)
		t_reply->reply[idx].auth_nbr = trim(sed.oe_field_display_value, 3)
	endif
 
 WITH nocounter, expand = 1
 ;end select
 
 
 ; get encounter auth data ;003
 SELECT INTO "nl:"
 FROM
	ENCOUNTER e
 
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.active_ind = 1)
 
	, (inner join AUTHORIZATION au on au.encntr_id = e.encntr_id
		and au.auth_type_cd = authorization_var
		and au.active_ind = 1)
 
 WHERE
	e.reg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
	and e.active_ind = 1
	and expand (lexpandcount ,1 ,reply_cnt ,
	  	e.person_id ,t_reply->reply[lexpandcount ].personid ,
	  	e.location_cd ,t_reply->reply[lexpandcount ].locationcd ,
	  	ea.alias ,t_reply->reply[lexpandcount ].encounternumber
  	)
 
 head e.person_id
 	call echo("")
 
 head e.location_cd
 	call echo("")
 
 head e.reg_dt_tm
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(t_reply->reply, 5),
	  	e.person_id ,t_reply->reply[numx ].personid ,
	  	e.location_cd ,t_reply->reply[numx ].locationcd ,
	  	ea.alias ,t_reply->reply[numx ].encounternumber
	)
 
	if (idx > 0)
		if (size(t_reply->reply[idx].auth_nbr) = 0)
			t_reply->reply[idx].auth_nbr = trim(au.auth_nbr, 3)
		endif
	endif
 
 WITH nocounter, expand = 1
 ;end select
 
 
 ; get ordering physician data ;002
 SELECT INTO "nl:"
 FROM
	SCH_APPT sa
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.active_ind = 1)
 
	, (inner join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = sed.oe_field_id)
 
	, (inner join OE_FIELD_MEANING ofm on ofm.oe_field_meaning_id = oef.oe_field_meaning_id
		and ofm.oe_field_meaning in ("SCHORDPHYS")
		)
 
 WHERE
	sa.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and expand (lexpandcount ,1 ,reply_cnt ,
	  	sa.person_id ,t_reply->reply[lexpandcount ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[lexpandcount ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[lexpandcount ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[lexpandcount ].appointmentdate
  	)
 
 head sa.person_id
 	call echo("")
 
 head sa.appt_location_cd
 	call echo("")
 
 head sar.resource_cd
 	call echo("")
 
 head sa.beg_dt_tm
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(t_reply->reply, 5),
	  	sa.person_id ,t_reply->reply[numx ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[numx ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[numx ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[numx ].appointmentdate
	)
 
	if (idx > 0)
		t_reply->reply[idx].ordering_physician = trim(sed.oe_field_display_value, 3)
	endif
 
 WITH nocounter, expand = 1
 ;end select
 
 IF ((t_record->resource_qual_cnt > 0 ) )
  SELECT INTO  $1
   begdateformatted = t_reply->reply[d.seq ].datelong ,
   location = t_reply->reply[d.seq ].appointmentlocation ,
   locationcd = t_reply->reply[d.seq ].locationcd ,
   resource = t_reply->reply[d.seq ].resourcename ,
   resourcecd = t_reply->reply[d.seq ].resourcecd ,
   begdate = t_reply->reply[reply_idx ].appointmentdate ,
   appttime = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" )
   FROM (dummyt d WITH seq = value (reply_cnt ) )
   PLAN (d
    WHERE (d.seq <= value (reply_cnt ) ) )
   ORDER BY begdateformatted ,
    resource ,
    resourcecd ,
    location ,
    locationcd
   HEAD REPORT
    generic_ind = 0 ,
    y_pos = 0 ,
    row 0 ,
    breakpage = 1
   HEAD PAGE
    CALL print ("{PS/792 0 translate 90 rotate/}" )
   HEAD begdateformatted
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD location
    null
   HEAD locationcd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD resourcecd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   DETAIL
    IF ((breakpage = 1 ) ) breakpage = 0 ,row 0 ,row + 1 ,"{F/0}{CPI/9}{LPI/5}" ,
     CALL print (calcpos (261 ,36 ) ) ,"{B}R E S O U R C E   S C H E D U L E{ENDB}" ,row + 1 ,row +
     1 ,"{F/0}{CPI/15}{LPI/5}" ,"{POS/702/54}Page " ,curpage "###" ,"{F/0}{CPI/11}{LPI/6}" ,
     "{POS/36/54}{B}Location: {ENDB}" ,t_reply->reply[d.seq ].appointmentlocation ,row + 1 ,
     "{POS/36/67}{B}Resource: {ENDB}" ,t_reply->reply[d.seq ].resourcename ,row + 1 ,datestring =
     format (t_reply->reply[d.seq ].appointmentdate ,"MM/DD/YYYY;;Q" ) ,"{POS/36/80}{B}Date: {ENDB}"
    ,datestring ,row + 1 ,
     CALL print (calcpos (36 ,93 ) ) ,"{B}Time" ,
     CALL print (calcpos (72 ,93 ) ) ,"Dur" ,
     CALL print (calcpos (144 ,93 ) ) ,"Name" ,
     CALL print (calcpos (360 ,93 ) ) ,"Appointment Type" ,
     CALL print (calcpos (540 ,93 ) ) ,"Visit Reason" ,
     CALL print (calcpos (684 ,93 ) ) ,"Status  {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,106 ) ) ,"{B}MRN" ,
     CALL print (calcpos (144 ,106 ) ) ,"DOB" ,
     CALL print (calcpos (216 ,106 ) ) ,"Age" ,
     CALL print (calcpos (270 ,106 ) ) ,"Sex" ,
     CALL print (calcpos (360 ,106 ) ) ,"Encounter" ,
     CALL print (calcpos (540 ,106 ) ) ,"Referring Physician {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,119 ) ) ,"{B}Home Phone" ,
     CALL print (calcpos (144 ,119 ) ) ,"Work Phone" ,
     CALL print (calcpos (216 ,119 ) ) ,"Ext" ,
     CALL print (calcpos (270 ,119 ) ) ,"Mobile Phone" ,
     CALL print (calcpos (360 ,119 ) ) ,"Primary Payer" ,
     CALL print (calcpos (540 ,119 ) ) ,"Health Plan {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,132 ) ) ,"{B}Comment" , ;001
     CALL print (calcpos (360 ,132 ) ) ,"Order" , ;001
     CALL print (calcpos (540 ,132 ) ) ,"Auth Number {ENDB}" ,row + 1 , ;002
     CALL print (calcpos (36 ,133 ) ) ,"{B}{REPEAT/108/_/}{ENDB}" ,row + 1 ,y_pos = 146 ,row + 1
    ENDIF
    ,row + 1 ,
    "{F/4}{CPI/15}{LPI/6}" ,
    datestring = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" ) ,
    CALL print (calcpos (36 ,y_pos ) ) ,
    datestring ,
    CALL print (calcpos (72 ,y_pos ) ) ,
    t_reply->reply[d.seq ].appointmentdur "####" ,
    IF ((size (t_reply->reply[d.seq ].patientname ) > 60 ) ) field60 = substring (1 ,60 ,t_reply->
      reply[d.seq ].patientname ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field60
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientname
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmenttype ) > 36 ) ) field36 = substring (1 ,36 ,t_reply
      ->reply[d.seq ].appointmenttype ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field36
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmenttype
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].visitreason ) > 30 ) ) field30 = substring (1 ,30 ,t_reply->
      reply[d.seq ].visitreason ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].visitreason
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmentstatus ) > 30 ) ) field30 = substring (1 ,30 ,
      t_reply->reply[d.seq ].appointmentstatus ) ,
     CALL print (calcpos (684 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (684 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentstatus
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].mrn ) > 15 ) ) field15 = substring (1 ,15 ,t_reply->reply[d
      .seq ].mrn ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field15
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].mrn
    ENDIF
    ,
    CALL print (calcpos (144 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientdateofbirth ,
    CALL print (calcpos (216 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientage ,
    CALL print (calcpos (270 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientgender ,
    IF ((size (t_reply->reply[d.seq ].encounternumber ) > 30 ) ) field30 = substring (1 ,30 ,t_reply
      ->reply[d.seq ].encounternumber ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].encounternumber
    ENDIF
    ,
 
    ;002
    if (size (t_reply->reply[d.seq ].referringphysician ) > 0)
	    IF ((size (t_reply->reply[d.seq ].referringphysician ) > 45 ) ) field45 = substring (1 ,45 ,
	      t_reply->reply[d.seq ].referringphysician ) ,
	     CALL print (calcpos (540 ,y_pos ) ) ,field45
	    ELSE
	     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].referringphysician
	    ENDIF
    else
	    IF ((size (t_reply->reply[d.seq ].ordering_physician ) > 45 ) ) field45 = substring (1 ,45 ,
	      t_reply->reply[d.seq ].ordering_physician ) ,
	     CALL print (calcpos (540 ,y_pos ) ) ,field45
	    ELSE
	     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].ordering_physician
	    ENDIF
    endif
    ;
 
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].patienthomephone ) > 22 ) ) field22 = substring (1 ,22 ,t_reply
      ->reply[d.seq ].patienthomephone ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].patienthomephone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientworkphone ) > 22 ) ) field22 = substring (1 ,22 ,t_reply
      ->reply[d.seq ].patientworkphone ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientworkphone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientworkext ) > 15 ) ) field22 = substring (1 ,22 ,t_reply->
      reply[d.seq ].patientworkext ) ,
     CALL print (calcpos (216 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (216 ,y_pos ) ) ,t_reply->reply[d.seq ].patientworkext
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientmobliephone ) > 22 ) ) field22 = substring (1 ,22 ,
      t_reply->reply[d.seq ].patientmobliephone ) ,
     CALL print (calcpos (270 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (270 ,y_pos ) ) ,t_reply->reply[d.seq ].patientmobliephone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].primaryinsurancepayer ) > 45 ) ) field45 = substring (1 ,45 ,
      t_reply->reply[d.seq ].primaryinsurancepayer ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field45
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].primaryinsurancepayer
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].primaryinsurancehealthplan ) > 45 ) ) field45 = substring (1 ,
      45 ,t_reply->reply[d.seq ].primaryinsurancehealthplan ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field45
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].primaryinsurancehealthplan
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].appointmentcomment ) > 130 ) )
     CALL wordwraphelvetica (t_reply->reply[d.seq ].appointmentcomment ,cpi ,xlinewidth ,0 ) ,
     IF ((format_text->output_string_cnt > 1 ) )
      FOR (wrapcnt = 1 TO 2 )
       IF ((wrapcnt = 2 ) ) field150 = format_text->output_string[wrapcnt ].string ,
        IF ((format_text->output_string_cnt > 2 ) ) field150 = build (field150 ,"..." )
        ENDIF
        ,
        CALL print (calcpos (36 ,y_pos ) ) ,field150
       ELSE
        CALL print (calcpos (36 ,y_pos ) ) ,format_text->output_string[wrapcnt ].string ,y_pos = (
        y_pos + 13 ) ,row + 1
       ENDIF
      ENDFOR
     ELSE
      CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentcomment
     ENDIF
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentcomment
    ENDIF
    ,
 
    ;002
    IF ((size (t_reply->reply[d.seq ].auth_nbr ) > 20 ) ) field20 = substring (1 ,
      20 ,t_reply->reply[d.seq ].auth_nbr ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field20
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].auth_nbr
    ENDIF
    ,
 	;
 
    ;001
    fieldOrder = fillstring(75, " ")
    ocnt = size (t_reply->reply[d.seq ].procedures, 5)
 
    for(i = 1 to ocnt)
	    IF (t_reply->reply[d.seq ].procedures[i].order_id > 0.0)
	    	fieldOrder = substring(1, 75, t_reply->reply[d.seq ].procedures[i].order_mnemonic)
 
	    	if (size(trim(fieldOrder, 3)) > 48) ; limit display length of order
	    		fieldOrder = build(substring(1, 45, fieldOrder), "...")
	    	endif
	     CALL print (calcpos (360 ,y_pos ) ) ,fieldOrder
	    ENDIF
 
	    y_pos = (y_pos + 13 )
    endfor
    ;
 
    ,y_pos = (y_pos + 26 ) ,
    row + 2 ,
    IF ((y_pos > 511 ) )
     CALL print (calcpos (350 ,y_pos ) ) ,"*** To be continued ***" ,breakpage = 1 ,
     BREAK,row 0
    ENDIF
   WITH nullreport ,dio = postscript ,landscape ,nocounter ,maxcol = 270 ,formfeed = post
  ;end select
 ELSE
  SELECT INTO  $1
   begdateformatted = t_reply->reply[d.seq ].datelong ,
   location = t_reply->reply[d.seq ].appointmentlocation ,
   locationcd = t_reply->reply[d.seq ].locationcd ,
   resource = t_reply->reply[d.seq ].resourcename ,
   resourcecd = t_reply->reply[d.seq ].resourcecd ,
   begdate = t_reply->reply[reply_idx ].appointmentdate ,
   appttime = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" )
   FROM (dummyt d WITH seq = value (reply_cnt ) )
   PLAN (d
    WHERE (d.seq <= value (reply_cnt ) ) )
   ORDER BY begdateformatted ,
    location ,
    locationcd ,
    resource ,
    resourcecd
   HEAD REPORT
    generic_ind = 0 ,
    y_pos = 0 ,
    row 0 ,
    breakpage = 1
   HEAD PAGE
    CALL print ("{PS/792 0 translate 90 rotate/}" )
   HEAD begdateformatted
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD location
    null
   HEAD locationcd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD resourcecd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   DETAIL
    IF ((breakpage = 1 ) ) breakpage = 0 ,row 0 ,row + 1 ,"{F/0}{CPI/9}{LPI/5}" ,
     CALL print (calcpos (261 ,36 ) ) ,"{B}R E S O U R C E   S C H E D U L E{ENDB}" ,row + 1 ,row +
     1 ,"{F/0}{CPI/15}{LPI/5}" ,"{POS/702/54}Page " ,curpage "###" ,"{F/0}{CPI/11}{LPI/6}" ,
     "{POS/36/54}{B}Location: {ENDB}" ,t_reply->reply[d.seq ].appointmentlocation ,row + 1 ,
     "{POS/36/67}{B}Resource: {ENDB}" ,t_reply->reply[d.seq ].resourcename ,row + 1 ,datestring =
     format (t_reply->reply[d.seq ].appointmentdate ,"MM/DD/YYYY;;Q" ) ,"{POS/36/80}{B}Date: {ENDB}"
    ,datestring ,row + 1 ,
     CALL print (calcpos (36 ,93 ) ) ,"{B}Time" ,
     CALL print (calcpos (72 ,93 ) ) ,"Dur" ,
     CALL print (calcpos (144 ,93 ) ) ,"Name" ,
     CALL print (calcpos (360 ,93 ) ) ,"Appointment Type" ,
     CALL print (calcpos (540 ,93 ) ) ,"Visit Reason" ,
     CALL print (calcpos (684 ,93 ) ) ,"Status  {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,106 ) ) ,"{B}MRN" ,
     CALL print (calcpos (144 ,106 ) ) ,"DOB" ,
     CALL print (calcpos (216 ,106 ) ) ,"Age" ,
     CALL print (calcpos (270 ,106 ) ) ,"Sex" ,
     CALL print (calcpos (360 ,106 ) ) ,"Encounter" ,
     CALL print (calcpos (540 ,106 ) ) ,"Referring Physician {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,119 ) ) ,"{B}Home Phone" ,
     CALL print (calcpos (144 ,119 ) ) ,"Work Phone" ,
     CALL print (calcpos (216 ,119 ) ) ,"Ext" ,
     CALL print (calcpos (270 ,119 ) ) ,"Mobile Phone" ,
     CALL print (calcpos (360 ,119 ) ) ,"Primary Payer" ,
     CALL print (calcpos (540 ,119 ) ) ,"Health Plan {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,132 ) ) ,"{B}Comment" , ;001
     CALL print (calcpos (360 ,132 ) ) ,"Order" , ;001
     CALL print (calcpos (540 ,132 ) ) ,"Auth Number {ENDB}" ,row + 1 , ;002
     CALL print (calcpos (36 ,133 ) ) ,"{B}{REPEAT/108/_/}{ENDB}" ,row + 1 ,y_pos = 146 ,row + 1
    ENDIF
    ,row + 1 ,
    "{F/4}{CPI/15}{LPI/6}" ,
    datestring = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" ) ,
    CALL print (calcpos (36 ,y_pos ) ) ,
    datestring ,
    CALL print (calcpos (72 ,y_pos ) ) ,
    t_reply->reply[d.seq ].appointmentdur "####" ,
    IF ((size (t_reply->reply[d.seq ].patientname ) > 60 ) ) field60 = substring (1 ,60 ,t_reply->
      reply[d.seq ].patientname ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field60
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientname
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmenttype ) > 36 ) ) field36 = substring (1 ,36 ,t_reply
      ->reply[d.seq ].appointmenttype ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field36
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmenttype
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].visitreason ) > 30 ) ) field30 = substring (1 ,30 ,t_reply->
      reply[d.seq ].visitreason ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].visitreason
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmentstatus ) > 30 ) ) field30 = substring (1 ,30 ,
      t_reply->reply[d.seq ].appointmentstatus ) ,
     CALL print (calcpos (684 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (684 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentstatus
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].mrn ) > 15 ) ) field15 = substring (1 ,15 ,t_reply->reply[d
      .seq ].mrn ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field15
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].mrn
    ENDIF
    ,
    CALL print (calcpos (144 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientdateofbirth ,
    CALL print (calcpos (216 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientage ,
    CALL print (calcpos (270 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientgender ,
    IF ((size (t_reply->reply[d.seq ].encounternumber ) > 30 ) ) field30 = substring (1 ,30 ,t_reply
      ->reply[d.seq ].encounternumber ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].encounternumber
    ENDIF
    ,
 
    ;002
    if (size (t_reply->reply[d.seq ].referringphysician ) > 0)
	    IF ((size (t_reply->reply[d.seq ].referringphysician ) > 45 ) ) field45 = substring (1 ,45 ,
	      t_reply->reply[d.seq ].referringphysician ) ,
	     CALL print (calcpos (540 ,y_pos ) ) ,field45
	    ELSE
	     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].referringphysician
	    ENDIF
    else
	    IF ((size (t_reply->reply[d.seq ].ordering_physician ) > 45 ) ) field45 = substring (1 ,45 ,
	      t_reply->reply[d.seq ].ordering_physician ) ,
	     CALL print (calcpos (540 ,y_pos ) ) ,field45
	    ELSE
	     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].ordering_physician
	    ENDIF
    endif
    ;
 
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].patienthomephone ) > 22 ) ) field22 = substring (1 ,22 ,t_reply
      ->reply[d.seq ].patienthomephone ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].patienthomephone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientworkphone ) > 22 ) ) field22 = substring (1 ,22 ,t_reply
      ->reply[d.seq ].patientworkphone ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientworkphone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientworkext ) > 15 ) ) field22 = substring (1 ,22 ,t_reply->
      reply[d.seq ].patientworkext ) ,
     CALL print (calcpos (216 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (216 ,y_pos ) ) ,t_reply->reply[d.seq ].patientworkext
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].patientmobliephone ) > 22 ) ) field22 = substring (1 ,22 ,
      t_reply->reply[d.seq ].patientmobliephone ) ,
     CALL print (calcpos (270 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (270 ,y_pos ) ) ,t_reply->reply[d.seq ].patientmobliephone
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].primaryinsurancepayer ) > 45 ) ) field45 = substring (1 ,45 ,
      t_reply->reply[d.seq ].primaryinsurancepayer ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field45
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].primaryinsurancepayer
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].primaryinsurancehealthplan ) > 45 ) ) field45 = substring (1 ,
      45 ,t_reply->reply[d.seq ].primaryinsurancehealthplan ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field45
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].primaryinsurancehealthplan
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].appointmentcomment ) > 130 ) )
     CALL wordwraphelvetica (t_reply->reply[d.seq ].appointmentcomment ,cpi ,xlinewidth ,0 ) ,
     IF ((format_text->output_string_cnt > 1 ) )
      FOR (wrapcnt = 1 TO 2 )
       IF ((wrapcnt = 2 ) ) field150 = format_text->output_string[wrapcnt ].string ,
        IF ((format_text->output_string_cnt > 2 ) ) field150 = build (field150 ,"..." )
        ENDIF
        ,
        CALL print (calcpos (36 ,y_pos ) ) ,field150
       ELSE
        CALL print (calcpos (36 ,y_pos ) ) ,format_text->output_string[wrapcnt ].string ,y_pos = (
        y_pos + 13 ) ,row + 1
       ENDIF
      ENDFOR
     ELSE
      CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentcomment
     ENDIF
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentcomment
    ENDIF
    ,
 
    ;002
    IF ((size (t_reply->reply[d.seq ].auth_nbr ) > 20 ) ) field20 = substring (1 ,
      20 ,t_reply->reply[d.seq ].auth_nbr ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field20
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].auth_nbr
    ENDIF
    ,
 	;
 
    ;001
    fieldOrder = fillstring(75, " ")
    ocnt = size (t_reply->reply[d.seq ].procedures, 5)
 
    for(i = 1 to ocnt)
	    IF (t_reply->reply[d.seq ].procedures[i].order_id > 0.0)
	    	fieldOrder = substring(1, 75, t_reply->reply[d.seq ].procedures[i].order_mnemonic)
 
	    	if (size(trim(fieldOrder, 3)) > 48) ; limit display length of order
	    		fieldOrder = build(substring(1, 45, fieldOrder), "...")
	    	endif
	     CALL print (calcpos (360 ,y_pos ) ) ,fieldOrder
	    ENDIF
 
	    y_pos = (y_pos + 13 )
    endfor
    ;
 
    ,y_pos = (y_pos + 26 ) ,
    row + 2 ,
    IF ((y_pos > 511 ) )
     CALL print (calcpos (350 ,y_pos ) ) ,"*** To be continued ***" ,breakpage = 1 ,
     BREAK,row 0
    ENDIF
   WITH nullreport ,dio = postscript ,landscape ,nocounter ,maxcol = 270 ,formfeed = post
  ;end select
 ENDIF
#exit_script
END GO
 

DROP PROGRAM chs_wklist_cust_print_temp:dba go
CREATE PROGRAM chs_wklist_cust_print_temp:dba
 
PROMPT
    "Output to File/Printer/MINE" = "MINE",
    "JSON Request:" = ""
WITH outdev,jsondata
 
%i ccluserdir:chs_tn_mp_script_logging.inc
%i ccluserdir:chs_tn_mp_common.inc
 
;====================
; Record Structures
;====================
FREE RECORD printdata
RECORD printdata(
	1 person_printing_name 				= vc
	1 print_group_flag					= i2 ;0=Simplified 1=Detailed
 
	1 display_columns
		2 location 						= i2 ;0=No 1=Yes
		2 patient						= i2 ;0=No 1=Yes
		2 consultant					= i2 ;0=No 1=Yes
		2 lengthOfStay					= i2 ;0=No 1=Yes
		2 notes							= i2 ;0=No 1=Yes
	1 patients [*]
		2 person_id 					= f8
		2 encntr_id 					= f8
		2 encntr_type 					= vc
		2 location_data
			3 facility 					= vc
			3 unit 						= vc
			3 room 						= vc
			3 bed 						= vc
		2 patient_data
			3 name_full					= vc
			3 age						= vc
			3 mrn						= vc
			3 fin						= vc
		2 sex 							= vc
		2 primary_contact				= vc
		2 consultant
			3 adm_phy					= vc
			3 att_phy					= vc
			3 consul_phy				= vc
			3 cover_phy					= vc
		2 length_of_stay				= i4
		2 notes 						= vc
		2 admit_date					= vc
		2 total_hours					= i4
 
%i cclsource:status_block.inc
	)
 
	;====================
	; Declare Variables
	;====================
	DECLARE json_blob_in				= vc WITH protect,noconstant("")
	DECLARE run_cust_ccl_prg			= i4 WITH protect,noconstant(0)
	DECLARE inerror_cd 					= f8 WITH protect,constant(uar_get_code_by("MEANING",8,"INERROR"))
	DECLARE notdone_cd 					= f8 WITH protect,constant(uar_get_code_by("MEANING",8,"NOT DONE"))
	DECLARE complete_cd 				= f8 WITH protect,constant(uar_get_code_by("MEANING",79,"COMPLETE"))
	DECLARE mrn_cd						= f8 WITH protect,constant(uar_get_code_by("MEANING",319,"MRN"))
	DECLARE fin_cd						= f8 WITH protect,constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
	DECLARE date_str                    = vc WITH protect,constant("MM/DD/YYYY;;Q")
 
	DECLARE column_consultant_str		= vc WITH protect,constant("MP_VB_COL_CONSULTANT")
	DECLARE column_patient_str			= vc WITH protect,constant("MP_VB_COL_PATIENT")
	DECLARE column_location_str			= vc WITH protect,constant("MP_VB_COL_LOCATION")
	DECLARE column_lengthofstay_str		= vc WITH protect,constant("MP_VB_COL_LENGTH_OF_STAY")
	DECLARE column_notes_str			= vc WITH protect,constant("MP_VB_COL_NOTES")
 
	;======================
	; Declare Subroutines
	;======================
	DECLARE getprintdata(null)			= null
	DECLARE getusername(null)			= null
	DECLARE getFin(nul)					= null
	DECLARE getAttPhy(NULL)				= NULL
	DECLARE getConPhy(null)				= null
	DECLARE getCovPhy(null)				= null
	DECLARE getAddPhy(null)				= null
	DECLARE getPrimaryContact(null)		= null
 
	;=====================
	; Main Program Logic
	;=====================
	CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 
	SET printdata->status_data.status = "F"
	IF(validate(print_options) = 0)
		IF(validate(request->blob_in,"") != "")
			SET json_blob_in = trim(request->blob_in,3)
		ELSEIF(size(trim( $JSONDATA,3)) > 0)
			SET json_blob_in = trim($JSONDATA,3)
		ELSE
			CALL populate_subeventstatus_rec("PopulateRequest","F","MISSING_JSON_INPUT","No JSON data provided to script.",printdata)
			GO TO exit_script
		ENDIF
		SET stat = cnvtjsontorec(json_blob_in)
		IF(error_message(1) = 1)
			CALL populate_subeventstatus_rec("PopulateRequest","F","CNVTJSONTOREC_ERROR","Error encountered during cnvtjsontorec().",
				printdata)
			GO TO exit_script
		ENDIF
 
	ELSE
		SET run_cust_ccl_prg = 1
	ENDIF
 
 
 
	IF(validate(print_options,"-999") = "-999")
		CALL populate_subeventstatus_rec("ValidateRequest",
			"F","MISSING_PRINT_OPTIONS_RECORD","Supplied JSON record not named 'PRINT_OPTIONS'.",printdata)
		GO TO exit_script
	ELSE
		IF(validate(debug_ind,0) = 1)
			CALL echorecord(print_options)
		ENDIF
	ENDIF
 
	; Check to see if they want Simplified or Detailed report
	IF (print_options->PRINT_STYLE = "simplified")
		set printData->print_group_flag = 0 ; Simplified
	ELSE
		SET printData->print_group_flag = 1 ; Detailed
	ENDIF
 
	; Save off list of columns which are active for the current user
	FOR (index = 1 to size(print_options->column_list.columns,5))
		CASE (print_options->column_list.columns[index].reportmean)
			OF column_consultant_str : ;1
				set printdata->display_columns.consultant = print_options->column_list.columns[index].active
			OF column_patient_str : ;2
				set printdata->display_columns.patient = print_options->column_list.columns[index].active
			OF column_location_str : ;3
				set printdata->display_columns.location = print_options->column_list.columns[index].active
			OF column_lengthofstay_str : ;4
				set printdata->display_columns.lengthOfStay = print_options->column_list.columns[index].active
			OF column_notes_str : ;5
 				set printdata->display_columns.notes = print_options->column_list.columns[index].active
		ENDCASE
	ENDFOR
 
	CALL getusername(null)  ; Get Name of person printing report
	CALL getprintdata(null) ; Query for the required data
	CALL getFin(null) ; get FIN no of patient
	CALL getAttPhy(null)
	CALL getConPhy(null)
	CALL getCovPhy(null)
	CALL getAddPhy(null)
	CALL getPrimaryContact(null)
 
 
	IF(run_cust_ccl_prg >= 0)
		CALL createprinttemplatelayout(null)
	ENDIF
 
	;==================
	; Subroutines
	;==================
	SUBROUTINE  getusername(null)
		CALL log_message("In getUserName()",log_level_debug)
 
		DECLARE begin_date_time = dq8 WITH constant(curtime3),private
 
		SELECT INTO "nl:"
		FROM person p
		WHERE p.person_id = print_options->user_context.user_id
		DETAIL
			printdata->person_printing_name = p.name_full_formatted
		WITH nocounter
 
		CALL log_message(build("Exit getUserName(), Elapsed time in seconds:",((curtime3 - begin_date_time) / 100)),log_level_debug)
	END ;Subroutine
 
 
	SUBROUTINE  getPrimaryContact(null)
		DECLARE primary_contact		= f8 WITH protect, constant(UAR_GET_CODE_BY("DISPLAYKEY",72,"PRIMARYCONTACT"))
	 	DECLARE ecnt 			= i4  WITH protect,noconstant(0)
	 	DECLARE eidx 			= i4  WITH protect,noconstant(0)
	 	DECLARE m_idx			= i4 WITH protect, noconstant(0)
		DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
 
	SELECT INTO "nl:"
 
	FROM
		CLINICAL_EVENT   CE
		, PCT_CARE_TEAM   pct
		, prsnl   p
 
	Plan ce
		WHERE expand(eidx, 1, size(print_options->qual,5), ce.encntr_id, print_options->qual[eidx].encntr_id)
		and CE.EVENT_CD =  primary_contact
 
	join pct
		where pct.orig_pct_team_id = cnvtreal(trim(substring(18,25,ce.result_val),3))
		and pct.active_ind = 1
		and pct.orig_pct_team_id = pct.pct_care_team_id
 
	join p
		where p.person_id = pct.prsnl_id
		and p.name_full_formatted is not null
 
	ORDER BY
		ce.encntr_id, p.UPDT_DT_TM   DESC
 
	;detail
	HEAD ce.encntr_id
 
			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), ce.encntr_id, printdata->patients[gm_idx].encntr_id)
			printdata->patients[m_idx].primary_contact = p.name_full_formatted
 
	WITH NOCOUNTER,  SEPARATOR=" ", FORMAT
	END ;Subroutine getPrimaryContact
 
 
	SUBROUTINE  getprintdata(null)
		CALL log_message("In getPrintData()",log_level_debug)
 
		DECLARE begin_date_time = dq8 WITH constant(curtime3),private
		DECLARE eidx 			= i4  WITH protect,noconstant(0)
		DECLARE ecnt 			= i4  WITH protect,noconstant(0)
		DECLARE dob 			= dq8 WITH protect,noconstant(0)
		DECLARE totalHours 		= i4 WITH protect, noconstant(0)
 
		; Query Patient Info
		SELECT INTO "nl:"
			dob = p.birth_dt_tm
		FROM encounter e
			,person p
			,encntr_alias ea
			,pct_ipass   pi
			,encntr_domain ed
		PLAN e
 
			WHERE expand(eidx, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[eidx].encntr_id)
			AND e.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND e.active_ind = 1
		JOIN p
			WHERE p.person_id = e.person_id
			AND p.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND p.active_ind = 1
		JOIN ea
			WHERE ea.encntr_id = e.encntr_id
			AND ea.encntr_alias_type_cd = mrn_cd
			AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND ea.active_ind = 1
		JOIN pi
			WHERE pi.encntr_id = outerjoin(e.encntr_id)
			AND pi.begin_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
			AND pi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
			AND pi.active_ind = outerjoin(1)
		JOIN ed
			WHERE ed.person_id = outerjoin(p.person_id)
			AND ed.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
			AND ed.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
			AND ed.active_ind = outerjoin(1)
		ORDER BY  p.person_id
 
		HEAD p.person_id
			ecnt = ecnt + 1
			IF(size(printdata->patients,5) < ecnt)
				stat = alterlist(printdata->patients,ecnt + 5)
			ENDIF
			printdata->patients[ecnt].person_id = p.person_id
			printdata->patients[ecnt].encntr_id = e.encntr_id
			printdata->patients[ecnt].encntr_type = uar_get_code_display(e.encntr_type_cd)
			printdata->patients[ecnt].admit_date = format(e.reg_dt_tm, date_str)
			IF (e.disch_dt_tm < CURRENT_DATE_TIME and e.disch_dt_tm > 0)
				printdata->patients[ecnt].total_hours = datetimediff(e.disch_dt_tm, e.reg_dt_tm,3)
			ELSE
			printdata->patients[ecnt].total_hours = datetimediff(CURRENT_DATE_TIME, e.reg_dt_tm,3)
			ENDIF
			totalHours = datetimediff(CURRENT_DATE_TIME, e.reg_dt_tm,3)
 
			printdata->patients[ecnt].length_of_stay = (totalHours/ 24)
			; Patient Data
			printdata->patients[ecnt].patient_data.name_full = p.name_full_formatted
			printdata->patients[ecnt].patient_data.age = SUBSTRING(1,3,(CNVTAGE(p.birth_dt_tm)))
			printdata->patients[ecnt].sex = SUBSTRING(1,1,(uar_get_code_display(p.sex_cd)))
	   		printdata->patients[ecnt].patient_data.mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
			; Location Data
			printdata->patients[ecnt].location_data.facility = uar_get_code_display(e.loc_facility_cd)
			printdata->patients[ecnt].location_data.unit = uar_get_code_display(e.loc_nurse_unit_cd)
			printdata->patients[ecnt].location_data.room = uar_get_code_display(e.loc_room_cd)
			printdata->patients[ecnt].location_data.bed = uar_get_code_display(e.loc_bed_cd)
		FOOT REPORT
			stat = alterlist(printdata->patients,ecnt)
		WITH maxrec=1, nocounter
 
		CALL log_message(build("Exit getPrintData(), Elapsed time in seconds:",((curtime3 -	begin_date_time) / 100)),log_level_debug)
	end ;Subroutine
 
	SUBROUTINE getFin(null)
		CALL log_message("In getFIN()",log_level_debug)
 
		DECLARE begin_date_time = dq8 WITH constant(curtime3),private
		DECLARE fidx 			= i4  WITH protect,noconstant(0)
		DECLARE fcnt 			= i4  WITH protect,noconstant(0)
		DECLARE m_idx			= i4 WITH protect, noconstant(0)
		DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
 
		; Query Patient Info
		SELECT INTO "nl:"
		FROM encounter e
			,person p
			,encntr_alias ea
		PLAN e
 
			WHERE expand(fidx, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[fidx].encntr_id)
			AND e.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND e.active_ind = 1
		JOIN p
			WHERE p.person_id = e.person_id
			AND p.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND p.active_ind = 1
		JOIN ea
			WHERE ea.encntr_id = e.encntr_id
			AND ea.encntr_alias_type_cd = fin_cd
			AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
			AND ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			AND ea.active_ind = 1
 
		ORDER BY p.person_id
 
		HEAD p.person_id
 
			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), e.encntr_id, printdata->patients[gm_idx].encntr_id)
			printdata->patients[m_idx].patient_data.fin = cnvtalias(ea.alias,ea.alias_pool_cd)
 
	end ;Subroutine
 
	SUBROUTINE getAttPhy(null)
 
	DECLARE ATT_PHY 		= F8 with public, constant (UAR_GET_CODE_BY("DISPLAY_KEY",333,"ATTENDINGPHYSICIAN"))
	DECLARE atnt			= i4 WITH protect, noconstant(0)
	DECLARE eidx1 			= i4  WITH protect,noconstant(0)
	DECLARE m_idx			= i4 WITH protect, noconstant(0)
	DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
 
	;Attending Physician
		SELECT into "nl:"
		FROM
		  	  prsnl p
			, ENCNTR_PRSNL_RELTN e
 
	 	PLAN e
 
	 		WHERE expand(eidx1, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[eidx1].encntr_id)
	    	and e.ENCNTR_PRSNL_R_CD = ATT_PHY
	     	AND e.active_ind = 1
	    	AND e.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME)
 
		JOIN p
	    	WHERE p.person_id = e.prsnl_person_id
		order by p.updt_dt_tm desc
 
		DETAIL
 
			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), e.encntr_id, printdata->patients[gm_idx].encntr_id)
			printdata->patients[m_idx].consultant.att_phy = p.name_full_formatted
 
	END
 
;	SUBROUTINE getConPhy(null)
;	DECLARE CON_PHY 		= F8 with public, constant (UAR_GET_CODE_BY("DISPLAY_KEY",333,"CONSULTINGPHYSICIAN"))
;	DECLARE cpnt			= i4 WITH protect, noconstant(0)
;	DECLARE eidx2 			= i4  WITH protect,noconstant(0)
;	DECLARE m_idx			= i4 WITH protect, noconstant(0)
;	DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
;
;	; Consulting Physician
;		SELECT into "nl:"
;		FROM
;		  	  prsnl p
;			, ENCNTR_PRSNL_RELTN e
;
;	 	PLAN e
;
;	    	WHERE expand(eidx2, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[eidx2].encntr_id)
;	    	and e.ENCNTR_PRSNL_R_CD = CON_PHY
;	     	AND e.active_ind = 1
;	    	AND e.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME)
;
;		JOIN p
;	    	WHERE p.person_id = e.prsnl_person_id
;
;		DETAIL
;
;			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), e.encntr_id, printdata->patients[gm_idx].encntr_id)
;			printdata->patients[m_idx].consultant.consul_phy = p.name_full_formatted
;
;	END
 
 
 
 
 SUBROUTINE  getconphy (null )
  DECLARE con_phy = f8 WITH public ,constant (uar_get_code_by ("DISPLAY_KEY" ,333 ,
    "CONSULTINGPHYSICIAN" ) )
  DECLARE cpnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx2 = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
from
    dcp_shift_assignment dsa
    , pct_care_team pct
    , prsnl p
plan dsa where expand (eidx2 ,1 ,size (print_options->qual ,5 ) ,dsa.encntr_id ,print_options->qual[eidx2 ].
     encntr_id )
    and dsa.active_ind = 1
    and dsa.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and dsa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join pct where pct.pct_care_team_id = dsa.pct_care_team_id
    and pct.active_ind = 1
    and pct.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and pct.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join p where p.person_id = pct.prsnl_id
    and p.active_ind = 1
    and p.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
DETAIL
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,dsa.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,
    printdata->patients[m_idx ].consultant.consul_phy = replace(concat(printdata->patients[m_idx ].consultant.consul_phy,
                                                    char(13), char(10),p.name_full_formatted),
                                                    printdata->patients[m_idx ].primary_contact, "")
 
 with nocounter
 
 END ;Subroutine
 
	SUBROUTINE getCovPhy(null)
 
	DECLARE COV_PHY 		= F8 with public, constant (UAR_GET_CODE_BY("DISPLAY_KEY",333,"COVERINGPHYSICIAN"))
	DECLARE cnt				= i4 WITH protect, noconstant(0)
	DECLARE eidx3 			= i4  WITH protect,noconstant(0)
	DECLARE m_idx			= i4 WITH protect, noconstant(0)
	DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
 
	; Covering Physician
		SELECT into "nl:"
		FROM
		  	  prsnl p
			, ENCNTR_PRSNL_RELTN   e
 
	 	PLAN e
 
	 		WHERE expand(eidx3, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[eidx3].encntr_id)
	    	AND e.ENCNTR_PRSNL_R_CD = COV_PHY
	     	AND e.active_ind = 1
	    	AND e.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME)
 
		JOIN p
	    	WHERE p.person_id = e.prsnl_person_id
	    order by p.updt_dt_tm desc
 
		DETAIL
 
			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), e.encntr_id, printdata->patients[gm_idx].encntr_id)
			printdata->patients[m_idx].consultant.cover_phy = p.name_full_formatted
 
	END
 
 
	SUBROUTINE getAddPhy(null)
	; Query get consultant
		DECLARE ADD_PHY 		= F8 with public, constant (UAR_GET_CODE_BY("DISPLAY_KEY",333,"ADMITTINGPHYSICIAN"))
		DECLARE adnt			= i4 WITH protect, noconstant(0)
	 	DECLARE eidx4 			= i4  WITH protect,noconstant(0)
	 	DECLARE m_idx			= i4 WITH protect, noconstant(0)
		DECLARE gm_idx 			= i4 WITH protect, noconstant(0)
 
		SELECT into "nl:"
		FROM
		  	  prsnl p
			, ENCNTR_PRSNL_RELTN   e
 
	 	PLAN e
	 		WHERE expand(eidx4, 1, size(print_options->qual,5), e.encntr_id, print_options->qual[eidx4].encntr_id)
	    	AND e.ENCNTR_PRSNL_R_CD = ADD_PHY
	     	AND e.active_ind = 1
	    	AND e.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME)
 
		JOIN p
	    	WHERE p.person_id = e.prsnl_person_id
	    order by p.updt_dt_tm desc
 
		DETAIL
			m_idx = locateval(gm_idx, 1, size(printdata->patients,5), e.encntr_id, printdata->patients[gm_idx].encntr_id)
			printdata->patients[m_idx].consultant.adm_phy = p.name_full_formatted
 
	END ;Subroutine
 
 
	SUBROUTINE  createprinttemplatelayout(null)
 
		DECLARE numberofpatients 	= i4 WITH protect,noconstant(size(printdata->patients,5))
		DECLARE sfinalhtml 			= vc WITH noconstant("")
		DECLARE index 				= i4 WITH protect,noconstant(0)
		DECLARE patientshtml 		= vc WITH noconstant("")
		DECLARE diagnosisIndex 		= i4 WITH protect,noconstant(0)
		DECLARE diagnosisData		= vc WITH noconstant("")
		DECLARE medsIndex 			= i4 WITH protect,noconstant(0)
		DECLARE medsData			= vc WITH noconstant("")
		DECLARE summaryData			= vc WITH noconstant("")
		DECLARE formatteddate 		= vc WITH protect,noconstant("")
		DECLARE current_date_time 	= dq8 WITH protect,constant(cnvtdatetime(curdate,curtime3))
 
 
	DECLARE rec_json            = vc with noconstant("")
	DECLARE temp_data           = vc with noconstant("")
	DECLARE rec_json_a          = vc with noconstant("")
	set rec_json = CnvtRecToJson(print_options)
	set rec_json_a = CnvtRecToJson(printdata)
 
	;DECLARE temp_data3          = vc with noconstant("")
	;set printdata->inputdata = $jsondata
 
	;set temp_data = build2("<div>PRINT_DATA<br/><textarea rows='40' cols='100'>",rec_json,"</textarea></div>")
 
	set temp_data = build2("<div>Print_Options<br/><textarea rows='40' cols='100'>",rec_json,"</textarea></div>",
  							"<div>PRINT_DATA<br/><textarea rows='40' cols='100'>",rec_json_a,"</textarea></div>")
 
 
		SET formatteddate = format(current_date_time,cclfmt->shortdatetimenosec)
 
		SET patientshtml = build2(
			patientshtml
			,'<div class="table-container">'
				,'<table class="w100">'
			)
 
			SET patientshtml = build2(
				patientshtml
							,'<thead>'
							,'<tr>'
								,'<td class="w10">'
									,'<div class="cell-header">Location</div>'
								,'</td>'
								,'<td class="w5">'
									,'<div class="cell-header">Age/Sex</div>'
								,'</td>'
								,'<td class="w15">'
									,'<div class="cell-header">Patient</div>'
								,'</td>'
								,'<td class="w25">'
									,'<div class="cell-header">Providers</div>'
								,'</td>'
								,'<td class="w15">'
									,'<div class="cell-header">LOS</div>'
								,'</td>'
								,'<td class="w35">'
									,'<div class="cell-header">Notes</div>'
								,'</td>'
							,'</tr>'
							,'</thead>'
 
			)
 
 
	 		FOR(index = 1 TO numberofpatients)
 
			SET patientshtml = build2(patientshtml
							,'<tbody>'
							,'<tr>'
							;Location
								,'<td>'
									,'<div class="cell-content">'
										,printdata->patients[index].location_data.facility
										,' / '
										,printdata->patients[index].location_data.unit
										,'<br/>'
										,printdata->patients[index].location_data.room
										,' / '
										,printdata->patients[index].location_data.bed
									,'</div>'
								,'</td>'
							;Age/Sex
								,'<td>'
									,'<div class="cell-content">'
										,printdata->patients[index].patient_data.age
										,' '
		 								,printdata->patients[index].sex
	 								,'</div>'
	 							,'</td>'
							;Patient Info
								,'<td>'
									,'<div class="cell-content">',printdata->patients[index].name_full,'</div>'
									,'<div class="cell-content">MRN: ',printdata->patients[index].patient_data.mrn,'</div>'
									,'<div class="cell-content">FIN: ',printdata->patients[index].patient_data.fin,'</div>'
								,'</td>'
	 		)
 
	 		;Consultant
 
	 		SET patientshtml = build2(patientshtml,'<td>')
			IF (printdata->patients[index].consultant.adm_phy != printdata->patients[index].consultant.att_phy)
				SET patientshtml = build2(patientshtml
									,'<div class="cell-content"><b><u>Primary Contact-</u></b>',printdata->patients[index].primary_contact,'</div>'
									,'<div class="cell-content"><b><u>Attending-</u></b>',printdata->patients[index].consultant.att_phy,'</div>'
									,'<div class="cell-content"><b><u>Admitting-</u></b>',printdata->patients[index].consultant.adm_phy,'</div>'
 
			)
			else
			SET patientshtml = build2(patientshtml
									,'<div class="cell-content"><b><u>Primary Contact-</u></b>',printdata->patients[index].primary_contact,'</div>'
									,'<div class="cell-content"><b><u>Attending-</u></b>',printdata->patients[index].consultant.att_phy,'</div>'
				)
			endif
			SET patientshtml = build2(patientshtml,'</td>')
 
	 		;Length of Stay
			SET patientshtml = build2(patientshtml,'<td>')
			if(printdata->patients[index].length_of_stay = 0)
			SET patientshtml = build2(patientshtml
									,'<div class="cell-content"></div>'
 
			)
			else
			SET patientshtml = build2(patientshtml
									,'<div class="cell-content">',printdata->patients[index].length_of_stay,' days</div>'
									,'<div class="cell-content">Adm Dt:',printdata->patients[index].admit_date,'</div>'
			)
			endif
			SET patientshtml = build2(patientshtml,'</td>')
 
 
	 		;Notes
			SET patientshtml = build2(patientshtml
								,'<td>'
									,'<div class="cell-content">',printdata->patients[index].notes,'</div>'
								,'</td>'
								,'</tr>'
								,'<tr>'
									,'<td colspan= "6">'
									,'<div class="consults-content">consults: ',printdata->patients[index].consultant.consul_phy,'</div>'
									,'</td>'
								,'</tr>'
								,'<tr>'
									,'<td colspan="14" class="dash1"/>'
								;,'</tr>'
								)
	 		SET patientshtml = build2(patientshtml,'</tr>')
 
 
		ENDFOR
 
		SET patientshtml = build2(
			patientshtml
					,'</tbody>'
					,'</table>'
				,'</div>'
			)
 
		SET sfinalhtml = build2(
			'<!doctype html>'
			,'<html>'
				,'<head>'
					,'<meta charset="utf-8">'
					,'<meta name="description">'
					,'<meta http-equiv="X-UA-Compatible" content="IE=Edge">'
					,'<title>MPage Print</title>'
					,'<style type="text/css">'
				        ,'body {font-family: calibri; font-size: 12px; position:relative;}'
				        ,'table {border-collapse:collapse; table-layout:fixed; width:1000px;}'
				        ,'td {vertical-align: top; padding: 2px; word-wrap: break-word;}'
				        ,'.w100 {width: 1000px;}'
				        ,'.w35 {width: 350px;}'
				        ,'.w25 {width: 250px;}'
				        ,'.w15 {width: 150px;}'
				        ,'.w10 {width: 100px;}'
				        ,'.w5 {width: 50px;}'
				        ,'.dash1 {border-top: 1px dashed #8b8b8b;}'
				        ,'.table-container {padding-top: 1em; padding-left:50px; margin: 0 auto -142px;}'
				        ,'.table-container:5th-child(2(5)+1) {break-before: always;}'
				        ,'.cell-content {font-family: calibri; font-size: 12px;}'
				        ,'.consults-content{font-family: calibri; font-size: 9px;}'
				        ,'.cell-header {font-weight: bold;  font-size: 11px;}'
				        ,'.print-header {display: flex; padding-left:50px;}'
				        ,'.print-header div {display: flex; flex: 1 1;}'
				        ,'.print-title {justify-content: center; font-style: bold; font-size: 26px; padding-top:30px;}'
				        ,'.printed-date {justify-content: flex-end; padding-top:30px;}'
				        ,'.printed-by-user {justify-content: flex-start; padding-top:30px;}'
 
					,'</style>'
				,'</head>'
				,'<body>'
					,'<div id = "print-container">'
						,'<div class="print-header">'
							,'<div class="printed-by-user">'
								,'<span>','Printed By: ','</span>'
								,'<span>',printdata->person_printing_name,'</span>'
							,'</div>'
							,'<div class="print-title">'
								,'<span>','Physician Handoff','</span>'
							,'</div>'
							,'<div class="printed-date">'
								,'<span>',formatteddate,'</span>'
							,'</div>'
						,'</div>'
						,patientshtml
						,temp_data
					,'</div>'
				,'</body>'
			,'</html>'
		)
 
		CALL putstringtofile(sfinalhtml)
 
		IF(error_message(1) = 1)
			CALL populate_subeventstatus_rec(
				"PopulateRequest"
				,"F"
				,"CREATING_PRINT_TEMPLATE_HTML"
				,"Error encountered during createPrintTemplateLayout()."
				,printdata)
			GO TO exit_script
		ENDIF
		GO TO exit_program
	END ;Subroutine
 
	;================
	; Wrap-up steps
	;================
	#exit_script
	IF(size(printdata->patients,5) > 0)
		SET printdata->status_data.status = "S"
	ENDIF
	IF(validate(debug_ind,0) = 1)
		CALL echorecord(printdata)
	ENDIF
 
	CALL putjsonrecordtofile(printdata)
 
	#exit_program
	CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
	END GO

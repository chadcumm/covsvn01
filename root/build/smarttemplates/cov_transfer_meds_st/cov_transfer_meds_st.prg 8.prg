drop program cov_transfer_meds_st go
create program cov_transfer_meds_st



if (not(validate(request,0)))
record request
	(
	  1 output_device = vc
	  1 script_name = vc
	  1 person_cnt = i4
	  1 person[*]
	    2 person_id        = f8
	  1 visit_cnt = i4
	  1 visit[*]
	    2 encntr_id        = f8
	  1 prsnl_cnt = i4
	  1 prsnl[*]
	    2 prsnl_id        = f8
	  1 nv_cnt = i4
	  1 nv[*]
	    2 pvc_name = vc
	    2 pvc_value = vc
	  1 batch_selection = vc
	)
endif

if (not(validate(reply,0)))
record  reply
(
    1 elapsed_time = f8
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif



;****************************************************************************
; BUILDING SCRIPT VARIABLES
;****************************************************************************
declare getStringFitLen(fitString = vc, cellWidth = f8,cellHeight = f8) = i4
declare person_id = f8 with protect
declare encntr_id = f8 with protect
declare printer_name = vc with protect
declare dummy_val = f8 with protect
declare num_allergies = i4 with protect
declare allergies_disp = vc with protect
declare room_bed = vc with protect
declare drug_details = vc with protect
declare allergy_list = vc with protect
declare allergy_list2 = vc with protect
declare secondstr = vc with protect
declare fit_length = i4 with protect
declare fit_length2 = i4 with protect
declare bGrow = i1 with protect, noconstant(1)
declare foot_rpt_flag = i1 with protect, noconstant(0)
declare errorCode = i2 with protect, noconstant(0)
 
;****************************************************************************
; SUCCESS CODES
;****************************************************************************
declare SUCCESS = i2 with protect, constant(0)
 
 
 
;****************************************************************************
; INVALID REQUEST ERRORS
;****************************************************************************
declare INVALID_PERSON_ID = i2 with protect, constant(1)
declare INVALID_ENCNTR_ID = i2 with protect, constant(2)
declare INVALID_PRINTER_NAME = i2 with protect, constant(3)
 
 
 
;****************************************************************************
; FAILED SCRIPTS
;****************************************************************************
declare FAILED_PATIENT_LOOKUP = i2 with protect, constant(4)
declare FAILED_PRINTER_LOOKUP = i2 with protect, constant(5)
 
 
 
 
;****************************************************************************
; STATUS/ERROR HANDLER
;****************************************************************************
declare StatusHandler("") = NULL
 
subroutine StatusHandler("")
	declare sErrMsg = vc with private
 
	if (errorCode = SUCCESS)
		set reply->status_data.status = "S"
	else
		case (errorCode)
			of (INVALID_PERSON_ID):
				set sErrMsg = "Invalid person_id"
			of (INVALID_ENCNTR_ID):
				set sErrMsg = "Invalid encntr_id"
			of (INVALID_PRINTER_NAME):
				set sErrMsg = "Invalid printer_name"
			of (FAILED_PATIENT_LOOKUP):
				set sErrMsg = "Patient lookup failed"
			of (FAILED_PRINTER_LOOKUP):
				set sErrMsg = "Printer lookup failed"
		endcase
 
		set reply->status_data->status = "F"
	    set reply->status_data->subeventstatus[1]->OperationStatus = "F"
	    set reply->status_data->subeventstatus[1]->TargetObjectValue = sErrMsg
	endif
end
 
 
;****************************************************************************
; CLEANUP RECORD STRUCTURES
;****************************************************************************
declare DestroyRecords("") = NULL
 
subroutine DestroyRecords("")
	if (validate(patientRec))
		free record patientRec
	endif
 
	if (validate(allergy))
		free record allergy
	endif
 
	if (validate(ordersRec))
		free record ordersRec
	endif
end

 
free set ordersRec
record ordersRec
(
	1 orders_list[*]
		2 order_id                      = f8
		2 rx_ind                = i2
		2 mnemonic		        = vc
		2 clinical_display_line		= vc
		2 order_flag			= i1
		2 details[*]
			3 indication		= vc
			3 last_admin_dt_tm	= vc
)


FREE RECORD drec
RECORD drec

(
1	line_cnt		=	i4
1	display_line	=	vc
1	line_qual[*]
	2	disp_line	=	vc
)

;RTF variables.
SET rhead   = concat('{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern Lucida Console;}}',
                  '{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134')
SET RH2r    = '\plain \f0 \fs18 \cb2 \pard\s10 '
SET RH2b    = '\plain \f0 \fs18 \b \cb2 \pard\s10 '
SET RH2bu   = '\plain \f0 \fs18 \b \ul \cb2 \pard\s10 '
SET RH2u    = '\plain \f0 \fs18 \u \cb2 \pard\s10 '
SET RH2i    = '\plain \f0 \fs18 \i \cb2 \pard\s10 '
SET REOL    = '\par '
SET Rtab    = '\tab '
SET wr      = '\plain \f0 \fs16 \cb2 '
SET ul      = '\ul '
SET wb      = '\plain \f0 \fs16 \b \cb2 '
SET wu      = '\plain \f0 \fs18 \ul \cb2 '
SET wi      = '\plain \f0 \fs18 \i \cb2 '
SET wbi     = '\plain \f0 \fs18 \b \i \cb2 '
SET wiu     = '\plain \f0 \fs18 \ul \i \cb2 '
SET wbiu    = '\plain \f0 \fs18 \b \ul \i \cb2 '
SET wbu     = '\plain \f0 \fs18 \b \ul \cb2 '
SET rtfeof  = '} '
SET bullet  = '\bullet '



;****************************************************************************
; BUILDING PATIENT REQUEST STRUCTURE
;****************************************************************************
 
/*
	The request structure that is passed to this .inc can be created in 2 ways.
	The first way is by the powerchart framework and the second is by the
	discern expert server.  Depending on how the .inc gets called, the request
	will take on different forms.  If powerchart calls the script, then the request
	will contain the standard request that is shown below.  However, if the discern
	server creates the request, it will be changed and will contain the standard
	request for a discern rule.  The key to this request structure are the n_* and o_*
	fields that designate the new and old values for common values such as
	person_id and encounter_id.  This .inc will determine how the parent script is
	getting called and will populate our internal request based on those findings.
 
 
	POWERCHART REPORT REQUEST
	record request
	(
	  1 output_device = vc
	  1 script_name = vc
	  1 person_cnt = i4
	  1 person[*]
	    2 person_id        = f8
	  1 visit_cnt = i4
	  1 visit[*]
	    2 encntr_id        = f8
	  1 prsnl_cnt = i4
	  1 prsnl[*]
	    2 prsnl_id        = f8
	  1 nv_cnt = i4
	  1 nv[*]
	    2 pvc_name = vc
	    2 pvc_value = vc
	  1 batch_selection = vc
	)
 
*/
 
declare BuildPatientRequest("") = i2
 
subroutine BuildPatientRequest("")
 
 	call echo("***  BEGIN - orm_rpt_meds_rec_requests.inc  ***")
 
	if(validate(request->n_person_id))
		if (request->n_encntr_id > 0)
			call echo("***  BEGIN - Locating the closest printer to the patient location.  ***")
 
			declare PRINTER_TYPE_CD = f8 with protect, constant(uar_get_code_by("MEANING", 3000, "PRINTER"))
	 		declare bedPrinter = vc with protect
		 	declare roomPrinter = vc with protect
		 	declare nurseUnitPrinter = vc with protect
		 	declare facilityPrinter = vc with protect
 
			set retval = 100 ;this must be done for the eks monitor to shown this transaction.
			set person_id = request->n_person_id
			set encntr_id = request->n_encntr_id
 
			select
				into "nl:"
			from
				encounter e
				,device_xref dxref
				,device d
				,code_value cv
			plan e
				where e.encntr_id = encntr_id
			join dxref
				where dxref.parent_entity_name = "LOCATION"
				and dxref.parent_entity_id in (e.loc_bed_cd, e.loc_room_cd, e.loc_nurse_unit_cd, e.loc_facility_cd)
				and dxref.usage_type_cd = PRINTER_TYPE_CD
			join d
				where d.device_cd = dxref.device_cd
 			join cv
 				where cv.code_value = dxref.parent_entity_id
 				and cv.code_set = 220
 				and cv.active_ind = 1
 
 			order by cv.cdf_meaning
 
			head cv.cdf_meaning
				if (cv.cdf_meaning = "BED")
					bedPrinter = trim(substring(1, 30, d.name))
				elseif (cv.cdf_meaning = "ROOM")
					roomPrinter = trim(substring(1, 30, d.name))
				elseif (cv.cdf_meaning = "NURSEUNIT" or cv.cdf_meaning = "AMBULATORY")
					nurseUnitPrinter = trim(substring(1, 30, d.name))
				elseif (cv.cdf_meaning = "FACILITY")
					facilityPrinter = trim(substring(1, 30, d.name))
				endif
 
			with nocounter
 
 			call echo(build("Bed printer: ", bedPrinter))
  			call echo(build("Room printer: ", roomPrinter))
  			call echo(build("Nurse Unit printer: ", nurseUnitPrinter))
  			call echo(build("Facility printer: ", facilityPrinter))
 
			if (textlen(bedPrinter) > 0)
				set printer_name = bedPrinter
			elseif (textlen(roomPrinter) > 0)
				set printer_name = roomPrinter
			elseif (textlen(nurseUnitPrinter) > 0)
				set printer_name = nurseUnitPrinter
			elseif (textlen(facilityPrinter) > 0)
				set printer_name = facilityPrinter
			endif
 
			call echo("***  END - Locating the closest printer to the patient location.  ***")
		endif
	else
		set encntr_id = request->visit[1].encntr_id
		set printer_name = request->output_device
 
		select into "nl:"
		from encounter e
		where e.encntr_id = encntr_id
		head report
			person_id = e.person_id
		with nocounter
	endif
 
 	if (person_id = 0)
 		return (INVALID_PERSON_ID)
 	endif
 
 	if (encntr_id = 0)
 		return (INVALID_ENCNTR_ID)
 	endif

 
	call echo(build("Person_id:  ", person_id))
	call echo(build("Encntr_id:  ", encntr_id))
	call echo(build("Printer_name:  ", printer_name))
 
 	call echo("***  END - orm_rpt_meds_rec_requests.inc  ***")
 
 	return (SUCCESS)
end


set errorCode = BuildPatientRequest("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif
 
 
 
;****************************************************************************
; BUILDING PATIENT INFO
;****************************************************************************
;***************Store patient encounters info*********************

 
free set patientRec
record patientRec
(
	1 name            = vc
  	1 room            = c40
  	1 bed             = c40
  	1 mrn             = vc
  	1 fin             = vc
  	1 dob             = c12
  	1 age             = c12
  	1 gender          = c40
  	1 height          = vc
  	1 weight          = vc
  	1 admit_phy_name  = vc
)
 
free set allergy
record allergy
(
	1 data[*]
	  2 person_id     = f8
	  2 encntr_id     = f8
	  2 details[*]
	    3 allergy_id          = f8
	    3 allergy_instance_id = f8
	    3 nomenclature_id     = f8
	    3 description         = vc
)
 

 
 
declare BuildAllergyList("") = NULL
declare LoadPatientInfo("") = i2
 
 
 
;****************************************************************************
; BUILDING PATIENT INFO
;****************************************************************************
subroutine LoadPatientInfo("")
 	call echo("***  BEGIN - orm_rpt_meds_rec_patient_data.inc  ***")
 
	;****************************************************************************
	; BUILDING PATIENT ALLERGY LIST
	;****************************************************************************
	set stat = alterlist(allergy->data,1)
	set allergy->data[1]->person_id = person_id
 
	execute pha_get_mar_allergy
 	call BuildAllergyList("")
 
	call echorecord(allergy)
 
 
	;****************************************************************************
	; BUILDING PATIENT DEMOGRAPHICS
	;****************************************************************************
	declare MRN_CD = f8 with protect, constant (uar_get_code_by("MEANING", 319, "MRN"))
	declare FIN_CD = f8 with protect, constant (uar_get_code_by("MEANING", 319, "FIN NBR"))
	declare ADMIT_PHY_CD = f8 with protect, constant (uar_get_code_by("MEANING", 333, "ADMITDOC"))
	declare INERROR_CD = f8 with protect, constant (uar_get_code_by("MEANING", 8, "IN ERROR"))
	declare admit_phy_id = f8 with protect, noconstant (0.0)
 
	select	into "nl:"
	        p.name_full_formatted
	        , p.sex_cd
	        , p.birth_dt_tm
	        , p.birth_tz
	        , e.encntr_type_cd
	        , e.loc_room_cd
	        , e.loc_bed_cd
 
	from    encounter e
	        , person p
	        , encntr_alias ea
 
 	plan p where p.person_id = person_id
	join e where e.person_id = p.person_id 
	        and e.encntr_id = encntr_id  ;001 
	join ea where (ea.encntr_id = e.encntr_id
	        and ea.encntr_alias_type_cd in (MRN_CD, FIN_CD))
	        or (ea.encntr_alias_id = 0)
 
	head report
		patientRec->name = p.name_full_formatted
		patientRec->room = uar_get_code_display(e.loc_room_cd)
		patientRec->bed = uar_get_code_display(e.loc_bed_cd)
		patientRec->dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"@SHORTDATE") ;002
		patientRec->age = cnvtage(p.birth_dt_tm)
		patientRec->gender = uar_get_code_display(p.sex_cd)
 
 	detail
    	if (ea.encntr_alias_type_cd = FIN_CD)
			patientRec->fin = cnvtalias (ea.alias, ea.alias_pool_cd)
		elseif (ea.encntr_alias_type_cd = MRN_CD)
			patientRec->mrn = cnvtalias (ea.alias, ea.alias_pool_cd)
		endif
 
	with nocounter
 
 	if (curqual = 0)
 		return (FAILED_PATIENT_LOOKUP)
 	endif
 
 
	;**************************************
	; BUILDING PATIENT HEIGHT AND WEIGHT
	;**************************************
	select into "nl:"
	from v500_event_set_code vesc
		,v500_event_set_explode vese
		,clinical_event ce
	plan vesc
		where vesc.event_set_name_key in ("CLINICALHEIGHT", "CLINICALWEIGHT")
	join vese
		where vese.event_set_cd = vesc.event_set_cd
	join ce
		where ce.person_id = person_id
		and ce.event_cd = vese.event_cd
		and ce.view_level = 1
		and ce.publish_flag = 1
		and ce.valid_until_dt_tm > cnvtdatetime(CURDATE, CURTIME)
		and ce.result_status_cd != INERROR_CD
	order by vesc.event_set_name_key, cnvtdatetime(ce.event_end_dt_tm) desc
 
	head vesc.event_set_name_key
		if(vesc.event_set_name_key = "CLINICALWEIGHT")
			patientRec->weight = concat(trim(ce.event_tag), " ", uar_get_code_display(ce.result_units_cd))
		else
			patientRec->height = concat(trim(ce.event_tag), " ", uar_get_code_display(ce.result_units_cd))
		endif
	with nocounter
 
 
 
	;****************************************************************************
	; BUILDING ADMITTING PHYSICIAN
	;****************************************************************************
	select	into "nl:"
	        p.name_full_formatted
 
	from
	        person p
	        , encntr_prsnl_reltn ep
 
	plan ep where ep.encntr_id = encntr_id
			and ep.encntr_prsnl_r_cd = ADMIT_PHY_CD
			and ep.active_ind = 1
			and ep.beg_effective_dt_tm < cnvtdatetime(CURDATE, CURTIME)
			and ep.end_effective_dt_tm > cnvtdatetime(CURDATE, CURTIME)
	join p where p.person_id = ep.prsnl_person_id
 
	order ep.end_effective_dt_tm desc
 
	detail
		patientRec->admit_phy_name = p.name_full_formatted
	with nocounter
 
	call echorecord(patientRec)
 
	call echo("***  END - orm_rpt_meds_rec_patient_data.inc  ***")
 
	return (SUCCESS)
end
 
 
 
;****************************************************************************
; BUILDING ALLERGY LIST
;****************************************************************************
subroutine BuildAllergyList("")
	set num_allergies = size(allergy->data[1]->details,5)
 
	if (num_allergies > 0)
		for (aller_cnt = 1 to (num_allergies))
			if (allergy->data[1]->details[aller_cnt].description != NULL)
				if(allergies_disp = NULL)
					set allergies_disp = trim(allergy->data[1]->details[aller_cnt].description, 3)
				else
					set allergies_disp = concat(allergies_disp,", ", trim(allergy->data[1]->details[aller_cnt].description,3))
				endif
			endif
		endfor
	else
		set allergies_disp = uar_i18ngetmessage(_hI18NHandle,"allergies_none1","No known allergies.")
	endif
end
set last_mod = "002"
set mod_date = "April 04, 2013"
set errorCode = LoadPatientInfo("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif
 
 
 
;****************************************************************************
; BUILDING OUTPATIENT ORDER LIST
;****************************************************************************
declare LoadInpatOrdersOfPatient("") = i2
 
subroutine LoadInpatOrdersOfPatient("")
	call echo("***  BEGIN - orm_rpt_meds_rec_transfer_data.inc  ***")
 
	declare IND_ID = f8 with protect, constant(15.0)
	declare LAST_ADMIN_DT_TM_ID = f8 with protect, constant(16.0)
	declare ORDERED_STAT_CD = f8 with protect, constant(uar_get_code_by("MEANING", 6004, "ORDERED"))
	declare PHARMACY_TYPE_CD = f8 with protect, constant(uar_get_code_by("MEANING", 6000, "PHARMACY"))
	declare CARE_SET_PARENT_FLAG = i2 with protect, constant(1)    ;001
	declare CARE_PLAN_PARENT_FLAG = i2 with protect, constant(16)  ;001
	declare NONE_TEMP_FLAG = i2 with protect, constant(0)
	declare TEMPLATE_TEMP_FLAG = i2 with protect, constant(1)
	declare ct = i4 with protect, noconstant(size(ordersRec->orders_list, 5))
 
	select into "nl:"
		o.ordered_as_mnemonic,
		o.hna_order_mnemonic,
		o.clinical_display_line,
		od.oe_field_meaning_id
 
	from 	orders o,
			order_detail od
 
	plan o
		where o.encntr_id = encntr_id
		and o.orig_ord_as_flag = 0
		and o.template_order_flag in (NONE_TEMP_FLAG, TEMPLATE_TEMP_FLAG)
		and o.active_ind = 1
		and o.order_status_cd+0 = ORDERED_STAT_CD
		and o.catalog_type_cd+0 = PHARMACY_TYPE_CD
		and o.hide_flag in (0, NULL)
		and o.cs_flag not in (CARE_SET_PARENT_FLAG, CARE_PLAN_PARENT_FLAG)  ;001
 
	join od
		where od.order_id = outerjoin(o.order_id)
		and od.oe_field_meaning_id = outerjoin(IND_ID)
 
	order by o.order_id, od.oe_field_meaning_id, od.action_sequence
 
	head o.order_id
		ct = ct + 1
		if (ct > size(ordersRec->orders_list, 5))
			stat = alterlist(ordersRec->orders_list, ct + 10)
		endif
 
		ordersRec->orders_list[ct].clinical_display_line = o.clinical_display_line
		ordersRec->orders_list[ct].order_flag = 1
 
		if (o.ordered_as_mnemonic = o.hna_order_mnemonic)
			ordersRec->orders_list[ct].mnemonic = o.ordered_as_mnemonic
		else
			ordersRec->orders_list[ct].mnemonic = (concat(trim(o.ordered_as_mnemonic), " (", trim(o.hna_order_mnemonic), ")"))
		endif
 
	detail
 
		if (size(ordersRec->orders_list[ct]->details, 5) = 0)
			stat = alterlist(ordersRec->orders_list[ct].details, 1)
		endif
 
		if (od.oe_field_meaning_id = IND_ID)
			ordersRec->orders_list[ct]->details[1].indication = od.oe_field_display_value
		endif
 
	foot report
		stat = alterlist(ordersRec->orders_list, ct)
 
	with nocounter
 
	; Adds a notifcation row to show there are no orders
 
	if (CURQUAL = 0)
		set ct = ct + 1
		set stat = alterlist(ordersRec->orders_list, ct)
		set ordersRec->orders_list[ct].order_flag = 1
		set ordersRec->orders_list[ct].mnemonic =
			uar_i18ngetmessage(_hI18NHandle,"no_active_orders","No known active medication orders.")
	endif
 
 	call echorecord(ordersRec)
 	call echo("***  END - orm_rpt_meds_rec_transfer_data.inc  ***")
	return (SUCCESS)
end

set errorCode = LoadInpatOrdersOfPatient("")
if (errorCode != SUCCESS)
	go to EXIT_SCRIPT
endif

set idx = 1
set stat = alterlist(drec->line_qual, idx)
set drec->line_qual[idx].disp_line = CONCAT(rhead,rh2bu,"Discharge Medications",wr,reol)

for (idx=1 to size(drec->line_qual,5))
	set reply->text = concat(reply->text,drec->line_qual[idx].disp_line)
endfor

#exit_script
SET reply->text = CONCAT(reply->text, rtfeof)
call echo(build2("errorCode=",errorCode))
call echorecord(request) 
call echorecord(reply)

end go


/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/01/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_EHR_Doc_Audit.prg
	Object name:		cov_him_EHR_Doc_Audit
	Request #:			11105
 
	Program purpose:	Lists various configuration data sets.
 
	Executing from:		CCL
 
 	Special Notes:		Based on CCL 'idn_aud_him_ehrdoc' written by Ryan Gotsche.
 	
 						Report Options:
							1 - Dynamic Documentation
							2 - All PowerForms
							3 - PowerForms
							4 - iView (Bands)
							5 - Clinical Documents
							6 - Clinical Document Event Classes
							7 - Position Note Types
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_EHR_Doc_Audit go
create program cov_him_EHR_Doc_Audit
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Please select your audit" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, audit_var, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare active_var			= f8 with constant(uar_get_code_by("DISPLAY_KEY", 48, "ACTIVE")),protect

declare file_var			= vc with noconstant("")
 
declare temppath_var		= vc with constant(build("cer_temp:him_ehr_aud.csv"))
declare temppath2_var		= vc with constant(build("$cer_temp/him_ehr_aud.csv"))
 
declare filepath_var		= vc with noconstant(build("/cerner/w_custom/", cnvtlower(curdomain), 
													   "_cust/to_client_site/RevenueCycle/HIM/"))
 
declare output_var			= vc with noconstant("")
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
	set modify filestream
else
	set output_var = value($OUTDEV)
endif

 
/**************************************************************
; DVDev Start Coding
**************************************************************/

if ($audit_var = 1)
	set file_var = "him_dd_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to DD_AUD
	
elseif ($audit_var = 2)
	set file_var = "him_pf_all_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to PF_ALL_AUD
	
elseif ($audit_var = 3)
	set file_var = "him_pf_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to PF_AUD
	
elseif ($audit_var = 4)
	set file_var = "him_iview_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to IVIEW_AUD
	
elseif ($audit_var = 5)
	set file_var = "him_clin_doc_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to CLIN_DOC
	
elseif ($audit_var = 6)
	set file_var = "him_clin_doc_class_aud.csv"
	set filepath_var = build(filepath_var, file_var)
	
	go to CLIN_DOC_CLASS
	
elseif ($audit_var = 7)
	set file_var = "him_pos_note_type_aud.csv"
	set filepath_var = build(filepath_var, file_var)

	go to POS_NOTE_TYPE
	
endif


/**************************************************************/ 
; select Dynamic Documents
#DD_AUD

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
into value(output_var)
	domain = currdbname
	, dyndoc_name = d.description_txt
	, custom_content = if (D.SOURCE_TXT = "cernerbasiccontent")
			"No"
		else
			"Yes"
		endif
		
from
	DD_REF_TEMPLATE   d
 
where d.active_ind = 1
	and d.dd_ref_template_id != 0

order by 
	d.description_txt
 
with nocounter, separator=" ", format

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select All PowerForms
#PF_ALL_AUD

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	domain = currdbname
	, vesc.event_set_name
	, powerform_textual_eventcode = uar_get_code_display(d.text_rendition_event_cd)
	, powerform_description = d.description
	, powerform_eventcode = uar_get_code_display(d.event_cd)
 	
from
	DCP_FORMS_REF   d
	, V500_EVENT_SET_CODE vesc
	, V500_EVENT_CODE vec
 
where d.active_ind = 1
	and d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and d.description != "zz*"
	and d.description != "ZZ*"
	and d.event_cd != 0
	and d.text_rendition_event_cd != 0
	and d.event_cd in (select event_cd from v500_event_code)
	and d.text_rendition_event_cd in (select event_cd from v500_event_code)
	and vec.event_cd = d.text_rendition_event_cd
	and vec.event_set_name = vesc.event_set_name
	
order by 
	vesc.event_set_name
	, d.description

with time=60, nocounter, separator=" ", format

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select PowerForms
#PF_AUD

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
into value(output_var)
	domain = currdbname
	, d.description
	, total = cnvtint(count(*))

from 
	DCP_FORMS_ACTIVITY d
	, PERSON p
	
plan d
where d.form_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
	and d.beg_activity_dt_tm > cnvtlookbehind("30,D")

join P
where P.person_id = d.person_id
	and p.name_last_key != "ZZ*"
	and p.name_last_key != "TTTT*"
	and p.name_last_key != "FFFF*"
	and p.name_last_key != "FF*"

group by
	d.dcp_forms_ref_id
	, d.description

order by 
	d.description

with time=60,nocounter, separator=" ", format

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select iView Bands
#IVIEW_AUD

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	domain = currdbname
	, band_name = pv.value_upper
 
from
	PREFDIR_VALUE   pv
	, PREFDIR_GROUP   p
	, PREFDIR_ENTRY   pe
 
where pv.entry_id = p.entry_id  
	and p.entry_id = pe.entry_id  
	and p.value not in ("component", "powerdoc", "system", "reference", "Powerdoc")
	and pv.entry_id in (select entry_id from prefdir_entry where value = "documentsettypes")
 
order by
	pv.value_upper
 
with nocounter, separator=" ", format, time = 120

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select Clinical Documents
#CLIN_DOC

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	domain = currdbname
	, level_0_disp = uar_get_code_display(vesc0.event_set_cd)
	, level_1_disp = uar_get_code_display(vesc1.event_set_cd)
	, level_2_disp = uar_get_code_display(vesc2.event_set_cd)
	, level_3_disp = uar_get_code_display(vesc3.event_set_cd)
	
	, primitive_es = if (vesc1.event_set_cd=0) uar_get_code_display(vesc0.event_set_cd) 
		elseif (vesc2.event_set_cd=0) uar_get_code_display(vesc1.event_set_cd)
		elseif (vesc3.event_set_cd=0) uar_get_code_display(vesc2.event_set_cd)
		elseif (vesc4.event_set_cd=0) uar_get_code_display(vesc3.event_set_cd)
		endif 
		
	, event_code = if (v0.event_cd != 0) uar_get_code_display(v0.event_cd)
		elseif (v.event_cd != 0) uar_get_code_display(v.event_cd)
		elseif (v2.event_cd != 0) uar_get_code_display(v2.event_cd)
		elseif (v3.event_cd != 0) uar_get_code_display(v3.event_cd)
		endif

	, cdi_alias = if (v0.event_cd > 0) cva0.alias
		elseif (v.event_cd > 0) cva.alias
		elseif (v2.event_cd > 0) cva2.alias
		elseif (v3.event_cd > 0) cva3.alias
		endif
		
from
	V500_EVENT_SET_CANON vesc0
	, V500_EVENT_SET_CANON vesc1
	, V500_EVENT_SET_CANON vesc2
	, V500_EVENT_SET_CANON vesc3
	, V500_EVENT_SET_CANON vesc4
	, V500_EVENT_SET_EXPLODE v0
	, V500_EVENT_SET_EXPLODE v
	, V500_EVENT_SET_EXPLODE v2
	, V500_EVENT_SET_EXPLODE v3
	, NOTE_TYPE nt0
	, NOTE_TYPE nt
	, NOTE_TYPE nt2
	, NOTE_TYPE nt3
	, V500_EVENT_CODE vec0
	, V500_EVENT_CODE vec
	, V500_EVENT_CODE vec2
	, V500_EVENT_CODE vec3
	, CODE_VALUE_ALIAS cva0
	, CODE_VALUE_ALIAS cva
	, CODE_VALUE_ALIAS cva2
	, CODE_VALUE_ALIAS cva3
	
plan vesc0
where vesc0.event_set_cd = value(uar_get_code_by("DISPLAYKEY",93,"CLINICALDOCUMENTS"))

join vesc1
where vesc1.parent_event_set_cd = vesc0.event_set_cd

join vesc2
where vesc2.parent_event_set_cd = outerjoin(vesc1.event_set_cd)

join vesc3
where vesc3.parent_event_set_cd = outerjoin(vesc2.event_set_cd)

join vesc4
where vesc4.parent_event_set_cd = outerjoin(vesc3.event_set_cd)

join v0
where outerjoin(vesc1.event_set_cd) = v0.event_set_cd
	and v0.event_set_level = outerjoin(0)

join nt0
where nt0.event_cd = outerjoin(v0.event_cd)
	and nt0.data_status_ind = outerjoin(1)

join vec0
where vec0.event_cd = outerjoin(v0.event_cd)
	and vec0.event_add_access_ind = outerjoin(1)

join cva0 
where outerjoin(v0.event_cd) = cva0.code_value
	and cva0.contributor_source_cd = outerjoin(value(uar_get_code_by("DISPLAYKEY",73,"CDI")))

join v
where outerjoin(vesc2.event_set_cd) = v.event_set_cd
	and v.event_set_level = outerjoin(0)

join nt
where nt.event_cd = outerjoin(v.event_cd)
	and nt.data_status_ind = outerjoin(1)

join vec
where vec.event_cd = outerjoin(v.event_cd)
	and vec.event_add_access_ind = outerjoin(1)

join cva 
where outerjoin(v.event_cd) = cva.code_value
	and cva.contributor_source_cd = outerjoin(value(uar_get_code_by("DISPLAYKEY",73,"CDI")))

join v2
where outerjoin(vesc3.event_set_cd) = v2.event_set_cd
	and v2.event_set_level = outerjoin(0)

join nt2
where nt2.event_cd = outerjoin(v2.event_cd)
	and nt2.data_status_ind = outerjoin(1)

join vec2
where vec2.event_cd = outerjoin(v2.event_cd)
	and vec2.event_add_access_ind = outerjoin(1)

join cva2 
where outerjoin(v2.event_cd) = cva2.code_value
	and cva2.contributor_source_cd = outerjoin(value(uar_get_code_by("DISPLAYKEY",73,"CDI")))

join v3
where outerjoin(vesc4.event_set_cd) = v3.event_set_cd
	and v3.event_set_level = outerjoin(0)

join nt3
where nt3.event_cd = outerjoin(v3.event_cd)
	and nt3.data_status_ind = outerjoin(1)

join vec3
where vec3.event_cd = outerjoin(v3.event_cd)
	and vec3.event_add_access_ind = outerjoin(1)

join cva3 
where outerjoin(v3.event_cd) = cva3.code_value
	and cva3.contributor_source_cd = outerjoin(value(uar_get_code_by("DISPLAYKEY",73,"CDI")))

order by
	vesc1.event_set_collating_seq
	, vesc2.event_set_collating_seq
	, vesc3.event_set_collating_seq
	, vesc4.event_set_collating_seq
	, v0.event_cd
	, v.event_cd
	, v2.event_cd
	, v3.event_cd
	
with nocounter, separator=" ", format, time = 120

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select Clinical Document Event Classes
#CLIN_DOC_CLASS

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	domain = currdbname
	, note_type = uar_get_code_display(n.event_cd)
	, event_code_disp = uar_get_code_display(vc.event_cd)
	, ec_class = uar_get_code_display(vc.def_event_class_cd)
	
from
	NOTE_TYPE n
	, V500_EVENT_CODE vc
	
plan n
where n.note_type_id != 0
	and n.data_status_ind = 1

join vc
where vc.event_cd = n.event_cd
	and vc.code_status_cd = active_var
 
order by
	note_type
	, event_code_disp
	, ec_class
	
with time=60, nocounter, separator=" ", format

go to EXPORT_FILE
 
 
/**************************************************************/ 
; select Position Note Types
#POS_NOTE_TYPE

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	domain = currdbname
	, position = uar_get_code_display(l.role_type_cd)
	, note_type = uar_get_code_display(n.event_cd)
	
from
	CODE_VALUE c
	, NOTE_TYPE_LIST l
	, NOTE_TYPE n
	
plan c where c.code_set = 88
	and c.active_ind = 1
	and c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and c.cdf_meaning != "DBA"
	and c.display != "IT*-*"
	
join l where l.role_type_cd = c.code_value

join n where n.note_type_id = l.note_type_id
	and n.data_status_ind = 1

order by
	position
	, note_type
	
with time=60, nocounter, separator=" ", format

go to EXPORT_FILE


/**************************************************************/
; copy file to AStream
#EXPORT_FILE

if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#EXIT_PROGRAM

end
go
 

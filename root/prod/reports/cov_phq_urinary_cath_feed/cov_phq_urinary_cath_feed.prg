/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb 2022
	Solution:			Quality
	Source file name:	      cov_phq_urinary_cath_feed.prg
	Object name:		cov_phq_urinary_cath_feed
	Request#:			12113
	Program purpose:	      Urinary Cath Feed
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------------------------------*/
 
drop program cov_phq_urinary_cath_feed:dba go
create program cov_phq_urinary_cath_feed:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Task Start Date/Time" = "SYSDATE"
	, "Task End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Screen Display" = 1
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list, to_file
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare urinary_cath_var   = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Activity:'))), protect
declare urinary_elimi_var  = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Elimination'))), protect
declare sn_device_type_var = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'SN - Cath - Device Type'))),protect
declare atten_phys_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 333, 'Attending Physician'))), protect

declare msg_var = vc with noconstant("")
declare cnt  = i4 with noconstant(0)
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare opr_fac_var = vc with noconstant("")
declare output_var  = vc

 
;Facility variable Setup
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0)	;all[*] values were selected
	set opr_fac_var = "!="
else									;a single value was selected
	set opr_fac_var = "="
endif
 

;OPS Output variable Setup
;declare filename_var     = vc with constant(build("cov_gstest.txt"))
declare filename_var     = vc with constant(build("cov_urinary_cath_feed.txt"))
declare ops_dir_var	 = vc with constant(build("cer_temp:",  filename_var))
declare ops_dir_var1     = vc with constant(build("$cer_temp/", filename_var))
declare AStream_filepath_var = vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain)
						,"_cust/to_client_site/Quality/Urinary_Cath_Feed/", filename_var))
 
if (validate(request->batch_selection) = 1 or $to_file = 0)
	set output_var = value(ops_dir_var)
else
	set output_var = value($outdev)       
endif

 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record foley(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 pat_name = vc
		2 pat_type = vc
		2 encntrid = f8
		2 personid = f8
		2 admitdt = vc
		2 dischdt = vc
		2 attend_prsnl = vc
		2 fol_activity = vc
		2 fol_activity_dt = vc
		2 urinary_elimi = vc
		2 urinary_elimi_doc_dt = vc
		2 device_typ = vc
		2 device_doc_dt = vc
)
 
;---------------------------------------------------------------
 
;Foley activity
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from  encounter e
	, clinical_event ce
 
plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd = urinary_cath_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
	/*and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
		'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.', 'sn - cath - inserted',
		'uc inserted in surgery/procedure', 'assessment')*/
 
order by ce.encntr_id, ce.event_end_dt_tm, ce.event_id
 
Head report
	cnt = 0
Head ce.event_id
	cnt += 1
	foley->rec_cnt = cnt
	call alterlist(foley->plist, cnt)
	foley->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	foley->plist[cnt].encntrid = ce.encntr_id
	foley->plist[cnt].personid = e.person_id
	foley->plist[cnt].admitdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	foley->plist[cnt].fol_activity = trim(ce.result_val)
	foley->plist[cnt].fol_activity_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
 
with nocounter
 
 
;--------------------------------------------------------------------------------------------------------------------------------
;Urinary Elimination
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from  encounter e
	, clinical_event ce
 
plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd = urinary_elimi_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
 
order by ce.encntr_id, ce.event_end_dt_tm, ce.event_id
 
Head ce.event_id
	cnt += 1
	foley->rec_cnt = cnt
	call alterlist(foley->plist, cnt)
	foley->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	foley->plist[cnt].encntrid = ce.encntr_id
	foley->plist[cnt].personid = e.person_id
	foley->plist[cnt].admitdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	foley->plist[cnt].urinary_elimi = trim(ce.result_val)
 	foley->plist[cnt].urinary_elimi_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
 
with nocounter
 
;--------------------------------------------------------------------------------------------------------------------------------
;Cath Device Type
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from  encounter e
	, clinical_event ce
 
plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd =  sn_device_type_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
 
order by ce.encntr_id, ce.event_end_dt_tm, ce.event_id
 
Head ce.event_id
	cnt += 1
	foley->rec_cnt = cnt
	call alterlist(foley->plist, cnt)
	foley->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	foley->plist[cnt].encntrid = ce.encntr_id
	foley->plist[cnt].personid = e.person_id
	foley->plist[cnt].admitdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	foley->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	foley->plist[cnt].device_typ = trim(ce.result_val)
 	foley->plist[cnt].device_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
 
with nocounter
 
;--------------------------------------------------------------------------------------------------------------------------------
;Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(foley->plist, 5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = foley->plist[d.seq].personid
	and p.active_ind = 1
 
join ea where ea.encntr_id = foley->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(foley->plist,5) ,ea.encntr_id ,foley->plist[icnt].encntrid)
	while(idx > 0)
		foley->plist[idx].pat_name = p.name_full_formatted
		foley->plist[idx].fin = trim(ea.alias)
		idx = locateval(icnt ,(idx+1) ,size(foley->plist,5) ,ea.encntr_id ,foley->plist[icnt].encntrid)
	endwhile
 
with nocounter
 
;--------------------------------------------------------------------------------------------------------------------------------
;Attending
 
select into $outdev
 
  epr.encntr_id, pr.name_full_formatted, epr.encntr_prsnl_r_cd
, prsnl = trim(pr.name_full_formatted)
 
from (dummyt d with seq = value(size(foley->plist, 5)))
	, prsnl pr
	, encntr_prsnl_reltn epr
 
plan d
 
join epr where epr.encntr_id = foley->plist[d.seq].encntrid
	and epr.active_ind = 1
	and epr.encntr_prsnl_r_cd = atten_phys_var
 
join pr where pr.person_id = epr.prsnl_person_id
	and pr.active_ind = 1
 
order by epr.encntr_id, epr.encntr_prsnl_r_cd, prsnl
 
Head epr.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,foley->rec_cnt ,epr.encntr_id ,foley->plist[icnt].encntrid)
	atten_pr = fillstring(1000," ")
Head prsnl
	atten_pr = build2(trim(atten_pr),'[' ,trim(prsnl),']',',')
Foot epr.encntr_id
	while(idx > 0)
		foley->plist[idx].attend_prsnl = replace(trim(atten_pr),",","",2)
		idx = locateval(icnt ,(idx+1) ,foley->rec_cnt ,epr.encntr_id ,foley->plist[icnt].encntrid)
	endwhile
with nocounter
 
;==============================================================================================================

call echorecord(foley)
 
;==============================================================================================================
;Final Output
 
IF (foley->rec_cnt > 0)
 
	if (validate(request->batch_selection) = 1 or $to_file = 0)
		set modify filestream
	endif
 
	SELECT 
		if (validate(request->batch_selection) = 1 or $to_file = 0)
			with nocounter, pcformat (^^, ^|^, 1,1), format, format=stream, formfeed=none
			;with nocounter, format, formfeed=stream, maxcol=2000, separator='|'
			;with nocounter, pcformat (^"^, ^|^, 1), format = stream, format, time = 240
		else
			with nocounter, separator = " ", format
		endif
 
	INTO value(output_var)
		start_date = format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q')
 		, end_date = format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q')
		, facility = trim(substring(1, 30, foley->plist[d1.seq].facility))
		, fin = trim(substring(1, 30, foley->plist[d1.seq].fin))
		, patient_name = trim(substring(1, 70, foley->plist[d1.seq].pat_name))
		, encounter_type = trim(substring(1, 50, foley->plist[d1.seq].pat_type))
		, attending_prsnl = trim(substring(1, 1000, foley->plist[d1.seq].attend_prsnl))
		, cath_activity = trim(substring(1, 300, foley->plist[d1.seq].fol_activity))
		, cath_activity_dt = trim(substring(1, 30, foley->plist[d1.seq].fol_activity_dt))
		, urinary_elimination = trim(substring(1, 300, foley->plist[d1.seq].urinary_elimi))
		, urinary_elimination_dt = trim(substring(1, 30, foley->plist[d1.seq].urinary_elimi_doc_dt))
		, sn_cath_device_type = trim(substring(1, 300, foley->plist[d1.seq].device_typ))
		, device_doc_dt = trim(substring(1, 30, foley->plist[d1.seq].device_doc_dt))
	 
		from
			(dummyt   d1  with seq = size(foley->plist, 5))
		 
		plan d1
		 
		order by facility, fin
		 
		with nocounter, separator=" ", format
ELSE

 	select into $outdev from dummyt 
 
	head report
		msg_var = build2('No records found for parameters ', $start_datetime, ' TO ', $end_datetime)
		call center(msg_var, 1, 132)
 	with nocounter

ENDIF 


;=========================================================================
; Copy/Move File to AStream Folder
;=========================================================================
if (validate(request->batch_selection) = 1 or $to_file = 0)
	set cmd = build2("cp ", ops_dir_var1, " ", AStream_filepath_var)
	;Move File
	;set cmd = build2("mv ", ops_dir_var1, " ", AStream_filepath_var)
	set len = size(trim(cmd))
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif


;----------------------------------------------------------------------------------------------------------
 
;with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
;go to exitscript
 
 
#exitscript
 
end
go
 

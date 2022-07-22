drop program cov_gstest1 go
create program cov_gstest1
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
;------------------------------------------------------------------------------------------
 
select fin = ea.alias, ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd),ce.order_id, ce.result_val,ce.valid_until_dt_tm, ce.result_status_cd
, normalcy = uar_get_code_display(ce.normalcy_cd)
;, ce.event_title_text, ce.event_tag
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, performed_by = pr.name_full_formatted
, verified_by = pr1.name_full_formatted
, ce.event_id, ce.event_cd, ce.result_status_cd, ce.order_id
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.view_level, ce.publish_flag, ce.*
 
from clinical_event ce, encntr_alias ea, prsnl pr, prsnl pr1, encounter e
 
where ce.encntr_id = ea.encntr_id
and e.encntr_id = ce.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.performed_prsnl_id = pr.person_id
and ce.verified_prsnl_id = pr1.person_id
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
;and ce.encntr_id = 116742553
and ea.alias = '2112500007'
order by event_end_dt asc
 
;and ce.event_end_dt_tm between cnvtdatetimE("01-JAN-2020 00:00:00") AND cnvtdatetimE("28-MAR-2021 23:59:00")
;and ce.event_end_dt_tm >= cnvtdatetime('01-FEB-2021 00:00:00')
;and ce.result_val = "VTE Close Chart - Not Responsible Provider"
 
;and ce.view_level = 1
;and ce.publish_flag = 1 ;active
;and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
;and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
;and ce.order_id = 1821667791
;and ce.person_id =    14694437.00
;and ce.event_cd =    33188349.00
 
 
;order by ce.encntr_id,ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
with nocounter, separator=" ", format
 
end go
 
 
select * from ce_dynamic_label cd where cd.ce_dynamic_label_id in(4880093966.00 , 4880099462.00)
 
select * from ce_event_action cea where cea.encntr_id = 116741411
 
select o.order_mnemonic, o.orig_order_dt_tm ';;q' from orders o where o.encntr_id =   116743834.00 order by o.orig_order_dt_tm 
 
select o.catalog_type_cd from orders o where  o.catalog_cd =  2555123195.00 and o.orig_order_dt_tm <= sysdate
with nocounter, separator=" ", format, reccount = 100
 
select etype = uar_get_code_display(e.encntr_type_cd), nu = uar_get_code_display(e.loc_nurse_unit_cd)
,loc = uar_get_code_display(e.loc_facility_cd), estst = uar_get_code_display(e.encntr_status_cd)
from encounter e where e.encntr_id = 116744566
 
select * from orders o where o.order_id =  2150635897.00
 
select * from order_detail od where od.order_id = 2126447905
 
select * from oe_format_fields ofm where ofm.oe_field_id = 663785.00
 
 
select * from encntr_alias ea where ea.encntr_id IN(116526535, 116557943)
;ea.alias = '1931800194'
 
select e.disch_dt_tm "@SHORTDATETIME", e.* from encounter e where e.encntr_id = 116683833.00
 
select * from surgical_case sc where sc.encntr_id =   116719742.00
 
select * from surg_case_procedure scp where scp.surg_case_id =   289993913.00
 
 
select * from order_comment oc where oc.order_id =  2150664359.00
 
select * from long_text lt where lt.long_text_id in(727712725.00, 727712726.00)
 
select * from orders o where o.encntr_id = 116719742 and o.order_mnemonic = 'etha*'
 
select perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d'), performed_by = pr.name_full_formatted, ce.*
from clinical_event ce, prsnl pr
where ce.performed_prsnl_id = pr.person_id
and ce.event_cd =      712635.00;	Mode of Arrival;   19316609.00;	Transport Mode
and ce.performed_dt_tm between cnvtdatetime("27-FEB-2020 00:00:00") and cnvtdatetime("27-FEB-2020 23:59:00")
 
 
 
select * from encntr_alias ea where ea.encntr_id = 116680247.00
 
 
 
select O.order_id, O.template_order_id, status = uar_get_code_display(o.order_status_cd),o.order_mnemonic
, o.hna_order_mnemonic, o.ordered_as_mnemonic, o.catalog_cd, o.orig_order_dt_tm "@SHORTDATETIME", o.dept_misc_line
from orders o where o.encntr_id = 116680247.00
and o.catalog_cd = 2757685.00
;and o.order_mnemonic = 'etha*'
order by o.orig_order_dt_tm
 
 
select o.orig_order_dt_tm "@SHORTDATETIME", o.template_order_id,status = uar_get_code_display(o.order_status_cd),o.*
from orders o where o.order_id in(2165037147,  2165037225)
;2165046701
 
select * from orders o where o.order_id =  2165037147.00
 
select * from order_detail od where od.order_id =  2165037147.00 ;2165037225.00
 
select * from order_action oa where oa.order_id =   2165037225.00
 
 
select oa.order_id, status = uar_get_code_display(oa.order_status_cd),oa.action_dt_tm "@SHORTDATETIME"
from order_action oa where oa.order_id = 2165037225
 
 
select * from encntr_loc_hist elh where elh.encntr_id = 116680247.00
 
select nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm  "@SHORTDATETIME", end_dt = elh.end_effective_dt_tm  "@SHORTDATETIME", elh.*
from encntr_loc_hist elh
where elh.encntr_id = 116744734
;and elh.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
and elh.end_effective_dt_tm = (select max(elh1.end_effective_dt_tm) from encntr_loc_hist elh1
						where elh1.encntr_id = elh.encntr_id
						and elh1.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
						group by elh1.encntr_id)
 
;--------------------------------------------------------------------------------------------------------
 
 ;Nozin Troubleshoot
select * from encntr_alias ea where ea.encntr_id = 116679956
 
select * from orders o where o.order_id =  2776682965.00
 
select * from order_detail od where od.order_id =      2167495061.00; and od.action_sequence = 1
 
select od.order_id, od.action_sequence, od.detail_sequence, od.oe_field_display_value,od.oe_field_dt_tm_value
, od.oe_field_meaning, od.updt_dt_tm "@SHORTDATETIME"
from order_detail od where od.order_id =   2775147083.00
 
 
 
select nu = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,BEG = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.beg_effective_dt_tm  "@SHORTDATETIME" , elh.*
 from encntr_loc_hist elh where elh.encntr_id =   118670930.00
 
 
select
 o.encntr_id, o.order_id, o.template_order_id, o.ordered_as_mnemonic, o.order_status_cd
 , status = uar_get_code_display(o.order_status_cd) ,o.orig_order_dt_tm "@SHORTDATETIME", o.dept_misc_line
 ;, od.oe_field_meaning, od.oe_field_display_value , od1.oe_field_meaning, od1.oe_field_display_value
 
from orders o;, order_detail od, order_detail od1
where o.encntr_id = 116679956
and o.catalog_cd = 2757685.00 ;Nozin / Ethanol Topical
and o.active_ind = 1
order by o.orig_order_dt_tm
 
 
select oa.order_id, oa.action_dt_tm "@SHORTDATETIME", action_type = uar_get_code_display(oa.action_type_cd)
,order_status = uar_get_code_display(oa.order_status_cd) , oa.*
from order_action oa where oa.order_id in(2775147083.00,2776654531.00, 2776682965.00)
 
;--------------------------------------------------------------------------------------------------------
 
select * from orders o where o.order_id =2185579685
 
select * from orders o where o.encntr_id =    116727481.00
 
select * from order_detail o where o.order_id =  2184210773 ;2183841549
 
select * from orders o where o.template_order_id = 2183841549
 
select * from clinical_event ce where ce.encntr_id =   116727469.00
 
select event = uar_get_code_display(ce.event_cd),ce.event_cd, ce.*
from clinical_event ce where ce.person_id =    18808071.00
 
select * from eks_alert_escalation ae where ae.encntr_id =  116727481.00
 
select task_class = uar_get_code_display(ta.task_class_cd),ta.* from task_activity ta
where ta.encntr_id =   116727511.00 ;ta.task_id = 1605003655
 
select * from task_activity_history tah where tah.encntr_id =   116727469.00 ;tah.task_id = 1605003655
 
;task_activity = uar_get_code_display(ta.task_class_cd)
;3152572867.00	BH Individual Plan of Care  Review
 
select * from encntr_alias ea where ea.encntr_id = 116593059
 
 1927100471
 
select fin = ea.alias, e.encntr_id, e.person_id, etype = uar_get_code_display(e.encntr_type_cd)
, name = p.name_full_formatted
from encntr_alias ea, encounter e, person p
where ea.alias in('2015600014', '2015600015','1924701190','1926200884')
and e.encntr_id = ea.encntr_id
and p.person_id = e.person_id
order by p.name_full_formatted
 
;----------------------------------------------------------------------------------------------------------
 
select ce.result_val
from clinical_event ce
where ce.person_id = 18809299 ;18809308 ;@PATIENTID:{ActivePatient}
 and ce.view_level = 1
 and ce.publish_flag = 1
 and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 and ce.event_cd = 31580383.00
 and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.person_id = ce.person_id
 		and ce1.event_cd = ce.event_cd
		group by ce1.person_id, ce1.event_cd)
 
head report
	log_misc1 = "Result Not Found"
detail
	log_misc1 = trim(ce.result_val)
with nocounter, nullreport go
 
 
 
 
select ce.encntr_id, ce.result_val, ce.event_end_dt_tm "@SHORTDATETIME"
from clinical_event ce
where ce.person_id =    14522151.00
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 31580383.00 ;assessed_risk
 	and ce.event_id = (select result = max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
 		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id,ce1.event_cd)
 
 
select
ce.encntr_id, ce.result_val
;, event = uar_get_code_display(ce.event_cd), ce.event_cd
;, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
;, rank_ord = rank() over(partition by ce.person_id order by ce.person_id, ce.event_id desc)
 
from 	clinical_event ce
 
plan ce where ce.person_id = personid_var
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 31580383.00 ;assessed_risk
 
order by ce.person_id, rank_ord
 
 
select into 'nl:'  from clinical_event ce
where ce.person_id = 14522151.00 ;@PERSONID:{ActivePatient}
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 31580383.00 ;assessed_risk
 	and ce.event_id = (select result = max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
 		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id,ce1.event_cd)
head report
	log_misc1 = "Result Not Found"
detail
	log_misc1 = trim(ce.result_val)
with nocounter, nullreport go
 
;-------------------------------------------------------------------------------------------------------------
 
select into "nl"
from dm_info di
where di.info_name = "FE_WH"
 
detail
	ekssub->mod = trim(di.info_char)
	stat = findstring("winintel",ekssub->mod)
	if (stat = 0)  ekssub->mod = concat(ekssub->mod,"\winintel") endif
	ekssub->mod = replace(ekssub->mod,"\","\\",0)
	ekssub->mod = replace(ekssub->mod,"/","\\",0)
with nocounter go
 
;--------------------------------------------------------------------------------------------------------------
 
---- SEPSIS ----------------------
;Dismiss PRSNL - Open chart alert
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-Sepsis Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
	and   ce.verified_prsnl_id = reqinfo->updt_id
	and   ce.event_end_dt_tm >= cnvtdatetime("@EVENTENDDTTM:{RA}:1")
head report
	log_message = "Not Dismiss Value found"
	log_retval = 0
detail
	log_message = concat("Dismiss found on ",format(ce.event_end_dt_tm,";;q"))
	log_retval = 100
with nocounter, nullreport go
 
 
 
---- VTE -------------------------
--------------------------------------------------------
 
 
if(@LOGIC:{OpenChart} = 1)
		set log_misc1 = concat("Defer Advisor - Open Chart", " ", "@MESSAGE:[ALERT]", " Alert")  go
elseif( @LOGIC:{Scratchpad} = 1)
		set log_misc1 = concat("Defer Advisor - ScratchPad", " ", "@MESSAGE:[ALERT]", " Alert")  go
elseif( @LOGIC:{CloseChart} = 1)
		set log_misc1 = concat("Not Resposible Provider - Close Chart", " ", "@MESSAGE:[ALERT]", " Alert")  go
endif
 
--------------------------------------------------------
 
;Open chart Defer
select
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val       = "Open Chart"
	and   ce.event_end_dt_tm >= cnvtlookbehind("15,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Not Open Chart Defer found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
;VTE Scratchpad - Defer Advisor
 
select
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val       = "Open Chart"
	and   ce.event_end_dt_tm >= cnvtlookbehind("15,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Open Chart Defer Not Found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer Found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
 
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "VTE Scratchpad - Defer Advisor"
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Not Scratchpad - Defer Advisor found"
	log_retval = 0
detail
	log_message = build2("Scratchpad - Defer Advisor found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
;Not Responsible Provider
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "VTE Close Chart - Not Responsible Provider"
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Did not find Not Responsible Provider"
	log_retval = 0
detail
	log_message = build2("Not Responsible Provider found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "VTE Close Chart - Not Responsible Provider"
 
	and    21849288.00	D-VTE Advisor Recommendation
 
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Did not find Not Responsible Provider"
	log_retval = 0
detail
	log_message = build2("Not Responsible Provider found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
----------------------------------------------------------------------------------------------
 
;MIS-C
 
select; into 'nl:'
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_id
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, minutes = datetimediff(cnvtdatetime(curdate,curtime3), ce.event_end_dt_tm ,4)
 
from	clinical_event ce
 
plan ce where ce.encntr_id = 116690002.00
	and ce.event_cd = 703558
	;in(temp_oral_var,temp_tympa_var,temp_rectal_var,temp_axil_var,temp_core_var,temp_bladder_var,temp_tempo_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 		and ce1.result_status_cd in (34.00, 25.00, 35.00)
		and ce1.event_tag != "Date\Time Correction"
		and cnvtreal(ce1.result_val) >= 38.0
		group by ce1.encntr_id, ce1.event_cd)
		and ce.event_end_dt_tm < CNVTLOOKBEHIND("24,H")
 
----------------------------------------------------------
  1586958119.00
select * from synonym_item_r o where o.synonym_id = 21851071.00
 
select * from order_catalog oc where oc.
 
select * from form_association fa where fa.catalog_cd = 21851069.00
 
 
21851069.00	VTE Prophylaxis Advisor
 
2582508333.00	D-VTE Open Chart
 
select o.*  from orders o where o.order_id = 2304996743
o.encntr_id = 116708174
 
select event = uar_get_code_display(cea.event_cd),mormalcy = uar_get_code_display(cea.normalcy_cd),cea.normalcy_cd, cea.event_tag, cea.*
from ce_event_action cea where cea.event_id in(1586957495.00, 1586957756.00)
 
 
select o.order_mnemonic,o.current_start_dt_tm, o.soft_stop_dt_tm, o.* from orders o
where o.encntr_id =   116738044.00
and o.ordered_as_mnemonic = 'Lovenox'
order by o.current_start_dt_tm
 
select * from diagnosis d where CNVTUPPER(d.diagnosis_display) = '*MRSA*'
 
select n.source_string, n.nomenclature_id ; n.*
from nomenclature n
where CNVTUPPER(n.source_string) = '*MRSA*'
and n.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and n.active_ind = 1
order by n.source_string
 
 
 
SELECT CV1.*
FROM CODE_VALUE CV1
WHERE CV1.CODE_SET =  220 AND CV1.ACTIVE_IND = 1
AND CV1.DESCRIPTION = '*SENIOR*'
WITH  FORMAT, TIME = 60
 
 
 
select ta.encntr_id, ot.task_description, ta.task_create_dt_tm
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 116734581       ;@ENCOUNTERID:3
	and ta.task_status_cd in(427,428,429)
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform CHG Treatment on Insertion of PICC/Central Line"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm) != 0
	and ot.active_ind = 1
head report
	log_message = "Did not find existing PICC/Central Line Task"
	log_retval = 0
detail
	log_message = "Existing PICC/Central Line Task found "
	log_retval = 100
 
;--------------------------------------------------------------------------------------------------
 
select e.reg_dt_tm ';;q' from encounter e where e.encntr_id = 116740458
 
;--------------------------------------------------------------------------------------------------
 
select into 'nl:'
from clinical_event c
where c.encntr_id = trigger_encntrid
and c.person_id = trigger_personid
and c.event_cd = value(uar_get_code_by("DISPLAY", 72, "D-VTE Override Recommendation Reason"))
and c.result_val = 'Primary service to address prophylaxis orders'
and c.performed_prsnl_id = reqinfo->updt_id
 
head report
	log_retval =0
	log_message = 'Override Reason of Primary Service to Address Not Found'
detail
	log_retval = 100
	log_misc1 = format(c.event_end_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
	log_message = concat( 'Override Reason of Primary Service to Address Found from ', log_misc1)
with nullreport go
 
;------------------------------------------------------------------------------------------------
;Find OverDue Task
select ;into $outdev
 
ta.encntr_id, ot.task_description, ta.task_create_dt_tm ';;q', task_stat = uar_get_code_display(ta.task_status_cd)
 
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 116734466 ;@ENCOUNTERID:3
	and ta.task_status_cd = value(uar_get_code_by("DISPLAY", 79, "Overdue"))
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and ot.active_ind = 1
 
 
 
select into "nl:"
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = @ENCOUNTERID:2
	and ta.task_status_cd = value(uar_get_code_by("DISPLAY", 79, "Overdue"))
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm) = 0
	and ot.active_ind = 1
head report
	log_message = "No Overdue task Found Today"
	log_retval = 0
detail
	log_message = "Overdue Task Found Today"
	log_retval = 100
with nocounter, nullreport go
 
 
select * from task_activity ta where ta.encntr_id = 116734581
;------------------------------------------------------------------------------------------------
;Not done
select ;into "nl:"
ce.result_val, ce.event_cd
from clinical_event ce
plan ce where ce.encntr_id = 116734800.00 ; @ENCOUNTERID:2
	;and ce.event_cd =  3124608373.00 ;Chlorhexidine treatment
	and CE.event_cd = value(uar_get_code_by("DISPLAY", 72, "Chlorhexidine treatment"))
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.result_val = "Not done due to patient allergy, Patient refused"
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce.result_status_cd in (34.00, 25.00, 35.00)
					and ce.result_val = "Not done due to patient allergy, Patient refused"
					group by ce1.encntr_id, ce1.event_cd)
 
 
select into "nl:"
from clinical_event ce
plan ce where ce.encntr_id = @ENCOUNTERID:2
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Chlorhexidine treatment"))
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.result_val = "Not done due to patient allergy, Patient refused"
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce.result_status_cd in (34.00, 25.00, 35.00)
					and ce.result_val = "Not done due to patient allergy, Patient refused"
					group by ce1.encntr_id, ce1.event_cd)
head report
	log_message = "Not-Done Reason Not Found"
	log_retval = 0
detail
	log_message = "Not-Done Reason Found"
	log_retval = 100
with nocounter, nullreport go
;-----------------------------------------------------------------------------------------------------
;7pm task
 
select ;into "nl:"
	ot.task_description,ta.task_create_dt_tm ';;q', hour = datetimepart(cnvtdatetime(ta.task_create_dt_tm),4)
	,mins = datetimepart(cnvtdatetime(ta.task_create_dt_tm),5)
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 116734466.00 ; @ENCOUNTERID:3
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and datetimepart(ta.task_create_dt_tm,4) = 12
	and datetimepart(ta.task_create_dt_tm,5) <= 30
	and ot.active_ind = 1
 
 
select into "nl:"
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = @ENCOUNTERID:3
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and datetimepart(ta.task_create_dt_tm,4) = 7
	and datetimepart(ta.task_create_dt_tm,5) <= 30
	and ot.active_ind = 1
head report
	log_message = "No existing task Found Today 7:00 to 7:30 pm"
	log_retval = 0
detail
	log_message = "Existing Task Found Today 7:00 to 7:30 pm"
	log_retval = 100
with nocounter, nullreport go
 
 
 
 
he following example echos 2016:
 
call echo(datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),1)) go
The following example echos 6:
 
call echo(datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),2)) go
The following example echos 20:
 
call echo(datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),3)) go
The following example echos 13:
 
call echo(datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),4)) go
The following example echos 45:
 
call echo(datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),5)) go
 
 
 
 
select into "nl:"
from encntr_prsnl_reltn e
where  e.encntr_id = trigger_encntrid
and e.prsnl_person_id = reqinfo->updt_id
and e.active_ind = 1
and e.expiration_ind = 0
and e.beg_effective_dt_tm < sysdate
and e.end_effective_dt_tm > sysdate
and e.encntr_prsnl_r_cd in (value(uar_get_code_by("DISPLAY", 333, "Consulting Physician"))
	,value(uar_get_code_by("DISPLAY", 333, "Database Coordinator")))
head report log_misc1 = "YES" go
 
 
 
 
 
 
 
 
 
 
 
 
 
;------------------------------------------------------------------------------------------------
 
select into 'nl:'
from
	encounter e
plan  e
	where e.encntr_id =  @ENCOUNTERID
	and e.encntr_type_cd = 19962820.00
	and e.disch_dt_tm is null
	and e.active_ind = 1
	and day(cnvtdatetime(curdate,0)) > day(e.reg_dt_tm)
	and month(cnvtdatetime(curdate,0)) >= month(e.reg_dt_tm)
	and year(cnvtdatetime(curdate,0)) >= year(e.reg_dt_tm)
head report
	log_message = "OutPatient in a bed - Same day"
	log_retval = 0
detail
	log_message = "OutPatient in a bed - After Midnight"
	log_retval = 100
with nocounter, nullreport go
 
;------------------------------------------------------------------------------------------------
;Outpatient in a Bed - After Midnight?
 
select
e.encntr_id, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q', uar_get_code_display(e.encntr_type_cd)
,cur_day = day(curdate), cur_month = month(curdate), cur_year = year(curdate)
,reg_day = day(e.reg_dt_tm), reg_month = month(e.reg_dt_tm), reg_year = year(e.reg_dt_tm)
 
from encounter e
 
plan e where e.encntr_id = 123515197.00
and e.encntr_type_cd = 19962820.00	;Outpatient in a Bed
and e.disch_dt_tm is null
and day(cnvtdatetime(curdate,0)) > day(e.reg_dt_tm)
and month(curdate) >= month(e.reg_dt_tm)
and year(curdate) >= year(e.reg_dt_tm)
 
;------------------------------------------------------------------------------------------------
;Outpatient in a Bed - After Midnight? - Next day 9am Timer
 
select
e.encntr_id, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q', uar_get_code_display(e.encntr_type_cd)
,cur_day = day(curdate), cur_month = month(curdate), cur_year = year(curdate)
,reg_day = day(e.reg_dt_tm), reg_month = month(e.reg_dt_tm), reg_year = year(e.reg_dt_tm)
 
from encounter e
 
plan e where e.encntr_id = 123515197.00
and e.encntr_type_cd = 19962820.00	;Outpatient in a Bed
and e.disch_dt_tm is null
and day(cnvtdatetime(curdate,0)) > day(e.reg_dt_tm)
and month(curdate) >= month(e.reg_dt_tm)
and year(curdate) >= year(e.reg_dt_tm)
 
 
 
select into 'nl:'
from
	encounter e
plan  e
	where e.encntr_id =  @ENCOUNTERID
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00,  19962820.00)
					;Inpatient, Observation, Behavioral, Outpatient in a bed
	and e.disch_dt_tm is null
	and e.active_ind = 1
	and day(cnvtdatetime(curdate,0)) > day(e.reg_dt_tm)
	and month(cnvtdatetime(curdate,0)) >= month(e.reg_dt_tm)
	and year(cnvtdatetime(curdate,0)) >= year(e.reg_dt_tm)
head report
	log_message = " "
	log_retval = 0
detail
	if(e.encntr_type_cd = 19962820.00)
		log_message = "OutPatient in a bed - After Midnight"
		log_retval = 100
with nocounter, nullreport go
 
 
      309308.00	Inpatient
     309312.00	Observation
 2555137051.00	Behavioral Health
 
;------------------------------------------------------------------------------------------------
;Powerform Details
select * from dcp_forms_ref dfr where dfr.dcp_forms_ref_id = 171986839.00
 
select * from dcp_forms_ref dfr where dfr.description = "QM Reason VTE Prophylaxis Not Given 2020 - Custom"
 
select * from dcp_forms_activity dfr where dfr.dcp_forms_ref_id = 171986839.00
 
;-----------------------------------------------------------------------------------------------------
 
Allergies listed are pulled from code_set = 400 and cdf_meaning is MULALGCAT or MULDRUG.
 
 
select event = uar_get_code_display(ce.event_cd),ce.result_val, ce.result_status_cd, stat = uar_get_code_display(ce.result_status_cd)
, ce.event_id, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d'), ce.valid_until_dt_tm ';;q'
;, ce.event_cd, ce.*
from clinical_event ce where ce.encntr_id = 116740458
order by event, ce.event_id, ce.event_end_dt_tm
 
 
 and ce.event_cd in(34439957.00, 24604416.00)
 
select e.disch_dt_tm ';;q', st = uar_get_code_display(e.encntr_status_cd ) from encounter e where e.encntr_id = 116727517
 
 
;--------------------------------------------------------------------------------------------------------------
;Not Done Reason
select; into "nl:"
	event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.event_id, ce.result_status_cd
from clinical_event ce
plan ce where ce.encntr_id = 116740458  ;@ENCOUNTERID:3
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Chlorhexidine treatment"))
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_val in("Not done due to patient allergy, Patient refused" , "Not done due to patient allergy" , "Patient refused")
 
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					group by ce1.encntr_id, ce1.event_cd)
head report
	log_message = "Not-Done Reason Not Found"
	log_retval = 0
detail
	log_message = "Not-Done Reason Found"
	log_retval = 100
with nocounter, nullreport go
 
 
;--------------------------------------------------------------------------------------------------------------------
;Existing Task?
select ;into "nl:"
	ot.task_description, ta.task_create_dt_tm ';;q',ta.task_status_cd,task_stat = uar_get_code_display(ta.task_status_cd)
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 116742785    ;@ENCOUNTERID:3
	and ta.task_status_cd in(value(uar_get_code_by("DISPLAY", 79, "Complete")),
					 value(uar_get_code_by("DISPLAY", 79, "InProcess")),
					 value(uar_get_code_by("DISPLAY", 79, "Opened")),
					 value(uar_get_code_by("DISPLAY", 79, "Overdue")),
					 value(uar_get_code_by("DISPLAY", 79, "Pending")))
	;and ta.task_status_cd in(419,425,427,428,429)
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and ot.active_ind = 1
head report
	log_message = "No existing task Today"
	log_retval = 0
detail
	log_message = "Existing Task found Today"
	log_retval = 100
with nocounter, nullreport go
 
 
;-------------------------------------------------------------------------------------------
;Outpatient - After Midnight
select ;into 'nl:'
	e.encntr_id
from
	encounter e
plan  e
	where e.encntr_id =  116742143  ;@ENCOUNTERID:2
	and e.encntr_type_cd = value(uar_get_code_by("DISPLAY", 71, "Outpatient in a Bed"))
	and e.disch_dt_tm is null
	and e.active_ind = 1
	and day(cnvtdatetime(curdate,0)) > day(e.reg_dt_tm)
	and month(cnvtdatetime(curdate,0)) >= month(e.reg_dt_tm)
	and year(cnvtdatetime(curdate,0)) >= year(e.reg_dt_tm)
head report
	log_message = "OutPatient in a bed - Same day"
	log_retval = 0
detail
	log_message = "OutPatient in a bed - After Midnight"
	log_retval = 100
with nocounter, nullreport go
 
 
 
;------------------------------------------------------------------------------------------
;PC and UC Status
select into "nl:"
from clinical_event ce
plan ce where ce.encntr_id = @ENCOUNTERID:2
	and ce.event_cd in(value(uar_get_code_by("DISPLAY",72,"Urinary Catheter Activity:"))
		,value(uar_get_code_by("DISPLAY",72,"Central Line Activity.")))
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_val != "Discontinued"
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					group by ce1.encntr_id, ce1.event_cd)
head report
	log_message = "PICC or Foley in Discontinued Status Found"
	log_retval = 0
detail
	log_message = "PICC or Foley in Active Status Found"
	log_retval = 100
with nocounter, nullreport go
 
;------------------------------------------------------------------------------------------------------------
 
 
select *;into "nl:"
from encntr_loc_hist elh
plan elh where elh.encntr_id = 116602132 ;@ENCOUNTERID:2
	and elh.loc_nurse_unit_cd != null
 
head report
	log_message = "There is no assigned Nurse Unit"
	log_retval = 0
detail
	log_message = "Assigned Nurse Unit Found"
	log_retval = 100
with nocounter, nullreport go
 
;---------------------------------------------------
 
select ;into "nl:"
event = uar_get_code_display(ce.event_cd), ce.result_val
from clinical_event ce
plan ce where ce.encntr_id =   116680052.00 ;@ENCOUNTERID:2
	and ce.event_cd in(value(uar_get_code_by("DISPLAY",72,"D-VTE Advisor Exit Reason")))
 	and trim(ce.result_val) = 'Cancel - in error'
 
head report
	log_message = "There is no assigned Nurse Unit"
	log_retval = 0
detail
	log_message = "Assigned Nurse Unit Found"
	log_retval = 100
with nocounter, nullreport go
 
 
 
select ema.module_name, emad.logging, emad.updt_dt_tm ';;q', emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
;and( cnvtupper(ema.module_name) = 'COV_VTE_SCRATCHPAD' OR cnvtupper(ema.module_name) = 'COV_VTE_OC_24HOUR_ADMIT')
and ema.module_name = 'COV_VTE*'
and emad.encntr_id =  116680052  ;116742767.00 ;116680052.00 ;@ENCOUNTERID:2
and emad.template_type = 'A'
;and emad.updt_dt_tm >= sysdate
order by emad.updt_dt_tm
 
 
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_cd, ce.event_end_dt_tm ';;q'
,ce.event_id, ce.parent_event_id
from clinical_event ce where ce.encntr_id = 116742168   ;116742767.00
116600499
 
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_cd, ce.event_end_dt_tm ';;q'
from 	clinical_event ce
plan ce
	where ce.encntr_id = 116680052 ;@ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "VTE Close Chart - Not Responsible Provider"
	and   ce.verified_prsnl_id = reqinfo->updt_id
 
 
 
 
 
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_cd, ce.event_end_dt_tm ';;q'
from	clinical_event ce
plan ce
	where ce.encntr_id = 116742767.00 ;@ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val       = "Open Chart"
	and   ce.event_end_dt_tm >= cnvtlookbehind("15,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
 
 
 
   270274033.00	D-VTE Advisor Exit Reason	Auth (Verified)	Cancel - in error
 
 
select e.loc_nurse_unit_cd
from encounter e where e.encntr_id = 116602132
 
select nu = uar_get_code_display(elh.loc_nurse_unit_cd), elh.*
from encntr_loc_hist elh where elh.encntr_id = 116602132
and elh.loc_nurse_unit_cd != null
;------------------------------------------------------------------------------------------------------------------
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_cd, ce.event_end_dt_tm ';;q'
,ce.event_id, ce.parent_event_id
from clinical_event ce where ce.encntr_id = 116600499
 
 
 
;------------------------------------------------------------------------------------------------------------
 
select distinct em.module_name from eks_module em
where cnvtupper(em.module_name) = '*DIS*'
;and em.active_flag = 'A'
;and em.maint_validation = 'PRODUCTION'
order by em.module_name
 
;--------------------------------------------------------------
;Med Rec
 
select orn.person_id, orn.encntr_id, orn.order_recon_id, orn.recon_type_flag, orn.performed_dt_tm ';;q'
from
  order_recon orn
plan orn
;where orn.person_id = 16193239.00 ;
where orn.encntr_id =   116743828.00
  and orn.recon_type_flag = 1 ; MedRecType
  and not exists
   (select 1
    from order_recon orn2 ;THIS WILL GET THE LATEST ONE
  	where orn2.encntr_id = orn.encntr_id
      and orn2.recon_type_flag = 1 ;MedRecType
      and orn2.performed_dt_tm > orn.performed_dt_tm )
 
 
select ocd.order_recon_id, ocd.order_mnemonic, ocd.recon_order_action_mean, ocd.updt_dt_tm ';;q'
,ocd.continue_order_ind, ocd.order_nbr
from order_recon_detail ocd where ocd.order_recon_id in(2409218301.00, 2409233813.00)
order by ocd.order_recon_id;, ocd.continue_order_ind
 
order_recon_id  recon_type_flag
 2409233813.00 	3
 2409218301.00 	3
 2409233793.00 	1
 
;-------------------------------------------------------
;ocd.continue_order_ind - meaning
indicates whether the personnel that performed the reconciliation chose to continue the order.
1 - continue the order, 2 - do not continue the order, 3 - continue the order with changes, 4 - acknowledge order.
;-------------------------------------------------------
;---------------------------------------
;orn.recon_type_flag - type of reconciliation that was performed.
 
          1.00	Admission
          2.00	Transfer
          3.00	Discharge
          4.00	Short Term Leave
          5.00	Return From Short Term Leave
;---------------------------------------
 
 
 
 
detail
4_testmedsrecreply->order_recon_id = orn.order_recon_id
4_testmedsrecreply->performed_dt_tm = orn.performed_dt_tm
4_testmedsrecreply->med_rec_status = "Complete"
 
with nocounter
 
 
 
 
select o.person_id, o.encntr_id, o.order_id, o.order_mnemonic, o.hna_order_mnemonic
,cat_type = uar_get_code_display(o.catalog_type_cd), o.catalog_type_cd
, order_status = uar_get_code_display(o.order_status_cd), o.updt_dt_tm ';;q'
from  orders o
plan o where o.person_id =    16193239.00 ;$PersonId
     ;and o.catalog_type_cd+0 = PHARM_CAT_CD
     ;and o.order_status_cd+0 = ORDEREDSTATUS_CD
     ;and o.projected_stop_dt_tm+0 = null
     and o.orig_ord_as_flag in(1,2,3)
     and o.iv_ind = 0
     and o.active_ind = 1
   ;and o.orig_order_dt_tm < CNVTDATETIME(4_testmedsrecreply->performed_dt_tm)
 
 
select o.person_id, o.encntr_id, o.order_id, o.order_mnemonic, O.orig_ord_as_flag
,cat_type = uar_get_code_display(o.catalog_type_cd), o.catalog_type_cd
, order_status = uar_get_code_display(o.order_status_cd), o.updt_dt_tm ';;q'
from  orders o
where O.order_id = 2417510863
and o.active_ind = 1
 
 
   2417510863
;-----------------------------------------------------------------------
o.ORIG_ORD_AS_FLAG
 
          0.00	Normal Order
          1.00	Prescription/Discharge Order
          2.00	Recorded / Home Meds
          3.00	Patient Owns Meds - this value is deprecated and will be removed in the future
          4.00	Pharmacy Charge Only
          5.00	Satellite (Super Bill) Meds
 
;-----------------------------------------------------------------------
 
 
 
 
select * from order_recon_detail ocd where ocd.order_recon_id =   445145043.00
 
select o.encntr_id, o.orig_ord_as_flag,o.* from orders o where o.order_id =   433565695.00 ;445183911
 
  110705084.00
 
select * from order_compliance oc where oc.encntr_id =   110705084.00
 
select * from med_history_audit mha where mha.person_id = 16193239.00
 
select * from med_rec_detail mha where mha.  .person_id = 16193239.00
 
 
;------------------ CHG -------------------------------
select ta.task_create_dt_tm ';;q', task_status = uar_get_code_display(ta.task_status_cd)
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 116742767; @ENCOUNTERID:2
	and ta.active_ind = 1
	and ta.task_status_cd in(value(uar_get_code_by("DISPLAY", 79, "Complete")),
					 value(uar_get_code_by("DISPLAY", 79, "InProcess")),
					 value(uar_get_code_by("DISPLAY", 79, "Opened")),
					 value(uar_get_code_by("DISPLAY", 79, "Overdue")),
					 value(uar_get_code_by("DISPLAY", 79, "Pending")))
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and ot.active_ind = 1
 
 
select nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm  "@SHORTDATETIME", end_dt = elh.end_effective_dt_tm  "@SHORTDATETIME", elh.*
from encntr_loc_hist elh
where elh.encntr_id = 116742767
;and elh.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
and elh.end_effective_dt_tm = (select max(elh1.end_effective_dt_tm) from encntr_loc_hist elh1
						where elh1.encntr_id = elh.encntr_id
						and elh1.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
						group by elh1.encntr_id)
 
 
select cv1.*
from code_value cv1
where cv1.code_set = 220
and (cv1.display = '* EB' or cv1.display = '* PACU')
order by cv1.display
 
 
select p.name_full_formatted, p.person_id from person p where cnvtlower(p.name_full_formatted) = 'zzzmock, joseph randall'
 
select p.name_full_formatted, p.name_first, p.person_id, e.encntr_id, e.reg_dt_tm, fin = ea.alias
from person p, encntr_alias ea, encounter e
where e.person_id = p.person_id
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and cnvtlower(p.name_full_formatted) = 'zzzmock, joseph randall'
 
;-------------------------------------------------------------------------------------------------
;FInding current session
select * from prsnl pr where cnvtlower(pr.username) = 'gsaravan' ;   12428721.00 pid
 
select * from prsnl pr where cnvtupper(pr.username) = 'UA.KSHIRLEY'
 
 
select pr.username from prsnl pr where pr.name_full_formatted = 'UA.SHIRLEY, KIMBERLY'
'SHIRLEY, KIMBERLY'
 
 
;Find Session
select ac.start_dt_tm ';;q', ac.end_dt_tm ';;q', ac.application_image,ac.*
from application_context ac
;where cnvtlower(ac.username) = 'gsaravan'
where cnvtlower(ac.username) = 'ua.kshirley'
;where ac.person_id =    12736302.00
and ac.application_image = 'PowerChart'
order by ac.start_dt_tm
 
;Latest Session
select ac.start_dt_tm ';;q', ac.end_dt_tm ';;q', ac.application_image,ac.*
from application_context ac
plan ac where ac.person_id = 12428721.00 ;Mee
;and ac.application_image = 'PowerChart'
;and datetimecmp(cnvtdatetime(curdate, curtime), ac.start_dt_tm)  = 0 ;today without time
;and ac.end_dt_tm is null
and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and ac1.application_image = 'PowerChart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0 ;today without time
				and ac1.end_dt_tm is null)
 
 
;------------------------------------------------------------
;Rule section
select ac.start_dt_tm ';;q', ac.end_dt_tm ';;q', ac.application_image,ac.*
from application_context ac
plan ac where ac.person_id = 12428721.00 ;Mee reqinfo->updt_id
and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and ac1.application_image = 'PowerChart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0 ;today without time
				and ac1.end_dt_tm is null)
head report
	log_message = "Open Chart Defer Not Found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer Found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
;-----------------------------------------------------------------------
 
 
 
******* limit the  scratchpad log >= ac.start_dt_tm , also openchart defer and closechart action
 
;Openchart alert with session lookup
 
select ac.start_dt_tm ';;q', ac.end_dt_tm ';;q', ac.application_image, ce.encntr_id, ce.result_val
, event_dt = ce.verified_dt_tm ';;q', session_dt = ac.start_dt_tm ';;q'
 
from clinical_event ce, application_context ac
 
plan ac where ac.person_id = reqinfo->updt_id
and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and ac1.application_image = 'PowerChart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0 ;today without time
				and ac1.end_dt_tm is null)
 
join ce where ce.verified_prsnl_id = ac.person_id
	and ce.verified_dt_tm >= ac.start_dt_tm
	and ce.encntr_id = 116743828.00       ;@ENCOUNTERID:1
	and ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.event_tag        != "Date\Time Correction"
	and ce.result_val       = "Open Chart"
	and datetimecmp(cnvtdatetime(curdate, curtime), ce.verified_dt_tm)  = 0
	;and   ce.verified_prsnl_id = reqinfo->updt_id
	and   ce.result_status_cd in(value(uar_get_code_by("MEANING",8,"AUTH"))
					,value(uar_get_code_by("MEANING",8,"MODIFIED"))
					,value(uar_get_code_by("MEANING",8,"ALTERED")))
 
 
 
 
select ac.start_dt_tm ';;q', ac.end_dt_tm ';;q', ac.application_image
, ce.encntr_id, ce.result_val, verify_dt = ce.verified_dt_tm ';;q', ce.event_cd,evt = uar_get_code_display(ce.event_cd)
from application_context ac, clinical_event ce
 
plan ac where ac.person_id = reqinfo->updt_id
and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and ac1.application_image = 'PowerChart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0 ;today without time
				and ac1.end_dt_tm is null)
 
join ce where ce.verified_prsnl_id = ac.person_id
	and ce.encntr_id = 116743828.00       ;@ENCOUNTERID:1
	and ce.verified_dt_tm >= ac.start_dt_tm
	and ce.event_cd = 2582508333.00; value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart")) ;2582508333.00
	and ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.event_tag        != "Date\Time Correction"
	and ce.result_val       = "Open Chart"
with nocounter, time = 60
 
select * from clinical_event ce where ce.event_cd =  2582508333.00	;D-VTE Open Chart
and ce.encntr_id = 116743828.00
 
 
head report
	log_message = "Open Chart Defer Not Found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer Found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
;--------------- 06/08/21
select ce.encntr_id, ce.event_end_dt_tm ';;q', event = uar_get_code_display(ce.event_cd), ce.result_val
from
	clinical_event ce
plan ce
	where ce.encntr_id = 116743828  ;@ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val       = "Open Chart"
	and   datetimecmp(cnvtdatetime(curdate, curtime), ce.verified_dt_tm)  = 0
	and   ce.event_end_dt_tm >= cnvtlookbehind("30,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
	and	ce.result_status_cd in( value(uar_get_code_by("MEANING",8,"AUTH"))
					 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
					 ,value(uar_get_code_by("MEANING",8,"ALTERED"))	)
 
head report
	log_message = "Open Chart Defer Not Found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer Found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 
;-------------------------------------------------------------------------------------------------
;OEF - Order Entry Format
 
 
select o.catalog_cd, o.* from orders o where o.order_id =   2417031909
 
19955031
 
select * from catalog c where c.  catalog_cd = 2771404
 
 
select o.orig_ord_as_flag,o.catalog_cd, o.* from orders o where o.order_id = 2417031909
 
select * from order_catalog_synonym ocs where ocs.oe_format_id =   273220713.00 and ocs.catalog_cd =     2759877.00
 
select * from oe_format_fields oef
 
select * from oe_format_fields oef where oef.oe_field_id = 12771.00 ; oef.oe_format_id =   273220713.00
 
select * from oe_field_meaning ofm where ofm.oe_field_meaning_id = 2070.00
 
select * from order_detail od where od.order_id = 2417031909
 
 
select e.encntr_id from encounter e where e.person_id = @patientid:2 order e.encntr_id detail encntrid = e.encntr_id
 
select e.encntr_id from encounter e where e.person_id =    18819025.00 order e.encntr_id
 
select * from encntr_alias ea where ea.alias = '2032800005'
 
select * from encounter e where e.encntr_id =   116739133.00
    18832229.00
;-------------------------------------------------------------------------------------------------
;MRSA PROJECT
 
select
    cv1.code_value
    ,cv1.display
    ,cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
 
select elh.encntr_id, nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm  "@SHORTDATETIME", end_dt = elh.end_effective_dt_tm  "@SHORTDATETIME", elh.*
from encntr_loc_hist elh
where elh.beg_effective_dt_tm between CNVTDATETIME('01-MAY-2021 00:00:00') and CNVTDATETIME('18-MAY-2021 00:00:00')
 
 
where elh.encntr_id = 116742767
;and elh.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
and elh.end_effective_dt_tm = (select max(elh1.end_effective_dt_tm) from encntr_loc_hist elh1
						where elh1.encntr_id = elh.encntr_id
						and elh1.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
						group by elh1.encntr_id)
 
 
;----------------------------------------------------------------
Where ce.encntr_id = ea.encntr_id
	and (ce.task_assay_cd = 1266875
	and ce.result_val = "Insert")
	and not exists (select ce2.encntr_id
	from clinical_event ce2
	where (ce.task_assay_cd = 1266875
	and ce.result_val = "Discontinue") )
 
;----------------------------------------------------------------
 
select
    cv1.code_value
    ,cv1.display
    ,cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
 
 
 
 
and e.encntr_type_cd not in(2555137251.00, 2555137243.00, 2555267433.00,4189852.00);Preadmit OB,Scheduled,Newborn,Prereg
 
 
;---------------------------------------------------------------------------------------------------
;VTE
 
select o.order_mnemonic, o.order_id, o.orig_order_dt_tm ';;q', o.*
from orders o where o.encntr_id = 116743828
order by o.orig_order_dt_tm
 
select * from order_detail od where od.order_id =  2433879679.00
 
 
;-------------------------------------------------------------------------------------------------- 
;Stroke 

select ce.encntr_id, ce.event_end_dt_tm ';;q', event = uar_get_code_display(ce.event_cd), ce.result_val
from
	clinical_event ce
plan ce
	where ce.encntr_id =   116743834.00  ;@ENCOUNTERID:1
	and ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"Discharge Summary"))
	and ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.event_tag != "Date\Time Correction"
	and datetimecmp(cnvtdatetime(curdate, curtime), ce.verified_dt_tm)  = 0
	and ce.result_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
 	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 
 			where ce1.encntr_id = ce.encntr_id
	 		and ce1.event_cd = ce.event_cd
			group by ce1.encntr_id,ce1.event_cd)

	
	
head report
	log_message = "Discharge Summary Not Found"
	log_retval = 0
detail
	log_message = concat("Discharge Summary Found - ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go




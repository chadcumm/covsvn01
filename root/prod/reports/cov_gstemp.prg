drop program cov_gstemp:DBA go
create program cov_gstemp:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
declare initcap()            = c100
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'MRN')),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'FIN NBR')),protect
declare prsnl_var            = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var         = f8 with constant(uar_get_code_by("CDF_MEANING", 88, 'PRIMARY CARE')),protect  ;19944603.00
 
declare type_var             = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Type:')),protect
declare rest_loc_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Location:')),protect
 
;Reason for restraint
declare rest_reson_var1      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Ed-Reason for Use of Restraint')),protect
declare rest_reson_var2      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Initiation Behavior Reason NV')),protect
declare rest_reson_var3      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Preadm Restraint Reason')),protect
declare rest_reson_var4      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reason for Restraint LTC')),protect
declare rest_reson_var5      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reason for Considering Restraint LTC')),protect
declare rest_reson_var6      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Initiation Behavior Reason V')),protect
 
 
declare activity_type_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Activity Type:')),protect
declare discon_crite_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Discontinue Criteria for Restraint')),protect
declare rest_alter_type_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternative Type')),protect
 
;Restraints activities documented
declare rest_alt_doc_var1    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternatives Violent')),protect
declare rest_alt_doc_var2    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternatives Non-Violent')),protect
 
;declare rest_response_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Response to Alternatives')),protect
 
;Behavior requiring Restraint
declare beha_med_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Behavior Requiring Medical Restraint')),protect
declare beha_vio_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Requiring Violent Restraint')),protect
declare beha_behav_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Behavior Requiring Behavioral Restraint')),protect
 
declare rest_response_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Response to Alternatives')),protect
declare eval_status_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Evaluation of Status in Restraints:')),protect
declare rest_behav_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Behavior Description')),protect
 
declare reles_resn_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Reason for Release')),protect
declare rest_reappli_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Reapplied After Care/Treatment')),protect
 
Record events(
	1 plist[*]
		2 encntrid = f8
		2 pat_name = vc
		;2 elist[*]
			2 rest_type = vc
			2 rest_type_result = vc
			2 rest_loc = vc
			2 rest_loc_result = vc
			;3 eventcd = f8
			;3 event = vc
			;3 result = vc
			;3 performdt = dq8
	) 
 
 
 
select distinct into "NL:"
 
from

encounter e
,(	
  
  ( select ce.encntr_id,ce.event_cd, ce.result_val, ce.performed_dt_tm, ce.performed_prsnl_id, ce.order_id 
	,ordext = dense_rank() over (partition by ce.encntr_id, ce.event_cd order by ce.performed_dt_tm desc)
 	from clinical_event ce, encounter e
 	where ce.encntr_id = e.encntr_id
	and ce.encntr_id =   110451821.00
 	and ce.result_status_cd in(25,34,35)
	and ce.event_cd in(type_var, rest_loc_var,rest_reson_var1,rest_reson_var2, rest_reson_var3,rest_reson_var4,rest_reson_var5,
		rest_reson_var6, activity_type_var, discon_crite_var, rest_alter_type_var,rest_alt_doc_var1,  rest_alt_doc_var2,
		rest_response_var, beha_med_var, beha_vio_var, beha_behav_var, rest_response_var, eval_status_var,rest_behav_var,
		reles_resn_var, rest_reappli_var)
	with sqltype("f8", "f8", "VC", "dq8", "f8", "f8","i4")	
 	)i2
 	
  )	

plan i2 where i2.ordext = 1	
  
join e where e.encntr_id = i2.encntr_id
	 and e.active_ind = 1
	
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT


;Load into Record Structure
HEAD REPORT
 
	pcnt = 0
	call alterlist(events->plist, 10)
 
HEAD e.encntr_id
 	pcnt = pcnt + 1
	if(mod(pcnt, 10) = 1 and pcnt > 100)
		call alterlist(events->plist, pcnt+9)
	endif
	events->plist[pcnt].encntrid      = e.encntr_id
	events->plist[pcnt].pat_name      = "N/A"
	ecnt = 0
 
;HEAD i2.event_cd
DETAIL
;	ecnt = ecnt + 1
;	call alterlist(events->plist[pcnt].elist, ecnt)
	
	CASE (i2.event_cd)	
		OF type_var:
			events->plist[pcnt].rest_type = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].rest_type_result = i2.result_val
			;events->plist[pcnt].elist[ecnt].event_short = "type_var"
			;events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			;events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			;events->plist[pcnt].elist[ecnt].result = i2.result_val
			;events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_loc_var:
			events->plist[pcnt].rest_loc = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].rest_loc_result = i2.result_val

			;events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			;events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			;events->plist[pcnt].elist[ecnt].result = i2.result_val
			;events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm


/*

		OF rest_reson_var1:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reson_var2:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reson_var3:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reson_var4:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reson_var5:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reson_var6:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF activity_type_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_alter_type_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_alt_doc_var1:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_alt_doc_var2:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_response_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF beha_med_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF beha_vio_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF beha_behav_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_response_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF eval_status_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_behav_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF reles_resn_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		OF rest_reappli_var:
			events->plist[pcnt].elist[ecnt].eventcd = i2.event_cd
			events->plist[pcnt].elist[ecnt].event = uar_get_code_display(i2.event_cd)
			events->plist[pcnt].elist[ecnt].result = i2.result_val
			events->plist[pcnt].elist[ecnt].performdt = i2.performed_dt_tm
		*/			
			
	ENDCASE	

;FOOT i2.event_cd
; 	call alterlist(events->plist[pcnt].elist, ecnt)
	
FOOT REPORT
 	call alterlist(events->plist, pcnt)
 
WITH nocounter
 
 
call echojson(events,"rec.out", 0)
call echorecord(events)

SELECT INTO $OUTDEV
	PLIST_ENCNTRID = EVENTS->plist[D1.SEQ].encntrid
	, PLIST_PAT_NAME = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].pat_name)
	, PLIST_REST_TYPE = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].rest_type)
	, PLIST_REST_TYPE_RESULT = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].rest_type_result)
	, PLIST_REST_LOC = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].rest_loc)
	, PLIST_REST_LOC_RESULT = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].rest_loc_result)

FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(EVENTS->plist, 5)))

PLAN D1

WITH NOCOUNTER, SEPARATOR=" ", FORMAT





/*
SELECT INTO $outdev ;geet.csv
	PLIST_ENCNTRID = EVENTS->plist[D1.SEQ].encntrid
	, ELIST_EVENTCD = EVENTS->plist[D1.SEQ].elist[D2.SEQ].eventcd
	, ELIST_EVENT = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].elist[D2.SEQ].event)
	, ELIST_RESULT = SUBSTRING(1, 30, EVENTS->plist[D1.SEQ].elist[D2.SEQ].result)
	, ELIST_PERFORMDT = EVENTS->plist[D1.SEQ].elist[D2.SEQ].performdt

FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(EVENTS->plist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)

PLAN D1 WHERE MAXREC(D2, SIZE(EVENTS->plist[D1.SEQ].elist, 5))
JOIN D2

WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, PCFORMAT
*/

end
go
 
 /*
 
 
 
 
 
 
 */
 
 
 
 
 
/*
 
select * from encntr_alias where alias = "1813402262"
 
select * from encounter where encntr_id =  110420356
 
select * from pregnancy_information where person_id = 16555451.00 ;encntr_id =  110420356
 
select * from pregnancy_instance where person_id = 16555451.00 ;encntr_id =  110420356
 
         149159979.00
 
where pregnancy_instance_id in(149159969.00, 149159979.00, 149159975.00, 149159975.00) ; EDD
 
select * from pregnancy_child where person_id =     16555451.00
 
select * from pregnancy_action where pregnancy_id in(149159975.00,  149159969.00,  149159969.00)
 
select order_mnemonic from orders where encntr_id =     110420356.00
 
 
 
--NewBorn
 
select * from encntr_alias where alias = "1813402549"
 
select hna_order_mnemonic, order_mnemonic, valid_dose_dt_tm from orders where encntr_id =  110420393
 
select * from sch_entry where encntr_id =  110420393
 
 
*/

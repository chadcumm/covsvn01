drop program cov_him_surg_antic_doc go
create program cov_him_surg_antic_doc

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


free set t_rec
record t_rec
(
	1 cnt = i4
	1 qual[*]
	 2 clinical_event_id = f8 
	 2 event_id = f8
	 2 encntr_id = f8
	 2 antic_prsnl_id = f8
	 2 person_id = f8
	 2 satisfied_event_id = f8
	 2 satisfied_event = vc
	 2 satisified_event_cd = f8
	 2 prsnl_name_full = vc
)

select into "nl:"
	 ce.clinical_event_id
	,uar_Get_code_display(ce.event_cd)
	,uar_Get_code_display(ce.result_status_cd)
	,ce.event_title_text
	,ce.result_status_cd
	,ce.event_end_dt_tm ";;q"
	,ce.performed_prsnl_id
	,ce.encntr_id
from
	clinical_event ce,prsnl p
plan ce
	where ce.event_cd =  2557737129.00
	and   ce.result_status_cd not in( 29.00,30,31)
	and   ce.result_status_cd =            24.00
	;and   ce.encntr_id = 113479748   
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.event_end_dt_tm >= cnvtdatetime("06-JUN-2019 00:00:00")
join p
	where p.person_id = ce.performed_prsnl_id
detail
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].clinical_Event_id = ce.clinical_event_id
	t_rec->qual[t_Rec->cnt].encntr_id = ce.encntr_id
	t_rec->qual[t_Rec->cnt].person_id = ce.person_id
	t_rec->qual[t_Rec->cnt].antic_prsnl_id = ce.performed_prsnl_id
	t_rec->qual[t_rec->cnt].event_id = ce.event_id
	t_rec->qual[t_rec->cnt].prsnl_name_full = p.name_full_formatted
with nocounter

for (i = 1 to t_rec->cnt)
	select into "nl:"
	
	from
		clinical_event ce
	plan ce
		where ce.person_id = t_rec->qual[i].person_id
		and   ce.encntr_id = t_rec->qual[i].encntr_id
		and   ce.event_id != t_rec->qual[i].event_id
		and   ce.result_status_cd not in( 29.00,30,31,24)
	and   ce.result_status_cd in(25,34,35)
		and   ce.verified_prsnl_id = t_rec->qual[i].antic_prsnl_id
			and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)   
	order by
	ce.event_end_dt_tm, ce.event_id 
	head ce.event_id
		 t_rec->qual[i].satisfied_event = uar_get_code_display(ce.event_cd)
		  t_rec->qual[i].satisified_event_cd = ce.event_cd
		   t_rec->qual[i].satisfied_event_id = ce.event_id
	with nocounter
endfor

SELECT into $OUTDEV
	QUAL_CLINICAL_EVENT_ID = T_REC->qual[D1.SEQ].clinical_event_id
	, QUAL_EVENT_ID = T_REC->qual[D1.SEQ].event_id
	, QUAL_ENCNTR_ID = T_REC->qual[D1.SEQ].encntr_id
	, QUAL_ANTIC_PRSNL_ID = T_REC->qual[D1.SEQ].antic_prsnl_id
	, QUAL_PERSON_ID = T_REC->qual[D1.SEQ].person_id
	, QUAL_SATISFIED_EVENT_ID = T_REC->qual[D1.SEQ].satisfied_event_id
	, QUAL_SATISFIED_EVENT = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].satisfied_event)
	, QUAL_SATISIFIED_EVENT_CD = T_REC->qual[D1.SEQ].satisified_event_cd
	, QUAL_PRSNL_NAME_FULL = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].prsnl_name_full)

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(T_REC->qual, 5))

PLAN D1

WITH NOCOUNTER, SEPARATOR=" ", FORMAT


call echorecord(t_rec)
end 
go
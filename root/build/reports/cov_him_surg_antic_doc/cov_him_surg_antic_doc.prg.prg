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
	 2 satisfied_status = vc
	 2 antic_dt_tm = dq8
	 2 satisified_dt_tm = dq8
	 2 fin = vc
	 2 facility = vc
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
	and   p.person_id > 0.0
	
detail
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].clinical_Event_id = ce.clinical_event_id
	t_rec->qual[t_Rec->cnt].encntr_id = ce.encntr_id
	t_rec->qual[t_Rec->cnt].person_id = ce.person_id
	t_rec->qual[t_Rec->cnt].antic_prsnl_id = ce.performed_prsnl_id
	t_rec->qual[t_rec->cnt].event_id = ce.event_id
	t_rec->qual[t_rec->cnt].prsnl_name_full = p.name_full_formatted
	t_rec->qual[t_rec->cnt].antic_dt_tm = ce.event_end_dt_tm
with nocounter

select into "nl:"
from 
	(dummyt d1 with seq = t_rec->cnt)
	,encntr_alias ea
	,encounter e
plan d1
join ea
	where ea.encntr_id = T_REC->qual[d1.seq].encntr_id
	and   ea.encntr_alias_type_cd = 1077
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
join e
	where ea.encntr_id = e.encntr_id
detail
	t_rec->qual[d1.seq].fin = ea.alias
	t_rec->qual[d1.seq].facility = uar_get_code_display(e.loc_facility_cd)
with nocounter

for (i = 1 to t_rec->cnt)
	select into "nl:"
	
	from
		clinical_event ce,code_value cv
		
	plan ce
		where ce.person_id = t_rec->qual[i].person_id
		and   ce.encntr_id = t_rec->qual[i].encntr_id
		and   ce.event_id != t_rec->qual[i].event_id
		and   ce.result_status_cd not in( 29,30,31,24)
	and   ce.result_status_cd in(25,34,35)
		and   ce.verified_prsnl_id = t_rec->qual[i].antic_prsnl_id
			and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)  
	join cv
		where cv.code_value = ce.event_cd
		and   cv.display in("24 Hour pH Probe",
			"Abdominal Paracentesis",
			"Anesthesia Procedure Note",
			"Angiogram",
			"Balloon Aortic Valvuloplasty",
			"Blood Patch Report",
			"Bronchoscopy",
			"Cardiac Cath Procedure",
			"Cardiac Catheterization diagnostic",
			"Cardiology General Procedures",
			"Cardiology Operative Note",
			"Cardiology Procedure Note",
			"Cardiothoracic Operative Note",
			"Cardiothoracic Procedure",
			"Colonoscopy",
			"Critical Care Procedure Note",
			"Dermatology Procedure Note",
			"Echocardiogram Transesophageal",
			"Electrophysiologic Study EP",
			"Endoscopic Retrograde Cholangiopanc ERCP",
			"Endovascular Procedure",
			"ENT Operative Note",
			"ENT Procedure Note",
			"Esophagogastroduodenoscopy EGD",
			"Feeding Tube Placement",
			"Flexible Sigmoidoscopy",
			"Gastroenterology Operative Note",
			"Gastroenterology Procedure Note",
			"Gynecology Operative Note",
			"Gynecology Procedure Note",
			"Gynecology/Oncology Operative Note",
			"Gynecology/Oncology Procedure Note",
			"Hospitalist Procedure Note",
			"Ileoscopy",
			"Interventional Radiology Procedure Note",
			"Lithotripsy Treatment",
			"Liver Biopsy",
			"Myocardial Biopsy",
			"Neurology Procedure Note",
			"Neurosurgery Operative Note",
			"Neurosurgery Procedure Note",
			"Obstetrics Operative Note",
			"Obstetrics Procedure Note",
			"Oncology Procedure Note",
			"Ophthalmology Operative Note",
			"Ophthalmology Procedure Note",
			"Oral & Maxillofacial Operative Note",
			"Oral & Maxillofacial Procedure Note",
			"Orthopedic Operative Note",
			"Orthopedic Procedure Note",
			"Panendoscopy",
			"PCI (Percutaneous Coronary Intervention)",
			"Pediatric Procedure Note",
			"Physiatrist Procedure Note",
			"Plastic Surgery Operative Note",
			"Plastic Surgery Procedure Note",
			"Podiatry Operative Note",
			"Podiatry Procedure Note",
			"PTCA",
			"Surgery Operative Note",
			"Surgery Procedure Note",
			"Thrombectomy",
			"Tilt Table Test",
			"Urology Operative Note",
			"Urology Procedure Note",
			"Vascular Surgery Operative Note",
			"Vascular Surgery Procedure Note",
			"Swan",
			"Pulmonary Procedure Note",
			"Nephrologist Procedure Note") 
	order by
	ce.event_end_dt_tm, ce.event_id 
	head ce.event_id
		 t_rec->qual[i].satisfied_event = uar_get_code_display(ce.event_cd)
		  t_rec->qual[i].satisified_event_cd = ce.event_cd
		   t_rec->qual[i].satisfied_event_id = ce.event_id
		 t_rec->qual[i].satisified_dt_tm = ce.event_end_dt_tm
		 t_rec->qual[i].satisfied_status = uar_get_code_display(ce.result_status_cd)  
	with nocounter
endfor

SELECT INTO $OUTDEV
	QUAL_FIN = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].fin)
	, QUAL_FACILITY = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].facility)
	, QUAL_CLINICAL_EVENT_ID = T_REC->qual[D1.SEQ].clinical_event_id
	, QUAL_EVENT_ID = T_REC->qual[D1.SEQ].event_id
	, QUAL_PERSON_ID = T_REC->qual[D1.SEQ].person_id
	, QUAL_ENCNTR_ID = T_REC->qual[D1.SEQ].encntr_id
	, QUAL_ANTIC_PRSNL_ID = T_REC->qual[D1.SEQ].antic_prsnl_id
	, QUAL_ANTIC_DT_TM = T_REC->qual[D1.SEQ].antic_dt_tm ";;q"
	, QUAL_SATISIFIED_DT_TM = T_REC->qual[D1.SEQ].satisified_dt_tm ";;q"
	, QUAL_SATISFIED_EVENT_ID = T_REC->qual[D1.SEQ].satisfied_event_id
	, QUAL_SATISFIED_EVENT = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].satisfied_event)
	, QUAL_SATISIFIED_EVENT_CD = T_REC->qual[D1.SEQ].satisified_event_cd
	, QUAL_PRSNL_NAME_FULL = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].prsnl_name_full)
	, QUAL_SATISFIED_STATUS = SUBSTRING(1, 30, T_REC->qual[D1.SEQ].satisfied_status)

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(T_REC->qual, 5))

PLAN D1

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, FORMAT(DATE, ";;q")


call echorecord(t_rec)
end 
go

drop program cov_mak_defic_by_phys_drv go
create program cov_mak_defic_by_phys_drv

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Physician(s)" = 0

with OUTDEV, ORGANIZATIONS, PHYSICIANS



execute ReportRtl
%i cclsource:him_reports_prompts.inc
%i cclsource:him_reports_layout.inc
%i cust_script:cov_him_mak_defic_by_phys_prmpt.inc

declare age_days = f8

declare star_pool_cd = f8 with protect, constant(uar_get_code_by("DISPLAY",263,"STAR Doctor Number"))

declare prsnl_alias_type_cd = f8 with protect, constant(uar_get_code_by("DISPLAY",320,"ORGANIZATION DOCTOR"))

declare dOTG = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))

declare dDOC = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))



select into "nl:"
from 
	 (dummyt d with seq = value(size(data->qual,5)))
    ,prsnl_alias pa
plan d
join pa
	where 	pa.person_id 			= data->qual[d.seq]->physician_person_id
	and		pa.active_ind 			= 1
	and		pa.prsnl_alias_type_cd	= value(uar_get_code_by("DISPLAY",320,"ORGANIZATION DOCTOR"))
	and		pa.alias_pool_cd		= value(uar_get_code_by("DISPLAY",263,"STAR Doctor Number"))
	and		pa.beg_effective_dt_tm	<= cnvtdatetime(curdate,curtime3)
	and		pa.end_effective_dt_tm	>= cnvtdatetime(curdate,curtime3)
detail
	data->qual[d.seq]->physician_star_id = pa.alias
with nocounter

;call echorecord(data)

end go

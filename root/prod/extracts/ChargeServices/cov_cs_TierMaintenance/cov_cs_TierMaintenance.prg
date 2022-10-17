/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/23/2020
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_TierMaintenance.prg
	Object name:		cov_cs_TierMaintenance
	Request #:			6184
 
	Program purpose:	Produces extract file of billing tier matrix data.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_cs_TierMaintenance:DBA go
create program cov_cs_TierMaintenance:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare wrap(data = vc) = vc

 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ambulatoryproftier_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 13035, "AMBULATORYPROFESSIONALTIER"))
 
declare activitytype_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "ACTIVITYTYPECD"))
declare healthplan_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "HEALTHPLAN"))
declare insorganization_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "INSURANCEORGANIZATION"))
declare interfacefile_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "INTERFACEFILE"))
declare organization_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "ORGANIZATION"))
declare priceschedule_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "PRICESCHEDULE"))
declare seperator_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "SEPERATOR"))
declare snomed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 13036, "SNOMED"))

declare file_dt_tm				= vc with constant(format(sysdate, "yyyymmddhhmm;;d"))
declare file_var				= vc with constant(build("tier_extract_", file_dt_tm, ".csv"))
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/ChargeServices/", file_var))
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

record tiercol_data (
	1	col_cnt						= i4
	1	list[*]
		2	code_value				= f8
		2	display					= c40
)

record billorg_data (
	1	org_cnt						= i4
	1	list[*]
		2	organization_id			= f8
		2	org_name				= c100
		
		2	bill_cnt					= i4
		2	bills[*]
			3	bill_org_type_cd		= f8
			3	bill_org_type			= c40
			3	bill_org_type_id		= f8
			3	bill_org_type_value		= c40
)

record tier_data (
	1	tier_cnt					= i4
	1	list[*]
		2	tier_group_cd			= f8
		2	tier_group				= c40
		2	has_orgs				= i2
		
		2	row_cnt						= i4
		2	rows[*]
			3	tier_row_num			= i4
			3	has_org					= i2
			3	organization_id			= f8
			
			3	col_cnt						= i4
			3	cols[*]
				4	tier_col_num			= i4
				
				4	tier_cell_id			= f8
				4	tier_cell_type_cd		= f8
				4	tier_cell_type			= c40
				4	tier_cell_entity_name	= c32
				4	tier_cell_value_id		= f8
				4	tier_cell_value			= c200
)


record final_data (
	1	final_cnt					= i4
	1	list[*]
		2	final_data				= c1024
		2	final_seq				= i4
)



/**************************************************************/
; select tier column data
select into "NL:"
from 
	CODE_VALUE cv 
	
where
	cv.code_set = 13036 
	and cv.code_value not in (seperator_var, snomed_var)
	and cv.end_effective_dt_tm > sysdate
	and cv.active_ind = 1
	
order by
	cv.collation_seq
 
 
; populate tiercol_data record structure
head report
	cnt = 0
	
detail
	cnt = cnt + 1
	
	call alterlist(tiercol_data->list, cnt)
 
	tiercol_data->col_cnt					= cnt
	tiercol_data->list[cnt].code_value		= cv.code_value
	tiercol_data->list[cnt].display			= cv.display
	
WITH nocounter, time = 60


/**************************************************************/
; select billing organization data
select into "NL:"
from
	ORGANIZATION org
	
	, (inner join BILL_ORG_PAYOR bop on bop.organization_id = org.organization_id
		and bop.bill_org_type_id not in (ambulatoryproftier_var)
		and bop.end_effective_dt_tm > sysdate
		and bop.active_ind = 1)
 
where
	org.end_effective_dt_tm > sysdate
	and org.active_ind = 1
	
;	and org.organization_id = 3192098.00 ; TESTING
	
order by
	org.org_name
	, org.organization_id
	, bop.bill_org_type_cd
 
 
; populate billorg_data record structure
head report
	cnt = 0
	
head org.organization_id
	bcnt = 0
	
	cnt = cnt + 1
	
	call alterlist(billorg_data->list, cnt)
 
	billorg_data->org_cnt						= cnt
	billorg_data->list[cnt].organization_id		= org.organization_id
	billorg_data->list[cnt].org_name			= org.org_name
	
detail
	bcnt = bcnt + 1
	
	call alterlist(billorg_data->list[cnt].bills, bcnt)
 
 	billorg_data->list[cnt].bill_cnt							= bcnt
	billorg_data->list[cnt].bills[bcnt].bill_org_type_cd		= bop.bill_org_type_cd
	billorg_data->list[cnt].bills[bcnt].bill_org_type			= uar_get_code_display(bop.bill_org_type_cd)
	billorg_data->list[cnt].bills[bcnt].bill_org_type_id		= bop.bill_org_type_id
	billorg_data->list[cnt].bills[bcnt].bill_org_type_value		= uar_get_code_display(bop.bill_org_type_id)
	
WITH nocounter, time = 60


/**************************************************************/
; select tier data
select into "NL:"
	tier_group = uar_get_code_display(tm.tier_group_cd)
	
from
	TIER_MATRIX tm 
	
	, (left join TIER_MATRIX tm_org on tm_org.tier_row_num = tm.tier_row_num
		and tm_org.tier_group_cd = tm.tier_group_cd
		and tm_org.tier_cell_type_cd in (organization_var, insorganization_var)
		and tm_org.end_effective_dt_tm > sysdate
		and tm_org.active_ind = 1)
		
	, (left join ORGANIZATION org on org.organization_id = tm_org.tier_cell_value_id)
	
	, (left join TIER_MATRIX tm_ps on tm_ps.tier_row_num = tm.tier_row_num
		and tm_ps.tier_group_cd = tm.tier_group_cd
		and tm_ps.tier_cell_type_cd = priceschedule_var
		and tm_ps.end_effective_dt_tm > sysdate
		and tm_ps.active_ind = 1)
		
	, (left join PRICE_SCHED ps on ps.price_sched_id = tm_ps.tier_cell_value_id)
	
	, (left join TIER_MATRIX tm_hp on tm_hp.tier_row_num = tm.tier_row_num
		and tm_hp.tier_group_cd = tm.tier_group_cd
		and tm_hp.tier_cell_type_cd = healthplan_var
		and tm_hp.end_effective_dt_tm > sysdate
		and tm_hp.active_ind = 1)
		
	, (left join HEALTH_PLAN hp on hp.health_plan_id = tm_hp.tier_cell_value_id)
	
	, (left join TIER_MATRIX tm_ifile on tm_ifile.tier_row_num = tm.tier_row_num
		and tm_ifile.tier_group_cd = tm.tier_group_cd
		and tm_ifile.tier_cell_type_cd = interfacefile_var
		and tm_ifile.end_effective_dt_tm > sysdate
		and tm_ifile.active_ind = 1)
		
	, (left join INTERFACE_FILE ifile on ifile.interface_file_id = tm_ifile.tier_cell_value_id)
 
where
	1 = 1
	and tm.end_effective_dt_tm > sysdate
	and tm.active_ind = 1
	
order by
	tier_group
	, tm.tier_group_cd
	, tm.tier_row_num
	, tm.tier_col_num
 
 
; populate tier_data record structure
head report
	cnt = 0
 
head tm.tier_group_cd
	rcnt = 0
	
	cnt = cnt + 1
 
	call alterlist(tier_data->list, cnt)
 
	tier_data->tier_cnt						= cnt
	tier_data->list[cnt].tier_group_cd		= tm.tier_group_cd
	tier_data->list[cnt].tier_group			= uar_get_code_display(tm.tier_group_cd)
	
head tm.tier_row_num
	ccnt = 0
	
	rcnt = rcnt + 1
 
	call alterlist(tier_data->list[cnt].rows, rcnt)

	tier_data->list[cnt].row_cnt						= rcnt
	tier_data->list[cnt].rows[rcnt].tier_row_num		= tm.tier_row_num
	
head tm.tier_col_num	
	ccnt = ccnt + 1
 
	call alterlist(tier_data->list[cnt].rows[rcnt].cols, ccnt)
	
	tier_data->list[cnt].rows[rcnt].col_cnt								= ccnt
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_col_num				= tm.tier_col_num
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_id				= tm.tier_cell_id
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_type_cd		= tm.tier_cell_type_cd
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_type			= uar_get_code_display(tm.tier_cell_type_cd)
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_entity_name	= tm.tier_cell_entity_name
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_value_id		= tm.tier_cell_value_id
	
	tier_data->list[cnt].rows[rcnt].cols[ccnt].tier_cell_value			= evaluate2(	
		if (tm.tier_cell_type_cd in (organization_var, insorganization_var))
			org.org_name
			
		elseif (tm.tier_cell_type_cd = priceschedule_var)
			ps.price_sched_desc
			
		elseif (tm.tier_cell_type_cd = healthplan_var)
			hp.plan_name
			
		elseif (tm.tier_cell_type_cd = interfacefile_var)
			ifile.description
			
		else
			uar_get_code_display(tm.tier_cell_value_id)
			
		endif
		)
	
	if (tm.tier_cell_type_cd = organization_var)
		tier_data->list[cnt].has_orgs = 1
		tier_data->list[cnt].rows[rcnt].has_org = 1
		tier_data->list[cnt].rows[rcnt].organization_id = org.organization_id
	endif
	
WITH nocounter, time = 60
	
 
/**************************************************************/
; select final data
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set modify filestream
;endif
 
;select if (validate(request->batch_selection) = 1 or $output_file = 1)
;	with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 1024, maxrow = 10000
;else
;	with separator = " ", format, maxcol = 1024
;endif
		
;into value(output_var)

select into "NL:"
	org_name = billorg_data->list[d1.seq].org_name

from
	(dummyt d1 with seq = value(billorg_data->org_cnt))
	
	, (dummyt d2 with seq = 2)

plan d1
where 
	maxrec(d2, billorg_data->list[d1.seq].bill_cnt)

join d2

order by
	billorg_data->list[d1.seq].org_name
	, billorg_data->list[d1.seq].bills[d2.seq].bill_org_type


head report
	strout = fillstring(1000, " ")
	
	; header row
	strout = build(strout, wrap("Organization"), ",")
	strout = build(strout, wrap("Tier Type"), ",")
	strout = build(strout, wrap("Tier"), ",")
	
	for (c = 1 to tiercol_data->col_cnt)
		strout = build(strout, wrap(tiercol_data->list[c].display), ",")
	endfor
	
	strout = replace(strout, ",", "", 2)
	
;	col 0 strout
;	
;	row + 1

	call alterlist(final_data->list, 1)
	
	final_data->final_cnt = 1
	final_data->list[1].final_data = trim(strout, 3)
	final_data->list[1].final_seq = 1
	
detail
	strout = fillstring(1000, " ")
	org_found = 0
	
	for (i = 1 to tier_data->tier_cnt)
		; find tier
		if (tier_data->list[i].tier_group_cd = billorg_data->list[d1.seq].bills[d2.seq].bill_org_type_id)
			; determine if tier has orgs
			if (tier_data->list[i].has_orgs = 1)
				for (j = 1 to tier_data->list[i].row_cnt)
					; determine if tier row has org
					if (tier_data->list[i].rows[j].has_org = 1)
						; find org data
						if (tier_data->list[i].rows[j].organization_id = billorg_data->list[d1.seq].organization_id)
							strout = fillstring(1000, " ")
							org_found = 1
	
							strout = build(strout, wrap(billorg_data->list[d1.seq].org_name), ",")
							strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type), ",")
							strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type_value), ",")
	
							; find column data
							for (c = 1 to tiercol_data->col_cnt)
								col_found = 0
								
								for (k = 1 to tier_data->list[i].rows[j].col_cnt)
									if (tiercol_data->list[c].code_value = tier_data->list[i].rows[j].cols[k].tier_cell_type_cd)
										col_found = 1

										strout = build(strout, wrap(tier_data->list[i].rows[j].cols[k].tier_cell_value), ",")
									endif
								endfor
								
								if (col_found = 0)
									strout = build(strout, ",")
								endif
							endfor
	
							strout = replace(strout, ",", "", 2)
							
;							col 0 strout
;							
;							row + 1

							call alterlist(final_data->list, final_data->final_cnt + 1)
							
							final_data->final_cnt = final_data->final_cnt + 1
							final_data->list[final_data->final_cnt].final_data = trim(strout, 3)
							final_data->list[final_data->final_cnt].final_seq = 2
						endif
					else
						; find non-mapped org data for activity type
						row_activity_type = fillstring(200, " ")
						global_org = 0
						global_activity_type = fillstring(200, " ")
						org_activity_found = 0
						
						; find current row activity type data
						for (k = 1 to tier_data->list[i].rows[j].col_cnt)
							if (tier_data->list[i].rows[j].cols[k].tier_cell_type_cd = activitytype_var)
								row_activity_type = trim(tier_data->list[i].rows[j].cols[k].tier_cell_value, 3)
							endif
						endfor
						
						if (size(row_activity_type) > 0)
							; determine if org has activity type anywhere in the tier
							for (jj = 1 to j)
								; find data for non-current row
								if (jj != j)									
									global_org = tier_data->list[i].rows[jj].organization_id
										
									; find global activity type data
									for (k = 1 to tier_data->list[i].rows[jj].col_cnt)
										if (tier_data->list[i].rows[jj].cols[k].tier_cell_type_cd = activitytype_var)
											global_activity_type = trim(tier_data->list[i].rows[jj].cols[k].tier_cell_value, 3)
										endif									
									endfor
									
									; determine if org has activity type
									if (billorg_data->list[d1.seq].organization_id = global_org)
										if (row_activity_type = global_activity_type) 
											org_activity_found = 1
										endif								
									endif
								endif
							endfor
						
							; org activity type not found
							if (org_activity_found = 0)
								strout = fillstring(1000, " ")
		
								strout = build(strout, wrap(billorg_data->list[d1.seq].org_name), ",")
								strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type), ",")
								strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type_value), ",")
		
								; find column data
								for (c = 1 to tiercol_data->col_cnt)
									col_found = 0
									
									for (k = 1 to tier_data->list[i].rows[j].col_cnt)
										if (tiercol_data->list[c].code_value = tier_data->list[i].rows[j].cols[k].tier_cell_type_cd)
											col_found = 1
	
											strout = build(strout, wrap(tier_data->list[i].rows[j].cols[k].tier_cell_value), ",")
										endif
									endfor
									
									if (col_found = 0)
										strout = build(strout, ",")
									endif
								endfor
		
								strout = replace(strout, ",", "", 2)
								
;								col 0 strout
;								
;								row + 1

								call alterlist(final_data->list, final_data->final_cnt + 1)
								
								final_data->final_cnt = final_data->final_cnt + 1
								final_data->list[final_data->final_cnt].final_data = trim(strout, 3)
								final_data->list[final_data->final_cnt].final_seq = 2
							endif
						endif
					endif
				endfor
				
				; org not found
				if (org_found = 0)
					for (j = 1 to tier_data->list[i].row_cnt)
						; skip tier rows with org
						if (tier_data->list[i].rows[j].has_org = 0)
							strout = fillstring(1000, " ")
	
							strout = build(strout, wrap(billorg_data->list[d1.seq].org_name), ",")
							strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type), ",")
							strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type_value), ",")
	
							; find column data
							for (c = 1 to tiercol_data->col_cnt)
								col_found = 0
								
								for (k = 1 to tier_data->list[i].rows[j].col_cnt)
									if (tiercol_data->list[c].code_value = tier_data->list[i].rows[j].cols[k].tier_cell_type_cd)
										col_found = 1

										strout = build(strout, wrap(tier_data->list[i].rows[j].cols[k].tier_cell_value), ",")
									endif
								endfor
								
								if (col_found = 0)
									strout = build(strout, ",")
								endif
							endfor
	
							strout = replace(strout, ",", "", 2)
							
;							col 0 strout
;							
;							row + 1

							call alterlist(final_data->list, final_data->final_cnt + 1)
							
							final_data->final_cnt = final_data->final_cnt + 1
							final_data->list[final_data->final_cnt].final_data = trim(strout, 3)
							final_data->list[final_data->final_cnt].final_seq = 2
						endif
					endfor
				endif
			else
				for (j = 1 to tier_data->list[i].row_cnt)
					strout = fillstring(1000, " ")

					strout = build(strout, wrap(billorg_data->list[d1.seq].org_name), ",")
					strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type), ",")
					strout = build(strout, wrap(billorg_data->list[d1.seq].bills[d2.seq].bill_org_type_value), ",")
	
					; find column data
					for (c = 1 to tiercol_data->col_cnt)
						col_found = 0
								
						for (k = 1 to tier_data->list[i].rows[j].col_cnt)
							if (tiercol_data->list[c].code_value = tier_data->list[i].rows[j].cols[k].tier_cell_type_cd)
								col_found = 1

								strout = build(strout, wrap(tier_data->list[i].rows[j].cols[k].tier_cell_value), ",")
							endif
						endfor
								
						if (col_found = 0)
							strout = build(strout, ",")
						endif
					endfor
	
					strout = replace(strout, ",", "", 2)
					
;					col 0 strout
;					
;					row + 1

					call alterlist(final_data->list, final_data->final_cnt + 1)
					
					final_data->final_cnt = final_data->final_cnt + 1
					final_data->list[final_data->final_cnt].final_data = trim(strout, 3)
					final_data->list[final_data->final_cnt].final_seq = 2
				endfor
			endif
		endif
	endfor

with nocounter
	
 
/**************************************************************/
; select final data for output
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, noheading, nullreport, format = stream, format = variable, landscape, compress
else
	with nocounter, separator = " ", format, maxcol = 1024
endif
		
distinct into value(output_var)
	final_data = trim(final_data->list[d1.seq].final_data, 3)

from
	(dummyt d1 with seq = value(final_data->final_cnt))

plan d1

order by
	final_data->list[d1.seq].final_seq
	, final_data

with nocounter


/**************************************************************/
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 

;call echorecord(tiercol_data)
call echorecord(billorg_data)
;call echorecord(tier_data)
;call echorecord(final_data)

;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc

 
#exitscript
 
end
go
 

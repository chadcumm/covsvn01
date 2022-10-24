
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'2022
	Solution:			Perioperative
	Source file name:	      cov_mp_get_bloodbank_product.prg
	Object name:		cov_mp_get_bloodbank_product
	Request#:			13313
	Program purpose:	      
	Executing from:		MPage /Powerchart / Perioperative WF
 	Special Notes:          
 
***************************************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***************************************************************************************************************
 
 CR#	  Mod Date	 Developer			Comment
----------------------------------------------------------------------------------------------------------------
13313   10-19-2022   Geetha       Initial Release

----------------------------------------------------------------------------------------------------------------*/


drop program cov_mp_get_bloodbank_product:dba go
create program cov_mp_get_bloodbank_product:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Patient ID:" = 0.00
	, "Encounter ID:" = 0.00
	, "Personnel ID:" = 0.00
	, "HTML File Name:" = ""
	, "HTML Backend Location:" = ""
	, "Provider Position Code:" = 0.00
	, "Patient Provider Relationship Code:" = 0.00
	, "Debug Indicator:" = 0 

with OUTDEV, PATIENTID, ENCOUNTERID, PERSONNELID, HTMLFILENAME, BACKENDLOC, 
	POSITIONCODE, PPRCODE, DEBUGIND
 
;"MINE","$pat_personid$","$vis_encntrid$","$usr_personid$",
;"eform_base.html", "ccluserdir:", "$USR_PositionCd$","$PAT_PPRCode$",0.0,0.0,"1"


;cov_mp_get_bloodbank_product "MINE",20812082.00,0.00,0.00,"","",0.00,0.00,0 go


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record criterion
record criterion
(
	1 person_id = f8
	1 encntrs[*]
		2 encntr_id = f8
	1 prsnl_id = f8
	1 executable = vc
	1 html_filename = vc
	1 backend_location = vc
	1 position_cd = f8
	1 ppr_cd = f8
	1 debug_ind = i2
	1 help_file_local_ind = i2
	1 patient_info
		2 sex_cd = f8
		2 dob = vc
)


free record prodinfo
record prodinfo
(
	1 status = c1
	1 prod_cnt = i4
	1 list[*]
		2 encntrid	= f8
		2 personid = f8
		2 antibody = vc
		2 antigen = vc
		2 aborh = vc
		2 transfusion_req = vc
		2 prd_a_cnt = i4
		2 prd_c_cnt = i4
		2 prd_d_cnt = i4
		2 prd_t_cnt = i4
		2 assigned[*]
			3 assign_cnt = i4
			3 a_product_event_label = vc
			3 a_product_status_dt = vc
			3 a_product_number = vc
			3 a_product_name = vc
			3 a_product_abo_rh = vc
		2 crossed[*]
			3 cross_cnt = i4
			3 c_product_event_label = vc
			3 c_product_status = vc
			3 c_product_status_dt = vc
			3 c_product_number = vc
			3 c_product_name = vc
			3 c_product_abo_rh = vc
		2 dispensed[*]
			3 dispen_cnt = i4
			3 d_product_event_label = vc
			3 d_product_status_dt = vc
			3 d_product_number = vc
			3 d_product_name = vc
			3 d_product_abo_rh = vc
		2 transfused[*]	
			3 trans_cnt = i4
			3 t_product_event_label = vc
			3 t_product_status_dt = vc
			3 t_product_number = vc
			3 t_product_name = vc
			3 t_product_abo_rh = vc
) 


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

set criterion->person_id = $PATIENTID
set stat = alterlist(criterion->encntrs, 1)
set criterion->encntrs[1].encntr_id = $ENCOUNTERID
set criterion->prsnl_id = $PERSONNELID
set criterion->backend_location = $BACKENDLOC
set criterion->html_filename = $HTMLFILENAME
set criterion->position_cd = $POSITIONCODE
set criterion->ppr_cd = $PPRCODE
set criterion->debug_ind = $DEBUGIND 

declare assign_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, "Assigned")),protect 
declare cross_var  = f8 with constant(uar_get_code_by("DISPLAY", 1610, "Crossmatched")),protect
declare dispen_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, "Dispensed")),protect
declare trans_var  = f8 with constant(uar_get_code_by("DISPLAY", 1610, "Transfused")),protect
declare antibody_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Antibody ID")),protect	
declare antigen_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Antigen Type")),protect
declare aborh_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "ABORh")),protect	


declare replyString = vc with noconstant(" ")
declare i = i2 with noconstant(0)
declare j = i2 with noconstant(0)
declare cross_rec_cnt_var = i4 with noconstant(0)

set prodinfo->status = "F"
set prodinfo->prod_cnt = 0
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
call GetEncounterInfo(null)
if (prodinfo->status = "S")
	call GetBloodBankProducts(null)
	call GetBloodBankOverview(null)
	call GetTransfusionReq(null)
endif

if (prodinfo->prod_cnt > 0)
	call FormatResults(null)
else
	set replyString = build(replyString,"<table><tr> No Results Found </tr></table>" )	
endif	

;set _MEMORY_REPLY_STRING = cnvtrectojson(prodinfo)
set _MEMORY_REPLY_STRING = replyString
call echo(_Memory_Reply_String)


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

subroutine GetEncounterInfo(null)
	select into "nl:"
	
	from encounter e
	plan e where e.person_id = criterion->person_id 
	order by e.person_id
	
	head report
		cnt = 0
	head e.person_id
		cnt += 1
		stat = alterlist(prodinfo->list,cnt)
		prodinfo->list[cnt].personid = e.person_id
	foot report
		prodinfo->status = "S"
	with nocounter
	
	if (curqual = 0)
		set prodinfo->status = "Z"
	endif
end ;sub


subroutine GetBloodBankProducts(null)

	select into 'nl:'
		pe.person_id, pe.encntr_id, pe.event_dt_tm, prod_label = trim(uar_get_code_display(pe.event_type_cd))
		,pe.product_id, pe.product_event_id
	
	from (dummyt d1 with seq = size(prodinfo->list,5))
		, product_event pe
		, product pr
		, blood_product bp
	
	plan d1

	join pe where pe.person_id = prodinfo->list[d1.seq].personid 
		and pe.event_type_cd in(assign_var, cross_var, dispen_var, trans_var)
		and pe.active_ind = 1
	
	join pr where pr.product_id = pe.product_id
		and pr.active_ind = 1
	
	join bp where bp.product_id = outerjoin(pr.product_id)	

	order by pe.event_type_cd, pe.product_event_id
	
	head pe.event_type_cd
		acnt = 0, ccnt = 0, dcnt = 0, tcnt = 0
		prodinfo->list[d1.seq].encntrid = pe.encntr_id
	head pe.product_event_id
		prodinfo->prod_cnt += 1
		case(pe.event_type_cd)	
			of assign_var:
				acnt += 1
				stat = alterlist(prodinfo->list[d1.seq].assigned, acnt)
				prodinfo->list[d1.seq].prd_a_cnt = acnt
				prodinfo->list[d1.seq].assigned[acnt].assign_cnt = acnt
				prodinfo->list[d1.seq].assigned[acnt].a_product_event_label = prod_label
				prodinfo->list[d1.seq].assigned[acnt].a_product_status_dt = format(pe.event_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
				prodinfo->list[d1.seq].assigned[acnt].a_product_number = pr.product_nbr
				prodinfo->list[d1.seq].assigned[acnt].a_product_name = 
					build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
				prodinfo->list[d1.seq].assigned[acnt].a_product_abo_rh = 
					build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
			of cross_var:
				ccnt += 1
				stat = alterlist(prodinfo->list[d1.seq].crossed, ccnt)
				prodinfo->list[d1.seq].prd_c_cnt = ccnt
				cross_rec_cnt_var = ccnt
				prodinfo->list[d1.seq].crossed[ccnt].cross_cnt = ccnt
				prodinfo->list[d1.seq].crossed[ccnt].c_product_event_label = prod_label
				prodinfo->list[d1.seq].crossed[ccnt].c_product_status_dt = format(pe.event_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
				prodinfo->list[d1.seq].crossed[ccnt].c_product_number = pr.product_nbr
				prodinfo->list[d1.seq].crossed[ccnt].c_product_name = 
					build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
				prodinfo->list[d1.seq].crossed[ccnt].c_product_abo_rh = 
					build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
			of dispen_var:
				dcnt += 1
				stat = alterlist(prodinfo->list[d1.seq].dispensed, dcnt)
				prodinfo->list[d1.seq].prd_d_cnt = dcnt
				prodinfo->list[d1.seq].dispensed[dcnt].dispen_cnt = dcnt
				prodinfo->list[d1.seq].dispensed[dcnt].d_product_event_label = prod_label
				prodinfo->list[d1.seq].dispensed[dcnt].d_product_status_dt = format(pe.event_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
				prodinfo->list[d1.seq].dispensed[dcnt].d_product_number = pr.product_nbr
				prodinfo->list[d1.seq].dispensed[dcnt].d_product_name = 
					build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
				prodinfo->list[d1.seq].dispensed[dcnt].d_product_abo_rh = 
					build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
			of trans_var:
				tcnt += 1
				stat = alterlist(prodinfo->list[d1.seq].transfused, tcnt)
				prodinfo->list[d1.seq].prd_t_cnt = tcnt
				prodinfo->list[d1.seq].transfused[tcnt].trans_cnt = tcnt
				prodinfo->list[d1.seq].transfused[tcnt].t_product_event_label = prod_label
				prodinfo->list[d1.seq].transfused[tcnt].t_product_status_dt = format(pe.event_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
				prodinfo->list[d1.seq].transfused[tcnt].t_product_number = pr.product_nbr
				prodinfo->list[d1.seq].transfused[tcnt].t_product_name = 
					build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
				prodinfo->list[d1.seq].transfused[tcnt].t_product_abo_rh = 
					build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
					
		endcase
	with nocounter
	
	;Flag dispensed products
	for (i = 1 to size(prodinfo->list,5))
		if (prodinfo->list[i].prd_c_cnt > 0)
			if (prodinfo->list[i].prd_d_cnt > 0)
				for (j = 1 to prodinfo->list[i].prd_c_cnt)
					for (k = 1 to prodinfo->list[i].prd_d_cnt)
						if(prodinfo->list[i].crossed[j].c_product_number = prodinfo->list[i].dispensed[k].d_product_number)
							set prodinfo->list[i].crossed[j].c_product_status = 'Dispensed'	
							;set cross_rec_cnt_var = prodinfo->list[i].prd_c_cnt - 1
							set cross_rec_cnt_var -= 1
						endif	
					endfor
				
				endfor
			endif
		endif	
	endfor
	
end ;sub			


subroutine GetBloodBankOverview(null)

	select into 'nl:'
	from (dummyt d1 with seq = size(prodinfo->list,5))
		, clinical_event ce
	
	plan d1
	
	join ce where ce.encntr_id = prodinfo->list[d1.seq].encntrid
		and ce.event_cd in(antibody_var, antigen_var ,aborh_var)
		and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
						where ce1.encntr_id = ce.encntr_id
						and ce1.event_cd = ce.event_cd
						and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
						and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
						group by ce1.encntr_id, ce1.event_cd)
						
	order by ce.encntr_id, ce.event_cd
	
	head ce.event_cd
		case(ce.event_cd)
			of antibody_var:
				prodinfo->list[d1.seq].antibody = ce.result_val
			of antigen_var:
				prodinfo->list[d1.seq].antigen = ce.result_val
			of aborh_var:
				prodinfo->list[d1.seq].aborh = ce.result_val
		endcase		
	with nocounter
						
end ;sub


subroutine GetTransfusionReq(null)
	
	select into 'nl:'
	from (dummyt d1 with seq = size(prodinfo->list,5))
		, person_trans_req ptr

	plan d1
	
	join ptr where ptr.encntr_id = prodinfo->list[d1.seq].encntrid
		and ptr.active_ind = 1
		
	order by ptr.encntr_id
	
	head ptr.encntr_id
		prodinfo->list[d1.seq].transfusion_req = trim(uar_get_code_display(ptr.requirement_cd))	
	with nocounter
	
end ;sub


subroutine FormatResults(null)

set replyString = build("<table>")

for (i = 1 to size(prodinfo->list,5))
	if (prodinfo->list[i].personid > 0.0)
		;Overview
		set replyString = build(replyString,
			"<tr style = 'background-color:rgba(255,255,0,0.3);'>",
				"<td><b>ABO/Rh Type</b></td>",
				"<td><b>Antibodies</b></td>",
				"<td><b>Transfusion Requirements</b></td>",
				"<td><b>Antigens</b></td>",
			"</tr>",
			"<tr><td>&nbsp</td></tr>")
		set replyString = build(replyString,	
			"<tr>",
				"<td>",trim(prodinfo->list[i].aborh),"</td>",
				"<td>",trim(prodinfo->list[i].antibody),"</td>",
				"<td>",trim(prodinfo->list[i].transfusion_req),"</td>",
				"<td>",trim(prodinfo->list[i].antigen),"</td>",
			"</tr>",
			"<tr><td>&nbsp</td></tr>")
				
		;Products
		set replyString = build(replyString,
			"<tr style = 'background-color:rgba(255,255,0,0.3);'>",
				"<td><b>Product Number</b></td>",
				"<td><b>Product Name</b></td>",
				;"<td><b>Product ABO/Rh</b></td>",
				"<td><b>Status DT/TM</b></td>",
				"<td>&nbsp</td>",
			"</tr>",
			"<tr><td>&nbsp</td></tr>")
		
		if (prodinfo->list[i].prd_a_cnt > 0)
			set replyString = build(replyString,
				"<tr style='color:Tomato;'>",
					"<td><b>Assigned (",prodinfo->list[i].prd_a_cnt,")</b></td>",
				"</tr>")
			for (j = 1 to prodinfo->list[i].prd_a_cnt)
				set replyString = build(replyString,
					"<tr>",
						"<td>",trim(prodinfo->list[i].assigned[j].a_product_number),"</td>",
						"<td>",trim(prodinfo->list[i].assigned[j].a_product_name),"</td>",
						;"<td>",trim(prodinfo->list[i].assigned[j].a_product_abo_rh),"</td>",
						"<td>",trim(prodinfo->list[i].assigned[j].a_product_status_dt),"</td>",
				 	"</tr>")
			endfor			
		endif
		
		if (prodinfo->list[i].prd_c_cnt > 0)
			set replyString = build(replyString,
				"<tr style='color:Tomato;'>",
					"<td><b>Crossmatched (",cross_rec_cnt_var,")</b></td>",
					;"<td><b>Crossmatched (",prodinfo->list[i].prd_c_cnt,")</b></td>",
				"</tr>")
			for (j = 1 to prodinfo->list[i].prd_c_cnt)
				if(prodinfo->list[i].crossed[j].c_product_status = ' ')
				set replyString = build(replyString,
					"<tr>",
						"<td>",trim(prodinfo->list[i].crossed[j].c_product_number),"</td>",
						"<td>",trim(prodinfo->list[i].crossed[j].c_product_name),"</td>",
						;"<td>",trim(prodinfo->list[i].crossed[j].c_product_abo_rh),"</td>",
						"<td>",trim(prodinfo->list[i].crossed[j].c_product_status_dt),"</td>",
				 	"</tr>")
				 endif	
			endfor			
		endif
		
		if (prodinfo->list[i].prd_d_cnt > 0)
			set replyString = build(replyString,
				"<tr style='color:Tomato;'>",
					"<td><b>Dispensed (",prodinfo->list[i].prd_d_cnt,")</b></td>",
				"</tr>")
			for (j = 1 to prodinfo->list[i].prd_d_cnt)
				set replyString = build(replyString,
					"<tr>",
						"<td>",trim(prodinfo->list[i].dispensed[j].d_product_number),"</td>",
						"<td>",trim(prodinfo->list[i].dispensed[j].d_product_name),"</td>",
						;"<td>",trim(prodinfo->list[i].dispensed[j].d_product_abo_rh),"</td>",
						"<td>",trim(prodinfo->list[i].dispensed[j].d_product_status_dt),"</td>",
				 	"</tr>")
			endfor			
		endif
		
		if (prodinfo->list[i].prd_t_cnt > 0)
			set replyString = build(replyString,
				"<tr style='color:Tomato;'>",
					"<td><b>Transfused (",prodinfo->list[i].prd_t_cnt,")</b></td>",
				"</tr>")
			for (j = 1 to prodinfo->list[i].prd_t_cnt)
				set replyString = build(replyString,
					"<tr>",
						"<td>",trim(prodinfo->list[i].transfused[j].t_product_number),"</td>",
						"<td>",trim(prodinfo->list[i].transfused[j].t_product_name),"</td>",
						;"<td>",trim(prodinfo->list[i].transfused[j].t_product_abo_rh),"</td>",
						"<td>",trim(prodinfo->list[i].transfused[j].t_product_status_dt),"</td>",
				 	"</tr>")
			endfor			
		endif

		
	endif	
endfor	
		
		

set replyString = build(replyString,"</table>")
call echo(build2("replyString=",replyString))
end
 
#exit_script

call echorecord(prodinfo)

end
go








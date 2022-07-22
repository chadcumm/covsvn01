drop program cov_sn_sched_ops go
create program cov_sn_sched_ops
 
prompt
	"Facility" = 0
 
with FAC_SEL
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
 
%i ccluserdir:cov_custom_ccl_common.inc
/*
No.	Name	Facility	CAO	Printer 	Number
2	Geri Pritchett		Peninsula		Liz Clary		PRN00306
4	Mary Patterson		Methodist		Jeremy Biggs	PRN04816	mmc_1adm_off_b_pln
5	Karen McClain		CMG Corporate	Monty Scott		PRN05519
6	Rhonda Roose		Regional		Keith Altshuler	PRN06522	fsr_ladm_cast_a_pln
7	Marti Nickel		Parkwest		Neil Heatherly	PRN08289	pw_1adm_dast_a_pln
8	Abigail Robillard	LeConte	Gaye 	Jolly			PRN12383
9	Lisa Mackiewicz		Morristown		Gordon Lintz	PRN12831	mhhs_1adm_rec_mfp
10	Jennifer Rose		Loudoun			Jeffrey Feike	PRN12900
11	Beth Cain			Roane			Jason Pilant	PRN13364
; CYCLE_PRINTER_PRN13113 cpt_b_revcycl_a_mfp
 
 
SELECT DISTINCT
    ORG.ORGANIZATION_ID
    , ORG.ORG_NAME
	, uar_get_code_Display(sr.service_resource_cd)
	,sr.service_resource_cd
FROM
   ; PRSNL   PR
   ; , PRSNL_ORG_RELTN   PO
     ORGANIZATION   ORG
    , LOCATION   L
    , SERVICE_RESOURCE   SR
 
plan ORG WHERE ORG.ORGANIZATION_ID > 0
    AND ORG.ORG_NAME_KEY != "COVENANT*"
JOIN l WHERE org.organization_id = l.organization_id
    AND L.ACTIVE_IND = 1
    and L.LOCATION_TYPE_CD+0 = 817.00    ;SURGERY
JOIN SR WHERE SR.LOCATION_CD=L.LOCATION_CD
    and SR.ACTIVE_IND=1
 
ORDER BY
    ORG.ORG_NAME
*/
 
 
if (($FAC_SEL = 0) or ($FAC_SEL > 11))
	go to exit_script
elseif (($FAC_SEL = 4))
	 ;removed per IN833959
     ;3144499.00	Methodist Medical Center	MMC Main OR	      			2554023941.00
     ;3144499.00	Methodist Medical Center	MMC PreAdmission Testing	2554023957.00
     ;3144499.00	Methodist Medical Center	MMC Endoscopy	      		2554023973.00
     ;3144499.00	Methodist Medical Center	MMC Non-Surgical	      	2554023989.00
     ;3144499.00	Methodist Medical Center	MMC Labor and Delivery	    2554024337.00
    /*
	execute cov1_sn_sched_ops "mmc_1adm_off_b_pln" ;"cpt_b_revcycl_a_mfp"
							,3144499.00
							,VALUE(2554023941.00, 2554023957.00, 2554023973.00,2554023989.00,2554024337.00)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
	*/
	go to exit_script
elseif (($FAC_SEL = 6))
	  ;removed per IN828677 
      ;675844.00	Fort Sanders Regional Medical Center	FSR Main OR	        				25442723.00
      ;675844.00	Fort Sanders Regional Medical Center	FSR PreAdmission Testing	        25442735.00
      ;675844.00	Fort Sanders Regional Medical Center	FSR Endoscopy	        			32216055.00
      ;675844.00	Fort Sanders Regional Medical Center	FSR Labor and Delivery	        	32216067.00
      ;675844.00	Fort Sanders Regional Medical Center	FSR Non-Surgical	      			2552923987.00
      ;675844.00	Fort Sanders Regional Medical Center	FSR Non Endo Procedure	      		2561496783.00
 
 
	/*execute cov1_sn_sched_ops 	"fsr_ladm_cast_a_pln"
							,675844.00
							,VALUE(25442723.00, 25442735.00, 32216055.00,32216067.00,2552923987.00,2561496783.00)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
	*/
	go to exit_script
elseif (($FAC_SEL = 7))
     ;3144503.00	Parkwest Medical Center	PWMC PreAdmission Testing	      	2557228423.00
     ;3144503.00	Parkwest Medical Center	PWMC Main OR	      				2557228439.00
     ;3144503.00	Parkwest Medical Center	PWMC Endoscopy	     	 			2557228455.00
     ;3144503.00	Parkwest Medical Center	PWMC Labor and Delivery	      		2557228471.00
     ;3144503.00	Parkwest Medical Center	PWMC Non Surgical	      			2557228487.00
     ;3144503.00	Parkwest Medical Center	PWMC Non Endo Procedure	      		2560310083.00
 
 
	execute cov1_sn_sched_ops 	"pw_1adm_dast_a_pln"
							,3144503.00
							,VALUE(2557228423.00, 2557228439.00, 2557228455.00,2557228471.00,2557228487.00,2560310083.00)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
elseif (($FAC_SEL = 8))
     ;3144505.00	LeConte Medical Center	LCMC PreAdmission Testing	     	2552926505.00
     ;3144505.00	LeConte Medical Center	LCMC Main OR	      				2552926529.00
     ;3144505.00	LeConte Medical Center	LCMC Labor and Delivery	      		2552926545.00
     ;3144505.00	LeConte Medical Center	LCMC Endoscopy	      				2552926567.00
     ;3144505.00	LeConte Medical Center	LCMC Non Surgical	      			2552926595.00
 
 
	execute cov1_sn_sched_ops 	"PRN12383"
							,3144505.00
							,VALUE(2552926505.00, 2552926529.00, 2552926545.00,2552926567.00,2552926595)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
elseif (($FAC_SEL = 9))
     ;3144502.00	Morristown-Hamblen Healthcare System	MHHS PreAdmission Testing	      	2557462357.00
     ;3144502.00	Morristown-Hamblen Healthcare System	MHHS Main OR	      				2557462381.00
     ;3144502.00	Morristown-Hamblen Healthcare System	MHHS Labor and Delivery	     		2557462433.00
     ;3144502.00	Morristown-Hamblen Healthcare System	MHHS Endoscopy	      				2557462459.00
     ;3144502.00	Morristown-Hamblen Healthcare System	MHHS Non Surgical	      			2557462497.00
 
 
	execute cov1_sn_sched_ops 	"mhhs_1adm_rec_mfp"
							,3144502.00
							,VALUE(2557462357.00, 2557462381.00, 2557462433.00,2557462459.00,2557462497)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
elseif (($FAC_SEL = 10))
     ;3144501.00	Fort Loudoun Medical Center	FLMC Main OR	      				2557236003.00
     ;3144501.00	Fort Loudoun Medical Center	FLMC Endoscopy	      				2557236019.00
     ;3144501.00	Fort Loudoun Medical Center	FLMC PreAdmission Testing	      	2557236531.00
     ;3144501.00	Fort Loudoun Medical Center	FLMC Non Surgical	      			2557236583.00
 
 
 
	execute cov1_sn_sched_ops 	"PRN12900"
							,3144501.00
							,VALUE(2557236003.00, 2557236019.00, 2557236531.00,2557236583.00)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
elseif (($FAC_SEL = 11))
     ;3144504.00	Roane Medical Center	RMC Main OR	      					2554024417.00
     ;3144504.00	Roane Medical Center	RMC PreAdmission Testing	      	2554024433.00
     ;3144504.00	Roane Medical Center	RMC Endoscopy	      				2554024461.00
     ;3144504.00	Roane Medical Center	RMC Non-Surgical	      			2554024477.00
 
 
 
	execute cov1_sn_sched_ops 	"PRN13364"
							,3144504.00
							,VALUE(2554024417.00, 2554024433.00, 2554024461.00,2554024477.00)
							,value(format(sysdate,"mmddyyyy;;d"))
							,value(format(sysdate,"mmddyyyy;;d"))
endif
#exit_script
 
 
end go

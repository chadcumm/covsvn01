/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_inactivate_pp_facility.prg
	Object name:		cov_inactivate_pp_facility
	Request #:

	Program purpose:	4888_Inactive Facilities Incorrectly Displaying On PowerPlans-WI
						https://wiki.cerner.com/x/7CZTe

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_inactivate_pp_facility:dba go
create program cov_inactivate_pp_facility:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 discovery_cnt = i4
	1 delete_mode_on = i2
	1 qual[*]
		2 pathway_catalog_id				  = f8
		2 description                         = vc
		2 parent_entity_id                    = f8
		2 Facility_Flexing_updt_dt_tm         = dq8
		2 Facility_Flexing_updt_id            = f8
		2 Facility_Flexing_updt_task          = i4
		2 LOCATION                            = vc
		2 LOC_ACTIVE_IND                      = i2
		2 Loc_updt_dt_tm                      = dq8
		2 Loc_updt_id                         = f8
		2 Loc_updt_task                       = i4
)

set t_rec->delete_mode_on = 1

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Discovery Audit Query   ****************************"))

select into "nl:"
	count(pc.pathway_catalog_id)
from 
	pathway_catalog pc,
	pw_cat_flex pcf,
	location l
where 
	pc.active_ind = 1
and pcf.pathway_catalog_id = pc.pathway_catalog_id
and pcf.parent_entity_id = l.location_cd
and l.active_ind = 0
and l.location_cd != 0.00
with orahintcbo("index(l xpklocation)")

set t_rec->discovery_cnt = curqual

if (t_rec->discovery_cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif
call writeLog(build2("* END   Discovery Audit Query   ****************************"))
call writeLog(build2("************************************************************"))

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Detailed Audit Query   *****************************"))
	select into "nl:"
	Logical_domain = ld.mnemonic,
	pc.pathway_catalog_id,
	pc.description,
	pcf.parent_entity_id,
	Facility_Flexing_updt_dt_tm = pcf.updt_dt_tm ";;q",
	Facility_Flexing_updt_id = pcf.updt_id,
	Facility_Flexing_updt_task = pcf.updt_task,
	LOCATION=uar_get_code_display(l.location_cd),
	LOC_ACTIVE_IND=l.active_ind,
	Loc_updt_dt_tm = l.updt_dt_tm ";;q",
	Loc_updt_id = l.updt_id,
	Loc_updt_task = l.updt_task
	from
	pathway_catalog pc,
	pw_cat_flex pcf,
	location l,
	organization o,
	logical_domain ld
	where pc.active_ind = 1
	and pcf.pathway_catalog_id = pc.pathway_catalog_id
	and pcf.parent_entity_id = l.location_cd
	and l.active_ind = 0
	and l.location_cd != 0.00
	and l.organization_id = o.organization_id
	and o.logical_domain_id = ld.logical_domain_id
	order by Logical_domain,pc.description
	detail
		t_rec->cnt = (t_rec->cnt + 1)
		stat = alterlist(t_rec->qual,t_rec->cnt)	
		t_rec->qual[t_rec->cnt].pathway_catalog_id				  	= pc.pathway_catalog_id			
		t_rec->qual[t_rec->cnt].description                         = pc.description                  
		t_rec->qual[t_rec->cnt].parent_entity_id                    = pcf.parent_entity_id             
		t_rec->qual[t_rec->cnt].Facility_Flexing_updt_dt_tm         = Facility_Flexing_updt_dt_tm  
		t_rec->qual[t_rec->cnt].Facility_Flexing_updt_id            = Facility_Flexing_updt_id     
		t_rec->qual[t_rec->cnt].Facility_Flexing_updt_task          = Facility_Flexing_updt_task   
		t_rec->qual[t_rec->cnt].LOCATION                            = LOCATION                     
		t_rec->qual[t_rec->cnt].LOC_ACTIVE_IND                      = LOC_ACTIVE_IND               
		t_rec->qual[t_rec->cnt].Loc_updt_dt_tm                      = Loc_updt_dt_tm               
		t_rec->qual[t_rec->cnt].Loc_updt_id                         = Loc_updt_id                  
		t_rec->qual[t_rec->cnt].Loc_updt_task                       = Loc_updt_task                
	with nocounter
	
if (t_rec->cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif
call writeLog(build2("* END   Detailed Audit Query   *****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Correct all Plans   ********************************"))
if (t_rec->delete_mode_on = 1)
	delete
	from pw_cat_flex pcf
	where pcf.parent_entity_id in (select location_cd
	                                from location
	                                where active_ind=0
	                                and location_cd != 0.00)
	and pcf.pathway_catalog_id in (select pc.pathway_catalog_id
	                                from pathway_catalog pc
	                                where pc.active_ind=1) 
	commit 
else
		call writeLog(build2("Skipping Delete statement"))
endif
call writeLog(build2("* END   Correct all Plans   ********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


set reply->status_data.status = "S"
#exit_script
call exitScript(null)
call echorecord(t_rec)

end
go

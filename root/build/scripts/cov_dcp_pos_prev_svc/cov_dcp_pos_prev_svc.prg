/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_dcp_pos_prev_svc.prg
	Object name:		cov_dcp_pos_prev_svc
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/
drop program cov_dcp_pos_prev_svc:dba go
create program cov_dcp_pos_prev_svc:dba

prompt 
	"Position" = ""
	, "Application" = "" 

with POSITION_DISP, APPLICATION_NBR


record t_rec
(
	1 prompts
	 2 position_disp = vc
	 2 application_nbr = i4
	1 pos_cnt = i2
	1 pos_qual[*]
	 2 display = vc
	 2 position_cd = f8
)

declare i = i2 with noconstant(0), protect

set t_rec->prompts.position_disp = $POSITION_DISP
set t_rec->prompts.application_nbr = $APPLICATION_NBR

if (t_rec->prompts.application_nbr = 0)
	call echo("no application parameter set, exiting")
	go to exit_script
endif 

if (t_rec->prompts.position_disp = "")
	call echo("no position parameter set, finding all positions")
	go to all_positions
endif 



#single_position
call echo("finding single position")
select into "nl:"
from
	code_value cv
plan cv
	where cv.display = t_rec->prompts.position_disp
	and   cv.active_ind = 1
	and   cv.code_set = 88
detail
	t_rec->pos_cnt = (t_rec->pos_cnt + 1)
	stat = alterlist(t_rec->pos_qual,t_rec->pos_cnt)
	t_rec->pos_qual[t_rec->pos_cnt].display = cv.display
	t_rec->pos_qual[t_rec->pos_cnt].position_cd = cv.code_value
with nocounter 

if (t_rec->pos_cnt = 0)
	call echo("no single position found")
	go to exit_script
else
	call echo("single position found, going to dcp_get_app_view_prefs")
	go to dcp_get_app_view_prefs
endif

#all_positions
select into "nl:"
from
	code_value cv
plan cv
	where cv.code_value > 0.0
	and   cv.active_ind = 1
	and   cv.code_set = 88
detail
	t_rec->pos_cnt = (t_rec->pos_cnt + 1)
	stat = alterlist(t_rec->pos_qual,t_rec->pos_cnt)
	t_rec->pos_qual[t_rec->pos_cnt].display = cv.display
	t_rec->pos_qual[t_rec->pos_cnt].position_cd = cv.code_value
with nocounter 

if (t_rec->pos_cnt = 0)
	go to exit_script
endif

#dcp_get_app_view_prefs

record 500525_request (
  1 application_number = i4   
  1 position_cd = f8   
  1 prsnl_id = f8   
  1 www_flag = i2   
  1 preftool_ind = i2   
  1 top_view_list_cnt = i4   
  1 top_view_list [*]   
    2 frame_type = c20  
) 

for (i=1 to t_rec->pos_cnt)
	free record 500525_reply
	set 500525_request->application_number = t_rec->prompts.application_nbr
	set 500525_request->position_cd = t_rec->pos_qual[i].position_cd
	set 500525_request->preftool_ind = 1
	
	set 500525_request->top_view_list_cnt = 21
	set stat = alterlist(500525_request->top_view_list,500525_request->top_view_list_cnt)
	
	set 500525_request->top_view_list[1].frame_type = "ORG"
	set 500525_request->top_view_list[2].frame_type = "CHART"
	set 500525_request->top_view_list[3].frame_type = "ORDINFO"
	set 500525_request->top_view_list[4].frame_type = "MEDDLG"
	set 500525_request->top_view_list[5].frame_type = "IVDLG"
	set 500525_request->top_view_list[6].frame_type = "ORDERDLG"
	set 500525_request->top_view_list[7].frame_type = "INBOXCNDLG"
	set 500525_request->top_view_list[8].frame_type = "FSCNDLG"
	set 500525_request->top_view_list[9].frame_type = "ISCNDLG"
	set 500525_request->top_view_list[10].frame_type = "INBOXFSDLG"
	set 500525_request->top_view_list[11].frame_type = "VISITWND"
	set 500525_request->top_view_list[12].frame_type = "PTLISTLITE"
	set 500525_request->top_view_list[13].frame_type = "CLINORDDLG"
	set 500525_request->top_view_list[14].frame_type = "FSNEWRSLTDLG"
	set 500525_request->top_view_list[15].frame_type = "DPRESVIEW"
	set 500525_request->top_view_list[16].frame_type = "PNEDCNDLG"
	set 500525_request->top_view_list[17].frame_type = "LVINBOXFSDLG"
	set 500525_request->top_view_list[18].frame_type = "MICROVIEWER"
	set 500525_request->top_view_list[19].frame_type = "INBOXDISCERN"
	set 500525_request->top_view_list[20].frame_type = "PWNOTEFS"
	set 500525_request->top_view_list[21].frame_type = "IMMFORECAST"
	
	set stat = tdbexecute(500017,500255,500525,"REC",500525_request,"REC",500525_reply)
	
	if (validate(500525_reply))
		call echorecord(500525_reply)
	endif
endfor


#exit_script

call echorecord(t_rec)
end 
go


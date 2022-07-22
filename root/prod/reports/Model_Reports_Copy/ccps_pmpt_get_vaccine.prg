drop program ccps_pmpt_get_vaccine:dba go
create program ccps_pmpt_get_vaccine:dba
 
prompt
	"Search String" = ""
 
with P_SEARCH
 
 
/*~BB~***********************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
/*****************************************************************************
 
   Source file name: ccps_pmpt_get_covid_immun.prg
   Object name:      ccps_pmpt_get_covid_immun
   Task #:
   Request #:
 
   Program purpose:  Covid Immun Event Cds.
 
   Tables read:
 
   Tables updated:
 
   Executing from:
 
   Special Notes:
 
*********************************************************************************************************************************/
;~DB~*****************************************************************************************************************************
;*                      GENERATED MODIFICATION CONTROL LOG                                                                       *
;*********************************************************************************************************************************
;*                                                                                                                               *
;*Mod   Date   Engineer       Comment                                                                                            *
;*--- -------- -------------  -------------------------------------------------------------------------------------------------- *
; 000 09/21/20 SF3151         Initial Release                                                                                    *
;*********************************************************************************************************************************
 
;*** Init/Declare Block =======================================================
execute ccl_prompt_api_dataset "autoset"
 
declare sSearchString = vc with protect,noconstant(concat("*",trim(cnvtupper(cnvtalphanum($P_SEARCH)),3),"*"))

declare prompt_error(error_msg = vc) = i2
;==============================================================================
 
;*** Get Items ================================================================
select
   cv.code_value
   ,cv.display
from v500_event_set_explode ese
   ,code_value cv
plan ese
   where ese.event_set_cd in
            (
               select cv.code_value
               from code_value cv
               where cv.code_set = 93
               and cv.display_key = "IMMUNIZATIONS"
               and cv.active_ind = 1
            )
join cv
   where cv.code_value = ese.event_cd
   and operator(cv.display_key,"LIKE",notrim(patstring(sSearchString,1)))
   and cv.active_ind = 1
   and cnvtdatetime(sysdate) between cv.begin_effective_dt_tm and cv.end_effective_dt_tm
order cv.display
head report
   stat = makedataset(10)
detail
   stat = writerecord(0)
foot report
   stat = closedataset(0)
with reporthelp, check
if(curqual = 0)
	set stat = prompt_error(concat("NO IMUNNIZATION FOUND WITH SEARCH STRING ",trim(sSearchString,3)))
endif
;==============================================================================

;*** Subroutines ==============================================================
subroutine prompt_error(message)
	select into "nl:"
		id = 0.0
		,desc = message
	from (dummyt d with seq = 1)
	plan d
	head report
		stat = MakeDataSet(10)
	detail
		stat = WriteRecord(0)
	foot report
		stat = CloseDataset(0)
	with reporthelp, check
end   ;*** prompt_error ========================================================

 
;*** Exit Script ==============================================================
end go

/*****************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 2004 Cerner Corporation                      *
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
      ***********************************************************************/
 
/*****************************************************************************
 
******************************************************************************/
/***********************************************************************************************************************
*                           GENERATED MODIFICATION CONTROL LOG
************************************************************************************************************************
*                                                                                                                      *
* Feature	Mod	Date		Engineer	Comment                                                                        *
* -------	---	----------	----------	-------------------------------------------------------------------------------*
			000 05/14/2018	ARG			Initial release (Alix Govatsos)
			001 10/08/2018	TAB			Updated list of radiologists.
			003 11/20/2018	TAB			Updated list of radiologists.
			004 01/04/2019	TAB			Updated list of radiologists.
			005 10/02/2019	TAB			Updated list of radiologists.
			006 10/16/2019	TAB			Updated list of radiologists.
			007 03/23/2019	TAB			Updated list of radiologists.
			008 06/22/2020	TAB			Replaced list of radiologists with values from custom code set.
			009 10/01/2020	TAB			Changed CODE_VALUE_EXTENSION field_name to STAR_ID.
			010 05/02/2022	TAB			Adjusted criteria for code value query.
 
************************* END OF ALL MODCONTROL BLOCKS *****************************************************************/
 
declare organization_doctor_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare star_doctor_number_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
 
free record radiologists
record radiologists
(
	1 cnt			= i4
	1 list[*]
		2 person_id = f8
)
 
 
; populate record structure with mbm radiologists
select into "NL:"
from
	PRSNL_ALIAS pera
	
where
	pera.prsnl_alias_type_cd = organization_doctor_var
	and pera.alias_pool_cd = star_doctor_number_var
	and pera.alias in (
		;008
		select
			cve.field_value
		from 
			CODE_VALUE cv
			
			, (inner join CODE_VALUE_EXTENSION cve on cve.code_set = cv.code_set
				and cve.code_value = cv.code_value
				and cve.field_name = "STAR_ID" ;009
				)			
		where 
			cv.code_set = 100506
			and cv.cdf_meaning = "RAD-MBM"
			and cv.begin_effective_dt_tm < cnvtdatetime(curdate, curtime) ;010
			and cv.end_effective_dt_tm > cnvtdatetime(curdate, curtime) ;010
			and cv.active_ind = 1
	)
	and pera.end_effective_dt_tm > cnvtdatetime(curdate, curtime) ;010
	and pera.active_ind = 1
	
order by
	pera.person_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	call alterlist(radiologists->list, cnt)
 
	radiologists->cnt = cnt
	radiologists->list[cnt].person_id = pera.person_id
 
with nocounter
 

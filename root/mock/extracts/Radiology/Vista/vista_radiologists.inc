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
			000	05/14/2018	ARG			Initial release (Alix Govatsos)
			001	10/10/2018	TAB			Updated list of radiologists.
			002 11/20/2018	TAB			Updated list of radiologists.
			003	01/16/2019	TAB			Updated list of radiologists.
			004 02/13/2019	TAB			Updated list of radiologists.
			005 04/29/2019	TAB			Updated list of radiologists.
			006 12/30/2019	TAB			Updated list of radiologists.
			007 06/22/2020	TAB			Replaced list of radiologists with values from custom code set.
			008 10/01/2020	TAB			Changed CODE_VALUE_EXTENSION field_name to STAR_ID.
 
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
 
 
; populate record structure with vista radiologists
select into "NL:"
from
	PRSNL_ALIAS pera
	
where
	pera.prsnl_alias_type_cd = organization_doctor_var
	and pera.alias_pool_cd = star_doctor_number_var
	and pera.alias in (
		;007
		select
			cve.field_value
		from 
			CODE_VALUE cv
			
			, (inner join CODE_VALUE_EXTENSION cve on cve.code_set = cv.code_set
				and cve.code_value = cv.code_value
				and cve.field_name = "STAR_ID" ;008
				)			
		where 
			cv.code_set = 100506
			and cv.cdf_meaning = "RAD-VISTA"
			and cv.active_ind = 1
	)
	and pera.end_effective_dt_tm > sysdate
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
 
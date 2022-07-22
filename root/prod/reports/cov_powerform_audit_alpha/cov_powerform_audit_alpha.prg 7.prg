/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2005 Cerner Corporation                 *
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

        Source file name:       cov_powerform_audit_alpha.prg
        Object name:			cov_powerform_audit_alpha

        Product:
        Product Team:
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:


        Tables updated:         -

******************************************************************************/


;~DB~************************************************************************
;    *    GENERATED MODIFICATION CONTROL LOG              *
;    ****************************************************************************
;    *                                                                         *
;    *Mod Date       Engineeer          Comment                                *
;    *--- ---------- ------------------ -----------------------------------    *
;     000 18-10-22  							initial release			       *
;    																           *
;~DE~***************************************************************************


;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program cov_powerform_audit_alpha:dba go
create program cov_powerform_audit_alpha:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Form Selection" = 0
	, "Nomenclature Search" = "" 

with OUTDEV, DCP_FORM_ID, NOMEN_STRING


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
)

if ($NOMEN_STRING > " ")

SELECT DISTINCT into $OUTDEV

        FORM_DESCRIPTION=SUBSTRING(1,50,F.DESCRIPTION),

        SECTION_DESC=SUBSTRING(1,50,S.DESCRIPTION),

        DTA_DESC=DTA.DESCRIPTION,

        DTA_MNEM=DTA.MNEMONIC,

        EVCODE_DISPLAY=SUBSTRING(1,40,V5C.EVENT_CD_DISP),

	EVSET_NAME=SUBSTRING(1,40,V5C.EVENT_SET_NAME),

        ALPHA_RESPONSE=SUBSTRING(1,50,A.DESCRIPTION),

        NOMEN_MNEM=N.MNEMONIC,

        NOMEN_STSTRING=N.SHORT_STRING,

        NOMEN_SOURCESRG=N.SOURCE_STRING,

        ALPHA_NOMEN_ID=A.NOMENCLATURE_ID



FROM    DCP_FORMS_DEF D,

        DCP_FORMS_REF F,

        DCP_SECTION_REF S,

        DCP_INPUT_REF I,

        NAME_VALUE_PREFS PRF,

        DISCRETE_TASK_ASSAY DTA,

        V500_EVENT_CODE V5C,

	REFERENCE_RANGE_FACTOR R,

        ALPHA_RESPONSES A,

        (DUMMYT D1 WITH SEQ=1),

        NOMENCLATURE N,

        DUMMYT D2

PLAN F

WHERE F.ACTIVE_IND=1
;and f.dcp_form_instance_id = $DCP_FORM_ID

JOIN D WHERE F.DCP_FORM_INSTANCE_ID = D.DCP_FORM_INSTANCE_ID

AND D.ACTIVE_IND=1 

JOIN S WHERE S.DCP_SECTION_REF_ID = D.DCP_SECTION_REF_ID

AND S.ACTIVE_IND=1

JOIN I WHERE I.DCP_SECTION_INSTANCE_ID = S.DCP_SECTION_INSTANCE_ID

AND I.ACTIVE_IND=1

JOIN PRF WHERE I.DCP_INPUT_REF_ID = PRF.PARENT_ENTITY_ID

AND PRF.ACTIVE_IND=1

JOIN dta WHERE PRF.MERGE_ID = DTA.TASK_ASSAY_CD

AND DTA.ACTIVE_IND=1

JOIN D1

JOIN V5C WHERE DTA.EVENT_CD = V5C.EVENT_CD

JOIN R WHERE DTA.TASK_ASSAY_CD = R.TASK_ASSAY_CD

AND R.ACTIVE_IND = 1

JOIN D2

JOIN A WHERE R.REFERENCE_RANGE_FACTOR_ID = A.REFERENCE_RANGE_FACTOR_ID

JOIN N WHERE A.NOMENCLATURE_ID = N.NOMENCLATURE_ID
and n.source_string = patstring(concat($NOMEN_STRING, '*'))


ORDER BY F.DESCRIPTION, S.DESCRIPTION, DTA.DESCRIPTION, V5C.EVENT_SET_NAME,

A.DESCRIPTION
WITH COUNTER, format, separator=" " 


endif

else

SELECT DISTINCT into $OUTDEV

        FORM_DESCRIPTION=SUBSTRING(1,50,F.DESCRIPTION),

        SECTION_DESC=SUBSTRING(1,50,S.DESCRIPTION),

        DTA_DESC=DTA.DESCRIPTION,

        DTA_MNEM=DTA.MNEMONIC,

        EVCODE_DISPLAY=SUBSTRING(1,40,V5C.EVENT_CD_DISP),

	EVSET_NAME=SUBSTRING(1,40,V5C.EVENT_SET_NAME),

        ALPHA_RESPONSE=SUBSTRING(1,50,A.DESCRIPTION),

        NOMEN_MNEM=N.MNEMONIC,

        NOMEN_STSTRING=N.SHORT_STRING,

        NOMEN_SOURCESRG=N.SOURCE_STRING,

        ALPHA_NOMEN_ID=A.NOMENCLATURE_ID



FROM    DCP_FORMS_DEF D,

        DCP_FORMS_REF F,

        DCP_SECTION_REF S,

        DCP_INPUT_REF I,

        NAME_VALUE_PREFS PRF,

        DISCRETE_TASK_ASSAY DTA,

        V500_EVENT_CODE V5C,

	REFERENCE_RANGE_FACTOR R,

        ALPHA_RESPONSES A,

        (DUMMYT D1 WITH SEQ=1),

        NOMENCLATURE N,

        DUMMYT D2

PLAN F

WHERE F.ACTIVE_IND=1
and f.dcp_form_instance_id = $DCP_FORM_ID

JOIN D WHERE F.DCP_FORM_INSTANCE_ID = D.DCP_FORM_INSTANCE_ID

AND D.ACTIVE_IND=1 

JOIN S WHERE S.DCP_SECTION_REF_ID = D.DCP_SECTION_REF_ID

AND S.ACTIVE_IND=1

JOIN I WHERE I.DCP_SECTION_INSTANCE_ID = S.DCP_SECTION_INSTANCE_ID

AND I.ACTIVE_IND=1

JOIN PRF WHERE I.DCP_INPUT_REF_ID = PRF.PARENT_ENTITY_ID

AND PRF.ACTIVE_IND=1

JOIN dta WHERE PRF.MERGE_ID = DTA.TASK_ASSAY_CD

AND DTA.ACTIVE_IND=1

JOIN D1

JOIN V5C WHERE DTA.EVENT_CD = V5C.EVENT_CD

JOIN R WHERE DTA.TASK_ASSAY_CD = R.TASK_ASSAY_CD

AND R.ACTIVE_IND = 1

JOIN D2

JOIN A WHERE R.REFERENCE_RANGE_FACTOR_ID = A.REFERENCE_RANGE_FACTOR_ID

JOIN N WHERE A.NOMENCLATURE_ID = N.NOMENCLATURE_ID
;and n.source_string = "Rehab*"


ORDER BY F.DESCRIPTION, S.DESCRIPTION, DTA.DESCRIPTION, V5C.EVENT_SET_NAME,

A.DESCRIPTION
WITH OUTERJOIN=D1,OUTERJOIN=D2, COUNTER, format, separator=" " 


endif


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go

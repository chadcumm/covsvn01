/*~BB~************************************************************************

  *                                                                      *

  *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *

  *                              Technology, Inc.                        *

  *       Revision      (c) 1984-1997 Cerner Corporation                 *

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

 

        Source file name:   ccps_provider_selection_lite.prg

        Object name:        ccps_provider_selection_lite

        Request #:

 

        Product:            Discern Custom Programming

        Product Team:       Centers Custom Programming Services

        HNA Version:

        CCL Version:

 

        Program purpose:    Search Script for Provider Selection Lite

 

        Tables read:

 

        Tables updated:

 

        Executing from:     ExplorerMenu

 

        Special Notes:

 

**********************************************************************************************

*                      GENERATED MODIFICATION CONTROL LOG

**********************************************************************************************

*

*Mod Date        Feature  Engineer     Comment

*--- ----------- -------  ------------ -------------------------------------------------------

*000 07/22/2010  250229   ML011047     Initial Release - SR 1-3693449191

*001 03/02/2011  288417   ML011047     Added Org. Security (SCINT-264)

*002 04/15/2014  400913   ML011047     Added the new reply variables needed for

                                       version 026 of ocx_get_providers_by_alias and version

                                       34 of ocx_get_providers_by_name.

                                       Removed original discern request logic as it's no

                                       longer needed.

                                       Added substring to select variables.

*********************************************************************************************/

drop program ccps_provider_selection_lite:dba go

create program ccps_provider_selection_lite:dba

 

prompt

	"Last Name:" = ""

	, "First Name:" = ""

	, "Suffix:" = ""

	, "Title:" = ""

	, "Alias:" = ""

	, "Alias Type:" = 0

	, "View Physician Only" = 0

	, "Max:" = 0

	, "Search By (Name or Alias):" = 0

 

with prmptLastName, prmptFirstName, prmptSuffix, prmptTitle, prmptAlias,

	prmptAliasType, prmptViewPhysicianOnly, prmptMax, prmptSearchBy

 

/**************************************************************

; DVDev DECLARED SUBROUTINES

**************************************************************/

 

/**************************************************************

; DVDev DECLARED VARIABLES

**************************************************************/

declare PRMPT_LAST_NAME                            = vc with protect, constant($prmptLastName)

declare PRMPT_FIRST_NAME                           = vc with protect, constant($prmptFirstName)

declare PRMPT_SUFFIX                               = vc with protect, constant($prmptSuffix)

declare PRMPT_TITLE                                = vc with protect, constant($prmptTitle)

declare PRMPT_ALIAS                                = vc with protect, constant($prmptAlias)

declare PRMPT_ALIAS_TYPE                           = f8 with protect, constant($prmptAliasType)

declare PRMPT_VIEW_PHYSICIAN_ONLY                  = i2 with protect, constant($prmptViewPhysicianOnly)

declare PRMPT_MAX                                  = i4 with protect, constant($prmptMax)

declare PRMPT_SEARCH_BY                            = i2 with protect, constant($prmptSearchBy)

declare SEARCH_BY_NAME                             = i2 with protect, constant(1)

if(validate(DEBUG, -1) < 0)

    declare DEBUG                                  = i2 with protect, constant(0)

endif



declare services_string                            = vc with protect, noconstant("")

declare orgs_string                                = vc with protect, noconstant("")

declare prsnl_alias_string                         = vc with protect, noconstant("")

declare positions_string                           = vc with protect, noconstant("")

declare org_security_ind                           = i2 with protect, noconstant(0)

 

if (DEBUG) call echorecord(request), call echorecord(reply) endif

  

if(PRMPT_SEARCH_BY = SEARCH_BY_NAME)

 

    record request ;name

    ( 1 max                  = i4

      1 name_last_key        = c100

      1 name_first_key       = c100

      1 search_str_ind       = i2

      1 search_str           = vc

      1 title_str            = vc

      1 suffix_str           = vc

      1 degree_str           = vc

      1 use_org_security_ind = i2

      1 organization_id      = f8

      1 organizations[*]

        2 organization_id    = f8

      1 context_ind          = i2

      1 start_name           = vc

      1 start_name_first     = vc

      1 context_person_id    = f8

      1 physician_ind        = i2

      1 ft_ind               = i2

      1 non_ft_ind           = i2

      1 inactive_ind         = i2

      1 prsnl_group_id       = f8

      1 location_cd          = f8

      1 return_aliases       = i2

      1 return_orgs          = i2

      1 return_services      = i2

      1 alias_type_list      = vc

      1 priv[*]

        2 privilege          = c12

      1 auth_only_ind        = i2

      1 provider_filter[*]

        2 filter_name        = vc

        2 filter_data[*]

            3 data_id        = f8

    ) with protect

 

    /*

    Record is known to all child processes (PUBLIC) but allows a child process to create a record with the same name.

    When control returns to the parent, the child record is no longer known, and the parent record is restored.

    If a child process does not create a record with the same name, PROTECT scope is the same as PUBLIC scope.

    */

 

    record reply ;name

    (  1 prsnl_cnt                      = i4

       1 maxqual                        = i4

       1 more_exist_ind                 = i2

       1 context_ind                    = i2

       1 start_name                     = vc

       1 start_name_first               = vc

       1 context_person_id              = f8

       1 search_name_first              = vc

       1 search_name_last               = vc

       1 prsnl[*]

         2 person_id                    = f8

         2 name_last_key                = c100

         2 name_first_key               = c100

         2 prsnl_type_cd                = f8

         2 name_full_formatted          = c100

         2 password                     = c100

         2 email                        = c100

         2 physician_ind                = i2

         2 position_cd                  = f8

         2 department_cd                = f8

         2 free_text_ind                = i2

         2 section_cd                   = f8

         2 contributor_system_cd        = f8

         2 name_last                    = c200

         2 name_first                   = c200

         2 username                     = c50

         2 service[*]

            3 service_desc_id           = f8

            3 service_desc_name         = c40

         2 org[*]

            3 org_id                    = f8

            3 org_name                  = c40

         2 prsnl_alias[*]

            3 prsnl_alias_id            = f8

            3 alias_pool_cd             = f8

            3 alias_pool_disp           = c40

            3 alias                     = c100

            3 prsnl_alias_type_cd       = f8

            3 prsnl_alias_type_disp     = c40

         2 positions[*]

            3 position_cd               = f8

            3 position_disp             = vc

%i cclsource:status_block.inc

    ) with protect

 

    record name_reply

     (  1 prsnl_cnt                      = i4

       1 maxqual                        = i4

       1 more_exist_ind                 = i2

       1 context_ind                    = i2

       1 start_name                     = vc

       1 start_name_first               = vc

       1 context_person_id              = f8

       1 search_name_first              = vc

       1 search_name_last               = vc

       1 prsnl[*]

         2 person_id                    = f8

         2 name_last_key                = c100

         2 name_first_key               = c100

         2 prsnl_type_cd                = f8

         2 name_full_formatted          = c100

         2 password                     = c100

         2 email                        = c100

         2 physician_ind                = i2

         2 position_cd                  = f8

         2 department_cd                = f8

         2 free_text_ind                = i2

         2 section_cd                   = f8

         2 contributor_system_cd        = f8

         2 name_last                    = c200

         2 name_first                   = c200

         2 username                     = c50

         2 service[*]

            3 service_desc_id           = f8

            3 service_desc_name         = c40

         2 org[*]

            3 org_id                    = f8

            3 org_name                  = c40

         2 prsnl_alias[*]

            3 prsnl_alias_id            = f8

            3 alias_pool_cd             = f8

            3 alias_pool_disp           = c40

            3 alias                     = c100

            3 prsnl_alias_type_cd       = f8

            3 prsnl_alias_type_disp     = c40

         2 positions[*]

            3 position_cd               = f8

            3 position_disp             = vc

%i cclsource:status_block.inc

    )

 

else ;search by alias

 

    record request ;alias

    (  1 max                    = i4

       1 alias                  = c200

       1 physician_ind          = i2

       1 inactive_ind           = i2

       1 group_id               = f8

       1 organization_id        = f8

       1 location_cd            = f8

       1 priv[*]

         2 privilege            = c12

       1 alias_type_cd          = f8

       1 use_org_security_ind   = i2

       1 orgs[*]

         2 org_id               = f8

       1 context_ind            = i2

       1 start_alias            = vc

       1 context_alias_id       = f8

       1 alias_type_list        = vc

       1 return_orgs            = i2

       1 auth_only_ind          = i2

       1 provider_filter[*]

         2 filter_name          = vc

         2 filter_data[*]

             3 data_id          = f8

       1 return_services        = i2

       1 return_aliases         = i2

    ) with protect

 

    record reply ;alias

    (  1 prsnl_alias_cnt                = i4

       1 more_exist_ind                 = i2

       1 context_ind                    = i2

       1 start_alias                    = vc

       1 context_alias_id               = f8

       1 prsnl_alias[*]

         2 prsnl_alias_id               = f8

         2 person_id                    = f8

         2 alias_pool_cd                = f8

         2 prsnl_alias_type_cd          = f8

         2 alias                        = c200

         2 prsnl_alias_sub_type_cd      = f8

         2 check_digit                  = i4

         2 check_digit_method_cd        = f8

         2 name_last_key                = c100

         2 name_first_key               = c100

         2 prsnl_type_cd                = f8

         2 name_full_formatted          = c100

         2 password                     = c100

         2 email                        = c100

         2 physician_ind                = i2

         2 position_cd                  = f8

         2 department_cd                = f8

         2 free_text_ind                = i2

         2 section_cd                   = f8

         2 contributor_system_cd        = f8

         2 name_last                    = c200

         2 name_first                   = c200

         2 username                     = c50

         2 service[*]

            3 service_desc_id           = f8

            3 service_desc_name         = c40

         2 org[*]

            3 org_id                    = f8

            3 org_name                  = c40

         2 other_prsnl_alias[*]

            3 prsnl_alias_id            = f8

            3 alias_pool_cd             = f8

            3 alias_pool_disp           = c40

            3 alias                     = c100

            3 prsnl_alias_type_cd       = f8

            3 prsnl_alias_type_disp     = c40

         2 positions[*]

            3 position_cd               = f8

            3 position_disp             = vc

         2 prsnl_alias_type_disp        = c40   

%i cclsource:status_block.inc

    ) with protect

 

    record alias_reply

    (  1 prsnl_alias_cnt                = i4

       1 more_exist_ind                 = i2

       1 context_ind                    = i2

       1 start_alias                    = vc

       1 context_alias_id               = f8

       1 prsnl_alias[*]

         2 prsnl_alias_id               = f8

         2 person_id                    = f8

         2 alias_pool_cd                = f8

         2 prsnl_alias_type_cd          = f8

         2 alias                        = c200

         2 prsnl_alias_sub_type_cd      = f8

         2 check_digit                  = i4

         2 check_digit_method_cd        = f8

         2 name_last_key                = c100

         2 name_first_key               = c100

         2 prsnl_type_cd                = f8

         2 name_full_formatted          = c100

         2 password                     = c100

         2 email                        = c100

         2 physician_ind                = i2

         2 position_cd                  = f8

         2 department_cd                = f8

         2 free_text_ind                = i2

         2 section_cd                   = f8

         2 contributor_system_cd        = f8

         2 name_last                    = c200

         2 name_first                   = c200

         2 username                     = c50

         2 service[*]

            3 service_desc_id           = f8

            3 service_desc_name         = c40

         2 org[*]

            3 org_id                    = f8

            3 org_name                  = c40

         2 other_prsnl_alias[*]

            3 prsnl_alias_id            = f8

            3 alias_pool_cd             = f8

            3 alias_pool_disp           = c40

            3 alias                     = c100

            3 prsnl_alias_type_cd       = f8

            3 prsnl_alias_type_disp     = c40

         2 positions[*]

            3 position_cd               = f8

            3 position_disp             = vc

         2 prsnl_alias_type_disp        = c40  

%i cclsource:status_block.inc

    )

 

endif

 

/**************************************************************

; DVDev Start Coding

**************************************************************/

select into "nl:" 

from dm_info i

where i.info_name       = "SEC_ORG_RELTN"

    and i.info_domain   = "SECURITY"

    and i.info_number   > 0.0

detail

    org_security_ind    = TRUE

with nocounter



if(PRMPT_SEARCH_BY = SEARCH_BY_NAME)

 

    set request->name_last_key          = PRMPT_LAST_NAME

    set request->name_first_key         = PRMPT_FIRST_NAME

    set request->suffix_str             = PRMPT_SUFFIX

    set request->title_str              = PRMPT_TITLE

    set request->physician_ind          = PRMPT_VIEW_PHYSICIAN_ONLY

    set request->max                    = PRMPT_MAX

    set request->return_aliases         = TRUE

    set request->return_orgs            = TRUE

    set request->return_services        = TRUE

    set request->use_org_security_ind   = org_security_ind

 

    execute ocx_get_providers_by_name

 

    /* Copy the PRSNL into a new structure for the dataset */

    set stat = moverec(reply, name_reply)

 

else ;search by alias

 

    set request->alias                  = PRMPT_ALIAS

    set request->alias_type_cd          = PRMPT_ALIAS_TYPE

    set request->physician_ind          = PRMPT_VIEW_PHYSICIAN_ONLY

    set request->max                    = PRMPT_MAX

    set request->return_aliases         = TRUE

    set request->return_orgs            = TRUE

    set request->return_services        = TRUE

    set request->use_org_security_ind   = org_security_ind

 

    execute ocx_get_providers_by_alias

 

    /* Copy the PRSNL into a new structure for the dataset */

    set stat = moverec(reply, alias_reply)

 

endif

 

if (DEBUG) call echorecord(request), call echorecord(reply) endif

 

free record reply

free record request



if(validate(name_reply->prsnl_cnt, 0) = 0 and validate(alias_reply->prsnl_alias_cnt, 0) = 0)

    go to exit_script

endif

 

 

/* Load the dataset returned in the reply */

execute ccl_prompt_api_dataset "dataset"

 

 

if(PRMPT_SEARCH_BY = SEARCH_BY_NAME)

 

    select into "nl:"

        name_order = build(substring(1, 50, name_reply->prsnl[d1.seq].name_last_key), " ",

                           substring(1, 50, name_reply->prsnl[d1.seq].name_first_key), " ",

                           substring(1, 50, cnvtstring(name_reply->prsnl[d1.seq].person_id)))

 

    from

        (dummyt d1 with seq = size(name_reply->prsnl, 5))

 

    plan d1

 

    order by name_order

 

    head report

        pcnt   = 0

        x      = 0

        stat   = MakeDataSet(10)

        vPID   = AddRealField  ("PID"          , "Person ID"       , 1    )

        vNAME  = AddStringField("Name"         , "Name"            , 1, 50)

        vORG   = AddStringField("Organizations", "Organizations"   , 1, 50)

        vSERV  = AddStringField("Services"     , "Services"        , 1, 50)

        vALIAS = AddStringField("Aliases"      , "Aliases"         , 1, 50)

        vPOS   = AddStringField("Positions"    , "Positions"       , 1, 50)

 

    head name_order

        pcnt = GetNextRecord(0)

        stat = SetRealField(pcnt,   vPID , name_reply->prsnl[d1.seq].person_id)

        stat = SetStringField(pcnt, vNAME, name_reply->prsnl[d1.seq].name_full_formatted)



        orgs_string = ""

        for(x = 1 to size(name_reply->prsnl[d1.seq].org,5))

            orgs_string = if(textlen(trim(orgs_string,3)) = 0)

                              trim(name_reply->prsnl[d1.seq].org[x].org_name,3)

                          else

                              build2(orgs_string, "; ", trim(name_reply->prsnl[d1.seq].org[x].org_name,3))

                          endif

        endfor

        stat = SetStringField(pcnt, vORG, trim(orgs_string,3))

      

        services_string = ""

        for(x = 1 to size(name_reply->prsnl[d1.seq].service,5))

            services_string = if(textlen(trim(services_string,3)) = 0)

                                  trim(name_reply->prsnl[d1.seq].service[x].service_desc_name,3)

                              else

                                  build2(services_string, "; ", trim(name_reply->prsnl[d1.seq].service[x].service_desc_name,3))

                              endif

        endfor

        stat = SetStringField(pcnt, vSERV, trim(services_string,3))



        prsnl_alias_string = ""

        for(x = 1 to size(name_reply->prsnl[d1.seq].prsnl_alias,5))

            prsnl_alias_string = if(textlen(trim(prsnl_alias_string,3)) = 0)

                                     trim(name_reply->prsnl[d1.seq].prsnl_alias[x].alias,3)

                                 else

                                     build2(prsnl_alias_string, "; ", trim(name_reply->prsnl[d1.seq].prsnl_alias[x].alias,3))

                                 endif

        endfor

        stat = SetStringField(pcnt, vALIAS, trim(prsnl_alias_string,3))



        positions_string = ""

        for(x = 1 to size(name_reply->prsnl[d1.seq].positions,5))

            positions_string = if(textlen(trim(positions_string,3)) = 0)

                                   trim(name_reply->prsnl[d1.seq].positions[x].position_disp,3)

                               else

                                   build2(positions_string, "; ", trim(name_reply->prsnl[d1.seq].positions[x].position_disp,3))

                               endif

        endfor

        stat = SetStringField(pcnt, vPOS, trim(positions_string,3))

 

    detail

        null

 

    foot name_order

        null

 

    foot report

        stat = CloseDataSet(0)

 

    with check

 

    if(DEBUG) call echorecord(name_reply) endif

 

else ;search by alias

 

    select into "nl:"

        alias = substring(1, 50, alias_reply->prsnl_alias[d1.seq].alias)

        ,ID   = alias_reply->prsnl_alias[d1.seq].prsnl_alias_id

 

    from

        (dummyt d1 with seq = size(alias_reply->prsnl_alias, 5))

 

    plan d1

 

    order by alias, ID

 

    head report

        pcnt    = 0

        x       = 0

        stat    = MakeDataSet(10)

        vPID    = AddRealField  ("PID"          , "Person ID"       , 1    )

        vPALIAS = AddStringField("Alias"        , "Alias"           , 1, 25)

        vNAME   = AddStringField("Name"         , "Name"            , 1, 50)

        vORG    = AddStringField("Organizations", "Organizations"   , 1, 50)

        vSERV   = AddStringField("Services"     , "Services"        , 1, 50)

        vALIAS  = AddStringField("Aliases"      , "Aliases"         , 1, 50)

        vPOS    = AddStringField("Positions"    , "Positions"       , 1, 50)

    

    head alias

        null

        

    head ID

        pcnt = GetNextRecord(0)

        stat = SetRealField(pcnt  , vPID   , alias_reply->prsnl_alias[d1.seq].person_id)

        stat = SetStringField(pcnt, vPALIAS, alias_reply->prsnl_alias[d1.seq].alias)

        stat = SetStringField(pcnt, vNAME  , alias_reply->prsnl_alias[d1.seq].name_full_formatted)

        

        orgs_string = ""

        for(x = 1 to size(alias_reply->prsnl_alias[d1.seq].org,5))

            orgs_string = if(textlen(trim(orgs_string,3)) = 0)

                              trim(alias_reply->prsnl_alias[d1.seq].org[x].org_name,3)

                          else

                              build2(orgs_string, "; ", trim(alias_reply->prsnl_alias[d1.seq].org[x].org_name,3))

                          endif

        endfor

        stat = SetStringField(pcnt, vORG, trim(orgs_string,3))

        

        services_string = ""

        for(x = 1 to size(alias_reply->prsnl_alias[d1.seq].service,5))

            services_string = if(textlen(trim(services_string,3)) = 0)

                                  trim(alias_reply->prsnl_alias[d1.seq].service[x].service_desc_name,3)

                              else

                                  build2(services_string, "; ", 

                                         trim(alias_reply->prsnl_alias[d1.seq].service[x].service_desc_name,3))

                              endif

        endfor

        stat = SetStringField(pcnt, vSERV, trim(services_string,3))

        

        prsnl_alias_string = ""

        for(x = 1 to size(alias_reply->prsnl_alias[d1.seq].other_prsnl_alias,5))

            prsnl_alias_string = if(textlen(trim(prsnl_alias_string,3)) = 0)

                                     trim(alias_reply->prsnl_alias[d1.seq].other_prsnl_alias[x].alias,3)

                                 else

                                     build2(prsnl_alias_string, "; ", 

                                            trim(alias_reply->prsnl_alias[d1.seq].other_prsnl_alias[x].alias,3))

                                 endif

        endfor

        stat = SetStringField(pcnt, vALIAS, trim(prsnl_alias_string,3))

        

        positions_string = ""

        for(x = 1 to size(alias_reply->prsnl_alias[d1.seq].positions,5))

            positions_string = if(textlen(trim(positions_string,3)) = 0)

                                   trim(alias_reply->prsnl_alias[d1.seq].positions[x].position_disp,3)

                               else

                                   build2(positions_string, "; ",

                                          trim(alias_reply->prsnl_alias[d1.seq].positions[x].position_disp,3))

                               endif

        endfor

        stat = SetStringField(pcnt, vPOS, trim(positions_string,3))

 

    detail

        null

 

    foot ID

        null

 

    foot report

        stat = CloseDataSet(0)

 

    with check

 

    if(DEBUG) call echorecord(alias_reply) endif

 

endif

 

 

#exit_script

 

if (DEBUG)

    call echo(build2("PRMPT_LAST_NAME: ",               PRMPT_LAST_NAME))

    call echo(build2("PRMPT_FIRST_NAME: ",              PRMPT_FIRST_NAME))

    call echo(build2("PRMPT_SUFFIX: ",                  PRMPT_SUFFIX))

    call echo(build2("PRMPT_TITLE: ",                   PRMPT_TITLE))

    call echo(build2("PRMPT_ALIAS: ",                   PRMPT_ALIAS))

    call echo(build2("PRMPT_ALIAS_TYPE: ",              PRMPT_ALIAS_TYPE))

    call echo(build2("PRMPT_VIEW_PHYSICIAN_ONLY: ",     PRMPT_VIEW_PHYSICIAN_ONLY))

    call echo(build2("PRMPT_MAX: ",                     PRMPT_MAX))

    call echo(build2("PRMPT_SEARCH_BY: ",               PRMPT_SEARCH_BY))

     

    call echorecord(request)

    call echorecord(reply)

endif

 

/**************************************************************

; DVDev DEFINED SUBROUTINES

**************************************************************/

 

set last_mod = "002 ML011047 04/15/2014"

 

end

go



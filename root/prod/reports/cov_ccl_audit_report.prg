select
                cra.object_name
                , cra.object_params
                , lt.long_text
                , cra.object_type
                , cra.status
                , cra.records_cnt
                , cra.updt_id
                , per.name_full_formatted
                , cra.begin_dt_tm
                , cra.end_dt_tm
                , runtime = datetimediff(cra.end_dt_tm, cra.begin_dt_tm, 4)
                
from 
                CCL_REPORT_AUDIT cra
                
                , (left join PRSNL per on per.person_id = cra.updt_id)
                
                , (left join LONG_TEXT lt on lt.long_text_id = cra.long_text_id)
                
where
                1 = 1
                and cra.updt_dt_tm >= cnvtdatetime(cnvtlookbehind("30 D")) ; 30 days max
                and cra.updt_id = 12401279.00 ; paul hester

order by
                cra.updt_dt_tm desc
                
with format(date, ";;q"), time = 60


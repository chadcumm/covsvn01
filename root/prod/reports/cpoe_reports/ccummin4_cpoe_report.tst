execute ccummin4_cpoe_report_prsnl "flanders_allcomm_apr.csv", "01-APR-2019 00:00:00", "30-APR-2019 23:59:00" go

VALUE(2552503645) go ;PW
VALUE(2552503635.00) go ;FLMC

select * from prsnl p where p.name_last = "*Flanders*"


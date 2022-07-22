execute ccummin4_cpoe_report_prsnl "flanders_b.csv", "01-JAN-2019 00:00:00", "31-MAR-2019 23:59:00" go

VALUE(2552503645) go ;PW
VALUE(2552503635.00) go ;FLMC

select * from prsnl p where p.name_last = "*Flanders*"


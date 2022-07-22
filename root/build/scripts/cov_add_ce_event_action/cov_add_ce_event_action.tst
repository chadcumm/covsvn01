;execute cov_add_ce_event_action "MINE",2663269945,   16908168.00,"ORDER","COMPLETED" go
;execute cov_add_ce_event_action "MINE",2663269945,   16908168.00,"ENDORSE","REQUESTED" go
;execute cov_add_ce_event_action "MINE", 2692618699,   12415296.00,"ORDER","COMPLETED" go
;execute cov_add_ce_event_action "MINE", 2692618699,   12415296.00,"ENDORSE","REQUESTED" go

;with OUTDEV, EVENT_ID, PRSNL_ID, ACTION_TYPE, ACTION_STATUS

execute cov_add_ce_event_action "MINE",    2829362926.00  ,  12414422.00 ,"ORDER","COMPLETED" go

/*
16908168
12414422
update into clinical_event set verified_prsnl_id = 1,performed_prsnl_id = 1
 where event_id in( 2695987309
) go
 
 , 2676063945.00, 2676063947.00)    go
update into ce_event_prsnl set action_prsnl_id = 1 where ce_event_prsnl_id in(8248471145,
8248471155,
8248471158,
8248472001
) 

update into ce_event_prsnl set action_prsnl_id = 1 where ce_event_prsnl_id in(8246297371,8248471153,8248471160) go
delete from ce_event_prsnl where ce_event_prsnl_id in(8459941470,8459996367,8460002745) go

*/


;2675052540; 2676063945.00; 2676063947.00
;2695987309
;2725642867



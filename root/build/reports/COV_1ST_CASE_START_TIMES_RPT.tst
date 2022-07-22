 
FREE RECORD a GO
RECORD a
(
1	rec_cnt				=	i4
1	surgarea			=	vc
1	total		=	i4
1	percontime	=	vc
1	ontime		=	i4
1	appttotal 	=	i4
1	qual[*]
	2	dept			=	vc
	2	roomcnt			=	i4
	2	roomqual[*]
		3	room		=	vc
		3	rm_rsrc_cd 	=   f8
		3 	apptcnt		=	i4
 
		3	apptqual[*]
			4	apptid		=	f8
			4	periopdocid	=	f8
			4	personid	=	f8
			4	encntrid	=	f8
			4	schapptdttm	=	vc
			4	apptdttm	=	f8
			4	ptinrmdttm	=	vc
			4	surgeon		=	vc
			4	diff		=	i4
			4	role_meaning	=	vc
			4	state_meaning	=	vc
			4	slot_meaning	=	vc
			4	bookingid		=	f8
			4	scheventid		=	f8
			4   surgcaseid		=	f8
			4	eventid			=	f8
			4	printflg		=	i2
			4	surgflg			=	i2
			4	staffflg		=	i2
			4	ontimestart		=	C2
			4	ptname			=	vc
			4	mrn				=	vc
			4	fin				=	vc
			4	sex				=	vc
			4	age				=	vc
			4	delayreason		=	vc
			4	surgeon			=	vc
			4	casenumber		=	vc
			4	addtnlprsnl		=	vc
			4	caseprsnlcnt	=	i4
			4	caseprsnlqual[*]
				5	prsnlid		=	f8
				5	name		=	vc
				5	role		=	vc
				5	eventid		=	f8
 
 
) GO
 
cov_1st_case_start_times_rpt "mine", 2554023941.00, 1,1,"01-apr-2018 0", "15-apr-2018 23:59" go
 

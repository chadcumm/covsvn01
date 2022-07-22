drop program da2_sched_email_report go
create program da2_sched_email_report

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Public/All" = "Public"
with OUTDEV, PUBALL

; Declarations
declare stat = i4 with protect
declare index = i4 with protect
declare emc = i4 with protect
declare text = c8192 with protect
declare str = vc with protect
declare keystr = vc with protect
declare pubstat = i2 with protect, noconstant(1)

record sched (
	1 qual[*]
		2 sortkey = vc
		2 id = f8
		2 desc = vc
		2 item_name = vc
		2 item_id = f8
		2 item_desc = vc
		2 type_cd = f8
		2 personal = vc
		2 email[*]
			3 addr = vc
) with protect

record emailtemp (
	1 item[*]
		2 addr = vc
) with protect

declare uar_xml_parsestring( xmlString = vc, fileHandle = i4(ref) ) = i4
declare uar_xml_closefile( fileHandle = i4(ref) ) = null
declare uar_xml_getroot( fileHandle = i4(ref), nodeHandle = i4(ref) ) = i4
declare uar_xml_findchildnode( nodeHandle = i4(ref), nodeName = vc, childHandle = i4(ref) ) = i4
declare uar_xml_getchildcount( nodeHandle = i4(ref) ) = i4
declare uar_xml_getchildnode( nodeHandle = i4(ref), nodeNO = i4(ref), childNode = i4(ref) ) = i4
declare uar_xml_getnodename( nodeHandle = i4(ref) ) = vc
declare uar_xml_getattributevalue( nodeHandle = i4(ref), attrName = vc ) = vc

declare GetEmailRecipients( text = vc ) = i4

; RetrieveBatchSchedulesToRun
; execute da2_sched_email_report:dba "MINE" go

subroutine GetEmailRecipients( text )
	declare count = i4 with protect, noconstant(0)
	declare hxml = i4 with protect, noconstant(0)
	declare hroot = i4 with protect, noconstant(0)
	declare hadnl = i4 with protect, noconstant(0)
	declare hemails = i4 with protect, noconstant(0)
	declare haddr = i4 with protect, noconstant(0)
	declare stat = i4 with protect
	declare maxnode = i4 with protect
	declare index = i4 with protect
	declare addrtxt = c1024 with protect
	
	
	set stat = uar_xml_parsestring(nullterm(text), hxml)
	if (stat = 1)
		set stat = uar_xml_getroot(hxml, hroot)
		if (stat = 1)
			set stat = uar_xml_findchildnode(hroot, "additional", hadnl)
			if (stat = 1)
				set stat = uar_xml_findchildnode(hadnl, "emails", hemails)
				if (stat = 1)
					set maxnode = uar_xml_getchildcount(hemails)
					for (index = 0 to maxnode - 1)
						set stat = uar_xml_getchildnode(hemails, index, haddr)
						if (stat = 1 and "toaddress" = uar_xml_getnodename(haddr))
							set addrtxt = uar_xml_getattributevalue(haddr, "toaddress")
							if (textlen(addrtxt) > 0)
								set count = count + 1
								if (count > size(emailtemp->item, 5))
									set stat = alterlist(emailtemp->item, count + 9)
								endif
								set emailtemp->item[count]->addr = replace(
										replace(addrtxt, "&apos;", "'"), "&quot;", '"')
							endif
						endif
					endfor
				endif
			endif
		endif
		call uar_xml_closefile(hxml)
	endif
	
	return(count)
end

if ("ALL" = trim(cnvtupper($PUBALL)))
	set pubstat = 0
endif


select into "nl:"
	ds.da_batch_sched_id
	, ds.da_sched_type_flag
	, ds.da_batch_sched_desc
	, ds.item_type
	, ds.item_name
	, ds.batch_item_id
	, ds.process_seq
	, ds.batch_item_desc
	, text_len = blobgetlen(ap.long_text)
from ( ( select
			bs.da_batch_sched_id
			, bs.da_sched_type_flag
			, bs.da_batch_sched_desc
			, item_type = r.report_type_cd
			, item_name = r.report_name
			, item_owner = p.name_full_formatted
			, batch_item_id = br.da_batch_report_id
			, br.process_seq
			, batch_item_desc = br.da_batch_report_desc
			, br.additional_parameter_txt_id
		from da_batch_sched bs
		, ( inner join da_batch_report br on br.da_batch_sched_id = bs.da_batch_sched_id )
		, ( inner join da_report r on r.da_report_id = br.da_report_id )
		, ( left join person p on r.owner_prsnl_id != 0 and p.person_id = r.owner_prsnl_id )
		where bs.active_ind = 1
		and bs.da_sched_type_flag = 0
		and cnvtdatetime(curdate, curtime3) < bs.end_effective_dt_tm
		and br.active_ind = 1
		and ( pubstat = 0 or r.owner_prsnl_id = 0 )
		union (
		select
			bs.da_batch_sched_id
			, bs.da_sched_type_flag
			, bs.da_batch_sched_desc
			, item_type = q.query_type_cd
			, item_name = q.query_name
			, item_owner = p.name_full_formatted
			, batch_item_id = bq.da_batch_query_id
			, bq.process_seq
			, batch_item_desc = bq.da_batch_query_desc
			, bq.additional_parameter_txt_id
		from da_batch_sched bs
		, ( inner join da_batch_query bq on bq.da_batch_sched_id = bs.da_batch_sched_id )
		, ( inner join da_query q on q.da_query_id = bq.da_query_id )
		, ( left join person p on q.public_ind = 0 and p.person_id = q.owner_prsnl_id )
		where bs.active_ind = 1
		and bs.da_sched_type_flag = 1
		and cnvtdatetime(curdate, curtime3) < bs.end_effective_dt_tm
		and bq.active_ind = 1
		and ( pubstat = 0 or q.public_ind = 1 )
		)
	with sqltype("F8", "I2", "C100", "F8", "C255", "C100", "F8", "I4", "C100", "F8") ) ds )
, ( inner join long_text_reference ap on ap.long_text_id = ds.additional_parameter_txt_id )
head report
	index = 0
detail
	if (text_len > textlen(text))
		stat = memrealloc(text, 1, build("C", text_len))
	else
		text = ""
	endif
	stat = blobget(text, 0, ap.long_text)
	emc = GetEmailRecipients(text)
	if (emc > 0)
		keystr = cnvtupper(concat(trim(ds.item_name), char(1), trim(ds.da_batch_sched_desc),
				char(1), build(ds.process_seq)))
		stat = locatevalsort(index, 1, size(sched->qual, 5), keystr, sched->qual[index]->sortkey)
		index = abs(stat)
		if (size(sched->qual, 5) = 0)
			stat = alterlist(sched->qual, 1)
		else
			stat = movereclist(sched->qual, sched->qual, index, index, 1, true)
		endif
		index = index + 1
		sched->qual[index]->sortkey = keystr
		sched->qual[index]->id = ds.da_batch_sched_id
		sched->qual[index]->type_cd = ds.item_type
		sched->qual[index]->desc = ds.da_batch_sched_desc
		sched->qual[index]->item_name = ds.item_name
		sched->qual[index]->personal = ds.item_owner
		sched->qual[index]->item_id = ds.batch_item_id
		sched->qual[index]->item_desc = ds.batch_item_desc
		if (size(sched->qual[index]->email, 5) != emc)
			stat = alterlist(sched->qual[index]->email, emc)
		endif
		stat = movereclist(emailtemp->item, sched->qual[index]->email, 1, 1, emc, false)
	endif
with nocounter, rdbarrayfetch = 1

free set text

select into $OUTDEV
from dummyt
head report
	col 0 "Active DA2 Schedule Email Addresses"
	for (index = 1 to size(sched->qual, 5))
		if (index = 1 or sched->qual[index]->id != sched->qual[index - 1]->id)
			str = concat(sched->qual[index]->desc, " (id=", build(sched->qual[index]->id), ")")
			row +1 str
		endif
		str = concat("    ", sched->qual[index]->item_desc, " (id=", build(sched->qual[index]->item_id), ")")
		row +1 str
		if (textlen(sched->qual[index]->personal) > 0)
			str = concat("Personal ", trim(uar_get_code_display(sched->qual[index]->type_cd)),
					" for ", sched->qual[index]->personal, ": ", sched->qual[index]->item_name)
		else
			str = concat(trim(uar_get_code_display(sched->qual[index]->type_cd)),
					": ", sched->qual[index]->item_name)
		endif
		row +1
		col 4 str
		for (emc = 1 to size(sched->qual[index]->email, 5))
			row +1
			col 8 sched->qual[index]->email[emc]->addr
		endfor
	endfor
with nocounter, maxcol = 500

end
go


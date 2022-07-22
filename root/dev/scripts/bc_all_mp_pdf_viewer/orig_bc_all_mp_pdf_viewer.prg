drop program bc_all_mp_pdf_viewer go
create program bc_all_mp_pdf_viewer 

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


SET  _MEMORY_REPLY_STRING  =  BUILD2 (
"<html>" ,
	"<head>" ,
		'<META content="MPAGES_SVC_AUTH" name="discern"/>' ,
		'<script type="text/javascript">' ,
			"var requestSync = getXMLHttpRequest();" ,
			"function getMpage(url){" ,
				;"alert('before ajax call');" ,
				'requestSync.open("GET",url,false);' ,
				'window.location = "javascript:MPAGES_SVC_AUTH(requestSync)";' ,
				"requestSync.send(null);" ,
				;"alert(requestSync.status);" ,
				;"if (requestSync.status == 200) {" ,
				;	'document.getElementById("element1").innerHTML = requestSync.responseText;' ,
				;"}" ,
			"}" ,
			"function openMpage(url){" ,
				"alert('before ajax call');" ,
				'requestSync.open("GET",url,false);' ,
				'window.location = "javascript:MPAGES_SVC_AUTH(requestSync)";' ,
				"requestSync.send(null);" ,
				"alert(requestSync.status);" ,
				"if (requestSync.status == 200) {" ,
					~document.getElementById("pdf1").setAttribute('data', url);~ ,
					~document.getElementById("pdf1").setAttribute('visibility', 'visible');~,
				"}" ,
			"}" ,
		"</script>" ,
	"</head>" ,
	~<body onload="javascript:getMpage('~,
~http://phsacdeanp.cerncd.com/camm/b0783.phsa_cd.cerncd.com/service/mediaContent/{a6-a0-4e-5e-7a-0e-4b-20-b2-11-93-ac-fc-0c-2a-38}~,
		~')">~, 
    ~<object data='~,
~http://phsacdeanp.cerncd.com/camm/b0783.phsa_cd.cerncd.com/service/mediaContent/{a6-a0-4e-5e-7a-0e-4b-20-b2-11-93-ac-fc-0c-2a-38}~,
		~' id="pdf" width=100% height=100% type="application/pdf" visibility='hidden'>~,
    ~</object>~,
    ~<br><a href="javascript:getMpage('~,
~http://phsacdeanp.cerncd.com/camm/b0783.phsa_cd.cerncd.com/service/mediaContent/{a6-a0-4e-5e-7a-0e-4b-20-b2-11-93-ac-fc-0c-2a-38}~,
		~')">~,
		~link</a>~,
	"</body>" ,
"</html>"
)

end go

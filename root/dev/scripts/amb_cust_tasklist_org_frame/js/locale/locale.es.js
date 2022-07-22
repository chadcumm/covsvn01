var dateFormat=function(){var token=/d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,timezone=/\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,timezoneClip=/[^-+\dA-Z]/g,pad=function(val,len){val=String(val);
len=len||2;
while(val.length<len){val="0"+val;
}return val;
};
return function(date,mask,utc){var dF=dateFormat;
if(arguments.length==1&&Object.prototype.toString.call(date)=="[object String]"&&!/\d/.test(date)){mask=date;
date=undefined;
}date=date?new Date(date):new Date;
if(isNaN(date)){throw SyntaxError("invalid date");
}mask=String(dF.masks[mask]||mask||dF.masks["default"]);
if(mask.slice(0,4)=="UTC:"){mask=mask.slice(4);
utc=true;
}var _=utc?"getUTC":"get",d=date[_+"Date"](),D=date[_+"Day"](),m=date[_+"Month"](),y=date[_+"FullYear"](),H=date[_+"Hours"](),M=date[_+"Minutes"](),s=date[_+"Seconds"](),L=date[_+"Milliseconds"](),o=utc?0:date.getTimezoneOffset(),flags={d:d,dd:pad(d),ddd:dF.i18n.dayNames[D],dddd:dF.i18n.dayNames[D+7],m:m+1,mm:pad(m+1),mmm:dF.i18n.monthNames[m],mmmm:dF.i18n.monthNames[m+12],yy:String(y).slice(2),yyyy:y,h:H%12||12,hh:pad(H%12||12),H:H,HH:pad(H),M:M,MM:pad(M),s:s,ss:pad(s),l:pad(L,3),L:pad(L>99?Math.round(L/10):L),t:H<12?"a":"p",tt:H<12?"am":"pm",T:H<12?"A":"P",TT:H<12?"AM":"PM",Z:utc?"UTC":(String(date).match(timezone)||[""]).pop().replace(timezoneClip,""),o:(o>0?"-":"+")+pad(Math.floor(Math.abs(o)/60)*100+Math.abs(o)%60,4),S:["th","st","nd","rd"][d%10>3?0:(d%100-d%10!=10)*d%10]};
return mask.replace(token,function($0){return $0 in flags?flags[$0]:$0.slice(1,$0.length-1);
});
};
}();
dateFormat.masks={"default":"ddd mmm dd yyyy HH:MM:ss",shortDate:"m/d/yy",shortDate2:"mm/dd/yyyy",shortDate3:"mm/dd/yy",shortDate4:"mm/yyyy",shortDate5:"yyyy",mediumDate:"mmm d, yyyy",longDate:"mmmm d, yyyy",fullDate:"dddd, mmmm d, yyyy",shortTime:"h:MM TT",mediumTime:"h:MM:ss TT",longTime:"h:MM:ss TT Z",militaryTime:"HH:MM",isoDate:"yyyy-mm-dd",isoTime:"HH:MM:ss",isoDateTime:"yyyy-mm-dd'T'HH:MM:ss",isoUtcDateTime:"UTC:yyyy-mm-dd'T'HH:MM:ss'Z'",longDateTime:"mm/dd/yyyy h:MM:ss TT Z",longDateTime2:"mm/dd/yy HH:MM",longDateTime3:"mm/dd/yyyy HH:MM",longDateTime4:"mm/dd/yy hh:MM TT",shortDateTime:"mm/dd h:MM TT"};
dateFormat.i18n={dayNames:["Sun","Mon","Tue","Wed","Thu","Fri","Sat","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],monthNames:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","January","February","March","April","May","June","July","August","September","October","November","December"]};
Date.prototype.format=function(mask,utc){
if(utc = "") {
	return "";
} else {
	return dateFormat(this,mask,utc);
}
};
Date.prototype.setISO8601=function(string){
if(string != "") {
	var regexp="([0-9]{4})(-([0-9]{2})(-([0-9]{2})(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(.([0-9]+))?)?(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
	var d=string.match(new RegExp(regexp));
	var offset=0;
	var date=new Date(d[1],0,1);
	if(d[3]){date.setMonth(d[3]-1);
	}if(d[5]){date.setDate(d[5]);
	}if(d[7]){date.setHours(d[7]);
	}if(d[8]){date.setMinutes(d[8]);
	}if(d[10]){date.setSeconds(d[10]);
	}if(d[12]){date.setMilliseconds(Number("0."+d[12])*1000);
	}if(d[14]){offset=(Number(d[16])*60)+Number(d[17]);
	offset*=((d[15]=="-")?1:-1);
	}offset-=date.getTimezoneOffset();
	time=(Number(date)+(offset*60*1000));
	this.setTime(Number(time));
}
};


var amb_i18n = {
	ABN: "ABN",
	ABN_TEMPLATE: "Plantilla ABN",
	ABN_SELECT: "Seleccione una plantilla ABN",  
	ACCESSION: "Solicitud",  
	ACCESSION_NUM: "Número de solicitud",
	ACTIONS_NOT_AVAIL: "Acciones no disponibles",  
	ACTIVE: "Activo",
	AGE: "Edad",
	ALERT_DATE: "Fecha de alerta",
	ALERT_STATE: "Estado de alerta",
	ALL: "Todo",
	ALL_FORMS: "Todos los formularios...",  
	ALLERGIES: "Alergias",
	BY_DATE: "Por fecha",
	CANCEL: "Cancelar",
	CHART_DONE: "Documentación terminada",
	CHART_FORMS: "Formularios de historia clínica",
	CHARTED_DONE_REFRESH: "Documentación terminada (actualice)",  
	CHARTED_NOT_DONE_REFRESH: "Documentación no terminada (actualice)",  
	CLEAR: "Borrar",
	ABN_TOOLTIP: "Haga clic para ver detalles de ABN e imprimir",
	CLOSE: "Cerrar",
	COLLECT_SPEC: "Tomar muestra",  
	COLLECTED_BY: "Muestra tomada por",
	COLLECTED_DATE: "Fecha de toma",
	COLLECTED_IN_OFFICE: "Tomada en consulta",
	COLLECTED_OUT_OFFICE: "Tomada fuera de la consulta",
	COLLECTION_DETAILS: "Detalles de toma",
	COLLECTED_IN_OFFICE_TOOLTIP: "Toma realizada en la consulta",
	COLLECTED_OUT_OFFICE_TOOLTIP: "Muestra tomada en el centro de servicio del laboratorio (PSC)",
	COMPLETE: "Completar",
	CONTAINER: "Contenedor",
	CONTAINER_ON_TRANS_LIST: "El contenedor ya está en una lista de transmisión. Quítelo de la lista actual para transmitir utilizando esta página.",  
	CONTAINER_EXIST_LIST: "Contenedor existente",
	CREATE: "Crear",  
	DESCRIPTION: "Descripción",
	DESELECT_ALL: "Deseleccionar todo",
	DIAGNOSIS: "Diagnóstico",
	DISCONTINUED: "Interrumpido",
	DISPLAY: "Visualizar",
	DOB: "Fecha de nacimiento",
	DONE: "Listo",
	DONE_WITH_DATE_TIME: "Terminado (con fecha/hora)",
	ERROR: "Error",
	FAILED_TO: "Error al",
	FIRST_LOGIN_SENT1: "Para visualizar tareas, seleccione una ubicación del menú desplegable situado en el cuadrante de la esquina superior derecha. El sistema guardará la última ubicación seleccionada y dicha ubicación se mostrará de manera predeterminada la próxima vez que acceda a la lista de tareas.", //new
	FIRST_LOGIN_SENT2: "Tras seleccionar la ubicación, seleccione el botón actualizar para cargar las tareas en una vista en la que aparezcan de manera predeterminada las tareas de las últimas semanas. Se puede cambiar el intervalo de fechas de las tareas visualizadas, sin embargo, el sistema limitará la recuperación de datos a un período de tiempo de un mes por razones de rendimiento del sistema.", //new
	FROM: "desde",
	GENDER: "Sexo",
	HELP_PAGE: "Página de ayuda",
	HIDE_ADV_FILTERS: "Ocultar filtros avanzados",
	ID: "Id",  
	LAB: "Laboratorio",
	LAB_RDY_TRANS: "El laboratorio está listo para transmitir",  
	LIST_ALREADY_TRANS: "La lista ya se ha transmitido, no se puede quitar de la lista. Pruebe a actualizar la página.",  
	LIST_NUM: "Lista nº",  
	LOADING: "Cargando",
	LOCATION: "Ubicación",
	LOGIN_TO_SPEC_LOC: "Inicie sesión en ubicación de muestras",  
	MRN: "NºHªC",
	NAME: "Nombre",
	NO: "No",  
	NO_DEFAULT_SPEC_LOC: "no hay ninguna ubicación de muestras predeterminada",
	NO_LAB_ASSOC: "No existen ubicaciones de laboratorio asociadas a la indicación ni a su cuenta. Póngase en contacto con el servicio de asistencia técnica.",  
	NO_LAB_LOC: "No hay ubicaciones de laboratorio", 
	NO_RESULTS: "No se encuentran resultados",
	NO_RELATED_LOC: "No se encontraron ubicaciones relacionadas", 
	NOT_ALLOW_TRANS: "No tiene autorización para transmitir",  
	NOT_DONE: "No realizado",
	NOT_TRANSMITTED: "No transmitido",  
	OF: "de",  
	OK: "Aceptar",   
	ON: "el",
	OPEN_PT_CHART: "Abrir historia clínica",
	OPEN_CHARTED_FORM: "Abrir formulario documentado",
	ORDER: "Indicación",
	ORDER_COMM_DETECT: "Se ha detectado un comentario de indicación",
	ORDER_COMMS: "Comentarios de indicación",
	ORDER_DATE: "Fecha de indicación",  
	ORDER_DETAILS: "Detalles de indicación",
	ORDER_INFO: "Información de la indicación",
	ORDER_ID: "Id. de indicación",  
	ORDER_NOT_TRANS: "Indicación no transmitida correctamente. Intente retransmitir.",  
	ORDER_PLAN: "Plan de indicación",  
	ORDER_RESULTS: "Resultados de indicación",  
	ORDER_TASKS: "Tareas de indicación",
	ORDERED: "Indicada",
	ORDERED_AS: "Indicado como",
	ORDERED_DATE: "Fecha de indicación",
	ORDERING_ID: "Id. de indicación",
	ORDERING_PROV: "Profesional asistencial",
	PAGE: "Página",
	PAGE_TIMER: "Temporizador de carga de página",
	PARTIAL_RESULTS: "Resultados parciales recibidos",
	PATIENT: "Paciente",
	PATIENT_DETAILS: "Detalles del paciente",
	PATIENT_NAME: "Nombre del paciente",   
 	PATIENT_SNAPSHOT: "Instantánea del paciente",
	PCP: "Profesional asistencial",
	PENDING_RESULTS: "Resultados pendientes",  
	PHONE_NUM: "Números de teléfono",
	PRINT_LABELS: "Imprimir etiqueta(s)",
	PRINT_PICKUP: "Imprimir Lista(s) de recogida",
	PRINT_REQ: "Imprimir solicitudes",
	PRN: "A demanda",     //like a prn task
	REASON: "Razón",
	REASON_COMM: "Comentario de razón",
	REF_LAB: "Laboratorio de referencia",
	REF_LAB_INFO: "Información del laboratorio de referencia",
	REFRESH_LIST: "Actualizar lista",
	REMOVE: "Quitar",  
	REMOVE_FROM_LIST: "Quitar de la lista",
	REQUEST_TEXT: "Solicitar texto",
	RESCHEDULE: "Reprogramar",
	RESCHEDULE_TASK: "Reprogramar tarea",
	RESCHEDULED_TO: "Reprogramar para",
	RESCHEDULE_REFRESH: "Reprogramado (actualice)",  
	RESULT: "Resultado",  
	RESULT_DATE: "Fecha del resultado",  
	RESULT_STATUS: "Estado del resultado",
	RESULTS_REC: "Resultados recibidos",
	RETRANSMIT: "Retransmitir",
	SAVE_LOC_PREF: "Guardar una preferencia de ubicación", 
	SAVE_TASK_TYPE_TOOLTIP: "Guardar Tipos de tarea seleccionados como predeterminados",
	SEC: "seg.", //as in seconds
	SELECT: "Seleccionar",  
	SELECT_ALL: "Seleccionar todo",
	SELECT_LAB_LOC: "Seleccionar laboratorio",
	SELECT_TO_LOCATION: "Seleccionar ubicación de destino",  
	SELECT_STATUS: "Seleccionar estados",  
	SELECT_PROV: "Seleccionar profesional asistencial",  
	SELECT_TYPE: "Seleccionar tipos",  
	SELECT_UNCHART: "Seleccionar tareas para eliminar de la documentación",  
	SELECTED: "seleccionado",
	SELECTED_FILTERS_NO_LABS: "Los filtros seleccionados no muestran ningún análisis",
	SELECTED_FILTERS_NO_TASKS: "Los filtros seleccionados no muestran ninguna tarea",
	SELECTED_REQ: "Peticiones seleccionadas",
	SELECTED_ACC: "Solicitudes seleccionadas",
	SHOW_ADV_FILTERS: "Mostrar filtros avanzados",
	SPEC_LOGIN_ERROR: "No se ha definido la ubicación de muestra clínica recibida predeterminada para una muestra. No se pudo iniciar sesión en muestras. Póngase en contacto con el servicio de asistencia técnica de Cerner.",  
	SPEC_NO_LAB_LOC: "La muestra no tiene una ubicación de laboratorio. Póngase en contacto con el servicio de asistencia técnica.",  
	SPEC_NOT_LOGIN_LOC_TOOLTIP: "La muestra no está en la ubicación de laboratorio correcta. Póngase en contacto con el servicio de asistencia técnica si al intentar volver a iniciar sesión no funciona.",  
	SPEC_NOT_LOGIN: "No se inició sesión en muestra",   
	STATUS: "Estado",
	SYSTEM_TRANS_INFO: "Información de transmisión del sistema",
	TASK: "Tarea",
	TASK_COMM: "Comentario de tarea",
	TASK_COMM_DETECT: "Se ha detectado un comentario de tarea",
	TASK_COMMS: "Comentarios de tarea",
	TASK_COMM_REFRESH: "Comentario de tarea agregado/modificado (actualice)",  
	TASK_DATE: "Fecha de tarea",
	TASK_DETAILS: "Detalles de la tarea",
	TASK_DISCONTINUED: "Tarea interrumpida",  
	TASK_DONE: "Tarea realizada",  
	TASK_IN_PROCESS: "Tarea en proceso",  
	TASK_NOT_DONE: "Tarea no realizada",  
	TASK_LIST: "Lista de tareas",
	TASK_LIST_INFO: "Información de lista de tareas",
	TASK_ORDER: "Tarea/Indicación",
	TASK_NOT_AVAIL: "Tarea no disponible",  
	THIS_VISIT: "Esta visita",
	TO: "a",
	TOTAL_ITEMS: "elementos totales",
	TRANSFERRED: "transferido", 
	TRANSMIT: "Transmisión",
	TRANSMIT_DATE: "Fecha de transmisión",
	TRANSMIT_DETAILS: "Detalles de transmisión",
	TRANSMIT_LIST: "Lista de transmisión",
	TRANSMITTED: "Transmitido",
	TRANSMITTED_BY: "Transmitido por",
	TRANSMITTING: "Transmitiendo",
	TYPE: "Tipo",
	UNABLE_ESO_ERROR: "No se puede crear el mensaje ESO. Retransmita la lista.",  
	UNCHART: "Deshacer documentación",
	UNCHART_COMM: "Deshacer documentación de comentario",
	UNCHART_TASK: "Deshacer documentación de tarea",
	UNCHART_REFRESH: "No documentado (actualice)",  
	UPDATE: "Actualizar",
	VALUE: "Valor",  
	VIEW: "Ver",
	VIEW_PT_DETAILS: "Ver detalles de paciente",
	VIEW_TASK_DETAILS: "Ver detalles de tarea",
	VISIT_DATE: "Fecha visita",
	VISIT_DATE_LOC: "Fecha/ubicación de visita",
	VISIT_DIAG: "Diagnóstico de visita",
	VISIT_LOC: "Ubicación de visita",
	VISIT_REQ: "Peticiones de visita",
	VISIT_ACC: "Solicitudes de visita",  
	YES: "Sí"  
};
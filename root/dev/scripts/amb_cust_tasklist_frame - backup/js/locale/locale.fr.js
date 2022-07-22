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
	ABN_TEMPLATE: "Modèle ABN",
	ABN_SELECT: "Sélectionner un modèle ABN",  
	ACCESSION: "Enregistrement",  
	ACCESSION_NUM: "Numéro d&#39;enregistrement",
	ACTIONS_NOT_AVAIL: "Actions non disponibles",  
	ACTIVE: "Actif",
	AGE: "Âge",
	ALERT_DATE: "Date de l&#39;alerte",
	ALERT_STATE: "État d&#39;alerte",
	ALL: "Tous",
	ALL_FORMS: "Tous les formulaires",  
	ALLERGIES: "Allergies",
	BY_DATE: "Par date",
	CANCEL: "Annuler",
	CHART_DONE: "Documentation terminée",
	CHART_FORMS: "Formulaires de dossier",
	CHARTED_DONE_REFRESH: "Documentation terminée (Veuillez actualiser)",  
	CHARTED_NOT_DONE_REFRESH: "Documentation non terminée (Veuillez actualiser)",  
	CLEAR: "Effacer",
	ABN_TOOLTIP: "Cliquer pour afficher les détails ABN et imprimer",
	CLOSE: "Fermer",
	COLLECT_SPEC: "Prélever un échantillon",  
	COLLECTED_BY: "Prélevé par",
	COLLECTED_DATE: "Date de prélèvement",
	COLLECTED_IN_OFFICE: "Prélevé au cabinet",
	COLLECTED_OUT_OFFICE: "Prélevé hors du cabinet",
	COLLECTION_DETAILS: "Informations de prélèvement",
	COLLECTED_IN_OFFICE_TOOLTIP: "Prélèvement effectué au cabinet",
	COLLECTED_OUT_OFFICE_TOOLTIP: "Échantillon prélevé au centre de prélèvement/laboratoire",
	COMPLETE: "Terminer",
	CONTAINER: "Récipient",
	CONTAINER_ON_TRANS_LIST: "Le récipient figure déjà sur une liste de transmission. Veuillez le supprimer de la liste actuelle afin de le transmettre à l&#39;aide de cette page.",  
	CONTAINER_EXIST_LIST: "Récipient sur la liste existante",
	CREATE: "Créer",  
	DESCRIPTION: "Description",
	DESELECT_ALL: "Désélectionner tout",
	DIAGNOSIS: "Diagnostic",
	DISCONTINUED: "Arrêté",
	DISPLAY: "Affichage",
	DOB: "Date de naissance",
	DONE: "Effectué",
	DONE_WITH_DATE_TIME: "Complété (avec date/heure)",
	ERROR: "Erreur",
	FAILED_TO: "Échec de",
	FIRST_LOGIN_SENT1: "Pour afficher les tâches, sélectionnez un emplacement dans le menu déroulant des emplacements situé en haut à droite. Votre dernier emplacement sélectionné sera enregistré et appliqué par défaut la prochaine fois que la liste de tâches sera ouverte.", //new
	FIRST_LOGIN_SENT2: "Une fois l&#39;emplacement sélectionné, cliquez sur le bouton Actualiser pour charger les tâches dans la vue et afficher par défaut les tâches des dernières semaines. La période des tâches affichées peut être modifiée, cependant la période de récupération est limitée à 1 mois pour des raisons de performance système.", //new
	FROM: "de",
	GENDER: "Sexe",
	HELP_PAGE: "Page d&#39;aide",
	HIDE_ADV_FILTERS: "Masquer les filtres avancés",
	ID: "ID",  
	LAB: "Lab",
	LAB_RDY_TRANS: "Le laboratoire est prêt pour la transmission.",  
	LIST_ALREADY_TRANS: "La liste a déjà été transmise. Impossible de supprimer de la liste. Essayez d&#39;actualiser la page.",  
	LIST_NUM: "Liste n° ",  
	LOADING: "Chargement",
	LOCATION: "Emplacement",
	LOGIN_TO_SPEC_LOC: "Se connecter à l&#39;emplacement de prélèvement",  
	MRN: "IPP",
	NAME: "Nom",
	NO: "Non",  
	NO_DEFAULT_SPEC_LOC: "Pas d&#39;emplacement de prélèvement par défaut",
	NO_LAB_ASSOC: "Aucun emplacement de laboratoire n&#39;est associé à la prescription ou à votre compte. Veuillez contacter le service de support.",  
	NO_LAB_LOC: "Aucun emplacement de laboratoire", 
	NO_RESULTS: "Aucun résultat n&#39;a été trouvé.",
	NO_RELATED_LOC: "Aucun emplacement lié n&#39;a été trouvé.", 
	NOT_ALLOW_TRANS: "Transmission non autorisée",  
	NOT_DONE: "Non effectué",
	NOT_TRANSMITTED: "Non transmis",  
	OF: "sur",  
	OK: "OK",   
	ON: "le",
	OPEN_PT_CHART: "Ouvrir un dossier patient",
	OPEN_CHARTED_FORM: "Ouvrir le formulaire documenté",
	ORDER: "Prescription",
	ORDER_COMM_DETECT: "Commentaire de prescription identifié",
	ORDER_COMMS: "Commentaires de prescription",
	ORDER_DATE: "Date de la prescription",  
	ORDER_DETAILS: "Détails de prescription",
	ORDER_INFO: "Informations sur la prescription",
	ORDER_ID: "ID de prescription",  
	ORDER_NOT_TRANS: "La prescription n&#39;a pas été transmise. Tentative de retransmission.",  
	ORDER_PLAN: "Protocole de prescription",  
	ORDER_RESULTS: "Résultats de prescription",  
	ORDER_TASKS: "Tâches de prescription",
	ORDERED: "Prescrit",
	ORDERED_AS: "Prescrit comme",
	ORDERED_DATE: "Date de prescription",
	ORDERING_ID: "ID de prescription",
	ORDERING_PROV: "Soignant prescripteur",
	PAGE: "Page",
	PAGE_TIMER: "Minuteur de chargement de page",
	PARTIAL_RESULTS: "Résultats partiels reçus",
	PATIENT: "Patient",
	PATIENT_DETAILS: "Informations sur le patient",
	PATIENT_NAME: "Nom du patient",   
 	PATIENT_SNAPSHOT: "Vue instantanée du patient",
	PCP: "Médecin traitant",
	PENDING_RESULTS: "Résultats en attente",  
	PHONE_NUM: "Numéros de téléphone",
	PRINT_LABELS: "Imprimer les étiquettes",
	PRINT_PICKUP: "Imprimer la ou les listes de sélection",
	PRINT_REQ: "Imprimer les demandes",
	PRN: "PRN",     //like a prn task
	REASON: "Motif",
	REASON_COMM: "Commentaires sur le motif",
	REF_LAB: "Laboratoire de référence",
	REF_LAB_INFO: "Informations sur le laboratoire de référence",
	REFRESH_LIST: "Actualiser la liste",
	REMOVE: "Supprimer",  
	REMOVE_FROM_LIST: "Supprimer de la liste",
	REQUEST_TEXT: "Demander le texte",
	RESCHEDULE: "Replanifier",
	RESCHEDULE_TASK: "Tâche de replanification",
	RESCHEDULED_TO: "Replanifier le",
	RESCHEDULE_REFRESH: "Replanifié (Veuillez actualiser)",  
	RESULT: "Résultat",  
	RESULT_DATE: "Date du résultat",  
	RESULT_STATUS: "Statut du résultat",
	RESULTS_REC: "Résultats reçus",
	RETRANSMIT: "Retransmettre",
	SAVE_LOC_PREF: "Enregistrer une préférence d&#39;emplacement", 
	SAVE_TASK_TYPE_TOOLTIP: "Enregistrer les types de tâches sélectionnées comme tâches par défaut",
	SEC: "s", //as in seconds
	SELECT: "Sélectionner",  
	SELECT_ALL: "Sélectionner tout",
	SELECT_LAB_LOC: "Sélectionner le laboratoire",
	SELECT_TO_LOCATION: "Sélectionner l&#39;emplacement de destination",  
	SELECT_STATUS: "Sélectionner les statuts",  
	SELECT_PROV: "Sélectionner un soignant",  
	SELECT_TYPE: "Sélectionner les types",  
	SELECT_UNCHART: "Sélectionner les tâches à supprimer",  
	SELECTED: "sélectionné",
	SELECTED_FILTERS_NO_LABS: "Les filtres sélectionnés n&#39;affichent aucun laboratoire.",
	SELECTED_FILTERS_NO_TASKS: "Les filtres sélectionnés n&#39;affichent aucune tâche.",
	SELECTED_REQ: "Demandes sélectionnées",
	SELECTED_ACC: "Enregistrement(s) sélectionné(s)",
	SHOW_ADV_FILTERS: "Afficher les filtres avancés",
	SPEC_LOGIN_ERROR: "Emplacement de réception du prélèvement en clinique par défaut non défini pour un prélèvement. Impossible de consigner le prélèvement. Veuillez contacter le service de support Cerner.",  
	SPEC_NO_LAB_LOC: "Le prélèvement n&#39;a pas d&#39;emplacement de laboratoire. Veuillez contacter le service de support.",  
	SPEC_NOT_LOGIN_LOC_TOOLTIP: "Le prélèvement n&#39;est pas dans le bon emplacement de laboratoire. Veuillez contacter le service de support si la tentative de reconnexion échoue.",  
	SPEC_NOT_LOGIN: "Prélèvement non consigné",   
	STATUS: "Statut",
	SYSTEM_TRANS_INFO: "Information sur la transmission système",
	TASK: "Tâche",
	TASK_COMM: "Commentaire de tâche",
	TASK_COMM_DETECT: "Commentaire de tâche identifié",
	TASK_COMMS: "Commentaires de tâche",
	TASK_COMM_REFRESH: "Commentaire de tâche ajouté/modifié (Veuillez actualiser)",  
	TASK_DATE: "Date de la tâche",
	TASK_DETAILS: "Détails de tâche",
	TASK_DISCONTINUED: "Tâche interrompue",  
	TASK_DONE: "Tâche effectuée",  
	TASK_IN_PROCESS: "Tâche en cours",  
	TASK_NOT_DONE: "Tâche non effectuée",  
	TASK_LIST: "Liste des tâches",
	TASK_LIST_INFO: "Informations sur la liste des tâches",
	TASK_ORDER: "Tâche/Prescription",
	TASK_NOT_AVAIL: "Tâche non disponible",  
	THIS_VISIT: "Séjour en cours",
	TO: "vers",
	TOTAL_ITEMS: "Nombre total d&#39;éléments",
	TRANSFERRED: "Transféré", 
	TRANSMIT: "Transmettre",
	TRANSMIT_DATE: "Date de transmission",
	TRANSMIT_DETAILS: "Détails de transmission",
	TRANSMIT_LIST: "Liste de transmission",
	TRANSMITTED: "Transmis",
	TRANSMITTED_BY: "Transmis par",
	TRANSMITTING: "Transmission",
	TYPE: "Type",
	UNABLE_ESO_ERROR: "Impossible de créer le message ESO. Veuillez retransmettre la liste.",  
	UNCHART: "Supprimer la documentation",
	UNCHART_COMM: "Supprimer le commentaire",
	UNCHART_TASK: "Supprimer la tâche",
	UNCHART_REFRESH: "Supprimé (Veuillez actualiser)",  
	UPDATE: "Mettre à jour",
	VALUE: "Valeur",  
	VIEW: "Vue",
	VIEW_PT_DETAILS: "Afficher les détails du patient",
	VIEW_TASK_DETAILS: "Afficher les détails de la tâche",
	VISIT_DATE: "Dt de consult.",
	VISIT_DATE_LOC: "Date/Emplacement de la consultation",
	VISIT_DIAG: "Diagnostic de la consultation",
	VISIT_LOC: "Emplacement de la consultation",
	VISIT_REQ: "Demandes de la consultation",
	VISIT_ACC: "Enregistrement(s) de la consultation",  
	YES: "Oui"  
};
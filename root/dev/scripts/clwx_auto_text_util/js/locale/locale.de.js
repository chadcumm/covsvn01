!function(e){var n={};function t(r){if(n[r])return n[r].exports;var i=n[r]={i:r,l:!1,exports:{}};return e[r].call(i.exports,i,i.exports,t),i.l=!0,i.exports}t.m=e,t.c=n,t.d=function(e,n,r){t.o(e,n)||Object.defineProperty(e,n,{enumerable:!0,get:r})},t.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},t.t=function(e,n){if(1&n&&(e=t(e)),8&n)return e;if(4&n&&"object"==typeof e&&e&&e.__esModule)return e;var r=Object.create(null);if(t.r(r),Object.defineProperty(r,"default",{enumerable:!0,value:e}),2&n&&"string"!=typeof e)for(var i in e)t.d(r,i,function(n){return e[n]}.bind(null,i));return r},t.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(n,"a",n),n},t.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},t.p="",t(t.s=377)}({377:function(e,n){var t,r,i,o,a=(t=/d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,r=/\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,i=/[^-+\dA-Z]/g,o=function(e,n){for(e=String(e),n=n||2;e.length<n;)e="0"+e;return e},function(e,n,u){var s=a;if(1!=arguments.length||"[object String]"!=Object.prototype.toString.call(e)||/\d/.test(e)||(n=e,e=void 0),e=e?new Date(e):new Date,isNaN(e))throw SyntaxError("invalid date");"UTC:"==(n=String(s.masks[n]||n||s.masks.default)).slice(0,4)&&(n=n.slice(4),u=!0);var m=u?"getUTC":"get",d=e[m+"Date"](),h=e[m+"Day"](),l=e[m+"Month"](),c=e[m+"FullYear"](),y=e[m+"Hours"](),T=e[m+"Minutes"](),A=e[m+"Seconds"](),g=e[m+"Milliseconds"](),M=u?0:e.getTimezoneOffset(),S={d:d,dd:o(d),ddd:s.i18n.dayNames[h],dddd:s.i18n.dayNames[h+7],m:l+1,mm:o(l+1),mmm:s.i18n.monthNames[l],mmmm:s.i18n.monthNames[l+12],yy:String(c).slice(2),yyyy:c,h:y%12||12,hh:o(y%12||12),H:y,HH:o(y),M:T,MM:o(T),s:A,ss:o(A),l:o(g,3),L:o(g>99?Math.round(g/10):g),t:y<12?"a":"p",tt:y<12?"am":"pm",T:y<12?"A":"P",TT:y<12?"AM":"PM",Z:u?"UTC":(String(e).match(r)||[""]).pop().replace(i,""),o:(M>0?"-":"+")+o(100*Math.floor(Math.abs(M)/60)+Math.abs(M)%60,4),S:["th","st","nd","rd"][d%10>3?0:(d%100-d%10!=10)*d%10]};return n.replace(t,(function(e){return e in S?S[e]:e.slice(1,e.length-1)}))});a.masks={default:"ddd dd.mm.yyyy HH:MM:ss",shortDate:"d.m.yy",shortDate2:"dd.mm.yyyy",shortDate3:"dd.mm.yy",shortDate4:"mm.yyyy",shortDate5:"yyyy",mediumDate:"d. mmm. yyyy",longDate:"d. mmmm yyyy",fullDate:"dddd, d. mmmm yyyy",shortTime:"HH:MM",mediumTime:"HH:MM:ss",longTime:"HH:MM:ss Z",militaryTime:"HH:MM",isoDate:"yyyy-mm-dd",isoTime:"HH:MM:ss",isoDateTime:"yyyy-mm-dd'T'HH:MM:ss",isoUtcDateTime:"UTC:yyyy-mm-dd'T'HH:MM:ss'Z'",longDateTime:"dd.mm.yyyy HH:MM:ss Z",longDateTime2:"dd.mm.yy HH:MM",longDateTime3:"dd.mm.yyyy HH:MM",shortDateTime:"dd.mm. HH:MM"},a.i18n={dayNames:["SO","MO","DI","MI","DO","FR","SA","Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"],monthNames:["Jan","Feb","M�r","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez","Januar","Februar","M�rz","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"]},Date.prototype.format=function(e,n){return""?"":a(this,e,"")},Date.prototype.setISO8601=function(e){if(""!=e){var n=e.match(new RegExp("([0-9]{4})(-([0-9]{2})(-([0-9]{2})(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(.([0-9]+))?)?(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?")),t=0,r=new Date(n[1],0,1);n[3]&&r.setMonth(n[3]-1),n[5]&&r.setDate(n[5]),n[7]&&r.setHours(n[7]),n[8]&&r.setMinutes(n[8]),n[10]&&r.setSeconds(n[10]),n[12]&&r.setMilliseconds(1e3*Number("0."+n[12])),n[14]&&(t=60*Number(n[16])+Number(n[17]),t*="-"==n[15]?1:-1),t-=r.getTimezoneOffset(),time=Number(r)+60*t*1e3,this.setTime(Number(time))}},window.i18n={SEARCHUSERDEFAULT:"Benutzer suchen ",AUTOTEXTSEARCH:"AutoText suchen",USERSELECTIONMSG:"Vor der Suche nach AutoText muss ein Benutzer ausgewählt werden.",NOUSER:"Kein Benutzer ausgewählt",NOPHRASE:"Es wurden keine übereinstimmenden AutoText-Sätze gefunden.",MYAUTO:"Mein AutoText-Archiv",MANAGEAUTO:"AutoText verwalten",ABBERV:"Abkürzung",DESC:"Beschreibung",UPDT:"Datum aktualisieren",PAGE:"Seite {0} von {1}",SELECTALL:"Alle auswählen",COPY:"Kopieren",DEL:"Löschen",PROCESSING:"In Bearbeitung...",DELAUTOTXT:"AutoText löschen",COPYAUTOTXT:"AutoText kopieren",RENABBERV:"Meine Abkürzung",RENDESC:"Meine Beschreibung",LOGOUTTITLE:"Abmeldungshinweis",LOGOUT:"Abmelden",YES:"Ja",NO:"Nein",CLOSE:"Schließen",CANCEL:"Abbrechen",DUPLICATEABBERV:"Einige Abkürzungen sind bereits in Ihrem Archiv vorhanden. Benennen Sie Abkürzungen um, um sie als neue Abkürzungen zu speichern, oder fahren Sie ohne Umbenennen fort, um derzeitigen AutoText zu überschreiben.",PREVIEWTITLE:"AutoText-Vorschau",DEFAULTPREVIEW:"Keine Vorschau verfügbar. Wählen Sie einen Satz für die Vorschau aus.",LOGOUTTEXT:"Melden Sie sich aus der Anwendung ab, damit alle AutoText-Änderungen übernommen werden können. Klicken Sie zum Weiterarbeiten auf dieser Seite auf 'Abbrechen'.",CONFIRMHEADER:"Überschreiben bestätigen",CONFIRMTEXT:"Sind Sie sicher, dass Sie {0} AutoText-Sätze überschreiben möchten?",ERROR:"Fehler",ERRORDELMODALFAIL:"Fehler: Folgende AutoText-Sätze konnten nicht aus Ihrem Archiv gelöscht werden.",ERRORCOPYMODALFAIL:"Fehler: Folgende AutoText-Sätze konnten nicht in Ihr Archiv kopiert werden.",DELMODALHEADER:"Warnung: Wenn Sie mit dem Löschen fortfahren, werden folgende AutoText-Sätze aus Ihrem Archiv entfernt.",COPYMODALHEADER:"Wenn Sie mit dem Kopieren fortfahren, werden Ihrem Archiv die folgenden AutoText-Sätze hinzugefügt.",SCRIPTERROR:"Daten konnten nicht abgerufen werden.",PARSEERROR:"Daten konnten nicht abgerufen werden. In der Antwort wurde ein unzulässiges Zeichen gefunden.",NOUSERMATCH:"Ihre Suche nach '{0}' ergab keine Treffer. Ändern Sie die Suchkriterien und versuchen Sie es erneut."}}});
//# sourceMappingURL=locale.de.js.map
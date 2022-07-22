/*
http://www.JSON.org/json2.js
2010-03-20

Public Domain.

NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

See http://www.JSON.org/js.html


This code should be minified before deployment.
See http://javascript.crockford.com/jsmin.html

USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
NOT CONTROL.


This file creates a global JSON object containing two methods: stringify
and parse.

JSON.stringify(value, replacer, space)
value       any JavaScript value, usually an object or array.

replacer    an optional parameter that determines how object
values are stringified for objects. It can be a
function or an array of strings.

space       an optional parameter that specifies the indentation
of nested structures. If it is omitted, the text will
be packed without extra whitespace. If it is a number,
it will specify the number of spaces to indent at each
level. If it is a string (such as '\t' or '&nbsp;'),
it contains the characters used to indent at each level.

This method produces a JSON text from a JavaScript value.

When an object value is found, if the object contains a toJSON
method, its toJSON method will be called and the result will be
stringified. A toJSON method does not serialize: it returns the
value represented by the name/value pair that should be serialized,
or undefined if nothing should be serialized. The toJSON method
will be passed the key associated with the value, and this will be
bound to the value

For example, this would serialize Dates as ISO strings.

Date.prototype.toJSON = function (key) {
function f(n) {
// Format integers to have at least two digits.
return n < 10 ? '0' + n : n;
}

return this.getUTCFullYear()   + '-' +
f(this.getUTCMonth() + 1) + '-' +
f(this.getUTCDate())      + 'T' +
f(this.getUTCHours())     + ':' +
f(this.getUTCMinutes())   + ':' +
f(this.getUTCSeconds())   + 'Z';
};

You can provide an optional replacer method. It will be passed the
key and value of each member, with this bound to the containing
object. The value that is returned from your method will be
serialized. If your method returns undefined, then the member will
be excluded from the serialization.

If the replacer parameter is an array of strings, then it will be
used to select the members to be serialized. It filters the results
such that only members with keys listed in the replacer array are
stringified.

Values that do not have JSON representations, such as undefined or
functions, will not be serialized. Such values in objects will be
dropped; in arrays they will be replaced with null. You can use
a replacer function to replace those with JSON values.
JSON.stringify(undefined) returns undefined.

The optional space parameter produces a stringification of the
value that is filled with line breaks and indentation to make it
easier to read.

If the space parameter is a non-empty string, then that string will
be used for indentation. If the space parameter is a number, then
the indentation will be that many spaces.

Example:

text = JSON.stringify(['e', {pluribus: 'unum'}]);
// text is '["e",{"pluribus":"unum"}]'


text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
// text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

text = JSON.stringify([new Date()], function (key, value) {
return this[key] instanceof Date ?
'Date(' + this[key] + ')' : value;
});
// text is '["Date(---current time---)"]'


JSON.parse(text, reviver)
This method parses a JSON text to produce an object or array.
It can throw a SyntaxError exception.

The optional reviver parameter is a function that can filter and
transform the results. It receives each of the keys and values,
and its return value is used instead of the original value.
If it returns what it received, then the structure is not modified.
If it returns undefined then the member is deleted.

Example:

// Parse the text. Values that look like ISO date strings will
// be converted to Date objects.

myData = JSON.parse(text, function (key, value) {
var a;
if (typeof value === 'string') {
a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
if (a) {
return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
+a[5], +a[6]));
}
}
return value;
});

myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
var d;
if (typeof value === 'string' &&
value.slice(0, 5) === 'Date(' &&
value.slice(-1) === ')') {
d = new Date(value.slice(5, -1));
if (d) {
return d;
}
}
return value;
});


This is a reference implementation. You are free to copy, modify, or
redistribute.
*/

/*jslint evil: true, strict: false */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
lastIndex, length, parse, prototype, push, replace, slice, stringify,
test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (!this.JSON) {
    this.JSON = {};
}

(function () {

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                this.getUTCFullYear() + '-' +
                f(this.getUTCMonth() + 1) + '-' +
                f(this.getUTCDate()) + 'T' +
                f(this.getUTCHours()) + ':' +
                f(this.getUTCMinutes()) + ':' +
                f(this.getUTCSeconds()) + 'Z' : null;
        };

        String.prototype.toJSON =
    Number.prototype.toJSON =
    Boolean.prototype.toJSON = function (key) {
        return this.valueOf();
    };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
    escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
    gap,
    indent,
    meta = {    // table of character substitutions
        '\b': '\\b',
        '\t': '\\t',
        '\n': '\\n',
        '\f': '\\f',
        '\r': '\\r',
        '"': '\\"',
        '\\': '\\\\'
    },
    rep;


    function quote(string) {

        // If the string contains no control characters, no quote characters, and no
        // backslash characters, then we can safely slap some quotes around it.
        // Otherwise we must also replace the offending characters with safe escape
        // sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ?
        '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string' ? c :
                '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' :
        '"' + string + '"';
    }


    function str(key, holder) {

        // Produce a string from holder[key].

        var i,          // The loop counter.
        k,          // The member key.
        v,          // The member value.
        length,
        mind = gap,
        partial,
        value = holder[key];

        // If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
            typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

        // If we were called with a replacer function, then call the replacer to
        // obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

        // What happens next depends on the value's type.

        switch (typeof value) {
            case 'string':
                return quote(value);

            case 'number':

                // JSON numbers must be finite. Encode non-finite numbers as null.

                return isFinite(value) ? String(value) : 'null';

            case 'boolean':
            case 'null':

                // If the value is a boolean or null, convert it to a string. Note:
                // typeof null does not produce 'null'. The case is included here in
                // the remote chance that this gets fixed someday.

                return String(value);

                // If the type is 'object', we might be dealing with an object or an array or
                // null.

            case 'object':

                // Due to a specification blunder in ECMAScript, typeof null is 'object',
                // so watch out for that case.

                if (!value) {
                    return 'null';
                }

                // Make an array to hold the partial results of stringifying this object value.

                gap += indent;
                partial = [];

                // Is the value an array?

                if (Object.prototype.toString.apply(value) === '[object Array]') {

                    // The value is an array. Stringify every element. Use null as a placeholder
                    // for non-JSON values.

                    length = value.length;
                    for (i = 0; i < length; i += 1) {
                        partial[i] = str(i, value) || 'null';
                    }

                    // Join all of the elements together, separated with commas, and wrap them in
                    // brackets.

                    v = partial.length === 0 ? '[]' :
                gap ? '[\n' + gap +
                        partial.join(',\n' + gap) + '\n' +
                            mind + ']' :
                        '[' + partial.join(',') + ']';
                    gap = mind;
                    return v;
                }

                // If the replacer is an array, use it to select the members to be stringified.

                if (rep && typeof rep === 'object') {
                    length = rep.length;
                    for (i = 0; i < length; i += 1) {
                        k = rep[i];
                        if (typeof k === 'string') {
                            v = str(k, value);
                            if (v) {
                                partial.push(quote(k) + (gap ? ': ' : ':') + v);
                            }
                        }
                    }
                } else {

                    // Otherwise, iterate through all of the keys in the object.

                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = str(k, value);
                            if (v) {
                                partial.push(quote(k) + (gap ? ': ' : ':') + v);
                            }
                        }
                    }
                }

                // Join all of the member texts together, separated with commas,
                // and wrap them in braces.

                v = partial.length === 0 ? '{}' :
            gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                    mind + '}' : '{' + partial.join(',') + '}';
                gap = mind;
                return v;
        }
    }

    // If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

            // The stringify method takes a value and an optional replacer, and an optional
            // space parameter, and returns a JSON text. The replacer can be a function
            // that can replace values, or an array of strings that will select the keys.
            // A default replacer method can be provided. Use of the space parameter can
            // produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

            // If the space parameter is a number, make an indent string containing that
            // many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

                // If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

            // If there is a replacer, it must be a function or an array.
            // Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

            // Make a fake root object containing our value under the key of ''.
            // Return the result of stringifying the value.

            return str('', { '': value });
        };
    }


    // If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

            // The parse method takes a text and an optional reviver function, and returns
            // a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

                // The walk method is used to recursively walk the resulting structure so
                // that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


            // Parsing happens in four stages. In the first stage, we replace certain
            // Unicode characters with escape sequences. JavaScript handles many characters
            // incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                    ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

            // In the second stage, we run the text against regular expressions that look
            // for non-JSON patterns. We are especially concerned with '()' and 'new'
            // because they can cause invocation, and '=' because it can cause mutation.
            // But just to be safe, we want to reject all unexpected forms.

            // We split the second stage into 4 regexp operations in order to work around
            // crippling inefficiencies in IE's and Safari's regexp engines. First we
            // replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
            // replace all simple value tokens with ']' characters. Third, we delete all
            // open brackets that follow a colon or comma or that begin the text. Finally,
            // we look to see that the remaining characters are only whitespace or ']' or
            // ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

                // In the third stage we use the eval function to compile the text into a
                // JavaScript structure. The '{' operator is subject to a syntactic ambiguity
                // in JavaScript: it can begin a block or an object literal. We wrap the text
                // in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

                // In the optional fourth stage, we recursively walk the new structure, passing
                // each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                walk({ '': j }, '') : j;
            }

            // If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
} ());

/*! jQuery v1.7.1 jquery.com | jquery.org/license */
(function (a, b) {
    function cy(a) { return f.isWindow(a) ? a : a.nodeType === 9 ? a.defaultView || a.parentWindow : !1 } function cv(a) { if (!ck[a]) { var b = c.body, d = f("<" + a + ">").appendTo(b), e = d.css("display"); d.remove(); if (e === "none" || e === "") { cl || (cl = c.createElement("iframe"), cl.frameBorder = cl.width = cl.height = 0), b.appendChild(cl); if (!cm || !cl.createElement) cm = (cl.contentWindow || cl.contentDocument).document, cm.write((c.compatMode === "CSS1Compat" ? "<!doctype html>" : "") + "<html><body>"), cm.close(); d = cm.createElement(a), cm.body.appendChild(d), e = f.css(d, "display"), b.removeChild(cl) } ck[a] = e } return ck[a] } function cu(a, b) { var c = {}; f.each(cq.concat.apply([], cq.slice(0, b)), function () { c[this] = a }); return c } function ct() { cr = b } function cs() { setTimeout(ct, 0); return cr = f.now() } function cj() { try { return new a.ActiveXObject("Microsoft.XMLHTTP") } catch (b) { } } function ci() { try { return new a.XMLHttpRequest } catch (b) { } } function cc(a, c) { a.dataFilter && (c = a.dataFilter(c, a.dataType)); var d = a.dataTypes, e = {}, g, h, i = d.length, j, k = d[0], l, m, n, o, p; for (g = 1; g < i; g++) { if (g === 1) for (h in a.converters) typeof h == "string" && (e[h.toLowerCase()] = a.converters[h]); l = k, k = d[g]; if (k === "*") k = l; else if (l !== "*" && l !== k) { m = l + " " + k, n = e[m] || e["* " + k]; if (!n) { p = b; for (o in e) { j = o.split(" "); if (j[0] === l || j[0] === "*") { p = e[j[1] + " " + k]; if (p) { o = e[o], o === !0 ? n = p : p === !0 && (n = o); break } } } } !n && !p && f.error("No conversion from " + m.replace(" ", " to ")), n !== !0 && (c = n ? n(c) : p(o(c))) } } return c } function cb(a, c, d) { var e = a.contents, f = a.dataTypes, g = a.responseFields, h, i, j, k; for (i in g) i in d && (c[g[i]] = d[i]); while (f[0] === "*") f.shift(), h === b && (h = a.mimeType || c.getResponseHeader("content-type")); if (h) for (i in e) if (e[i] && e[i].test(h)) { f.unshift(i); break } if (f[0] in d) j = f[0]; else { for (i in d) { if (!f[0] || a.converters[i + " " + f[0]]) { j = i; break } k || (k = i) } j = j || k } if (j) { j !== f[0] && f.unshift(j); return d[j] } } function ca(a, b, c, d) { if (f.isArray(b)) f.each(b, function (b, e) { c || bE.test(a) ? d(a, e) : ca(a + "[" + (typeof e == "object" || f.isArray(e) ? b : "") + "]", e, c, d) }); else if (!c && b != null && typeof b == "object") for (var e in b) ca(a + "[" + e + "]", b[e], c, d); else d(a, b) } function b_(a, c) { var d, e, g = f.ajaxSettings.flatOptions || {}; for (d in c) c[d] !== b && ((g[d] ? a : e || (e = {}))[d] = c[d]); e && f.extend(!0, a, e) } function b$(a, c, d, e, f, g) { f = f || c.dataTypes[0], g = g || {}, g[f] = !0; var h = a[f], i = 0, j = h ? h.length : 0, k = a === bT, l; for (; i < j && (k || !l); i++) l = h[i](c, d, e), typeof l == "string" && (!k || g[l] ? l = b : (c.dataTypes.unshift(l), l = b$(a, c, d, e, l, g))); (k || !l) && !g["*"] && (l = b$(a, c, d, e, "*", g)); return l } function bZ(a) { return function (b, c) { typeof b != "string" && (c = b, b = "*"); if (f.isFunction(c)) { var d = b.toLowerCase().split(bP), e = 0, g = d.length, h, i, j; for (; e < g; e++) h = d[e], j = /^\+/.test(h), j && (h = h.substr(1) || "*"), i = a[h] = a[h] || [], i[j ? "unshift" : "push"](c) } } } function bC(a, b, c) { var d = b === "width" ? a.offsetWidth : a.offsetHeight, e = b === "width" ? bx : by, g = 0, h = e.length; if (d > 0) { if (c !== "border") for (; g < h; g++) c || (d -= parseFloat(f.css(a, "padding" + e[g])) || 0), c === "margin" ? d += parseFloat(f.css(a, c + e[g])) || 0 : d -= parseFloat(f.css(a, "border" + e[g] + "Width")) || 0; return d + "px" } d = bz(a, b, b); if (d < 0 || d == null) d = a.style[b] || 0; d = parseFloat(d) || 0; if (c) for (; g < h; g++) d += parseFloat(f.css(a, "padding" + e[g])) || 0, c !== "padding" && (d += parseFloat(f.css(a, "border" + e[g] + "Width")) || 0), c === "margin" && (d += parseFloat(f.css(a, c + e[g])) || 0); return d + "px" } function bp(a, b) { b.src ? f.ajax({ url: b.src, async: !1, dataType: "script" }) : f.globalEval((b.text || b.textContent || b.innerHTML || "").replace(bf, "/*$0*/")), b.parentNode && b.parentNode.removeChild(b) } function bo(a) { var b = c.createElement("div"); bh.appendChild(b), b.innerHTML = a.outerHTML; return b.firstChild } function bn(a) { var b = (a.nodeName || "").toLowerCase(); b === "input" ? bm(a) : b !== "script" && typeof a.getElementsByTagName != "undefined" && f.grep(a.getElementsByTagName("input"), bm) } function bm(a) { if (a.type === "checkbox" || a.type === "radio") a.defaultChecked = a.checked } function bl(a) { return typeof a.getElementsByTagName != "undefined" ? a.getElementsByTagName("*") : typeof a.querySelectorAll != "undefined" ? a.querySelectorAll("*") : [] } function bk(a, b) { var c; if (b.nodeType === 1) { b.clearAttributes && b.clearAttributes(), b.mergeAttributes && b.mergeAttributes(a), c = b.nodeName.toLowerCase(); if (c === "object") b.outerHTML = a.outerHTML; else if (c !== "input" || a.type !== "checkbox" && a.type !== "radio") { if (c === "option") b.selected = a.defaultSelected; else if (c === "input" || c === "textarea") b.defaultValue = a.defaultValue } else a.checked && (b.defaultChecked = b.checked = a.checked), b.value !== a.value && (b.value = a.value); b.removeAttribute(f.expando) } } function bj(a, b) { if (b.nodeType === 1 && !!f.hasData(a)) { var c, d, e, g = f._data(a), h = f._data(b, g), i = g.events; if (i) { delete h.handle, h.events = {}; for (c in i) for (d = 0, e = i[c].length; d < e; d++) f.event.add(b, c + (i[c][d].namespace ? "." : "") + i[c][d].namespace, i[c][d], i[c][d].data) } h.data && (h.data = f.extend({}, h.data)) } } function bi(a, b) { return f.nodeName(a, "table") ? a.getElementsByTagName("tbody")[0] || a.appendChild(a.ownerDocument.createElement("tbody")) : a } function U(a) { var b = V.split("|"), c = a.createDocumentFragment(); if (c.createElement) while (b.length) c.createElement(b.pop()); return c } function T(a, b, c) { b = b || 0; if (f.isFunction(b)) return f.grep(a, function (a, d) { var e = !!b.call(a, d, a); return e === c }); if (b.nodeType) return f.grep(a, function (a, d) { return a === b === c }); if (typeof b == "string") { var d = f.grep(a, function (a) { return a.nodeType === 1 }); if (O.test(b)) return f.filter(b, d, !c); b = f.filter(b, d) } return f.grep(a, function (a, d) { return f.inArray(a, b) >= 0 === c }) } function S(a) { return !a || !a.parentNode || a.parentNode.nodeType === 11 } function K() { return !0 } function J() { return !1 } function n(a, b, c) { var d = b + "defer", e = b + "queue", g = b + "mark", h = f._data(a, d); h && (c === "queue" || !f._data(a, e)) && (c === "mark" || !f._data(a, g)) && setTimeout(function () { !f._data(a, e) && !f._data(a, g) && (f.removeData(a, d, !0), h.fire()) }, 0) } function m(a) { for (var b in a) { if (b === "data" && f.isEmptyObject(a[b])) continue; if (b !== "toJSON") return !1 } return !0 } function l(a, c, d) { if (d === b && a.nodeType === 1) { var e = "data-" + c.replace(k, "-$1").toLowerCase(); d = a.getAttribute(e); if (typeof d == "string") { try { d = d === "true" ? !0 : d === "false" ? !1 : d === "null" ? null : f.isNumeric(d) ? parseFloat(d) : j.test(d) ? f.parseJSON(d) : d } catch (g) { } f.data(a, c, d) } else d = b } return d } function h(a) { var b = g[a] = {}, c, d; a = a.split(/\s+/); for (c = 0, d = a.length; c < d; c++) b[a[c]] = !0; return b } var c = a.document, d = a.navigator, e = a.location, f = function () { function J() { if (!e.isReady) { try { c.documentElement.doScroll("left") } catch (a) { setTimeout(J, 1); return } e.ready() } } var e = function (a, b) { return new e.fn.init(a, b, h) }, f = a.jQuery, g = a.$, h, i = /^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/, j = /\S/, k = /^\s+/, l = /\s+$/, m = /^<(\w+)\s*\/?>(?:<\/\1>)?$/, n = /^[\],:{}\s]*$/, o = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, p = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, q = /(?:^|:|,)(?:\s*\[)+/g, r = /(webkit)[ \/]([\w.]+)/, s = /(opera)(?:.*version)?[ \/]([\w.]+)/, t = /(msie) ([\w.]+)/, u = /(mozilla)(?:.*? rv:([\w.]+))?/, v = /-([a-z]|[0-9])/ig, w = /^-ms-/, x = function (a, b) { return (b + "").toUpperCase() }, y = d.userAgent, z, A, B, C = Object.prototype.toString, D = Object.prototype.hasOwnProperty, E = Array.prototype.push, F = Array.prototype.slice, G = String.prototype.trim, H = Array.prototype.indexOf, I = {}; e.fn = e.prototype = { constructor: e, init: function (a, d, f) { var g, h, j, k; if (!a) return this; if (a.nodeType) { this.context = this[0] = a, this.length = 1; return this } if (a === "body" && !d && c.body) { this.context = c, this[0] = c.body, this.selector = a, this.length = 1; return this } if (typeof a == "string") { a.charAt(0) !== "<" || a.charAt(a.length - 1) !== ">" || a.length < 3 ? g = i.exec(a) : g = [null, a, null]; if (g && (g[1] || !d)) { if (g[1]) { d = d instanceof e ? d[0] : d, k = d ? d.ownerDocument || d : c, j = m.exec(a), j ? e.isPlainObject(d) ? (a = [c.createElement(j[1])], e.fn.attr.call(a, d, !0)) : a = [k.createElement(j[1])] : (j = e.buildFragment([g[1]], [k]), a = (j.cacheable ? e.clone(j.fragment) : j.fragment).childNodes); return e.merge(this, a) } h = c.getElementById(g[2]); if (h && h.parentNode) { if (h.id !== g[2]) return f.find(a); this.length = 1, this[0] = h } this.context = c, this.selector = a; return this } return !d || d.jquery ? (d || f).find(a) : this.constructor(d).find(a) } if (e.isFunction(a)) return f.ready(a); a.selector !== b && (this.selector = a.selector, this.context = a.context); return e.makeArray(a, this) }, selector: "", jquery: "1.7.1", length: 0, size: function () { return this.length }, toArray: function () { return F.call(this, 0) }, get: function (a) { return a == null ? this.toArray() : a < 0 ? this[this.length + a] : this[a] }, pushStack: function (a, b, c) { var d = this.constructor(); e.isArray(a) ? E.apply(d, a) : e.merge(d, a), d.prevObject = this, d.context = this.context, b === "find" ? d.selector = this.selector + (this.selector ? " " : "") + c : b && (d.selector = this.selector + "." + b + "(" + c + ")"); return d }, each: function (a, b) { return e.each(this, a, b) }, ready: function (a) { e.bindReady(), A.add(a); return this }, eq: function (a) { a = +a; return a === -1 ? this.slice(a) : this.slice(a, a + 1) }, first: function () { return this.eq(0) }, last: function () { return this.eq(-1) }, slice: function () { return this.pushStack(F.apply(this, arguments), "slice", F.call(arguments).join(",")) }, map: function (a) { return this.pushStack(e.map(this, function (b, c) { return a.call(b, c, b) })) }, end: function () { return this.prevObject || this.constructor(null) }, push: E, sort: [].sort, splice: [].splice }, e.fn.init.prototype = e.fn, e.extend = e.fn.extend = function () { var a, c, d, f, g, h, i = arguments[0] || {}, j = 1, k = arguments.length, l = !1; typeof i == "boolean" && (l = i, i = arguments[1] || {}, j = 2), typeof i != "object" && !e.isFunction(i) && (i = {}), k === j && (i = this, --j); for (; j < k; j++) if ((a = arguments[j]) != null) for (c in a) { d = i[c], f = a[c]; if (i === f) continue; l && f && (e.isPlainObject(f) || (g = e.isArray(f))) ? (g ? (g = !1, h = d && e.isArray(d) ? d : []) : h = d && e.isPlainObject(d) ? d : {}, i[c] = e.extend(l, h, f)) : f !== b && (i[c] = f) } return i }, e.extend({ noConflict: function (b) { a.$ === e && (a.$ = g), b && a.jQuery === e && (a.jQuery = f); return e }, isReady: !1, readyWait: 1, holdReady: function (a) { a ? e.readyWait++ : e.ready(!0) }, ready: function (a) { if (a === !0 && ! --e.readyWait || a !== !0 && !e.isReady) { if (!c.body) return setTimeout(e.ready, 1); e.isReady = !0; if (a !== !0 && --e.readyWait > 0) return; A.fireWith(c, [e]), e.fn.trigger && e(c).trigger("ready").off("ready") } }, bindReady: function () { if (!A) { A = e.Callbacks("once memory"); if (c.readyState === "complete") return setTimeout(e.ready, 1); if (c.addEventListener) c.addEventListener("DOMContentLoaded", B, !1), a.addEventListener("load", e.ready, !1); else if (c.attachEvent) { c.attachEvent("onreadystatechange", B), a.attachEvent("onload", e.ready); var b = !1; try { b = a.frameElement == null } catch (d) { } c.documentElement.doScroll && b && J() } } }, isFunction: function (a) { return e.type(a) === "function" }, isArray: Array.isArray || function (a) { return e.type(a) === "array" }, isWindow: function (a) { return a && typeof a == "object" && "setInterval" in a }, isNumeric: function (a) { return !isNaN(parseFloat(a)) && isFinite(a) }, type: function (a) { return a == null ? String(a) : I[C.call(a)] || "object" }, isPlainObject: function (a) { if (!a || e.type(a) !== "object" || a.nodeType || e.isWindow(a)) return !1; try { if (a.constructor && !D.call(a, "constructor") && !D.call(a.constructor.prototype, "isPrototypeOf")) return !1 } catch (c) { return !1 } var d; for (d in a); return d === b || D.call(a, d) }, isEmptyObject: function (a) { for (var b in a) return !1; return !0 }, error: function (a) { throw new Error(a) }, parseJSON: function (b) { if (typeof b != "string" || !b) return null; b = e.trim(b); if (a.JSON && a.JSON.parse) return a.JSON.parse(b); if (n.test(b.replace(o, "@").replace(p, "]").replace(q, ""))) return (new Function("return " + b))(); e.error("Invalid JSON: " + b) }, parseXML: function (c) { var d, f; try { a.DOMParser ? (f = new DOMParser, d = f.parseFromString(c, "text/xml")) : (d = new ActiveXObject("Microsoft.XMLDOM"), d.async = "false", d.loadXML(c)) } catch (g) { d = b } (!d || !d.documentElement || d.getElementsByTagName("parsererror").length) && e.error("Invalid XML: " + c); return d }, noop: function () { }, globalEval: function (b) { b && j.test(b) && (a.execScript || function (b) { a.eval.call(a, b) })(b) }, camelCase: function (a) { return a.replace(w, "ms-").replace(v, x) }, nodeName: function (a, b) { return a.nodeName && a.nodeName.toUpperCase() === b.toUpperCase() }, each: function (a, c, d) { var f, g = 0, h = a.length, i = h === b || e.isFunction(a); if (d) { if (i) { for (f in a) if (c.apply(a[f], d) === !1) break } else for (; g < h; ) if (c.apply(a[g++], d) === !1) break } else if (i) { for (f in a) if (c.call(a[f], f, a[f]) === !1) break } else for (; g < h; ) if (c.call(a[g], g, a[g++]) === !1) break; return a }, trim: G ? function (a) { return a == null ? "" : G.call(a) } : function (a) { return a == null ? "" : (a + "").replace(k, "").replace(l, "") }, makeArray: function (a, b) { var c = b || []; if (a != null) { var d = e.type(a); a.length == null || d === "string" || d === "function" || d === "regexp" || e.isWindow(a) ? E.call(c, a) : e.merge(c, a) } return c }, inArray: function (a, b, c) { var d; if (b) { if (H) return H.call(b, a, c); d = b.length, c = c ? c < 0 ? Math.max(0, d + c) : c : 0; for (; c < d; c++) if (c in b && b[c] === a) return c } return -1 }, merge: function (a, c) { var d = a.length, e = 0; if (typeof c.length == "number") for (var f = c.length; e < f; e++) a[d++] = c[e]; else while (c[e] !== b) a[d++] = c[e++]; a.length = d; return a }, grep: function (a, b, c) { var d = [], e; c = !!c; for (var f = 0, g = a.length; f < g; f++) e = !!b(a[f], f), c !== e && d.push(a[f]); return d }, map: function (a, c, d) { var f, g, h = [], i = 0, j = a.length, k = a instanceof e || j !== b && typeof j == "number" && (j > 0 && a[0] && a[j - 1] || j === 0 || e.isArray(a)); if (k) for (; i < j; i++) f = c(a[i], i, d), f != null && (h[h.length] = f); else for (g in a) f = c(a[g], g, d), f != null && (h[h.length] = f); return h.concat.apply([], h) }, guid: 1, proxy: function (a, c) { if (typeof c == "string") { var d = a[c]; c = a, a = d } if (!e.isFunction(a)) return b; var f = F.call(arguments, 2), g = function () { return a.apply(c, f.concat(F.call(arguments))) }; g.guid = a.guid = a.guid || g.guid || e.guid++; return g }, access: function (a, c, d, f, g, h) { var i = a.length; if (typeof c == "object") { for (var j in c) e.access(a, j, c[j], f, g, d); return a } if (d !== b) { f = !h && f && e.isFunction(d); for (var k = 0; k < i; k++) g(a[k], c, f ? d.call(a[k], k, g(a[k], c)) : d, h); return a } return i ? g(a[0], c) : b }, now: function () { return (new Date).getTime() }, uaMatch: function (a) { a = a.toLowerCase(); var b = r.exec(a) || s.exec(a) || t.exec(a) || a.indexOf("compatible") < 0 && u.exec(a) || []; return { browser: b[1] || "", version: b[2] || "0"} }, sub: function () { function a(b, c) { return new a.fn.init(b, c) } e.extend(!0, a, this), a.superclass = this, a.fn = a.prototype = this(), a.fn.constructor = a, a.sub = this.sub, a.fn.init = function (d, f) { f && f instanceof e && !(f instanceof a) && (f = a(f)); return e.fn.init.call(this, d, f, b) }, a.fn.init.prototype = a.fn; var b = a(c); return a }, browser: {} }), e.each("Boolean Number String Function Array Date RegExp Object".split(" "), function (a, b) { I["[object " + b + "]"] = b.toLowerCase() }), z = e.uaMatch(y), z.browser && (e.browser[z.browser] = !0, e.browser.version = z.version), e.browser.webkit && (e.browser.safari = !0), j.test(" ") && (k = /^[\s\xA0]+/, l = /[\s\xA0]+$/), h = e(c), c.addEventListener ? B = function () { c.removeEventListener("DOMContentLoaded", B, !1), e.ready() } : c.attachEvent && (B = function () { c.readyState === "complete" && (c.detachEvent("onreadystatechange", B), e.ready()) }); return e } (), g = {}; f.Callbacks = function (a) { a = a ? g[a] || h(a) : {}; var c = [], d = [], e, i, j, k, l, m = function (b) { var d, e, g, h, i; for (d = 0, e = b.length; d < e; d++) g = b[d], h = f.type(g), h === "array" ? m(g) : h === "function" && (!a.unique || !o.has(g)) && c.push(g) }, n = function (b, f) { f = f || [], e = !a.memory || [b, f], i = !0, l = j || 0, j = 0, k = c.length; for (; c && l < k; l++) if (c[l].apply(b, f) === !1 && a.stopOnFalse) { e = !0; break } i = !1, c && (a.once ? e === !0 ? o.disable() : c = [] : d && d.length && (e = d.shift(), o.fireWith(e[0], e[1]))) }, o = { add: function () { if (c) { var a = c.length; m(arguments), i ? k = c.length : e && e !== !0 && (j = a, n(e[0], e[1])) } return this }, remove: function () { if (c) { var b = arguments, d = 0, e = b.length; for (; d < e; d++) for (var f = 0; f < c.length; f++) if (b[d] === c[f]) { i && f <= k && (k--, f <= l && l--), c.splice(f--, 1); if (a.unique) break } } return this }, has: function (a) { if (c) { var b = 0, d = c.length; for (; b < d; b++) if (a === c[b]) return !0 } return !1 }, empty: function () { c = []; return this }, disable: function () { c = d = e = b; return this }, disabled: function () { return !c }, lock: function () { d = b, (!e || e === !0) && o.disable(); return this }, locked: function () { return !d }, fireWith: function (b, c) { d && (i ? a.once || d.push([b, c]) : (!a.once || !e) && n(b, c)); return this }, fire: function () { o.fireWith(this, arguments); return this }, fired: function () { return !!e } }; return o }; var i = [].slice; f.extend({ Deferred: function (a) { var b = f.Callbacks("once memory"), c = f.Callbacks("once memory"), d = f.Callbacks("memory"), e = "pending", g = { resolve: b, reject: c, notify: d }, h = { done: b.add, fail: c.add, progress: d.add, state: function () { return e }, isResolved: b.fired, isRejected: c.fired, then: function (a, b, c) { i.done(a).fail(b).progress(c); return this }, always: function () { i.done.apply(i, arguments).fail.apply(i, arguments); return this }, pipe: function (a, b, c) { return f.Deferred(function (d) { f.each({ done: [a, "resolve"], fail: [b, "reject"], progress: [c, "notify"] }, function (a, b) { var c = b[0], e = b[1], g; f.isFunction(c) ? i[a](function () { g = c.apply(this, arguments), g && f.isFunction(g.promise) ? g.promise().then(d.resolve, d.reject, d.notify) : d[e + "With"](this === i ? d : this, [g]) }) : i[a](d[e]) }) }).promise() }, promise: function (a) { if (a == null) a = h; else for (var b in h) a[b] = h[b]; return a } }, i = h.promise({}), j; for (j in g) i[j] = g[j].fire, i[j + "With"] = g[j].fireWith; i.done(function () { e = "resolved" }, c.disable, d.lock).fail(function () { e = "rejected" }, b.disable, d.lock), a && a.call(i, i); return i }, when: function (a) { function m(a) { return function (b) { e[a] = arguments.length > 1 ? i.call(arguments, 0) : b, j.notifyWith(k, e) } } function l(a) { return function (c) { b[a] = arguments.length > 1 ? i.call(arguments, 0) : c, --g || j.resolveWith(j, b) } } var b = i.call(arguments, 0), c = 0, d = b.length, e = Array(d), g = d, h = d, j = d <= 1 && a && f.isFunction(a.promise) ? a : f.Deferred(), k = j.promise(); if (d > 1) { for (; c < d; c++) b[c] && b[c].promise && f.isFunction(b[c].promise) ? b[c].promise().then(l(c), j.reject, m(c)) : --g; g || j.resolveWith(j, b) } else j !== a && j.resolveWith(j, d ? [a] : []); return k } }), f.support = function () { var b, d, e, g, h, i, j, k, l, m, n, o, p, q = c.createElement("div"), r = c.documentElement; q.setAttribute("className", "t"), q.innerHTML = "   <link/><table></table><a href='/a' style='top:1px;float:left;opacity:.55;'>a</a><input type='checkbox'/>", d = q.getElementsByTagName("*"), e = q.getElementsByTagName("a")[0]; if (!d || !d.length || !e) return {}; g = c.createElement("select"), h = g.appendChild(c.createElement("option")), i = q.getElementsByTagName("input")[0], b = { leadingWhitespace: q.firstChild.nodeType === 3, tbody: !q.getElementsByTagName("tbody").length, htmlSerialize: !!q.getElementsByTagName("link").length, style: /top/.test(e.getAttribute("style")), hrefNormalized: e.getAttribute("href") === "/a", opacity: /^0.55/.test(e.style.opacity), cssFloat: !!e.style.cssFloat, checkOn: i.value === "on", optSelected: h.selected, getSetAttribute: q.className !== "t", enctype: !!c.createElement("form").enctype, html5Clone: c.createElement("nav").cloneNode(!0).outerHTML !== "<:nav></:nav>", submitBubbles: !0, changeBubbles: !0, focusinBubbles: !1, deleteExpando: !0, noCloneEvent: !0, inlineBlockNeedsLayout: !1, shrinkWrapBlocks: !1, reliableMarginRight: !0 }, i.checked = !0, b.noCloneChecked = i.cloneNode(!0).checked, g.disabled = !0, b.optDisabled = !h.disabled; try { delete q.test } catch (s) { b.deleteExpando = !1 } !q.addEventListener && q.attachEvent && q.fireEvent && (q.attachEvent("onclick", function () { b.noCloneEvent = !1 }), q.cloneNode(!0).fireEvent("onclick")), i = c.createElement("input"), i.value = "t", i.setAttribute("type", "radio"), b.radioValue = i.value === "t", i.setAttribute("checked", "checked"), q.appendChild(i), k = c.createDocumentFragment(), k.appendChild(q.lastChild), b.checkClone = k.cloneNode(!0).cloneNode(!0).lastChild.checked, b.appendChecked = i.checked, k.removeChild(i), k.appendChild(q), q.innerHTML = "", a.getComputedStyle && (j = c.createElement("div"), j.style.width = "0", j.style.marginRight = "0", q.style.width = "2px", q.appendChild(j), b.reliableMarginRight = (parseInt((a.getComputedStyle(j, null) || { marginRight: 0 }).marginRight, 10) || 0) === 0); if (q.attachEvent) for (o in { submit: 1, change: 1, focusin: 1 }) n = "on" + o, p = n in q, p || (q.setAttribute(n, "return;"), p = typeof q[n] == "function"), b[o + "Bubbles"] = p; k.removeChild(q), k = g = h = j = q = i = null, f(function () { var a, d, e, g, h, i, j, k, m, n, o, r = c.getElementsByTagName("body")[0]; !r || (j = 1, k = "position:absolute;top:0;left:0;width:1px;height:1px;margin:0;", m = "visibility:hidden;border:0;", n = "style='" + k + "border:5px solid #000;padding:0;'", o = "<div " + n + "><div></div></div>" + "<table " + n + " cellpadding='0' cellspacing='0'>" + "<tr><td></td></tr></table>", a = c.createElement("div"), a.style.cssText = m + "width:0;height:0;position:static;top:0;margin-top:" + j + "px", r.insertBefore(a, r.firstChild), q = c.createElement("div"), a.appendChild(q), q.innerHTML = "<table><tr><td style='padding:0;border:0;display:none'></td><td>t</td></tr></table>", l = q.getElementsByTagName("td"), p = l[0].offsetHeight === 0, l[0].style.display = "", l[1].style.display = "none", b.reliableHiddenOffsets = p && l[0].offsetHeight === 0, q.innerHTML = "", q.style.width = q.style.paddingLeft = "1px", f.boxModel = b.boxModel = q.offsetWidth === 2, typeof q.style.zoom != "undefined" && (q.style.display = "inline", q.style.zoom = 1, b.inlineBlockNeedsLayout = q.offsetWidth === 2, q.style.display = "", q.innerHTML = "<div style='width:4px;'></div>", b.shrinkWrapBlocks = q.offsetWidth !== 2), q.style.cssText = k + m, q.innerHTML = o, d = q.firstChild, e = d.firstChild, h = d.nextSibling.firstChild.firstChild, i = { doesNotAddBorder: e.offsetTop !== 5, doesAddBorderForTableAndCells: h.offsetTop === 5 }, e.style.position = "fixed", e.style.top = "20px", i.fixedPosition = e.offsetTop === 20 || e.offsetTop === 15, e.style.position = e.style.top = "", d.style.overflow = "hidden", d.style.position = "relative", i.subtractsBorderForOverflowNotVisible = e.offsetTop === -5, i.doesNotIncludeMarginInBodyOffset = r.offsetTop !== j, r.removeChild(a), q = a = null, f.extend(b, i)) }); return b } (); var j = /^(?:\{.*\}|\[.*\])$/, k = /([A-Z])/g; f.extend({ cache: {}, uuid: 0, expando: "jQuery" + (f.fn.jquery + Math.random()).replace(/\D/g, ""), noData: { embed: !0, object: "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000", applet: !0 }, hasData: function (a) { a = a.nodeType ? f.cache[a[f.expando]] : a[f.expando]; return !!a && !m(a) }, data: function (a, c, d, e) { if (!!f.acceptData(a)) { var g, h, i, j = f.expando, k = typeof c == "string", l = a.nodeType, m = l ? f.cache : a, n = l ? a[j] : a[j] && j, o = c === "events"; if ((!n || !m[n] || !o && !e && !m[n].data) && k && d === b) return; n || (l ? a[j] = n = ++f.uuid : n = j), m[n] || (m[n] = {}, l || (m[n].toJSON = f.noop)); if (typeof c == "object" || typeof c == "function") e ? m[n] = f.extend(m[n], c) : m[n].data = f.extend(m[n].data, c); g = h = m[n], e || (h.data || (h.data = {}), h = h.data), d !== b && (h[f.camelCase(c)] = d); if (o && !h[c]) return g.events; k ? (i = h[c], i == null && (i = h[f.camelCase(c)])) : i = h; return i } }, removeData: function (a, b, c) { if (!!f.acceptData(a)) { var d, e, g, h = f.expando, i = a.nodeType, j = i ? f.cache : a, k = i ? a[h] : h; if (!j[k]) return; if (b) { d = c ? j[k] : j[k].data; if (d) { f.isArray(b) || (b in d ? b = [b] : (b = f.camelCase(b), b in d ? b = [b] : b = b.split(" "))); for (e = 0, g = b.length; e < g; e++) delete d[b[e]]; if (!(c ? m : f.isEmptyObject)(d)) return } } if (!c) { delete j[k].data; if (!m(j[k])) return } f.support.deleteExpando || !j.setInterval ? delete j[k] : j[k] = null, i && (f.support.deleteExpando ? delete a[h] : a.removeAttribute ? a.removeAttribute(h) : a[h] = null) } }, _data: function (a, b, c) { return f.data(a, b, c, !0) }, acceptData: function (a) { if (a.nodeName) { var b = f.noData[a.nodeName.toLowerCase()]; if (b) return b !== !0 && a.getAttribute("classid") === b } return !0 } }), f.fn.extend({ data: function (a, c) { var d, e, g, h = null; if (typeof a == "undefined") { if (this.length) { h = f.data(this[0]); if (this[0].nodeType === 1 && !f._data(this[0], "parsedAttrs")) { e = this[0].attributes; for (var i = 0, j = e.length; i < j; i++) g = e[i].name, g.indexOf("data-") === 0 && (g = f.camelCase(g.substring(5)), l(this[0], g, h[g])); f._data(this[0], "parsedAttrs", !0) } } return h } if (typeof a == "object") return this.each(function () { f.data(this, a) }); d = a.split("."), d[1] = d[1] ? "." + d[1] : ""; if (c === b) { h = this.triggerHandler("getData" + d[1] + "!", [d[0]]), h === b && this.length && (h = f.data(this[0], a), h = l(this[0], a, h)); return h === b && d[1] ? this.data(d[0]) : h } return this.each(function () { var b = f(this), e = [d[0], c]; b.triggerHandler("setData" + d[1] + "!", e), f.data(this, a, c), b.triggerHandler("changeData" + d[1] + "!", e) }) }, removeData: function (a) { return this.each(function () { f.removeData(this, a) }) } }), f.extend({ _mark: function (a, b) { a && (b = (b || "fx") + "mark", f._data(a, b, (f._data(a, b) || 0) + 1)) }, _unmark: function (a, b, c) { a !== !0 && (c = b, b = a, a = !1); if (b) { c = c || "fx"; var d = c + "mark", e = a ? 0 : (f._data(b, d) || 1) - 1; e ? f._data(b, d, e) : (f.removeData(b, d, !0), n(b, c, "mark")) } }, queue: function (a, b, c) { var d; if (a) { b = (b || "fx") + "queue", d = f._data(a, b), c && (!d || f.isArray(c) ? d = f._data(a, b, f.makeArray(c)) : d.push(c)); return d || [] } }, dequeue: function (a, b) { b = b || "fx"; var c = f.queue(a, b), d = c.shift(), e = {}; d === "inprogress" && (d = c.shift()), d && (b === "fx" && c.unshift("inprogress"), f._data(a, b + ".run", e), d.call(a, function () { f.dequeue(a, b) }, e)), c.length || (f.removeData(a, b + "queue " + b + ".run", !0), n(a, b, "queue")) } }), f.fn.extend({ queue: function (a, c) { typeof a != "string" && (c = a, a = "fx"); if (c === b) return f.queue(this[0], a); return this.each(function () { var b = f.queue(this, a, c); a === "fx" && b[0] !== "inprogress" && f.dequeue(this, a) }) }, dequeue: function (a) { return this.each(function () { f.dequeue(this, a) }) }, delay: function (a, b) { a = f.fx ? f.fx.speeds[a] || a : a, b = b || "fx"; return this.queue(b, function (b, c) { var d = setTimeout(b, a); c.stop = function () { clearTimeout(d) } }) }, clearQueue: function (a) { return this.queue(a || "fx", []) }, promise: function (a, c) { function m() { --h || d.resolveWith(e, [e]) } typeof a != "string" && (c = a, a = b), a = a || "fx"; var d = f.Deferred(), e = this, g = e.length, h = 1, i = a + "defer", j = a + "queue", k = a + "mark", l; while (g--) if (l = f.data(e[g], i, b, !0) || (f.data(e[g], j, b, !0) || f.data(e[g], k, b, !0)) && f.data(e[g], i, f.Callbacks("once memory"), !0)) h++, l.add(m); m(); return d.promise() } }); var o = /[\n\t\r]/g, p = /\s+/, q = /\r/g, r = /^(?:button|input)$/i, s = /^(?:button|input|object|select|textarea)$/i, t = /^a(?:rea)?$/i, u = /^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i, v = f.support.getSetAttribute, w, x, y; f.fn.extend({ attr: function (a, b) { return f.access(this, a, b, !0, f.attr) }, removeAttr: function (a) { return this.each(function () { f.removeAttr(this, a) }) }, prop: function (a, b) { return f.access(this, a, b, !0, f.prop) }, removeProp: function (a) { a = f.propFix[a] || a; return this.each(function () { try { this[a] = b, delete this[a] } catch (c) { } }) }, addClass: function (a) { var b, c, d, e, g, h, i; if (f.isFunction(a)) return this.each(function (b) { f(this).addClass(a.call(this, b, this.className)) }); if (a && typeof a == "string") { b = a.split(p); for (c = 0, d = this.length; c < d; c++) { e = this[c]; if (e.nodeType === 1) if (!e.className && b.length === 1) e.className = a; else { g = " " + e.className + " "; for (h = 0, i = b.length; h < i; h++) ~g.indexOf(" " + b[h] + " ") || (g += b[h] + " "); e.className = f.trim(g) } } } return this }, removeClass: function (a) { var c, d, e, g, h, i, j; if (f.isFunction(a)) return this.each(function (b) { f(this).removeClass(a.call(this, b, this.className)) }); if (a && typeof a == "string" || a === b) { c = (a || "").split(p); for (d = 0, e = this.length; d < e; d++) { g = this[d]; if (g.nodeType === 1 && g.className) if (a) { h = (" " + g.className + " ").replace(o, " "); for (i = 0, j = c.length; i < j; i++) h = h.replace(" " + c[i] + " ", " "); g.className = f.trim(h) } else g.className = "" } } return this }, toggleClass: function (a, b) { var c = typeof a, d = typeof b == "boolean"; if (f.isFunction(a)) return this.each(function (c) { f(this).toggleClass(a.call(this, c, this.className, b), b) }); return this.each(function () { if (c === "string") { var e, g = 0, h = f(this), i = b, j = a.split(p); while (e = j[g++]) i = d ? i : !h.hasClass(e), h[i ? "addClass" : "removeClass"](e) } else if (c === "undefined" || c === "boolean") this.className && f._data(this, "__className__", this.className), this.className = this.className || a === !1 ? "" : f._data(this, "__className__") || "" }) }, hasClass: function (a) { var b = " " + a + " ", c = 0, d = this.length; for (; c < d; c++) if (this[c].nodeType === 1 && (" " + this[c].className + " ").replace(o, " ").indexOf(b) > -1) return !0; return !1 }, val: function (a) { var c, d, e, g = this[0]; { if (!!arguments.length) { e = f.isFunction(a); return this.each(function (d) { var g = f(this), h; if (this.nodeType === 1) { e ? h = a.call(this, d, g.val()) : h = a, h == null ? h = "" : typeof h == "number" ? h += "" : f.isArray(h) && (h = f.map(h, function (a) { return a == null ? "" : a + "" })), c = f.valHooks[this.nodeName.toLowerCase()] || f.valHooks[this.type]; if (!c || !("set" in c) || c.set(this, h, "value") === b) this.value = h } }) } if (g) { c = f.valHooks[g.nodeName.toLowerCase()] || f.valHooks[g.type]; if (c && "get" in c && (d = c.get(g, "value")) !== b) return d; d = g.value; return typeof d == "string" ? d.replace(q, "") : d == null ? "" : d } } } }), f.extend({ valHooks: { option: { get: function (a) { var b = a.attributes.value; return !b || b.specified ? a.value : a.text } }, select: { get: function (a) { var b, c, d, e, g = a.selectedIndex, h = [], i = a.options, j = a.type === "select-one"; if (g < 0) return null; c = j ? g : 0, d = j ? g + 1 : i.length; for (; c < d; c++) { e = i[c]; if (e.selected && (f.support.optDisabled ? !e.disabled : e.getAttribute("disabled") === null) && (!e.parentNode.disabled || !f.nodeName(e.parentNode, "optgroup"))) { b = f(e).val(); if (j) return b; h.push(b) } } if (j && !h.length && i.length) return f(i[g]).val(); return h }, set: function (a, b) { var c = f.makeArray(b); f(a).find("option").each(function () { this.selected = f.inArray(f(this).val(), c) >= 0 }), c.length || (a.selectedIndex = -1); return c } } }, attrFn: { val: !0, css: !0, html: !0, text: !0, data: !0, width: !0, height: !0, offset: !0 }, attr: function (a, c, d, e) { var g, h, i, j = a.nodeType; if (!!a && j !== 3 && j !== 8 && j !== 2) { if (e && c in f.attrFn) return f(a)[c](d); if (typeof a.getAttribute == "undefined") return f.prop(a, c, d); i = j !== 1 || !f.isXMLDoc(a), i && (c = c.toLowerCase(), h = f.attrHooks[c] || (u.test(c) ? x : w)); if (d !== b) { if (d === null) { f.removeAttr(a, c); return } if (h && "set" in h && i && (g = h.set(a, d, c)) !== b) return g; a.setAttribute(c, "" + d); return d } if (h && "get" in h && i && (g = h.get(a, c)) !== null) return g; g = a.getAttribute(c); return g === null ? b : g } }, removeAttr: function (a, b) { var c, d, e, g, h = 0; if (b && a.nodeType === 1) { d = b.toLowerCase().split(p), g = d.length; for (; h < g; h++) e = d[h], e && (c = f.propFix[e] || e, f.attr(a, e, ""), a.removeAttribute(v ? e : c), u.test(e) && c in a && (a[c] = !1)) } }, attrHooks: { type: { set: function (a, b) { if (r.test(a.nodeName) && a.parentNode) f.error("type property can't be changed"); else if (!f.support.radioValue && b === "radio" && f.nodeName(a, "input")) { var c = a.value; a.setAttribute("type", b), c && (a.value = c); return b } } }, value: { get: function (a, b) { if (w && f.nodeName(a, "button")) return w.get(a, b); return b in a ? a.value : null }, set: function (a, b, c) { if (w && f.nodeName(a, "button")) return w.set(a, b, c); a.value = b } } }, propFix: { tabindex: "tabIndex", readonly: "readOnly", "for": "htmlFor", "class": "className", maxlength: "maxLength", cellspacing: "cellSpacing", cellpadding: "cellPadding", rowspan: "rowSpan", colspan: "colSpan", usemap: "useMap", frameborder: "frameBorder", contenteditable: "contentEditable" }, prop: function (a, c, d) { var e, g, h, i = a.nodeType; if (!!a && i !== 3 && i !== 8 && i !== 2) { h = i !== 1 || !f.isXMLDoc(a), h && (c = f.propFix[c] || c, g = f.propHooks[c]); return d !== b ? g && "set" in g && (e = g.set(a, d, c)) !== b ? e : a[c] = d : g && "get" in g && (e = g.get(a, c)) !== null ? e : a[c] } }, propHooks: { tabIndex: { get: function (a) { var c = a.getAttributeNode("tabindex"); return c && c.specified ? parseInt(c.value, 10) : s.test(a.nodeName) || t.test(a.nodeName) && a.href ? 0 : b } }} }), f.attrHooks.tabindex = f.propHooks.tabIndex, x = { get: function (a, c) { var d, e = f.prop(a, c); return e === !0 || typeof e != "boolean" && (d = a.getAttributeNode(c)) && d.nodeValue !== !1 ? c.toLowerCase() : b }, set: function (a, b, c) { var d; b === !1 ? f.removeAttr(a, c) : (d = f.propFix[c] || c, d in a && (a[d] = !0), a.setAttribute(c, c.toLowerCase())); return c } }, v || (y = { name: !0, id: !0 }, w = f.valHooks.button = { get: function (a, c) { var d; d = a.getAttributeNode(c); return d && (y[c] ? d.nodeValue !== "" : d.specified) ? d.nodeValue : b }, set: function (a, b, d) { var e = a.getAttributeNode(d); e || (e = c.createAttribute(d), a.setAttributeNode(e)); return e.nodeValue = b + "" } }, f.attrHooks.tabindex.set = w.set, f.each(["width", "height"], function (a, b) { f.attrHooks[b] = f.extend(f.attrHooks[b], { set: function (a, c) { if (c === "") { a.setAttribute(b, "auto"); return c } } }) }), f.attrHooks.contenteditable = { get: w.get, set: function (a, b, c) { b === "" && (b = "false"), w.set(a, b, c) } }), f.support.hrefNormalized || f.each(["href", "src", "width", "height"], function (a, c) { f.attrHooks[c] = f.extend(f.attrHooks[c], { get: function (a) { var d = a.getAttribute(c, 2); return d === null ? b : d } }) }), f.support.style || (f.attrHooks.style = { get: function (a) { return a.style.cssText.toLowerCase() || b }, set: function (a, b) { return a.style.cssText = "" + b } }), f.support.optSelected || (f.propHooks.selected = f.extend(f.propHooks.selected, { get: function (a) { var b = a.parentNode; b && (b.selectedIndex, b.parentNode && b.parentNode.selectedIndex); return null } })), f.support.enctype || (f.propFix.enctype = "encoding"), f.support.checkOn || f.each(["radio", "checkbox"], function () { f.valHooks[this] = { get: function (a) { return a.getAttribute("value") === null ? "on" : a.value } } }), f.each(["radio", "checkbox"], function () { f.valHooks[this] = f.extend(f.valHooks[this], { set: function (a, b) { if (f.isArray(b)) return a.checked = f.inArray(f(a).val(), b) >= 0 } }) }); var z = /^(?:textarea|input|select)$/i, A = /^([^\.]*)?(?:\.(.+))?$/, B = /\bhover(\.\S+)?\b/, C = /^key/, D = /^(?:mouse|contextmenu)|click/, E = /^(?:focusinfocus|focusoutblur)$/, F = /^(\w*)(?:#([\w\-]+))?(?:\.([\w\-]+))?$/, G = function (a) { var b = F.exec(a); b && (b[1] = (b[1] || "").toLowerCase(), b[3] = b[3] && new RegExp("(?:^|\\s)" + b[3] + "(?:\\s|$)")); return b }, H = function (a, b) { var c = a.attributes || {}; return (!b[1] || a.nodeName.toLowerCase() === b[1]) && (!b[2] || (c.id || {}).value === b[2]) && (!b[3] || b[3].test((c["class"] || {}).value)) }, I = function (a) { return f.event.special.hover ? a : a.replace(B, "mouseenter$1 mouseleave$1") };
    f.event = { add: function (a, c, d, e, g) { var h, i, j, k, l, m, n, o, p, q, r, s; if (!(a.nodeType === 3 || a.nodeType === 8 || !c || !d || !(h = f._data(a)))) { d.handler && (p = d, d = p.handler), d.guid || (d.guid = f.guid++), j = h.events, j || (h.events = j = {}), i = h.handle, i || (h.handle = i = function (a) { return typeof f != "undefined" && (!a || f.event.triggered !== a.type) ? f.event.dispatch.apply(i.elem, arguments) : b }, i.elem = a), c = f.trim(I(c)).split(" "); for (k = 0; k < c.length; k++) { l = A.exec(c[k]) || [], m = l[1], n = (l[2] || "").split(".").sort(), s = f.event.special[m] || {}, m = (g ? s.delegateType : s.bindType) || m, s = f.event.special[m] || {}, o = f.extend({ type: m, origType: l[1], data: e, handler: d, guid: d.guid, selector: g, quick: G(g), namespace: n.join(".") }, p), r = j[m]; if (!r) { r = j[m] = [], r.delegateCount = 0; if (!s.setup || s.setup.call(a, e, n, i) === !1) a.addEventListener ? a.addEventListener(m, i, !1) : a.attachEvent && a.attachEvent("on" + m, i) } s.add && (s.add.call(a, o), o.handler.guid || (o.handler.guid = d.guid)), g ? r.splice(r.delegateCount++, 0, o) : r.push(o), f.event.global[m] = !0 } a = null } }, global: {}, remove: function (a, b, c, d, e) { var g = f.hasData(a) && f._data(a), h, i, j, k, l, m, n, o, p, q, r, s; if (!!g && !!(o = g.events)) { b = f.trim(I(b || "")).split(" "); for (h = 0; h < b.length; h++) { i = A.exec(b[h]) || [], j = k = i[1], l = i[2]; if (!j) { for (j in o) f.event.remove(a, j + b[h], c, d, !0); continue } p = f.event.special[j] || {}, j = (d ? p.delegateType : p.bindType) || j, r = o[j] || [], m = r.length, l = l ? new RegExp("(^|\\.)" + l.split(".").sort().join("\\.(?:.*\\.)?") + "(\\.|$)") : null; for (n = 0; n < r.length; n++) s = r[n], (e || k === s.origType) && (!c || c.guid === s.guid) && (!l || l.test(s.namespace)) && (!d || d === s.selector || d === "**" && s.selector) && (r.splice(n--, 1), s.selector && r.delegateCount--, p.remove && p.remove.call(a, s)); r.length === 0 && m !== r.length && ((!p.teardown || p.teardown.call(a, l) === !1) && f.removeEvent(a, j, g.handle), delete o[j]) } f.isEmptyObject(o) && (q = g.handle, q && (q.elem = null), f.removeData(a, ["events", "handle"], !0)) } }, customEvent: { getData: !0, setData: !0, changeData: !0 }, trigger: function (c, d, e, g) { if (!e || e.nodeType !== 3 && e.nodeType !== 8) { var h = c.type || c, i = [], j, k, l, m, n, o, p, q, r, s; if (E.test(h + f.event.triggered)) return; h.indexOf("!") >= 0 && (h = h.slice(0, -1), k = !0), h.indexOf(".") >= 0 && (i = h.split("."), h = i.shift(), i.sort()); if ((!e || f.event.customEvent[h]) && !f.event.global[h]) return; c = typeof c == "object" ? c[f.expando] ? c : new f.Event(h, c) : new f.Event(h), c.type = h, c.isTrigger = !0, c.exclusive = k, c.namespace = i.join("."), c.namespace_re = c.namespace ? new RegExp("(^|\\.)" + i.join("\\.(?:.*\\.)?") + "(\\.|$)") : null, o = h.indexOf(":") < 0 ? "on" + h : ""; if (!e) { j = f.cache; for (l in j) j[l].events && j[l].events[h] && f.event.trigger(c, d, j[l].handle.elem, !0); return } c.result = b, c.target || (c.target = e), d = d != null ? f.makeArray(d) : [], d.unshift(c), p = f.event.special[h] || {}; if (p.trigger && p.trigger.apply(e, d) === !1) return; r = [[e, p.bindType || h]]; if (!g && !p.noBubble && !f.isWindow(e)) { s = p.delegateType || h, m = E.test(s + h) ? e : e.parentNode, n = null; for (; m; m = m.parentNode) r.push([m, s]), n = m; n && n === e.ownerDocument && r.push([n.defaultView || n.parentWindow || a, s]) } for (l = 0; l < r.length && !c.isPropagationStopped(); l++) m = r[l][0], c.type = r[l][1], q = (f._data(m, "events") || {})[c.type] && f._data(m, "handle"), q && q.apply(m, d), q = o && m[o], q && f.acceptData(m) && q.apply(m, d) === !1 && c.preventDefault(); c.type = h, !g && !c.isDefaultPrevented() && (!p._default || p._default.apply(e.ownerDocument, d) === !1) && (h !== "click" || !f.nodeName(e, "a")) && f.acceptData(e) && o && e[h] && (h !== "focus" && h !== "blur" || c.target.offsetWidth !== 0) && !f.isWindow(e) && (n = e[o], n && (e[o] = null), f.event.triggered = h, e[h](), f.event.triggered = b, n && (e[o] = n)); return c.result } }, dispatch: function (c) { c = f.event.fix(c || a.event); var d = (f._data(this, "events") || {})[c.type] || [], e = d.delegateCount, g = [].slice.call(arguments, 0), h = !c.exclusive && !c.namespace, i = [], j, k, l, m, n, o, p, q, r, s, t; g[0] = c, c.delegateTarget = this; if (e && !c.target.disabled && (!c.button || c.type !== "click")) { m = f(this), m.context = this.ownerDocument || this; for (l = c.target; l != this; l = l.parentNode || this) { o = {}, q = [], m[0] = l; for (j = 0; j < e; j++) r = d[j], s = r.selector, o[s] === b && (o[s] = r.quick ? H(l, r.quick) : m.is(s)), o[s] && q.push(r); q.length && i.push({ elem: l, matches: q }) } } d.length > e && i.push({ elem: this, matches: d.slice(e) }); for (j = 0; j < i.length && !c.isPropagationStopped(); j++) { p = i[j], c.currentTarget = p.elem; for (k = 0; k < p.matches.length && !c.isImmediatePropagationStopped(); k++) { r = p.matches[k]; if (h || !c.namespace && !r.namespace || c.namespace_re && c.namespace_re.test(r.namespace)) c.data = r.data, c.handleObj = r, n = ((f.event.special[r.origType] || {}).handle || r.handler).apply(p.elem, g), n !== b && (c.result = n, n === !1 && (c.preventDefault(), c.stopPropagation())) } } return c.result }, props: "attrChange attrName relatedNode srcElement altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "), fixHooks: {}, keyHooks: { props: "char charCode key keyCode".split(" "), filter: function (a, b) { a.which == null && (a.which = b.charCode != null ? b.charCode : b.keyCode); return a } }, mouseHooks: { props: "button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "), filter: function (a, d) { var e, f, g, h = d.button, i = d.fromElement; a.pageX == null && d.clientX != null && (e = a.target.ownerDocument || c, f = e.documentElement, g = e.body, a.pageX = d.clientX + (f && f.scrollLeft || g && g.scrollLeft || 0) - (f && f.clientLeft || g && g.clientLeft || 0), a.pageY = d.clientY + (f && f.scrollTop || g && g.scrollTop || 0) - (f && f.clientTop || g && g.clientTop || 0)), !a.relatedTarget && i && (a.relatedTarget = i === a.target ? d.toElement : i), !a.which && h !== b && (a.which = h & 1 ? 1 : h & 2 ? 3 : h & 4 ? 2 : 0); return a } }, fix: function (a) { if (a[f.expando]) return a; var d, e, g = a, h = f.event.fixHooks[a.type] || {}, i = h.props ? this.props.concat(h.props) : this.props; a = f.Event(g); for (d = i.length; d; ) e = i[--d], a[e] = g[e]; a.target || (a.target = g.srcElement || c), a.target.nodeType === 3 && (a.target = a.target.parentNode), a.metaKey === b && (a.metaKey = a.ctrlKey); return h.filter ? h.filter(a, g) : a }, special: { ready: { setup: f.bindReady }, load: { noBubble: !0 }, focus: { delegateType: "focusin" }, blur: { delegateType: "focusout" }, beforeunload: { setup: function (a, b, c) { f.isWindow(this) && (this.onbeforeunload = c) }, teardown: function (a, b) { this.onbeforeunload === b && (this.onbeforeunload = null) } } }, simulate: function (a, b, c, d) { var e = f.extend(new f.Event, c, { type: a, isSimulated: !0, originalEvent: {} }); d ? f.event.trigger(e, null, b) : f.event.dispatch.call(b, e), e.isDefaultPrevented() && c.preventDefault() } }, f.event.handle = f.event.dispatch, f.removeEvent = c.removeEventListener ? function (a, b, c) { a.removeEventListener && a.removeEventListener(b, c, !1) } : function (a, b, c) { a.detachEvent && a.detachEvent("on" + b, c) }, f.Event = function (a, b) { if (!(this instanceof f.Event)) return new f.Event(a, b); a && a.type ? (this.originalEvent = a, this.type = a.type, this.isDefaultPrevented = a.defaultPrevented || a.returnValue === !1 || a.getPreventDefault && a.getPreventDefault() ? K : J) : this.type = a, b && f.extend(this, b), this.timeStamp = a && a.timeStamp || f.now(), this[f.expando] = !0 }, f.Event.prototype = { preventDefault: function () { this.isDefaultPrevented = K; var a = this.originalEvent; !a || (a.preventDefault ? a.preventDefault() : a.returnValue = !1) }, stopPropagation: function () { this.isPropagationStopped = K; var a = this.originalEvent; !a || (a.stopPropagation && a.stopPropagation(), a.cancelBubble = !0) }, stopImmediatePropagation: function () { this.isImmediatePropagationStopped = K, this.stopPropagation() }, isDefaultPrevented: J, isPropagationStopped: J, isImmediatePropagationStopped: J }, f.each({ mouseenter: "mouseover", mouseleave: "mouseout" }, function (a, b) { f.event.special[a] = { delegateType: b, bindType: b, handle: function (a) { var c = this, d = a.relatedTarget, e = a.handleObj, g = e.selector, h; if (!d || d !== c && !f.contains(c, d)) a.type = e.origType, h = e.handler.apply(this, arguments), a.type = b; return h } } }), f.support.submitBubbles || (f.event.special.submit = { setup: function () { if (f.nodeName(this, "form")) return !1; f.event.add(this, "click._submit keypress._submit", function (a) { var c = a.target, d = f.nodeName(c, "input") || f.nodeName(c, "button") ? c.form : b; d && !d._submit_attached && (f.event.add(d, "submit._submit", function (a) { this.parentNode && !a.isTrigger && f.event.simulate("submit", this.parentNode, a, !0) }), d._submit_attached = !0) }) }, teardown: function () { if (f.nodeName(this, "form")) return !1; f.event.remove(this, "._submit") } }), f.support.changeBubbles || (f.event.special.change = { setup: function () { if (z.test(this.nodeName)) { if (this.type === "checkbox" || this.type === "radio") f.event.add(this, "propertychange._change", function (a) { a.originalEvent.propertyName === "checked" && (this._just_changed = !0) }), f.event.add(this, "click._change", function (a) { this._just_changed && !a.isTrigger && (this._just_changed = !1, f.event.simulate("change", this, a, !0)) }); return !1 } f.event.add(this, "beforeactivate._change", function (a) { var b = a.target; z.test(b.nodeName) && !b._change_attached && (f.event.add(b, "change._change", function (a) { this.parentNode && !a.isSimulated && !a.isTrigger && f.event.simulate("change", this.parentNode, a, !0) }), b._change_attached = !0) }) }, handle: function (a) { var b = a.target; if (this !== b || a.isSimulated || a.isTrigger || b.type !== "radio" && b.type !== "checkbox") return a.handleObj.handler.apply(this, arguments) }, teardown: function () { f.event.remove(this, "._change"); return z.test(this.nodeName) } }), f.support.focusinBubbles || f.each({ focus: "focusin", blur: "focusout" }, function (a, b) { var d = 0, e = function (a) { f.event.simulate(b, a.target, f.event.fix(a), !0) }; f.event.special[b] = { setup: function () { d++ === 0 && c.addEventListener(a, e, !0) }, teardown: function () { --d === 0 && c.removeEventListener(a, e, !0) } } }), f.fn.extend({ on: function (a, c, d, e, g) { var h, i; if (typeof a == "object") { typeof c != "string" && (d = c, c = b); for (i in a) this.on(i, c, d, a[i], g); return this } d == null && e == null ? (e = c, d = c = b) : e == null && (typeof c == "string" ? (e = d, d = b) : (e = d, d = c, c = b)); if (e === !1) e = J; else if (!e) return this; g === 1 && (h = e, e = function (a) { f().off(a); return h.apply(this, arguments) }, e.guid = h.guid || (h.guid = f.guid++)); return this.each(function () { f.event.add(this, a, e, d, c) }) }, one: function (a, b, c, d) { return this.on.call(this, a, b, c, d, 1) }, off: function (a, c, d) { if (a && a.preventDefault && a.handleObj) { var e = a.handleObj; f(a.delegateTarget).off(e.namespace ? e.type + "." + e.namespace : e.type, e.selector, e.handler); return this } if (typeof a == "object") { for (var g in a) this.off(g, c, a[g]); return this } if (c === !1 || typeof c == "function") d = c, c = b; d === !1 && (d = J); return this.each(function () { f.event.remove(this, a, d, c) }) }, bind: function (a, b, c) { return this.on(a, null, b, c) }, unbind: function (a, b) { return this.off(a, null, b) }, live: function (a, b, c) { f(this.context).on(a, this.selector, b, c); return this }, die: function (a, b) { f(this.context).off(a, this.selector || "**", b); return this }, delegate: function (a, b, c, d) { return this.on(b, a, c, d) }, undelegate: function (a, b, c) { return arguments.length == 1 ? this.off(a, "**") : this.off(b, a, c) }, trigger: function (a, b) { return this.each(function () { f.event.trigger(a, b, this) }) }, triggerHandler: function (a, b) { if (this[0]) return f.event.trigger(a, b, this[0], !0) }, toggle: function (a) { var b = arguments, c = a.guid || f.guid++, d = 0, e = function (c) { var e = (f._data(this, "lastToggle" + a.guid) || 0) % d; f._data(this, "lastToggle" + a.guid, e + 1), c.preventDefault(); return b[e].apply(this, arguments) || !1 }; e.guid = c; while (d < b.length) b[d++].guid = c; return this.click(e) }, hover: function (a, b) { return this.mouseenter(a).mouseleave(b || a) } }), f.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "), function (a, b) { f.fn[b] = function (a, c) { c == null && (c = a, a = null); return arguments.length > 0 ? this.on(b, null, a, c) : this.trigger(b) }, f.attrFn && (f.attrFn[b] = !0), C.test(b) && (f.event.fixHooks[b] = f.event.keyHooks), D.test(b) && (f.event.fixHooks[b] = f.event.mouseHooks) }), function () { function x(a, b, c, e, f, g) { for (var h = 0, i = e.length; h < i; h++) { var j = e[h]; if (j) { var k = !1; j = j[a]; while (j) { if (j[d] === c) { k = e[j.sizset]; break } if (j.nodeType === 1) { g || (j[d] = c, j.sizset = h); if (typeof b != "string") { if (j === b) { k = !0; break } } else if (m.filter(b, [j]).length > 0) { k = j; break } } j = j[a] } e[h] = k } } } function w(a, b, c, e, f, g) { for (var h = 0, i = e.length; h < i; h++) { var j = e[h]; if (j) { var k = !1; j = j[a]; while (j) { if (j[d] === c) { k = e[j.sizset]; break } j.nodeType === 1 && !g && (j[d] = c, j.sizset = h); if (j.nodeName.toLowerCase() === b) { k = j; break } j = j[a] } e[h] = k } } } var a = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g, d = "sizcache" + (Math.random() + "").replace(".", ""), e = 0, g = Object.prototype.toString, h = !1, i = !0, j = /\\/g, k = /\r\n/g, l = /\W/; [0, 0].sort(function () { i = !1; return 0 }); var m = function (b, d, e, f) { e = e || [], d = d || c; var h = d; if (d.nodeType !== 1 && d.nodeType !== 9) return []; if (!b || typeof b != "string") return e; var i, j, k, l, n, q, r, t, u = !0, v = m.isXML(d), w = [], x = b; do { a.exec(""), i = a.exec(x); if (i) { x = i[3], w.push(i[1]); if (i[2]) { l = i[3]; break } } } while (i); if (w.length > 1 && p.exec(b)) if (w.length === 2 && o.relative[w[0]]) j = y(w[0] + w[1], d, f); else { j = o.relative[w[0]] ? [d] : m(w.shift(), d); while (w.length) b = w.shift(), o.relative[b] && (b += w.shift()), j = y(b, j, f) } else { !f && w.length > 1 && d.nodeType === 9 && !v && o.match.ID.test(w[0]) && !o.match.ID.test(w[w.length - 1]) && (n = m.find(w.shift(), d, v), d = n.expr ? m.filter(n.expr, n.set)[0] : n.set[0]); if (d) { n = f ? { expr: w.pop(), set: s(f)} : m.find(w.pop(), w.length === 1 && (w[0] === "~" || w[0] === "+") && d.parentNode ? d.parentNode : d, v), j = n.expr ? m.filter(n.expr, n.set) : n.set, w.length > 0 ? k = s(j) : u = !1; while (w.length) q = w.pop(), r = q, o.relative[q] ? r = w.pop() : q = "", r == null && (r = d), o.relative[q](k, r, v) } else k = w = [] } k || (k = j), k || m.error(q || b); if (g.call(k) === "[object Array]") if (!u) e.push.apply(e, k); else if (d && d.nodeType === 1) for (t = 0; k[t] != null; t++) k[t] && (k[t] === !0 || k[t].nodeType === 1 && m.contains(d, k[t])) && e.push(j[t]); else for (t = 0; k[t] != null; t++) k[t] && k[t].nodeType === 1 && e.push(j[t]); else s(k, e); l && (m(l, h, e, f), m.uniqueSort(e)); return e }; m.uniqueSort = function (a) { if (u) { h = i, a.sort(u); if (h) for (var b = 1; b < a.length; b++) a[b] === a[b - 1] && a.splice(b--, 1) } return a }, m.matches = function (a, b) { return m(a, null, null, b) }, m.matchesSelector = function (a, b) { return m(b, null, null, [a]).length > 0 }, m.find = function (a, b, c) { var d, e, f, g, h, i; if (!a) return []; for (e = 0, f = o.order.length; e < f; e++) { h = o.order[e]; if (g = o.leftMatch[h].exec(a)) { i = g[1], g.splice(1, 1); if (i.substr(i.length - 1) !== "\\") { g[1] = (g[1] || "").replace(j, ""), d = o.find[h](g, b, c); if (d != null) { a = a.replace(o.match[h], ""); break } } } } d || (d = typeof b.getElementsByTagName != "undefined" ? b.getElementsByTagName("*") : []); return { set: d, expr: a} }, m.filter = function (a, c, d, e) { var f, g, h, i, j, k, l, n, p, q = a, r = [], s = c, t = c && c[0] && m.isXML(c[0]); while (a && c.length) { for (h in o.filter) if ((f = o.leftMatch[h].exec(a)) != null && f[2]) { k = o.filter[h], l = f[1], g = !1, f.splice(1, 1); if (l.substr(l.length - 1) === "\\") continue; s === r && (r = []); if (o.preFilter[h]) { f = o.preFilter[h](f, s, d, r, e, t); if (!f) g = i = !0; else if (f === !0) continue } if (f) for (n = 0; (j = s[n]) != null; n++) j && (i = k(j, f, n, s), p = e ^ i, d && i != null ? p ? g = !0 : s[n] = !1 : p && (r.push(j), g = !0)); if (i !== b) { d || (s = r), a = a.replace(o.match[h], ""); if (!g) return []; break } } if (a === q) if (g == null) m.error(a); else break; q = a } return s }, m.error = function (a) { throw new Error("Syntax error, unrecognized expression: " + a) }; var n = m.getText = function (a) { var b, c, d = a.nodeType, e = ""; if (d) { if (d === 1 || d === 9) { if (typeof a.textContent == "string") return a.textContent; if (typeof a.innerText == "string") return a.innerText.replace(k, ""); for (a = a.firstChild; a; a = a.nextSibling) e += n(a) } else if (d === 3 || d === 4) return a.nodeValue } else for (b = 0; c = a[b]; b++) c.nodeType !== 8 && (e += n(c)); return e }, o = m.selectors = { order: ["ID", "NAME", "TAG"], match: { ID: /#((?:[\w\u00c0-\uFFFF\-]|\\.)+)/, CLASS: /\.((?:[\w\u00c0-\uFFFF\-]|\\.)+)/, NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF\-]|\\.)+)['"]*\]/, ATTR: /\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(?:(['"])(.*?)\3|(#?(?:[\w\u00c0-\uFFFF\-]|\\.)*)|)|)\s*\]/, TAG: /^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/, CHILD: /:(only|nth|last|first)-child(?:\(\s*(even|odd|(?:[+\-]?\d+|(?:[+\-]?\d*)?n\s*(?:[+\-]\s*\d+)?))\s*\))?/, POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^\-]|$)/, PSEUDO: /:((?:[\w\u00c0-\uFFFF\-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/ }, leftMatch: {}, attrMap: { "class": "className", "for": "htmlFor" }, attrHandle: { href: function (a) { return a.getAttribute("href") }, type: function (a) { return a.getAttribute("type") } }, relative: { "+": function (a, b) { var c = typeof b == "string", d = c && !l.test(b), e = c && !d; d && (b = b.toLowerCase()); for (var f = 0, g = a.length, h; f < g; f++) if (h = a[f]) { while ((h = h.previousSibling) && h.nodeType !== 1); a[f] = e || h && h.nodeName.toLowerCase() === b ? h || !1 : h === b } e && m.filter(b, a, !0) }, ">": function (a, b) { var c, d = typeof b == "string", e = 0, f = a.length; if (d && !l.test(b)) { b = b.toLowerCase(); for (; e < f; e++) { c = a[e]; if (c) { var g = c.parentNode; a[e] = g.nodeName.toLowerCase() === b ? g : !1 } } } else { for (; e < f; e++) c = a[e], c && (a[e] = d ? c.parentNode : c.parentNode === b); d && m.filter(b, a, !0) } }, "": function (a, b, c) { var d, f = e++, g = x; typeof b == "string" && !l.test(b) && (b = b.toLowerCase(), d = b, g = w), g("parentNode", b, f, a, d, c) }, "~": function (a, b, c) { var d, f = e++, g = x; typeof b == "string" && !l.test(b) && (b = b.toLowerCase(), d = b, g = w), g("previousSibling", b, f, a, d, c) } }, find: { ID: function (a, b, c) { if (typeof b.getElementById != "undefined" && !c) { var d = b.getElementById(a[1]); return d && d.parentNode ? [d] : [] } }, NAME: function (a, b) { if (typeof b.getElementsByName != "undefined") { var c = [], d = b.getElementsByName(a[1]); for (var e = 0, f = d.length; e < f; e++) d[e].getAttribute("name") === a[1] && c.push(d[e]); return c.length === 0 ? null : c } }, TAG: function (a, b) { if (typeof b.getElementsByTagName != "undefined") return b.getElementsByTagName(a[1]) } }, preFilter: { CLASS: function (a, b, c, d, e, f) { a = " " + a[1].replace(j, "") + " "; if (f) return a; for (var g = 0, h; (h = b[g]) != null; g++) h && (e ^ (h.className && (" " + h.className + " ").replace(/[\t\n\r]/g, " ").indexOf(a) >= 0) ? c || d.push(h) : c && (b[g] = !1)); return !1 }, ID: function (a) { return a[1].replace(j, "") }, TAG: function (a, b) { return a[1].replace(j, "").toLowerCase() }, CHILD: function (a) { if (a[1] === "nth") { a[2] || m.error(a[0]), a[2] = a[2].replace(/^\+|\s*/g, ""); var b = /(-?)(\d*)(?:n([+\-]?\d*))?/.exec(a[2] === "even" && "2n" || a[2] === "odd" && "2n+1" || !/\D/.test(a[2]) && "0n+" + a[2] || a[2]); a[2] = b[1] + (b[2] || 1) - 0, a[3] = b[3] - 0 } else a[2] && m.error(a[0]); a[0] = e++; return a }, ATTR: function (a, b, c, d, e, f) { var g = a[1] = a[1].replace(j, ""); !f && o.attrMap[g] && (a[1] = o.attrMap[g]), a[4] = (a[4] || a[5] || "").replace(j, ""), a[2] === "~=" && (a[4] = " " + a[4] + " "); return a }, PSEUDO: function (b, c, d, e, f) { if (b[1] === "not") if ((a.exec(b[3]) || "").length > 1 || /^\w/.test(b[3])) b[3] = m(b[3], null, null, c); else { var g = m.filter(b[3], c, d, !0 ^ f); d || e.push.apply(e, g); return !1 } else if (o.match.POS.test(b[0]) || o.match.CHILD.test(b[0])) return !0; return b }, POS: function (a) { a.unshift(!0); return a } }, filters: { enabled: function (a) { return a.disabled === !1 && a.type !== "hidden" }, disabled: function (a) { return a.disabled === !0 }, checked: function (a) { return a.checked === !0 }, selected: function (a) { a.parentNode && a.parentNode.selectedIndex; return a.selected === !0 }, parent: function (a) { return !!a.firstChild }, empty: function (a) { return !a.firstChild }, has: function (a, b, c) { return !!m(c[3], a).length }, header: function (a) { return /h\d/i.test(a.nodeName) }, text: function (a) { var b = a.getAttribute("type"), c = a.type; return a.nodeName.toLowerCase() === "input" && "text" === c && (b === c || b === null) }, radio: function (a) { return a.nodeName.toLowerCase() === "input" && "radio" === a.type }, checkbox: function (a) { return a.nodeName.toLowerCase() === "input" && "checkbox" === a.type }, file: function (a) { return a.nodeName.toLowerCase() === "input" && "file" === a.type }, password: function (a) { return a.nodeName.toLowerCase() === "input" && "password" === a.type }, submit: function (a) { var b = a.nodeName.toLowerCase(); return (b === "input" || b === "button") && "submit" === a.type }, image: function (a) { return a.nodeName.toLowerCase() === "input" && "image" === a.type }, reset: function (a) { var b = a.nodeName.toLowerCase(); return (b === "input" || b === "button") && "reset" === a.type }, button: function (a) { var b = a.nodeName.toLowerCase(); return b === "input" && "button" === a.type || b === "button" }, input: function (a) { return /input|select|textarea|button/i.test(a.nodeName) }, focus: function (a) { return a === a.ownerDocument.activeElement } }, setFilters: { first: function (a, b) { return b === 0 }, last: function (a, b, c, d) { return b === d.length - 1 }, even: function (a, b) { return b % 2 === 0 }, odd: function (a, b) { return b % 2 === 1 }, lt: function (a, b, c) { return b < c[3] - 0 }, gt: function (a, b, c) { return b > c[3] - 0 }, nth: function (a, b, c) { return c[3] - 0 === b }, eq: function (a, b, c) { return c[3] - 0 === b } }, filter: { PSEUDO: function (a, b, c, d) { var e = b[1], f = o.filters[e]; if (f) return f(a, c, b, d); if (e === "contains") return (a.textContent || a.innerText || n([a]) || "").indexOf(b[3]) >= 0; if (e === "not") { var g = b[3]; for (var h = 0, i = g.length; h < i; h++) if (g[h] === a) return !1; return !0 } m.error(e) }, CHILD: function (a, b) { var c, e, f, g, h, i, j, k = b[1], l = a; switch (k) { case "only": case "first": while (l = l.previousSibling) if (l.nodeType === 1) return !1; if (k === "first") return !0; l = a; case "last": while (l = l.nextSibling) if (l.nodeType === 1) return !1; return !0; case "nth": c = b[2], e = b[3]; if (c === 1 && e === 0) return !0; f = b[0], g = a.parentNode; if (g && (g[d] !== f || !a.nodeIndex)) { i = 0; for (l = g.firstChild; l; l = l.nextSibling) l.nodeType === 1 && (l.nodeIndex = ++i); g[d] = f } j = a.nodeIndex - e; return c === 0 ? j === 0 : j % c === 0 && j / c >= 0 } }, ID: function (a, b) { return a.nodeType === 1 && a.getAttribute("id") === b }, TAG: function (a, b) { return b === "*" && a.nodeType === 1 || !!a.nodeName && a.nodeName.toLowerCase() === b }, CLASS: function (a, b) { return (" " + (a.className || a.getAttribute("class")) + " ").indexOf(b) > -1 }, ATTR: function (a, b) { var c = b[1], d = m.attr ? m.attr(a, c) : o.attrHandle[c] ? o.attrHandle[c](a) : a[c] != null ? a[c] : a.getAttribute(c), e = d + "", f = b[2], g = b[4]; return d == null ? f === "!=" : !f && m.attr ? d != null : f === "=" ? e === g : f === "*=" ? e.indexOf(g) >= 0 : f === "~=" ? (" " + e + " ").indexOf(g) >= 0 : g ? f === "!=" ? e !== g : f === "^=" ? e.indexOf(g) === 0 : f === "$=" ? e.substr(e.length - g.length) === g : f === "|=" ? e === g || e.substr(0, g.length + 1) === g + "-" : !1 : e && d !== !1 }, POS: function (a, b, c, d) { var e = b[2], f = o.setFilters[e]; if (f) return f(a, c, b, d) } } }, p = o.match.POS, q = function (a, b) { return "\\" + (b - 0 + 1) }; for (var r in o.match) o.match[r] = new RegExp(o.match[r].source + /(?![^\[]*\])(?![^\(]*\))/.source), o.leftMatch[r] = new RegExp(/(^(?:.|\r|\n)*?)/.source + o.match[r].source.replace(/\\(\d+)/g, q)); var s = function (a, b) { a = Array.prototype.slice.call(a, 0); if (b) { b.push.apply(b, a); return b } return a }; try { Array.prototype.slice.call(c.documentElement.childNodes, 0)[0].nodeType } catch (t) { s = function (a, b) { var c = 0, d = b || []; if (g.call(a) === "[object Array]") Array.prototype.push.apply(d, a); else if (typeof a.length == "number") for (var e = a.length; c < e; c++) d.push(a[c]); else for (; a[c]; c++) d.push(a[c]); return d } } var u, v; c.documentElement.compareDocumentPosition ? u = function (a, b) { if (a === b) { h = !0; return 0 } if (!a.compareDocumentPosition || !b.compareDocumentPosition) return a.compareDocumentPosition ? -1 : 1; return a.compareDocumentPosition(b) & 4 ? -1 : 1 } : (u = function (a, b) { if (a === b) { h = !0; return 0 } if (a.sourceIndex && b.sourceIndex) return a.sourceIndex - b.sourceIndex; var c, d, e = [], f = [], g = a.parentNode, i = b.parentNode, j = g; if (g === i) return v(a, b); if (!g) return -1; if (!i) return 1; while (j) e.unshift(j), j = j.parentNode; j = i; while (j) f.unshift(j), j = j.parentNode; c = e.length, d = f.length; for (var k = 0; k < c && k < d; k++) if (e[k] !== f[k]) return v(e[k], f[k]); return k === c ? v(a, f[k], -1) : v(e[k], b, 1) }, v = function (a, b, c) { if (a === b) return c; var d = a.nextSibling; while (d) { if (d === b) return -1; d = d.nextSibling } return 1 }), function () { var a = c.createElement("div"), d = "script" + (new Date).getTime(), e = c.documentElement; a.innerHTML = "<a name='" + d + "'/>", e.insertBefore(a, e.firstChild), c.getElementById(d) && (o.find.ID = function (a, c, d) { if (typeof c.getElementById != "undefined" && !d) { var e = c.getElementById(a[1]); return e ? e.id === a[1] || typeof e.getAttributeNode != "undefined" && e.getAttributeNode("id").nodeValue === a[1] ? [e] : b : [] } }, o.filter.ID = function (a, b) { var c = typeof a.getAttributeNode != "undefined" && a.getAttributeNode("id"); return a.nodeType === 1 && c && c.nodeValue === b }), e.removeChild(a), e = a = null } (), function () { var a = c.createElement("div"); a.appendChild(c.createComment("")), a.getElementsByTagName("*").length > 0 && (o.find.TAG = function (a, b) { var c = b.getElementsByTagName(a[1]); if (a[1] === "*") { var d = []; for (var e = 0; c[e]; e++) c[e].nodeType === 1 && d.push(c[e]); c = d } return c }), a.innerHTML = "<a href='#'></a>", a.firstChild && typeof a.firstChild.getAttribute != "undefined" && a.firstChild.getAttribute("href") !== "#" && (o.attrHandle.href = function (a) { return a.getAttribute("href", 2) }), a = null } (), c.querySelectorAll && function () { var a = m, b = c.createElement("div"), d = "__sizzle__"; b.innerHTML = "<p class='TEST'></p>"; if (!b.querySelectorAll || b.querySelectorAll(".TEST").length !== 0) { m = function (b, e, f, g) { e = e || c; if (!g && !m.isXML(e)) { var h = /^(\w+$)|^\.([\w\-]+$)|^#([\w\-]+$)/.exec(b); if (h && (e.nodeType === 1 || e.nodeType === 9)) { if (h[1]) return s(e.getElementsByTagName(b), f); if (h[2] && o.find.CLASS && e.getElementsByClassName) return s(e.getElementsByClassName(h[2]), f) } if (e.nodeType === 9) { if (b === "body" && e.body) return s([e.body], f); if (h && h[3]) { var i = e.getElementById(h[3]); if (!i || !i.parentNode) return s([], f); if (i.id === h[3]) return s([i], f) } try { return s(e.querySelectorAll(b), f) } catch (j) { } } else if (e.nodeType === 1 && e.nodeName.toLowerCase() !== "object") { var k = e, l = e.getAttribute("id"), n = l || d, p = e.parentNode, q = /^\s*[+~]/.test(b); l ? n = n.replace(/'/g, "\\$&") : e.setAttribute("id", n), q && p && (e = e.parentNode); try { if (!q || p) return s(e.querySelectorAll("[id='" + n + "'] " + b), f) } catch (r) { } finally { l || k.removeAttribute("id") } } } return a(b, e, f, g) }; for (var e in a) m[e] = a[e]; b = null } } (), function () { var a = c.documentElement, b = a.matchesSelector || a.mozMatchesSelector || a.webkitMatchesSelector || a.msMatchesSelector; if (b) { var d = !b.call(c.createElement("div"), "div"), e = !1; try { b.call(c.documentElement, "[test!='']:sizzle") } catch (f) { e = !0 } m.matchesSelector = function (a, c) { c = c.replace(/\=\s*([^'"\]]*)\s*\]/g, "='$1']"); if (!m.isXML(a)) try { if (e || !o.match.PSEUDO.test(c) && !/!=/.test(c)) { var f = b.call(a, c); if (f || !d || a.document && a.document.nodeType !== 11) return f } } catch (g) { } return m(c, null, null, [a]).length > 0 } } } (), function () { var a = c.createElement("div"); a.innerHTML = "<div class='test e'></div><div class='test'></div>"; if (!!a.getElementsByClassName && a.getElementsByClassName("e").length !== 0) { a.lastChild.className = "e"; if (a.getElementsByClassName("e").length === 1) return; o.order.splice(1, 0, "CLASS"), o.find.CLASS = function (a, b, c) { if (typeof b.getElementsByClassName != "undefined" && !c) return b.getElementsByClassName(a[1]) }, a = null } } (), c.documentElement.contains ? m.contains = function (a, b) { return a !== b && (a.contains ? a.contains(b) : !0) } : c.documentElement.compareDocumentPosition ? m.contains = function (a, b) { return !!(a.compareDocumentPosition(b) & 16) } : m.contains = function () { return !1 }, m.isXML = function (a) { var b = (a ? a.ownerDocument || a : 0).documentElement; return b ? b.nodeName !== "HTML" : !1 }; var y = function (a, b, c) { var d, e = [], f = "", g = b.nodeType ? [b] : b; while (d = o.match.PSEUDO.exec(a)) f += d[0], a = a.replace(o.match.PSEUDO, ""); a = o.relative[a] ? a + "*" : a; for (var h = 0, i = g.length; h < i; h++) m(a, g[h], e, c); return m.filter(f, e) }; m.attr = f.attr, m.selectors.attrMap = {}, f.find = m, f.expr = m.selectors, f.expr[":"] = f.expr.filters, f.unique = m.uniqueSort, f.text = m.getText, f.isXMLDoc = m.isXML, f.contains = m.contains } (); var L = /Until$/, M = /^(?:parents|prevUntil|prevAll)/, N = /,/, O = /^.[^:#\[\.,]*$/, P = Array.prototype.slice, Q = f.expr.match.POS, R = { children: !0, contents: !0, next: !0, prev: !0 }; f.fn.extend({ find: function (a) { var b = this, c, d; if (typeof a != "string") return f(a).filter(function () { for (c = 0, d = b.length; c < d; c++) if (f.contains(b[c], this)) return !0 }); var e = this.pushStack("", "find", a), g, h, i; for (c = 0, d = this.length; c < d; c++) { g = e.length, f.find(a, this[c], e); if (c > 0) for (h = g; h < e.length; h++) for (i = 0; i < g; i++) if (e[i] === e[h]) { e.splice(h--, 1); break } } return e }, has: function (a) { var b = f(a); return this.filter(function () { for (var a = 0, c = b.length; a < c; a++) if (f.contains(this, b[a])) return !0 }) }, not: function (a) { return this.pushStack(T(this, a, !1), "not", a) }, filter: function (a) { return this.pushStack(T(this, a, !0), "filter", a) }, is: function (a) { return !!a && (typeof a == "string" ? Q.test(a) ? f(a, this.context).index(this[0]) >= 0 : f.filter(a, this).length > 0 : this.filter(a).length > 0) }, closest: function (a, b) { var c = [], d, e, g = this[0]; if (f.isArray(a)) { var h = 1; while (g && g.ownerDocument && g !== b) { for (d = 0; d < a.length; d++) f(g).is(a[d]) && c.push({ selector: a[d], elem: g, level: h }); g = g.parentNode, h++ } return c } var i = Q.test(a) || typeof a != "string" ? f(a, b || this.context) : 0; for (d = 0, e = this.length; d < e; d++) { g = this[d]; while (g) { if (i ? i.index(g) > -1 : f.find.matchesSelector(g, a)) { c.push(g); break } g = g.parentNode; if (!g || !g.ownerDocument || g === b || g.nodeType === 11) break } } c = c.length > 1 ? f.unique(c) : c; return this.pushStack(c, "closest", a) }, index: function (a) { if (!a) return this[0] && this[0].parentNode ? this.prevAll().length : -1; if (typeof a == "string") return f.inArray(this[0], f(a)); return f.inArray(a.jquery ? a[0] : a, this) }, add: function (a, b) { var c = typeof a == "string" ? f(a, b) : f.makeArray(a && a.nodeType ? [a] : a), d = f.merge(this.get(), c); return this.pushStack(S(c[0]) || S(d[0]) ? d : f.unique(d)) }, andSelf: function () { return this.add(this.prevObject) } }), f.each({ parent: function (a) { var b = a.parentNode; return b && b.nodeType !== 11 ? b : null }, parents: function (a) { return f.dir(a, "parentNode") }, parentsUntil: function (a, b, c) { return f.dir(a, "parentNode", c) }, next: function (a) { return f.nth(a, 2, "nextSibling") }, prev: function (a) { return f.nth(a, 2, "previousSibling") }, nextAll: function (a) { return f.dir(a, "nextSibling") }, prevAll: function (a) { return f.dir(a, "previousSibling") }, nextUntil: function (a, b, c) { return f.dir(a, "nextSibling", c) }, prevUntil: function (a, b, c) { return f.dir(a, "previousSibling", c) }, siblings: function (a) { return f.sibling(a.parentNode.firstChild, a) }, children: function (a) { return f.sibling(a.firstChild) }, contents: function (a) { return f.nodeName(a, "iframe") ? a.contentDocument || a.contentWindow.document : f.makeArray(a.childNodes) } }, function (a, b) { f.fn[a] = function (c, d) { var e = f.map(this, b, c); L.test(a) || (d = c), d && typeof d == "string" && (e = f.filter(d, e)), e = this.length > 1 && !R[a] ? f.unique(e) : e, (this.length > 1 || N.test(d)) && M.test(a) && (e = e.reverse()); return this.pushStack(e, a, P.call(arguments).join(",")) } }), f.extend({ filter: function (a, b, c) { c && (a = ":not(" + a + ")"); return b.length === 1 ? f.find.matchesSelector(b[0], a) ? [b[0]] : [] : f.find.matches(a, b) }, dir: function (a, c, d) { var e = [], g = a[c]; while (g && g.nodeType !== 9 && (d === b || g.nodeType !== 1 || !f(g).is(d))) g.nodeType === 1 && e.push(g), g = g[c]; return e }, nth: function (a, b, c, d) { b = b || 1; var e = 0; for (; a; a = a[c]) if (a.nodeType === 1 && ++e === b) break; return a }, sibling: function (a, b) { var c = []; for (; a; a = a.nextSibling) a.nodeType === 1 && a !== b && c.push(a); return c } }); var V = "abbr|article|aside|audio|canvas|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video", W = / jQuery\d+="(?:\d+|null)"/g, X = /^\s+/, Y = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/ig, Z = /<([\w:]+)/, $ = /<tbody/i, _ = /<|&#?\w+;/, ba = /<(?:script|style)/i, bb = /<(?:script|object|embed|option|style)/i, bc = new RegExp("<(?:" + V + ")", "i"), bd = /checked\s*(?:[^=]|=\s*.checked.)/i, be = /\/(java|ecma)script/i, bf = /^\s*<!(?:\[CDATA\[|\-\-)/, bg = { option: [1, "<select multiple='multiple'>", "</select>"], legend: [1, "<fieldset>", "</fieldset>"], thead: [1, "<table>", "</table>"], tr: [2, "<table><tbody>", "</tbody></table>"], td: [3, "<table><tbody><tr>", "</tr></tbody></table>"], col: [2, "<table><tbody></tbody><colgroup>", "</colgroup></table>"], area: [1, "<map>", "</map>"], _default: [0, "", ""] }, bh = U(c); bg.optgroup = bg.option, bg.tbody = bg.tfoot = bg.colgroup = bg.caption = bg.thead, bg.th = bg.td, f.support.htmlSerialize || (bg._default = [1, "div<div>", "</div>"]), f.fn.extend({ text: function (a) { if (f.isFunction(a)) return this.each(function (b) { var c = f(this); c.text(a.call(this, b, c.text())) }); if (typeof a != "object" && a !== b) return this.empty().append((this[0] && this[0].ownerDocument || c).createTextNode(a)); return f.text(this) }, wrapAll: function (a) { if (f.isFunction(a)) return this.each(function (b) { f(this).wrapAll(a.call(this, b)) }); if (this[0]) { var b = f(a, this[0].ownerDocument).eq(0).clone(!0); this[0].parentNode && b.insertBefore(this[0]), b.map(function () { var a = this; while (a.firstChild && a.firstChild.nodeType === 1) a = a.firstChild; return a }).append(this) } return this }, wrapInner: function (a) { if (f.isFunction(a)) return this.each(function (b) { f(this).wrapInner(a.call(this, b)) }); return this.each(function () { var b = f(this), c = b.contents(); c.length ? c.wrapAll(a) : b.append(a) }) }, wrap: function (a) { var b = f.isFunction(a); return this.each(function (c) { f(this).wrapAll(b ? a.call(this, c) : a) }) }, unwrap: function () { return this.parent().each(function () { f.nodeName(this, "body") || f(this).replaceWith(this.childNodes) }).end() }, append: function () { return this.domManip(arguments, !0, function (a) { this.nodeType === 1 && this.appendChild(a) }) }, prepend: function () { return this.domManip(arguments, !0, function (a) { this.nodeType === 1 && this.insertBefore(a, this.firstChild) }) }, before: function () { if (this[0] && this[0].parentNode) return this.domManip(arguments, !1, function (a) { this.parentNode.insertBefore(a, this) }); if (arguments.length) { var a = f.clean(arguments); a.push.apply(a, this.toArray()); return this.pushStack(a, "before", arguments) } }, after: function () { if (this[0] && this[0].parentNode) return this.domManip(arguments, !1, function (a) { this.parentNode.insertBefore(a, this.nextSibling) }); if (arguments.length) { var a = this.pushStack(this, "after", arguments); a.push.apply(a, f.clean(arguments)); return a } }, remove: function (a, b) { for (var c = 0, d; (d = this[c]) != null; c++) if (!a || f.filter(a, [d]).length) !b && d.nodeType === 1 && (f.cleanData(d.getElementsByTagName("*")), f.cleanData([d])), d.parentNode && d.parentNode.removeChild(d); return this }, empty: function ()
    { for (var a = 0, b; (b = this[a]) != null; a++) { b.nodeType === 1 && f.cleanData(b.getElementsByTagName("*")); while (b.firstChild) b.removeChild(b.firstChild) } return this }, clone: function (a, b) { a = a == null ? !1 : a, b = b == null ? a : b; return this.map(function () { return f.clone(this, a, b) }) }, html: function (a) { if (a === b) return this[0] && this[0].nodeType === 1 ? this[0].innerHTML.replace(W, "") : null; if (typeof a == "string" && !ba.test(a) && (f.support.leadingWhitespace || !X.test(a)) && !bg[(Z.exec(a) || ["", ""])[1].toLowerCase()]) { a = a.replace(Y, "<$1></$2>"); try { for (var c = 0, d = this.length; c < d; c++) this[c].nodeType === 1 && (f.cleanData(this[c].getElementsByTagName("*")), this[c].innerHTML = a) } catch (e) { this.empty().append(a) } } else f.isFunction(a) ? this.each(function (b) { var c = f(this); c.html(a.call(this, b, c.html())) }) : this.empty().append(a); return this }, replaceWith: function (a) { if (this[0] && this[0].parentNode) { if (f.isFunction(a)) return this.each(function (b) { var c = f(this), d = c.html(); c.replaceWith(a.call(this, b, d)) }); typeof a != "string" && (a = f(a).detach()); return this.each(function () { var b = this.nextSibling, c = this.parentNode; f(this).remove(), b ? f(b).before(a) : f(c).append(a) }) } return this.length ? this.pushStack(f(f.isFunction(a) ? a() : a), "replaceWith", a) : this }, detach: function (a) { return this.remove(a, !0) }, domManip: function (a, c, d) { var e, g, h, i, j = a[0], k = []; if (!f.support.checkClone && arguments.length === 3 && typeof j == "string" && bd.test(j)) return this.each(function () { f(this).domManip(a, c, d, !0) }); if (f.isFunction(j)) return this.each(function (e) { var g = f(this); a[0] = j.call(this, e, c ? g.html() : b), g.domManip(a, c, d) }); if (this[0]) { i = j && j.parentNode, f.support.parentNode && i && i.nodeType === 11 && i.childNodes.length === this.length ? e = { fragment: i} : e = f.buildFragment(a, this, k), h = e.fragment, h.childNodes.length === 1 ? g = h = h.firstChild : g = h.firstChild; if (g) { c = c && f.nodeName(g, "tr"); for (var l = 0, m = this.length, n = m - 1; l < m; l++) d.call(c ? bi(this[l], g) : this[l], e.cacheable || m > 1 && l < n ? f.clone(h, !0, !0) : h) } k.length && f.each(k, bp) } return this }
    }), f.buildFragment = function (a, b, d) { var e, g, h, i, j = a[0]; b && b[0] && (i = b[0].ownerDocument || b[0]), i.createDocumentFragment || (i = c), a.length === 1 && typeof j == "string" && j.length < 512 && i === c && j.charAt(0) === "<" && !bb.test(j) && (f.support.checkClone || !bd.test(j)) && (f.support.html5Clone || !bc.test(j)) && (g = !0, h = f.fragments[j], h && h !== 1 && (e = h)), e || (e = i.createDocumentFragment(), f.clean(a, i, e, d)), g && (f.fragments[j] = h ? e : 1); return { fragment: e, cacheable: g} }, f.fragments = {}, f.each({ appendTo: "append", prependTo: "prepend", insertBefore: "before", insertAfter: "after", replaceAll: "replaceWith" }, function (a, b) { f.fn[a] = function (c) { var d = [], e = f(c), g = this.length === 1 && this[0].parentNode; if (g && g.nodeType === 11 && g.childNodes.length === 1 && e.length === 1) { e[b](this[0]); return this } for (var h = 0, i = e.length; h < i; h++) { var j = (h > 0 ? this.clone(!0) : this).get(); f(e[h])[b](j), d = d.concat(j) } return this.pushStack(d, a, e.selector) } }), f.extend({ clone: function (a, b, c) { var d, e, g, h = f.support.html5Clone || !bc.test("<" + a.nodeName) ? a.cloneNode(!0) : bo(a); if ((!f.support.noCloneEvent || !f.support.noCloneChecked) && (a.nodeType === 1 || a.nodeType === 11) && !f.isXMLDoc(a)) { bk(a, h), d = bl(a), e = bl(h); for (g = 0; d[g]; ++g) e[g] && bk(d[g], e[g]) } if (b) { bj(a, h); if (c) { d = bl(a), e = bl(h); for (g = 0; d[g]; ++g) bj(d[g], e[g]) } } d = e = null; return h }, clean: function (a, b, d, e) { var g; b = b || c, typeof b.createElement == "undefined" && (b = b.ownerDocument || b[0] && b[0].ownerDocument || c); var h = [], i; for (var j = 0, k; (k = a[j]) != null; j++) { typeof k == "number" && (k += ""); if (!k) continue; if (typeof k == "string") if (!_.test(k)) k = b.createTextNode(k); else { k = k.replace(Y, "<$1></$2>"); var l = (Z.exec(k) || ["", ""])[1].toLowerCase(), m = bg[l] || bg._default, n = m[0], o = b.createElement("div"); b === c ? bh.appendChild(o) : U(b).appendChild(o), o.innerHTML = m[1] + k + m[2]; while (n--) o = o.lastChild; if (!f.support.tbody) { var p = $.test(k), q = l === "table" && !p ? o.firstChild && o.firstChild.childNodes : m[1] === "<table>" && !p ? o.childNodes : []; for (i = q.length - 1; i >= 0; --i) f.nodeName(q[i], "tbody") && !q[i].childNodes.length && q[i].parentNode.removeChild(q[i]) } !f.support.leadingWhitespace && X.test(k) && o.insertBefore(b.createTextNode(X.exec(k)[0]), o.firstChild), k = o.childNodes } var r; if (!f.support.appendChecked) if (k[0] && typeof (r = k.length) == "number") for (i = 0; i < r; i++) bn(k[i]); else bn(k); k.nodeType ? h.push(k) : h = f.merge(h, k) } if (d) { g = function (a) { return !a.type || be.test(a.type) }; for (j = 0; h[j]; j++) if (e && f.nodeName(h[j], "script") && (!h[j].type || h[j].type.toLowerCase() === "text/javascript")) e.push(h[j].parentNode ? h[j].parentNode.removeChild(h[j]) : h[j]); else { if (h[j].nodeType === 1) { var s = f.grep(h[j].getElementsByTagName("script"), g); h.splice.apply(h, [j + 1, 0].concat(s)) } d.appendChild(h[j]) } } return h }, cleanData: function (a) { var b, c, d = f.cache, e = f.event.special, g = f.support.deleteExpando; for (var h = 0, i; (i = a[h]) != null; h++) { if (i.nodeName && f.noData[i.nodeName.toLowerCase()]) continue; c = i[f.expando]; if (c) { b = d[c]; if (b && b.events) { for (var j in b.events) e[j] ? f.event.remove(i, j) : f.removeEvent(i, j, b.handle); b.handle && (b.handle.elem = null) } g ? delete i[f.expando] : i.removeAttribute && i.removeAttribute(f.expando), delete d[c] } } } }); var bq = /alpha\([^)]*\)/i, br = /opacity=([^)]*)/, bs = /([A-Z]|^ms)/g, bt = /^-?\d+(?:px)?$/i, bu = /^-?\d/, bv = /^([\-+])=([\-+.\de]+)/, bw = { position: "absolute", visibility: "hidden", display: "block" }, bx = ["Left", "Right"], by = ["Top", "Bottom"], bz, bA, bB; f.fn.css = function (a, c) { if (arguments.length === 2 && c === b) return this; return f.access(this, a, c, !0, function (a, c, d) { return d !== b ? f.style(a, c, d) : f.css(a, c) }) }, f.extend({ cssHooks: { opacity: { get: function (a, b) { if (b) { var c = bz(a, "opacity", "opacity"); return c === "" ? "1" : c } return a.style.opacity } } }, cssNumber: { fillOpacity: !0, fontWeight: !0, lineHeight: !0, opacity: !0, orphans: !0, widows: !0, zIndex: !0, zoom: !0 }, cssProps: { "float": f.support.cssFloat ? "cssFloat" : "styleFloat" }, style: function (a, c, d, e) { if (!!a && a.nodeType !== 3 && a.nodeType !== 8 && !!a.style) { var g, h, i = f.camelCase(c), j = a.style, k = f.cssHooks[i]; c = f.cssProps[i] || i; if (d === b) { if (k && "get" in k && (g = k.get(a, !1, e)) !== b) return g; return j[c] } h = typeof d, h === "string" && (g = bv.exec(d)) && (d = +(g[1] + 1) * +g[2] + parseFloat(f.css(a, c)), h = "number"); if (d == null || h === "number" && isNaN(d)) return; h === "number" && !f.cssNumber[i] && (d += "px"); if (!k || !("set" in k) || (d = k.set(a, d)) !== b) try { j[c] = d } catch (l) { } } }, css: function (a, c, d) { var e, g; c = f.camelCase(c), g = f.cssHooks[c], c = f.cssProps[c] || c, c === "cssFloat" && (c = "float"); if (g && "get" in g && (e = g.get(a, !0, d)) !== b) return e; if (bz) return bz(a, c) }, swap: function (a, b, c) { var d = {}; for (var e in b) d[e] = a.style[e], a.style[e] = b[e]; c.call(a); for (e in b) a.style[e] = d[e] } }), f.curCSS = f.css, f.each(["height", "width"], function (a, b) { f.cssHooks[b] = { get: function (a, c, d) { var e; if (c) { if (a.offsetWidth !== 0) return bC(a, b, d); f.swap(a, bw, function () { e = bC(a, b, d) }); return e } }, set: function (a, b) { if (!bt.test(b)) return b; b = parseFloat(b); if (b >= 0) return b + "px" } } }), f.support.opacity || (f.cssHooks.opacity = { get: function (a, b) { return br.test((b && a.currentStyle ? a.currentStyle.filter : a.style.filter) || "") ? parseFloat(RegExp.$1) / 100 + "" : b ? "1" : "" }, set: function (a, b) { var c = a.style, d = a.currentStyle, e = f.isNumeric(b) ? "alpha(opacity=" + b * 100 + ")" : "", g = d && d.filter || c.filter || ""; c.zoom = 1; if (b >= 1 && f.trim(g.replace(bq, "")) === "") { c.removeAttribute("filter"); if (d && !d.filter) return } c.filter = bq.test(g) ? g.replace(bq, e) : g + " " + e } }), f(function () { f.support.reliableMarginRight || (f.cssHooks.marginRight = { get: function (a, b) { var c; f.swap(a, { display: "inline-block" }, function () { b ? c = bz(a, "margin-right", "marginRight") : c = a.style.marginRight }); return c } }) }), c.defaultView && c.defaultView.getComputedStyle && (bA = function (a, b) { var c, d, e; b = b.replace(bs, "-$1").toLowerCase(), (d = a.ownerDocument.defaultView) && (e = d.getComputedStyle(a, null)) && (c = e.getPropertyValue(b), c === "" && !f.contains(a.ownerDocument.documentElement, a) && (c = f.style(a, b))); return c }), c.documentElement.currentStyle && (bB = function (a, b) { var c, d, e, f = a.currentStyle && a.currentStyle[b], g = a.style; f === null && g && (e = g[b]) && (f = e), !bt.test(f) && bu.test(f) && (c = g.left, d = a.runtimeStyle && a.runtimeStyle.left, d && (a.runtimeStyle.left = a.currentStyle.left), g.left = b === "fontSize" ? "1em" : f || 0, f = g.pixelLeft + "px", g.left = c, d && (a.runtimeStyle.left = d)); return f === "" ? "auto" : f }), bz = bA || bB, f.expr && f.expr.filters && (f.expr.filters.hidden = function (a) { var b = a.offsetWidth, c = a.offsetHeight; return b === 0 && c === 0 || !f.support.reliableHiddenOffsets && (a.style && a.style.display || f.css(a, "display")) === "none" }, f.expr.filters.visible = function (a) { return !f.expr.filters.hidden(a) }); var bD = /%20/g, bE = /\[\]$/, bF = /\r?\n/g, bG = /#.*$/, bH = /^(.*?):[ \t]*([^\r\n]*)\r?$/mg, bI = /^(?:color|date|datetime|datetime-local|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i, bJ = /^(?:about|app|app\-storage|.+\-extension|file|res|widget):$/, bK = /^(?:GET|HEAD)$/, bL = /^\/\//, bM = /\?/, bN = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, bO = /^(?:select|textarea)/i, bP = /\s+/, bQ = /([?&])_=[^&]*/, bR = /^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+))?)?/, bS = f.fn.load, bT = {}, bU = {}, bV, bW, bX = ["*/"] + ["*"]; try { bV = e.href } catch (bY) { bV = c.createElement("a"), bV.href = "", bV = bV.href } bW = bR.exec(bV.toLowerCase()) || [], f.fn.extend({ load: function (a, c, d) { if (typeof a != "string" && bS) return bS.apply(this, arguments); if (!this.length) return this; var e = a.indexOf(" "); if (e >= 0) { var g = a.slice(e, a.length); a = a.slice(0, e) } var h = "GET"; c && (f.isFunction(c) ? (d = c, c = b) : typeof c == "object" && (c = f.param(c, f.ajaxSettings.traditional), h = "POST")); var i = this; f.ajax({ url: a, type: h, dataType: "html", data: c, complete: function (a, b, c) { c = a.responseText, a.isResolved() && (a.done(function (a) { c = a }), i.html(g ? f("<div>").append(c.replace(bN, "")).find(g) : c)), d && i.each(d, [c, b, a]) } }); return this }, serialize: function () { return f.param(this.serializeArray()) }, serializeArray: function () { return this.map(function () { return this.elements ? f.makeArray(this.elements) : this }).filter(function () { return this.name && !this.disabled && (this.checked || bO.test(this.nodeName) || bI.test(this.type)) }).map(function (a, b) { var c = f(this).val(); return c == null ? null : f.isArray(c) ? f.map(c, function (a, c) { return { name: b.name, value: a.replace(bF, "\r\n")} }) : { name: b.name, value: c.replace(bF, "\r\n")} }).get() } }), f.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "), function (a, b) { f.fn[b] = function (a) { return this.on(b, a) } }), f.each(["get", "post"], function (a, c) { f[c] = function (a, d, e, g) { f.isFunction(d) && (g = g || e, e = d, d = b); return f.ajax({ type: c, url: a, data: d, success: e, dataType: g }) } }), f.extend({ getScript: function (a, c) { return f.get(a, b, c, "script") }, getJSON: function (a, b, c) { return f.get(a, b, c, "json") }, ajaxSetup: function (a, b) { b ? b_(a, f.ajaxSettings) : (b = a, a = f.ajaxSettings), b_(a, b); return a }, ajaxSettings: { url: bV, isLocal: bJ.test(bW[1]), global: !0, type: "GET", contentType: "application/x-www-form-urlencoded", processData: !0, async: !0, accepts: { xml: "application/xml, text/xml", html: "text/html", text: "text/plain", json: "application/json, text/javascript", "*": bX }, contents: { xml: /xml/, html: /html/, json: /json/ }, responseFields: { xml: "responseXML", text: "responseText" }, converters: { "* text": a.String, "text html": !0, "text json": f.parseJSON, "text xml": f.parseXML }, flatOptions: { context: !0, url: !0} }, ajaxPrefilter: bZ(bT), ajaxTransport: bZ(bU), ajax: function (a, c) { function w(a, c, l, m) { if (s !== 2) { s = 2, q && clearTimeout(q), p = b, n = m || "", v.readyState = a > 0 ? 4 : 0; var o, r, u, w = c, x = l ? cb(d, v, l) : b, y, z; if (a >= 200 && a < 300 || a === 304) { if (d.ifModified) { if (y = v.getResponseHeader("Last-Modified")) f.lastModified[k] = y; if (z = v.getResponseHeader("Etag")) f.etag[k] = z } if (a === 304) w = "notmodified", o = !0; else try { r = cc(d, x), w = "success", o = !0 } catch (A) { w = "parsererror", u = A } } else { u = w; if (!w || a) w = "error", a < 0 && (a = 0) } v.status = a, v.statusText = "" + (c || w), o ? h.resolveWith(e, [r, w, v]) : h.rejectWith(e, [v, w, u]), v.statusCode(j), j = b, t && g.trigger("ajax" + (o ? "Success" : "Error"), [v, d, o ? r : u]), i.fireWith(e, [v, w]), t && (g.trigger("ajaxComplete", [v, d]), --f.active || f.event.trigger("ajaxStop")) } } typeof a == "object" && (c = a, a = b), c = c || {}; var d = f.ajaxSetup({}, c), e = d.context || d, g = e !== d && (e.nodeType || e instanceof f) ? f(e) : f.event, h = f.Deferred(), i = f.Callbacks("once memory"), j = d.statusCode || {}, k, l = {}, m = {}, n, o, p, q, r, s = 0, t, u, v = { readyState: 0, setRequestHeader: function (a, b) { if (!s) { var c = a.toLowerCase(); a = m[c] = m[c] || a, l[a] = b } return this }, getAllResponseHeaders: function () { return s === 2 ? n : null }, getResponseHeader: function (a) { var c; if (s === 2) { if (!o) { o = {}; while (c = bH.exec(n)) o[c[1].toLowerCase()] = c[2] } c = o[a.toLowerCase()] } return c === b ? null : c }, overrideMimeType: function (a) { s || (d.mimeType = a); return this }, abort: function (a) { a = a || "abort", p && p.abort(a), w(0, a); return this } }; h.promise(v), v.success = v.done, v.error = v.fail, v.complete = i.add, v.statusCode = function (a) { if (a) { var b; if (s < 2) for (b in a) j[b] = [j[b], a[b]]; else b = a[v.status], v.then(b, b) } return this }, d.url = ((a || d.url) + "").replace(bG, "").replace(bL, bW[1] + "//"), d.dataTypes = f.trim(d.dataType || "*").toLowerCase().split(bP), d.crossDomain == null && (r = bR.exec(d.url.toLowerCase()), d.crossDomain = !(!r || r[1] == bW[1] && r[2] == bW[2] && (r[3] || (r[1] === "http:" ? 80 : 443)) == (bW[3] || (bW[1] === "http:" ? 80 : 443)))), d.data && d.processData && typeof d.data != "string" && (d.data = f.param(d.data, d.traditional)), b$(bT, d, c, v); if (s === 2) return !1; t = d.global, d.type = d.type.toUpperCase(), d.hasContent = !bK.test(d.type), t && f.active++ === 0 && f.event.trigger("ajaxStart"); if (!d.hasContent) { d.data && (d.url += (bM.test(d.url) ? "&" : "?") + d.data, delete d.data), k = d.url; if (d.cache === !1) { var x = f.now(), y = d.url.replace(bQ, "$1_=" + x); d.url = y + (y === d.url ? (bM.test(d.url) ? "&" : "?") + "_=" + x : "") } } (d.data && d.hasContent && d.contentType !== !1 || c.contentType) && v.setRequestHeader("Content-Type", d.contentType), d.ifModified && (k = k || d.url, f.lastModified[k] && v.setRequestHeader("If-Modified-Since", f.lastModified[k]), f.etag[k] && v.setRequestHeader("If-None-Match", f.etag[k])), v.setRequestHeader("Accept", d.dataTypes[0] && d.accepts[d.dataTypes[0]] ? d.accepts[d.dataTypes[0]] + (d.dataTypes[0] !== "*" ? ", " + bX + "; q=0.01" : "") : d.accepts["*"]); for (u in d.headers) v.setRequestHeader(u, d.headers[u]); if (d.beforeSend && (d.beforeSend.call(e, v, d) === !1 || s === 2)) { v.abort(); return !1 } for (u in { success: 1, error: 1, complete: 1 }) v[u](d[u]); p = b$(bU, d, c, v); if (!p) w(-1, "No Transport"); else { v.readyState = 1, t && g.trigger("ajaxSend", [v, d]), d.async && d.timeout > 0 && (q = setTimeout(function () { v.abort("timeout") }, d.timeout)); try { s = 1, p.send(l, w) } catch (z) { if (s < 2) w(-1, z); else throw z } } return v }, param: function (a, c) { var d = [], e = function (a, b) { b = f.isFunction(b) ? b() : b, d[d.length] = encodeURIComponent(a) + "=" + encodeURIComponent(b) }; c === b && (c = f.ajaxSettings.traditional); if (f.isArray(a) || a.jquery && !f.isPlainObject(a)) f.each(a, function () { e(this.name, this.value) }); else for (var g in a) ca(g, a[g], c, e); return d.join("&").replace(bD, "+") } }), f.extend({ active: 0, lastModified: {}, etag: {} }); var cd = f.now(), ce = /(\=)\?(&|$)|\?\?/i; f.ajaxSetup({ jsonp: "callback", jsonpCallback: function () { return f.expando + "_" + cd++ } }), f.ajaxPrefilter("json jsonp", function (b, c, d) { var e = b.contentType === "application/x-www-form-urlencoded" && typeof b.data == "string"; if (b.dataTypes[0] === "jsonp" || b.jsonp !== !1 && (ce.test(b.url) || e && ce.test(b.data))) { var g, h = b.jsonpCallback = f.isFunction(b.jsonpCallback) ? b.jsonpCallback() : b.jsonpCallback, i = a[h], j = b.url, k = b.data, l = "$1" + h + "$2"; b.jsonp !== !1 && (j = j.replace(ce, l), b.url === j && (e && (k = k.replace(ce, l)), b.data === k && (j += (/\?/.test(j) ? "&" : "?") + b.jsonp + "=" + h))), b.url = j, b.data = k, a[h] = function (a) { g = [a] }, d.always(function () { a[h] = i, g && f.isFunction(i) && a[h](g[0]) }), b.converters["script json"] = function () { g || f.error(h + " was not called"); return g[0] }, b.dataTypes[0] = "json"; return "script" } }), f.ajaxSetup({ accepts: { script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript" }, contents: { script: /javascript|ecmascript/ }, converters: { "text script": function (a) { f.globalEval(a); return a } } }), f.ajaxPrefilter("script", function (a) { a.cache === b && (a.cache = !1), a.crossDomain && (a.type = "GET", a.global = !1) }), f.ajaxTransport("script", function (a) { if (a.crossDomain) { var d, e = c.head || c.getElementsByTagName("head")[0] || c.documentElement; return { send: function (f, g) { d = c.createElement("script"), d.async = "async", a.scriptCharset && (d.charset = a.scriptCharset), d.src = a.url, d.onload = d.onreadystatechange = function (a, c) { if (c || !d.readyState || /loaded|complete/.test(d.readyState)) d.onload = d.onreadystatechange = null, e && d.parentNode && e.removeChild(d), d = b, c || g(200, "success") }, e.insertBefore(d, e.firstChild) }, abort: function () { d && d.onload(0, 1) } } } }); var cf = a.ActiveXObject ? function () { for (var a in ch) ch[a](0, 1) } : !1, cg = 0, ch; f.ajaxSettings.xhr = a.ActiveXObject ? function () { return !this.isLocal && ci() || cj() } : ci, function (a) { f.extend(f.support, { ajax: !!a, cors: !!a && "withCredentials" in a }) } (f.ajaxSettings.xhr()), f.support.ajax && f.ajaxTransport(function (c) { if (!c.crossDomain || f.support.cors) { var d; return { send: function (e, g) { var h = c.xhr(), i, j; c.username ? h.open(c.type, c.url, c.async, c.username, c.password) : h.open(c.type, c.url, c.async); if (c.xhrFields) for (j in c.xhrFields) h[j] = c.xhrFields[j]; c.mimeType && h.overrideMimeType && h.overrideMimeType(c.mimeType), !c.crossDomain && !e["X-Requested-With"] && (e["X-Requested-With"] = "XMLHttpRequest"); try { for (j in e) h.setRequestHeader(j, e[j]) } catch (k) { } h.send(c.hasContent && c.data || null), d = function (a, e) { var j, k, l, m, n; try { if (d && (e || h.readyState === 4)) { d = b, i && (h.onreadystatechange = f.noop, cf && delete ch[i]); if (e) h.readyState !== 4 && h.abort(); else { j = h.status, l = h.getAllResponseHeaders(), m = {}, n = h.responseXML, n && n.documentElement && (m.xml = n), m.text = h.responseText; try { k = h.statusText } catch (o) { k = "" } !j && c.isLocal && !c.crossDomain ? j = m.text ? 200 : 404 : j === 1223 && (j = 204) } } } catch (p) { e || g(-1, p) } m && g(j, k, m, l) }, !c.async || h.readyState === 4 ? d() : (i = ++cg, cf && (ch || (ch = {}, f(a).unload(cf)), ch[i] = d), h.onreadystatechange = d) }, abort: function () { d && d(0, 1) } } } }); var ck = {}, cl, cm, cn = /^(?:toggle|show|hide)$/, co = /^([+\-]=)?([\d+.\-]+)([a-z%]*)$/i, cp, cq = [["height", "marginTop", "marginBottom", "paddingTop", "paddingBottom"], ["width", "marginLeft", "marginRight", "paddingLeft", "paddingRight"], ["opacity"]], cr; f.fn.extend({ show: function (a, b, c) { var d, e; if (a || a === 0) return this.animate(cu("show", 3), a, b, c); for (var g = 0, h = this.length; g < h; g++) d = this[g], d.style && (e = d.style.display, !f._data(d, "olddisplay") && e === "none" && (e = d.style.display = ""), e === "" && f.css(d, "display") === "none" && f._data(d, "olddisplay", cv(d.nodeName))); for (g = 0; g < h; g++) { d = this[g]; if (d.style) { e = d.style.display; if (e === "" || e === "none") d.style.display = f._data(d, "olddisplay") || "" } } return this }, hide: function (a, b, c) { if (a || a === 0) return this.animate(cu("hide", 3), a, b, c); var d, e, g = 0, h = this.length; for (; g < h; g++) d = this[g], d.style && (e = f.css(d, "display"), e !== "none" && !f._data(d, "olddisplay") && f._data(d, "olddisplay", e)); for (g = 0; g < h; g++) this[g].style && (this[g].style.display = "none"); return this }, _toggle: f.fn.toggle, toggle: function (a, b, c) { var d = typeof a == "boolean"; f.isFunction(a) && f.isFunction(b) ? this._toggle.apply(this, arguments) : a == null || d ? this.each(function () { var b = d ? a : f(this).is(":hidden"); f(this)[b ? "show" : "hide"]() }) : this.animate(cu("toggle", 3), a, b, c); return this }, fadeTo: function (a, b, c, d) { return this.filter(":hidden").css("opacity", 0).show().end().animate({ opacity: b }, a, c, d) }, animate: function (a, b, c, d) { function g() { e.queue === !1 && f._mark(this); var b = f.extend({}, e), c = this.nodeType === 1, d = c && f(this).is(":hidden"), g, h, i, j, k, l, m, n, o; b.animatedProperties = {}; for (i in a) { g = f.camelCase(i), i !== g && (a[g] = a[i], delete a[i]), h = a[g], f.isArray(h) ? (b.animatedProperties[g] = h[1], h = a[g] = h[0]) : b.animatedProperties[g] = b.specialEasing && b.specialEasing[g] || b.easing || "swing"; if (h === "hide" && d || h === "show" && !d) return b.complete.call(this); c && (g === "height" || g === "width") && (b.overflow = [this.style.overflow, this.style.overflowX, this.style.overflowY], f.css(this, "display") === "inline" && f.css(this, "float") === "none" && (!f.support.inlineBlockNeedsLayout || cv(this.nodeName) === "inline" ? this.style.display = "inline-block" : this.style.zoom = 1)) } b.overflow != null && (this.style.overflow = "hidden"); for (i in a) j = new f.fx(this, b, i), h = a[i], cn.test(h) ? (o = f._data(this, "toggle" + i) || (h === "toggle" ? d ? "show" : "hide" : 0), o ? (f._data(this, "toggle" + i, o === "show" ? "hide" : "show"), j[o]()) : j[h]()) : (k = co.exec(h), l = j.cur(), k ? (m = parseFloat(k[2]), n = k[3] || (f.cssNumber[i] ? "" : "px"), n !== "px" && (f.style(this, i, (m || 1) + n), l = (m || 1) / j.cur() * l, f.style(this, i, l + n)), k[1] && (m = (k[1] === "-=" ? -1 : 1) * m + l), j.custom(l, m, n)) : j.custom(l, h, "")); return !0 } var e = f.speed(b, c, d); if (f.isEmptyObject(a)) return this.each(e.complete, [!1]); a = f.extend({}, a); return e.queue === !1 ? this.each(g) : this.queue(e.queue, g) }, stop: function (a, c, d) { typeof a != "string" && (d = c, c = a, a = b), c && a !== !1 && this.queue(a || "fx", []); return this.each(function () { function h(a, b, c) { var e = b[c]; f.removeData(a, c, !0), e.stop(d) } var b, c = !1, e = f.timers, g = f._data(this); d || f._unmark(!0, this); if (a == null) for (b in g) g[b] && g[b].stop && b.indexOf(".run") === b.length - 4 && h(this, g, b); else g[b = a + ".run"] && g[b].stop && h(this, g, b); for (b = e.length; b--; ) e[b].elem === this && (a == null || e[b].queue === a) && (d ? e[b](!0) : e[b].saveState(), c = !0, e.splice(b, 1)); (!d || !c) && f.dequeue(this, a) }) } }), f.each({ slideDown: cu("show", 1), slideUp: cu("hide", 1), slideToggle: cu("toggle", 1), fadeIn: { opacity: "show" }, fadeOut: { opacity: "hide" }, fadeToggle: { opacity: "toggle"} }, function (a, b) { f.fn[a] = function (a, c, d) { return this.animate(b, a, c, d) } }), f.extend({ speed: function (a, b, c) { var d = a && typeof a == "object" ? f.extend({}, a) : { complete: c || !c && b || f.isFunction(a) && a, duration: a, easing: c && b || b && !f.isFunction(b) && b }; d.duration = f.fx.off ? 0 : typeof d.duration == "number" ? d.duration : d.duration in f.fx.speeds ? f.fx.speeds[d.duration] : f.fx.speeds._default; if (d.queue == null || d.queue === !0) d.queue = "fx"; d.old = d.complete, d.complete = function (a) { f.isFunction(d.old) && d.old.call(this), d.queue ? f.dequeue(this, d.queue) : a !== !1 && f._unmark(this) }; return d }, easing: { linear: function (a, b, c, d) { return c + d * a }, swing: function (a, b, c, d) { return (-Math.cos(a * Math.PI) / 2 + .5) * d + c } }, timers: [], fx: function (a, b, c) { this.options = b, this.elem = a, this.prop = c, b.orig = b.orig || {} } }), f.fx.prototype = { update: function () { this.options.step && this.options.step.call(this.elem, this.now, this), (f.fx.step[this.prop] || f.fx.step._default)(this) }, cur: function () { if (this.elem[this.prop] != null && (!this.elem.style || this.elem.style[this.prop] == null)) return this.elem[this.prop]; var a, b = f.css(this.elem, this.prop); return isNaN(a = parseFloat(b)) ? !b || b === "auto" ? 0 : b : a }, custom: function (a, c, d) { function h(a) { return e.step(a) } var e = this, g = f.fx; this.startTime = cr || cs(), this.end = c, this.now = this.start = a, this.pos = this.state = 0, this.unit = d || this.unit || (f.cssNumber[this.prop] ? "" : "px"), h.queue = this.options.queue, h.elem = this.elem, h.saveState = function () { e.options.hide && f._data(e.elem, "fxshow" + e.prop) === b && f._data(e.elem, "fxshow" + e.prop, e.start) }, h() && f.timers.push(h) && !cp && (cp = setInterval(g.tick, g.interval)) }, show: function () { var a = f._data(this.elem, "fxshow" + this.prop); this.options.orig[this.prop] = a || f.style(this.elem, this.prop), this.options.show = !0, a !== b ? this.custom(this.cur(), a) : this.custom(this.prop === "width" || this.prop === "height" ? 1 : 0, this.cur()), f(this.elem).show() }, hide: function () { this.options.orig[this.prop] = f._data(this.elem, "fxshow" + this.prop) || f.style(this.elem, this.prop), this.options.hide = !0, this.custom(this.cur(), 0) }, step: function (a) { var b, c, d, e = cr || cs(), g = !0, h = this.elem, i = this.options; if (a || e >= i.duration + this.startTime) { this.now = this.end, this.pos = this.state = 1, this.update(), i.animatedProperties[this.prop] = !0; for (b in i.animatedProperties) i.animatedProperties[b] !== !0 && (g = !1); if (g) { i.overflow != null && !f.support.shrinkWrapBlocks && f.each(["", "X", "Y"], function (a, b) { h.style["overflow" + b] = i.overflow[a] }), i.hide && f(h).hide(); if (i.hide || i.show) for (b in i.animatedProperties) f.style(h, b, i.orig[b]), f.removeData(h, "fxshow" + b, !0), f.removeData(h, "toggle" + b, !0); d = i.complete, d && (i.complete = !1, d.call(h)) } return !1 } i.duration == Infinity ? this.now = e : (c = e - this.startTime, this.state = c / i.duration, this.pos = f.easing[i.animatedProperties[this.prop]](this.state, c, 0, 1, i.duration), this.now = this.start + (this.end - this.start) * this.pos), this.update(); return !0 } }, f.extend(f.fx, { tick: function () { var a, b = f.timers, c = 0; for (; c < b.length; c++) a = b[c], !a() && b[c] === a && b.splice(c--, 1); b.length || f.fx.stop() }, interval: 13, stop: function () { clearInterval(cp), cp = null }, speeds: { slow: 600, fast: 200, _default: 400 }, step: { opacity: function (a) { f.style(a.elem, "opacity", a.now) }, _default: function (a) { a.elem.style && a.elem.style[a.prop] != null ? a.elem.style[a.prop] = a.now + a.unit : a.elem[a.prop] = a.now } } }), f.each(["width", "height"], function (a, b) { f.fx.step[b] = function (a) { f.style(a.elem, b, Math.max(0, a.now) + a.unit) } }), f.expr && f.expr.filters && (f.expr.filters.animated = function (a) { return f.grep(f.timers, function (b) { return a === b.elem }).length }); var cw = /^t(?:able|d|h)$/i, cx = /^(?:body|html)$/i; "getBoundingClientRect" in c.documentElement ? f.fn.offset = function (a) { var b = this[0], c; if (a) return this.each(function (b) { f.offset.setOffset(this, a, b) }); if (!b || !b.ownerDocument) return null; if (b === b.ownerDocument.body) return f.offset.bodyOffset(b); try { c = b.getBoundingClientRect() } catch (d) { } var e = b.ownerDocument, g = e.documentElement; if (!c || !f.contains(g, b)) return c ? { top: c.top, left: c.left} : { top: 0, left: 0 }; var h = e.body, i = cy(e), j = g.clientTop || h.clientTop || 0, k = g.clientLeft || h.clientLeft || 0, l = i.pageYOffset || f.support.boxModel && g.scrollTop || h.scrollTop, m = i.pageXOffset || f.support.boxModel && g.scrollLeft || h.scrollLeft, n = c.top + l - j, o = c.left + m - k; return { top: n, left: o} } : f.fn.offset = function (a) { var b = this[0]; if (a) return this.each(function (b) { f.offset.setOffset(this, a, b) }); if (!b || !b.ownerDocument) return null; if (b === b.ownerDocument.body) return f.offset.bodyOffset(b); var c, d = b.offsetParent, e = b, g = b.ownerDocument, h = g.documentElement, i = g.body, j = g.defaultView, k = j ? j.getComputedStyle(b, null) : b.currentStyle, l = b.offsetTop, m = b.offsetLeft; while ((b = b.parentNode) && b !== i && b !== h) { if (f.support.fixedPosition && k.position === "fixed") break; c = j ? j.getComputedStyle(b, null) : b.currentStyle, l -= b.scrollTop, m -= b.scrollLeft, b === d && (l += b.offsetTop, m += b.offsetLeft, f.support.doesNotAddBorder && (!f.support.doesAddBorderForTableAndCells || !cw.test(b.nodeName)) && (l += parseFloat(c.borderTopWidth) || 0, m += parseFloat(c.borderLeftWidth) || 0), e = d, d = b.offsetParent), f.support.subtractsBorderForOverflowNotVisible && c.overflow !== "visible" && (l += parseFloat(c.borderTopWidth) || 0, m += parseFloat(c.borderLeftWidth) || 0), k = c } if (k.position === "relative" || k.position === "static") l += i.offsetTop, m += i.offsetLeft; f.support.fixedPosition && k.position === "fixed" && (l += Math.max(h.scrollTop, i.scrollTop), m += Math.max(h.scrollLeft, i.scrollLeft)); return { top: l, left: m} }, f.offset = { bodyOffset: function (a) { var b = a.offsetTop, c = a.offsetLeft; f.support.doesNotIncludeMarginInBodyOffset && (b += parseFloat(f.css(a, "marginTop")) || 0, c += parseFloat(f.css(a, "marginLeft")) || 0); return { top: b, left: c} }, setOffset: function (a, b, c) { var d = f.css(a, "position"); d === "static" && (a.style.position = "relative"); var e = f(a), g = e.offset(), h = f.css(a, "top"), i = f.css(a, "left"), j = (d === "absolute" || d === "fixed") && f.inArray("auto", [h, i]) > -1, k = {}, l = {}, m, n; j ? (l = e.position(), m = l.top, n = l.left) : (m = parseFloat(h) || 0, n = parseFloat(i) || 0), f.isFunction(b) && (b = b.call(a, c, g)), b.top != null && (k.top = b.top - g.top + m), b.left != null && (k.left = b.left - g.left + n), "using" in b ? b.using.call(a, k) : e.css(k) } }, f.fn.extend({ position: function () { if (!this[0]) return null; var a = this[0], b = this.offsetParent(), c = this.offset(), d = cx.test(b[0].nodeName) ? { top: 0, left: 0} : b.offset(); c.top -= parseFloat(f.css(a, "marginTop")) || 0, c.left -= parseFloat(f.css(a, "marginLeft")) || 0, d.top += parseFloat(f.css(b[0], "borderTopWidth")) || 0, d.left += parseFloat(f.css(b[0], "borderLeftWidth")) || 0; return { top: c.top - d.top, left: c.left - d.left} }, offsetParent: function () { return this.map(function () { var a = this.offsetParent || c.body; while (a && !cx.test(a.nodeName) && f.css(a, "position") === "static") a = a.offsetParent; return a }) } }), f.each(["Left", "Top"], function (a, c) { var d = "scroll" + c; f.fn[d] = function (c) { var e, g; if (c === b) { e = this[0]; if (!e) return null; g = cy(e); return g ? "pageXOffset" in g ? g[a ? "pageYOffset" : "pageXOffset"] : f.support.boxModel && g.document.documentElement[d] || g.document.body[d] : e[d] } return this.each(function () { g = cy(this), g ? g.scrollTo(a ? f(g).scrollLeft() : c, a ? c : f(g).scrollTop()) : this[d] = c }) } }), f.each(["Height", "Width"], function (a, c) { var d = c.toLowerCase(); f.fn["inner" + c] = function () { var a = this[0]; return a ? a.style ? parseFloat(f.css(a, d, "padding")) : this[d]() : null }, f.fn["outer" + c] = function (a) { var b = this[0]; return b ? b.style ? parseFloat(f.css(b, d, a ? "margin" : "border")) : this[d]() : null }, f.fn[d] = function (a) { var e = this[0]; if (!e) return a == null ? null : this; if (f.isFunction(a)) return this.each(function (b) { var c = f(this); c[d](a.call(this, b, c[d]())) }); if (f.isWindow(e)) { var g = e.document.documentElement["client" + c], h = e.document.body; return e.document.compatMode === "CSS1Compat" && g || h && h["client" + c] || g } if (e.nodeType === 9) return Math.max(e.documentElement["client" + c], e.body["scroll" + c], e.documentElement["scroll" + c], e.body["offset" + c], e.documentElement["offset" + c]); if (a === b) { var i = f.css(e, d), j = parseFloat(i); return f.isNumeric(j) ? j : i } return this.css(d, typeof a == "string" ? a : a + "px") } }), a.jQuery = a.$ = f, typeof define == "function" && define.amd && define.amd.jQuery && define("jquery", [], function () { return f })
})(window);

/*!
* jQuery UI 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI
*/
(function (a, b) { function d(b) { return !a(b).parents().andSelf().filter(function () { return a.curCSS(this, "visibility") === "hidden" || a.expr.filters.hidden(this) }).length } function c(b, c) { var e = b.nodeName.toLowerCase(); if ("area" === e) { var f = b.parentNode, g = f.name, h; if (!b.href || !g || f.nodeName.toLowerCase() !== "map") return !1; h = a("img[usemap=#" + g + "]")[0]; return !!h && d(h) } return (/input|select|textarea|button|object/.test(e) ? !b.disabled : "a" == e ? b.href || c : c) && d(b) } a.ui = a.ui || {}; a.ui.version || (a.extend(a.ui, { version: "1.8.18", keyCode: { ALT: 18, BACKSPACE: 8, CAPS_LOCK: 20, COMMA: 188, COMMAND: 91, COMMAND_LEFT: 91, COMMAND_RIGHT: 93, CONTROL: 17, DELETE: 46, DOWN: 40, END: 35, ENTER: 13, ESCAPE: 27, HOME: 36, INSERT: 45, LEFT: 37, MENU: 93, NUMPAD_ADD: 107, NUMPAD_DECIMAL: 110, NUMPAD_DIVIDE: 111, NUMPAD_ENTER: 108, NUMPAD_MULTIPLY: 106, NUMPAD_SUBTRACT: 109, PAGE_DOWN: 34, PAGE_UP: 33, PERIOD: 190, RIGHT: 39, SHIFT: 16, SPACE: 32, TAB: 9, UP: 38, WINDOWS: 91} }), a.fn.extend({ propAttr: a.fn.prop || a.fn.attr, _focus: a.fn.focus, focus: function (b, c) { return typeof b == "number" ? this.each(function () { var d = this; setTimeout(function () { a(d).focus(), c && c.call(d) }, b) }) : this._focus.apply(this, arguments) }, scrollParent: function () { var b; a.browser.msie && /(static|relative)/.test(this.css("position")) || /absolute/.test(this.css("position")) ? b = this.parents().filter(function () { return /(relative|absolute|fixed)/.test(a.curCSS(this, "position", 1)) && /(auto|scroll)/.test(a.curCSS(this, "overflow", 1) + a.curCSS(this, "overflow-y", 1) + a.curCSS(this, "overflow-x", 1)) }).eq(0) : b = this.parents().filter(function () { return /(auto|scroll)/.test(a.curCSS(this, "overflow", 1) + a.curCSS(this, "overflow-y", 1) + a.curCSS(this, "overflow-x", 1)) }).eq(0); return /fixed/.test(this.css("position")) || !b.length ? a(document) : b }, zIndex: function (c) { if (c !== b) return this.css("zIndex", c); if (this.length) { var d = a(this[0]), e, f; while (d.length && d[0] !== document) { e = d.css("position"); if (e === "absolute" || e === "relative" || e === "fixed") { f = parseInt(d.css("zIndex"), 10); if (!isNaN(f) && f !== 0) return f } d = d.parent() } } return 0 }, disableSelection: function () { return this.bind((a.support.selectstart ? "selectstart" : "mousedown") + ".ui-disableSelection", function (a) { a.preventDefault() }) }, enableSelection: function () { return this.unbind(".ui-disableSelection") } }), a.each(["Width", "Height"], function (c, d) { function h(b, c, d, f) { a.each(e, function () { c -= parseFloat(a.curCSS(b, "padding" + this, !0)) || 0, d && (c -= parseFloat(a.curCSS(b, "border" + this + "Width", !0)) || 0), f && (c -= parseFloat(a.curCSS(b, "margin" + this, !0)) || 0) }); return c } var e = d === "Width" ? ["Left", "Right"] : ["Top", "Bottom"], f = d.toLowerCase(), g = { innerWidth: a.fn.innerWidth, innerHeight: a.fn.innerHeight, outerWidth: a.fn.outerWidth, outerHeight: a.fn.outerHeight }; a.fn["inner" + d] = function (c) { if (c === b) return g["inner" + d].call(this); return this.each(function () { a(this).css(f, h(this, c) + "px") }) }, a.fn["outer" + d] = function (b, c) { if (typeof b != "number") return g["outer" + d].call(this, b); return this.each(function () { a(this).css(f, h(this, b, !0, c) + "px") }) } }), a.extend(a.expr[":"], { data: function (b, c, d) { return !!a.data(b, d[3]) }, focusable: function (b) { return c(b, !isNaN(a.attr(b, "tabindex"))) }, tabbable: function (b) { var d = a.attr(b, "tabindex"), e = isNaN(d); return (e || d >= 0) && c(b, !e) } }), a(function () { var b = document.body, c = b.appendChild(c = document.createElement("div")); c.offsetHeight, a.extend(c.style, { minHeight: "100px", height: "auto", padding: 0, borderWidth: 0 }), a.support.minHeight = c.offsetHeight === 100, a.support.selectstart = "onselectstart" in c, b.removeChild(c).style.display = "none" }), a.extend(a.ui, { plugin: { add: function (b, c, d) { var e = a.ui[b].prototype; for (var f in d) e.plugins[f] = e.plugins[f] || [], e.plugins[f].push([c, d[f]]) }, call: function (a, b, c) { var d = a.plugins[b]; if (!!d && !!a.element[0].parentNode) for (var e = 0; e < d.length; e++) a.options[d[e][0]] && d[e][1].apply(a.element, c) } }, contains: function (a, b) { return document.compareDocumentPosition ? a.compareDocumentPosition(b) & 16 : a !== b && a.contains(b) }, hasScroll: function (b, c) { if (a(b).css("overflow") === "hidden") return !1; var d = c && c === "left" ? "scrollLeft" : "scrollTop", e = !1; if (b[d] > 0) return !0; b[d] = 1, e = b[d] > 0, b[d] = 0; return e }, isOverAxis: function (a, b, c) { return a > b && a < b + c }, isOver: function (b, c, d, e, f, g) { return a.ui.isOverAxis(b, d, f) && a.ui.isOverAxis(c, e, g) } })) })(jQuery); /*!
* jQuery UI Widget 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Widget
*/
(function (a, b) { if (a.cleanData) { var c = a.cleanData; a.cleanData = function (b) { for (var d = 0, e; (e = b[d]) != null; d++) try { a(e).triggerHandler("remove") } catch (f) { } c(b) } } else { var d = a.fn.remove; a.fn.remove = function (b, c) { return this.each(function () { c || (!b || a.filter(b, [this]).length) && a("*", this).add([this]).each(function () { try { a(this).triggerHandler("remove") } catch (b) { } }); return d.call(a(this), b, c) }) } } a.widget = function (b, c, d) { var e = b.split(".")[0], f; b = b.split(".")[1], f = e + "-" + b, d || (d = c, c = a.Widget), a.expr[":"][f] = function (c) { return !!a.data(c, b) }, a[e] = a[e] || {}, a[e][b] = function (a, b) { arguments.length && this._createWidget(a, b) }; var g = new c; g.options = a.extend(!0, {}, g.options), a[e][b].prototype = a.extend(!0, g, { namespace: e, widgetName: b, widgetEventPrefix: a[e][b].prototype.widgetEventPrefix || b, widgetBaseClass: f }, d), a.widget.bridge(b, a[e][b]) }, a.widget.bridge = function (c, d) { a.fn[c] = function (e) { var f = typeof e == "string", g = Array.prototype.slice.call(arguments, 1), h = this; e = !f && g.length ? a.extend.apply(null, [!0, e].concat(g)) : e; if (f && e.charAt(0) === "_") return h; f ? this.each(function () { var d = a.data(this, c), f = d && a.isFunction(d[e]) ? d[e].apply(d, g) : d; if (f !== d && f !== b) { h = f; return !1 } }) : this.each(function () { var b = a.data(this, c); b ? b.option(e || {})._init() : a.data(this, c, new d(e, this)) }); return h } }, a.Widget = function (a, b) { arguments.length && this._createWidget(a, b) }, a.Widget.prototype = { widgetName: "widget", widgetEventPrefix: "", options: { disabled: !1 }, _createWidget: function (b, c) { a.data(c, this.widgetName, this), this.element = a(c), this.options = a.extend(!0, {}, this.options, this._getCreateOptions(), b); var d = this; this.element.bind("remove." + this.widgetName, function () { d.destroy() }), this._create(), this._trigger("create"), this._init() }, _getCreateOptions: function () { return a.metadata && a.metadata.get(this.element[0])[this.widgetName] }, _create: function () { }, _init: function () { }, destroy: function () { this.element.unbind("." + this.widgetName).removeData(this.widgetName), this.widget().unbind("." + this.widgetName).removeAttr("aria-disabled").removeClass(this.widgetBaseClass + "-disabled " + "ui-state-disabled") }, widget: function () { return this.element }, option: function (c, d) { var e = c; if (arguments.length === 0) return a.extend({}, this.options); if (typeof c == "string") { if (d === b) return this.options[c]; e = {}, e[c] = d } this._setOptions(e); return this }, _setOptions: function (b) { var c = this; a.each(b, function (a, b) { c._setOption(a, b) }); return this }, _setOption: function (a, b) { this.options[a] = b, a === "disabled" && this.widget()[b ? "addClass" : "removeClass"](this.widgetBaseClass + "-disabled" + " " + "ui-state-disabled").attr("aria-disabled", b); return this }, enable: function () { return this._setOption("disabled", !1) }, disable: function () { return this._setOption("disabled", !0) }, _trigger: function (b, c, d) { var e, f, g = this.options[b]; d = d || {}, c = a.Event(c), c.type = (b === this.widgetEventPrefix ? b : this.widgetEventPrefix + b).toLowerCase(), c.target = this.element[0], f = c.originalEvent; if (f) for (e in f) e in c || (c[e] = f[e]); this.element.trigger(c, d); return !(a.isFunction(g) && g.call(this.element[0], c, d) === !1 || c.isDefaultPrevented()) } } })(jQuery); /*!
* jQuery UI Mouse 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Mouse
*
* Depends:
*	jquery.ui.widget.js
*/
(function (a, b) { var c = !1; a(document).mouseup(function (a) { c = !1 }), a.widget("ui.mouse", { options: { cancel: ":input,option", distance: 1, delay: 0 }, _mouseInit: function () { var b = this; this.element.bind("mousedown." + this.widgetName, function (a) { return b._mouseDown(a) }).bind("click." + this.widgetName, function (c) { if (!0 === a.data(c.target, b.widgetName + ".preventClickEvent")) { a.removeData(c.target, b.widgetName + ".preventClickEvent"), c.stopImmediatePropagation(); return !1 } }), this.started = !1 }, _mouseDestroy: function () { this.element.unbind("." + this.widgetName) }, _mouseDown: function (b) { if (!c) { this._mouseStarted && this._mouseUp(b), this._mouseDownEvent = b; var d = this, e = b.which == 1, f = typeof this.options.cancel == "string" && b.target.nodeName ? a(b.target).closest(this.options.cancel).length : !1; if (!e || f || !this._mouseCapture(b)) return !0; this.mouseDelayMet = !this.options.delay, this.mouseDelayMet || (this._mouseDelayTimer = setTimeout(function () { d.mouseDelayMet = !0 }, this.options.delay)); if (this._mouseDistanceMet(b) && this._mouseDelayMet(b)) { this._mouseStarted = this._mouseStart(b) !== !1; if (!this._mouseStarted) { b.preventDefault(); return !0 } } !0 === a.data(b.target, this.widgetName + ".preventClickEvent") && a.removeData(b.target, this.widgetName + ".preventClickEvent"), this._mouseMoveDelegate = function (a) { return d._mouseMove(a) }, this._mouseUpDelegate = function (a) { return d._mouseUp(a) }, a(document).bind("mousemove." + this.widgetName, this._mouseMoveDelegate).bind("mouseup." + this.widgetName, this._mouseUpDelegate), b.preventDefault(), c = !0; return !0 } }, _mouseMove: function (b) { if (a.browser.msie && !(document.documentMode >= 9) && !b.button) return this._mouseUp(b); if (this._mouseStarted) { this._mouseDrag(b); return b.preventDefault() } this._mouseDistanceMet(b) && this._mouseDelayMet(b) && (this._mouseStarted = this._mouseStart(this._mouseDownEvent, b) !== !1, this._mouseStarted ? this._mouseDrag(b) : this._mouseUp(b)); return !this._mouseStarted }, _mouseUp: function (b) { a(document).unbind("mousemove." + this.widgetName, this._mouseMoveDelegate).unbind("mouseup." + this.widgetName, this._mouseUpDelegate), this._mouseStarted && (this._mouseStarted = !1, b.target == this._mouseDownEvent.target && a.data(b.target, this.widgetName + ".preventClickEvent", !0), this._mouseStop(b)); return !1 }, _mouseDistanceMet: function (a) { return Math.max(Math.abs(this._mouseDownEvent.pageX - a.pageX), Math.abs(this._mouseDownEvent.pageY - a.pageY)) >= this.options.distance }, _mouseDelayMet: function (a) { return this.mouseDelayMet }, _mouseStart: function (a) { }, _mouseDrag: function (a) { }, _mouseStop: function (a) { }, _mouseCapture: function (a) { return !0 } }) })(jQuery); /*
* jQuery UI Position 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Position
*/
(function (a, b) { a.ui = a.ui || {}; var c = /left|center|right/, d = /top|center|bottom/, e = "center", f = {}, g = a.fn.position, h = a.fn.offset; a.fn.position = function (b) { if (!b || !b.of) return g.apply(this, arguments); b = a.extend({}, b); var h = a(b.of), i = h[0], j = (b.collision || "flip").split(" "), k = b.offset ? b.offset.split(" ") : [0, 0], l, m, n; i.nodeType === 9 ? (l = h.width(), m = h.height(), n = { top: 0, left: 0 }) : i.setTimeout ? (l = h.width(), m = h.height(), n = { top: h.scrollTop(), left: h.scrollLeft() }) : i.preventDefault ? (b.at = "left top", l = m = 0, n = { top: b.of.pageY, left: b.of.pageX }) : (l = h.outerWidth(), m = h.outerHeight(), n = h.offset()), a.each(["my", "at"], function () { var a = (b[this] || "").split(" "); a.length === 1 && (a = c.test(a[0]) ? a.concat([e]) : d.test(a[0]) ? [e].concat(a) : [e, e]), a[0] = c.test(a[0]) ? a[0] : e, a[1] = d.test(a[1]) ? a[1] : e, b[this] = a }), j.length === 1 && (j[1] = j[0]), k[0] = parseInt(k[0], 10) || 0, k.length === 1 && (k[1] = k[0]), k[1] = parseInt(k[1], 10) || 0, b.at[0] === "right" ? n.left += l : b.at[0] === e && (n.left += l / 2), b.at[1] === "bottom" ? n.top += m : b.at[1] === e && (n.top += m / 2), n.left += k[0], n.top += k[1]; return this.each(function () { var c = a(this), d = c.outerWidth(), g = c.outerHeight(), h = parseInt(a.curCSS(this, "marginLeft", !0)) || 0, i = parseInt(a.curCSS(this, "marginTop", !0)) || 0, o = d + h + (parseInt(a.curCSS(this, "marginRight", !0)) || 0), p = g + i + (parseInt(a.curCSS(this, "marginBottom", !0)) || 0), q = a.extend({}, n), r; b.my[0] === "right" ? q.left -= d : b.my[0] === e && (q.left -= d / 2), b.my[1] === "bottom" ? q.top -= g : b.my[1] === e && (q.top -= g / 2), f.fractions || (q.left = Math.round(q.left), q.top = Math.round(q.top)), r = { left: q.left - h, top: q.top - i }, a.each(["left", "top"], function (c, e) { a.ui.position[j[c]] && a.ui.position[j[c]][e](q, { targetWidth: l, targetHeight: m, elemWidth: d, elemHeight: g, collisionPosition: r, collisionWidth: o, collisionHeight: p, offset: k, my: b.my, at: b.at }) }), a.fn.bgiframe && c.bgiframe(), c.offset(a.extend(q, { using: b.using })) }) }, a.ui.position = { fit: { left: function (b, c) { var d = a(window), e = c.collisionPosition.left + c.collisionWidth - d.width() - d.scrollLeft(); b.left = e > 0 ? b.left - e : Math.max(b.left - c.collisionPosition.left, b.left) }, top: function (b, c) { var d = a(window), e = c.collisionPosition.top + c.collisionHeight - d.height() - d.scrollTop(); b.top = e > 0 ? b.top - e : Math.max(b.top - c.collisionPosition.top, b.top) } }, flip: { left: function (b, c) { if (c.at[0] !== e) { var d = a(window), f = c.collisionPosition.left + c.collisionWidth - d.width() - d.scrollLeft(), g = c.my[0] === "left" ? -c.elemWidth : c.my[0] === "right" ? c.elemWidth : 0, h = c.at[0] === "left" ? c.targetWidth : -c.targetWidth, i = -2 * c.offset[0]; b.left += c.collisionPosition.left < 0 ? g + h + i : f > 0 ? g + h + i : 0 } }, top: function (b, c) { if (c.at[1] !== e) { var d = a(window), f = c.collisionPosition.top + c.collisionHeight - d.height() - d.scrollTop(), g = c.my[1] === "top" ? -c.elemHeight : c.my[1] === "bottom" ? c.elemHeight : 0, h = c.at[1] === "top" ? c.targetHeight : -c.targetHeight, i = -2 * c.offset[1]; b.top += c.collisionPosition.top < 0 ? g + h + i : f > 0 ? g + h + i : 0 } } } }, a.offset.setOffset || (a.offset.setOffset = function (b, c) { /static/.test(a.curCSS(b, "position")) && (b.style.position = "relative"); var d = a(b), e = d.offset(), f = parseInt(a.curCSS(b, "top", !0), 10) || 0, g = parseInt(a.curCSS(b, "left", !0), 10) || 0, h = { top: c.top - e.top + f, left: c.left - e.left + g }; "using" in c ? c.using.call(b, h) : d.css(h) }, a.fn.offset = function (b) { var c = this[0]; if (!c || !c.ownerDocument) return null; if (b) return this.each(function () { a.offset.setOffset(this, b) }); return h.call(this) }), function () { var b = document.getElementsByTagName("body")[0], c = document.createElement("div"), d, e, g, h, i; d = document.createElement(b ? "div" : "body"), g = { visibility: "hidden", width: 0, height: 0, border: 0, margin: 0, background: "none" }, b && a.extend(g, { position: "absolute", left: "-1000px", top: "-1000px" }); for (var j in g) d.style[j] = g[j]; d.appendChild(c), e = b || document.documentElement, e.insertBefore(d, e.firstChild), c.style.cssText = "position: absolute; left: 10.7432222px; top: 10.432325px; height: 30px; width: 201px;", h = a(c).offset(function (a, b) { return b }).offset(), d.innerHTML = "", e.removeChild(d), i = h.top + h.left + (b ? 2e3 : 0), f.fractions = i > 21 && i < 22 } () })(jQuery); /*
* jQuery UI Draggable 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Draggables
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.mouse.js
*	jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.draggable", a.ui.mouse, { widgetEventPrefix: "drag", options: { addClasses: !0, appendTo: "parent", axis: !1, connectToSortable: !1, containment: !1, cursor: "auto", cursorAt: !1, grid: !1, handle: !1, helper: "original", iframeFix: !1, opacity: !1, refreshPositions: !1, revert: !1, revertDuration: 500, scope: "default", scroll: !0, scrollSensitivity: 20, scrollSpeed: 20, snap: !1, snapMode: "both", snapTolerance: 20, stack: !1, zIndex: !1 }, _create: function () { this.options.helper == "original" && !/^(?:r|a|f)/.test(this.element.css("position")) && (this.element[0].style.position = "relative"), this.options.addClasses && this.element.addClass("ui-draggable"), this.options.disabled && this.element.addClass("ui-draggable-disabled"), this._mouseInit() }, destroy: function () { if (!!this.element.data("draggable")) { this.element.removeData("draggable").unbind(".draggable").removeClass("ui-draggable ui-draggable-dragging ui-draggable-disabled"), this._mouseDestroy(); return this } }, _mouseCapture: function (b) { var c = this.options; if (this.helper || c.disabled || a(b.target).is(".ui-resizable-handle")) return !1; this.handle = this._getHandle(b); if (!this.handle) return !1; c.iframeFix && a(c.iframeFix === !0 ? "iframe" : c.iframeFix).each(function () { a('<div class="ui-draggable-iframeFix" style="background: #fff;"></div>').css({ width: this.offsetWidth + "px", height: this.offsetHeight + "px", position: "absolute", opacity: "0.001", zIndex: 1e3 }).css(a(this).offset()).appendTo("body") }); return !0 }, _mouseStart: function (b) { var c = this.options; this.helper = this._createHelper(b), this._cacheHelperProportions(), a.ui.ddmanager && (a.ui.ddmanager.current = this), this._cacheMargins(), this.cssPosition = this.helper.css("position"), this.scrollParent = this.helper.scrollParent(), this.offset = this.positionAbs = this.element.offset(), this.offset = { top: this.offset.top - this.margins.top, left: this.offset.left - this.margins.left }, a.extend(this.offset, { click: { left: b.pageX - this.offset.left, top: b.pageY - this.offset.top }, parent: this._getParentOffset(), relative: this._getRelativeOffset() }), this.originalPosition = this.position = this._generatePosition(b), this.originalPageX = b.pageX, this.originalPageY = b.pageY, c.cursorAt && this._adjustOffsetFromHelper(c.cursorAt), c.containment && this._setContainment(); if (this._trigger("start", b) === !1) { this._clear(); return !1 } this._cacheHelperProportions(), a.ui.ddmanager && !c.dropBehaviour && a.ui.ddmanager.prepareOffsets(this, b), this.helper.addClass("ui-draggable-dragging"), this._mouseDrag(b, !0), a.ui.ddmanager && a.ui.ddmanager.dragStart(this, b); return !0 }, _mouseDrag: function (b, c) { this.position = this._generatePosition(b), this.positionAbs = this._convertPositionTo("absolute"); if (!c) { var d = this._uiHash(); if (this._trigger("drag", b, d) === !1) { this._mouseUp({}); return !1 } this.position = d.position } if (!this.options.axis || this.options.axis != "y") this.helper[0].style.left = this.position.left + "px"; if (!this.options.axis || this.options.axis != "x") this.helper[0].style.top = this.position.top + "px"; a.ui.ddmanager && a.ui.ddmanager.drag(this, b); return !1 }, _mouseStop: function (b) { var c = !1; a.ui.ddmanager && !this.options.dropBehaviour && (c = a.ui.ddmanager.drop(this, b)), this.dropped && (c = this.dropped, this.dropped = !1); if ((!this.element[0] || !this.element[0].parentNode) && this.options.helper == "original") return !1; if (this.options.revert == "invalid" && !c || this.options.revert == "valid" && c || this.options.revert === !0 || a.isFunction(this.options.revert) && this.options.revert.call(this.element, c)) { var d = this; a(this.helper).animate(this.originalPosition, parseInt(this.options.revertDuration, 10), function () { d._trigger("stop", b) !== !1 && d._clear() }) } else this._trigger("stop", b) !== !1 && this._clear(); return !1 }, _mouseUp: function (b) { this.options.iframeFix === !0 && a("div.ui-draggable-iframeFix").each(function () { this.parentNode.removeChild(this) }), a.ui.ddmanager && a.ui.ddmanager.dragStop(this, b); return a.ui.mouse.prototype._mouseUp.call(this, b) }, cancel: function () { this.helper.is(".ui-draggable-dragging") ? this._mouseUp({}) : this._clear(); return this }, _getHandle: function (b) { var c = !this.options.handle || !a(this.options.handle, this.element).length ? !0 : !1; a(this.options.handle, this.element).find("*").andSelf().each(function () { this == b.target && (c = !0) }); return c }, _createHelper: function (b) { var c = this.options, d = a.isFunction(c.helper) ? a(c.helper.apply(this.element[0], [b])) : c.helper == "clone" ? this.element.clone().removeAttr("id") : this.element; d.parents("body").length || d.appendTo(c.appendTo == "parent" ? this.element[0].parentNode : c.appendTo), d[0] != this.element[0] && !/(fixed|absolute)/.test(d.css("position")) && d.css("position", "absolute"); return d }, _adjustOffsetFromHelper: function (b) { typeof b == "string" && (b = b.split(" ")), a.isArray(b) && (b = { left: +b[0], top: +b[1] || 0 }), "left" in b && (this.offset.click.left = b.left + this.margins.left), "right" in b && (this.offset.click.left = this.helperProportions.width - b.right + this.margins.left), "top" in b && (this.offset.click.top = b.top + this.margins.top), "bottom" in b && (this.offset.click.top = this.helperProportions.height - b.bottom + this.margins.top) }, _getParentOffset: function () { this.offsetParent = this.helper.offsetParent(); var b = this.offsetParent.offset(); this.cssPosition == "absolute" && this.scrollParent[0] != document && a.ui.contains(this.scrollParent[0], this.offsetParent[0]) && (b.left += this.scrollParent.scrollLeft(), b.top += this.scrollParent.scrollTop()); if (this.offsetParent[0] == document.body || this.offsetParent[0].tagName && this.offsetParent[0].tagName.toLowerCase() == "html" && a.browser.msie) b = { top: 0, left: 0 }; return { top: b.top + (parseInt(this.offsetParent.css("borderTopWidth"), 10) || 0), left: b.left + (parseInt(this.offsetParent.css("borderLeftWidth"), 10) || 0)} }, _getRelativeOffset: function () { if (this.cssPosition == "relative") { var a = this.element.position(); return { top: a.top - (parseInt(this.helper.css("top"), 10) || 0) + this.scrollParent.scrollTop(), left: a.left - (parseInt(this.helper.css("left"), 10) || 0) + this.scrollParent.scrollLeft()} } return { top: 0, left: 0} }, _cacheMargins: function () { this.margins = { left: parseInt(this.element.css("marginLeft"), 10) || 0, top: parseInt(this.element.css("marginTop"), 10) || 0, right: parseInt(this.element.css("marginRight"), 10) || 0, bottom: parseInt(this.element.css("marginBottom"), 10) || 0} }, _cacheHelperProportions: function () { this.helperProportions = { width: this.helper.outerWidth(), height: this.helper.outerHeight()} }, _setContainment: function () { var b = this.options; b.containment == "parent" && (b.containment = this.helper[0].parentNode); if (b.containment == "document" || b.containment == "window") this.containment = [b.containment == "document" ? 0 : a(window).scrollLeft() - this.offset.relative.left - this.offset.parent.left, b.containment == "document" ? 0 : a(window).scrollTop() - this.offset.relative.top - this.offset.parent.top, (b.containment == "document" ? 0 : a(window).scrollLeft()) + a(b.containment == "document" ? document : window).width() - this.helperProportions.width - this.margins.left, (b.containment == "document" ? 0 : a(window).scrollTop()) + (a(b.containment == "document" ? document : window).height() || document.body.parentNode.scrollHeight) - this.helperProportions.height - this.margins.top]; if (!/^(document|window|parent)$/.test(b.containment) && b.containment.constructor != Array) { var c = a(b.containment), d = c[0]; if (!d) return; var e = c.offset(), f = a(d).css("overflow") != "hidden"; this.containment = [(parseInt(a(d).css("borderLeftWidth"), 10) || 0) + (parseInt(a(d).css("paddingLeft"), 10) || 0), (parseInt(a(d).css("borderTopWidth"), 10) || 0) + (parseInt(a(d).css("paddingTop"), 10) || 0), (f ? Math.max(d.scrollWidth, d.offsetWidth) : d.offsetWidth) - (parseInt(a(d).css("borderLeftWidth"), 10) || 0) - (parseInt(a(d).css("paddingRight"), 10) || 0) - this.helperProportions.width - this.margins.left - this.margins.right, (f ? Math.max(d.scrollHeight, d.offsetHeight) : d.offsetHeight) - (parseInt(a(d).css("borderTopWidth"), 10) || 0) - (parseInt(a(d).css("paddingBottom"), 10) || 0) - this.helperProportions.height - this.margins.top - this.margins.bottom], this.relative_container = c } else b.containment.constructor == Array && (this.containment = b.containment) }, _convertPositionTo: function (b, c) { c || (c = this.position); var d = b == "absolute" ? 1 : -1, e = this.options, f = this.cssPosition == "absolute" && (this.scrollParent[0] == document || !a.ui.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, g = /(html|body)/i.test(f[0].tagName); return { top: c.top + this.offset.relative.top * d + this.offset.parent.top * d - (a.browser.safari && a.browser.version < 526 && this.cssPosition == "fixed" ? 0 : (this.cssPosition == "fixed" ? -this.scrollParent.scrollTop() : g ? 0 : f.scrollTop()) * d), left: c.left + this.offset.relative.left * d + this.offset.parent.left * d - (a.browser.safari && a.browser.version < 526 && this.cssPosition == "fixed" ? 0 : (this.cssPosition == "fixed" ? -this.scrollParent.scrollLeft() : g ? 0 : f.scrollLeft()) * d)} }, _generatePosition: function (b) { var c = this.options, d = this.cssPosition == "absolute" && (this.scrollParent[0] == document || !a.ui.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, e = /(html|body)/i.test(d[0].tagName), f = b.pageX, g = b.pageY; if (this.originalPosition) { var h; if (this.containment) { if (this.relative_container) { var i = this.relative_container.offset(); h = [this.containment[0] + i.left, this.containment[1] + i.top, this.containment[2] + i.left, this.containment[3] + i.top] } else h = this.containment; b.pageX - this.offset.click.left < h[0] && (f = h[0] + this.offset.click.left), b.pageY - this.offset.click.top < h[1] && (g = h[1] + this.offset.click.top), b.pageX - this.offset.click.left > h[2] && (f = h[2] + this.offset.click.left), b.pageY - this.offset.click.top > h[3] && (g = h[3] + this.offset.click.top) } if (c.grid) { var j = c.grid[1] ? this.originalPageY + Math.round((g - this.originalPageY) / c.grid[1]) * c.grid[1] : this.originalPageY; g = h ? j - this.offset.click.top < h[1] || j - this.offset.click.top > h[3] ? j - this.offset.click.top < h[1] ? j + c.grid[1] : j - c.grid[1] : j : j; var k = c.grid[0] ? this.originalPageX + Math.round((f - this.originalPageX) / c.grid[0]) * c.grid[0] : this.originalPageX; f = h ? k - this.offset.click.left < h[0] || k - this.offset.click.left > h[2] ? k - this.offset.click.left < h[0] ? k + c.grid[0] : k - c.grid[0] : k : k } } return { top: g - this.offset.click.top - this.offset.relative.top - this.offset.parent.top + (a.browser.safari && a.browser.version < 526 && this.cssPosition == "fixed" ? 0 : this.cssPosition == "fixed" ? -this.scrollParent.scrollTop() : e ? 0 : d.scrollTop()), left: f - this.offset.click.left - this.offset.relative.left - this.offset.parent.left + (a.browser.safari && a.browser.version < 526 && this.cssPosition == "fixed" ? 0 : this.cssPosition == "fixed" ? -this.scrollParent.scrollLeft() : e ? 0 : d.scrollLeft())} }, _clear: function () { this.helper.removeClass("ui-draggable-dragging"), this.helper[0] != this.element[0] && !this.cancelHelperRemoval && this.helper.remove(), this.helper = null, this.cancelHelperRemoval = !1 }, _trigger: function (b, c, d) { d = d || this._uiHash(), a.ui.plugin.call(this, b, [c, d]), b == "drag" && (this.positionAbs = this._convertPositionTo("absolute")); return a.Widget.prototype._trigger.call(this, b, c, d) }, plugins: {}, _uiHash: function (a) { return { helper: this.helper, position: this.position, originalPosition: this.originalPosition, offset: this.positionAbs} } }), a.extend(a.ui.draggable, { version: "1.8.18" }), a.ui.plugin.add("draggable", "connectToSortable", { start: function (b, c) { var d = a(this).data("draggable"), e = d.options, f = a.extend({}, c, { item: d.element }); d.sortables = [], a(e.connectToSortable).each(function () { var c = a.data(this, "sortable"); c && !c.options.disabled && (d.sortables.push({ instance: c, shouldRevert: c.options.revert }), c.refreshPositions(), c._trigger("activate", b, f)) }) }, stop: function (b, c) { var d = a(this).data("draggable"), e = a.extend({}, c, { item: d.element }); a.each(d.sortables, function () { this.instance.isOver ? (this.instance.isOver = 0, d.cancelHelperRemoval = !0, this.instance.cancelHelperRemoval = !1, this.shouldRevert && (this.instance.options.revert = !0), this.instance._mouseStop(b), this.instance.options.helper = this.instance.options._helper, d.options.helper == "original" && this.instance.currentItem.css({ top: "auto", left: "auto" })) : (this.instance.cancelHelperRemoval = !1, this.instance._trigger("deactivate", b, e)) }) }, drag: function (b, c) { var d = a(this).data("draggable"), e = this, f = function (b) { var c = this.offset.click.top, d = this.offset.click.left, e = this.positionAbs.top, f = this.positionAbs.left, g = b.height, h = b.width, i = b.top, j = b.left; return a.ui.isOver(e + c, f + d, i, j, g, h) }; a.each(d.sortables, function (f) { this.instance.positionAbs = d.positionAbs, this.instance.helperProportions = d.helperProportions, this.instance.offset.click = d.offset.click, this.instance._intersectsWith(this.instance.containerCache) ? (this.instance.isOver || (this.instance.isOver = 1, this.instance.currentItem = a(e).clone().removeAttr("id").appendTo(this.instance.element).data("sortable-item", !0), this.instance.options._helper = this.instance.options.helper, this.instance.options.helper = function () { return c.helper[0] }, b.target = this.instance.currentItem[0], this.instance._mouseCapture(b, !0), this.instance._mouseStart(b, !0, !0), this.instance.offset.click.top = d.offset.click.top, this.instance.offset.click.left = d.offset.click.left, this.instance.offset.parent.left -= d.offset.parent.left - this.instance.offset.parent.left, this.instance.offset.parent.top -= d.offset.parent.top - this.instance.offset.parent.top, d._trigger("toSortable", b), d.dropped = this.instance.element, d.currentItem = d.element, this.instance.fromOutside = d), this.instance.currentItem && this.instance._mouseDrag(b)) : this.instance.isOver && (this.instance.isOver = 0, this.instance.cancelHelperRemoval = !0, this.instance.options.revert = !1, this.instance._trigger("out", b, this.instance._uiHash(this.instance)), this.instance._mouseStop(b, !0), this.instance.options.helper = this.instance.options._helper, this.instance.currentItem.remove(), this.instance.placeholder && this.instance.placeholder.remove(), d._trigger("fromSortable", b), d.dropped = !1) }) } }), a.ui.plugin.add("draggable", "cursor", { start: function (b, c) { var d = a("body"), e = a(this).data("draggable").options; d.css("cursor") && (e._cursor = d.css("cursor")), d.css("cursor", e.cursor) }, stop: function (b, c) { var d = a(this).data("draggable").options; d._cursor && a("body").css("cursor", d._cursor) } }), a.ui.plugin.add("draggable", "opacity", { start: function (b, c) { var d = a(c.helper), e = a(this).data("draggable").options; d.css("opacity") && (e._opacity = d.css("opacity")), d.css("opacity", e.opacity) }, stop: function (b, c) { var d = a(this).data("draggable").options; d._opacity && a(c.helper).css("opacity", d._opacity) } }), a.ui.plugin.add("draggable", "scroll", { start: function (b, c) { var d = a(this).data("draggable"); d.scrollParent[0] != document && d.scrollParent[0].tagName != "HTML" && (d.overflowOffset = d.scrollParent.offset()) }, drag: function (b, c) { var d = a(this).data("draggable"), e = d.options, f = !1; if (d.scrollParent[0] != document && d.scrollParent[0].tagName != "HTML") { if (!e.axis || e.axis != "x") d.overflowOffset.top + d.scrollParent[0].offsetHeight - b.pageY < e.scrollSensitivity ? d.scrollParent[0].scrollTop = f = d.scrollParent[0].scrollTop + e.scrollSpeed : b.pageY - d.overflowOffset.top < e.scrollSensitivity && (d.scrollParent[0].scrollTop = f = d.scrollParent[0].scrollTop - e.scrollSpeed); if (!e.axis || e.axis != "y") d.overflowOffset.left + d.scrollParent[0].offsetWidth - b.pageX < e.scrollSensitivity ? d.scrollParent[0].scrollLeft = f = d.scrollParent[0].scrollLeft + e.scrollSpeed : b.pageX - d.overflowOffset.left < e.scrollSensitivity && (d.scrollParent[0].scrollLeft = f = d.scrollParent[0].scrollLeft - e.scrollSpeed) } else { if (!e.axis || e.axis != "x") b.pageY - a(document).scrollTop() < e.scrollSensitivity ? f = a(document).scrollTop(a(document).scrollTop() - e.scrollSpeed) : a(window).height() - (b.pageY - a(document).scrollTop()) < e.scrollSensitivity && (f = a(document).scrollTop(a(document).scrollTop() + e.scrollSpeed)); if (!e.axis || e.axis != "y") b.pageX - a(document).scrollLeft() < e.scrollSensitivity ? f = a(document).scrollLeft(a(document).scrollLeft() - e.scrollSpeed) : a(window).width() - (b.pageX - a(document).scrollLeft()) < e.scrollSensitivity && (f = a(document).scrollLeft(a(document).scrollLeft() + e.scrollSpeed)) } f !== !1 && a.ui.ddmanager && !e.dropBehaviour && a.ui.ddmanager.prepareOffsets(d, b) } }), a.ui.plugin.add("draggable", "snap", { start: function (b, c) { var d = a(this).data("draggable"), e = d.options; d.snapElements = [], a(e.snap.constructor != String ? e.snap.items || ":data(draggable)" : e.snap).each(function () { var b = a(this), c = b.offset(); this != d.element[0] && d.snapElements.push({ item: this, width: b.outerWidth(), height: b.outerHeight(), top: c.top, left: c.left }) }) }, drag: function (b, c) { var d = a(this).data("draggable"), e = d.options, f = e.snapTolerance, g = c.offset.left, h = g + d.helperProportions.width, i = c.offset.top, j = i + d.helperProportions.height; for (var k = d.snapElements.length - 1; k >= 0; k--) { var l = d.snapElements[k].left, m = l + d.snapElements[k].width, n = d.snapElements[k].top, o = n + d.snapElements[k].height; if (!(l - f < g && g < m + f && n - f < i && i < o + f || l - f < g && g < m + f && n - f < j && j < o + f || l - f < h && h < m + f && n - f < i && i < o + f || l - f < h && h < m + f && n - f < j && j < o + f)) { d.snapElements[k].snapping && d.options.snap.release && d.options.snap.release.call(d.element, b, a.extend(d._uiHash(), { snapItem: d.snapElements[k].item })), d.snapElements[k].snapping = !1; continue } if (e.snapMode != "inner") { var p = Math.abs(n - j) <= f, q = Math.abs(o - i) <= f, r = Math.abs(l - h) <= f, s = Math.abs(m - g) <= f; p && (c.position.top = d._convertPositionTo("relative", { top: n - d.helperProportions.height, left: 0 }).top - d.margins.top), q && (c.position.top = d._convertPositionTo("relative", { top: o, left: 0 }).top - d.margins.top), r && (c.position.left = d._convertPositionTo("relative", { top: 0, left: l - d.helperProportions.width }).left - d.margins.left), s && (c.position.left = d._convertPositionTo("relative", { top: 0, left: m }).left - d.margins.left) } var t = p || q || r || s; if (e.snapMode != "outer") { var p = Math.abs(n - i) <= f, q = Math.abs(o - j) <= f, r = Math.abs(l - g) <= f, s = Math.abs(m - h) <= f; p && (c.position.top = d._convertPositionTo("relative", { top: n, left: 0 }).top - d.margins.top), q && (c.position.top = d._convertPositionTo("relative", { top: o - d.helperProportions.height, left: 0 }).top - d.margins.top), r && (c.position.left = d._convertPositionTo("relative", { top: 0, left: l }).left - d.margins.left), s && (c.position.left = d._convertPositionTo("relative", { top: 0, left: m - d.helperProportions.width }).left - d.margins.left) } !d.snapElements[k].snapping && (p || q || r || s || t) && d.options.snap.snap && d.options.snap.snap.call(d.element, b, a.extend(d._uiHash(), { snapItem: d.snapElements[k].item })), d.snapElements[k].snapping = p || q || r || s || t } } }), a.ui.plugin.add("draggable", "stack", { start: function (b, c) { var d = a(this).data("draggable").options, e = a.makeArray(a(d.stack)).sort(function (b, c) { return (parseInt(a(b).css("zIndex"), 10) || 0) - (parseInt(a(c).css("zIndex"), 10) || 0) }); if (!!e.length) { var f = parseInt(e[0].style.zIndex) || 0; a(e).each(function (a) { this.style.zIndex = f + a }), this[0].style.zIndex = f + e.length } } }), a.ui.plugin.add("draggable", "zIndex", { start: function (b, c) { var d = a(c.helper), e = a(this).data("draggable").options; d.css("zIndex") && (e._zIndex = d.css("zIndex")), d.css("zIndex", e.zIndex) }, stop: function (b, c) { var d = a(this).data("draggable").options; d._zIndex && a(c.helper).css("zIndex", d._zIndex) } }) })(jQuery); /*
* jQuery UI Droppable 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Droppables
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*	jquery.ui.mouse.js
*	jquery.ui.draggable.js
*/
(function (a, b) { a.widget("ui.droppable", { widgetEventPrefix: "drop", options: { accept: "*", activeClass: !1, addClasses: !0, greedy: !1, hoverClass: !1, scope: "default", tolerance: "intersect" }, _create: function () { var b = this.options, c = b.accept; this.isover = 0, this.isout = 1, this.accept = a.isFunction(c) ? c : function (a) { return a.is(c) }, this.proportions = { width: this.element[0].offsetWidth, height: this.element[0].offsetHeight }, a.ui.ddmanager.droppables[b.scope] = a.ui.ddmanager.droppables[b.scope] || [], a.ui.ddmanager.droppables[b.scope].push(this), b.addClasses && this.element.addClass("ui-droppable") }, destroy: function () { var b = a.ui.ddmanager.droppables[this.options.scope]; for (var c = 0; c < b.length; c++) b[c] == this && b.splice(c, 1); this.element.removeClass("ui-droppable ui-droppable-disabled").removeData("droppable").unbind(".droppable"); return this }, _setOption: function (b, c) { b == "accept" && (this.accept = a.isFunction(c) ? c : function (a) { return a.is(c) }), a.Widget.prototype._setOption.apply(this, arguments) }, _activate: function (b) { var c = a.ui.ddmanager.current; this.options.activeClass && this.element.addClass(this.options.activeClass), c && this._trigger("activate", b, this.ui(c)) }, _deactivate: function (b) { var c = a.ui.ddmanager.current; this.options.activeClass && this.element.removeClass(this.options.activeClass), c && this._trigger("deactivate", b, this.ui(c)) }, _over: function (b) { var c = a.ui.ddmanager.current; !!c && (c.currentItem || c.element)[0] != this.element[0] && this.accept.call(this.element[0], c.currentItem || c.element) && (this.options.hoverClass && this.element.addClass(this.options.hoverClass), this._trigger("over", b, this.ui(c))) }, _out: function (b) { var c = a.ui.ddmanager.current; !!c && (c.currentItem || c.element)[0] != this.element[0] && this.accept.call(this.element[0], c.currentItem || c.element) && (this.options.hoverClass && this.element.removeClass(this.options.hoverClass), this._trigger("out", b, this.ui(c))) }, _drop: function (b, c) { var d = c || a.ui.ddmanager.current; if (!d || (d.currentItem || d.element)[0] == this.element[0]) return !1; var e = !1; this.element.find(":data(droppable)").not(".ui-draggable-dragging").each(function () { var b = a.data(this, "droppable"); if (b.options.greedy && !b.options.disabled && b.options.scope == d.options.scope && b.accept.call(b.element[0], d.currentItem || d.element) && a.ui.intersect(d, a.extend(b, { offset: b.element.offset() }), b.options.tolerance)) { e = !0; return !1 } }); if (e) return !1; if (this.accept.call(this.element[0], d.currentItem || d.element)) { this.options.activeClass && this.element.removeClass(this.options.activeClass), this.options.hoverClass && this.element.removeClass(this.options.hoverClass), this._trigger("drop", b, this.ui(d)); return this.element } return !1 }, ui: function (a) { return { draggable: a.currentItem || a.element, helper: a.helper, position: a.position, offset: a.positionAbs} } }), a.extend(a.ui.droppable, { version: "1.8.18" }), a.ui.intersect = function (b, c, d) { if (!c.offset) return !1; var e = (b.positionAbs || b.position.absolute).left, f = e + b.helperProportions.width, g = (b.positionAbs || b.position.absolute).top, h = g + b.helperProportions.height, i = c.offset.left, j = i + c.proportions.width, k = c.offset.top, l = k + c.proportions.height; switch (d) { case "fit": return i <= e && f <= j && k <= g && h <= l; case "intersect": return i < e + b.helperProportions.width / 2 && f - b.helperProportions.width / 2 < j && k < g + b.helperProportions.height / 2 && h - b.helperProportions.height / 2 < l; case "pointer": var m = (b.positionAbs || b.position.absolute).left + (b.clickOffset || b.offset.click).left, n = (b.positionAbs || b.position.absolute).top + (b.clickOffset || b.offset.click).top, o = a.ui.isOver(n, m, k, i, c.proportions.height, c.proportions.width); return o; case "touch": return (g >= k && g <= l || h >= k && h <= l || g < k && h > l) && (e >= i && e <= j || f >= i && f <= j || e < i && f > j); default: return !1 } }, a.ui.ddmanager = { current: null, droppables: { "default": [] }, prepareOffsets: function (b, c) { var d = a.ui.ddmanager.droppables[b.options.scope] || [], e = c ? c.type : null, f = (b.currentItem || b.element).find(":data(droppable)").andSelf(); droppablesLoop: for (var g = 0; g < d.length; g++) { if (d[g].options.disabled || b && !d[g].accept.call(d[g].element[0], b.currentItem || b.element)) continue; for (var h = 0; h < f.length; h++) if (f[h] == d[g].element[0]) { d[g].proportions.height = 0; continue droppablesLoop } d[g].visible = d[g].element.css("display") != "none"; if (!d[g].visible) continue; e == "mousedown" && d[g]._activate.call(d[g], c), d[g].offset = d[g].element.offset(), d[g].proportions = { width: d[g].element[0].offsetWidth, height: d[g].element[0].offsetHeight} } }, drop: function (b, c) { var d = !1; a.each(a.ui.ddmanager.droppables[b.options.scope] || [], function () { !this.options || (!this.options.disabled && this.visible && a.ui.intersect(b, this, this.options.tolerance) && (d = this._drop.call(this, c) || d), !this.options.disabled && this.visible && this.accept.call(this.element[0], b.currentItem || b.element) && (this.isout = 1, this.isover = 0, this._deactivate.call(this, c))) }); return d }, dragStart: function (b, c) { b.element.parents(":not(body,html)").bind("scroll.droppable", function () { b.options.refreshPositions || a.ui.ddmanager.prepareOffsets(b, c) }) }, drag: function (b, c) { b.options.refreshPositions && a.ui.ddmanager.prepareOffsets(b, c), a.each(a.ui.ddmanager.droppables[b.options.scope] || [], function () { if (!(this.options.disabled || this.greedyChild || !this.visible)) { var d = a.ui.intersect(b, this, this.options.tolerance), e = !d && this.isover == 1 ? "isout" : d && this.isover == 0 ? "isover" : null; if (!e) return; var f; if (this.options.greedy) { var g = this.element.parents(":data(droppable):eq(0)"); g.length && (f = a.data(g[0], "droppable"), f.greedyChild = e == "isover" ? 1 : 0) } f && e == "isover" && (f.isover = 0, f.isout = 1, f._out.call(f, c)), this[e] = 1, this[e == "isout" ? "isover" : "isout"] = 0, this[e == "isover" ? "_over" : "_out"].call(this, c), f && e == "isout" && (f.isout = 0, f.isover = 1, f._over.call(f, c)) } }) }, dragStop: function (b, c) { b.element.parents(":not(body,html)").unbind("scroll.droppable"), b.options.refreshPositions || a.ui.ddmanager.prepareOffsets(b, c) } } })(jQuery); /*
* jQuery UI Resizable 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Resizables
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.mouse.js
*	jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.resizable", a.ui.mouse, { widgetEventPrefix: "resize", options: { alsoResize: !1, animate: !1, animateDuration: "slow", animateEasing: "swing", aspectRatio: !1, autoHide: !1, containment: !1, ghost: !1, grid: !1, handles: "e,s,se", helper: !1, maxHeight: null, maxWidth: null, minHeight: 10, minWidth: 10, zIndex: 1e3 }, _create: function () { var b = this, c = this.options; this.element.addClass("ui-resizable"), a.extend(this, { _aspectRatio: !!c.aspectRatio, aspectRatio: c.aspectRatio, originalElement: this.element, _proportionallyResizeElements: [], _helper: c.helper || c.ghost || c.animate ? c.helper || "ui-resizable-helper" : null }), this.element[0].nodeName.match(/canvas|textarea|input|select|button|img/i) && (this.element.wrap(a('<div class="ui-wrapper" style="overflow: hidden;"></div>').css({ position: this.element.css("position"), width: this.element.outerWidth(), height: this.element.outerHeight(), top: this.element.css("top"), left: this.element.css("left") })), this.element = this.element.parent().data("resizable", this.element.data("resizable")), this.elementIsWrapper = !0, this.element.css({ marginLeft: this.originalElement.css("marginLeft"), marginTop: this.originalElement.css("marginTop"), marginRight: this.originalElement.css("marginRight"), marginBottom: this.originalElement.css("marginBottom") }), this.originalElement.css({ marginLeft: 0, marginTop: 0, marginRight: 0, marginBottom: 0 }), this.originalResizeStyle = this.originalElement.css("resize"), this.originalElement.css("resize", "none"), this._proportionallyResizeElements.push(this.originalElement.css({ position: "static", zoom: 1, display: "block" })), this.originalElement.css({ margin: this.originalElement.css("margin") }), this._proportionallyResize()), this.handles = c.handles || (a(".ui-resizable-handle", this.element).length ? { n: ".ui-resizable-n", e: ".ui-resizable-e", s: ".ui-resizable-s", w: ".ui-resizable-w", se: ".ui-resizable-se", sw: ".ui-resizable-sw", ne: ".ui-resizable-ne", nw: ".ui-resizable-nw"} : "e,s,se"); if (this.handles.constructor == String) { this.handles == "all" && (this.handles = "n,e,s,w,se,sw,ne,nw"); var d = this.handles.split(","); this.handles = {}; for (var e = 0; e < d.length; e++) { var f = a.trim(d[e]), g = "ui-resizable-" + f, h = a('<div class="ui-resizable-handle ' + g + '"></div>'); /sw|se|ne|nw/.test(f) && h.css({ zIndex: ++c.zIndex }), "se" == f && h.addClass("ui-icon ui-icon-gripsmall-diagonal-se"), this.handles[f] = ".ui-resizable-" + f, this.element.append(h) } } this._renderAxis = function (b) { b = b || this.element; for (var c in this.handles) { this.handles[c].constructor == String && (this.handles[c] = a(this.handles[c], this.element).show()); if (this.elementIsWrapper && this.originalElement[0].nodeName.match(/textarea|input|select|button/i)) { var d = a(this.handles[c], this.element), e = 0; e = /sw|ne|nw|se|n|s/.test(c) ? d.outerHeight() : d.outerWidth(); var f = ["padding", /ne|nw|n/.test(c) ? "Top" : /se|sw|s/.test(c) ? "Bottom" : /^e$/.test(c) ? "Right" : "Left"].join(""); b.css(f, e), this._proportionallyResize() } if (!a(this.handles[c]).length) continue } }, this._renderAxis(this.element), this._handles = a(".ui-resizable-handle", this.element).disableSelection(), this._handles.mouseover(function () { if (!b.resizing) { if (this.className) var a = this.className.match(/ui-resizable-(se|sw|ne|nw|n|e|s|w)/i); b.axis = a && a[1] ? a[1] : "se" } }), c.autoHide && (this._handles.hide(), a(this.element).addClass("ui-resizable-autohide").hover(function () { c.disabled || (a(this).removeClass("ui-resizable-autohide"), b._handles.show()) }, function () { c.disabled || b.resizing || (a(this).addClass("ui-resizable-autohide"), b._handles.hide()) })), this._mouseInit() }, destroy: function () { this._mouseDestroy(); var b = function (b) { a(b).removeClass("ui-resizable ui-resizable-disabled ui-resizable-resizing").removeData("resizable").unbind(".resizable").find(".ui-resizable-handle").remove() }; if (this.elementIsWrapper) { b(this.element); var c = this.element; c.after(this.originalElement.css({ position: c.css("position"), width: c.outerWidth(), height: c.outerHeight(), top: c.css("top"), left: c.css("left") })).remove() } this.originalElement.css("resize", this.originalResizeStyle), b(this.originalElement); return this }, _mouseCapture: function (b) { var c = !1; for (var d in this.handles) a(this.handles[d])[0] == b.target && (c = !0); return !this.options.disabled && c }, _mouseStart: function (b) { var d = this.options, e = this.element.position(), f = this.element; this.resizing = !0, this.documentScroll = { top: a(document).scrollTop(), left: a(document).scrollLeft() }, (f.is(".ui-draggable") || /absolute/.test(f.css("position"))) && f.css({ position: "absolute", top: e.top, left: e.left }), this._renderProxy(); var g = c(this.helper.css("left")), h = c(this.helper.css("top")); d.containment && (g += a(d.containment).scrollLeft() || 0, h += a(d.containment).scrollTop() || 0), this.offset = this.helper.offset(), this.position = { left: g, top: h }, this.size = this._helper ? { width: f.outerWidth(), height: f.outerHeight()} : { width: f.width(), height: f.height() }, this.originalSize = this._helper ? { width: f.outerWidth(), height: f.outerHeight()} : { width: f.width(), height: f.height() }, this.originalPosition = { left: g, top: h }, this.sizeDiff = { width: f.outerWidth() - f.width(), height: f.outerHeight() - f.height() }, this.originalMousePosition = { left: b.pageX, top: b.pageY }, this.aspectRatio = typeof d.aspectRatio == "number" ? d.aspectRatio : this.originalSize.width / this.originalSize.height || 1; var i = a(".ui-resizable-" + this.axis).css("cursor"); a("body").css("cursor", i == "auto" ? this.axis + "-resize" : i), f.addClass("ui-resizable-resizing"), this._propagate("start", b); return !0 }, _mouseDrag: function (b) { var c = this.helper, d = this.options, e = {}, f = this, g = this.originalMousePosition, h = this.axis, i = b.pageX - g.left || 0, j = b.pageY - g.top || 0, k = this._change[h]; if (!k) return !1; var l = k.apply(this, [b, i, j]), m = a.browser.msie && a.browser.version < 7, n = this.sizeDiff; this._updateVirtualBoundaries(b.shiftKey); if (this._aspectRatio || b.shiftKey) l = this._updateRatio(l, b); l = this._respectSize(l, b), this._propagate("resize", b), c.css({ top: this.position.top + "px", left: this.position.left + "px", width: this.size.width + "px", height: this.size.height + "px" }), !this._helper && this._proportionallyResizeElements.length && this._proportionallyResize(), this._updateCache(l), this._trigger("resize", b, this.ui()); return !1 }, _mouseStop: function (b) { this.resizing = !1; var c = this.options, d = this; if (this._helper) { var e = this._proportionallyResizeElements, f = e.length && /textarea/i.test(e[0].nodeName), g = f && a.ui.hasScroll(e[0], "left") ? 0 : d.sizeDiff.height, h = f ? 0 : d.sizeDiff.width, i = { width: d.helper.width() - h, height: d.helper.height() - g }, j = parseInt(d.element.css("left"), 10) + (d.position.left - d.originalPosition.left) || null, k = parseInt(d.element.css("top"), 10) + (d.position.top - d.originalPosition.top) || null; c.animate || this.element.css(a.extend(i, { top: k, left: j })), d.helper.height(d.size.height), d.helper.width(d.size.width), this._helper && !c.animate && this._proportionallyResize() } a("body").css("cursor", "auto"), this.element.removeClass("ui-resizable-resizing"), this._propagate("stop", b), this._helper && this.helper.remove(); return !1 }, _updateVirtualBoundaries: function (a) { var b = this.options, c, e, f, g, h; h = { minWidth: d(b.minWidth) ? b.minWidth : 0, maxWidth: d(b.maxWidth) ? b.maxWidth : Infinity, minHeight: d(b.minHeight) ? b.minHeight : 0, maxHeight: d(b.maxHeight) ? b.maxHeight : Infinity }; if (this._aspectRatio || a) c = h.minHeight * this.aspectRatio, f = h.minWidth / this.aspectRatio, e = h.maxHeight * this.aspectRatio, g = h.maxWidth / this.aspectRatio, c > h.minWidth && (h.minWidth = c), f > h.minHeight && (h.minHeight = f), e < h.maxWidth && (h.maxWidth = e), g < h.maxHeight && (h.maxHeight = g); this._vBoundaries = h }, _updateCache: function (a) { var b = this.options; this.offset = this.helper.offset(), d(a.left) && (this.position.left = a.left), d(a.top) && (this.position.top = a.top), d(a.height) && (this.size.height = a.height), d(a.width) && (this.size.width = a.width) }, _updateRatio: function (a, b) { var c = this.options, e = this.position, f = this.size, g = this.axis; d(a.height) ? a.width = a.height * this.aspectRatio : d(a.width) && (a.height = a.width / this.aspectRatio), g == "sw" && (a.left = e.left + (f.width - a.width), a.top = null), g == "nw" && (a.top = e.top + (f.height - a.height), a.left = e.left + (f.width - a.width)); return a }, _respectSize: function (a, b) { var c = this.helper, e = this._vBoundaries, f = this._aspectRatio || b.shiftKey, g = this.axis, h = d(a.width) && e.maxWidth && e.maxWidth < a.width, i = d(a.height) && e.maxHeight && e.maxHeight < a.height, j = d(a.width) && e.minWidth && e.minWidth > a.width, k = d(a.height) && e.minHeight && e.minHeight > a.height; j && (a.width = e.minWidth), k && (a.height = e.minHeight), h && (a.width = e.maxWidth), i && (a.height = e.maxHeight); var l = this.originalPosition.left + this.originalSize.width, m = this.position.top + this.size.height, n = /sw|nw|w/.test(g), o = /nw|ne|n/.test(g); j && n && (a.left = l - e.minWidth), h && n && (a.left = l - e.maxWidth), k && o && (a.top = m - e.minHeight), i && o && (a.top = m - e.maxHeight); var p = !a.width && !a.height; p && !a.left && a.top ? a.top = null : p && !a.top && a.left && (a.left = null); return a }, _proportionallyResize: function () { var b = this.options; if (!!this._proportionallyResizeElements.length) { var c = this.helper || this.element; for (var d = 0; d < this._proportionallyResizeElements.length; d++) { var e = this._proportionallyResizeElements[d]; if (!this.borderDif) { var f = [e.css("borderTopWidth"), e.css("borderRightWidth"), e.css("borderBottomWidth"), e.css("borderLeftWidth")], g = [e.css("paddingTop"), e.css("paddingRight"), e.css("paddingBottom"), e.css("paddingLeft")]; this.borderDif = a.map(f, function (a, b) { var c = parseInt(a, 10) || 0, d = parseInt(g[b], 10) || 0; return c + d }) } if (a.browser.msie && (!!a(c).is(":hidden") || !!a(c).parents(":hidden").length)) continue; e.css({ height: c.height() - this.borderDif[0] - this.borderDif[2] || 0, width: c.width() - this.borderDif[1] - this.borderDif[3] || 0 }) } } }, _renderProxy: function () { var b = this.element, c = this.options; this.elementOffset = b.offset(); if (this._helper) { this.helper = this.helper || a('<div style="overflow:hidden;"></div>'); var d = a.browser.msie && a.browser.version < 7, e = d ? 1 : 0, f = d ? 2 : -1; this.helper.addClass(this._helper).css({ width: this.element.outerWidth() + f, height: this.element.outerHeight() + f, position: "absolute", left: this.elementOffset.left - e + "px", top: this.elementOffset.top - e + "px", zIndex: ++c.zIndex }), this.helper.appendTo("body").disableSelection() } else this.helper = this.element }, _change: { e: function (a, b, c) { return { width: this.originalSize.width + b} }, w: function (a, b, c) { var d = this.options, e = this.originalSize, f = this.originalPosition; return { left: f.left + b, width: e.width - b} }, n: function (a, b, c) { var d = this.options, e = this.originalSize, f = this.originalPosition; return { top: f.top + c, height: e.height - c} }, s: function (a, b, c) { return { height: this.originalSize.height + c} }, se: function (b, c, d) { return a.extend(this._change.s.apply(this, arguments), this._change.e.apply(this, [b, c, d])) }, sw: function (b, c, d) { return a.extend(this._change.s.apply(this, arguments), this._change.w.apply(this, [b, c, d])) }, ne: function (b, c, d) { return a.extend(this._change.n.apply(this, arguments), this._change.e.apply(this, [b, c, d])) }, nw: function (b, c, d) { return a.extend(this._change.n.apply(this, arguments), this._change.w.apply(this, [b, c, d])) } }, _propagate: function (b, c) { a.ui.plugin.call(this, b, [c, this.ui()]), b != "resize" && this._trigger(b, c, this.ui()) }, plugins: {}, ui: function () { return { originalElement: this.originalElement, element: this.element, helper: this.helper, position: this.position, size: this.size, originalSize: this.originalSize, originalPosition: this.originalPosition} } }), a.extend(a.ui.resizable, { version: "1.8.18" }), a.ui.plugin.add("resizable", "alsoResize", { start: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = function (b) { a(b).each(function () { var b = a(this); b.data("resizable-alsoresize", { width: parseInt(b.width(), 10), height: parseInt(b.height(), 10), left: parseInt(b.css("left"), 10), top: parseInt(b.css("top"), 10) }) }) }; typeof e.alsoResize == "object" && !e.alsoResize.parentNode ? e.alsoResize.length ? (e.alsoResize = e.alsoResize[0], f(e.alsoResize)) : a.each(e.alsoResize, function (a) { f(a) }) : f(e.alsoResize) }, resize: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d.originalSize, g = d.originalPosition, h = { height: d.size.height - f.height || 0, width: d.size.width - f.width || 0, top: d.position.top - g.top || 0, left: d.position.left - g.left || 0 }, i = function (b, d) { a(b).each(function () { var b = a(this), e = a(this).data("resizable-alsoresize"), f = {}, g = d && d.length ? d : b.parents(c.originalElement[0]).length ? ["width", "height"] : ["width", "height", "top", "left"]; a.each(g, function (a, b) { var c = (e[b] || 0) + (h[b] || 0); c && c >= 0 && (f[b] = c || null) }), b.css(f) }) }; typeof e.alsoResize == "object" && !e.alsoResize.nodeType ? a.each(e.alsoResize, function (a, b) { i(a, b) }) : i(e.alsoResize) }, stop: function (b, c) { a(this).removeData("resizable-alsoresize") } }), a.ui.plugin.add("resizable", "animate", { stop: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d._proportionallyResizeElements, g = f.length && /textarea/i.test(f[0].nodeName), h = g && a.ui.hasScroll(f[0], "left") ? 0 : d.sizeDiff.height, i = g ? 0 : d.sizeDiff.width, j = { width: d.size.width - i, height: d.size.height - h }, k = parseInt(d.element.css("left"), 10) + (d.position.left - d.originalPosition.left) || null, l = parseInt(d.element.css("top"), 10) + (d.position.top - d.originalPosition.top) || null; d.element.animate(a.extend(j, l && k ? { top: l, left: k} : {}), { duration: e.animateDuration, easing: e.animateEasing, step: function () { var c = { width: parseInt(d.element.css("width"), 10), height: parseInt(d.element.css("height"), 10), top: parseInt(d.element.css("top"), 10), left: parseInt(d.element.css("left"), 10) }; f && f.length && a(f[0]).css({ width: c.width, height: c.height }), d._updateCache(c), d._propagate("resize", b) } }) } }), a.ui.plugin.add("resizable", "containment", { start: function (b, d) { var e = a(this).data("resizable"), f = e.options, g = e.element, h = f.containment, i = h instanceof a ? h.get(0) : /parent/.test(h) ? g.parent().get(0) : h; if (!!i) { e.containerElement = a(i); if (/document/.test(h) || h == document) e.containerOffset = { left: 0, top: 0 }, e.containerPosition = { left: 0, top: 0 }, e.parentData = { element: a(document), left: 0, top: 0, width: a(document).width(), height: a(document).height() || document.body.parentNode.scrollHeight }; else { var j = a(i), k = []; a(["Top", "Right", "Left", "Bottom"]).each(function (a, b) { k[a] = c(j.css("padding" + b)) }), e.containerOffset = j.offset(), e.containerPosition = j.position(), e.containerSize = { height: j.innerHeight() - k[3], width: j.innerWidth() - k[1] }; var l = e.containerOffset, m = e.containerSize.height, n = e.containerSize.width, o = a.ui.hasScroll(i, "left") ? i.scrollWidth : n, p = a.ui.hasScroll(i) ? i.scrollHeight : m; e.parentData = { element: i, left: l.left, top: l.top, width: o, height: p} } } }, resize: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d.containerSize, g = d.containerOffset, h = d.size, i = d.position, j = d._aspectRatio || b.shiftKey, k = { top: 0, left: 0 }, l = d.containerElement; l[0] != document && /static/.test(l.css("position")) && (k = g), i.left < (d._helper ? g.left : 0) && (d.size.width = d.size.width + (d._helper ? d.position.left - g.left : d.position.left - k.left), j && (d.size.height = d.size.width / e.aspectRatio), d.position.left = e.helper ? g.left : 0), i.top < (d._helper ? g.top : 0) && (d.size.height = d.size.height + (d._helper ? d.position.top - g.top : d.position.top), j && (d.size.width = d.size.height * e.aspectRatio), d.position.top = d._helper ? g.top : 0), d.offset.left = d.parentData.left + d.position.left, d.offset.top = d.parentData.top + d.position.top; var m = Math.abs((d._helper ? d.offset.left - k.left : d.offset.left - k.left) + d.sizeDiff.width), n = Math.abs((d._helper ? d.offset.top - k.top : d.offset.top - g.top) + d.sizeDiff.height), o = d.containerElement.get(0) == d.element.parent().get(0), p = /relative|absolute/.test(d.containerElement.css("position")); o && p && (m -= d.parentData.left), m + d.size.width >= d.parentData.width && (d.size.width = d.parentData.width - m, j && (d.size.height = d.size.width / d.aspectRatio)), n + d.size.height >= d.parentData.height && (d.size.height = d.parentData.height - n, j && (d.size.width = d.size.height * d.aspectRatio)) }, stop: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d.position, g = d.containerOffset, h = d.containerPosition, i = d.containerElement, j = a(d.helper), k = j.offset(), l = j.outerWidth() - d.sizeDiff.width, m = j.outerHeight() - d.sizeDiff.height; d._helper && !e.animate && /relative/.test(i.css("position")) && a(this).css({ left: k.left - h.left - g.left, width: l, height: m }), d._helper && !e.animate && /static/.test(i.css("position")) && a(this).css({ left: k.left - h.left - g.left, width: l, height: m }) } }), a.ui.plugin.add("resizable", "ghost", { start: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d.size; d.ghost = d.originalElement.clone(), d.ghost.css({ opacity: .25, display: "block", position: "relative", height: f.height, width: f.width, margin: 0, left: 0, top: 0 }).addClass("ui-resizable-ghost").addClass(typeof e.ghost == "string" ? e.ghost : ""), d.ghost.appendTo(d.helper) }, resize: function (b, c) { var d = a(this).data("resizable"), e = d.options; d.ghost && d.ghost.css({ position: "relative", height: d.size.height, width: d.size.width }) }, stop: function (b, c) { var d = a(this).data("resizable"), e = d.options; d.ghost && d.helper && d.helper.get(0).removeChild(d.ghost.get(0)) } }), a.ui.plugin.add("resizable", "grid", { resize: function (b, c) { var d = a(this).data("resizable"), e = d.options, f = d.size, g = d.originalSize, h = d.originalPosition, i = d.axis, j = e._aspectRatio || b.shiftKey; e.grid = typeof e.grid == "number" ? [e.grid, e.grid] : e.grid; var k = Math.round((f.width - g.width) / (e.grid[0] || 1)) * (e.grid[0] || 1), l = Math.round((f.height - g.height) / (e.grid[1] || 1)) * (e.grid[1] || 1); /^(se|s|e)$/.test(i) ? (d.size.width = g.width + k, d.size.height = g.height + l) : /^(ne)$/.test(i) ? (d.size.width = g.width + k, d.size.height = g.height + l, d.position.top = h.top - l) : /^(sw)$/.test(i) ? (d.size.width = g.width + k, d.size.height = g.height + l, d.position.left = h.left - k) : (d.size.width = g.width + k, d.size.height = g.height + l, d.position.top = h.top - l, d.position.left = h.left - k) } }); var c = function (a) { return parseInt(a, 10) || 0 }, d = function (a) { return !isNaN(parseInt(a, 10)) } })(jQuery); /*
* jQuery UI Selectable 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Selectables
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.mouse.js
*	jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.selectable", a.ui.mouse, { options: { appendTo: "body", autoRefresh: !0, distance: 0, filter: "*", tolerance: "touch" }, _create: function () { var b = this; this.element.addClass("ui-selectable"), this.dragged = !1; var c; this.refresh = function () { c = a(b.options.filter, b.element[0]), c.addClass("ui-selectee"), c.each(function () { var b = a(this), c = b.offset(); a.data(this, "selectable-item", { element: this, $element: b, left: c.left, top: c.top, right: c.left + b.outerWidth(), bottom: c.top + b.outerHeight(), startselected: !1, selected: b.hasClass("ui-selected"), selecting: b.hasClass("ui-selecting"), unselecting: b.hasClass("ui-unselecting") }) }) }, this.refresh(), this.selectees = c.addClass("ui-selectee"), this._mouseInit(), this.helper = a("<div class='ui-selectable-helper'></div>") }, destroy: function () { this.selectees.removeClass("ui-selectee").removeData("selectable-item"), this.element.removeClass("ui-selectable ui-selectable-disabled").removeData("selectable").unbind(".selectable"), this._mouseDestroy(); return this }, _mouseStart: function (b) { var c = this; this.opos = [b.pageX, b.pageY]; if (!this.options.disabled) { var d = this.options; this.selectees = a(d.filter, this.element[0]), this._trigger("start", b), a(d.appendTo).append(this.helper), this.helper.css({ left: b.clientX, top: b.clientY, width: 0, height: 0 }), d.autoRefresh && this.refresh(), this.selectees.filter(".ui-selected").each(function () { var d = a.data(this, "selectable-item"); d.startselected = !0, !b.metaKey && !b.ctrlKey && (d.$element.removeClass("ui-selected"), d.selected = !1, d.$element.addClass("ui-unselecting"), d.unselecting = !0, c._trigger("unselecting", b, { unselecting: d.element })) }), a(b.target).parents().andSelf().each(function () { var d = a.data(this, "selectable-item"); if (d) { var e = !b.metaKey && !b.ctrlKey || !d.$element.hasClass("ui-selected"); d.$element.removeClass(e ? "ui-unselecting" : "ui-selected").addClass(e ? "ui-selecting" : "ui-unselecting"), d.unselecting = !e, d.selecting = e, d.selected = e, e ? c._trigger("selecting", b, { selecting: d.element }) : c._trigger("unselecting", b, { unselecting: d.element }); return !1 } }) } }, _mouseDrag: function (b) { var c = this; this.dragged = !0; if (!this.options.disabled) { var d = this.options, e = this.opos[0], f = this.opos[1], g = b.pageX, h = b.pageY; if (e > g) { var i = g; g = e, e = i } if (f > h) { var i = h; h = f, f = i } this.helper.css({ left: e, top: f, width: g - e, height: h - f }), this.selectees.each(function () { var i = a.data(this, "selectable-item"); if (!!i && i.element != c.element[0]) { var j = !1; d.tolerance == "touch" ? j = !(i.left > g || i.right < e || i.top > h || i.bottom < f) : d.tolerance == "fit" && (j = i.left > e && i.right < g && i.top > f && i.bottom < h), j ? (i.selected && (i.$element.removeClass("ui-selected"), i.selected = !1), i.unselecting && (i.$element.removeClass("ui-unselecting"), i.unselecting = !1), i.selecting || (i.$element.addClass("ui-selecting"), i.selecting = !0, c._trigger("selecting", b, { selecting: i.element }))) : (i.selecting && ((b.metaKey || b.ctrlKey) && i.startselected ? (i.$element.removeClass("ui-selecting"), i.selecting = !1, i.$element.addClass("ui-selected"), i.selected = !0) : (i.$element.removeClass("ui-selecting"), i.selecting = !1, i.startselected && (i.$element.addClass("ui-unselecting"), i.unselecting = !0), c._trigger("unselecting", b, { unselecting: i.element }))), i.selected && !b.metaKey && !b.ctrlKey && !i.startselected && (i.$element.removeClass("ui-selected"), i.selected = !1, i.$element.addClass("ui-unselecting"), i.unselecting = !0, c._trigger("unselecting", b, { unselecting: i.element }))) } }); return !1 } }, _mouseStop: function (b) { var c = this; this.dragged = !1; var d = this.options; a(".ui-unselecting", this.element[0]).each(function () { var d = a.data(this, "selectable-item"); d.$element.removeClass("ui-unselecting"), d.unselecting = !1, d.startselected = !1, c._trigger("unselected", b, { unselected: d.element }) }), a(".ui-selecting", this.element[0]).each(function () { var d = a.data(this, "selectable-item"); d.$element.removeClass("ui-selecting").addClass("ui-selected"), d.selecting = !1, d.selected = !0, d.startselected = !0, c._trigger("selected", b, { selected: d.element }) }), this._trigger("stop", b), this.helper.remove(); return !1 } }), a.extend(a.ui.selectable, { version: "1.8.18" }) })(jQuery); /*
* jQuery UI Sortable 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Sortables
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.mouse.js
*	jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.sortable", a.ui.mouse, { widgetEventPrefix: "sort", ready: !1, options: { appendTo: "parent", axis: !1, connectWith: !1, containment: !1, cursor: "auto", cursorAt: !1, dropOnEmpty: !0, forcePlaceholderSize: !1, forceHelperSize: !1, grid: !1, handle: !1, helper: "original", items: "> *", opacity: !1, placeholder: !1, revert: !1, scroll: !0, scrollSensitivity: 20, scrollSpeed: 20, scope: "default", tolerance: "intersect", zIndex: 1e3 }, _create: function () { var a = this.options; this.containerCache = {}, this.element.addClass("ui-sortable"), this.refresh(), this.floating = this.items.length ? a.axis === "x" || /left|right/.test(this.items[0].item.css("float")) || /inline|table-cell/.test(this.items[0].item.css("display")) : !1, this.offset = this.element.offset(), this._mouseInit(), this.ready = !0 }, destroy: function () { a.Widget.prototype.destroy.call(this), this.element.removeClass("ui-sortable ui-sortable-disabled"), this._mouseDestroy(); for (var b = this.items.length - 1; b >= 0; b--) this.items[b].item.removeData(this.widgetName + "-item"); return this }, _setOption: function (b, c) { b === "disabled" ? (this.options[b] = c, this.widget()[c ? "addClass" : "removeClass"]("ui-sortable-disabled")) : a.Widget.prototype._setOption.apply(this, arguments) }, _mouseCapture: function (b, c) { var d = this; if (this.reverting) return !1; if (this.options.disabled || this.options.type == "static") return !1; this._refreshItems(b); var e = null, f = this, g = a(b.target).parents().each(function () { if (a.data(this, d.widgetName + "-item") == f) { e = a(this); return !1 } }); a.data(b.target, d.widgetName + "-item") == f && (e = a(b.target)); if (!e) return !1; if (this.options.handle && !c) { var h = !1; a(this.options.handle, e).find("*").andSelf().each(function () { this == b.target && (h = !0) }); if (!h) return !1 } this.currentItem = e, this._removeCurrentsFromItems(); return !0 }, _mouseStart: function (b, c, d) { var e = this.options, f = this; this.currentContainer = this, this.refreshPositions(), this.helper = this._createHelper(b), this._cacheHelperProportions(), this._cacheMargins(), this.scrollParent = this.helper.scrollParent(), this.offset = this.currentItem.offset(), this.offset = { top: this.offset.top - this.margins.top, left: this.offset.left - this.margins.left }, this.helper.css("position", "absolute"), this.cssPosition = this.helper.css("position"), a.extend(this.offset, { click: { left: b.pageX - this.offset.left, top: b.pageY - this.offset.top }, parent: this._getParentOffset(), relative: this._getRelativeOffset() }), this.originalPosition = this._generatePosition(b), this.originalPageX = b.pageX, this.originalPageY = b.pageY, e.cursorAt && this._adjustOffsetFromHelper(e.cursorAt), this.domPosition = { prev: this.currentItem.prev()[0], parent: this.currentItem.parent()[0] }, this.helper[0] != this.currentItem[0] && this.currentItem.hide(), this._createPlaceholder(), e.containment && this._setContainment(), e.cursor && (a("body").css("cursor") && (this._storedCursor = a("body").css("cursor")), a("body").css("cursor", e.cursor)), e.opacity && (this.helper.css("opacity") && (this._storedOpacity = this.helper.css("opacity")), this.helper.css("opacity", e.opacity)), e.zIndex && (this.helper.css("zIndex") && (this._storedZIndex = this.helper.css("zIndex")), this.helper.css("zIndex", e.zIndex)), this.scrollParent[0] != document && this.scrollParent[0].tagName != "HTML" && (this.overflowOffset = this.scrollParent.offset()), this._trigger("start", b, this._uiHash()), this._preserveHelperProportions || this._cacheHelperProportions(); if (!d) for (var g = this.containers.length - 1; g >= 0; g--) this.containers[g]._trigger("activate", b, f._uiHash(this)); a.ui.ddmanager && (a.ui.ddmanager.current = this), a.ui.ddmanager && !e.dropBehaviour && a.ui.ddmanager.prepareOffsets(this, b), this.dragging = !0, this.helper.addClass("ui-sortable-helper"), this._mouseDrag(b); return !0 }, _mouseDrag: function (b) { this.position = this._generatePosition(b), this.positionAbs = this._convertPositionTo("absolute"), this.lastPositionAbs || (this.lastPositionAbs = this.positionAbs); if (this.options.scroll) { var c = this.options, d = !1; this.scrollParent[0] != document && this.scrollParent[0].tagName != "HTML" ? (this.overflowOffset.top + this.scrollParent[0].offsetHeight - b.pageY < c.scrollSensitivity ? this.scrollParent[0].scrollTop = d = this.scrollParent[0].scrollTop + c.scrollSpeed : b.pageY - this.overflowOffset.top < c.scrollSensitivity && (this.scrollParent[0].scrollTop = d = this.scrollParent[0].scrollTop - c.scrollSpeed), this.overflowOffset.left + this.scrollParent[0].offsetWidth - b.pageX < c.scrollSensitivity ? this.scrollParent[0].scrollLeft = d = this.scrollParent[0].scrollLeft + c.scrollSpeed : b.pageX - this.overflowOffset.left < c.scrollSensitivity && (this.scrollParent[0].scrollLeft = d = this.scrollParent[0].scrollLeft - c.scrollSpeed)) : (b.pageY - a(document).scrollTop() < c.scrollSensitivity ? d = a(document).scrollTop(a(document).scrollTop() - c.scrollSpeed) : a(window).height() - (b.pageY - a(document).scrollTop()) < c.scrollSensitivity && (d = a(document).scrollTop(a(document).scrollTop() + c.scrollSpeed)), b.pageX - a(document).scrollLeft() < c.scrollSensitivity ? d = a(document).scrollLeft(a(document).scrollLeft() - c.scrollSpeed) : a(window).width() - (b.pageX - a(document).scrollLeft()) < c.scrollSensitivity && (d = a(document).scrollLeft(a(document).scrollLeft() + c.scrollSpeed))), d !== !1 && a.ui.ddmanager && !c.dropBehaviour && a.ui.ddmanager.prepareOffsets(this, b) } this.positionAbs = this._convertPositionTo("absolute"); if (!this.options.axis || this.options.axis != "y") this.helper[0].style.left = this.position.left + "px"; if (!this.options.axis || this.options.axis != "x") this.helper[0].style.top = this.position.top + "px"; for (var e = this.items.length - 1; e >= 0; e--) { var f = this.items[e], g = f.item[0], h = this._intersectsWithPointer(f); if (!h) continue; if (g != this.currentItem[0] && this.placeholder[h == 1 ? "next" : "prev"]()[0] != g && !a.ui.contains(this.placeholder[0], g) && (this.options.type == "semi-dynamic" ? !a.ui.contains(this.element[0], g) : !0)) { this.direction = h == 1 ? "down" : "up"; if (this.options.tolerance == "pointer" || this._intersectsWithSides(f)) this._rearrange(b, f); else break; this._trigger("change", b, this._uiHash()); break } } this._contactContainers(b), a.ui.ddmanager && a.ui.ddmanager.drag(this, b), this._trigger("sort", b, this._uiHash()), this.lastPositionAbs = this.positionAbs; return !1 }, _mouseStop: function (b, c) { if (!!b) { a.ui.ddmanager && !this.options.dropBehaviour && a.ui.ddmanager.drop(this, b); if (this.options.revert) { var d = this, e = d.placeholder.offset(); d.reverting = !0, a(this.helper).animate({ left: e.left - this.offset.parent.left - d.margins.left + (this.offsetParent[0] == document.body ? 0 : this.offsetParent[0].scrollLeft), top: e.top - this.offset.parent.top - d.margins.top + (this.offsetParent[0] == document.body ? 0 : this.offsetParent[0].scrollTop) }, parseInt(this.options.revert, 10) || 500, function () { d._clear(b) }) } else this._clear(b, c); return !1 } }, cancel: function () { var b = this; if (this.dragging) { this._mouseUp({ target: null }), this.options.helper == "original" ? this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper") : this.currentItem.show(); for (var c = this.containers.length - 1; c >= 0; c--) this.containers[c]._trigger("deactivate", null, b._uiHash(this)), this.containers[c].containerCache.over && (this.containers[c]._trigger("out", null, b._uiHash(this)), this.containers[c].containerCache.over = 0) } this.placeholder && (this.placeholder[0].parentNode && this.placeholder[0].parentNode.removeChild(this.placeholder[0]), this.options.helper != "original" && this.helper && this.helper[0].parentNode && this.helper.remove(), a.extend(this, { helper: null, dragging: !1, reverting: !1, _noFinalSort: null }), this.domPosition.prev ? a(this.domPosition.prev).after(this.currentItem) : a(this.domPosition.parent).prepend(this.currentItem)); return this }, serialize: function (b) { var c = this._getItemsAsjQuery(b && b.connected), d = []; b = b || {}, a(c).each(function () { var c = (a(b.item || this).attr(b.attribute || "id") || "").match(b.expression || /(.+)[-=_](.+)/); c && d.push((b.key || c[1] + "[]") + "=" + (b.key && b.expression ? c[1] : c[2])) }), !d.length && b.key && d.push(b.key + "="); return d.join("&") }, toArray: function (b) { var c = this._getItemsAsjQuery(b && b.connected), d = []; b = b || {}, c.each(function () { d.push(a(b.item || this).attr(b.attribute || "id") || "") }); return d }, _intersectsWith: function (a) { var b = this.positionAbs.left, c = b + this.helperProportions.width, d = this.positionAbs.top, e = d + this.helperProportions.height, f = a.left, g = f + a.width, h = a.top, i = h + a.height, j = this.offset.click.top, k = this.offset.click.left, l = d + j > h && d + j < i && b + k > f && b + k < g; return this.options.tolerance == "pointer" || this.options.forcePointerForContainers || this.options.tolerance != "pointer" && this.helperProportions[this.floating ? "width" : "height"] > a[this.floating ? "width" : "height"] ? l : f < b + this.helperProportions.width / 2 && c - this.helperProportions.width / 2 < g && h < d + this.helperProportions.height / 2 && e - this.helperProportions.height / 2 < i }, _intersectsWithPointer: function (b) { var c = a.ui.isOverAxis(this.positionAbs.top + this.offset.click.top, b.top, b.height), d = a.ui.isOverAxis(this.positionAbs.left + this.offset.click.left, b.left, b.width), e = c && d, f = this._getDragVerticalDirection(), g = this._getDragHorizontalDirection(); if (!e) return !1; return this.floating ? g && g == "right" || f == "down" ? 2 : 1 : f && (f == "down" ? 2 : 1) }, _intersectsWithSides: function (b) { var c = a.ui.isOverAxis(this.positionAbs.top + this.offset.click.top, b.top + b.height / 2, b.height), d = a.ui.isOverAxis(this.positionAbs.left + this.offset.click.left, b.left + b.width / 2, b.width), e = this._getDragVerticalDirection(), f = this._getDragHorizontalDirection(); return this.floating && f ? f == "right" && d || f == "left" && !d : e && (e == "down" && c || e == "up" && !c) }, _getDragVerticalDirection: function () { var a = this.positionAbs.top - this.lastPositionAbs.top; return a != 0 && (a > 0 ? "down" : "up") }, _getDragHorizontalDirection: function () { var a = this.positionAbs.left - this.lastPositionAbs.left; return a != 0 && (a > 0 ? "right" : "left") }, refresh: function (a) { this._refreshItems(a), this.refreshPositions(); return this }, _connectWith: function () { var a = this.options; return a.connectWith.constructor == String ? [a.connectWith] : a.connectWith }, _getItemsAsjQuery: function (b) { var c = this, d = [], e = [], f = this._connectWith(); if (f && b) for (var g = f.length - 1; g >= 0; g--) { var h = a(f[g]); for (var i = h.length - 1; i >= 0; i--) { var j = a.data(h[i], this.widgetName); j && j != this && !j.options.disabled && e.push([a.isFunction(j.options.items) ? j.options.items.call(j.element) : a(j.options.items, j.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), j]) } } e.push([a.isFunction(this.options.items) ? this.options.items.call(this.element, null, { options: this.options, item: this.currentItem }) : a(this.options.items, this.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), this]); for (var g = e.length - 1; g >= 0; g--) e[g][0].each(function () { d.push(this) }); return a(d) }, _removeCurrentsFromItems: function () { var a = this.currentItem.find(":data(" + this.widgetName + "-item)"); for (var b = 0; b < this.items.length; b++) for (var c = 0; c < a.length; c++) a[c] == this.items[b].item[0] && this.items.splice(b, 1) }, _refreshItems: function (b) { this.items = [], this.containers = [this]; var c = this.items, d = this, e = [[a.isFunction(this.options.items) ? this.options.items.call(this.element[0], b, { item: this.currentItem }) : a(this.options.items, this.element), this]], f = this._connectWith(); if (f && this.ready) for (var g = f.length - 1; g >= 0; g--) { var h = a(f[g]); for (var i = h.length - 1; i >= 0; i--) { var j = a.data(h[i], this.widgetName); j && j != this && !j.options.disabled && (e.push([a.isFunction(j.options.items) ? j.options.items.call(j.element[0], b, { item: this.currentItem }) : a(j.options.items, j.element), j]), this.containers.push(j)) } } for (var g = e.length - 1; g >= 0; g--) { var k = e[g][1], l = e[g][0]; for (var i = 0, m = l.length; i < m; i++) { var n = a(l[i]); n.data(this.widgetName + "-item", k), c.push({ item: n, instance: k, width: 0, height: 0, left: 0, top: 0 }) } } }, refreshPositions: function (b) { this.offsetParent && this.helper && (this.offset.parent = this._getParentOffset()); for (var c = this.items.length - 1; c >= 0; c--) { var d = this.items[c]; if (d.instance != this.currentContainer && this.currentContainer && d.item[0] != this.currentItem[0]) continue; var e = this.options.toleranceElement ? a(this.options.toleranceElement, d.item) : d.item; b || (d.width = e.outerWidth(), d.height = e.outerHeight()); var f = e.offset(); d.left = f.left, d.top = f.top } if (this.options.custom && this.options.custom.refreshContainers) this.options.custom.refreshContainers.call(this); else for (var c = this.containers.length - 1; c >= 0; c--) { var f = this.containers[c].element.offset(); this.containers[c].containerCache.left = f.left, this.containers[c].containerCache.top = f.top, this.containers[c].containerCache.width = this.containers[c].element.outerWidth(), this.containers[c].containerCache.height = this.containers[c].element.outerHeight() } return this }, _createPlaceholder: function (b) { var c = b || this, d = c.options; if (!d.placeholder || d.placeholder.constructor == String) { var e = d.placeholder; d.placeholder = { element: function () { var b = a(document.createElement(c.currentItem[0].nodeName)).addClass(e || c.currentItem[0].className + " ui-sortable-placeholder").removeClass("ui-sortable-helper")[0]; e || (b.style.visibility = "hidden"); return b }, update: function (a, b) { if (!e || !!d.forcePlaceholderSize) b.height() || b.height(c.currentItem.innerHeight() - parseInt(c.currentItem.css("paddingTop") || 0, 10) - parseInt(c.currentItem.css("paddingBottom") || 0, 10)), b.width() || b.width(c.currentItem.innerWidth() - parseInt(c.currentItem.css("paddingLeft") || 0, 10) - parseInt(c.currentItem.css("paddingRight") || 0, 10)) } } } c.placeholder = a(d.placeholder.element.call(c.element, c.currentItem)), c.currentItem.after(c.placeholder), d.placeholder.update(c, c.placeholder) }, _contactContainers: function (b) { var c = null, d = null; for (var e = this.containers.length - 1; e >= 0; e--) { if (a.ui.contains(this.currentItem[0], this.containers[e].element[0])) continue; if (this._intersectsWith(this.containers[e].containerCache)) { if (c && a.ui.contains(this.containers[e].element[0], c.element[0])) continue; c = this.containers[e], d = e } else this.containers[e].containerCache.over && (this.containers[e]._trigger("out", b, this._uiHash(this)), this.containers[e].containerCache.over = 0) } if (!!c) if (this.containers.length === 1) this.containers[d]._trigger("over", b, this._uiHash(this)), this.containers[d].containerCache.over = 1; else if (this.currentContainer != this.containers[d]) { var f = 1e4, g = null, h = this.positionAbs[this.containers[d].floating ? "left" : "top"]; for (var i = this.items.length - 1; i >= 0; i--) { if (!a.ui.contains(this.containers[d].element[0], this.items[i].item[0])) continue; var j = this.items[i][this.containers[d].floating ? "left" : "top"]; Math.abs(j - h) < f && (f = Math.abs(j - h), g = this.items[i]) } if (!g && !this.options.dropOnEmpty) return; this.currentContainer = this.containers[d], g ? this._rearrange(b, g, null, !0) : this._rearrange(b, null, this.containers[d].element, !0), this._trigger("change", b, this._uiHash()), this.containers[d]._trigger("change", b, this._uiHash(this)), this.options.placeholder.update(this.currentContainer, this.placeholder), this.containers[d]._trigger("over", b, this._uiHash(this)), this.containers[d].containerCache.over = 1 } }, _createHelper: function (b) { var c = this.options, d = a.isFunction(c.helper) ? a(c.helper.apply(this.element[0], [b, this.currentItem])) : c.helper == "clone" ? this.currentItem.clone() : this.currentItem; d.parents("body").length || a(c.appendTo != "parent" ? c.appendTo : this.currentItem[0].parentNode)[0].appendChild(d[0]), d[0] == this.currentItem[0] && (this._storedCSS = { width: this.currentItem[0].style.width, height: this.currentItem[0].style.height, position: this.currentItem.css("position"), top: this.currentItem.css("top"), left: this.currentItem.css("left") }), (d[0].style.width == "" || c.forceHelperSize) && d.width(this.currentItem.width()), (d[0].style.height == "" || c.forceHelperSize) && d.height(this.currentItem.height()); return d }, _adjustOffsetFromHelper: function (b) { typeof b == "string" && (b = b.split(" ")), a.isArray(b) && (b = { left: +b[0], top: +b[1] || 0 }), "left" in b && (this.offset.click.left = b.left + this.margins.left), "right" in b && (this.offset.click.left = this.helperProportions.width - b.right + this.margins.left), "top" in b && (this.offset.click.top = b.top + this.margins.top), "bottom" in b && (this.offset.click.top = this.helperProportions.height - b.bottom + this.margins.top) }, _getParentOffset: function () { this.offsetParent = this.helper.offsetParent(); var b = this.offsetParent.offset(); this.cssPosition == "absolute" && this.scrollParent[0] != document && a.ui.contains(this.scrollParent[0], this.offsetParent[0]) && (b.left += this.scrollParent.scrollLeft(), b.top += this.scrollParent.scrollTop()); if (this.offsetParent[0] == document.body || this.offsetParent[0].tagName && this.offsetParent[0].tagName.toLowerCase() == "html" && a.browser.msie) b = { top: 0, left: 0 }; return { top: b.top + (parseInt(this.offsetParent.css("borderTopWidth"), 10) || 0), left: b.left + (parseInt(this.offsetParent.css("borderLeftWidth"), 10) || 0)} }, _getRelativeOffset: function () { if (this.cssPosition == "relative") { var a = this.currentItem.position(); return { top: a.top - (parseInt(this.helper.css("top"), 10) || 0) + this.scrollParent.scrollTop(), left: a.left - (parseInt(this.helper.css("left"), 10) || 0) + this.scrollParent.scrollLeft()} } return { top: 0, left: 0} }, _cacheMargins: function () { this.margins = { left: parseInt(this.currentItem.css("marginLeft"), 10) || 0, top: parseInt(this.currentItem.css("marginTop"), 10) || 0} }, _cacheHelperProportions: function () { this.helperProportions = { width: this.helper.outerWidth(), height: this.helper.outerHeight()} }, _setContainment: function () { var b = this.options; b.containment == "parent" && (b.containment = this.helper[0].parentNode); if (b.containment == "document" || b.containment == "window") this.containment = [0 - this.offset.relative.left - this.offset.parent.left, 0 - this.offset.relative.top - this.offset.parent.top, a(b.containment == "document" ? document : window).width() - this.helperProportions.width - this.margins.left, (a(b.containment == "document" ? document : window).height() || document.body.parentNode.scrollHeight) - this.helperProportions.height - this.margins.top]; if (!/^(document|window|parent)$/.test(b.containment)) { var c = a(b.containment)[0], d = a(b.containment).offset(), e = a(c).css("overflow") != "hidden"; this.containment = [d.left + (parseInt(a(c).css("borderLeftWidth"), 10) || 0) + (parseInt(a(c).css("paddingLeft"), 10) || 0) - this.margins.left, d.top + (parseInt(a(c).css("borderTopWidth"), 10) || 0) + (parseInt(a(c).css("paddingTop"), 10) || 0) - this.margins.top, d.left + (e ? Math.max(c.scrollWidth, c.offsetWidth) : c.offsetWidth) - (parseInt(a(c).css("borderLeftWidth"), 10) || 0) - (parseInt(a(c).css("paddingRight"), 10) || 0) - this.helperProportions.width - this.margins.left, d.top + (e ? Math.max(c.scrollHeight, c.offsetHeight) : c.offsetHeight) - (parseInt(a(c).css("borderTopWidth"), 10) || 0) - (parseInt(a(c).css("paddingBottom"), 10) || 0) - this.helperProportions.height - this.margins.top] } }, _convertPositionTo: function (b, c) { c || (c = this.position); var d = b == "absolute" ? 1 : -1, e = this.options, f = this.cssPosition == "absolute" && (this.scrollParent[0] == document || !a.ui.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, g = /(html|body)/i.test(f[0].tagName); return { top: c.top + this.offset.relative.top * d + this.offset.parent.top * d - (a.browser.safari && this.cssPosition == "fixed" ? 0 : (this.cssPosition == "fixed" ? -this.scrollParent.scrollTop() : g ? 0 : f.scrollTop()) * d), left: c.left + this.offset.relative.left * d + this.offset.parent.left * d - (a.browser.safari && this.cssPosition == "fixed" ? 0 : (this.cssPosition == "fixed" ? -this.scrollParent.scrollLeft() : g ? 0 : f.scrollLeft()) * d)} }, _generatePosition: function (b) { var c = this.options, d = this.cssPosition == "absolute" && (this.scrollParent[0] == document || !a.ui.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, e = /(html|body)/i.test(d[0].tagName); this.cssPosition == "relative" && (this.scrollParent[0] == document || this.scrollParent[0] == this.offsetParent[0]) && (this.offset.relative = this._getRelativeOffset()); var f = b.pageX, g = b.pageY; if (this.originalPosition) { this.containment && (b.pageX - this.offset.click.left < this.containment[0] && (f = this.containment[0] + this.offset.click.left), b.pageY - this.offset.click.top < this.containment[1] && (g = this.containment[1] + this.offset.click.top), b.pageX - this.offset.click.left > this.containment[2] && (f = this.containment[2] + this.offset.click.left), b.pageY - this.offset.click.top > this.containment[3] && (g = this.containment[3] + this.offset.click.top)); if (c.grid) { var h = this.originalPageY + Math.round((g - this.originalPageY) / c.grid[1]) * c.grid[1]; g = this.containment ? h - this.offset.click.top < this.containment[1] || h - this.offset.click.top > this.containment[3] ? h - this.offset.click.top < this.containment[1] ? h + c.grid[1] : h - c.grid[1] : h : h; var i = this.originalPageX + Math.round((f - this.originalPageX) / c.grid[0]) * c.grid[0]; f = this.containment ? i - this.offset.click.left < this.containment[0] || i - this.offset.click.left > this.containment[2] ? i - this.offset.click.left < this.containment[0] ? i + c.grid[0] : i - c.grid[0] : i : i } } return { top: g - this.offset.click.top - this.offset.relative.top - this.offset.parent.top + (a.browser.safari && this.cssPosition == "fixed" ? 0 : this.cssPosition == "fixed" ? -this.scrollParent.scrollTop() : e ? 0 : d.scrollTop()), left: f - this.offset.click.left - this.offset.relative.left - this.offset.parent.left + (a.browser.safari && this.cssPosition == "fixed" ? 0 : this.cssPosition == "fixed" ? -this.scrollParent.scrollLeft() : e ? 0 : d.scrollLeft())} }, _rearrange: function (a, b, c, d) { c ? c[0].appendChild(this.placeholder[0]) : b.item[0].parentNode.insertBefore(this.placeholder[0], this.direction == "down" ? b.item[0] : b.item[0].nextSibling), this.counter = this.counter ? ++this.counter : 1; var e = this, f = this.counter; window.setTimeout(function () { f == e.counter && e.refreshPositions(!d) }, 0) }, _clear: function (b, c) { this.reverting = !1; var d = [], e = this; !this._noFinalSort && this.currentItem.parent().length && this.placeholder.before(this.currentItem), this._noFinalSort = null; if (this.helper[0] == this.currentItem[0]) { for (var f in this._storedCSS) if (this._storedCSS[f] == "auto" || this._storedCSS[f] == "static") this._storedCSS[f] = ""; this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper") } else this.currentItem.show(); this.fromOutside && !c && d.push(function (a) { this._trigger("receive", a, this._uiHash(this.fromOutside)) }), (this.fromOutside || this.domPosition.prev != this.currentItem.prev().not(".ui-sortable-helper")[0] || this.domPosition.parent != this.currentItem.parent()[0]) && !c && d.push(function (a) { this._trigger("update", a, this._uiHash()) }); if (!a.ui.contains(this.element[0], this.currentItem[0])) { c || d.push(function (a) { this._trigger("remove", a, this._uiHash()) }); for (var f = this.containers.length - 1; f >= 0; f--) a.ui.contains(this.containers[f].element[0], this.currentItem[0]) && !c && (d.push(function (a) { return function (b) { a._trigger("receive", b, this._uiHash(this)) } } .call(this, this.containers[f])), d.push(function (a) { return function (b) { a._trigger("update", b, this._uiHash(this)) } } .call(this, this.containers[f]))) } for (var f = this.containers.length - 1; f >= 0; f--) c || d.push(function (a) { return function (b) { a._trigger("deactivate", b, this._uiHash(this)) } } .call(this, this.containers[f])), this.containers[f].containerCache.over && (d.push(function (a) { return function (b) { a._trigger("out", b, this._uiHash(this)) } } .call(this, this.containers[f])), this.containers[f].containerCache.over = 0); this._storedCursor && a("body").css("cursor", this._storedCursor), this._storedOpacity && this.helper.css("opacity", this._storedOpacity), this._storedZIndex && this.helper.css("zIndex", this._storedZIndex == "auto" ? "" : this._storedZIndex), this.dragging = !1; if (this.cancelHelperRemoval) { if (!c) { this._trigger("beforeStop", b, this._uiHash()); for (var f = 0; f < d.length; f++) d[f].call(this, b); this._trigger("stop", b, this._uiHash()) } return !1 } c || this._trigger("beforeStop", b, this._uiHash()), this.placeholder[0].parentNode.removeChild(this.placeholder[0]), this.helper[0] != this.currentItem[0] && this.helper.remove(), this.helper = null; if (!c) { for (var f = 0; f < d.length; f++) d[f].call(this, b); this._trigger("stop", b, this._uiHash()) } this.fromOutside = !1; return !0 }, _trigger: function () { a.Widget.prototype._trigger.apply(this, arguments) === !1 && this.cancel() }, _uiHash: function (b) { var c = b || this; return { helper: c.helper, placeholder: c.placeholder || a([]), position: c.position, originalPosition: c.originalPosition, offset: c.positionAbs, item: c.currentItem, sender: b ? b.element : null} } }), a.extend(a.ui.sortable, { version: "1.8.18" }) })(jQuery); /*
* jQuery UI Accordion 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Accordion
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.accordion", { options: { active: 0, animated: "slide", autoHeight: !0, clearStyle: !1, collapsible: !1, event: "click", fillSpace: !1, header: "> li > :first-child,> :not(li):even", icons: { header: "ui-icon-triangle-1-e", headerSelected: "ui-icon-triangle-1-s" }, navigation: !1, navigationFilter: function () { return this.href.toLowerCase() === location.href.toLowerCase() } }, _create: function () { var b = this, c = b.options; b.running = 0, b.element.addClass("ui-accordion ui-widget ui-helper-reset").children("li").addClass("ui-accordion-li-fix"), b.headers = b.element.find(c.header).addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-all").bind("mouseenter.accordion", function () { c.disabled || a(this).addClass("ui-state-hover") }).bind("mouseleave.accordion", function () { c.disabled || a(this).removeClass("ui-state-hover") }).bind("focus.accordion", function () { c.disabled || a(this).addClass("ui-state-focus") }).bind("blur.accordion", function () { c.disabled || a(this).removeClass("ui-state-focus") }), b.headers.next().addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom"); if (c.navigation) { var d = b.element.find("a").filter(c.navigationFilter).eq(0); if (d.length) { var e = d.closest(".ui-accordion-header"); e.length ? b.active = e : b.active = d.closest(".ui-accordion-content").prev() } } b.active = b._findActive(b.active || c.active).addClass("ui-state-default ui-state-active").toggleClass("ui-corner-all").toggleClass("ui-corner-top"), b.active.next().addClass("ui-accordion-content-active"), b._createIcons(), b.resize(), b.element.attr("role", "tablist"), b.headers.attr("role", "tab").bind("keydown.accordion", function (a) { return b._keydown(a) }).next().attr("role", "tabpanel"), b.headers.not(b.active || "").attr({ "aria-expanded": "false", "aria-selected": "false", tabIndex: -1 }).next().hide(), b.active.length ? b.active.attr({ "aria-expanded": "true", "aria-selected": "true", tabIndex: 0 }) : b.headers.eq(0).attr("tabIndex", 0), a.browser.safari || b.headers.find("a").attr("tabIndex", -1), c.event && b.headers.bind(c.event.split(" ").join(".accordion ") + ".accordion", function (a) { b._clickHandler.call(b, a, this), a.preventDefault() }) }, _createIcons: function () { var b = this.options; b.icons && (a("<span></span>").addClass("ui-icon " + b.icons.header).prependTo(this.headers), this.active.children(".ui-icon").toggleClass(b.icons.header).toggleClass(b.icons.headerSelected), this.element.addClass("ui-accordion-icons")) }, _destroyIcons: function () { this.headers.children(".ui-icon").remove(), this.element.removeClass("ui-accordion-icons") }, destroy: function () { var b = this.options; this.element.removeClass("ui-accordion ui-widget ui-helper-reset").removeAttr("role"), this.headers.unbind(".accordion").removeClass("ui-accordion-header ui-accordion-disabled ui-helper-reset ui-state-default ui-corner-all ui-state-active ui-state-disabled ui-corner-top").removeAttr("role").removeAttr("aria-expanded").removeAttr("aria-selected").removeAttr("tabIndex"), this.headers.find("a").removeAttr("tabIndex"), this._destroyIcons(); var c = this.headers.next().css("display", "").removeAttr("role").removeClass("ui-helper-reset ui-widget-content ui-corner-bottom ui-accordion-content ui-accordion-content-active ui-accordion-disabled ui-state-disabled"); (b.autoHeight || b.fillHeight) && c.css("height", ""); return a.Widget.prototype.destroy.call(this) }, _setOption: function (b, c) { a.Widget.prototype._setOption.apply(this, arguments), b == "active" && this.activate(c), b == "icons" && (this._destroyIcons(), c && this._createIcons()), b == "disabled" && this.headers.add(this.headers.next())[c ? "addClass" : "removeClass"]("ui-accordion-disabled ui-state-disabled") }, _keydown: function (b) { if (!(this.options.disabled || b.altKey || b.ctrlKey)) { var c = a.ui.keyCode, d = this.headers.length, e = this.headers.index(b.target), f = !1; switch (b.keyCode) { case c.RIGHT: case c.DOWN: f = this.headers[(e + 1) % d]; break; case c.LEFT: case c.UP: f = this.headers[(e - 1 + d) % d]; break; case c.SPACE: case c.ENTER: this._clickHandler({ target: b.target }, b.target), b.preventDefault() } if (f) { a(b.target).attr("tabIndex", -1), a(f).attr("tabIndex", 0), f.focus(); return !1 } return !0 } }, resize: function () { var b = this.options, c; if (b.fillSpace) { if (a.browser.msie) { var d = this.element.parent().css("overflow"); this.element.parent().css("overflow", "hidden") } c = this.element.parent().height(), a.browser.msie && this.element.parent().css("overflow", d), this.headers.each(function () { c -= a(this).outerHeight(!0) }), this.headers.next().each(function () { a(this).height(Math.max(0, c - a(this).innerHeight() + a(this).height())) }).css("overflow", "auto") } else b.autoHeight && (c = 0, this.headers.next().each(function () { c = Math.max(c, a(this).height("").height()) }).height(c)); return this }, activate: function (a) { this.options.active = a; var b = this._findActive(a)[0]; this._clickHandler({ target: b }, b); return this }, _findActive: function (b) { return b ? typeof b == "number" ? this.headers.filter(":eq(" + b + ")") : this.headers.not(this.headers.not(b)) : b === !1 ? a([]) : this.headers.filter(":eq(0)") }, _clickHandler: function (b, c) { var d = this.options; if (!d.disabled) { if (!b.target) { if (!d.collapsible) return; this.active.removeClass("ui-state-active ui-corner-top").addClass("ui-state-default ui-corner-all").children(".ui-icon").removeClass(d.icons.headerSelected).addClass(d.icons.header), this.active.next().addClass("ui-accordion-content-active"); var e = this.active.next(), f = { options: d, newHeader: a([]), oldHeader: d.active, newContent: a([]), oldContent: e }, g = this.active = a([]); this._toggle(g, e, f); return } var h = a(b.currentTarget || c), i = h[0] === this.active[0]; d.active = d.collapsible && i ? !1 : this.headers.index(h); if (this.running || !d.collapsible && i) return; var j = this.active, g = h.next(), e = this.active.next(), f = { options: d, newHeader: i && d.collapsible ? a([]) : h, oldHeader: this.active, newContent: i && d.collapsible ? a([]) : g, oldContent: e }, k = this.headers.index(this.active[0]) > this.headers.index(h[0]); this.active = i ? a([]) : h, this._toggle(g, e, f, i, k), j.removeClass("ui-state-active ui-corner-top").addClass("ui-state-default ui-corner-all").children(".ui-icon").removeClass(d.icons.headerSelected).addClass(d.icons.header), i || (h.removeClass("ui-state-default ui-corner-all").addClass("ui-state-active ui-corner-top").children(".ui-icon").removeClass(d.icons.header).addClass(d.icons.headerSelected), h.next().addClass("ui-accordion-content-active")); return } }, _toggle: function (b, c, d, e, f) { var g = this, h = g.options; g.toShow = b, g.toHide = c, g.data = d; var i = function () { if (!!g) return g._completed.apply(g, arguments) }; g._trigger("changestart", null, g.data), g.running = c.size() === 0 ? b.size() : c.size(); if (h.animated) { var j = {}; h.collapsible && e ? j = { toShow: a([]), toHide: c, complete: i, down: f, autoHeight: h.autoHeight || h.fillSpace} : j = { toShow: b, toHide: c, complete: i, down: f, autoHeight: h.autoHeight || h.fillSpace }, h.proxied || (h.proxied = h.animated), h.proxiedDuration || (h.proxiedDuration = h.duration), h.animated = a.isFunction(h.proxied) ? h.proxied(j) : h.proxied, h.duration = a.isFunction(h.proxiedDuration) ? h.proxiedDuration(j) : h.proxiedDuration; var k = a.ui.accordion.animations, l = h.duration, m = h.animated; m && !k[m] && !a.easing[m] && (m = "slide"), k[m] || (k[m] = function (a) { this.slide(a, { easing: m, duration: l || 700 }) }), k[m](j) } else h.collapsible && e ? b.toggle() : (c.hide(), b.show()), i(!0); c.prev().attr({ "aria-expanded": "false", "aria-selected": "false", tabIndex: -1 }).blur(), b.prev().attr({ "aria-expanded": "true", "aria-selected": "true", tabIndex: 0 }).focus() }, _completed: function (a) { this.running = a ? 0 : --this.running; this.running || (this.options.clearStyle && this.toShow.add(this.toHide).css({ height: "", overflow: "" }), this.toHide.removeClass("ui-accordion-content-active"), this.toHide.length && (this.toHide.parent()[0].className = this.toHide.parent()[0].className), this._trigger("change", null, this.data)) } }), a.extend(a.ui.accordion, { version: "1.8.18", animations: { slide: function (b, c) { b = a.extend({ easing: "swing", duration: 300 }, b, c); if (!b.toHide.size()) b.toShow.animate({ height: "show", paddingTop: "show", paddingBottom: "show" }, b); else { if (!b.toShow.size()) { b.toHide.animate({ height: "hide", paddingTop: "hide", paddingBottom: "hide" }, b); return } var d = b.toShow.css("overflow"), e = 0, f = {}, g = {}, h = ["height", "paddingTop", "paddingBottom"], i, j = b.toShow; i = j[0].style.width, j.width(j.parent().width() - parseFloat(j.css("paddingLeft")) - parseFloat(j.css("paddingRight")) - (parseFloat(j.css("borderLeftWidth")) || 0) - (parseFloat(j.css("borderRightWidth")) || 0)), a.each(h, function (c, d) { g[d] = "hide"; var e = ("" + a.css(b.toShow[0], d)).match(/^([\d+-.]+)(.*)$/); f[d] = { value: e[1], unit: e[2] || "px"} }), b.toShow.css({ height: 0, overflow: "hidden" }).show(), b.toHide.filter(":hidden").each(b.complete).end().filter(":visible").animate(g, { step: function (a, c) { c.prop == "height" && (e = c.end - c.start === 0 ? 0 : (c.now - c.start) / (c.end - c.start)), b.toShow[0].style[c.prop] = e * f[c.prop].value + f[c.prop].unit }, duration: b.duration, easing: b.easing, complete: function () { b.autoHeight || b.toShow.css("height", ""), b.toShow.css({ width: i, overflow: d }), b.complete() } }) } }, bounceslide: function (a) { this.slide(a, { easing: a.down ? "easeOutBounce" : "swing", duration: a.down ? 1e3 : 200 }) } } }) })(jQuery); /*
* jQuery UI Autocomplete 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Autocomplete
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*	jquery.ui.position.js
*/
(function (a, b) { var c = 0; a.widget("ui.autocomplete", { options: { appendTo: "body", autoFocus: !1, delay: 300, minLength: 1, position: { my: "left top", at: "left bottom", collision: "none" }, source: null }, pending: 0, _create: function () { var b = this, c = this.element[0].ownerDocument, d; this.element.addClass("ui-autocomplete-input").attr("autocomplete", "off").attr({ role: "textbox", "aria-autocomplete": "list", "aria-haspopup": "true" }).bind("keydown.autocomplete", function (c) { if (!b.options.disabled && !b.element.propAttr("readOnly")) { d = !1; var e = a.ui.keyCode; switch (c.keyCode) { case e.PAGE_UP: b._move("previousPage", c); break; case e.PAGE_DOWN: b._move("nextPage", c); break; case e.UP: b._move("previous", c), c.preventDefault(); break; case e.DOWN: b._move("next", c), c.preventDefault(); break; case e.ENTER: case e.NUMPAD_ENTER: b.menu.active && (d = !0, c.preventDefault()); case e.TAB: if (!b.menu.active) return; b.menu.select(c); break; case e.ESCAPE: b.element.val(b.term), b.close(c); break; default: clearTimeout(b.searching), b.searching = setTimeout(function () { b.term != b.element.val() && (b.selectedItem = null, b.search(null, c)) }, b.options.delay) } } }).bind("keypress.autocomplete", function (a) { d && (d = !1, a.preventDefault()) }).bind("focus.autocomplete", function () { b.options.disabled || (b.selectedItem = null, b.previous = b.element.val()) }).bind("blur.autocomplete", function (a) { b.options.disabled || (clearTimeout(b.searching), b.closing = setTimeout(function () { b.close(a), b._change(a) }, 150)) }), this._initSource(), this.response = function () { return b._response.apply(b, arguments) }, this.menu = a("<ul></ul>").addClass("ui-autocomplete").appendTo(a(this.options.appendTo || "body", c)[0]).mousedown(function (c) { var d = b.menu.element[0]; a(c.target).closest(".ui-menu-item").length || setTimeout(function () { a(document).one("mousedown", function (c) { c.target !== b.element[0] && c.target !== d && !a.ui.contains(d, c.target) && b.close() }) }, 1), setTimeout(function () { clearTimeout(b.closing) }, 13) }).menu({ focus: function (a, c) { var d = c.item.data("item.autocomplete"); !1 !== b._trigger("focus", a, { item: d }) && /^key/.test(a.originalEvent.type) && b.element.val(d.value) }, selected: function (a, d) { var e = d.item.data("item.autocomplete"), f = b.previous; b.element[0] !== c.activeElement && (b.element.focus(), b.previous = f, setTimeout(function () { b.previous = f, b.selectedItem = e }, 1)), !1 !== b._trigger("select", a, { item: e }) && b.element.val(e.value), b.term = b.element.val(), b.close(a), b.selectedItem = e }, blur: function (a, c) { b.menu.element.is(":visible") && b.element.val() !== b.term && b.element.val(b.term) } }).zIndex(this.element.zIndex() + 1).css({ top: 0, left: 0 }).hide().data("menu"), a.fn.bgiframe && this.menu.element.bgiframe(), b.beforeunloadHandler = function () { b.element.removeAttr("autocomplete") }, a(window).bind("beforeunload", b.beforeunloadHandler) }, destroy: function () { this.element.removeClass("ui-autocomplete-input").removeAttr("autocomplete").removeAttr("role").removeAttr("aria-autocomplete").removeAttr("aria-haspopup"), this.menu.element.remove(), a(window).unbind("beforeunload", this.beforeunloadHandler), a.Widget.prototype.destroy.call(this) }, _setOption: function (b, c) { a.Widget.prototype._setOption.apply(this, arguments), b === "source" && this._initSource(), b === "appendTo" && this.menu.element.appendTo(a(c || "body", this.element[0].ownerDocument)[0]), b === "disabled" && c && this.xhr && this.xhr.abort() }, _initSource: function () { var b = this, d, e; a.isArray(this.options.source) ? (d = this.options.source, this.source = function (b, c) { c(a.ui.autocomplete.filter(d, b.term)) }) : typeof this.options.source == "string" ? (e = this.options.source, this.source = function (d, f) { b.xhr && b.xhr.abort(), b.xhr = a.ajax({ url: e, data: d, dataType: "json", context: { autocompleteRequest: ++c }, success: function (a, b) { this.autocompleteRequest === c && f(a) }, error: function () { this.autocompleteRequest === c && f([]) } }) }) : this.source = this.options.source }, search: function (a, b) { a = a != null ? a : this.element.val(), this.term = this.element.val(); if (a.length < this.options.minLength) return this.close(b); clearTimeout(this.closing); if (this._trigger("search", b) !== !1) return this._search(a) }, _search: function (a) { this.pending++, this.element.addClass("ui-autocomplete-loading"), this.source({ term: a }, this.response) }, _response: function (a) { !this.options.disabled && a && a.length ? (a = this._normalize(a), this._suggest(a), this._trigger("open")) : this.close(), this.pending--, this.pending || this.element.removeClass("ui-autocomplete-loading") }, close: function (a) { clearTimeout(this.closing), this.menu.element.is(":visible") && (this.menu.element.hide(), this.menu.deactivate(), this._trigger("close", a)) }, _change: function (a) { this.previous !== this.element.val() && this._trigger("change", a, { item: this.selectedItem }) }, _normalize: function (b) { if (b.length && b[0].label && b[0].value) return b; return a.map(b, function (b) { if (typeof b == "string") return { label: b, value: b }; return a.extend({ label: b.label || b.value, value: b.value || b.label }, b) }) }, _suggest: function (b) { var c = this.menu.element.empty().zIndex(this.element.zIndex() + 1); this._renderMenu(c, b), this.menu.deactivate(), this.menu.refresh(), c.show(), this._resizeMenu(), c.position(a.extend({ of: this.element }, this.options.position)), this.options.autoFocus && this.menu.next(new a.Event("mouseover")) }, _resizeMenu: function () { var a = this.menu.element; a.outerWidth(Math.max(a.width("").outerWidth() + 1, this.element.outerWidth())) }, _renderMenu: function (b, c) { var d = this; a.each(c, function (a, c) { d._renderItem(b, c) }) }, _renderItem: function (b, c) { return a("<li></li>").data("item.autocomplete", c).append(a("<a></a>").text(c.label)).appendTo(b) }, _move: function (a, b) { if (!this.menu.element.is(":visible")) this.search(null, b); else { if (this.menu.first() && /^previous/.test(a) || this.menu.last() && /^next/.test(a)) { this.element.val(this.term), this.menu.deactivate(); return } this.menu[a](b) } }, widget: function () { return this.menu.element } }), a.extend(a.ui.autocomplete, { escapeRegex: function (a) { return a.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") }, filter: function (b, c) { var d = new RegExp(a.ui.autocomplete.escapeRegex(c), "i"); return a.grep(b, function (a) { return d.test(a.label || a.value || a) }) } }) })(jQuery), function (a) { a.widget("ui.menu", { _create: function () { var b = this; this.element.addClass("ui-menu ui-widget ui-widget-content ui-corner-all").attr({ role: "listbox", "aria-activedescendant": "ui-active-menuitem" }).click(function (c) { !a(c.target).closest(".ui-menu-item a").length || (c.preventDefault(), b.select(c)) }), this.refresh() }, refresh: function () { var b = this, c = this.element.children("li:not(.ui-menu-item):has(a)").addClass("ui-menu-item").attr("role", "menuitem"); c.children("a").addClass("ui-corner-all").attr("tabindex", -1).mouseenter(function (c) { b.activate(c, a(this).parent()) }).mouseleave(function () { b.deactivate() }) }, activate: function (a, b) { this.deactivate(); if (this.hasScroll()) { var c = b.offset().top - this.element.offset().top, d = this.element.scrollTop(), e = this.element.height(); c < 0 ? this.element.scrollTop(d + c) : c >= e && this.element.scrollTop(d + c - e + b.height()) } this.active = b.eq(0).children("a").addClass("ui-state-hover").attr("id", "ui-active-menuitem").end(), this._trigger("focus", a, { item: b }) }, deactivate: function () { !this.active || (this.active.children("a").removeClass("ui-state-hover").removeAttr("id"), this._trigger("blur"), this.active = null) }, next: function (a) { this.move("next", ".ui-menu-item:first", a) }, previous: function (a) { this.move("prev", ".ui-menu-item:last", a) }, first: function () { return this.active && !this.active.prevAll(".ui-menu-item").length }, last: function () { return this.active && !this.active.nextAll(".ui-menu-item").length }, move: function (a, b, c) { if (!this.active) this.activate(c, this.element.children(b)); else { var d = this.active[a + "All"](".ui-menu-item").eq(0); d.length ? this.activate(c, d) : this.activate(c, this.element.children(b)) } }, nextPage: function (b) { if (this.hasScroll()) { if (!this.active || this.last()) { this.activate(b, this.element.children(".ui-menu-item:first")); return } var c = this.active.offset().top, d = this.element.height(), e = this.element.children(".ui-menu-item").filter(function () { var b = a(this).offset().top - c - d + a(this).height(); return b < 10 && b > -10 }); e.length || (e = this.element.children(".ui-menu-item:last")), this.activate(b, e) } else this.activate(b, this.element.children(".ui-menu-item").filter(!this.active || this.last() ? ":first" : ":last")) }, previousPage: function (b) { if (this.hasScroll()) { if (!this.active || this.first()) { this.activate(b, this.element.children(".ui-menu-item:last")); return } var c = this.active.offset().top, d = this.element.height(); result = this.element.children(".ui-menu-item").filter(function () { var b = a(this).offset().top - c + d - a(this).height(); return b < 10 && b > -10 }), result.length || (result = this.element.children(".ui-menu-item:first")), this.activate(b, result) } else this.activate(b, this.element.children(".ui-menu-item").filter(!this.active || this.first() ? ":last" : ":first")) }, hasScroll: function () { return this.element.height() < this.element[a.fn.prop ? "prop" : "attr"]("scrollHeight") }, select: function (a) { this._trigger("selected", a, { item: this.active }) } }) } (jQuery); /*
* jQuery UI Button 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Button
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*/
(function (a, b) { var c, d, e, f, g = "ui-button ui-widget ui-state-default ui-corner-all", h = "ui-state-hover ui-state-active ", i = "ui-button-icons-only ui-button-icon-only ui-button-text-icons ui-button-text-icon-primary ui-button-text-icon-secondary ui-button-text-only", j = function () { var b = a(this).find(":ui-button"); setTimeout(function () { b.button("refresh") }, 1) }, k = function (b) { var c = b.name, d = b.form, e = a([]); c && (d ? e = a(d).find("[name='" + c + "']") : e = a("[name='" + c + "']", b.ownerDocument).filter(function () { return !this.form })); return e }; a.widget("ui.button", { options: { disabled: null, text: !0, label: null, icons: { primary: null, secondary: null} }, _create: function () { this.element.closest("form").unbind("reset.button").bind("reset.button", j), typeof this.options.disabled != "boolean" ? this.options.disabled = !!this.element.propAttr("disabled") : this.element.propAttr("disabled", this.options.disabled), this._determineButtonType(), this.hasTitle = !!this.buttonElement.attr("title"); var b = this, h = this.options, i = this.type === "checkbox" || this.type === "radio", l = "ui-state-hover" + (i ? "" : " ui-state-active"), m = "ui-state-focus"; h.label === null && (h.label = this.buttonElement.html()), this.buttonElement.addClass(g).attr("role", "button").bind("mouseenter.button", function () { h.disabled || (a(this).addClass("ui-state-hover"), this === c && a(this).addClass("ui-state-active")) }).bind("mouseleave.button", function () { h.disabled || a(this).removeClass(l) }).bind("click.button", function (a) { h.disabled && (a.preventDefault(), a.stopImmediatePropagation()) }), this.element.bind("focus.button", function () { b.buttonElement.addClass(m) }).bind("blur.button", function () { b.buttonElement.removeClass(m) }), i && (this.element.bind("change.button", function () { f || b.refresh() }), this.buttonElement.bind("mousedown.button", function (a) { h.disabled || (f = !1, d = a.pageX, e = a.pageY) }).bind("mouseup.button", function (a) { !h.disabled && (d !== a.pageX || e !== a.pageY) && (f = !0) })), this.type === "checkbox" ? this.buttonElement.bind("click.button", function () { if (h.disabled || f) return !1; a(this).toggleClass("ui-state-active"), b.buttonElement.attr("aria-pressed", b.element[0].checked) }) : this.type === "radio" ? this.buttonElement.bind("click.button", function () { if (h.disabled || f) return !1; a(this).addClass("ui-state-active"), b.buttonElement.attr("aria-pressed", "true"); var c = b.element[0]; k(c).not(c).map(function () { return a(this).button("widget")[0] }).removeClass("ui-state-active").attr("aria-pressed", "false") }) : (this.buttonElement.bind("mousedown.button", function () { if (h.disabled) return !1; a(this).addClass("ui-state-active"), c = this, a(document).one("mouseup", function () { c = null }) }).bind("mouseup.button", function () { if (h.disabled) return !1; a(this).removeClass("ui-state-active") }).bind("keydown.button", function (b) { if (h.disabled) return !1; (b.keyCode == a.ui.keyCode.SPACE || b.keyCode == a.ui.keyCode.ENTER) && a(this).addClass("ui-state-active") }).bind("keyup.button", function () { a(this).removeClass("ui-state-active") }), this.buttonElement.is("a") && this.buttonElement.keyup(function (b) { b.keyCode === a.ui.keyCode.SPACE && a(this).click() })), this._setOption("disabled", h.disabled), this._resetButton() }, _determineButtonType: function () { this.element.is(":checkbox") ? this.type = "checkbox" : this.element.is(":radio") ? this.type = "radio" : this.element.is("input") ? this.type = "input" : this.type = "button"; if (this.type === "checkbox" || this.type === "radio") { var a = this.element.parents().filter(":last"), b = "label[for='" + this.element.attr("id") + "']"; this.buttonElement = a.find(b), this.buttonElement.length || (a = a.length ? a.siblings() : this.element.siblings(), this.buttonElement = a.filter(b), this.buttonElement.length || (this.buttonElement = a.find(b))), this.element.addClass("ui-helper-hidden-accessible"); var c = this.element.is(":checked"); c && this.buttonElement.addClass("ui-state-active"), this.buttonElement.attr("aria-pressed", c) } else this.buttonElement = this.element }, widget: function () { return this.buttonElement }, destroy: function () { this.element.removeClass("ui-helper-hidden-accessible"), this.buttonElement.removeClass(g + " " + h + " " + i).removeAttr("role").removeAttr("aria-pressed").html(this.buttonElement.find(".ui-button-text").html()), this.hasTitle || this.buttonElement.removeAttr("title"), a.Widget.prototype.destroy.call(this) }, _setOption: function (b, c) { a.Widget.prototype._setOption.apply(this, arguments); b === "disabled" ? c ? this.element.propAttr("disabled", !0) : this.element.propAttr("disabled", !1) : this._resetButton() }, refresh: function () { var b = this.element.is(":disabled"); b !== this.options.disabled && this._setOption("disabled", b), this.type === "radio" ? k(this.element[0]).each(function () { a(this).is(":checked") ? a(this).button("widget").addClass("ui-state-active").attr("aria-pressed", "true") : a(this).button("widget").removeClass("ui-state-active").attr("aria-pressed", "false") }) : this.type === "checkbox" && (this.element.is(":checked") ? this.buttonElement.addClass("ui-state-active").attr("aria-pressed", "true") : this.buttonElement.removeClass("ui-state-active").attr("aria-pressed", "false")) }, _resetButton: function () { if (this.type === "input") this.options.label && this.element.val(this.options.label); else { var b = this.buttonElement.removeClass(i), c = a("<span></span>", this.element[0].ownerDocument).addClass("ui-button-text").html(this.options.label).appendTo(b.empty()).text(), d = this.options.icons, e = d.primary && d.secondary, f = []; d.primary || d.secondary ? (this.options.text && f.push("ui-button-text-icon" + (e ? "s" : d.primary ? "-primary" : "-secondary")), d.primary && b.prepend("<span class='ui-button-icon-primary ui-icon " + d.primary + "'></span>"), d.secondary && b.append("<span class='ui-button-icon-secondary ui-icon " + d.secondary + "'></span>"), this.options.text || (f.push(e ? "ui-button-icons-only" : "ui-button-icon-only"), this.hasTitle || b.attr("title", c))) : f.push("ui-button-text-only"), b.addClass(f.join(" ")) } } }), a.widget("ui.buttonset", { options: { items: ":button, :submit, :reset, :checkbox, :radio, a, :data(button)" }, _create: function () { this.element.addClass("ui-buttonset") }, _init: function () { this.refresh() }, _setOption: function (b, c) { b === "disabled" && this.buttons.button("option", b, c), a.Widget.prototype._setOption.apply(this, arguments) }, refresh: function () { var b = this.element.css("direction") === "rtl"; this.buttons = this.element.find(this.options.items).filter(":ui-button").button("refresh").end().not(":ui-button").button().end().map(function () { return a(this).button("widget")[0] }).removeClass("ui-corner-all ui-corner-left ui-corner-right").filter(":first").addClass(b ? "ui-corner-right" : "ui-corner-left").end().filter(":last").addClass(b ? "ui-corner-left" : "ui-corner-right").end().end() }, destroy: function () { this.element.removeClass("ui-buttonset"), this.buttons.map(function () { return a(this).button("widget")[0] }).removeClass("ui-corner-left ui-corner-right").end().button("destroy"), a.Widget.prototype.destroy.call(this) } }) })(jQuery); /*
* jQuery UI Dialog 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Dialog
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*  jquery.ui.button.js
*	jquery.ui.draggable.js
*	jquery.ui.mouse.js
*	jquery.ui.position.js
*	jquery.ui.resizable.js
*/
(function (a, b) { var c = "ui-dialog ui-widget ui-widget-content ui-corner-all ", d = { buttons: !0, height: !0, maxHeight: !0, maxWidth: !0, minHeight: !0, minWidth: !0, width: !0 }, e = { maxHeight: !0, maxWidth: !0, minHeight: !0, minWidth: !0 }, f = a.attrFn || { val: !0, css: !0, html: !0, text: !0, data: !0, width: !0, height: !0, offset: !0, click: !0 }; a.widget("ui.dialog", { options: { autoOpen: !0, buttons: {}, closeOnEscape: !0, closeText: "close", dialogClass: "", draggable: !0, hide: null, height: "auto", maxHeight: !1, maxWidth: !1, minHeight: 150, minWidth: 150, modal: !1, position: { my: "center", at: "center", collision: "fit", using: function (b) { var c = a(this).css(b).offset().top; c < 0 && a(this).css("top", b.top - c) } }, resizable: !0, show: null, stack: !0, title: "", width: 300, zIndex: 1e3 }, _create: function () { this.originalTitle = this.element.attr("title"), typeof this.originalTitle != "string" && (this.originalTitle = ""), this.options.title = this.options.title || this.originalTitle; var b = this, d = b.options, e = d.title || "&#160;", f = a.ui.dialog.getTitleId(b.element), g = (b.uiDialog = a("<div></div>")).appendTo(document.body).hide().addClass(c + d.dialogClass).css({ zIndex: d.zIndex }).attr("tabIndex", -1).css("outline", 0).keydown(function (c) { d.closeOnEscape && !c.isDefaultPrevented() && c.keyCode && c.keyCode === a.ui.keyCode.ESCAPE && (b.close(c), c.preventDefault()) }).attr({ role: "dialog", "aria-labelledby": f }).mousedown(function (a) { b.moveToTop(!1, a) }), h = b.element.show().removeAttr("title").addClass("ui-dialog-content ui-widget-content").appendTo(g), i = (b.uiDialogTitlebar = a("<div></div>")).addClass("ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix").prependTo(g), j = a('<a href="#"></a>').addClass("ui-dialog-titlebar-close ui-corner-all").attr("role", "button").hover(function () { j.addClass("ui-state-hover") }, function () { j.removeClass("ui-state-hover") }).focus(function () { j.addClass("ui-state-focus") }).blur(function () { j.removeClass("ui-state-focus") }).click(function (a) { b.close(a); return !1 }).appendTo(i), k = (b.uiDialogTitlebarCloseText = a("<span></span>")).addClass("ui-icon ui-icon-closethick").text(d.closeText).appendTo(j), l = a("<span></span>").addClass("ui-dialog-title").attr("id", f).html(e).prependTo(i); a.isFunction(d.beforeclose) && !a.isFunction(d.beforeClose) && (d.beforeClose = d.beforeclose), i.find("*").add(i).disableSelection(), d.draggable && a.fn.draggable && b._makeDraggable(), d.resizable && a.fn.resizable && b._makeResizable(), b._createButtons(d.buttons), b._isOpen = !1, a.fn.bgiframe && g.bgiframe() }, _init: function () { this.options.autoOpen && this.open() }, destroy: function () { var a = this; a.overlay && a.overlay.destroy(), a.uiDialog.hide(), a.element.unbind(".dialog").removeData("dialog").removeClass("ui-dialog-content ui-widget-content").hide().appendTo("body"), a.uiDialog.remove(), a.originalTitle && a.element.attr("title", a.originalTitle); return a }, widget: function () { return this.uiDialog }, close: function (b) { var c = this, d, e; if (!1 !== c._trigger("beforeClose", b)) { c.overlay && c.overlay.destroy(), c.uiDialog.unbind("keypress.ui-dialog"), c._isOpen = !1, c.options.hide ? c.uiDialog.hide(c.options.hide, function () { c._trigger("close", b) }) : (c.uiDialog.hide(), c._trigger("close", b)), a.ui.dialog.overlay.resize(), c.options.modal && (d = 0, a(".ui-dialog").each(function () { this !== c.uiDialog[0] && (e = a(this).css("z-index"), isNaN(e) || (d = Math.max(d, e))) }), a.ui.dialog.maxZ = d); return c } }, isOpen: function () { return this._isOpen }, moveToTop: function (b, c) { var d = this, e = d.options, f; if (e.modal && !b || !e.stack && !e.modal) return d._trigger("focus", c); e.zIndex > a.ui.dialog.maxZ && (a.ui.dialog.maxZ = e.zIndex), d.overlay && (a.ui.dialog.maxZ += 1, d.overlay.$el.css("z-index", a.ui.dialog.overlay.maxZ = a.ui.dialog.maxZ)), f = { scrollTop: d.element.scrollTop(), scrollLeft: d.element.scrollLeft() }, a.ui.dialog.maxZ += 1, d.uiDialog.css("z-index", a.ui.dialog.maxZ), d.element.attr(f), d._trigger("focus", c); return d }, open: function () { if (!this._isOpen) { var b = this, c = b.options, d = b.uiDialog; b.overlay = c.modal ? new a.ui.dialog.overlay(b) : null, b._size(), b._position(c.position), d.show(c.show), b.moveToTop(!0), c.modal && d.bind("keydown.ui-dialog", function (b) { if (b.keyCode === a.ui.keyCode.TAB) { var c = a(":tabbable", this), d = c.filter(":first"), e = c.filter(":last"); if (b.target === e[0] && !b.shiftKey) { d.focus(1); return !1 } if (b.target === d[0] && b.shiftKey) { e.focus(1); return !1 } } }), a(b.element.find(":tabbable").get().concat(d.find(".ui-dialog-buttonpane :tabbable").get().concat(d.get()))).eq(0).focus(), b._isOpen = !0, b._trigger("open"); return b } }, _createButtons: function (b) { var c = this, d = !1, e = a("<div></div>").addClass("ui-dialog-buttonpane ui-widget-content ui-helper-clearfix"), g = a("<div></div>").addClass("ui-dialog-buttonset").appendTo(e); c.uiDialog.find(".ui-dialog-buttonpane").remove(), typeof b == "object" && b !== null && a.each(b, function () { return !(d = !0) }), d && (a.each(b, function (b, d) { d = a.isFunction(d) ? { click: d, text: b} : d; var e = a('<button type="button"></button>').click(function () { d.click.apply(c.element[0], arguments) }).appendTo(g); a.each(d, function (a, b) { a !== "click" && (a in f ? e[a](b) : e.attr(a, b)) }), a.fn.button && e.button() }), e.appendTo(c.uiDialog)) }, _makeDraggable: function () { function f(a) { return { position: a.position, offset: a.offset} } var b = this, c = b.options, d = a(document), e; b.uiDialog.draggable({ cancel: ".ui-dialog-content, .ui-dialog-titlebar-close", handle: ".ui-dialog-titlebar", containment: "document", start: function (d, g) { e = c.height === "auto" ? "auto" : a(this).height(), a(this).height(a(this).height()).addClass("ui-dialog-dragging"), b._trigger("dragStart", d, f(g)) }, drag: function (a, c) { b._trigger("drag", a, f(c)) }, stop: function (g, h) { c.position = [h.position.left - d.scrollLeft(), h.position.top - d.scrollTop()], a(this).removeClass("ui-dialog-dragging").height(e), b._trigger("dragStop", g, f(h)), a.ui.dialog.overlay.resize() } }) }, _makeResizable: function (c) { function h(a) { return { originalPosition: a.originalPosition, originalSize: a.originalSize, position: a.position, size: a.size} } c = c === b ? this.options.resizable : c; var d = this, e = d.options, f = d.uiDialog.css("position"), g = typeof c == "string" ? c : "n,e,s,w,se,sw,ne,nw"; d.uiDialog.resizable({ cancel: ".ui-dialog-content", containment: "document", alsoResize: d.element, maxWidth: e.maxWidth, maxHeight: e.maxHeight, minWidth: e.minWidth, minHeight: d._minHeight(), handles: g, start: function (b, c) { a(this).addClass("ui-dialog-resizing"), d._trigger("resizeStart", b, h(c)) }, resize: function (a, b) { d._trigger("resize", a, h(b)) }, stop: function (b, c) { a(this).removeClass("ui-dialog-resizing"), e.height = a(this).height(), e.width = a(this).width(), d._trigger("resizeStop", b, h(c)), a.ui.dialog.overlay.resize() } }).css("position", f).find(".ui-resizable-se").addClass("ui-icon ui-icon-grip-diagonal-se") }, _minHeight: function () { var a = this.options; return a.height === "auto" ? a.minHeight : Math.min(a.minHeight, a.height) }, _position: function (b) { var c = [], d = [0, 0], e; if (b) { if (typeof b == "string" || typeof b == "object" && "0" in b) c = b.split ? b.split(" ") : [b[0], b[1]], c.length === 1 && (c[1] = c[0]), a.each(["left", "top"], function (a, b) { +c[a] === c[a] && (d[a] = c[a], c[a] = b) }), b = { my: c.join(" "), at: c.join(" "), offset: d.join(" ") }; b = a.extend({}, a.ui.dialog.prototype.options.position, b) } else b = a.ui.dialog.prototype.options.position; e = this.uiDialog.is(":visible"), e || this.uiDialog.show(), this.uiDialog.css({ top: 0, left: 0 }).position(a.extend({ of: window }, b)), e || this.uiDialog.hide() }, _setOptions: function (b) { var c = this, f = {}, g = !1; a.each(b, function (a, b) { c._setOption(a, b), a in d && (g = !0), a in e && (f[a] = b) }), g && this._size(), this.uiDialog.is(":data(resizable)") && this.uiDialog.resizable("option", f) }, _setOption: function (b, d) { var e = this, f = e.uiDialog; switch (b) { case "beforeclose": b = "beforeClose"; break; case "buttons": e._createButtons(d); break; case "closeText": e.uiDialogTitlebarCloseText.text("" + d); break; case "dialogClass": f.removeClass(e.options.dialogClass).addClass(c + d); break; case "disabled": d ? f.addClass("ui-dialog-disabled") : f.removeClass("ui-dialog-disabled"); break; case "draggable": var g = f.is(":data(draggable)"); g && !d && f.draggable("destroy"), !g && d && e._makeDraggable(); break; case "position": e._position(d); break; case "resizable": var h = f.is(":data(resizable)"); h && !d && f.resizable("destroy"), h && typeof d == "string" && f.resizable("option", "handles", d), !h && d !== !1 && e._makeResizable(d); break; case "title": a(".ui-dialog-title", e.uiDialogTitlebar).html("" + (d || "&#160;")) } a.Widget.prototype._setOption.apply(e, arguments) }, _size: function () { var b = this.options, c, d, e = this.uiDialog.is(":visible"); this.element.show().css({ width: "auto", minHeight: 0, height: 0 }), b.minWidth > b.width && (b.width = b.minWidth), c = this.uiDialog.css({ height: "auto", width: b.width }).height(), d = Math.max(0, b.minHeight - c); if (b.height === "auto") if (a.support.minHeight) this.element.css({ minHeight: d, height: "auto" }); else { this.uiDialog.show(); var f = this.element.css("height", "auto").height(); e || this.uiDialog.hide(), this.element.height(Math.max(f, d)) } else this.element.height(Math.max(b.height - c, 0)); this.uiDialog.is(":data(resizable)") && this.uiDialog.resizable("option", "minHeight", this._minHeight()) } }), a.extend(a.ui.dialog, { version: "1.8.18", uuid: 0, maxZ: 0, getTitleId: function (a) { var b = a.attr("id"); b || (this.uuid += 1, b = this.uuid); return "ui-dialog-title-" + b }, overlay: function (b) { this.$el = a.ui.dialog.overlay.create(b) } }), a.extend(a.ui.dialog.overlay, { instances: [], oldInstances: [], maxZ: 0, events: a.map("focus,mousedown,mouseup,keydown,keypress,click".split(","), function (a) { return a + ".dialog-overlay" }).join(" "), create: function (b) { this.instances.length === 0 && (setTimeout(function () { a.ui.dialog.overlay.instances.length && a(document).bind(a.ui.dialog.overlay.events, function (b) { if (a(b.target).zIndex() < a.ui.dialog.overlay.maxZ) return !1 }) }, 1), a(document).bind("keydown.dialog-overlay", function (c) { b.options.closeOnEscape && !c.isDefaultPrevented() && c.keyCode && c.keyCode === a.ui.keyCode.ESCAPE && (b.close(c), c.preventDefault()) }), a(window).bind("resize.dialog-overlay", a.ui.dialog.overlay.resize)); var c = (this.oldInstances.pop() || a("<div></div>").addClass("ui-widget-overlay")).appendTo(document.body).css({ width: this.width(), height: this.height() }); a.fn.bgiframe && c.bgiframe(), this.instances.push(c); return c }, destroy: function (b) { var c = a.inArray(b, this.instances); c != -1 && this.oldInstances.push(this.instances.splice(c, 1)[0]), this.instances.length === 0 && a([document, window]).unbind(".dialog-overlay"), b.remove(); var d = 0; a.each(this.instances, function () { d = Math.max(d, this.css("z-index")) }), this.maxZ = d }, height: function () { var b, c; if (a.browser.msie && a.browser.version < 7) { b = Math.max(document.documentElement.scrollHeight, document.body.scrollHeight), c = Math.max(document.documentElement.offsetHeight, document.body.offsetHeight); return b < c ? a(window).height() + "px" : b + "px" } return a(document).height() + "px" }, width: function () { var b, c; if (a.browser.msie) { b = Math.max(document.documentElement.scrollWidth, document.body.scrollWidth), c = Math.max(document.documentElement.offsetWidth, document.body.offsetWidth); return b < c ? a(window).width() + "px" : b + "px" } return a(document).width() + "px" }, resize: function () { var b = a([]); a.each(a.ui.dialog.overlay.instances, function () { b = b.add(this) }), b.css({ width: 0, height: 0 }).css({ width: a.ui.dialog.overlay.width(), height: a.ui.dialog.overlay.height() }) } }), a.extend(a.ui.dialog.overlay.prototype, { destroy: function () { a.ui.dialog.overlay.destroy(this.$el) } }) })(jQuery); /*
* jQuery UI Slider 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Slider
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.mouse.js
*	jquery.ui.widget.js
*/
(function (a, b) { var c = 5; a.widget("ui.slider", a.ui.mouse, { widgetEventPrefix: "slide", options: { animate: !1, distance: 0, max: 100, min: 0, orientation: "horizontal", range: !1, step: 1, value: 0, values: null }, _create: function () { var b = this, d = this.options, e = this.element.find(".ui-slider-handle").addClass("ui-state-default ui-corner-all"), f = "<a class='ui-slider-handle ui-state-default ui-corner-all' href='#'></a>", g = d.values && d.values.length || 1, h = []; this._keySliding = !1, this._mouseSliding = !1, this._animateOff = !0, this._handleIndex = null, this._detectOrientation(), this._mouseInit(), this.element.addClass("ui-slider ui-slider-" + this.orientation + " ui-widget" + " ui-widget-content" + " ui-corner-all" + (d.disabled ? " ui-slider-disabled ui-disabled" : "")), this.range = a([]), d.range && (d.range === !0 && (d.values || (d.values = [this._valueMin(), this._valueMin()]), d.values.length && d.values.length !== 2 && (d.values = [d.values[0], d.values[0]])), this.range = a("<div></div>").appendTo(this.element).addClass("ui-slider-range ui-widget-header" + (d.range === "min" || d.range === "max" ? " ui-slider-range-" + d.range : ""))); for (var i = e.length; i < g; i += 1) h.push(f); this.handles = e.add(a(h.join("")).appendTo(b.element)), this.handle = this.handles.eq(0), this.handles.add(this.range).filter("a").click(function (a) { a.preventDefault() }).hover(function () { d.disabled || a(this).addClass("ui-state-hover") }, function () { a(this).removeClass("ui-state-hover") }).focus(function () { d.disabled ? a(this).blur() : (a(".ui-slider .ui-state-focus").removeClass("ui-state-focus"), a(this).addClass("ui-state-focus")) }).blur(function () { a(this).removeClass("ui-state-focus") }), this.handles.each(function (b) { a(this).data("index.ui-slider-handle", b) }), this.handles.keydown(function (d) { var e = a(this).data("index.ui-slider-handle"), f, g, h, i; if (!b.options.disabled) { switch (d.keyCode) { case a.ui.keyCode.HOME: case a.ui.keyCode.END: case a.ui.keyCode.PAGE_UP: case a.ui.keyCode.PAGE_DOWN: case a.ui.keyCode.UP: case a.ui.keyCode.RIGHT: case a.ui.keyCode.DOWN: case a.ui.keyCode.LEFT: d.preventDefault(); if (!b._keySliding) { b._keySliding = !0, a(this).addClass("ui-state-active"), f = b._start(d, e); if (f === !1) return } } i = b.options.step, b.options.values && b.options.values.length ? g = h = b.values(e) : g = h = b.value(); switch (d.keyCode) { case a.ui.keyCode.HOME: h = b._valueMin(); break; case a.ui.keyCode.END: h = b._valueMax(); break; case a.ui.keyCode.PAGE_UP: h = b._trimAlignValue(g + (b._valueMax() - b._valueMin()) / c); break; case a.ui.keyCode.PAGE_DOWN: h = b._trimAlignValue(g - (b._valueMax() - b._valueMin()) / c); break; case a.ui.keyCode.UP: case a.ui.keyCode.RIGHT: if (g === b._valueMax()) return; h = b._trimAlignValue(g + i); break; case a.ui.keyCode.DOWN: case a.ui.keyCode.LEFT: if (g === b._valueMin()) return; h = b._trimAlignValue(g - i) } b._slide(d, e, h) } }).keyup(function (c) { var d = a(this).data("index.ui-slider-handle"); b._keySliding && (b._keySliding = !1, b._stop(c, d), b._change(c, d), a(this).removeClass("ui-state-active")) }), this._refreshValue(), this._animateOff = !1 }, destroy: function () { this.handles.remove(), this.range.remove(), this.element.removeClass("ui-slider ui-slider-horizontal ui-slider-vertical ui-slider-disabled ui-widget ui-widget-content ui-corner-all").removeData("slider").unbind(".slider"), this._mouseDestroy(); return this }, _mouseCapture: function (b) { var c = this.options, d, e, f, g, h, i, j, k, l; if (c.disabled) return !1; this.elementSize = { width: this.element.outerWidth(), height: this.element.outerHeight() }, this.elementOffset = this.element.offset(), d = { x: b.pageX, y: b.pageY }, e = this._normValueFromMouse(d), f = this._valueMax() - this._valueMin() + 1, h = this, this.handles.each(function (b) { var c = Math.abs(e - h.values(b)); f > c && (f = c, g = a(this), i = b) }), c.range === !0 && this.values(1) === c.min && (i += 1, g = a(this.handles[i])), j = this._start(b, i); if (j === !1) return !1; this._mouseSliding = !0, h._handleIndex = i, g.addClass("ui-state-active").focus(), k = g.offset(), l = !a(b.target).parents().andSelf().is(".ui-slider-handle"), this._clickOffset = l ? { left: 0, top: 0} : { left: b.pageX - k.left - g.width() / 2, top: b.pageY - k.top - g.height() / 2 - (parseInt(g.css("borderTopWidth"), 10) || 0) - (parseInt(g.css("borderBottomWidth"), 10) || 0) + (parseInt(g.css("marginTop"), 10) || 0) }, this.handles.hasClass("ui-state-hover") || this._slide(b, i, e), this._animateOff = !0; return !0 }, _mouseStart: function (a) { return !0 }, _mouseDrag: function (a) { var b = { x: a.pageX, y: a.pageY }, c = this._normValueFromMouse(b); this._slide(a, this._handleIndex, c); return !1 }, _mouseStop: function (a) { this.handles.removeClass("ui-state-active"), this._mouseSliding = !1, this._stop(a, this._handleIndex), this._change(a, this._handleIndex), this._handleIndex = null, this._clickOffset = null, this._animateOff = !1; return !1 }, _detectOrientation: function () { this.orientation = this.options.orientation === "vertical" ? "vertical" : "horizontal" }, _normValueFromMouse: function (a) { var b, c, d, e, f; this.orientation === "horizontal" ? (b = this.elementSize.width, c = a.x - this.elementOffset.left - (this._clickOffset ? this._clickOffset.left : 0)) : (b = this.elementSize.height, c = a.y - this.elementOffset.top - (this._clickOffset ? this._clickOffset.top : 0)), d = c / b, d > 1 && (d = 1), d < 0 && (d = 0), this.orientation === "vertical" && (d = 1 - d), e = this._valueMax() - this._valueMin(), f = this._valueMin() + d * e; return this._trimAlignValue(f) }, _start: function (a, b) { var c = { handle: this.handles[b], value: this.value() }; this.options.values && this.options.values.length && (c.value = this.values(b), c.values = this.values()); return this._trigger("start", a, c) }, _slide: function (a, b, c) { var d, e, f; this.options.values && this.options.values.length ? (d = this.values(b ? 0 : 1), this.options.values.length === 2 && this.options.range === !0 && (b === 0 && c > d || b === 1 && c < d) && (c = d), c !== this.values(b) && (e = this.values(), e[b] = c, f = this._trigger("slide", a, { handle: this.handles[b], value: c, values: e }), d = this.values(b ? 0 : 1), f !== !1 && this.values(b, c, !0))) : c !== this.value() && (f = this._trigger("slide", a, { handle: this.handles[b], value: c }), f !== !1 && this.value(c)) }, _stop: function (a, b) { var c = { handle: this.handles[b], value: this.value() }; this.options.values && this.options.values.length && (c.value = this.values(b), c.values = this.values()), this._trigger("stop", a, c) }, _change: function (a, b) { if (!this._keySliding && !this._mouseSliding) { var c = { handle: this.handles[b], value: this.value() }; this.options.values && this.options.values.length && (c.value = this.values(b), c.values = this.values()), this._trigger("change", a, c) } }, value: function (a) { if (arguments.length) this.options.value = this._trimAlignValue(a), this._refreshValue(), this._change(null, 0); else return this._value() }, values: function (b, c) { var d, e, f; if (arguments.length > 1) this.options.values[b] = this._trimAlignValue(c), this._refreshValue(), this._change(null, b); else { if (!arguments.length) return this._values(); if (!a.isArray(arguments[0])) return this.options.values && this.options.values.length ? this._values(b) : this.value(); d = this.options.values, e = arguments[0]; for (f = 0; f < d.length; f += 1) d[f] = this._trimAlignValue(e[f]), this._change(null, f); this._refreshValue() } }, _setOption: function (b, c) { var d, e = 0; a.isArray(this.options.values) && (e = this.options.values.length), a.Widget.prototype._setOption.apply(this, arguments); switch (b) { case "disabled": c ? (this.handles.filter(".ui-state-focus").blur(), this.handles.removeClass("ui-state-hover"), this.handles.propAttr("disabled", !0), this.element.addClass("ui-disabled")) : (this.handles.propAttr("disabled", !1), this.element.removeClass("ui-disabled")); break; case "orientation": this._detectOrientation(), this.element.removeClass("ui-slider-horizontal ui-slider-vertical").addClass("ui-slider-" + this.orientation), this._refreshValue(); break; case "value": this._animateOff = !0, this._refreshValue(), this._change(null, 0), this._animateOff = !1; break; case "values": this._animateOff = !0, this._refreshValue(); for (d = 0; d < e; d += 1) this._change(null, d); this._animateOff = !1 } }, _value: function () { var a = this.options.value; a = this._trimAlignValue(a); return a }, _values: function (a) { var b, c, d; if (arguments.length) { b = this.options.values[a], b = this._trimAlignValue(b); return b } c = this.options.values.slice(); for (d = 0; d < c.length; d += 1) c[d] = this._trimAlignValue(c[d]); return c }, _trimAlignValue: function (a) { if (a <= this._valueMin()) return this._valueMin(); if (a >= this._valueMax()) return this._valueMax(); var b = this.options.step > 0 ? this.options.step : 1, c = (a - this._valueMin()) % b, d = a - c; Math.abs(c) * 2 >= b && (d += c > 0 ? b : -b); return parseFloat(d.toFixed(5)) }, _valueMin: function () { return this.options.min }, _valueMax: function () { return this.options.max }, _refreshValue: function () { var b = this.options.range, c = this.options, d = this, e = this._animateOff ? !1 : c.animate, f, g = {}, h, i, j, k; this.options.values && this.options.values.length ? this.handles.each(function (b, i) { f = (d.values(b) - d._valueMin()) / (d._valueMax() - d._valueMin()) * 100, g[d.orientation === "horizontal" ? "left" : "bottom"] = f + "%", a(this).stop(1, 1)[e ? "animate" : "css"](g, c.animate), d.options.range === !0 && (d.orientation === "horizontal" ? (b === 0 && d.range.stop(1, 1)[e ? "animate" : "css"]({ left: f + "%" }, c.animate), b === 1 && d.range[e ? "animate" : "css"]({ width: f - h + "%" }, { queue: !1, duration: c.animate })) : (b === 0 && d.range.stop(1, 1)[e ? "animate" : "css"]({ bottom: f + "%" }, c.animate), b === 1 && d.range[e ? "animate" : "css"]({ height: f - h + "%" }, { queue: !1, duration: c.animate }))), h = f }) : (i = this.value(), j = this._valueMin(), k = this._valueMax(), f = k !== j ? (i - j) / (k - j) * 100 : 0, g[d.orientation === "horizontal" ? "left" : "bottom"] = f + "%", this.handle.stop(1, 1)[e ? "animate" : "css"](g, c.animate), b === "min" && this.orientation === "horizontal" && this.range.stop(1, 1)[e ? "animate" : "css"]({ width: f + "%" }, c.animate), b === "max" && this.orientation === "horizontal" && this.range[e ? "animate" : "css"]({ width: 100 - f + "%" }, { queue: !1, duration: c.animate }), b === "min" && this.orientation === "vertical" && this.range.stop(1, 1)[e ? "animate" : "css"]({ height: f + "%" }, c.animate), b === "max" && this.orientation === "vertical" && this.range[e ? "animate" : "css"]({ height: 100 - f + "%" }, { queue: !1, duration: c.animate })) } }), a.extend(a.ui.slider, { version: "1.8.18" }) })(jQuery); /*
* jQuery UI Tabs 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Tabs
*
* Depends:
*	jquery.ui.core.js
*	jquery.ui.widget.js
*/
(function (a, b) { function f() { return ++d } function e() { return ++c } var c = 0, d = 0; a.widget("ui.tabs", { options: { add: null, ajaxOptions: null, cache: !1, cookie: null, collapsible: !1, disable: null, disabled: [], enable: null, event: "click", fx: null, idPrefix: "ui-tabs-", load: null, panelTemplate: "<div></div>", remove: null, select: null, show: null, spinner: "<em>Loading&#8230;</em>", tabTemplate: "<li><a href='#{href}'><span>#{label}</span></a></li>" }, _create: function () { this._tabify(!0) }, _setOption: function (a, b) { if (a == "selected") { if (this.options.collapsible && b == this.options.selected) return; this.select(b) } else this.options[a] = b, this._tabify() }, _tabId: function (a) { return a.title && a.title.replace(/\s/g, "_").replace(/[^\w\u00c0-\uFFFF-]/g, "") || this.options.idPrefix + e() }, _sanitizeSelector: function (a) { return a.replace(/:/g, "\\:") }, _cookie: function () { var b = this.cookie || (this.cookie = this.options.cookie.name || "ui-tabs-" + f()); return a.cookie.apply(null, [b].concat(a.makeArray(arguments))) }, _ui: function (a, b) { return { tab: a, panel: b, index: this.anchors.index(a)} }, _cleanup: function () { this.lis.filter(".ui-state-processing").removeClass("ui-state-processing").find("span:data(label.tabs)").each(function () { var b = a(this); b.html(b.data("label.tabs")).removeData("label.tabs") }) }, _tabify: function (c) { function m(b, c) { b.css("display", ""), !a.support.opacity && c.opacity && b[0].style.removeAttribute("filter") } var d = this, e = this.options, f = /^#.+/; this.list = this.element.find("ol,ul").eq(0), this.lis = a(" > li:has(a[href])", this.list), this.anchors = this.lis.map(function () { return a("a", this)[0] }), this.panels = a([]), this.anchors.each(function (b, c) { var g = a(c).attr("href"), h = g.split("#")[0], i; h && (h === location.toString().split("#")[0] || (i = a("base")[0]) && h === i.href) && (g = c.hash, c.href = g); if (f.test(g)) d.panels = d.panels.add(d.element.find(d._sanitizeSelector(g))); else if (g && g !== "#") { a.data(c, "href.tabs", g), a.data(c, "load.tabs", g.replace(/#.*$/, "")); var j = d._tabId(c); c.href = "#" + j; var k = d.element.find("#" + j); k.length || (k = a(e.panelTemplate).attr("id", j).addClass("ui-tabs-panel ui-widget-content ui-corner-bottom").insertAfter(d.panels[b - 1] || d.list), k.data("destroy.tabs", !0)), d.panels = d.panels.add(k) } else e.disabled.push(b) }), c ? (this.element.addClass("ui-tabs ui-widget ui-widget-content ui-corner-all"), this.list.addClass("ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all"), this.lis.addClass("ui-state-default ui-corner-top"), this.panels.addClass("ui-tabs-panel ui-widget-content ui-corner-bottom"), e.selected === b ? (location.hash && this.anchors.each(function (a, b) { if (b.hash == location.hash) { e.selected = a; return !1 } }), typeof e.selected != "number" && e.cookie && (e.selected = parseInt(d._cookie(), 10)), typeof e.selected != "number" && this.lis.filter(".ui-tabs-selected").length && (e.selected = this.lis.index(this.lis.filter(".ui-tabs-selected"))), e.selected = e.selected || (this.lis.length ? 0 : -1)) : e.selected === null && (e.selected = -1), e.selected = e.selected >= 0 && this.anchors[e.selected] || e.selected < 0 ? e.selected : 0, e.disabled = a.unique(e.disabled.concat(a.map(this.lis.filter(".ui-state-disabled"), function (a, b) { return d.lis.index(a) }))).sort(), a.inArray(e.selected, e.disabled) != -1 && e.disabled.splice(a.inArray(e.selected, e.disabled), 1), this.panels.addClass("ui-tabs-hide"), this.lis.removeClass("ui-tabs-selected ui-state-active"), e.selected >= 0 && this.anchors.length && (d.element.find(d._sanitizeSelector(d.anchors[e.selected].hash)).removeClass("ui-tabs-hide"), this.lis.eq(e.selected).addClass("ui-tabs-selected ui-state-active"), d.element.queue("tabs", function () { d._trigger("show", null, d._ui(d.anchors[e.selected], d.element.find(d._sanitizeSelector(d.anchors[e.selected].hash))[0])) }), this.load(e.selected)), a(window).bind("unload", function () { d.lis.add(d.anchors).unbind(".tabs"), d.lis = d.anchors = d.panels = null })) : e.selected = this.lis.index(this.lis.filter(".ui-tabs-selected")), this.element[e.collapsible ? "addClass" : "removeClass"]("ui-tabs-collapsible"), e.cookie && this._cookie(e.selected, e.cookie); for (var g = 0, h; h = this.lis[g]; g++) a(h)[a.inArray(g, e.disabled) != -1 && !a(h).hasClass("ui-tabs-selected") ? "addClass" : "removeClass"]("ui-state-disabled"); e.cache === !1 && this.anchors.removeData("cache.tabs"), this.lis.add(this.anchors).unbind(".tabs"); if (e.event !== "mouseover") { var i = function (a, b) { b.is(":not(.ui-state-disabled)") && b.addClass("ui-state-" + a) }, j = function (a, b) { b.removeClass("ui-state-" + a) }; this.lis.bind("mouseover.tabs", function () { i("hover", a(this)) }), this.lis.bind("mouseout.tabs", function () { j("hover", a(this)) }), this.anchors.bind("focus.tabs", function () { i("focus", a(this).closest("li")) }), this.anchors.bind("blur.tabs", function () { j("focus", a(this).closest("li")) }) } var k, l; e.fx && (a.isArray(e.fx) ? (k = e.fx[0], l = e.fx[1]) : k = l = e.fx); var n = l ? function (b, c) { a(b).closest("li").addClass("ui-tabs-selected ui-state-active"), c.hide().removeClass("ui-tabs-hide").animate(l, l.duration || "normal", function () { m(c, l), d._trigger("show", null, d._ui(b, c[0])) }) } : function (b, c) { a(b).closest("li").addClass("ui-tabs-selected ui-state-active"), c.removeClass("ui-tabs-hide"), d._trigger("show", null, d._ui(b, c[0])) }, o = k ? function (a, b) { b.animate(k, k.duration || "normal", function () { d.lis.removeClass("ui-tabs-selected ui-state-active"), b.addClass("ui-tabs-hide"), m(b, k), d.element.dequeue("tabs") }) } : function (a, b, c) { d.lis.removeClass("ui-tabs-selected ui-state-active"), b.addClass("ui-tabs-hide"), d.element.dequeue("tabs") }; this.anchors.bind(e.event + ".tabs", function () { var b = this, c = a(b).closest("li"), f = d.panels.filter(":not(.ui-tabs-hide)"), g = d.element.find(d._sanitizeSelector(b.hash)); if (c.hasClass("ui-tabs-selected") && !e.collapsible || c.hasClass("ui-state-disabled") || c.hasClass("ui-state-processing") || d.panels.filter(":animated").length || d._trigger("select", null, d._ui(this, g[0])) === !1) { this.blur(); return !1 } e.selected = d.anchors.index(this), d.abort(); if (e.collapsible) { if (c.hasClass("ui-tabs-selected")) { e.selected = -1, e.cookie && d._cookie(e.selected, e.cookie), d.element.queue("tabs", function () { o(b, f) }).dequeue("tabs"), this.blur(); return !1 } if (!f.length) { e.cookie && d._cookie(e.selected, e.cookie), d.element.queue("tabs", function () { n(b, g) }), d.load(d.anchors.index(this)), this.blur(); return !1 } } e.cookie && d._cookie(e.selected, e.cookie); if (g.length) f.length && d.element.queue("tabs", function () { o(b, f) }), d.element.queue("tabs", function () { n(b, g) }), d.load(d.anchors.index(this)); else throw "jQuery UI Tabs: Mismatching fragment identifier."; a.browser.msie && this.blur() }), this.anchors.bind("click.tabs", function () { return !1 }) }, _getIndex: function (a) { typeof a == "string" && (a = this.anchors.index(this.anchors.filter("[href$=" + a + "]"))); return a }, destroy: function () { var b = this.options; this.abort(), this.element.unbind(".tabs").removeClass("ui-tabs ui-widget ui-widget-content ui-corner-all ui-tabs-collapsible").removeData("tabs"), this.list.removeClass("ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all"), this.anchors.each(function () { var b = a.data(this, "href.tabs"); b && (this.href = b); var c = a(this).unbind(".tabs"); a.each(["href", "load", "cache"], function (a, b) { c.removeData(b + ".tabs") }) }), this.lis.unbind(".tabs").add(this.panels).each(function () { a.data(this, "destroy.tabs") ? a(this).remove() : a(this).removeClass(["ui-state-default", "ui-corner-top", "ui-tabs-selected", "ui-state-active", "ui-state-hover", "ui-state-focus", "ui-state-disabled", "ui-tabs-panel", "ui-widget-content", "ui-corner-bottom", "ui-tabs-hide"].join(" ")) }), b.cookie && this._cookie(null, b.cookie); return this }, add: function (c, d, e) { e === b && (e = this.anchors.length); var f = this, g = this.options, h = a(g.tabTemplate.replace(/#\{href\}/g, c).replace(/#\{label\}/g, d)), i = c.indexOf("#") ? this._tabId(a("a", h)[0]) : c.replace("#", ""); h.addClass("ui-state-default ui-corner-top").data("destroy.tabs", !0); var j = f.element.find("#" + i); j.length || (j = a(g.panelTemplate).attr("id", i).data("destroy.tabs", !0)), j.addClass("ui-tabs-panel ui-widget-content ui-corner-bottom ui-tabs-hide"), e >= this.lis.length ? (h.appendTo(this.list), j.appendTo(this.list[0].parentNode)) : (h.insertBefore(this.lis[e]), j.insertBefore(this.panels[e])), g.disabled = a.map(g.disabled, function (a, b) { return a >= e ? ++a : a }), this._tabify(), this.anchors.length == 1 && (g.selected = 0, h.addClass("ui-tabs-selected ui-state-active"), j.removeClass("ui-tabs-hide"), this.element.queue("tabs", function () { f._trigger("show", null, f._ui(f.anchors[0], f.panels[0])) }), this.load(0)), this._trigger("add", null, this._ui(this.anchors[e], this.panels[e])); return this }, remove: function (b) { b = this._getIndex(b); var c = this.options, d = this.lis.eq(b).remove(), e = this.panels.eq(b).remove(); d.hasClass("ui-tabs-selected") && this.anchors.length > 1 && this.select(b + (b + 1 < this.anchors.length ? 1 : -1)), c.disabled = a.map(a.grep(c.disabled, function (a, c) { return a != b }), function (a, c) { return a >= b ? --a : a }), this._tabify(), this._trigger("remove", null, this._ui(d.find("a")[0], e[0])); return this }, enable: function (b) { b = this._getIndex(b); var c = this.options; if (a.inArray(b, c.disabled) != -1) { this.lis.eq(b).removeClass("ui-state-disabled"), c.disabled = a.grep(c.disabled, function (a, c) { return a != b }), this._trigger("enable", null, this._ui(this.anchors[b], this.panels[b])); return this } }, disable: function (a) { a = this._getIndex(a); var b = this, c = this.options; a != c.selected && (this.lis.eq(a).addClass("ui-state-disabled"), c.disabled.push(a), c.disabled.sort(), this._trigger("disable", null, this._ui(this.anchors[a], this.panels[a]))); return this }, select: function (a) { a = this._getIndex(a); if (a == -1) if (this.options.collapsible && this.options.selected != -1) a = this.options.selected; else return this; this.anchors.eq(a).trigger(this.options.event + ".tabs"); return this }, load: function (b) { b = this._getIndex(b); var c = this, d = this.options, e = this.anchors.eq(b)[0], f = a.data(e, "load.tabs"); this.abort(); if (!f || this.element.queue("tabs").length !== 0 && a.data(e, "cache.tabs")) this.element.dequeue("tabs"); else { this.lis.eq(b).addClass("ui-state-processing"); if (d.spinner) { var g = a("span", e); g.data("label.tabs", g.html()).html(d.spinner) } this.xhr = a.ajax(a.extend({}, d.ajaxOptions, { url: f, success: function (f, g) { c.element.find(c._sanitizeSelector(e.hash)).html(f), c._cleanup(), d.cache && a.data(e, "cache.tabs", !0), c._trigger("load", null, c._ui(c.anchors[b], c.panels[b])); try { d.ajaxOptions.success(f, g) } catch (h) { } }, error: function (a, f, g) { c._cleanup(), c._trigger("load", null, c._ui(c.anchors[b], c.panels[b])); try { d.ajaxOptions.error(a, f, b, e) } catch (g) { } } })), c.element.dequeue("tabs"); return this } }, abort: function () { this.element.queue([]), this.panels.stop(!1, !0), this.element.queue("tabs", this.element.queue("tabs").splice(-2, 2)), this.xhr && (this.xhr.abort(), delete this.xhr), this._cleanup(); return this }, url: function (a, b) { this.anchors.eq(a).removeData("cache.tabs").data("load.tabs", b); return this }, length: function () { return this.anchors.length } }), a.extend(a.ui.tabs, { version: "1.8.18" }), a.extend(a.ui.tabs.prototype, { rotation: null, rotate: function (a, b) { var c = this, d = this.options, e = c._rotate || (c._rotate = function (b) { clearTimeout(c.rotation), c.rotation = setTimeout(function () { var a = d.selected; c.select(++a < c.anchors.length ? a : 0) }, a), b && b.stopPropagation() }), f = c._unrotate || (c._unrotate = b ? function (a) { t = d.selected, e() } : function (a) { a.clientX && c.rotate(null) }); a ? (this.element.bind("tabsshow", e), this.anchors.bind(d.event + ".tabs", f), e()) : (clearTimeout(c.rotation), this.element.unbind("tabsshow", e), this.anchors.unbind(d.event + ".tabs", f), delete this._rotate, delete this._unrotate); return this } }) })(jQuery); /*
* jQuery UI Datepicker 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Datepicker
*
* Depends:
*	jquery.ui.core.js
*/
(function ($, undefined) {
    function isArray(a) { return a && ($.browser.safari && typeof a == "object" && a.length || a.constructor && a.constructor.toString().match(/\Array\(\)/)) } function extendRemove(a, b) { $.extend(a, b); for (var c in b) if (b[c] == null || b[c] == undefined) a[c] = b[c]; return a } function bindHover(a) { var b = "button, .ui-datepicker-prev, .ui-datepicker-next, .ui-datepicker-calendar td a"; return a.bind("mouseout", function (a) { var c = $(a.target).closest(b); !c.length || c.removeClass("ui-state-hover ui-datepicker-prev-hover ui-datepicker-next-hover") }).bind("mouseover", function (c) { var d = $(c.target).closest(b); !$.datepicker._isDisabledDatepicker(instActive.inline ? a.parent()[0] : instActive.input[0]) && !!d.length && (d.parents(".ui-datepicker-calendar").find("a").removeClass("ui-state-hover"), d.addClass("ui-state-hover"), d.hasClass("ui-datepicker-prev") && d.addClass("ui-datepicker-prev-hover"), d.hasClass("ui-datepicker-next") && d.addClass("ui-datepicker-next-hover")) }) } function Datepicker() { this.debug = !1, this._curInst = null, this._keyEvent = !1, this._disabledInputs = [], this._datepickerShowing = !1, this._inDialog = !1, this._mainDivId = "ui-datepicker-div", this._inlineClass = "ui-datepicker-inline", this._appendClass = "ui-datepicker-append", this._triggerClass = "ui-datepicker-trigger", this._dialogClass = "ui-datepicker-dialog", this._disableClass = "ui-datepicker-disabled", this._unselectableClass = "ui-datepicker-unselectable", this._currentClass = "ui-datepicker-current-day", this._dayOverClass = "ui-datepicker-days-cell-over", this.regional = [], this.regional[""] = { closeText: "Done", prevText: "Prev", nextText: "Next", currentText: "Today", monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], monthNamesShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], dayNames: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], dayNamesMin: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], weekHeader: "Wk", dateFormat: "mm/dd/yy", firstDay: 0, isRTL: !1, showMonthAfterYear: !1, yearSuffix: "" }, this._defaults = { showOn: "focus", showAnim: "fadeIn", showOptions: {}, defaultDate: null, appendText: "", buttonText: "...", buttonImage: "", buttonImageOnly: !1, hideIfNoPrevNext: !1, navigationAsDateFormat: !1, gotoCurrent: !1, changeMonth: !1, changeYear: !1, yearRange: "c-10:c+10", showOtherMonths: !1, selectOtherMonths: !1, showWeek: !1, calculateWeek: this.iso8601Week, shortYearCutoff: "+10", minDate: null, maxDate: null, duration: "fast", beforeShowDay: null, beforeShow: null, onSelect: null, onChangeMonthYear: null, onClose: null, numberOfMonths: 1, showCurrentAtPos: 0, stepMonths: 1, stepBigMonths: 12, altField: "", altFormat: "", constrainInput: !0, showButtonPanel: !1, autoSize: !1, disabled: !1 }, $.extend(this._defaults, this.regional[""]), this.dpDiv = bindHover($('<div id="' + this._mainDivId + '" class="ui-datepicker ui-widget ui-widget-content ui-helper-clearfix ui-corner-all"></div>')) } $.extend($.ui, { datepicker: { version: "1.8.18"} }); var PROP_NAME = "datepicker", dpuuid = (new Date).getTime(), instActive; $.extend(Datepicker.prototype, { markerClassName: "hasDatepicker", maxRows: 4, log: function () { this.debug && console.log.apply("", arguments) }, _widgetDatepicker: function () { return this.dpDiv }, setDefaults: function (a) { extendRemove(this._defaults, a || {}); return this }, _attachDatepicker: function (target, settings) { var inlineSettings = null; for (var attrName in this._defaults) { var attrValue = target.getAttribute("date:" + attrName); if (attrValue) { inlineSettings = inlineSettings || {}; try { inlineSettings[attrName] = eval(attrValue) } catch (err) { inlineSettings[attrName] = attrValue } } } var nodeName = target.nodeName.toLowerCase(), inline = nodeName == "div" || nodeName == "span"; target.id || (this.uuid += 1, target.id = "dp" + this.uuid); var inst = this._newInst($(target), inline); inst.settings = $.extend({}, settings || {}, inlineSettings || {}), nodeName == "input" ? this._connectDatepicker(target, inst) : inline && this._inlineDatepicker(target, inst) }, _newInst: function (a, b) { var c = a[0].id.replace(/([^A-Za-z0-9_-])/g, "\\\\$1"); return { id: c, input: a, selectedDay: 0, selectedMonth: 0, selectedYear: 0, drawMonth: 0, drawYear: 0, inline: b, dpDiv: b ? bindHover($('<div class="' + this._inlineClass + ' ui-datepicker ui-widget ui-widget-content ui-helper-clearfix ui-corner-all"></div>')) : this.dpDiv} }, _connectDatepicker: function (a, b) { var c = $(a); b.append = $([]), b.trigger = $([]); c.hasClass(this.markerClassName) || (this._attachments(c, b), c.addClass(this.markerClassName).keydown(this._doKeyDown).keypress(this._doKeyPress).keyup(this._doKeyUp).bind("setData.datepicker", function (a, c, d) { b.settings[c] = d }).bind("getData.datepicker", function (a, c) { return this._get(b, c) }), this._autoSize(b), $.data(a, PROP_NAME, b), b.settings.disabled && this._disableDatepicker(a)) }, _attachments: function (a, b) { var c = this._get(b, "appendText"), d = this._get(b, "isRTL"); b.append && b.append.remove(), c && (b.append = $('<span class="' + this._appendClass + '">' + c + "</span>"), a[d ? "before" : "after"](b.append)), a.unbind("focus", this._showDatepicker), b.trigger && b.trigger.remove(); var e = this._get(b, "showOn"); (e == "focus" || e == "both") && a.focus(this._showDatepicker); if (e == "button" || e == "both") { var f = this._get(b, "buttonText"), g = this._get(b, "buttonImage"); b.trigger = $(this._get(b, "buttonImageOnly") ? $("<img/>").addClass(this._triggerClass).attr({ src: g, alt: f, title: f }) : $('<button type="button"></button>').addClass(this._triggerClass).html(g == "" ? f : $("<img/>").attr({ src: g, alt: f, title: f }))), a[d ? "before" : "after"](b.trigger), b.trigger.click(function () { $.datepicker._datepickerShowing && $.datepicker._lastInput == a[0] ? $.datepicker._hideDatepicker() : $.datepicker._datepickerShowing && $.datepicker._lastInput != a[0] ? ($.datepicker._hideDatepicker(), $.datepicker._showDatepicker(a[0])) : $.datepicker._showDatepicker(a[0]); return !1 }) } }, _autoSize: function (a) { if (this._get(a, "autoSize") && !a.inline) { var b = new Date(2009, 11, 20), c = this._get(a, "dateFormat"); if (c.match(/[DM]/)) { var d = function (a) { var b = 0, c = 0; for (var d = 0; d < a.length; d++) a[d].length > b && (b = a[d].length, c = d); return c }; b.setMonth(d(this._get(a, c.match(/MM/) ? "monthNames" : "monthNamesShort"))), b.setDate(d(this._get(a, c.match(/DD/) ? "dayNames" : "dayNamesShort")) + 20 - b.getDay()) } a.input.attr("size", this._formatDate(a, b).length) } }, _inlineDatepicker: function (a, b) { var c = $(a); c.hasClass(this.markerClassName) || (c.addClass(this.markerClassName).append(b.dpDiv).bind("setData.datepicker", function (a, c, d) { b.settings[c] = d }).bind("getData.datepicker", function (a, c) { return this._get(b, c) }), $.data(a, PROP_NAME, b), this._setDate(b, this._getDefaultDate(b), !0), this._updateDatepicker(b), this._updateAlternate(b), b.settings.disabled && this._disableDatepicker(a), b.dpDiv.css("display", "block")) }, _dialogDatepicker: function (a, b, c, d, e) { var f = this._dialogInst; if (!f) { this.uuid += 1; var g = "dp" + this.uuid; this._dialogInput = $('<input type="text" id="' + g + '" style="position: absolute; top: -100px; width: 0px; z-index: -10;"/>'), this._dialogInput.keydown(this._doKeyDown), $("body").append(this._dialogInput), f = this._dialogInst = this._newInst(this._dialogInput, !1), f.settings = {}, $.data(this._dialogInput[0], PROP_NAME, f) } extendRemove(f.settings, d || {}), b = b && b.constructor == Date ? this._formatDate(f, b) : b, this._dialogInput.val(b), this._pos = e ? e.length ? e : [e.pageX, e.pageY] : null; if (!this._pos) { var h = document.documentElement.clientWidth, i = document.documentElement.clientHeight, j = document.documentElement.scrollLeft || document.body.scrollLeft, k = document.documentElement.scrollTop || document.body.scrollTop; this._pos = [h / 2 - 100 + j, i / 2 - 150 + k] } this._dialogInput.css("left", this._pos[0] + 20 + "px").css("top", this._pos[1] + "px"), f.settings.onSelect = c, this._inDialog = !0, this.dpDiv.addClass(this._dialogClass), this._showDatepicker(this._dialogInput[0]), $.blockUI && $.blockUI(this.dpDiv), $.data(this._dialogInput[0], PROP_NAME, f); return this }, _destroyDatepicker: function (a) { var b = $(a), c = $.data(a, PROP_NAME); if (!!b.hasClass(this.markerClassName)) { var d = a.nodeName.toLowerCase(); $.removeData(a, PROP_NAME), d == "input" ? (c.append.remove(), c.trigger.remove(), b.removeClass(this.markerClassName).unbind("focus", this._showDatepicker).unbind("keydown", this._doKeyDown).unbind("keypress", this._doKeyPress).unbind("keyup", this._doKeyUp)) : (d == "div" || d == "span") && b.removeClass(this.markerClassName).empty() } }, _enableDatepicker: function (a) { var b = $(a), c = $.data(a, PROP_NAME); if (!!b.hasClass(this.markerClassName)) { var d = a.nodeName.toLowerCase(); if (d == "input") a.disabled = !1, c.trigger.filter("button").each(function () { this.disabled = !1 }).end().filter("img").css({ opacity: "1.0", cursor: "" }); else if (d == "div" || d == "span") { var e = b.children("." + this._inlineClass); e.children().removeClass("ui-state-disabled"), e.find("select.ui-datepicker-month, select.ui-datepicker-year").removeAttr("disabled") } this._disabledInputs = $.map(this._disabledInputs, function (b) { return b == a ? null : b }) } }, _disableDatepicker: function (a) { var b = $(a), c = $.data(a, PROP_NAME); if (!!b.hasClass(this.markerClassName)) { var d = a.nodeName.toLowerCase(); if (d == "input") a.disabled = !0, c.trigger.filter("button").each(function () { this.disabled = !0 }).end().filter("img").css({ opacity: "0.5", cursor: "default" }); else if (d == "div" || d == "span") { var e = b.children("." + this._inlineClass); e.children().addClass("ui-state-disabled"), e.find("select.ui-datepicker-month, select.ui-datepicker-year").attr("disabled", "disabled") } this._disabledInputs = $.map(this._disabledInputs, function (b) { return b == a ? null : b }), this._disabledInputs[this._disabledInputs.length] = a } }, _isDisabledDatepicker: function (a) { if (!a) return !1; for (var b = 0; b < this._disabledInputs.length; b++) if (this._disabledInputs[b] == a) return !0; return !1 }, _getInst: function (a) { try { return $.data(a, PROP_NAME) } catch (b) { throw "Missing instance data for this datepicker" } }, _optionDatepicker: function (a, b, c) { var d = this._getInst(a); if (arguments.length == 2 && typeof b == "string") return b == "defaults" ? $.extend({}, $.datepicker._defaults) : d ? b == "all" ? $.extend({}, d.settings) : this._get(d, b) : null; var e = b || {}; typeof b == "string" && (e = {}, e[b] = c); if (d) { this._curInst == d && this._hideDatepicker(); var f = this._getDateDatepicker(a, !0), g = this._getMinMaxDate(d, "min"), h = this._getMinMaxDate(d, "max"); extendRemove(d.settings, e), g !== null && e.dateFormat !== undefined && e.minDate === undefined && (d.settings.minDate = this._formatDate(d, g)), h !== null && e.dateFormat !== undefined && e.maxDate === undefined && (d.settings.maxDate = this._formatDate(d, h)), this._attachments($(a), d), this._autoSize(d), this._setDate(d, f), this._updateAlternate(d), this._updateDatepicker(d) } }, _changeDatepicker: function (a, b, c) { this._optionDatepicker(a, b, c) }, _refreshDatepicker: function (a) { var b = this._getInst(a); b && this._updateDatepicker(b) }, _setDateDatepicker: function (a, b) { var c = this._getInst(a); c && (this._setDate(c, b), this._updateDatepicker(c), this._updateAlternate(c)) }, _getDateDatepicker: function (a, b) { var c = this._getInst(a); c && !c.inline && this._setDateFromField(c, b); return c ? this._getDate(c) : null }, _doKeyDown: function (a) { var b = $.datepicker._getInst(a.target), c = !0, d = b.dpDiv.is(".ui-datepicker-rtl"); b._keyEvent = !0; if ($.datepicker._datepickerShowing) switch (a.keyCode) { case 9: $.datepicker._hideDatepicker(), c = !1; break; case 13: var e = $("td." + $.datepicker._dayOverClass + ":not(." + $.datepicker._currentClass + ")", b.dpDiv); e[0] && $.datepicker._selectDay(a.target, b.selectedMonth, b.selectedYear, e[0]); var f = $.datepicker._get(b, "onSelect"); if (f) { var g = $.datepicker._formatDate(b); f.apply(b.input ? b.input[0] : null, [g, b]) } else $.datepicker._hideDatepicker(); return !1; case 27: $.datepicker._hideDatepicker(); break; case 33: $.datepicker._adjustDate(a.target, a.ctrlKey ? -$.datepicker._get(b, "stepBigMonths") : -$.datepicker._get(b, "stepMonths"), "M"); break; case 34: $.datepicker._adjustDate(a.target, a.ctrlKey ? +$.datepicker._get(b, "stepBigMonths") : +$.datepicker._get(b, "stepMonths"), "M"); break; case 35: (a.ctrlKey || a.metaKey) && $.datepicker._clearDate(a.target), c = a.ctrlKey || a.metaKey; break; case 36: (a.ctrlKey || a.metaKey) && $.datepicker._gotoToday(a.target), c = a.ctrlKey || a.metaKey; break; case 37: (a.ctrlKey || a.metaKey) && $.datepicker._adjustDate(a.target, d ? 1 : -1, "D"), c = a.ctrlKey || a.metaKey, a.originalEvent.altKey && $.datepicker._adjustDate(a.target, a.ctrlKey ? -$.datepicker._get(b, "stepBigMonths") : -$.datepicker._get(b, "stepMonths"), "M"); break; case 38: (a.ctrlKey || a.metaKey) && $.datepicker._adjustDate(a.target, -7, "D"), c = a.ctrlKey || a.metaKey; break; case 39: (a.ctrlKey || a.metaKey) && $.datepicker._adjustDate(a.target, d ? -1 : 1, "D"), c = a.ctrlKey || a.metaKey, a.originalEvent.altKey && $.datepicker._adjustDate(a.target, a.ctrlKey ? +$.datepicker._get(b, "stepBigMonths") : +$.datepicker._get(b, "stepMonths"), "M"); break; case 40: (a.ctrlKey || a.metaKey) && $.datepicker._adjustDate(a.target, 7, "D"), c = a.ctrlKey || a.metaKey; break; default: c = !1 } else a.keyCode == 36 && a.ctrlKey ? $.datepicker._showDatepicker(this) : c = !1; c && (a.preventDefault(), a.stopPropagation()) }, _doKeyPress: function (a) { var b = $.datepicker._getInst(a.target); if ($.datepicker._get(b, "constrainInput")) { var c = $.datepicker._possibleChars($.datepicker._get(b, "dateFormat")), d = String.fromCharCode(a.charCode == undefined ? a.keyCode : a.charCode); return a.ctrlKey || a.metaKey || d < " " || !c || c.indexOf(d) > -1 } }, _doKeyUp: function (a) { var b = $.datepicker._getInst(a.target); if (b.input.val() != b.lastVal) try { var c = $.datepicker.parseDate($.datepicker._get(b, "dateFormat"), b.input ? b.input.val() : null, $.datepicker._getFormatConfig(b)); c && ($.datepicker._setDateFromField(b), $.datepicker._updateAlternate(b), $.datepicker._updateDatepicker(b)) } catch (a) { $.datepicker.log(a) } return !0 }, _showDatepicker: function (a) { a = a.target || a, a.nodeName.toLowerCase() != "input" && (a = $("input", a.parentNode)[0]); if (!$.datepicker._isDisabledDatepicker(a) && $.datepicker._lastInput != a) { var b = $.datepicker._getInst(a); $.datepicker._curInst && $.datepicker._curInst != b && ($.datepicker._curInst.dpDiv.stop(!0, !0), b && $.datepicker._datepickerShowing && $.datepicker._hideDatepicker($.datepicker._curInst.input[0])); var c = $.datepicker._get(b, "beforeShow"), d = c ? c.apply(a, [a, b]) : {}; if (d === !1) return; extendRemove(b.settings, d), b.lastVal = null, $.datepicker._lastInput = a, $.datepicker._setDateFromField(b), $.datepicker._inDialog && (a.value = ""), $.datepicker._pos || ($.datepicker._pos = $.datepicker._findPos(a), $.datepicker._pos[1] += a.offsetHeight); var e = !1; $(a).parents().each(function () { e |= $(this).css("position") == "fixed"; return !e }), e && $.browser.opera && ($.datepicker._pos[0] -= document.documentElement.scrollLeft, $.datepicker._pos[1] -= document.documentElement.scrollTop); var f = { left: $.datepicker._pos[0], top: $.datepicker._pos[1] }; $.datepicker._pos = null, b.dpDiv.empty(), b.dpDiv.css({ position: "absolute", display: "block", top: "-1000px" }), $.datepicker._updateDatepicker(b), f = $.datepicker._checkOffset(b, f, e), b.dpDiv.css({ position: $.datepicker._inDialog && $.blockUI ? "static" : e ? "fixed" : "absolute", display: "none", left: f.left + "px", top: f.top + "px" }); if (!b.inline) { var g = $.datepicker._get(b, "showAnim"), h = $.datepicker._get(b, "duration"), i = function () { var a = b.dpDiv.find("iframe.ui-datepicker-cover"); if (!!a.length) { var c = $.datepicker._getBorders(b.dpDiv); a.css({ left: -c[0], top: -c[1], width: b.dpDiv.outerWidth(), height: b.dpDiv.outerHeight() }) } }; b.dpDiv.zIndex($(a).zIndex() + 1), $.datepicker._datepickerShowing = !0, $.effects && $.effects[g] ? b.dpDiv.show(g, $.datepicker._get(b, "showOptions"), h, i) : b.dpDiv[g || "show"](g ? h : null, i), (!g || !h) && i(), b.input.is(":visible") && !b.input.is(":disabled") && b.input.focus(), $.datepicker._curInst = b } } }, _updateDatepicker: function (a) { var b = this; b.maxRows = 4; var c = $.datepicker._getBorders(a.dpDiv); instActive = a, a.dpDiv.empty().append(this._generateHTML(a)); var d = a.dpDiv.find("iframe.ui-datepicker-cover"); !d.length || d.css({ left: -c[0], top: -c[1], width: a.dpDiv.outerWidth(), height: a.dpDiv.outerHeight() }), a.dpDiv.find("." + this._dayOverClass + " a").mouseover(); var e = this._getNumberOfMonths(a), f = e[1], g = 17; a.dpDiv.removeClass("ui-datepicker-multi-2 ui-datepicker-multi-3 ui-datepicker-multi-4").width(""), f > 1 && a.dpDiv.addClass("ui-datepicker-multi-" + f).css("width", g * f + "em"), a.dpDiv[(e[0] != 1 || e[1] != 1 ? "add" : "remove") + "Class"]("ui-datepicker-multi"), a.dpDiv[(this._get(a, "isRTL") ? "add" : "remove") + "Class"]("ui-datepicker-rtl"), a == $.datepicker._curInst && $.datepicker._datepickerShowing && a.input && a.input.is(":visible") && !a.input.is(":disabled") && a.input[0] != document.activeElement && a.input.focus(); if (a.yearshtml) { var h = a.yearshtml; setTimeout(function () { h === a.yearshtml && a.yearshtml && a.dpDiv.find("select.ui-datepicker-year:first").replaceWith(a.yearshtml), h = a.yearshtml = null }, 0) } }, _getBorders: function (a) { var b = function (a) { return { thin: 1, medium: 2, thick: 3}[a] || a }; return [parseFloat(b(a.css("border-left-width"))), parseFloat(b(a.css("border-top-width")))] }, _checkOffset: function (a, b, c) { var d = a.dpDiv.outerWidth(), e = a.dpDiv.outerHeight(), f = a.input ? a.input.outerWidth() : 0, g = a.input ? a.input.outerHeight() : 0, h = document.documentElement.clientWidth + $(document).scrollLeft(), i = document.documentElement.clientHeight + $(document).scrollTop(); b.left -= this._get(a, "isRTL") ? d - f : 0, b.left -= c && b.left == a.input.offset().left ? $(document).scrollLeft() : 0, b.top -= c && b.top == a.input.offset().top + g ? $(document).scrollTop() : 0, b.left -= Math.min(b.left, b.left + d > h && h > d ? Math.abs(b.left + d - h) : 0), b.top -= Math.min(b.top, b.top + e > i && i > e ? Math.abs(e + g) : 0); return b }, _findPos: function (a) { var b = this._getInst(a), c = this._get(b, "isRTL"); while (a && (a.type == "hidden" || a.nodeType != 1 || $.expr.filters.hidden(a))) a = a[c ? "previousSibling" : "nextSibling"]; var d = $(a).offset(); return [d.left, d.top] }, _hideDatepicker: function (a) { var b = this._curInst; if (!(!b || a && b != $.data(a, PROP_NAME)) && this._datepickerShowing) { var c = this._get(b, "showAnim"), d = this._get(b, "duration"), e = this, f = function () { $.datepicker._tidyDialog(b), e._curInst = null }; $.effects && $.effects[c] ? b.dpDiv.hide(c, $.datepicker._get(b, "showOptions"), d, f) : b.dpDiv[c == "slideDown" ? "slideUp" : c == "fadeIn" ? "fadeOut" : "hide"](c ? d : null, f), c || f(), this._datepickerShowing = !1; var g = this._get(b, "onClose"); g && g.apply(b.input ? b.input[0] : null, [b.input ? b.input.val() : "", b]), this._lastInput = null, this._inDialog && (this._dialogInput.css({ position: "absolute", left: "0", top: "-100px" }), $.blockUI && ($.unblockUI(), $("body").append(this.dpDiv))), this._inDialog = !1 } }, _tidyDialog: function (a) { a.dpDiv.removeClass(this._dialogClass).unbind(".ui-datepicker-calendar") }, _checkExternalClick: function (a) { if (!!$.datepicker._curInst) { var b = $(a.target), c = $.datepicker._getInst(b[0]); (b[0].id != $.datepicker._mainDivId && b.parents("#" + $.datepicker._mainDivId).length == 0 && !b.hasClass($.datepicker.markerClassName) && !b.closest("." + $.datepicker._triggerClass).length && $.datepicker._datepickerShowing && (!$.datepicker._inDialog || !$.blockUI) || b.hasClass($.datepicker.markerClassName) && $.datepicker._curInst != c) && $.datepicker._hideDatepicker() } }, _adjustDate: function (a, b, c) { var d = $(a), e = this._getInst(d[0]); this._isDisabledDatepicker(d[0]) || (this._adjustInstDate(e, b + (c == "M" ? this._get(e, "showCurrentAtPos") : 0), c), this._updateDatepicker(e)) }, _gotoToday: function (a) { var b = $(a), c = this._getInst(b[0]); if (this._get(c, "gotoCurrent") && c.currentDay) c.selectedDay = c.currentDay, c.drawMonth = c.selectedMonth = c.currentMonth, c.drawYear = c.selectedYear = c.currentYear; else { var d = new Date; c.selectedDay = d.getDate(), c.drawMonth = c.selectedMonth = d.getMonth(), c.drawYear = c.selectedYear = d.getFullYear() } this._notifyChange(c), this._adjustDate(b) }, _selectMonthYear: function (a, b, c) { var d = $(a), e = this._getInst(d[0]); e["selected" + (c == "M" ? "Month" : "Year")] = e["draw" + (c == "M" ? "Month" : "Year")] = parseInt(b.options[b.selectedIndex].value, 10), this._notifyChange(e), this._adjustDate(d) }, _selectDay: function (a, b, c, d) { var e = $(a); if (!$(d).hasClass(this._unselectableClass) && !this._isDisabledDatepicker(e[0])) { var f = this._getInst(e[0]); f.selectedDay = f.currentDay = $("a", d).html(), f.selectedMonth = f.currentMonth = b, f.selectedYear = f.currentYear = c, this._selectDate(a, this._formatDate(f, f.currentDay, f.currentMonth, f.currentYear)) } }, _clearDate: function (a) { var b = $(a), c = this._getInst(b[0]); this._selectDate(b, "") }, _selectDate: function (a, b) { var c = $(a), d = this._getInst(c[0]); b = b != null ? b : this._formatDate(d), d.input && d.input.val(b), this._updateAlternate(d); var e = this._get(d, "onSelect"); e ? e.apply(d.input ? d.input[0] : null, [b, d]) : d.input && d.input.trigger("change"), d.inline ? this._updateDatepicker(d) : (this._hideDatepicker(), this._lastInput = d.input[0], typeof d.input[0] != "object" && d.input.focus(), this._lastInput = null) }, _updateAlternate: function (a) { var b = this._get(a, "altField"); if (b) { var c = this._get(a, "altFormat") || this._get(a, "dateFormat"), d = this._getDate(a), e = this.formatDate(c, d, this._getFormatConfig(a)); $(b).each(function () { $(this).val(e) }) } }, noWeekends: function (a) { var b = a.getDay(); return [b > 0 && b < 6, ""] }, iso8601Week: function (a) { var b = new Date(a.getTime()); b.setDate(b.getDate() + 4 - (b.getDay() || 7)); var c = b.getTime(); b.setMonth(0), b.setDate(1); return Math.floor(Math.round((c - b) / 864e5) / 7) + 1 }, parseDate: function (a, b, c) { if (a == null || b == null) throw "Invalid arguments"; b = typeof b == "object" ? b.toString() : b + ""; if (b == "") return null; var d = (c ? c.shortYearCutoff : null) || this._defaults.shortYearCutoff; d = typeof d != "string" ? d : (new Date).getFullYear() % 100 + parseInt(d, 10); var e = (c ? c.dayNamesShort : null) || this._defaults.dayNamesShort, f = (c ? c.dayNames : null) || this._defaults.dayNames, g = (c ? c.monthNamesShort : null) || this._defaults.monthNamesShort, h = (c ? c.monthNames : null) || this._defaults.monthNames, i = -1, j = -1, k = -1, l = -1, m = !1, n = function (b) { var c = s + 1 < a.length && a.charAt(s + 1) == b; c && s++; return c }, o = function (a) { var c = n(a), d = a == "@" ? 14 : a == "!" ? 20 : a == "y" && c ? 4 : a == "o" ? 3 : 2, e = new RegExp("^\\d{1," + d + "}"), f = b.substring(r).match(e); if (!f) throw "Missing number at position " + r; r += f[0].length; return parseInt(f[0], 10) }, p = function (a, c, d) { var e = $.map(n(a) ? d : c, function (a, b) { return [[b, a]] }).sort(function (a, b) { return -(a[1].length - b[1].length) }), f = -1; $.each(e, function (a, c) { var d = c[1]; if (b.substr(r, d.length).toLowerCase() == d.toLowerCase()) { f = c[0], r += d.length; return !1 } }); if (f != -1) return f + 1; throw "Unknown name at position " + r }, q = function () { if (b.charAt(r) != a.charAt(s)) throw "Unexpected literal at position " + r; r++ }, r = 0; for (var s = 0; s < a.length; s++) if (m) a.charAt(s) == "'" && !n("'") ? m = !1 : q(); else switch (a.charAt(s)) { case "d": k = o("d"); break; case "D": p("D", e, f); break; case "o": l = o("o"); break; case "m": j = o("m"); break; case "M": j = p("M", g, h); break; case "y": i = o("y"); break; case "@": var t = new Date(o("@")); i = t.getFullYear(), j = t.getMonth() + 1, k = t.getDate(); break; case "!": var t = new Date((o("!") - this._ticksTo1970) / 1e4); i = t.getFullYear(), j = t.getMonth() + 1, k = t.getDate(); break; case "'": n("'") ? q() : m = !0; break; default: q() } if (r < b.length) throw "Extra/unparsed characters found in date: " + b.substring(r); i == -1 ? i = (new Date).getFullYear() : i < 100 && (i += (new Date).getFullYear() - (new Date).getFullYear() % 100 + (i <= d ? 0 : -100)); if (l > -1) { j = 1, k = l; for (; ; ) { var u = this._getDaysInMonth(i, j - 1); if (k <= u) break; j++, k -= u } } var t = this._daylightSavingAdjust(new Date(i, j - 1, k)); if (t.getFullYear() != i || t.getMonth() + 1 != j || t.getDate() != k) throw "Invalid date"; return t }, ATOM: "yy-mm-dd", COOKIE: "D, dd M yy", ISO_8601: "yy-mm-dd", RFC_822: "D, d M y", RFC_850: "DD, dd-M-y", RFC_1036: "D, d M y", RFC_1123: "D, d M yy", RFC_2822: "D, d M yy", RSS: "D, d M y", TICKS: "!", TIMESTAMP: "@", W3C: "yy-mm-dd", _ticksTo1970: (718685 + Math.floor(492.5) - Math.floor(19.7) + Math.floor(4.925)) * 24 * 60 * 60 * 1e7, formatDate: function (a, b, c) { if (!b) return ""; var d = (c ? c.dayNamesShort : null) || this._defaults.dayNamesShort, e = (c ? c.dayNames : null) || this._defaults.dayNames, f = (c ? c.monthNamesShort : null) || this._defaults.monthNamesShort, g = (c ? c.monthNames : null) || this._defaults.monthNames, h = function (b) { var c = m + 1 < a.length && a.charAt(m + 1) == b; c && m++; return c }, i = function (a, b, c) { var d = "" + b; if (h(a)) while (d.length < c) d = "0" + d; return d }, j = function (a, b, c, d) { return h(a) ? d[b] : c[b] }, k = "", l = !1; if (b) for (var m = 0; m < a.length; m++) if (l) a.charAt(m) == "'" && !h("'") ? l = !1 : k += a.charAt(m); else switch (a.charAt(m)) { case "d": k += i("d", b.getDate(), 2); break; case "D": k += j("D", b.getDay(), d, e); break; case "o": k += i("o", Math.round(((new Date(b.getFullYear(), b.getMonth(), b.getDate())).getTime() - (new Date(b.getFullYear(), 0, 0)).getTime()) / 864e5), 3); break; case "m": k += i("m", b.getMonth() + 1, 2); break; case "M": k += j("M", b.getMonth(), f, g); break; case "y": k += h("y") ? b.getFullYear() : (b.getYear() % 100 < 10 ? "0" : "") + b.getYear() % 100; break; case "@": k += b.getTime(); break; case "!": k += b.getTime() * 1e4 + this._ticksTo1970; break; case "'": h("'") ? k += "'" : l = !0; break; default: k += a.charAt(m) } return k }, _possibleChars: function (a) { var b = "", c = !1, d = function (b) { var c = e + 1 < a.length && a.charAt(e + 1) == b; c && e++; return c }; for (var e = 0; e < a.length; e++) if (c) a.charAt(e) == "'" && !d("'") ? c = !1 : b += a.charAt(e); else switch (a.charAt(e)) { case "d": case "m": case "y": case "@": b += "0123456789"; break; case "D": case "M": return null; case "'": d("'") ? b += "'" : c = !0; break; default: b += a.charAt(e) } return b }, _get: function (a, b) { return a.settings[b] !== undefined ? a.settings[b] : this._defaults[b] }, _setDateFromField: function (a, b) { if (a.input.val() != a.lastVal) { var c = this._get(a, "dateFormat"), d = a.lastVal = a.input ? a.input.val() : null, e, f; e = f = this._getDefaultDate(a); var g = this._getFormatConfig(a); try { e = this.parseDate(c, d, g) || f } catch (h) { this.log(h), d = b ? "" : d } a.selectedDay = e.getDate(), a.drawMonth = a.selectedMonth = e.getMonth(), a.drawYear = a.selectedYear = e.getFullYear(), a.currentDay = d ? e.getDate() : 0, a.currentMonth = d ? e.getMonth() : 0, a.currentYear = d ? e.getFullYear() : 0, this._adjustInstDate(a) } }, _getDefaultDate: function (a) { return this._restrictMinMax(a, this._determineDate(a, this._get(a, "defaultDate"), new Date)) }, _determineDate: function (a, b, c) { var d = function (a) { var b = new Date; b.setDate(b.getDate() + a); return b }, e = function (b) { try { return $.datepicker.parseDate($.datepicker._get(a, "dateFormat"), b, $.datepicker._getFormatConfig(a)) } catch (c) { } var d = (b.toLowerCase().match(/^c/) ? $.datepicker._getDate(a) : null) || new Date, e = d.getFullYear(), f = d.getMonth(), g = d.getDate(), h = /([+-]?[0-9]+)\s*(d|D|w|W|m|M|y|Y)?/g, i = h.exec(b); while (i) { switch (i[2] || "d") { case "d": case "D": g += parseInt(i[1], 10); break; case "w": case "W": g += parseInt(i[1], 10) * 7; break; case "m": case "M": f += parseInt(i[1], 10), g = Math.min(g, $.datepicker._getDaysInMonth(e, f)); break; case "y": case "Y": e += parseInt(i[1], 10), g = Math.min(g, $.datepicker._getDaysInMonth(e, f)) } i = h.exec(b) } return new Date(e, f, g) }, f = b == null || b === "" ? c : typeof b == "string" ? e(b) : typeof b == "number" ? isNaN(b) ? c : d(b) : new Date(b.getTime()); f = f && f.toString() == "Invalid Date" ? c : f, f && (f.setHours(0), f.setMinutes(0), f.setSeconds(0), f.setMilliseconds(0)); return this._daylightSavingAdjust(f) }, _daylightSavingAdjust: function (a) { if (!a) return null; a.setHours(a.getHours() > 12 ? a.getHours() + 2 : 0); return a }, _setDate: function (a, b, c) { var d = !b, e = a.selectedMonth, f = a.selectedYear, g = this._restrictMinMax(a, this._determineDate(a, b, new Date)); a.selectedDay = a.currentDay = g.getDate(), a.drawMonth = a.selectedMonth = a.currentMonth = g.getMonth(), a.drawYear = a.selectedYear = a.currentYear = g.getFullYear(), (e != a.selectedMonth || f != a.selectedYear) && !c && this._notifyChange(a), this._adjustInstDate(a), a.input && a.input.val(d ? "" : this._formatDate(a)) }, _getDate: function (a) { var b = !a.currentYear || a.input && a.input.val() == "" ? null : this._daylightSavingAdjust(new Date(a.currentYear, a.currentMonth, a.currentDay)); return b }, _generateHTML: function (a) {
        var b = new Date; b = this._daylightSavingAdjust(new Date(b.getFullYear(), b.getMonth(), b.getDate())); var c = this._get(a, "isRTL"), d = this._get(a, "showButtonPanel"), e = this._get(a, "hideIfNoPrevNext"), f = this._get(a, "navigationAsDateFormat"), g = this._getNumberOfMonths(a), h = this._get(a, "showCurrentAtPos"), i = this._get(a, "stepMonths"), j = g[0] != 1 || g[1] != 1, k = this._daylightSavingAdjust(a.currentDay ? new Date(a.currentYear, a.currentMonth, a.currentDay) : new Date(9999, 9, 9)), l = this._getMinMaxDate(a, "min"), m = this._getMinMaxDate(a, "max"), n = a.drawMonth - h, o = a.drawYear; n < 0 && (n += 12, o--); if (m) { var p = this._daylightSavingAdjust(new Date(m.getFullYear(), m.getMonth() - g[0] * g[1] + 1, m.getDate())); p = l && p < l ? l : p; while (this._daylightSavingAdjust(new Date(o, n, 1)) > p) n--, n < 0 && (n = 11, o--) } a.drawMonth = n, a.drawYear = o; var q = this._get(a, "prevText"); q = f ? this.formatDate(q, this._daylightSavingAdjust(new Date(o, n - i, 1)), this._getFormatConfig(a)) : q; var r = this._canAdjustMonth(a, -1, o, n) ? '<a class="ui-datepicker-prev ui-corner-all" onclick="DP_jQuery_' + dpuuid + ".datepicker._adjustDate('#" + a.id + "', -" + i + ", 'M');\"" + ' title="' + q + '"><span class="ui-icon ui-icon-circle-triangle-' + (c ? "e" : "w") + '">' + q + "</span></a>" : e ? "" : '<a class="ui-datepicker-prev ui-corner-all ui-state-disabled" title="' + q + '"><span class="ui-icon ui-icon-circle-triangle-' + (c ? "e" : "w") + '">' + q + "</span></a>", s = this._get(a, "nextText"); s = f ? this.formatDate(s, this._daylightSavingAdjust(new Date(o, n + i, 1)), this._getFormatConfig(a)) : s; var t = this._canAdjustMonth(a, 1, o, n) ? '<a class="ui-datepicker-next ui-corner-all" onclick="DP_jQuery_' + dpuuid + ".datepicker._adjustDate('#" + a.id + "', +" + i + ", 'M');\"" + ' title="' + s + '"><span class="ui-icon ui-icon-circle-triangle-' + (c ? "w" : "e") + '">' + s + "</span></a>" : e ? "" : '<a class="ui-datepicker-next ui-corner-all ui-state-disabled" title="' + s + '"><span class="ui-icon ui-icon-circle-triangle-' + (c ? "w" : "e") + '">' + s + "</span></a>", u = this._get(a, "currentText"), v = this._get(a, "gotoCurrent") && a.currentDay ? k : b; u = f ? this.formatDate(u, v, this._getFormatConfig(a)) : u; var w = a.inline ? "" : '<button type="button" class="ui-datepicker-close ui-state-default ui-priority-primary ui-corner-all" onclick="DP_jQuery_' + dpuuid + '.datepicker._hideDatepicker();">' + this._get(a, "closeText") + "</button>", x = d ? '<div class="ui-datepicker-buttonpane ui-widget-content">' + (c ? w : "") + (this._isInRange(a, v) ? '<button type="button" class="ui-datepicker-current ui-state-default ui-priority-secondary ui-corner-all" onclick="DP_jQuery_' + dpuuid + ".datepicker._gotoToday('#" + a.id + "');\"" + ">" + u + "</button>" : "") + (c ? "" : w) + "</div>" : "", y = parseInt(this._get(a, "firstDay"), 10); y = isNaN(y) ? 0 : y; var z = this._get(a, "showWeek"), A = this._get(a, "dayNames"), B = this._get(a, "dayNamesShort"), C = this._get(a, "dayNamesMin"), D = this._get(a, "monthNames"), E = this._get(a, "monthNamesShort"), F = this._get(a, "beforeShowDay"), G = this._get(a, "showOtherMonths"), H = this._get(a, "selectOtherMonths"), I = this._get(a, "calculateWeek") || this.iso8601Week, J = this._getDefaultDate(a), K = ""; for (var L = 0; L < g[0]; L++) { var M = ""; this.maxRows = 4; for (var N = 0; N < g[1]; N++) { var O = this._daylightSavingAdjust(new Date(o, n, a.selectedDay)), P = " ui-corner-all", Q = ""; if (j) { Q += '<div class="ui-datepicker-group'; if (g[1] > 1) switch (N) { case 0: Q += " ui-datepicker-group-first", P = " ui-corner-" + (c ? "right" : "left"); break; case g[1] - 1: Q += " ui-datepicker-group-last", P = " ui-corner-" + (c ? "left" : "right"); break; default: Q += " ui-datepicker-group-middle", P = "" } Q += '">' } Q += '<div class="ui-datepicker-header ui-widget-header ui-helper-clearfix' + P + '">' + (/all|left/.test(P) && L == 0 ? c ? t : r : "") + (/all|right/.test(P) && L == 0 ? c ? r : t : "") + this._generateMonthYearHeader(a, n, o, l, m, L > 0 || N > 0, D, E) + '</div><table class="ui-datepicker-calendar"><thead>' + "<tr>"; var R = z ? '<th class="ui-datepicker-week-col">' + this._get(a, "weekHeader") + "</th>" : ""; for (var S = 0; S < 7; S++) { var T = (S + y) % 7; R += "<th" + ((S + y + 6) % 7 >= 5 ? ' class="ui-datepicker-week-end"' : "") + ">" + '<span title="' + A[T] + '">' + C[T] + "</span></th>" } Q += R + "</tr></thead><tbody>"; var U = this._getDaysInMonth(o, n); o == a.selectedYear && n == a.selectedMonth && (a.selectedDay = Math.min(a.selectedDay, U)); var V = (this._getFirstDayOfMonth(o, n) - y + 7) % 7, W = Math.ceil((V + U) / 7), X = j ? this.maxRows > W ? this.maxRows : W : W; this.maxRows = X; var Y = this._daylightSavingAdjust(new Date(o, n, 1 - V)); for (var Z = 0; Z < X; Z++) { Q += "<tr>"; var _ = z ? '<td class="ui-datepicker-week-col">' + this._get(a, "calculateWeek")(Y) + "</td>" : ""; for (var S = 0; S < 7; S++) { var ba = F ? F.apply(a.input ? a.input[0] : null, [Y]) : [!0, ""], bb = Y.getMonth() != n, bc = bb && !H || !ba[0] || l && Y < l || m && Y > m; _ += '<td class="' + ((S + y + 6) % 7 >= 5 ? " ui-datepicker-week-end" : "") + (bb ? " ui-datepicker-other-month" : "") + (Y.getTime() == O.getTime() && n == a.selectedMonth && a._keyEvent || J.getTime() == Y.getTime() && J.getTime() == O.getTime() ? " " + this._dayOverClass : "") + (bc ? " " + this._unselectableClass + " ui-state-disabled" : "") + (bb && !G ? "" : " " + ba[1] + (Y.getTime() == k.getTime() ? " " + this._currentClass : "") + (Y.getTime() == b.getTime() ? " ui-datepicker-today" : "")) + '"' + ((!bb || G) && ba[2] ? ' title="' + ba[2] + '"' : "") + (bc ? "" : ' onclick="DP_jQuery_' + dpuuid + ".datepicker._selectDay('#" + a.id + "'," + Y.getMonth() + "," + Y.getFullYear() + ', this);return false;"') + ">" + (bb && !G ? "&#xa0;" : bc ? '<span class="ui-state-default">' + Y.getDate() + "</span>" : '<a class="ui-state-default' + (Y.getTime() == b.getTime() ? " ui-state-highlight" : "") + (Y.getTime() == k.getTime() ? " ui-state-active" : "") + (bb ? " ui-priority-secondary" : "") + '" href="#">' + Y.getDate() + "</a>") + "</td>", Y.setDate(Y.getDate() + 1), Y = this._daylightSavingAdjust(Y) } Q += _ + "</tr>" } n++, n > 11 && (n = 0, o++), Q += "</tbody></table>" + (j ? "</div>" + (g[0] > 0 && N == g[1] - 1 ? '<div class="ui-datepicker-row-break"></div>' : "") : ""), M += Q } K += M } K += x + ($.browser.msie && parseInt($.browser.version, 10) < 7 && !a.inline ? '<iframe src="javascript:false;" class="ui-datepicker-cover" frameborder="0"></iframe>' : ""),
a._keyEvent = !1; return K
    }, _generateMonthYearHeader: function (a, b, c, d, e, f, g, h) { var i = this._get(a, "changeMonth"), j = this._get(a, "changeYear"), k = this._get(a, "showMonthAfterYear"), l = '<div class="ui-datepicker-title">', m = ""; if (f || !i) m += '<span class="ui-datepicker-month">' + g[b] + "</span>"; else { var n = d && d.getFullYear() == c, o = e && e.getFullYear() == c; m += '<select class="ui-datepicker-month" onchange="DP_jQuery_' + dpuuid + ".datepicker._selectMonthYear('#" + a.id + "', this, 'M');\" " + ">"; for (var p = 0; p < 12; p++) (!n || p >= d.getMonth()) && (!o || p <= e.getMonth()) && (m += '<option value="' + p + '"' + (p == b ? ' selected="selected"' : "") + ">" + h[p] + "</option>"); m += "</select>" } k || (l += m + (f || !i || !j ? "&#xa0;" : "")); if (!a.yearshtml) { a.yearshtml = ""; if (f || !j) l += '<span class="ui-datepicker-year">' + c + "</span>"; else { var q = this._get(a, "yearRange").split(":"), r = (new Date).getFullYear(), s = function (a) { var b = a.match(/c[+-].*/) ? c + parseInt(a.substring(1), 10) : a.match(/[+-].*/) ? r + parseInt(a, 10) : parseInt(a, 10); return isNaN(b) ? r : b }, t = s(q[0]), u = Math.max(t, s(q[1] || "")); t = d ? Math.max(t, d.getFullYear()) : t, u = e ? Math.min(u, e.getFullYear()) : u, a.yearshtml += '<select class="ui-datepicker-year" onchange="DP_jQuery_' + dpuuid + ".datepicker._selectMonthYear('#" + a.id + "', this, 'Y');\" " + ">"; for (; t <= u; t++) a.yearshtml += '<option value="' + t + '"' + (t == c ? ' selected="selected"' : "") + ">" + t + "</option>"; a.yearshtml += "</select>", l += a.yearshtml, a.yearshtml = null } } l += this._get(a, "yearSuffix"), k && (l += (f || !i || !j ? "&#xa0;" : "") + m), l += "</div>"; return l }, _adjustInstDate: function (a, b, c) { var d = a.drawYear + (c == "Y" ? b : 0), e = a.drawMonth + (c == "M" ? b : 0), f = Math.min(a.selectedDay, this._getDaysInMonth(d, e)) + (c == "D" ? b : 0), g = this._restrictMinMax(a, this._daylightSavingAdjust(new Date(d, e, f))); a.selectedDay = g.getDate(), a.drawMonth = a.selectedMonth = g.getMonth(), a.drawYear = a.selectedYear = g.getFullYear(), (c == "M" || c == "Y") && this._notifyChange(a) }, _restrictMinMax: function (a, b) { var c = this._getMinMaxDate(a, "min"), d = this._getMinMaxDate(a, "max"), e = c && b < c ? c : b; e = d && e > d ? d : e; return e }, _notifyChange: function (a) { var b = this._get(a, "onChangeMonthYear"); b && b.apply(a.input ? a.input[0] : null, [a.selectedYear, a.selectedMonth + 1, a]) }, _getNumberOfMonths: function (a) { var b = this._get(a, "numberOfMonths"); return b == null ? [1, 1] : typeof b == "number" ? [1, b] : b }, _getMinMaxDate: function (a, b) { return this._determineDate(a, this._get(a, b + "Date"), null) }, _getDaysInMonth: function (a, b) { return 32 - this._daylightSavingAdjust(new Date(a, b, 32)).getDate() }, _getFirstDayOfMonth: function (a, b) { return (new Date(a, b, 1)).getDay() }, _canAdjustMonth: function (a, b, c, d) { var e = this._getNumberOfMonths(a), f = this._daylightSavingAdjust(new Date(c, d + (b < 0 ? b : e[0] * e[1]), 1)); b < 0 && f.setDate(this._getDaysInMonth(f.getFullYear(), f.getMonth())); return this._isInRange(a, f) }, _isInRange: function (a, b) { var c = this._getMinMaxDate(a, "min"), d = this._getMinMaxDate(a, "max"); return (!c || b.getTime() >= c.getTime()) && (!d || b.getTime() <= d.getTime()) }, _getFormatConfig: function (a) { var b = this._get(a, "shortYearCutoff"); b = typeof b != "string" ? b : (new Date).getFullYear() % 100 + parseInt(b, 10); return { shortYearCutoff: b, dayNamesShort: this._get(a, "dayNamesShort"), dayNames: this._get(a, "dayNames"), monthNamesShort: this._get(a, "monthNamesShort"), monthNames: this._get(a, "monthNames")} }, _formatDate: function (a, b, c, d) { b || (a.currentDay = a.selectedDay, a.currentMonth = a.selectedMonth, a.currentYear = a.selectedYear); var e = b ? typeof b == "object" ? b : this._daylightSavingAdjust(new Date(d, c, b)) : this._daylightSavingAdjust(new Date(a.currentYear, a.currentMonth, a.currentDay)); return this.formatDate(this._get(a, "dateFormat"), e, this._getFormatConfig(a)) }
    }), $.fn.datepicker = function (a) { if (!this.length) return this; $.datepicker.initialized || ($(document).mousedown($.datepicker._checkExternalClick).find("body").append($.datepicker.dpDiv), $.datepicker.initialized = !0); var b = Array.prototype.slice.call(arguments, 1); if (typeof a == "string" && (a == "isDisabled" || a == "getDate" || a == "widget")) return $.datepicker["_" + a + "Datepicker"].apply($.datepicker, [this[0]].concat(b)); if (a == "option" && arguments.length == 2 && typeof arguments[1] == "string") return $.datepicker["_" + a + "Datepicker"].apply($.datepicker, [this[0]].concat(b)); return this.each(function () { typeof a == "string" ? $.datepicker["_" + a + "Datepicker"].apply($.datepicker, [this].concat(b)) : $.datepicker._attachDatepicker(this, a) }) }, $.datepicker = new Datepicker, $.datepicker.initialized = !1, $.datepicker.uuid = (new Date).getTime(), $.datepicker.version = "1.8.18", window["DP_jQuery_" + dpuuid] = $
})(jQuery); /*
* jQuery UI Progressbar 1.8.18
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Progressbar
*
* Depends:
*   jquery.ui.core.js
*   jquery.ui.widget.js
*/
(function (a, b) { a.widget("ui.progressbar", { options: { value: 0, max: 100 }, min: 0, _create: function () { this.element.addClass("ui-progressbar ui-widget ui-widget-content ui-corner-all").attr({ role: "progressbar", "aria-valuemin": this.min, "aria-valuemax": this.options.max, "aria-valuenow": this._value() }), this.valueDiv = a("<div class='ui-progressbar-value ui-widget-header ui-corner-left'></div>").appendTo(this.element), this.oldValue = this._value(), this._refreshValue() }, destroy: function () { this.element.removeClass("ui-progressbar ui-widget ui-widget-content ui-corner-all").removeAttr("role").removeAttr("aria-valuemin").removeAttr("aria-valuemax").removeAttr("aria-valuenow"), this.valueDiv.remove(), a.Widget.prototype.destroy.apply(this, arguments) }, value: function (a) { if (a === b) return this._value(); this._setOption("value", a); return this }, _setOption: function (b, c) { b === "value" && (this.options.value = c, this._refreshValue(), this._value() === this.options.max && this._trigger("complete")), a.Widget.prototype._setOption.apply(this, arguments) }, _value: function () { var a = this.options.value; typeof a != "number" && (a = 0); return Math.min(this.options.max, Math.max(this.min, a)) }, _percentage: function () { return 100 * this._value() / this.options.max }, _refreshValue: function () { var a = this.value(), b = this._percentage(); this.oldValue !== a && (this.oldValue = a, this._trigger("change")), this.valueDiv.toggle(a > this.min).toggleClass("ui-corner-right", a === this.options.max).width(b.toFixed(0) + "%"), this.element.attr("aria-valuenow", a) } }), a.extend(a.ui.progressbar, { version: "1.8.18" }) })(jQuery);
/* jQuery UI Effects 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/
*/
jQuery.effects || function (a, b) { function l(b) { if (!b || typeof b == "number" || a.fx.speeds[b]) return !0; if (typeof b == "string" && !a.effects[b]) return !0; return !1 } function k(b, c, d, e) { typeof b == "object" && (e = c, d = null, c = b, b = c.effect), a.isFunction(c) && (e = c, d = null, c = {}); if (typeof c == "number" || a.fx.speeds[c]) e = d, d = c, c = {}; a.isFunction(d) && (e = d, d = null), c = c || {}, d = d || c.duration, d = a.fx.off ? 0 : typeof d == "number" ? d : d in a.fx.speeds ? a.fx.speeds[d] : a.fx.speeds._default, e = e || c.complete; return [b, c, d, e] } function j(a, b) { var c = { _: 0 }, d; for (d in b) a[d] != b[d] && (c[d] = b[d]); return c } function i(b) { var c, d; for (c in b) d = b[c], (d == null || a.isFunction(d) || c in g || /scrollbar/.test(c) || !/color/i.test(c) && isNaN(parseFloat(d))) && delete b[c]; return b } function h() { var a = document.defaultView ? document.defaultView.getComputedStyle(this, null) : this.currentStyle, b = {}, c, d; if (a && a.length && a[0] && a[a[0]]) { var e = a.length; while (e--) c = a[e], typeof a[c] == "string" && (d = c.replace(/\-(\w)/g, function (a, b) { return b.toUpperCase() }), b[d] = a[c]) } else for (c in a) typeof a[c] == "string" && (b[c] = a[c]); return b } function d(b, d) { var e; do { e = a.curCSS(b, d); if (e != "" && e != "transparent" || a.nodeName(b, "body")) break; d = "backgroundColor" } while (b = b.parentNode); return c(e) } function c(b) { var c; if (b && b.constructor == Array && b.length == 3) return b; if (c = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(b)) return [parseInt(c[1], 10), parseInt(c[2], 10), parseInt(c[3], 10)]; if (c = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(b)) return [parseFloat(c[1]) * 2.55, parseFloat(c[2]) * 2.55, parseFloat(c[3]) * 2.55]; if (c = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(b)) return [parseInt(c[1], 16), parseInt(c[2], 16), parseInt(c[3], 16)]; if (c = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(b)) return [parseInt(c[1] + c[1], 16), parseInt(c[2] + c[2], 16), parseInt(c[3] + c[3], 16)]; if (c = /rgba\(0, 0, 0, 0\)/.exec(b)) return e.transparent; return e[a.trim(b).toLowerCase()] } a.effects = {}, a.each(["backgroundColor", "borderBottomColor", "borderLeftColor", "borderRightColor", "borderTopColor", "borderColor", "color", "outlineColor"], function (b, e) { a.fx.step[e] = function (a) { a.colorInit || (a.start = d(a.elem, e), a.end = c(a.end), a.colorInit = !0), a.elem.style[e] = "rgb(" + Math.max(Math.min(parseInt(a.pos * (a.end[0] - a.start[0]) + a.start[0], 10), 255), 0) + "," + Math.max(Math.min(parseInt(a.pos * (a.end[1] - a.start[1]) + a.start[1], 10), 255), 0) + "," + Math.max(Math.min(parseInt(a.pos * (a.end[2] - a.start[2]) + a.start[2], 10), 255), 0) + ")" } }); var e = { aqua: [0, 255, 255], azure: [240, 255, 255], beige: [245, 245, 220], black: [0, 0, 0], blue: [0, 0, 255], brown: [165, 42, 42], cyan: [0, 255, 255], darkblue: [0, 0, 139], darkcyan: [0, 139, 139], darkgrey: [169, 169, 169], darkgreen: [0, 100, 0], darkkhaki: [189, 183, 107], darkmagenta: [139, 0, 139], darkolivegreen: [85, 107, 47], darkorange: [255, 140, 0], darkorchid: [153, 50, 204], darkred: [139, 0, 0], darksalmon: [233, 150, 122], darkviolet: [148, 0, 211], fuchsia: [255, 0, 255], gold: [255, 215, 0], green: [0, 128, 0], indigo: [75, 0, 130], khaki: [240, 230, 140], lightblue: [173, 216, 230], lightcyan: [224, 255, 255], lightgreen: [144, 238, 144], lightgrey: [211, 211, 211], lightpink: [255, 182, 193], lightyellow: [255, 255, 224], lime: [0, 255, 0], magenta: [255, 0, 255], maroon: [128, 0, 0], navy: [0, 0, 128], olive: [128, 128, 0], orange: [255, 165, 0], pink: [255, 192, 203], purple: [128, 0, 128], violet: [128, 0, 128], red: [255, 0, 0], silver: [192, 192, 192], white: [255, 255, 255], yellow: [255, 255, 0], transparent: [255, 255, 255] }, f = ["add", "remove", "toggle"], g = { border: 1, borderBottom: 1, borderColor: 1, borderLeft: 1, borderRight: 1, borderTop: 1, borderWidth: 1, margin: 1, padding: 1 }; a.effects.animateClass = function (b, c, d, e) { a.isFunction(d) && (e = d, d = null); return this.queue(function () { var g = a(this), k = g.attr("style") || " ", l = i(h.call(this)), m, n = g.attr("class"); a.each(f, function (a, c) { b[c] && g[c + "Class"](b[c]) }), m = i(h.call(this)), g.attr("class", n), g.animate(j(l, m), { queue: !1, duration: c, easing: d, complete: function () { a.each(f, function (a, c) { b[c] && g[c + "Class"](b[c]) }), typeof g.attr("style") == "object" ? (g.attr("style").cssText = "", g.attr("style").cssText = k) : g.attr("style", k), e && e.apply(this, arguments), a.dequeue(this) } }) }) }, a.fn.extend({ _addClass: a.fn.addClass, addClass: function (b, c, d, e) { return c ? a.effects.animateClass.apply(this, [{ add: b }, c, d, e]) : this._addClass(b) }, _removeClass: a.fn.removeClass, removeClass: function (b, c, d, e) { return c ? a.effects.animateClass.apply(this, [{ remove: b }, c, d, e]) : this._removeClass(b) }, _toggleClass: a.fn.toggleClass, toggleClass: function (c, d, e, f, g) { return typeof d == "boolean" || d === b ? e ? a.effects.animateClass.apply(this, [d ? { add: c} : { remove: c }, e, f, g]) : this._toggleClass(c, d) : a.effects.animateClass.apply(this, [{ toggle: c }, d, e, f]) }, switchClass: function (b, c, d, e, f) { return a.effects.animateClass.apply(this, [{ add: c, remove: b }, d, e, f]) } }), a.extend(a.effects, { version: "1.8.17", save: function (a, b) { for (var c = 0; c < b.length; c++) b[c] !== null && a.data("ec.storage." + b[c], a[0].style[b[c]]) }, restore: function (a, b) { for (var c = 0; c < b.length; c++) b[c] !== null && a.css(b[c], a.data("ec.storage." + b[c])) }, setMode: function (a, b) { b == "toggle" && (b = a.is(":hidden") ? "show" : "hide"); return b }, getBaseline: function (a, b) { var c, d; switch (a[0]) { case "top": c = 0; break; case "middle": c = .5; break; case "bottom": c = 1; break; default: c = a[0] / b.height } switch (a[1]) { case "left": d = 0; break; case "center": d = .5; break; case "right": d = 1; break; default: d = a[1] / b.width } return { x: d, y: c} }, createWrapper: function (b) { if (b.parent().is(".ui-effects-wrapper")) return b.parent(); var c = { width: b.outerWidth(!0), height: b.outerHeight(!0), "float": b.css("float") }, d = a("<div></div>").addClass("ui-effects-wrapper").css({ fontSize: "100%", background: "transparent", border: "none", margin: 0, padding: 0 }), e = document.activeElement; b.wrap(d), (b[0] === e || a.contains(b[0], e)) && a(e).focus(), d = b.parent(), b.css("position") == "static" ? (d.css({ position: "relative" }), b.css({ position: "relative" })) : (a.extend(c, { position: b.css("position"), zIndex: b.css("z-index") }), a.each(["top", "left", "bottom", "right"], function (a, d) { c[d] = b.css(d), isNaN(parseInt(c[d], 10)) && (c[d] = "auto") }), b.css({ position: "relative", top: 0, left: 0, right: "auto", bottom: "auto" })); return d.css(c).show() }, removeWrapper: function (b) { var c, d = document.activeElement; if (b.parent().is(".ui-effects-wrapper")) { c = b.parent().replaceWith(b), (b[0] === d || a.contains(b[0], d)) && a(d).focus(); return c } return b }, setTransition: function (b, c, d, e) { e = e || {}, a.each(c, function (a, c) { unit = b.cssUnit(c), unit[0] > 0 && (e[c] = unit[0] * d + unit[1]) }); return e } }), a.fn.extend({ effect: function (b, c, d, e) { var f = k.apply(this, arguments), g = { options: f[1], duration: f[2], callback: f[3] }, h = g.options.mode, i = a.effects[b]; if (a.fx.off || !i) return h ? this[h](g.duration, g.callback) : this.each(function () { g.callback && g.callback.call(this) }); return i.call(this, g) }, _show: a.fn.show, show: function (a) { if (l(a)) return this._show.apply(this, arguments); var b = k.apply(this, arguments); b[1].mode = "show"; return this.effect.apply(this, b) }, _hide: a.fn.hide, hide: function (a) { if (l(a)) return this._hide.apply(this, arguments); var b = k.apply(this, arguments); b[1].mode = "hide"; return this.effect.apply(this, b) }, __toggle: a.fn.toggle, toggle: function (b) { if (l(b) || typeof b == "boolean" || a.isFunction(b)) return this.__toggle.apply(this, arguments); var c = k.apply(this, arguments); c[1].mode = "toggle"; return this.effect.apply(this, c) }, cssUnit: function (b) { var c = this.css(b), d = []; a.each(["em", "px", "%", "pt"], function (a, b) { c.indexOf(b) > 0 && (d = [parseFloat(c), b]) }); return d } }), a.easing.jswing = a.easing.swing, a.extend(a.easing, { def: "easeOutQuad", swing: function (b, c, d, e, f) { return a.easing[a.easing.def](b, c, d, e, f) }, easeInQuad: function (a, b, c, d, e) { return d * (b /= e) * b + c }, easeOutQuad: function (a, b, c, d, e) { return -d * (b /= e) * (b - 2) + c }, easeInOutQuad: function (a, b, c, d, e) { if ((b /= e / 2) < 1) return d / 2 * b * b + c; return -d / 2 * (--b * (b - 2) - 1) + c }, easeInCubic: function (a, b, c, d, e) { return d * (b /= e) * b * b + c }, easeOutCubic: function (a, b, c, d, e) { return d * ((b = b / e - 1) * b * b + 1) + c }, easeInOutCubic: function (a, b, c, d, e) { if ((b /= e / 2) < 1) return d / 2 * b * b * b + c; return d / 2 * ((b -= 2) * b * b + 2) + c }, easeInQuart: function (a, b, c, d, e) { return d * (b /= e) * b * b * b + c }, easeOutQuart: function (a, b, c, d, e) { return -d * ((b = b / e - 1) * b * b * b - 1) + c }, easeInOutQuart: function (a, b, c, d, e) { if ((b /= e / 2) < 1) return d / 2 * b * b * b * b + c; return -d / 2 * ((b -= 2) * b * b * b - 2) + c }, easeInQuint: function (a, b, c, d, e) { return d * (b /= e) * b * b * b * b + c }, easeOutQuint: function (a, b, c, d, e) { return d * ((b = b / e - 1) * b * b * b * b + 1) + c }, easeInOutQuint: function (a, b, c, d, e) { if ((b /= e / 2) < 1) return d / 2 * b * b * b * b * b + c; return d / 2 * ((b -= 2) * b * b * b * b + 2) + c }, easeInSine: function (a, b, c, d, e) { return -d * Math.cos(b / e * (Math.PI / 2)) + d + c }, easeOutSine: function (a, b, c, d, e) { return d * Math.sin(b / e * (Math.PI / 2)) + c }, easeInOutSine: function (a, b, c, d, e) { return -d / 2 * (Math.cos(Math.PI * b / e) - 1) + c }, easeInExpo: function (a, b, c, d, e) { return b == 0 ? c : d * Math.pow(2, 10 * (b / e - 1)) + c }, easeOutExpo: function (a, b, c, d, e) { return b == e ? c + d : d * (-Math.pow(2, -10 * b / e) + 1) + c }, easeInOutExpo: function (a, b, c, d, e) { if (b == 0) return c; if (b == e) return c + d; if ((b /= e / 2) < 1) return d / 2 * Math.pow(2, 10 * (b - 1)) + c; return d / 2 * (-Math.pow(2, -10 * --b) + 2) + c }, easeInCirc: function (a, b, c, d, e) { return -d * (Math.sqrt(1 - (b /= e) * b) - 1) + c }, easeOutCirc: function (a, b, c, d, e) { return d * Math.sqrt(1 - (b = b / e - 1) * b) + c }, easeInOutCirc: function (a, b, c, d, e) { if ((b /= e / 2) < 1) return -d / 2 * (Math.sqrt(1 - b * b) - 1) + c; return d / 2 * (Math.sqrt(1 - (b -= 2) * b) + 1) + c }, easeInElastic: function (a, b, c, d, e) { var f = 1.70158, g = 0, h = d; if (b == 0) return c; if ((b /= e) == 1) return c + d; g || (g = e * .3); if (h < Math.abs(d)) { h = d; var f = g / 4 } else var f = g / (2 * Math.PI) * Math.asin(d / h); return -(h * Math.pow(2, 10 * (b -= 1)) * Math.sin((b * e - f) * 2 * Math.PI / g)) + c }, easeOutElastic: function (a, b, c, d, e) { var f = 1.70158, g = 0, h = d; if (b == 0) return c; if ((b /= e) == 1) return c + d; g || (g = e * .3); if (h < Math.abs(d)) { h = d; var f = g / 4 } else var f = g / (2 * Math.PI) * Math.asin(d / h); return h * Math.pow(2, -10 * b) * Math.sin((b * e - f) * 2 * Math.PI / g) + d + c }, easeInOutElastic: function (a, b, c, d, e) { var f = 1.70158, g = 0, h = d; if (b == 0) return c; if ((b /= e / 2) == 2) return c + d; g || (g = e * .3 * 1.5); if (h < Math.abs(d)) { h = d; var f = g / 4 } else var f = g / (2 * Math.PI) * Math.asin(d / h); if (b < 1) return -0.5 * h * Math.pow(2, 10 * (b -= 1)) * Math.sin((b * e - f) * 2 * Math.PI / g) + c; return h * Math.pow(2, -10 * (b -= 1)) * Math.sin((b * e - f) * 2 * Math.PI / g) * .5 + d + c }, easeInBack: function (a, c, d, e, f, g) { g == b && (g = 1.70158); return e * (c /= f) * c * ((g + 1) * c - g) + d }, easeOutBack: function (a, c, d, e, f, g) { g == b && (g = 1.70158); return e * ((c = c / f - 1) * c * ((g + 1) * c + g) + 1) + d }, easeInOutBack: function (a, c, d, e, f, g) { g == b && (g = 1.70158); if ((c /= f / 2) < 1) return e / 2 * c * c * (((g *= 1.525) + 1) * c - g) + d; return e / 2 * ((c -= 2) * c * (((g *= 1.525) + 1) * c + g) + 2) + d }, easeInBounce: function (b, c, d, e, f) { return e - a.easing.easeOutBounce(b, f - c, 0, e, f) + d }, easeOutBounce: function (a, b, c, d, e) { return (b /= e) < 1 / 2.75 ? d * 7.5625 * b * b + c : b < 2 / 2.75 ? d * (7.5625 * (b -= 1.5 / 2.75) * b + .75) + c : b < 2.5 / 2.75 ? d * (7.5625 * (b -= 2.25 / 2.75) * b + .9375) + c : d * (7.5625 * (b -= 2.625 / 2.75) * b + .984375) + c }, easeInOutBounce: function (b, c, d, e, f) { if (c < f / 2) return a.easing.easeInBounce(b, c * 2, 0, e, f) * .5 + d; return a.easing.easeOutBounce(b, c * 2 - f, 0, e, f) * .5 + e * .5 + d } }) } (jQuery); /*
* jQuery UI Effects Blind 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Blind
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.blind = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right"], e = a.effects.setMode(c, b.options.mode || "hide"), f = b.options.direction || "vertical"; a.effects.save(c, d), c.show(); var g = a.effects.createWrapper(c).css({ overflow: "hidden" }), h = f == "vertical" ? "height" : "width", i = f == "vertical" ? g.height() : g.width(); e == "show" && g.css(h, 0); var j = {}; j[h] = e == "show" ? i : 0, g.animate(j, b.duration, b.options.easing, function () { e == "hide" && c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(c[0], arguments), c.dequeue() }) }) } })(jQuery); /*
* jQuery UI Effects Bounce 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Bounce
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.bounce = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right"], e = a.effects.setMode(c, b.options.mode || "effect"), f = b.options.direction || "up", g = b.options.distance || 20, h = b.options.times || 5, i = b.duration || 250; /show|hide/.test(e) && d.push("opacity"), a.effects.save(c, d), c.show(), a.effects.createWrapper(c); var j = f == "up" || f == "down" ? "top" : "left", k = f == "up" || f == "left" ? "pos" : "neg", g = b.options.distance || (j == "top" ? c.outerHeight({ margin: !0 }) / 3 : c.outerWidth({ margin: !0 }) / 3); e == "show" && c.css("opacity", 0).css(j, k == "pos" ? -g : g), e == "hide" && (g = g / (h * 2)), e != "hide" && h--; if (e == "show") { var l = { opacity: 1 }; l[j] = (k == "pos" ? "+=" : "-=") + g, c.animate(l, i / 2, b.options.easing), g = g / 2, h-- } for (var m = 0; m < h; m++) { var n = {}, p = {}; n[j] = (k == "pos" ? "-=" : "+=") + g, p[j] = (k == "pos" ? "+=" : "-=") + g, c.animate(n, i / 2, b.options.easing).animate(p, i / 2, b.options.easing), g = e == "hide" ? g * 2 : g / 2 } if (e == "hide") { var l = { opacity: 0 }; l[j] = (k == "pos" ? "-=" : "+=") + g, c.animate(l, i / 2, b.options.easing, function () { c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments) }) } else { var n = {}, p = {}; n[j] = (k == "pos" ? "-=" : "+=") + g, p[j] = (k == "pos" ? "+=" : "-=") + g, c.animate(n, i / 2, b.options.easing).animate(p, i / 2, b.options.easing, function () { a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments) }) } c.queue("fx", function () { c.dequeue() }), c.dequeue() }) } })(jQuery); /*
* jQuery UI Effects Clip 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Clip
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.clip = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right", "height", "width"], e = a.effects.setMode(c, b.options.mode || "hide"), f = b.options.direction || "vertical"; a.effects.save(c, d), c.show(); var g = a.effects.createWrapper(c).css({ overflow: "hidden" }), h = c[0].tagName == "IMG" ? g : c, i = { size: f == "vertical" ? "height" : "width", position: f == "vertical" ? "top" : "left" }, j = f == "vertical" ? h.height() : h.width(); e == "show" && (h.css(i.size, 0), h.css(i.position, j / 2)); var k = {}; k[i.size] = e == "show" ? j : 0, k[i.position] = e == "show" ? 0 : j / 2, h.animate(k, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { e == "hide" && c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(c[0], arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Drop 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Drop
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.drop = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right", "opacity"], e = a.effects.setMode(c, b.options.mode || "hide"), f = b.options.direction || "left"; a.effects.save(c, d), c.show(), a.effects.createWrapper(c); var g = f == "up" || f == "down" ? "top" : "left", h = f == "up" || f == "left" ? "pos" : "neg", i = b.options.distance || (g == "top" ? c.outerHeight({ margin: !0 }) / 2 : c.outerWidth({ margin: !0 }) / 2); e == "show" && c.css("opacity", 0).css(g, h == "pos" ? -i : i); var j = { opacity: e == "show" ? 1 : 0 }; j[g] = (e == "show" ? h == "pos" ? "+=" : "-=" : h == "pos" ? "-=" : "+=") + i, c.animate(j, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { e == "hide" && c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Explode 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Explode
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.explode = function (b) { return this.queue(function () { var c = b.options.pieces ? Math.round(Math.sqrt(b.options.pieces)) : 3, d = b.options.pieces ? Math.round(Math.sqrt(b.options.pieces)) : 3; b.options.mode = b.options.mode == "toggle" ? a(this).is(":visible") ? "hide" : "show" : b.options.mode; var e = a(this).show().css("visibility", "hidden"), f = e.offset(); f.top -= parseInt(e.css("marginTop"), 10) || 0, f.left -= parseInt(e.css("marginLeft"), 10) || 0; var g = e.outerWidth(!0), h = e.outerHeight(!0); for (var i = 0; i < c; i++) for (var j = 0; j < d; j++) e.clone().appendTo("body").wrap("<div></div>").css({ position: "absolute", visibility: "visible", left: -j * (g / d), top: -i * (h / c) }).parent().addClass("ui-effects-explode").css({ position: "absolute", overflow: "hidden", width: g / d, height: h / c, left: f.left + j * (g / d) + (b.options.mode == "show" ? (j - Math.floor(d / 2)) * (g / d) : 0), top: f.top + i * (h / c) + (b.options.mode == "show" ? (i - Math.floor(c / 2)) * (h / c) : 0), opacity: b.options.mode == "show" ? 0 : 1 }).animate({ left: f.left + j * (g / d) + (b.options.mode == "show" ? 0 : (j - Math.floor(d / 2)) * (g / d)), top: f.top + i * (h / c) + (b.options.mode == "show" ? 0 : (i - Math.floor(c / 2)) * (h / c)), opacity: b.options.mode == "show" ? 1 : 0 }, b.duration || 500); setTimeout(function () { b.options.mode == "show" ? e.css({ visibility: "visible" }) : e.css({ visibility: "visible" }).hide(), b.callback && b.callback.apply(e[0]), e.dequeue(), a("div.ui-effects-explode").remove() }, b.duration || 500) }) } })(jQuery); /*
* jQuery UI Effects Fade 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Fade
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.fade = function (b) { return this.queue(function () { var c = a(this), d = a.effects.setMode(c, b.options.mode || "hide"); c.animate({ opacity: d }, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { b.callback && b.callback.apply(this, arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Fold 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Fold
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.fold = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right"], e = a.effects.setMode(c, b.options.mode || "hide"), f = b.options.size || 15, g = !!b.options.horizFirst, h = b.duration ? b.duration / 2 : a.fx.speeds._default / 2; a.effects.save(c, d), c.show(); var i = a.effects.createWrapper(c).css({ overflow: "hidden" }), j = e == "show" != g, k = j ? ["width", "height"] : ["height", "width"], l = j ? [i.width(), i.height()] : [i.height(), i.width()], m = /([0-9]+)%/.exec(f); m && (f = parseInt(m[1], 10) / 100 * l[e == "hide" ? 0 : 1]), e == "show" && i.css(g ? { height: 0, width: f} : { height: f, width: 0 }); var n = {}, p = {}; n[k[0]] = e == "show" ? l[0] : f, p[k[1]] = e == "show" ? l[1] : 0, i.animate(n, h, b.options.easing).animate(p, h, b.options.easing, function () { e == "hide" && c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(c[0], arguments), c.dequeue() }) }) } })(jQuery); /*
* jQuery UI Effects Highlight 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Highlight
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.highlight = function (b) { return this.queue(function () { var c = a(this), d = ["backgroundImage", "backgroundColor", "opacity"], e = a.effects.setMode(c, b.options.mode || "show"), f = { backgroundColor: c.css("backgroundColor") }; e == "hide" && (f.opacity = 0), a.effects.save(c, d), c.show().css({ backgroundImage: "none", backgroundColor: b.options.color || "#ffff99" }).animate(f, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { e == "hide" && c.hide(), a.effects.restore(c, d), e == "show" && !a.support.opacity && this.style.removeAttribute("filter"), b.callback && b.callback.apply(this, arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Pulsate 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Pulsate
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.pulsate = function (b) { return this.queue(function () { var c = a(this), d = a.effects.setMode(c, b.options.mode || "show"); times = (b.options.times || 5) * 2 - 1, duration = b.duration ? b.duration / 2 : a.fx.speeds._default / 2, isVisible = c.is(":visible"), animateTo = 0, isVisible || (c.css("opacity", 0).show(), animateTo = 1), (d == "hide" && isVisible || d == "show" && !isVisible) && times--; for (var e = 0; e < times; e++) c.animate({ opacity: animateTo }, duration, b.options.easing), animateTo = (animateTo + 1) % 2; c.animate({ opacity: animateTo }, duration, b.options.easing, function () { animateTo == 0 && c.hide(), b.callback && b.callback.apply(this, arguments) }), c.queue("fx", function () { c.dequeue() }).dequeue() }) } })(jQuery); /*
* jQuery UI Effects Scale 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Scale
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.puff = function (b) { return this.queue(function () { var c = a(this), d = a.effects.setMode(c, b.options.mode || "hide"), e = parseInt(b.options.percent, 10) || 150, f = e / 100, g = { height: c.height(), width: c.width() }; a.extend(b.options, { fade: !0, mode: d, percent: d == "hide" ? e : 100, from: d == "hide" ? g : { height: g.height * f, width: g.width * f} }), c.effect("scale", b.options, b.duration, b.callback), c.dequeue() }) }, a.effects.scale = function (b) { return this.queue(function () { var c = a(this), d = a.extend(!0, {}, b.options), e = a.effects.setMode(c, b.options.mode || "effect"), f = parseInt(b.options.percent, 10) || (parseInt(b.options.percent, 10) == 0 ? 0 : e == "hide" ? 0 : 100), g = b.options.direction || "both", h = b.options.origin; e != "effect" && (d.origin = h || ["middle", "center"], d.restore = !0); var i = { height: c.height(), width: c.width() }; c.from = b.options.from || (e == "show" ? { height: 0, width: 0} : i); var j = { y: g != "horizontal" ? f / 100 : 1, x: g != "vertical" ? f / 100 : 1 }; c.to = { height: i.height * j.y, width: i.width * j.x }, b.options.fade && (e == "show" && (c.from.opacity = 0, c.to.opacity = 1), e == "hide" && (c.from.opacity = 1, c.to.opacity = 0)), d.from = c.from, d.to = c.to, d.mode = e, c.effect("size", d, b.duration, b.callback), c.dequeue() }) }, a.effects.size = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right", "width", "height", "overflow", "opacity"], e = ["position", "top", "bottom", "left", "right", "overflow", "opacity"], f = ["width", "height", "overflow"], g = ["fontSize"], h = ["borderTopWidth", "borderBottomWidth", "paddingTop", "paddingBottom"], i = ["borderLeftWidth", "borderRightWidth", "paddingLeft", "paddingRight"], j = a.effects.setMode(c, b.options.mode || "effect"), k = b.options.restore || !1, l = b.options.scale || "both", m = b.options.origin, n = { height: c.height(), width: c.width() }; c.from = b.options.from || n, c.to = b.options.to || n; if (m) { var p = a.effects.getBaseline(m, n); c.from.top = (n.height - c.from.height) * p.y, c.from.left = (n.width - c.from.width) * p.x, c.to.top = (n.height - c.to.height) * p.y, c.to.left = (n.width - c.to.width) * p.x } var q = { from: { y: c.from.height / n.height, x: c.from.width / n.width }, to: { y: c.to.height / n.height, x: c.to.width / n.width} }; if (l == "box" || l == "both") q.from.y != q.to.y && (d = d.concat(h), c.from = a.effects.setTransition(c, h, q.from.y, c.from), c.to = a.effects.setTransition(c, h, q.to.y, c.to)), q.from.x != q.to.x && (d = d.concat(i), c.from = a.effects.setTransition(c, i, q.from.x, c.from), c.to = a.effects.setTransition(c, i, q.to.x, c.to)); (l == "content" || l == "both") && q.from.y != q.to.y && (d = d.concat(g), c.from = a.effects.setTransition(c, g, q.from.y, c.from), c.to = a.effects.setTransition(c, g, q.to.y, c.to)), a.effects.save(c, k ? d : e), c.show(), a.effects.createWrapper(c), c.css("overflow", "hidden").css(c.from); if (l == "content" || l == "both") h = h.concat(["marginTop", "marginBottom"]).concat(g), i = i.concat(["marginLeft", "marginRight"]), f = d.concat(h).concat(i), c.find("*[width]").each(function () { child = a(this), k && a.effects.save(child, f); var c = { height: child.height(), width: child.width() }; child.from = { height: c.height * q.from.y, width: c.width * q.from.x }, child.to = { height: c.height * q.to.y, width: c.width * q.to.x }, q.from.y != q.to.y && (child.from = a.effects.setTransition(child, h, q.from.y, child.from), child.to = a.effects.setTransition(child, h, q.to.y, child.to)), q.from.x != q.to.x && (child.from = a.effects.setTransition(child, i, q.from.x, child.from), child.to = a.effects.setTransition(child, i, q.to.x, child.to)), child.css(child.from), child.animate(child.to, b.duration, b.options.easing, function () { k && a.effects.restore(child, f) }) }); c.animate(c.to, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { c.to.opacity === 0 && c.css("opacity", c.from.opacity), j == "hide" && c.hide(), a.effects.restore(c, k ? d : e), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Shake 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Shake
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.shake = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right"], e = a.effects.setMode(c, b.options.mode || "effect"), f = b.options.direction || "left", g = b.options.distance || 20, h = b.options.times || 3, i = b.duration || b.options.duration || 140; a.effects.save(c, d), c.show(), a.effects.createWrapper(c); var j = f == "up" || f == "down" ? "top" : "left", k = f == "up" || f == "left" ? "pos" : "neg", l = {}, m = {}, n = {}; l[j] = (k == "pos" ? "-=" : "+=") + g, m[j] = (k == "pos" ? "+=" : "-=") + g * 2, n[j] = (k == "pos" ? "-=" : "+=") + g * 2, c.animate(l, i, b.options.easing); for (var p = 1; p < h; p++) c.animate(m, i, b.options.easing).animate(n, i, b.options.easing); c.animate(m, i, b.options.easing).animate(l, i / 2, b.options.easing, function () { a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments) }), c.queue("fx", function () { c.dequeue() }), c.dequeue() }) } })(jQuery); /*
* jQuery UI Effects Slide 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Slide
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.slide = function (b) { return this.queue(function () { var c = a(this), d = ["position", "top", "bottom", "left", "right"], e = a.effects.setMode(c, b.options.mode || "show"), f = b.options.direction || "left"; a.effects.save(c, d), c.show(), a.effects.createWrapper(c).css({ overflow: "hidden" }); var g = f == "up" || f == "down" ? "top" : "left", h = f == "up" || f == "left" ? "pos" : "neg", i = b.options.distance || (g == "top" ? c.outerHeight({ margin: !0 }) : c.outerWidth({ margin: !0 })); e == "show" && c.css(g, h == "pos" ? isNaN(i) ? "-" + i : -i : i); var j = {}; j[g] = (e == "show" ? h == "pos" ? "+=" : "-=" : h == "pos" ? "-=" : "+=") + i, c.animate(j, { queue: !1, duration: b.duration, easing: b.options.easing, complete: function () { e == "hide" && c.hide(), a.effects.restore(c, d), a.effects.removeWrapper(c), b.callback && b.callback.apply(this, arguments), c.dequeue() } }) }) } })(jQuery); /*
* jQuery UI Effects Transfer 1.8.17
*
* Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
* Dual licensed under the MIT or GPL Version 2 licenses.
* http://jquery.org/license
*
* http://docs.jquery.com/UI/Effects/Transfer
*
* Depends:
*	jquery.effects.core.js
*/
(function (a, b) { a.effects.transfer = function (b) { return this.queue(function () { var c = a(this), d = a(b.options.to), e = d.offset(), f = { top: e.top, left: e.left, height: d.innerHeight(), width: d.innerWidth() }, g = c.offset(), h = a('<div class="ui-effects-transfer"></div>').appendTo(document.body).addClass(b.options.className).css({ top: g.top, left: g.left, height: c.innerHeight(), width: c.innerWidth(), position: "absolute" }).animate(f, b.duration, b.options.easing, function () { h.remove(), b.callback && b.callback.apply(c[0], arguments), c.dequeue() }) }) } })(jQuery);

/**
* @version: 1.0 Alpha-1
* @author: Coolite Inc. http://www.coolite.com/
* @date: 2008-05-13
* @copyright: Copyright (c) 2006-2008, Coolite Inc. (http://www.coolite.com/). All rights reserved.
* @license: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
* @website: http://www.datejs.com/
*/
Date.CultureInfo = { name: "en-US", englishName: "English (United States)", nativeName: "English (United States)", dayNames: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], abbreviatedDayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], shortestDayNames: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], firstLetterDayNames: ["S", "M", "T", "W", "T", "F", "S"], monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], abbreviatedMonthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], amDesignator: "AM", pmDesignator: "PM", firstDayOfWeek: 0, twoDigitYearMax: 2029, dateElementOrder: "mdy", formatPatterns: { shortDate: "M/d/yyyy", longDate: "dddd, MMMM dd, yyyy", shortTime: "h:mm tt", longTime: "h:mm:ss tt", fullDateTime: "dddd, MMMM dd, yyyy h:mm:ss tt", sortableDateTime: "yyyy-MM-ddTHH:mm:ss", universalSortableDateTime: "yyyy-MM-dd HH:mm:ssZ", rfc1123: "ddd, dd MMM yyyy HH:mm:ss GMT", monthDay: "MMMM dd", yearMonth: "MMMM, yyyy" }, regexPatterns: { jan: /^jan(uary)?/i, feb: /^feb(ruary)?/i, mar: /^mar(ch)?/i, apr: /^apr(il)?/i, may: /^may/i, jun: /^jun(e)?/i, jul: /^jul(y)?/i, aug: /^aug(ust)?/i, sep: /^sep(t(ember)?)?/i, oct: /^oct(ober)?/i, nov: /^nov(ember)?/i, dec: /^dec(ember)?/i, sun: /^su(n(day)?)?/i, mon: /^mo(n(day)?)?/i, tue: /^tu(e(s(day)?)?)?/i, wed: /^we(d(nesday)?)?/i, thu: /^th(u(r(s(day)?)?)?)?/i, fri: /^fr(i(day)?)?/i, sat: /^sa(t(urday)?)?/i, future: /^next/i, past: /^last|past|prev(ious)?/i, add: /^(\+|aft(er)?|from|hence)/i, subtract: /^(\-|bef(ore)?|ago)/i, yesterday: /^yes(terday)?/i, today: /^t(od(ay)?)?/i, tomorrow: /^tom(orrow)?/i, now: /^n(ow)?/i, millisecond: /^ms|milli(second)?s?/i, second: /^sec(ond)?s?/i, minute: /^mn|min(ute)?s?/i, hour: /^h(our)?s?/i, week: /^w(eek)?s?/i, month: /^m(onth)?s?/i, day: /^d(ay)?s?/i, year: /^y(ear)?s?/i, shortMeridian: /^(a|p)/i, longMeridian: /^(a\.?m?\.?|p\.?m?\.?)/i, timezone: /^((e(s|d)t|c(s|d)t|m(s|d)t|p(s|d)t)|((gmt)?\s*(\+|\-)\s*\d\d\d\d?)|gmt|utc)/i, ordinalSuffix: /^\s*(st|nd|rd|th)/i, timeContext: /^\s*(\:|a(?!u|p)|p)/i }, timezones: [{ name: "UTC", offset: "-000" }, { name: "GMT", offset: "-000" }, { name: "EST", offset: "-0500" }, { name: "EDT", offset: "-0400" }, { name: "CST", offset: "-0600" }, { name: "CDT", offset: "-0500" }, { name: "MST", offset: "-0700" }, { name: "MDT", offset: "-0600" }, { name: "PST", offset: "-0800" }, { name: "PDT", offset: "-0700"}] };
(function () {
    var $D = Date, $P = $D.prototype, $C = $D.CultureInfo, p = function (s, l) {
        if (!l) { l = 2; }
        return ("000" + s).slice(l * -1);
    }; $P.clearTime = function () { this.setHours(0); this.setMinutes(0); this.setSeconds(0); this.setMilliseconds(0); return this; }; $P.setTimeToNow = function () { var n = new Date(); this.setHours(n.getHours()); this.setMinutes(n.getMinutes()); this.setSeconds(n.getSeconds()); this.setMilliseconds(n.getMilliseconds()); return this; }; $D.today = function () { return new Date().clearTime(); }; $D.compare = function (date1, date2) { if (isNaN(date1) || isNaN(date2)) { throw new Error(date1 + " - " + date2); } else if (date1 instanceof Date && date2 instanceof Date) { return (date1 < date2) ? -1 : (date1 > date2) ? 1 : 0; } else { throw new TypeError(date1 + " - " + date2); } }; $D.equals = function (date1, date2) { return (date1.compareTo(date2) === 0); }; $D.getDayNumberFromName = function (name) {
        var n = $C.dayNames, m = $C.abbreviatedDayNames, o = $C.shortestDayNames, s = name.toLowerCase(); for (var i = 0; i < n.length; i++) { if (n[i].toLowerCase() == s || m[i].toLowerCase() == s || o[i].toLowerCase() == s) { return i; } }
        return -1;
    }; $D.getMonthNumberFromName = function (name) {
        var n = $C.monthNames, m = $C.abbreviatedMonthNames, s = name.toLowerCase(); for (var i = 0; i < n.length; i++) { if (n[i].toLowerCase() == s || m[i].toLowerCase() == s) { return i; } }
        return -1;
    }; $D.isLeapYear = function (year) { return ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0); }; $D.getDaysInMonth = function (year, month) { return [31, ($D.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]; }; $D.getTimezoneAbbreviation = function (offset) {
        var z = $C.timezones, p; for (var i = 0; i < z.length; i++) { if (z[i].offset === offset) { return z[i].name; } }
        return null;
    }; $D.getTimezoneOffset = function (name) {
        var z = $C.timezones, p; for (var i = 0; i < z.length; i++) { if (z[i].name === name.toUpperCase()) { return z[i].offset; } }
        return null;
    }; $P.clone = function () { return new Date(this.getTime()); }; $P.compareTo = function (date) { return Date.compare(this, date); }; $P.equals = function (date) { return Date.equals(this, date || new Date()); }; $P.between = function (start, end) { return this.getTime() >= start.getTime() && this.getTime() <= end.getTime(); }; $P.isAfter = function (date) { return this.compareTo(date || new Date()) === 1; }; $P.isBefore = function (date) { return (this.compareTo(date || new Date()) === -1); }; $P.isToday = function () { return this.isSameDay(new Date()); }; $P.isSameDay = function (date) { return this.clone().clearTime().equals(date.clone().clearTime()); }; $P.addMilliseconds = function (value) { this.setMilliseconds(this.getMilliseconds() + value); return this; }; $P.addSeconds = function (value) { return this.addMilliseconds(value * 1000); }; $P.addMinutes = function (value) { return this.addMilliseconds(value * 60000); }; $P.addHours = function (value) { return this.addMilliseconds(value * 3600000); }; $P.addDays = function (value) { this.setDate(this.getDate() + value); return this; }; $P.addWeeks = function (value) { return this.addDays(value * 7); }; $P.addMonths = function (value) { var n = this.getDate(); this.setDate(1); this.setMonth(this.getMonth() + value); this.setDate(Math.min(n, $D.getDaysInMonth(this.getFullYear(), this.getMonth()))); return this; }; $P.addYears = function (value) { return this.addMonths(value * 12); }; $P.add = function (config) {
        if (typeof config == "number") { this._orient = config; return this; }
        var x = config; if (x.milliseconds) { this.addMilliseconds(x.milliseconds); }
        if (x.seconds) { this.addSeconds(x.seconds); }
        if (x.minutes) { this.addMinutes(x.minutes); }
        if (x.hours) { this.addHours(x.hours); }
        if (x.weeks) { this.addWeeks(x.weeks); }
        if (x.months) { this.addMonths(x.months); }
        if (x.years) { this.addYears(x.years); }
        if (x.days) { this.addDays(x.days); }
        return this;
    }; var $y, $m, $d; $P.getWeek = function () {
        var a, b, c, d, e, f, g, n, s, w; $y = (!$y) ? this.getFullYear() : $y; $m = (!$m) ? this.getMonth() + 1 : $m; $d = (!$d) ? this.getDate() : $d; if ($m <= 2) { a = $y - 1; b = (a / 4 | 0) - (a / 100 | 0) + (a / 400 | 0); c = ((a - 1) / 4 | 0) - ((a - 1) / 100 | 0) + ((a - 1) / 400 | 0); s = b - c; e = 0; f = $d - 1 + (31 * ($m - 1)); } else { a = $y; b = (a / 4 | 0) - (a / 100 | 0) + (a / 400 | 0); c = ((a - 1) / 4 | 0) - ((a - 1) / 100 | 0) + ((a - 1) / 400 | 0); s = b - c; e = s + 1; f = $d + ((153 * ($m - 3) + 2) / 5) + 58 + s; }
        g = (a + b) % 7; d = (f + g - e) % 7; n = (f + 3 - d) | 0; if (n < 0) { w = 53 - ((g - s) / 5 | 0); } else if (n > 364 + s) { w = 1; } else { w = (n / 7 | 0) + 1; }
        $y = $m = $d = null; return w;
    }; $P.getISOWeek = function () { $y = this.getUTCFullYear(); $m = this.getUTCMonth() + 1; $d = this.getUTCDate(); return p(this.getWeek()); }; $P.setWeek = function (n) { return this.moveToDayOfWeek(1).addWeeks(n - this.getWeek()); }; $D._validate = function (n, min, max, name) {
        if (typeof n == "undefined") { return false; } else if (typeof n != "number") { throw new TypeError(n + " is not a Number."); } else if (n < min || n > max) { throw new RangeError(n + " is not a valid value for " + name + "."); }
        return true;
    }; $D.validateMillisecond = function (value) { return $D._validate(value, 0, 999, "millisecond"); }; $D.validateSecond = function (value) { return $D._validate(value, 0, 59, "second"); }; $D.validateMinute = function (value) { return $D._validate(value, 0, 59, "minute"); }; $D.validateHour = function (value) { return $D._validate(value, 0, 23, "hour"); }; $D.validateDay = function (value, year, month) { return $D._validate(value, 1, $D.getDaysInMonth(year, month), "day"); }; $D.validateMonth = function (value) { return $D._validate(value, 0, 11, "month"); }; $D.validateYear = function (value) { return $D._validate(value, 0, 9999, "year"); }; $P.set = function (config) {
        if ($D.validateMillisecond(config.millisecond)) { this.addMilliseconds(config.millisecond - this.getMilliseconds()); }
        if ($D.validateSecond(config.second)) { this.addSeconds(config.second - this.getSeconds()); }
        if ($D.validateMinute(config.minute)) { this.addMinutes(config.minute - this.getMinutes()); }
        if ($D.validateHour(config.hour)) { this.addHours(config.hour - this.getHours()); }
        if ($D.validateMonth(config.month)) { this.addMonths(config.month - this.getMonth()); }
        if ($D.validateYear(config.year)) { this.addYears(config.year - this.getFullYear()); }
        if ($D.validateDay(config.day, this.getFullYear(), this.getMonth())) { this.addDays(config.day - this.getDate()); }
        if (config.timezone) { this.setTimezone(config.timezone); }
        if (config.timezoneOffset) { this.setTimezoneOffset(config.timezoneOffset); }
        if (config.week && $D._validate(config.week, 0, 53, "week")) { this.setWeek(config.week); }
        return this;
    }; $P.moveToFirstDayOfMonth = function () { return this.set({ day: 1 }); }; $P.moveToLastDayOfMonth = function () { return this.set({ day: $D.getDaysInMonth(this.getFullYear(), this.getMonth()) }); }; $P.moveToNthOccurrence = function (dayOfWeek, occurrence) {
        var shift = 0; if (occurrence > 0) { shift = occurrence - 1; }
        else if (occurrence === -1) {
            this.moveToLastDayOfMonth(); if (this.getDay() !== dayOfWeek) { this.moveToDayOfWeek(dayOfWeek, -1); }
            return this;
        }
        return this.moveToFirstDayOfMonth().addDays(-1).moveToDayOfWeek(dayOfWeek, +1).addWeeks(shift);
    }; $P.moveToDayOfWeek = function (dayOfWeek, orient) { var diff = (dayOfWeek - this.getDay() + 7 * (orient || +1)) % 7; return this.addDays((diff === 0) ? diff += 7 * (orient || +1) : diff); }; $P.moveToMonth = function (month, orient) { var diff = (month - this.getMonth() + 12 * (orient || +1)) % 12; return this.addMonths((diff === 0) ? diff += 12 * (orient || +1) : diff); }; $P.getOrdinalNumber = function () { return Math.ceil((this.clone().clearTime() - new Date(this.getFullYear(), 0, 1)) / 86400000) + 1; }; $P.getTimezone = function () { return $D.getTimezoneAbbreviation(this.getUTCOffset()); }; $P.setTimezoneOffset = function (offset) { var here = this.getTimezoneOffset(), there = Number(offset) * -6 / 10; return this.addMinutes(there - here); }; $P.setTimezone = function (offset) { return this.setTimezoneOffset($D.getTimezoneOffset(offset)); }; $P.hasDaylightSavingTime = function () { return (Date.today().set({ month: 0, day: 1 }).getTimezoneOffset() !== Date.today().set({ month: 6, day: 1 }).getTimezoneOffset()); }; $P.isDaylightSavingTime = function () { return (this.hasDaylightSavingTime() && new Date().getTimezoneOffset() === Date.today().set({ month: 6, day: 1 }).getTimezoneOffset()); }; $P.getUTCOffset = function () { var n = this.getTimezoneOffset() * -10 / 6, r; if (n < 0) { r = (n - 10000).toString(); return r.charAt(0) + r.substr(2); } else { r = (n + 10000).toString(); return "+" + r.substr(1); } }; $P.getElapsed = function (date) { return (date || new Date()) - this; }; if (!$P.toISOString) {
        $P.toISOString = function () {
            function f(n) { return n < 10 ? '0' + n : n; }
            return '"' + this.getUTCFullYear() + '-' +
f(this.getUTCMonth() + 1) + '-' +
f(this.getUTCDate()) + 'T' +
f(this.getUTCHours()) + ':' +
f(this.getUTCMinutes()) + ':' +
f(this.getUTCSeconds()) + 'Z"';
        };
    }
    $P._toString = $P.toString; $P.toString = function (format) {
        var x = this; if (format && format.length == 1) { var c = $C.formatPatterns; x.t = x.toString; switch (format) { case "d": return x.t(c.shortDate); case "D": return x.t(c.longDate); case "F": return x.t(c.fullDateTime); case "m": return x.t(c.monthDay); case "r": return x.t(c.rfc1123); case "s": return x.t(c.sortableDateTime); case "t": return x.t(c.shortTime); case "T": return x.t(c.longTime); case "u": return x.t(c.universalSortableDateTime); case "y": return x.t(c.yearMonth); } }
        var ord = function (n) { switch (n * 1) { case 1: case 21: case 31: return "st"; case 2: case 22: return "nd"; case 3: case 23: return "rd"; default: return "th"; } }; return format ? format.replace(/(\\)?(dd?d?d?|MM?M?M?|yy?y?y?|hh?|HH?|mm?|ss?|tt?|S)/g, function (m) {
            if (m.charAt(0) === "\\") { return m.replace("\\", ""); }
            x.h = x.getHours; switch (m) { case "hh": return p(x.h() < 13 ? (x.h() === 0 ? 12 : x.h()) : (x.h() - 12)); case "h": return x.h() < 13 ? (x.h() === 0 ? 12 : x.h()) : (x.h() - 12); case "HH": return p(x.h()); case "H": return x.h(); case "mm": return p(x.getMinutes()); case "m": return x.getMinutes(); case "ss": return p(x.getSeconds()); case "s": return x.getSeconds(); case "yyyy": return p(x.getFullYear(), 4); case "yy": return p(x.getFullYear()); case "dddd": return $C.dayNames[x.getDay()]; case "ddd": return $C.abbreviatedDayNames[x.getDay()]; case "dd": return p(x.getDate()); case "d": return x.getDate(); case "MMMM": return $C.monthNames[x.getMonth()]; case "MMM": return $C.abbreviatedMonthNames[x.getMonth()]; case "MM": return p((x.getMonth() + 1)); case "M": return x.getMonth() + 1; case "t": return x.h() < 12 ? $C.amDesignator.substring(0, 1) : $C.pmDesignator.substring(0, 1); case "tt": return x.h() < 12 ? $C.amDesignator : $C.pmDesignator; case "S": return ord(x.getDate()); default: return m; }
        }) : this._toString();
    };
} ());
(function () {
    var $D = Date, $P = $D.prototype, $C = $D.CultureInfo, $N = Number.prototype; $P._orient = +1; $P._nth = null; $P._is = false; $P._same = false; $P._isSecond = false; $N._dateElement = "day"; $P.next = function () { this._orient = +1; return this; }; $D.next = function () { return $D.today().next(); }; $P.last = $P.prev = $P.previous = function () { this._orient = -1; return this; }; $D.last = $D.prev = $D.previous = function () { return $D.today().last(); }; $P.is = function () { this._is = true; return this; }; $P.same = function () { this._same = true; this._isSecond = false; return this; }; $P.today = function () { return this.same().day(); }; $P.weekday = function () {
        if (this._is) { this._is = false; return (!this.is().sat() && !this.is().sun()); }
        return false;
    }; $P.at = function (time) { return (typeof time === "string") ? $D.parse(this.toString("d") + " " + time) : this.set(time); }; $N.fromNow = $N.after = function (date) { var c = {}; c[this._dateElement] = this; return ((!date) ? new Date() : date.clone()).add(c); }; $N.ago = $N.before = function (date) { var c = {}; c[this._dateElement] = this * -1; return ((!date) ? new Date() : date.clone()).add(c); }; var dx = ("sunday monday tuesday wednesday thursday friday saturday").split(/\s/), mx = ("january february march april may june july august september october november december").split(/\s/), px = ("Millisecond Second Minute Hour Day Week Month Year").split(/\s/), pxf = ("Milliseconds Seconds Minutes Hours Date Week Month FullYear").split(/\s/), nth = ("final first second third fourth fifth").split(/\s/), de; $P.toObject = function () {
        var o = {}; for (var i = 0; i < px.length; i++) { o[px[i].toLowerCase()] = this["get" + pxf[i]](); }
        return o;
    }; $D.fromObject = function (config) { config.week = null; return Date.today().set(config); }; var df = function (n) {
        return function () {
            if (this._is) { this._is = false; return this.getDay() == n; }
            if (this._nth !== null) {
                if (this._isSecond) { this.addSeconds(this._orient * -1); }
                this._isSecond = false; var ntemp = this._nth; this._nth = null; var temp = this.clone().moveToLastDayOfMonth(); this.moveToNthOccurrence(n, ntemp); if (this > temp) { throw new RangeError($D.getDayName(n) + " does not occur " + ntemp + " times in the month of " + $D.getMonthName(temp.getMonth()) + " " + temp.getFullYear() + "."); }
                return this;
            }
            return this.moveToDayOfWeek(n, this._orient);
        };
    }; var sdf = function (n) {
        return function () {
            var t = $D.today(), shift = n - t.getDay(); if (n === 0 && $C.firstDayOfWeek === 1 && t.getDay() !== 0) { shift = shift + 7; }
            return t.addDays(shift);
        };
    }; for (var i = 0; i < dx.length; i++) { $D[dx[i].toUpperCase()] = $D[dx[i].toUpperCase().substring(0, 3)] = i; $D[dx[i]] = $D[dx[i].substring(0, 3)] = sdf(i); $P[dx[i]] = $P[dx[i].substring(0, 3)] = df(i); }
    var mf = function (n) {
        return function () {
            if (this._is) { this._is = false; return this.getMonth() === n; }
            return this.moveToMonth(n, this._orient);
        };
    }; var smf = function (n) { return function () { return $D.today().set({ month: n, day: 1 }); }; }; for (var j = 0; j < mx.length; j++) { $D[mx[j].toUpperCase()] = $D[mx[j].toUpperCase().substring(0, 3)] = j; $D[mx[j]] = $D[mx[j].substring(0, 3)] = smf(j); $P[mx[j]] = $P[mx[j].substring(0, 3)] = mf(j); }
    var ef = function (j) {
        return function () {
            if (this._isSecond) { this._isSecond = false; return this; }
            if (this._same) {
                this._same = this._is = false; var o1 = this.toObject(), o2 = (arguments[0] || new Date()).toObject(), v = "", k = j.toLowerCase(); for (var m = (px.length - 1); m > -1; m--) {
                    v = px[m].toLowerCase(); if (o1[v] != o2[v]) { return false; }
                    if (k == v) { break; }
                }
                return true;
            }
            if (j.substring(j.length - 1) != "s") { j += "s"; }
            return this["add" + j](this._orient);
        };
    }; var nf = function (n) { return function () { this._dateElement = n; return this; }; }; for (var k = 0; k < px.length; k++) { de = px[k].toLowerCase(); $P[de] = $P[de + "s"] = ef(px[k]); $N[de] = $N[de + "s"] = nf(de); }
    $P._ss = ef("Second"); var nthfn = function (n) {
        return function (dayOfWeek) {
            if (this._same) { return this._ss(arguments[0]); }
            if (dayOfWeek || dayOfWeek === 0) { return this.moveToNthOccurrence(dayOfWeek, n); }
            this._nth = n; if (n === 2 && (dayOfWeek === undefined || dayOfWeek === null)) { this._isSecond = true; return this.addSeconds(this._orient); }
            return this;
        };
    }; for (var l = 0; l < nth.length; l++) { $P[nth[l]] = (l === 0) ? nthfn(-1) : nthfn(l); }
} ());
(function () {
    Date.Parsing = { Exception: function (s) { this.message = "Parse error at '" + s.substring(0, 10) + " ...'"; } }; var $P = Date.Parsing; var _ = $P.Operators = { rtoken: function (r) { return function (s) { var mx = s.match(r); if (mx) { return ([mx[0], s.substring(mx[0].length)]); } else { throw new $P.Exception(s); } }; }, token: function (s) { return function (s) { return _.rtoken(new RegExp("^\s*" + s + "\s*"))(s); }; }, stoken: function (s) { return _.rtoken(new RegExp("^" + s)); }, until: function (p) {
        return function (s) {
            var qx = [], rx = null; while (s.length) {
                try { rx = p.call(this, s); } catch (e) { qx.push(rx[0]); s = rx[1]; continue; }
                break;
            }
            return [qx, s];
        };
    }, many: function (p) {
        return function (s) {
            var rx = [], r = null; while (s.length) {
                try { r = p.call(this, s); } catch (e) { return [rx, s]; }
                rx.push(r[0]); s = r[1];
            }
            return [rx, s];
        };
    }, optional: function (p) {
        return function (s) {
            var r = null; try { r = p.call(this, s); } catch (e) { return [null, s]; }
            return [r[0], r[1]];
        };
    }, not: function (p) {
        return function (s) {
            try { p.call(this, s); } catch (e) { return [null, s]; }
            throw new $P.Exception(s);
        };
    }, ignore: function (p) { return p ? function (s) { var r = null; r = p.call(this, s); return [null, r[1]]; } : null; }, product: function () {
        var px = arguments[0], qx = Array.prototype.slice.call(arguments, 1), rx = []; for (var i = 0; i < px.length; i++) { rx.push(_.each(px[i], qx)); }
        return rx;
    }, cache: function (rule) {
        var cache = {}, r = null; return function (s) {
            try { r = cache[s] = (cache[s] || rule.call(this, s)); } catch (e) { r = cache[s] = e; }
            if (r instanceof $P.Exception) { throw r; } else { return r; }
        };
    }, any: function () {
        var px = arguments; return function (s) {
            var r = null; for (var i = 0; i < px.length; i++) {
                if (px[i] == null) { continue; }
                try { r = (px[i].call(this, s)); } catch (e) { r = null; }
                if (r) { return r; }
            }
            throw new $P.Exception(s);
        };
    }, each: function () {
        var px = arguments; return function (s) {
            var rx = [], r = null; for (var i = 0; i < px.length; i++) {
                if (px[i] == null) { continue; }
                try { r = (px[i].call(this, s)); } catch (e) { throw new $P.Exception(s); }
                rx.push(r[0]); s = r[1];
            }
            return [rx, s];
        };
    }, all: function () { var px = arguments, _ = _; return _.each(_.optional(px)); }, sequence: function (px, d, c) {
        d = d || _.rtoken(/^\s*/); c = c || null; if (px.length == 1) { return px[0]; }
        return function (s) {
            var r = null, q = null; var rx = []; for (var i = 0; i < px.length; i++) {
                try { r = px[i].call(this, s); } catch (e) { break; }
                rx.push(r[0]); try { q = d.call(this, r[1]); } catch (ex) { q = null; break; }
                s = q[1];
            }
            if (!r) { throw new $P.Exception(s); }
            if (q) { throw new $P.Exception(q[1]); }
            if (c) { try { r = c.call(this, r[1]); } catch (ey) { throw new $P.Exception(r[1]); } }
            return [rx, (r ? r[1] : s)];
        };
    }, between: function (d1, p, d2) { d2 = d2 || d1; var _fn = _.each(_.ignore(d1), p, _.ignore(d2)); return function (s) { var rx = _fn.call(this, s); return [[rx[0][0], r[0][2]], rx[1]]; }; }, list: function (p, d, c) { d = d || _.rtoken(/^\s*/); c = c || null; return (p instanceof Array ? _.each(_.product(p.slice(0, -1), _.ignore(d)), p.slice(-1), _.ignore(c)) : _.each(_.many(_.each(p, _.ignore(d))), px, _.ignore(c))); }, set: function (px, d, c) {
        d = d || _.rtoken(/^\s*/); c = c || null; return function (s) {
            var r = null, p = null, q = null, rx = null, best = [[], s], last = false; for (var i = 0; i < px.length; i++) {
                q = null; p = null; r = null; last = (px.length == 1); try { r = px[i].call(this, s); } catch (e) { continue; }
                rx = [[r[0]], r[1]]; if (r[1].length > 0 && !last) { try { q = d.call(this, r[1]); } catch (ex) { last = true; } } else { last = true; }
                if (!last && q[1].length === 0) { last = true; }
                if (!last) {
                    var qx = []; for (var j = 0; j < px.length; j++) { if (i != j) { qx.push(px[j]); } }
                    p = _.set(qx, d).call(this, q[1]); if (p[0].length > 0) { rx[0] = rx[0].concat(p[0]); rx[1] = p[1]; }
                }
                if (rx[1].length < best[1].length) { best = rx; }
                if (best[1].length === 0) { break; }
            }
            if (best[0].length === 0) { return best; }
            if (c) {
                try { q = c.call(this, best[1]); } catch (ey) { throw new $P.Exception(best[1]); }
                best[1] = q[1];
            }
            return best;
        };
    }, forward: function (gr, fname) { return function (s) { return gr[fname].call(this, s); }; }, replace: function (rule, repl) { return function (s) { var r = rule.call(this, s); return [repl, r[1]]; }; }, process: function (rule, fn) { return function (s) { var r = rule.call(this, s); return [fn.call(this, r[0]), r[1]]; }; }, min: function (min, rule) {
        return function (s) {
            var rx = rule.call(this, s); if (rx[0].length < min) { throw new $P.Exception(s); }
            return rx;
        };
    }
    }; var _generator = function (op) {
        return function () {
            var args = null, rx = []; if (arguments.length > 1) { args = Array.prototype.slice.call(arguments); } else if (arguments[0] instanceof Array) { args = arguments[0]; }
            if (args) { for (var i = 0, px = args.shift(); i < px.length; i++) { args.unshift(px[i]); rx.push(op.apply(null, args)); args.shift(); return rx; } } else { return op.apply(null, arguments); }
        };
    }; var gx = "optional not ignore cache".split(/\s/); for (var i = 0; i < gx.length; i++) { _[gx[i]] = _generator(_[gx[i]]); }
    var _vector = function (op) { return function () { if (arguments[0] instanceof Array) { return op.apply(null, arguments[0]); } else { return op.apply(null, arguments); } }; }; var vx = "each any all".split(/\s/); for (var j = 0; j < vx.length; j++) { _[vx[j]] = _vector(_[vx[j]]); }
} ()); (function () {
    var $D = Date, $P = $D.prototype, $C = $D.CultureInfo; var flattenAndCompact = function (ax) {
        var rx = []; for (var i = 0; i < ax.length; i++) { if (ax[i] instanceof Array) { rx = rx.concat(flattenAndCompact(ax[i])); } else { if (ax[i]) { rx.push(ax[i]); } } }
        return rx;
    }; $D.Grammar = {}; $D.Translator = { hour: function (s) { return function () { this.hour = Number(s); }; }, minute: function (s) { return function () { this.minute = Number(s); }; }, second: function (s) { return function () { this.second = Number(s); }; }, meridian: function (s) { return function () { this.meridian = s.slice(0, 1).toLowerCase(); }; }, timezone: function (s) { return function () { var n = s.replace(/[^\d\+\-]/g, ""); if (n.length) { this.timezoneOffset = Number(n); } else { this.timezone = s.toLowerCase(); } }; }, day: function (x) { var s = x[0]; return function () { this.day = Number(s.match(/\d+/)[0]); }; }, month: function (s) { return function () { this.month = (s.length == 3) ? "jan feb mar apr may jun jul aug sep oct nov dec".indexOf(s) / 4 : Number(s) - 1; }; }, year: function (s) { return function () { var n = Number(s); this.year = ((s.length > 2) ? n : (n + (((n + 2000) < $C.twoDigitYearMax) ? 2000 : 1900))); }; }, rday: function (s) { return function () { switch (s) { case "yesterday": this.days = -1; break; case "tomorrow": this.days = 1; break; case "today": this.days = 0; break; case "now": this.days = 0; this.now = true; break; } }; }, finishExact: function (x) {
        x = (x instanceof Array) ? x : [x]; for (var i = 0; i < x.length; i++) { if (x[i]) { x[i].call(this); } }
        var now = new Date(); if ((this.hour || this.minute) && (!this.month && !this.year && !this.day)) { this.day = now.getDate(); }
        if (!this.year) { this.year = now.getFullYear(); }
        if (!this.month && this.month !== 0) { this.month = now.getMonth(); }
        if (!this.day) { this.day = 1; }
        if (!this.hour) { this.hour = 0; }
        if (!this.minute) { this.minute = 0; }
        if (!this.second) { this.second = 0; }
        if (this.meridian && this.hour) { if (this.meridian == "p" && this.hour < 12) { this.hour = this.hour + 12; } else if (this.meridian == "a" && this.hour == 12) { this.hour = 0; } }
        if (this.day > $D.getDaysInMonth(this.year, this.month)) { throw new RangeError(this.day + " is not a valid value for days."); }
        var r = new Date(this.year, this.month, this.day, this.hour, this.minute, this.second); if (this.timezone) { r.set({ timezone: this.timezone }); } else if (this.timezoneOffset) { r.set({ timezoneOffset: this.timezoneOffset }); }
        return r;
    }, finish: function (x) {
        x = (x instanceof Array) ? flattenAndCompact(x) : [x]; if (x.length === 0) { return null; }
        for (var i = 0; i < x.length; i++) { if (typeof x[i] == "function") { x[i].call(this); } }
        var today = $D.today(); if (this.now && !this.unit && !this.operator) { return new Date(); } else if (this.now) { today = new Date(); }
        var expression = !!(this.days && this.days !== null || this.orient || this.operator); var gap, mod, orient; orient = ((this.orient == "past" || this.operator == "subtract") ? -1 : 1); if (!this.now && "hour minute second".indexOf(this.unit) != -1) { today.setTimeToNow(); }
        if (this.month || this.month === 0) { if ("year day hour minute second".indexOf(this.unit) != -1) { this.value = this.month + 1; this.month = null; expression = true; } }
        if (!expression && this.weekday && !this.day && !this.days) {
            var temp = Date[this.weekday](); this.day = temp.getDate(); if (!this.month) { this.month = temp.getMonth(); }
            this.year = temp.getFullYear();
        }
        if (expression && this.weekday && this.unit != "month") { this.unit = "day"; gap = ($D.getDayNumberFromName(this.weekday) - today.getDay()); mod = 7; this.days = gap ? ((gap + (orient * mod)) % mod) : (orient * mod); }
        if (this.month && this.unit == "day" && this.operator) { this.value = (this.month + 1); this.month = null; }
        if (this.value != null && this.month != null && this.year != null) { this.day = this.value * 1; }
        if (this.month && !this.day && this.value) { today.set({ day: this.value * 1 }); if (!expression) { this.day = this.value * 1; } }
        if (!this.month && this.value && this.unit == "month" && !this.now) { this.month = this.value; expression = true; }
        if (expression && (this.month || this.month === 0) && this.unit != "year") { this.unit = "month"; gap = (this.month - today.getMonth()); mod = 12; this.months = gap ? ((gap + (orient * mod)) % mod) : (orient * mod); this.month = null; }
        if (!this.unit) { this.unit = "day"; }
        if (!this.value && this.operator && this.operator !== null && this[this.unit + "s"] && this[this.unit + "s"] !== null) { this[this.unit + "s"] = this[this.unit + "s"] + ((this.operator == "add") ? 1 : -1) + (this.value || 0) * orient; } else if (this[this.unit + "s"] == null || this.operator != null) {
            if (!this.value) { this.value = 1; }
            this[this.unit + "s"] = this.value * orient;
        }
        if (this.meridian && this.hour) { if (this.meridian == "p" && this.hour < 12) { this.hour = this.hour + 12; } else if (this.meridian == "a" && this.hour == 12) { this.hour = 0; } }
        if (this.weekday && !this.day && !this.days) { var temp = Date[this.weekday](); this.day = temp.getDate(); if (temp.getMonth() !== today.getMonth()) { this.month = temp.getMonth(); } }
        if ((this.month || this.month === 0) && !this.day) { this.day = 1; }
        if (!this.orient && !this.operator && this.unit == "week" && this.value && !this.day && !this.month) { return Date.today().setWeek(this.value); }
        if (expression && this.timezone && this.day && this.days) { this.day = this.days; }
        return (expression) ? today.add(this) : today.set(this);
    }
    }; var _ = $D.Parsing.Operators, g = $D.Grammar, t = $D.Translator, _fn; g.datePartDelimiter = _.rtoken(/^([\s\-\.\,\/\x27]+)/); g.timePartDelimiter = _.stoken(":"); g.whiteSpace = _.rtoken(/^\s*/); g.generalDelimiter = _.rtoken(/^(([\s\,]|at|@|on)+)/); var _C = {}; g.ctoken = function (keys) {
        var fn = _C[keys]; if (!fn) {
            var c = $C.regexPatterns; var kx = keys.split(/\s+/), px = []; for (var i = 0; i < kx.length; i++) { px.push(_.replace(_.rtoken(c[kx[i]]), kx[i])); }
            fn = _C[keys] = _.any.apply(null, px);
        }
        return fn;
    }; g.ctoken2 = function (key) { return _.rtoken($C.regexPatterns[key]); }; g.h = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2]|[1-9])/), t.hour)); g.hh = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2])/), t.hour)); g.H = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3]|[0-9])/), t.hour)); g.HH = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3])/), t.hour)); g.m = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), t.minute)); g.mm = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), t.minute)); g.s = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), t.second)); g.ss = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), t.second)); g.hms = _.cache(_.sequence([g.H, g.m, g.s], g.timePartDelimiter)); g.t = _.cache(_.process(g.ctoken2("shortMeridian"), t.meridian)); g.tt = _.cache(_.process(g.ctoken2("longMeridian"), t.meridian)); g.z = _.cache(_.process(_.rtoken(/^((\+|\-)\s*\d\d\d\d)|((\+|\-)\d\d\:?\d\d)/), t.timezone)); g.zz = _.cache(_.process(_.rtoken(/^((\+|\-)\s*\d\d\d\d)|((\+|\-)\d\d\:?\d\d)/), t.timezone)); g.zzz = _.cache(_.process(g.ctoken2("timezone"), t.timezone)); g.timeSuffix = _.each(_.ignore(g.whiteSpace), _.set([g.tt, g.zzz])); g.time = _.each(_.optional(_.ignore(_.stoken("T"))), g.hms, g.timeSuffix); g.d = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1]|\d)/), _.optional(g.ctoken2("ordinalSuffix"))), t.day)); g.dd = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1])/), _.optional(g.ctoken2("ordinalSuffix"))), t.day)); g.ddd = g.dddd = _.cache(_.process(g.ctoken("sun mon tue wed thu fri sat"), function (s) { return function () { this.weekday = s; }; })); g.M = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d|\d)/), t.month)); g.MM = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d)/), t.month)); g.MMM = g.MMMM = _.cache(_.process(g.ctoken("jan feb mar apr may jun jul aug sep oct nov dec"), t.month)); g.y = _.cache(_.process(_.rtoken(/^(\d\d?)/), t.year)); g.yy = _.cache(_.process(_.rtoken(/^(\d\d)/), t.year)); g.yyy = _.cache(_.process(_.rtoken(/^(\d\d?\d?\d?)/), t.year)); g.yyyy = _.cache(_.process(_.rtoken(/^(\d\d\d\d)/), t.year)); _fn = function () { return _.each(_.any.apply(null, arguments), _.not(g.ctoken2("timeContext"))); }; g.day = _fn(g.d, g.dd); g.month = _fn(g.M, g.MMM); g.year = _fn(g.yyyy, g.yy); g.orientation = _.process(g.ctoken("past future"), function (s) { return function () { this.orient = s; }; }); g.operator = _.process(g.ctoken("add subtract"), function (s) { return function () { this.operator = s; }; }); g.rday = _.process(g.ctoken("yesterday tomorrow today now"), t.rday); g.unit = _.process(g.ctoken("second minute hour day week month year"), function (s) { return function () { this.unit = s; }; }); g.value = _.process(_.rtoken(/^\d\d?(st|nd|rd|th)?/), function (s) { return function () { this.value = s.replace(/\D/g, ""); }; }); g.expression = _.set([g.rday, g.operator, g.value, g.unit, g.orientation, g.ddd, g.MMM]); _fn = function () { return _.set(arguments, g.datePartDelimiter); }; g.mdy = _fn(g.ddd, g.month, g.day, g.year); g.ymd = _fn(g.ddd, g.year, g.month, g.day); g.dmy = _fn(g.ddd, g.day, g.month, g.year); g.date = function (s) { return ((g[$C.dateElementOrder] || g.mdy).call(this, s)); }; g.format = _.process(_.many(_.any(_.process(_.rtoken(/^(dd?d?d?|MM?M?M?|yy?y?y?|hh?|HH?|mm?|ss?|tt?|zz?z?)/), function (fmt) { if (g[fmt]) { return g[fmt]; } else { throw $D.Parsing.Exception(fmt); } }), _.process(_.rtoken(/^[^dMyhHmstz]+/), function (s) { return _.ignore(_.stoken(s)); }))), function (rules) { return _.process(_.each.apply(null, rules), t.finishExact); }); var _F = {}; var _get = function (f) { return _F[f] = (_F[f] || g.format(f)[0]); }; g.formats = function (fx) {
        if (fx instanceof Array) {
            var rx = []; for (var i = 0; i < fx.length; i++) { rx.push(_get(fx[i])); }
            return _.any.apply(null, rx);
        } else { return _get(fx); }
    }; g._formats = g.formats(["\"yyyy-MM-ddTHH:mm:ssZ\"", "yyyy-MM-ddTHH:mm:ssZ", "yyyy-MM-ddTHH:mm:ssz", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mmZ", "yyyy-MM-ddTHH:mmz", "yyyy-MM-ddTHH:mm", "ddd, MMM dd, yyyy H:mm:ss tt", "ddd MMM d yyyy HH:mm:ss zzz", "MMddyyyy", "ddMMyyyy", "Mddyyyy", "ddMyyyy", "Mdyyyy", "dMyyyy", "yyyy", "Mdyy", "dMyy", "d"]); g._start = _.process(_.set([g.date, g.time, g.expression], g.generalDelimiter, g.whiteSpace), t.finish); g.start = function (s) {
        try { var r = g._formats.call({}, s); if (r[1].length === 0) { return r; } } catch (e) { }
        return g._start.call({}, s);
    }; $D._parse = $D.parse; $D.parse = function (s) {
        var r = null; if (!s) { return null; }
        if (s instanceof Date) { return s; }
        try { r = $D.Grammar.start.call({}, s.replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1")); } catch (e) { return null; }
        return ((r[1].length === 0) ? r[0] : null);
    }; $D.getParseFunction = function (fx) {
        var fn = $D.Grammar.formats(fx); return function (s) {
            var r = null; try { r = fn.call({}, s); } catch (e) { return null; }
            return ((r[1].length === 0) ? r[0] : null);
        };
    }; $D.parseExact = function (s, fx) { return $D.getParseFunction(fx)(s); };
} ());
/*New context menu*/
/*
* jQuery contextMenu - Plugin for simple contextMenu handling
*
* Version: 1.5.10
*
* Authors: Rodney Rehm, Addy Osmani (patches for FF)
* Web: http://medialize.github.com/jQuery-contextMenu/
*
* Licensed under
*   MIT License http://www.opensource.org/licenses/mit-license
*   GPL v3 http://opensource.org/licenses/GPL-3.0
*
*/

(function ($, undefined) {

    // TODO: -
    // ARIA stuff: menuitem, menuitemcheckbox und menuitemradio
    // create <menu> structure if $.support[htmlCommand || htmlMenuitem] and !opt.disableNative

    // determine html5 compatibility
    $.support.htmlMenuitem = ('HTMLMenuItemElement' in window);
    $.support.htmlCommand = ('HTMLCommandElement' in window);

    var // currently active contextMenu trigger
$currentTrigger = null,
    // is contextMenu initialized with at least one menu?
initialized = false,
    // flag stating to ignore the contextmenu event
ignoreThisClick = false,
    // window handle
$win = $(window),
    // number of registered menus
counter = 0,
    // mapping selector to namespace
namespaces = {},
    // mapping namespace to options
menus = {},
    // custom command type handlers
types = {},
    // default values
defaults = {
    // selector of contextMenu trigger
    selector: null,
    // where to append the menu to
    appendTo: null,
    // method to trigger context menu ["right", "left", "hover"]
    trigger: "right",
    // hide menu when mouse leaves trigger / menu elements
    autoHide: false,
    // ignore right click triggers for left, hover or custom activation
    ignoreRightClick: false,
    // ms to wait before showing a hover-triggered context menu
    delay: 200,
    // determine position to show menu at
    determinePosition: function ($menu) {
        // position to the lower middle of the trigger element
        if ($.ui && $.ui.position) {
            // .position() is provided as a jQuery UI utility
            // (...and it won't work on hidden elements)
            $menu.css('display', 'block').position({
                my: "center top",
                at: "center bottom",
                of: this,
                offset: "0 5",
                collision: "fit"
            }).css('display', 'none');
        } else {
            // determine contextMenu position
            var offset = this.offset();
            offset.top += this.outerHeight();
            offset.left += this.outerWidth() / 2 - $menu.outerWidth() / 2;
            $menu.css(offset);
        }
    },
    // position menu
    position: function (opt, x, y) {
        var $this = this,
            offset;
        // determine contextMenu position
        if (!x && !y) {
            opt.determinePosition.call(this, opt.$menu);
            return;
        } else if (x === "maintain" && y === "maintain") {
            // x and y must not be changed (after re-show on command click)
            offset = opt.$menu.position();
        } else {
            // x and y are given (by mouse event)
            var triggerIsFixed = opt.$trigger.parents().andSelf()
                .filter(function () {
                    return $(this).css('position') == "fixed";
                }).length;

            if (triggerIsFixed) {
                y -= $win.scrollTop();
                x -= $win.scrollLeft();
            }
            offset = { top: y, left: x };
        }

        // correct offset if viewport demands it
        var bottom = $win.scrollTop() + $win.height(),
            right = $win.scrollLeft() + $win.width(),
            height = opt.$menu.height(),
            width = opt.$menu.width();

        if (offset.top + height > bottom) {
            offset.top -= height;
        }

        if (offset.left + width > right) {
            offset.left -= width;
        }

        opt.$menu.css(offset);
    },
    // position the sub-menu
    positionSubmenu: function ($menu) {
        if ($.ui && $.ui.position) {
            // .position() is provided as a jQuery UI utility
            // (...and it won't work on hidden elements)
            $menu.css('display', 'block').position({
                my: "left top",
                at: "right top",
                of: this,
                collision: "fit"
            }).css('display', '');
        } else {
            // determine contextMenu position
            var offset = this.offset();
            offset.top += 0;
            offset.left += this.outerWidth();
            $menu.css(offset);
        }
    },
    // offset to add to zIndex
    zIndex: 1,
    // show hide animation settings
    animation: {
        duration: 50,
        show: 'slideDown',
        hide: 'slideUp'
    },
    // events
    events: {
        show: $.noop,
        hide: $.noop
    },
    // default callback
    callback: null,
    // list of contextMenu items
    items: {}
},
    // mouse position for hover activation
hoveract = {
    timer: null,
    pageX: null,
    pageY: null
},
    // determine zIndex
zindex = function ($t) {
    var zin = 0,
        $tt = $t;

    while (true) {
        zin = Math.max(zin, parseInt($tt.css('z-index'), 10) || 0);
        $tt = $tt.parent();
        if (!$tt || !$tt.length || $tt.prop('nodeName').toLowerCase() == 'body') {
            break;
        }
    }

    return zin;
},
    // event handlers
handle = {
    // abort anything
    abortevent: function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
    },

    // contextmenu show dispatcher
    contextmenu: function (e) {
        var $this = $(this);
        // disable actual context-menu
        e.preventDefault();
        e.stopImmediatePropagation();

        // ignore right click trigger
        if (ignoreThisClick) {
            ignoreThisClick = false;
            return;
        }

        if (!$this.hasClass('context-menu-disabled')) {
            // theoretically need to fire a show event at <menu>
            // http://www.whatwg.org/specs/web-apps/current-work/multipage/interactive-elements.html#context-menus
            // var evt = jQuery.Event("show", { data: data, pageX: e.pageX, pageY: e.pageY, relatedTarget: this });
            // e.data.$menu.trigger(evt);

            $currentTrigger = $this;
            if (e.data.build) {
                var built = e.data.build($currentTrigger, e);
                // abort if build() returned false
                if (built === false) {
                    return;
                }

                // dynamically build menu on invocation
                $.extend(true, e.data, defaults, built || {});

                // abort if there are no items to display
                if (!e.data.items || $.isEmptyObject(e.data.items)) {
                    // Note: jQuery captures and ignores errors from event handlers
                    if (window.console) {
                        (console.error || console.log)("No items specified to show in contextMenu");
                    }

                    throw new Error('No Items sepcified');
                }

                op.create(e.data);
            }
            // show menu
            op.show.call($this, e.data, e.pageX, e.pageY);
        }
    },
    // contextMenu left-click trigger
    click: function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
        $(this).trigger(jQuery.Event("contextmenu", { data: e.data, pageX: e.pageX, pageY: e.pageY }));
    },
    // contextMenu right-click trigger
    mousedown: function (e) {
        // register mouse down
        var $this = $(this);

        // hide any previous menus
        if ($currentTrigger && $currentTrigger.length && !$currentTrigger.is($this)) {
            $currentTrigger.data('contextMenu').$menu.trigger('contextmenu:hide');
        }

        // activate on right click
        if (e.button == 2) {
            $currentTrigger = $this.data('contextMenuActive', true);
        }
    },
    // contextMenu right-click trigger
    mouseup: function (e) {
        // show menu
        var $this = $(this);
        if ($this.data('contextMenuActive') && $currentTrigger && $currentTrigger.length && $currentTrigger.is($this) && !$this.hasClass('context-menu-disabled')) {
            e.preventDefault();
            e.stopImmediatePropagation();
            $currentTrigger = $this;
            $this.trigger(jQuery.Event("contextmenu", { data: e.data, pageX: e.pageX, pageY: e.pageY }));
        }

        $this.removeData('contextMenuActive');
    },
    // contextMenu hover trigger
    mouseenter: function (e) {
        var $this = $(this),
            $related = $(e.relatedTarget),
            $document = $(document);

        // abort if we're coming from a menu
        if ($related.is('.context-menu-list') || $related.closest('.context-menu-list').length) {
            return;
        }

        // abort if a menu is shown
        if ($currentTrigger && $currentTrigger.length) {
            return;
        }

        hoveract.pageX = e.pageX;
        hoveract.pageY = e.pageY;
        hoveract.data = e.data;
        $document.on('mousemove.contextMenuShow', handle.mousemove);
        hoveract.timer = setTimeout(function () {
            hoveract.timer = null;
            $document.off('mousemove.contextMenuShow');
            $currentTrigger = $this;
            $this.trigger(jQuery.Event("contextmenu", { data: hoveract.data, pageX: hoveract.pageX, pageY: hoveract.pageY }));
        }, e.data.delay);
    },
    // contextMenu hover trigger
    mousemove: function (e) {
        hoveract.pageX = e.pageX;
        hoveract.pageY = e.pageY;
    },
    // contextMenu hover trigger
    mouseleave: function (e) {
        // abort if we're leaving for a menu
        var $related = $(e.relatedTarget);
        if ($related.is('.context-menu-list') || $related.closest('.context-menu-list').length) {
            return;
        }

        try {
            clearTimeout(hoveract.timer);
        } catch (e) { }

        hoveract.timer = null;
    },

    // ignore right click trigger
    ignoreRightClick: function (e) {
        if (e.button == 2) {
            ignoreThisClick = true;
        }
    },

    // click on layer to hide contextMenu
    layerClick: function (e) {
        var $this = $(this),
            root = $this.data('contextMenuRoot');

        e.preventDefault();
        e.stopImmediatePropagation();
        $this.remove();
        root.$menu.trigger('contextmenu:hide');

        // ignore right click for left click trigger menu
        if (root.ignoreRightClick && e.button == 2) {
            ignoreThisClick = true;
        }
    },
    // key handled :hover
    keyStop: function (e, opt) {
        if (!opt.isInput) {
            e.preventDefault();
        }

        e.stopPropagation();
    },
    key: function (e) {
        var opt = $currentTrigger.data('contextMenu') || {},
            $children = opt.$menu.children(),
            $round;

        switch (e.keyCode) {
            case 9:
            case 38: // up
                handle.keyStop(e, opt);
                // if keyCode is [38 (up)] or [9 (tab) with shift]
                if (opt.isInput) {
                    if (e.keyCode == 9 && e.shiftKey) {
                        e.preventDefault();
                        opt.$selected && opt.$selected.find('input, textarea, select').blur();
                        opt.$menu.trigger('prevcommand');
                        return;
                    } else if (e.keyCode == 38 && opt.$selected.find('input, textarea, select').prop('type') == 'checkbox') {
                        // checkboxes don't capture this key
                        e.preventDefault();
                        return;
                    }
                } else if (e.keyCode != 9 || e.shiftKey) {
                    opt.$menu.trigger('prevcommand');
                    return;
                }

            case 9: // tab
            case 40: // down
                handle.keyStop(e, opt);
                if (opt.isInput) {
                    if (e.keyCode == 9) {
                        e.preventDefault();
                        opt.$selected && opt.$selected.find('input, textarea, select').blur();
                        opt.$menu.trigger('nextcommand');
                        return;
                    } else if (e.keyCode == 40 && opt.$selected.find('input, textarea, select').prop('type') == 'checkbox') {
                        // checkboxes don't capture this key
                        e.preventDefault();
                        return;
                    }
                } else {
                    opt.$menu.trigger('nextcommand');
                    return;
                }
                break;

            case 37: // left
                handle.keyStop(e, opt);
                if (opt.isInput || !opt.$selected || !opt.$selected.length) {
                    break;
                }

                if (!opt.$selected.parent().hasClass('context-menu-root')) {
                    var $parent = opt.$selected.parent().parent();
                    opt.$selected.trigger('contextmenu:blur');
                    opt.$selected = $parent;
                    return;
                }
                break;

            case 39: // right
                handle.keyStop(e, opt);
                if (opt.isInput || !opt.$selected || !opt.$selected.length) {
                    break;
                }

                var itemdata = opt.$selected.data('contextMenu') || {};
                if (itemdata.$menu && opt.$selected.hasClass('context-menu-submenu')) {
                    opt.$selected = null;
                    itemdata.$selected = null;
                    itemdata.$menu.trigger('nextcommand');
                    return;
                }
                break;

            case 35: // end
            case 36: // home
                if (opt.$selected && opt.$selected.find('input, textarea, select').length) {
                    return;
                } else {
                    (opt.$selected && opt.$selected.parent() || opt.$menu)
                        .children(':not(.disabled, .not-selectable)')[e.keyCode == 36 ? 'first' : 'last']()
                        .trigger('contextmenu:focus');
                    e.preventDefault();
                    return;
                }
                break;

            case 13: // enter
                handle.keyStop(e, opt);
                if (opt.isInput) {
                    if (opt.$selected && !opt.$selected.is('textarea, select')) {
                        e.preventDefault();
                        return;
                    }
                    break;
                }
                opt.$selected && opt.$selected.trigger('mouseup');
                return;

            case 32: // space
            case 33: // page up
            case 34: // page down
                // prevent browser from scrolling down while menu is visible
                handle.keyStop(e, opt);
                return;

            case 27: // esc
                handle.keyStop(e, opt);
                opt.$menu.trigger('contextmenu:hide');
                return;

            default: // 0-9, a-z
                var k = (String.fromCharCode(e.keyCode)).toUpperCase();
                if (opt.accesskeys[k]) {
                    // according to the specs accesskeys must be invoked immediately
                    opt.accesskeys[k].$node.trigger(opt.accesskeys[k].$menu
                        ? 'contextmenu:focus'
                        : 'mouseup'
                    );
                    return;
                }
                break;
        }
        // pass event to selected item, 
        // stop propagation to avoid endless recursion
        e.stopPropagation();
        opt.$selected && opt.$selected.trigger(e);
    },

    // select previous possible command in menu
    prevItem: function (e) {
        e.stopPropagation();
        var opt = $(this).data('contextMenu') || {};

        // obtain currently selected menu
        if (opt.$selected) {
            var $s = opt.$selected;
            opt = opt.$selected.parent().data('contextMenu') || {};
            opt.$selected = $s;
        }

        var $children = opt.$menu.children(),
            $prev = !opt.$selected || !opt.$selected.prev().length ? $children.last() : opt.$selected.prev(),
            $round = $prev;

        // skip disabled
        while ($prev.hasClass('disabled') || $prev.hasClass('not-selectable')) {
            if ($prev.prev().length) {
                $prev = $prev.prev();
            } else {
                $prev = $children.last();
            }
            if ($prev.is($round)) {
                // break endless loop
                return;
            }
        }

        // leave current
        if (opt.$selected) {
            handle.itemMouseleave.call(opt.$selected.get(0), e);
        }

        // activate next
        handle.itemMouseenter.call($prev.get(0), e);

        // focus input
        var $input = $prev.find('input, textarea, select');
        if ($input.length) {
            $input.focus();
        }
    },
    // select next possible command in menu
    nextItem: function (e) {
        e.stopPropagation();
        var opt = $(this).data('contextMenu') || {};

        // obtain currently selected menu
        if (opt.$selected) {
            var $s = opt.$selected;
            opt = opt.$selected.parent().data('contextMenu') || {};
            opt.$selected = $s;
        }

        var $children = opt.$menu.children(),
            $next = !opt.$selected || !opt.$selected.next().length ? $children.first() : opt.$selected.next(),
            $round = $next;

        // skip disabled
        while ($next.hasClass('disabled') || $next.hasClass('not-selectable')) {
            if ($next.next().length) {
                $next = $next.next();
            } else {
                $next = $children.first();
            }
            if ($next.is($round)) {
                // break endless loop
                return;
            }
        }

        // leave current
        if (opt.$selected) {
            handle.itemMouseleave.call(opt.$selected.get(0), e);
        }

        // activate next
        handle.itemMouseenter.call($next.get(0), e);

        // focus input
        var $input = $next.find('input, textarea, select');
        if ($input.length) {
            $input.focus();
        }
    },

    // flag that we're inside an input so the key handler can act accordingly
    focusInput: function (e) {
        var $this = $(this).closest('.context-menu-item'),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        root.$selected = opt.$selected = $this;
        root.isInput = opt.isInput = true;
    },
    // flag that we're inside an input so the key handler can act accordingly
    blurInput: function (e) {
        var $this = $(this).closest('.context-menu-item'),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        root.isInput = opt.isInput = false;
    },

    // :hover on menu
    menuMouseenter: function (e) {
        var root = $(this).data().contextMenuRoot;
        root.hovering = true;
    },
    // :hover on menu
    menuMouseleave: function (e) {
        var root = $(this).data().contextMenuRoot;
        if (root.$layer && root.$layer.is(e.relatedTarget)) {
            root.hovering = false;
        }
    },


    // :hover done manually so key handling is possible
    itemMouseenter: function (e) {
        var $this = $(this),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        root.hovering = true;

        // abort if we're re-entering
        if (e && root.$layer && root.$layer.is(e.relatedTarget)) {
            e.preventDefault();
            e.stopImmediatePropagation();
        }

        // make sure only one item is selected
        (opt.$menu ? opt : root).$menu
            .children('.hover').trigger('contextmenu:blur');

        if ($this.hasClass('disabled') || $this.hasClass('not-selectable')) {
            opt.$selected = null;
            return;
        }

        $this.trigger('contextmenu:focus');
    },
    // :hover done manually so key handling is possible
    itemMouseleave: function (e) {
        var $this = $(this),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        if (root !== opt && root.$layer && root.$layer.is(e.relatedTarget)) {
            root.$selected && root.$selected.trigger('contextmenu:blur');
            e.preventDefault();
            e.stopImmediatePropagation();
            root.$selected = opt.$selected = opt.$node;
            return;
        }

        $this.trigger('contextmenu:blur');
    },
    // contextMenu item click
    itemClick: function (e) {
        var $this = $(this),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot,
            key = data.contextMenuKey,
            callback;

        // abort if the key is unknown or disabled
        if (!opt.items[key] || $this.hasClass('disabled')) {
            return;
        }

        e.preventDefault();
        e.stopImmediatePropagation();

        if ($.isFunction(root.callbacks[key])) {
            // item-specific callback
            callback = root.callbacks[key];
        } else if ($.isFunction(root.callback)) {
            // default callback
            callback = root.callback;
        } else {
            // no callback, no action
            return;
        }

        // hide menu if callback doesn't stop that
        if (callback.call(root.$trigger, key, root) !== false) {
            root.$menu.trigger('contextmenu:hide');
        } else {
            op.update.call(root.$trigger, root);
        }
    },
    // ignore click events on input elements
    inputClick: function (e) {
        e.stopImmediatePropagation();
    },

    // hide <menu>
    hideMenu: function (e) {
        var root = $(this).data('contextMenuRoot');
        op.hide.call(root.$trigger, root);
    },
    // focus <command>
    focusItem: function (e) {
        e.stopPropagation();
        var $this = $(this),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        $this.addClass('hover')
            .siblings('.hover').trigger('contextmenu:blur');

        // remember selected
        opt.$selected = root.$selected = $this;

        // position sub-menu - do after show so dumb $.ui.position can keep up
        if (opt.$node) {
            root.positionSubmenu.call(opt.$node, opt.$menu);
        }
    },
    // blur <command>
    blurItem: function (e) {
        e.stopPropagation();
        var $this = $(this),
            data = $this.data(),
            opt = data.contextMenu,
            root = data.contextMenuRoot;

        $this.removeClass('hover');
        opt.$selected = null;
    }
},
    // operations
op = {
    show: function (opt, x, y) {
        var $this = $(this),
            offset,
            css = {};

        // hide any open menus
        $('#context-menu-layer').trigger('mousedown');

        // show event
        if (opt.events.show.call($this, opt) === false) {
            $currentTrigger = null;
            return;
        }

        // backreference for callbacks
        opt.$trigger = $this;

        // create or update context menu
        op.update.call($this, opt);

        // position menu
        opt.position.call($this, opt, x, y);

        // make sure we're in front
        if (opt.zIndex) {
            css.zIndex = zindex($this) + opt.zIndex;
        }

        // add layer
        op.layer.call(opt.$menu, opt, css.zIndex);

        // adjust sub-menu zIndexes
        opt.$menu.find('ul').css('zIndex', css.zIndex + 1);

        // position and show context menu
        opt.$menu.css(css)[opt.animation.show](opt.animation.duration);
        // make options available
        $this.data('contextMenu', opt);
        // register key handler
        $(document).off('keydown.contextMenu').on('keydown.contextMenu', handle.key);
        // register autoHide handler
        if (opt.autoHide) {
            // trigger element coordinates
            var pos = $this.position();
            pos.right = pos.left + $this.outerWidth();
            pos.bottom = pos.top + this.outerHeight();
            // mouse position handler
            $(document).on('mousemove.contextMenuAutoHide', function (e) {
                if (opt.$layer && !opt.hovering && (!(e.pageX >= pos.left && e.pageX <= pos.right) || !(e.pageY >= pos.top && e.pageY <= pos.bottom))) {
                    // if mouse in menu...
                    opt.$layer.trigger('mousedown');
                }
            });
        }
    },
    hide: function (opt) {
        var $this = $(this);
        if (!opt) {
            opt = $this.data('contextMenu') || {};
        }

        // hide event
        if (opt.events && opt.events.hide.call($this, opt) === false) {
            return;
        }

        if (opt.$layer) {
            try {
                opt.$layer.remove();
                delete opt.$layer;
            } catch (e) {
                opt.$layer = null;
            }
        }

        // remove handle
        $currentTrigger = null;
        // remove selected
        opt.$menu.find('.hover').trigger('contextmenu:blur');
        opt.$selected = null;
        // unregister key and mouse handlers
        //$(document).off('.contextMenuAutoHide keydown.contextMenu'); // http://bugs.jquery.com/ticket/10705
        $(document).off('.contextMenuAutoHide').off('keydown.contextMenu');
        // hide menu
        opt.$menu && opt.$menu[opt.animation.hide](opt.animation.duration);

        // tear down dynamically built menu
        if (opt.build) {
            opt.$menu.remove();
            $.each(opt, function (key, value) {
                switch (key) {
                    case 'ns':
                    case 'selector':
                    case 'build':
                    case 'trigger':
                    case 'ignoreRightClick':
                        return true;

                    default:
                        opt[key] = undefined;
                        try {
                            delete opt[key];
                        } catch (e) { }
                        return true;
                }
            });
        }
    },
    create: function (opt, root) {
        if (root === undefined) {
            root = opt;
        }
        // create contextMenu
        opt.$menu = $('<ul class="context-menu-list ' + (opt.className || "") + '"></ul>').data({
            'contextMenu': opt,
            'contextMenuRoot': root
        });

        $.each(['callbacks', 'commands', 'inputs'], function (i, k) {
            opt[k] = {};
            if (!root[k]) {
                root[k] = {};
            }
        });

        root.accesskeys || (root.accesskeys = {});

        // create contextMenu items
        $.each(opt.items, function (key, item) {
            var $t = $('<li class="context-menu-item ' + (item.className || "") + '"></li>'),
                $label = null,
                $input = null;

            item.$node = $t.data({
                'contextMenu': opt,
                'contextMenuRoot': root,
                'contextMenuKey': key
            });

            // register accesskey
            // NOTE: the accesskey attribute should be applicable to any element, but Safari5 and Chrome13 still can't do that
            if (item.accesskey) {
                var aks = splitAccesskey(item.accesskey);
                for (var i = 0, ak; ak = aks[i]; i++) {
                    if (!root.accesskeys[ak]) {
                        root.accesskeys[ak] = item;
                        item._name = item.name.replace(new RegExp('(' + ak + ')', 'i'), '<span class="context-menu-accesskey">$1</span>');
                        break;
                    }
                }
            }

            if (typeof item == "string") {
                $t.addClass('context-menu-separator not-selectable');
            } else if (item.type && types[item.type]) {
                // run custom type handler
                types[item.type].call($t, item, opt, root);
                // register commands
                $.each([opt, root], function (i, k) {
                    k.commands[key] = item;
                    if ($.isFunction(item.callback)) {
                        k.callbacks[key] = item.callback;
                    }
                });
            } else {
                // add label for input
                if (item.type == 'html') {
                    $t.addClass('context-menu-html not-selectable');
                } else if (item.type) {
                    $label = $('<label></label>').appendTo($t);
                    $('<span></span>').html(item._name || item.name).appendTo($label);
                    $t.addClass('context-menu-input');
                    opt.hasTypes = true;
                    $.each([opt, root], function (i, k) {
                        k.commands[key] = item;
                        k.inputs[key] = item;
                    });
                } else if (item.items) {
                    item.type = 'sub';
                }

                switch (item.type) {
                    case 'text':
                        $input = $('<input type="text" value="1" name="context-menu-input-' + key + '" value="">')
                            .val(item.value || "").appendTo($label);
                        break;

                    case 'textarea':
                        $input = $('<textarea name="context-menu-input-' + key + '"></textarea>')
                            .val(item.value || "").appendTo($label);

                        if (item.height) {
                            $input.height(item.height);
                        }
                        break;

                    case 'checkbox':
                        $input = $('<input type="checkbox" value="1" name="context-menu-input-' + key + '" value="">')
                            .val(item.value || "").prop("checked", !!item.selected).prependTo($label);
                        break;

                    case 'radio':
                        $input = $('<input type="radio" value="1" name="context-menu-input-' + item.radio + '" value="">')
                            .val(item.value || "").prop("checked", !!item.selected).prependTo($label);
                        break;

                    case 'select':
                        $input = $('<select name="context-menu-input-' + key + '">').appendTo($label);
                        if (item.options) {
                            $.each(item.options, function (value, text) {
                                $('<option></option>').val(value).text(text).appendTo($input);
                            });
                            $input.val(item.selected);
                        }
                        break;

                    case 'sub':
                        $('<span></span>').html(item._name || item.name).appendTo($t);
                        item.appendTo = item.$node;
                        op.create(item, root);
                        $t.data('contextMenu', item).addClass('context-menu-submenu');
                        item.callback = null;
                        break;

                    case 'html':
                        $(item.html).appendTo($t);
                        break;

                    default:
                        $.each([opt, root], function (i, k) {
                            k.commands[key] = item;
                            if ($.isFunction(item.callback)) {
                                k.callbacks[key] = item.callback;
                            }
                        });

                        $('<span></span>').html(item._name || item.name || "").appendTo($t);
                        break;
                }

                // disable key listener in <input>
                if (item.type && item.type != 'sub' && item.type != 'html') {
                    $input
                        .on('focus', handle.focusInput)
                        .on('blur', handle.blurInput);

                    if (item.events) {
                        $input.on(item.events);
                    }
                }

                // add icons
                if (item.icon) {
                    $t.addClass("icon icon-" + item.icon);
                }
            }

            // cache contained elements
            item.$input = $input;
            item.$label = $label;

            // attach item to menu
            $t.appendTo(opt.$menu);

            // Disable text selection
            if (!opt.hasTypes) {
                if ($.browser.msie) {
                    $t.on('selectstart.disableTextSelect', handle.abortevent);
                } else if (!$.browser.mozilla) {
                    $t.on('mousedown.disableTextSelect', handle.abortevent);
                }
            }
        });
        // attach contextMenu to <body> (to bypass any possible overflow:hidden issues on parents of the trigger element)
        if (!opt.$node) {
            opt.$menu.css('display', 'none').addClass('context-menu-root');
        }
        opt.$menu.appendTo(opt.appendTo || document.body);
    },
    update: function (opt, root) {
        var $this = this;
        if (root === undefined) {
            root = opt;
            // determine widths of submenus, as CSS won't grow them automatically
            // position:absolute > position:absolute; min-width:100; max-width:200; results in width: 100;
            // kinda sucks hard...
            opt.$menu.find('ul').andSelf().css({ position: 'static', display: 'block' }).each(function () {
                var $this = $(this);
                $this.width($this.css('position', 'absolute').width())
                    .css('position', 'static');
            }).css({ position: '', display: '' });
        }
        // re-check disabled for each item
        opt.$menu.children().each(function () {
            var $item = $(this),
                key = $item.data('contextMenuKey'),
                item = opt.items[key],
                disabled = ($.isFunction(item.disabled) && item.disabled.call($this, key, root)) || item.disabled === true;

            // dis- / enable item
            $item[disabled ? 'addClass' : 'removeClass']('disabled');

            if (item.type) {
                // dis- / enable input elements
                $item.find('input, select, textarea').prop('disabled', disabled);

                // update input states
                switch (item.type) {
                    case 'text':
                    case 'textarea':
                        item.$input.val(item.value || "");
                        break;

                    case 'checkbox':
                    case 'radio':
                        item.$input.val(item.value || "").prop('checked', !!item.selected);
                        break;

                    case 'select':
                        item.$input.val(item.selected || "");
                        break;
                }
            }

            if (item.$menu) {
                // update sub-menu
                op.update.call($this, item, root);
            }
        });
    },
    layer: function (opt, zIndex) {
        // add transparent layer for click area
        // filter and background for Internet Explorer, Issue #23
        return opt.$layer = $('<div id="context-menu-layer" style="position:fixed; z-index:' + zIndex + '; top:0; left:0; opacity: 0; filter: alpha(opacity=0); background-color: #000;"></div>')
            .css({ height: $win.height(), width: $win.width(), display: 'block' })
            .data('contextMenuRoot', opt)
            .insertBefore(this)
            .on('mousedown', handle.layerClick);
    }
};

    // split accesskey according to http://www.whatwg.org/specs/web-apps/current-work/multipage/editing.html#assigned-access-key
    function splitAccesskey(val) {
        var t = val.split(/\s+/),
    keys = [];

        for (var i = 0, k; k = t[i]; i++) {
            k = k[0].toUpperCase(); // first character only
            // theoretically non-accessible characters should be ignored, but different systems, different keyboard layouts, ... screw it.
            // a map to look up already used access keys would be nice
            keys.push(k);
        }

        return keys;
    }

    // handle contextMenu triggers
    $.fn.contextMenu = function (operation) {
        if (operation === undefined) {
            this.first().trigger('contextmenu');
        } else if (operation.x && operation.y) {
            this.first().trigger(jQuery.Event("contextmenu", { pageX: operation.x, pageY: operation.y }));
        } else if (operation === "hide") {
            var $menu = this.data('contextMenu').$menu;
            $menu && $menu.trigger('contextmenu:hide');
        } else if (operation) {
            this.removeClass('context-menu-disabled');
        } else if (!operation) {
            this.addClass('context-menu-disabled');
        }

        return this;
    };

    // manage contextMenu instances
    $.contextMenu = function (operation, options) {
        if (typeof operation != 'string') {
            options = operation;
            operation = 'create';
        }

        if (typeof options == 'string') {
            options = { selector: options };
        } else if (options === undefined) {
            options = {};
        }

        // merge with default options
        var o = $.extend(true, {}, defaults, options || {}),
    $body = $body = $(document);

        switch (operation) {
            case 'create':
                // no selector no joy
                if (!o.selector) {
                    throw new Error('No selector specified');
                }
                // make sure internal classes are not bound to
                if (o.selector.match(/.context-menu-(list|item|input)($|\s)/)) {
                    throw new Error('Cannot bind to selector "' + o.selector + '" as it contains a reserved className');
                }
                if (!o.build && (!o.items || $.isEmptyObject(o.items))) {
                    throw new Error('No Items sepcified');
                }
                counter++;
                o.ns = '.contextMenu' + counter;
                namespaces[o.selector] = o.ns;
                menus[o.ns] = o;

                if (!initialized) {
                    // make sure item click is registered first
                    $body
                .on({
                    'contextmenu:hide.contextMenu': handle.hideMenu,
                    'prevcommand.contextMenu': handle.prevItem,
                    'nextcommand.contextMenu': handle.nextItem,
                    'contextmenu.contextMenu': handle.abortevent,
                    'mouseenter.contextMenu': handle.menuMouseenter,
                    'mouseleave.contextMenu': handle.menuMouseleave
                }, '.context-menu-list')
                .on('mouseup.contextMenu', '.context-menu-input', handle.inputClick)
                .on({
                    'mouseup.contextMenu': handle.itemClick,
                    'contextmenu:focus.contextMenu': handle.focusItem,
                    'contextmenu:blur.contextMenu': handle.blurItem,
                    'contextmenu.contextMenu': handle.abortevent,
                    'mouseenter.contextMenu': handle.itemMouseenter,
                    'mouseleave.contextMenu': handle.itemMouseleave
                }, '.context-menu-item');

                    initialized = true;
                }

                // engage native contextmenu event
                $body
            .on('contextmenu' + o.ns, o.selector, o, handle.contextmenu);

                switch (o.trigger) {
                    case 'hover':
                        $body
                        .on('mouseenter' + o.ns, o.selector, o, handle.mouseenter)
                        .on('mouseleave' + o.ns, o.selector, o, handle.mouseleave);
                        break;

                    case 'left':
                        $body.on('click' + o.ns, o.selector, o, handle.click);
                        break;
                    /*
                    default:
                    // http://www.quirksmode.org/dom/events/contextmenu.html
                    $body
                    .on('mousedown' + o.ns, o.selector, o, handle.mousedown)
                    .on('mouseup' + o.ns, o.selector, o, handle.mouseup);
                    break;
                    */ 
                }

                if (o.trigger != 'hover' && o.ignoreRightClick) {
                    $body.on('mousedown' + o.ns, o.selector, handle.ignoreRightClick);
                }

                // create menu
                if (!o.build) {
                    op.create(o);
                }
                break;

            case 'destroy':
                if (!o.selector) {
                    $body.off('.contextMenu .contextMenuAutoHide');
                    $.each(namespaces, function (key, value) {
                        $body.off(value);
                    });

                    namespaces = {};
                    menus = {};
                    counter = 0;
                    initialized = false;

                    $('.context-menu-list').remove();
                } else if (namespaces[o.selector]) {
                    try {
                        if (menus[namespaces[o.selector]].$menu) {
                            menus[namespaces[o.selector]].$menu.remove();
                        }

                        delete menus[namespaces[o.selector]];
                    } catch (e) {
                        menus[namespaces[o.selector]] = null;
                    }

                    $body.off(namespaces[o.selector]);
                }
                break;

            case 'html5':
                // if <command> or <menuitem> are not handled by the browser,
                // or options was a bool true,
                // initialize $.contextMenu for them
                if ((!$.support.htmlCommand && !$.support.htmlMenuitem) || (typeof options == "boolean" && options)) {
                    $('menu[type="context"]').each(function () {
                        if (this.id) {
                            $.contextMenu({
                                selector: '[contextmenu=' + this.id + ']',
                                items: $.contextMenu.fromMenu(this)
                            });
                        }
                    }).css('display', 'none');
                }
                break;

            default:
                throw new Error('Unknown operation "' + operation + '"');
        }

        return this;
    };

    // import values into <input> commands
    $.contextMenu.setInputValues = function (opt, data) {
        if (data === undefined) {
            data = {};
        }

        $.each(opt.inputs, function (key, item) {
            switch (item.type) {
                case 'text':
                case 'textarea':
                    item.value = data[key] || "";
                    break;

                case 'checkbox':
                    item.selected = data[key] ? true : false;
                    break;

                case 'radio':
                    item.selected = (data[item.radio] || "") == item.value ? true : false;
                    break;

                case 'select':
                    item.selected = data[key] || "";
                    break;
            }
        });
    };

    // export values from <input> commands
    $.contextMenu.getInputValues = function (opt, data) {
        if (data === undefined) {
            data = {};
        }

        $.each(opt.inputs, function (key, item) {
            switch (item.type) {
                case 'text':
                case 'textarea':
                case 'select':
                    data[key] = item.$input.val();
                    break;

                case 'checkbox':
                    data[key] = item.$input.prop('checked');
                    break;

                case 'radio':
                    if (item.$input.prop('checked')) {
                        data[item.radio] = item.value;
                    }
                    break;
            }
        });

        return data;
    };

    // find <label for="xyz">
    function inputLabel(node) {
        return (node.id && $('label[for="' + node.id + '"]').val()) || node.name;
    }

    // convert <menu> to items object
    function menuChildren(items, $children, counter) {
        if (!counter) {
            counter = 0;
        }

        $children.each(function () {
            var $node = $(this),
        node = this,
        nodeName = this.nodeName.toLowerCase(),
        label,
        item;

            // extract <label><input>
            if (nodeName == 'label' && $node.find('input, textarea, select').length) {
                label = $node.text();
                $node = $node.children().first();
                node = $node.get(0);
                nodeName = node.nodeName.toLowerCase();
            }

            /*
            * <menu> accepts flow-content as children. that means <embed>, <canvas> and such are valid menu items.
            * Not being the sadistic kind, $.contextMenu only accepts:
            * <command>, <menuitem>, <hr>, <span>, <p> <input [text, radio, checkbox]>, <textarea>, <select> and of course <menu>.
            * Everything else will be imported as an html node, which is not interfaced with contextMenu.
            */

            // http://www.whatwg.org/specs/web-apps/current-work/multipage/commands.html#concept-command
            switch (nodeName) {
                // http://www.whatwg.org/specs/web-apps/current-work/multipage/interactive-elements.html#the-menu-element    
                case 'menu':
                    item = { name: $node.attr('label'), items: {} };
                    menuChildren(item.items, $node.children(), counter);
                    break;

                // http://www.whatwg.org/specs/web-apps/current-work/multipage/commands.html#using-the-a-element-to-define-a-command    
                case 'a':
                    // http://www.whatwg.org/specs/web-apps/current-work/multipage/commands.html#using-the-button-element-to-define-a-command
                case 'button':
                    item = {
                        name: $node.text(),
                        disabled: !!$node.attr('disabled'),
                        callback: (function () { return function () { $node.click(); }; })()
                    };
                    break;

                // http://www.whatwg.org/specs/web-apps/current-work/multipage/commands.html#using-the-command-element-to-define-a-command    

                case 'menuitem':
                case 'command':
                    switch ($node.attr('type')) {
                        case undefined:
                        case 'command':
                        case 'menuitem':
                            item = {
                                name: $node.attr('label'),
                                disabled: !!$node.attr('disabled'),
                                callback: (function () { return function () { $node.click(); }; })()
                            };
                            break;

                        case 'checkbox':
                            item = {
                                type: 'checkbox',
                                disabled: !!$node.attr('disabled'),
                                name: $node.attr('label'),
                                selected: !!$node.attr('checked')
                            };
                            break;

                        case 'radio':
                            item = {
                                type: 'radio',
                                disabled: !!$node.attr('disabled'),
                                name: $node.attr('label'),
                                radio: $node.attr('radiogroup'),
                                value: $node.attr('id'),
                                selected: !!$node.attr('checked')
                            };
                            break;

                        default:
                            item = undefined;
                    }
                    break;

                case 'hr':
                    item = '-------';
                    break;

                case 'input':
                    switch ($node.attr('type')) {
                        case 'text':
                            item = {
                                type: 'text',
                                name: label || inputLabel(node),
                                disabled: !!$node.attr('disabled'),
                                value: $node.val()
                            };
                            break;

                        case 'checkbox':
                            item = {
                                type: 'checkbox',
                                name: label || inputLabel(node),
                                disabled: !!$node.attr('disabled'),
                                selected: !!$node.attr('checked')
                            };
                            break;

                        case 'radio':
                            item = {
                                type: 'radio',
                                name: label || inputLabel(node),
                                disabled: !!$node.attr('disabled'),
                                radio: !!$node.attr('name'),
                                value: $node.val(),
                                selected: !!$node.attr('checked')
                            };
                            break;

                        default:
                            item = undefined;
                            break;
                    }
                    break;

                case 'select':
                    item = {
                        type: 'select',
                        name: label || inputLabel(node),
                        disabled: !!$node.attr('disabled'),
                        selected: $node.val(),
                        options: {}
                    };
                    $node.children().each(function () {
                        item.options[this.value] = $(this).text();
                    });
                    break;

                case 'textarea':
                    item = {
                        type: 'textarea',
                        name: label || inputLabel(node),
                        disabled: !!$node.attr('disabled'),
                        value: $node.val()
                    };
                    break;

                case 'label':
                    break;

                default:
                    item = { type: 'html', html: $node.clone(true) };
                    break;
            }

            if (item) {
                counter++;
                items['key' + counter] = item;
            }
        });
    }

    // convert html5 menu
    $.contextMenu.fromMenu = function (element) {
        var $this = $(element),
    items = {};

        menuChildren(items, $this.children());

        return items;
    };

    // make defaults accessible
    $.contextMenu.defaults = defaults;
    $.contextMenu.types = types;

})(jQuery);

/*
* jQuery MultiSelect UI Widget 1.13
* Copyright (c) 2012 Eric Hynds
*
* http://www.erichynds.com/jquery/jquery-ui-multiselect-widget/
*
* Depends:
*   - jQuery 1.4.2+
*   - jQuery UI 1.8 widget factory
*
* Optional:
*   - jQuery UI effects
*   - jQuery UI position utility
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*
*/
(function (d) { var k = 0; d.widget("ech.multiselect", { options: { header: !0, height: 175, minWidth: 225, classes: "", checkAllText: "Check all", uncheckAllText: "Uncheck all", noneSelectedText: "Select options", selectedText: "# selected", selectedList: 0, show: null, hide: null, autoOpen: !1, multiple: !0, position: {} }, _create: function () { var a = this.element.hide(), b = this.options; this.speed = d.fx.speeds._default; this._isOpen = !1; a = (this.button = d('<button type="button"><span class="ui-icon ui-icon-triangle-1-s"></span></button>')).addClass("ui-multiselect ui-widget ui-state-default ui-corner-all").addClass(b.classes).attr({ title: a.attr("title"), "aria-haspopup": !0, tabIndex: a.attr("tabIndex") }).insertAfter(a); (this.buttonlabel = d("<span />")).html(b.noneSelectedText).appendTo(a); var a = (this.menu = d("<div />")).addClass("ui-multiselect-menu ui-widget ui-widget-content ui-corner-all").addClass(b.classes).appendTo(document.body), c = (this.header = d("<div />")).addClass("ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix").appendTo(a); (this.headerLinkContainer = d("<ul />")).addClass("ui-helper-reset").html(function () { return !0 === b.header ? '<li><a class="ui-multiselect-all" href="#"><span class="ui-icon ui-icon-check"></span><span>' + b.checkAllText + '</span></a></li><li><a class="ui-multiselect-none" href="#"><span class="ui-icon ui-icon-closethick"></span><span>' + b.uncheckAllText + "</span></a></li>" : "string" === typeof b.header ? "<li>" + b.header + "</li>" : "" }).append('<li class="ui-multiselect-close"><a href="#" class="ui-multiselect-close"><span class="ui-icon ui-icon-circle-close"></span></a></li>').appendTo(c); (this.checkboxContainer = d("<ul />")).addClass("ui-multiselect-checkboxes ui-helper-reset").appendTo(a); this._bindEvents(); this.refresh(!0); b.multiple || a.addClass("ui-multiselect-single") }, _init: function () { !1 === this.options.header && this.header.hide(); this.options.multiple || this.headerLinkContainer.find(".ui-multiselect-all, .ui-multiselect-none").hide(); this.options.autoOpen && this.open(); this.element.is(":disabled") && this.disable() }, refresh: function (a) { var b = this.element, c = this.options, f = this.menu, h = this.checkboxContainer, g = [], e = "", i = b.attr("id") || k++; b.find("option").each(function (b) { d(this); var a = this.parentNode, f = this.innerHTML, h = this.title, k = this.value, b = "ui-multiselect-" + (this.id || i + "-option-" + b), l = this.disabled, n = this.selected, m = ["ui-corner-all"], o = (l ? "ui-multiselect-disabled " : " ") + this.className, j; "OPTGROUP" === a.tagName && (j = a.getAttribute("label"), -1 === d.inArray(j, g) && (e += '<li class="ui-multiselect-optgroup-label ' + a.className + '"><a href="#">' + j + "</a></li>", g.push(j))); l && m.push("ui-state-disabled"); n && !c.multiple && m.push("ui-state-active"); e += '<li class="' + o + '">'; e += '<label for="' + b + '" title="' + h + '" class="' + m.join(" ") + '">'; e += '<input id="' + b + '" name="multiselect_' + i + '" type="' + (c.multiple ? "checkbox" : "radio") + '" value="' + k + '" title="' + f + '"'; n && (e += ' checked="checked"', e += ' aria-selected="true"'); l && (e += ' disabled="disabled"', e += ' aria-disabled="true"'); e += " /><span>" + f + "</span></label></li>" }); h.html(e); this.labels = f.find("label"); this.inputs = this.labels.children("input"); this._setButtonWidth(); this._setMenuWidth(); this.button[0].defaultValue = this.update(); a || this._trigger("refresh") }, update: function () { var a = this.options, b = this.inputs, c = b.filter(":checked"), f = c.length, a = 0 === f ? a.noneSelectedText : d.isFunction(a.selectedText) ? a.selectedText.call(this, f, b.length, c.get()) : /\d/.test(a.selectedList) && 0 < a.selectedList && f <= a.selectedList ? c.map(function () { return d(this).next().html() }).get().join(", ") : a.selectedText.replace("#", f).replace("#", b.length); this.buttonlabel.html(a); return a }, _bindEvents: function () { function a() { b[b._isOpen ? "close" : "open"](); return !1 } var b = this, c = this.button; c.find("span").bind("click.multiselect", a); c.bind({ click: a, keypress: function (a) { switch (a.which) { case 27: case 38: case 37: b.close(); break; case 39: case 40: b.open() } }, mouseenter: function () { c.hasClass("ui-state-disabled") || d(this).addClass("ui-state-hover") }, mouseleave: function () { d(this).removeClass("ui-state-hover") }, focus: function () { c.hasClass("ui-state-disabled") || d(this).addClass("ui-state-focus") }, blur: function () { d(this).removeClass("ui-state-focus") } }); this.header.delegate("a", "click.multiselect", function (a) { if (d(this).hasClass("ui-multiselect-close")) b.close(); else b[d(this).hasClass("ui-multiselect-all") ? "checkAll" : "uncheckAll"](); a.preventDefault() }); this.menu.delegate("li.ui-multiselect-optgroup-label a", "click.multiselect", function (a) { a.preventDefault(); var c = d(this), g = c.parent().nextUntil("li.ui-multiselect-optgroup-label").find("input:visible:not(:disabled)"), e = g.get(), c = c.parent().text(); !1 !== b._trigger("beforeoptgrouptoggle", a, { inputs: e, label: c }) && (b._toggleChecked(g.filter(":checked").length !== g.length, g), b._trigger("optgrouptoggle", a, { inputs: e, label: c, checked: e[0].checked })) }).delegate("label", "mouseenter.multiselect", function () { d(this).hasClass("ui-state-disabled") || (b.labels.removeClass("ui-state-hover"), d(this).addClass("ui-state-hover").find("input").focus()) }).delegate("label", "keydown.multiselect", function (a) { a.preventDefault(); switch (a.which) { case 9: case 27: b.close(); break; case 38: case 40: case 37: case 39: b._traverse(a.which, this); break; case 13: d(this).find("input")[0].click() } }).delegate('input[type="checkbox"], input[type="radio"]', "click.multiselect", function (a) { var c = d(this), g = this.value, e = this.checked, i = b.element.find("option"); this.disabled || !1 === b._trigger("click", a, { value: g, text: this.title, checked: e }) ? a.preventDefault() : (c.focus(), c.attr("aria-selected", e), i.each(function () { this.value === g ? this.selected = e : b.options.multiple || (this.selected = !1) }), b.options.multiple || (b.labels.removeClass("ui-state-active"), c.closest("label").toggleClass("ui-state-active", e), b.close()), b.element.trigger("change"), setTimeout(d.proxy(b.update, b), 10)) }); d(document).bind("mousedown.multiselect", function (a) { b._isOpen && (!d.contains(b.menu[0], a.target) && !d.contains(b.button[0], a.target) && a.target !== b.button[0]) && b.close() }); d(this.element[0].form).bind("reset.multiselect", function () { setTimeout(d.proxy(b.refresh, b), 10) }) }, _setButtonWidth: function () { var a = this.element.outerWidth(), b = this.options; /\d/.test(b.minWidth) && a < b.minWidth && (a = b.minWidth); this.button.width(a) }, _setMenuWidth: function () { var a = this.menu, b = this.button.outerWidth() - parseInt(a.css("padding-left"), 10) - parseInt(a.css("padding-right"), 10) - parseInt(a.css("border-right-width"), 10) - parseInt(a.css("border-left-width"), 10); a.width(b || this.button.outerWidth()) }, _traverse: function (a, b) { var c = d(b), f = 38 === a || 37 === a, c = c.parent()[f ? "prevAll" : "nextAll"]("li:not(.ui-multiselect-disabled, .ui-multiselect-optgroup-label)")[f ? "last" : "first"](); c.length ? c.find("label").trigger("mouseover") : (c = this.menu.find("ul").last(), this.menu.find("label")[f ? "last" : "first"]().trigger("mouseover"), c.scrollTop(f ? c.height() : 0)) }, _toggleState: function (a, b) { return function () { this.disabled || (this[a] = b); b ? this.setAttribute("aria-selected", !0) : this.removeAttribute("aria-selected") } }, _toggleChecked: function (a, b) { var c = b && b.length ? b : this.inputs, f = this; c.each(this._toggleState("checked", a)); c.eq(0).focus(); this.update(); var h = c.map(function () { return this.value }).get(); this.element.find("option").each(function () { !this.disabled && -1 < d.inArray(this.value, h) && f._toggleState("selected", a).call(this) }); c.length && this.element.trigger("change") }, _toggleDisabled: function (a) { this.button.attr({ disabled: a, "aria-disabled": a })[a ? "addClass" : "removeClass"]("ui-state-disabled"); var b = this.menu.find("input"), b = a ? b.filter(":enabled").data("ech-multiselect-disabled", !0) : b.filter(function () { return !0 === d.data(this, "ech-multiselect-disabled") }).removeData("ech-multiselect-disabled"); b.attr({ disabled: a, "arial-disabled": a }).parent()[a ? "addClass" : "removeClass"]("ui-state-disabled"); this.element.attr({ disabled: a, "aria-disabled": a }) }, open: function () { var a = this.button, b = this.menu, c = this.speed, f = this.options, h = []; if (!(!1 === this._trigger("beforeopen") || a.hasClass("ui-state-disabled") || this._isOpen)) { var g = b.find("ul").last(), e = f.show, i = a.offset(); d.isArray(f.show) && (e = f.show[0], c = f.show[1] || this.speed); e && (h = [e, c]); g.scrollTop(0).height(f.height); d.ui.position && !d.isEmptyObject(f.position) ? (f.position.of = f.position.of || a, b.show().position(f.position).hide()) : b.css({ top: i.top + a.outerHeight(), left: i.left }); d.fn.show.apply(b, h); this.labels.eq(0).trigger("mouseover").trigger("mouseenter").find("input").trigger("focus"); a.addClass("ui-state-active"); this._isOpen = !0; this._trigger("open") } }, close: function () { if (!1 !== this._trigger("beforeclose")) { var a = this.options, b = a.hide, c = this.speed, f = []; d.isArray(a.hide) && (b = a.hide[0], c = a.hide[1] || this.speed); b && (f = [b, c]); d.fn.hide.apply(this.menu, f); this.button.removeClass("ui-state-active").trigger("blur").trigger("mouseleave"); this._isOpen = !1; this._trigger("close") } }, enable: function () { this._toggleDisabled(!1) }, disable: function () { this._toggleDisabled(!0) }, checkAll: function () { this._toggleChecked(!0); this._trigger("checkAll") }, uncheckAll: function () { this._toggleChecked(!1); this._trigger("uncheckAll") }, getChecked: function () { return this.menu.find("input").filter(":checked") }, destroy: function () { d.Widget.prototype.destroy.call(this); this.button.remove(); this.menu.remove(); this.element.show(); return this }, isOpen: function () { return this._isOpen }, widget: function () { return this.menu }, getButton: function () { return this.button }, _setOption: function (a, b) { var c = this.menu; switch (a) { case "header": c.find("div.ui-multiselect-header")[b ? "show" : "hide"](); break; case "checkAllText": c.find("a.ui-multiselect-all span").eq(-1).text(b); break; case "uncheckAllText": c.find("a.ui-multiselect-none span").eq(-1).text(b); break; case "height": c.find("ul").last().height(parseInt(b, 10)); break; case "minWidth": this.options[a] = parseInt(b, 10); this._setButtonWidth(); this._setMenuWidth(); break; case "selectedText": case "selectedList": case "noneSelectedText": this.options[a] = b; this.update(); break; case "classes": c.add(this.button).removeClass(this.options.classes).addClass(b); break; case "multiple": c.toggleClass("ui-multiselect-single", !b), this.options.multiple = b, this.element[0].multiple = b, this.refresh() } d.Widget.prototype._setOption.apply(this, arguments) } }) })(jQuery);

/*
* jQuery timepicker addon
* By: Trent Richardson [http://trentrichardson.com]
* Version 0.9.9
* Last Modified: 02/05/2012
* 
* Copyright 2012 Trent Richardson
* Dual licensed under the MIT and GPL licenses.
* http://trentrichardson.com/Impromptu/GPL-LICENSE.txt
* http://trentrichardson.com/Impromptu/MIT-LICENSE.txt
* 
* HERES THE CSS:
* .ui-timepicker-div .ui-widget-header { margin-bottom: 8px; }
* .ui-timepicker-div dl { text-align: left; }
* .ui-timepicker-div dl dt { height: 25px; margin-bottom: -25px; }
* .ui-timepicker-div dl dd { margin: 0 10px 10px 65px; }
* .ui-timepicker-div td { font-size: 90%; }
* .ui-tpicker-grid-label { background: none; border: none; margin: 0; padding: 0; }
*/

(function ($) {

    $.extend($.ui, { timepicker: { version: "0.9.9"} });

    /* Time picker manager.
    Use the singleton instance of this class, $.timepicker, to interact with the time picker.
    Settings for (groups of) time pickers are maintained in an instance object,
    allowing multiple different settings on the same page. */

    function Timepicker() {
        this.regional = []; // Available regional settings, indexed by language code
        this.regional[''] = { // Default regional settings
            currentText: 'Now',
            closeText: 'Done',
            ampm: false,
            amNames: ['AM', 'A'],
            pmNames: ['PM', 'P'],
            timeFormat: 'hh:mm tt',
            timeSuffix: '',
            timeOnlyTitle: 'Choose Time',
            timeText: 'Time',
            hourText: 'Hour',
            minuteText: 'Minute',
            secondText: 'Second',
            millisecText: 'Millisecond',
            timezoneText: 'Time Zone'
        };
        this._defaults = { // Global defaults for all the datetime picker instances
            showButtonPanel: true,
            timeOnly: false,
            showHour: true,
            showMinute: true,
            showSecond: false,
            showMillisec: false,
            showTimezone: false,
            showTime: true,
            stepHour: 1,
            stepMinute: 1,
            stepSecond: 1,
            stepMillisec: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisec: 0,
            timezone: '+0000',
            hourMin: 0,
            minuteMin: 0,
            secondMin: 0,
            millisecMin: 0,
            hourMax: 23,
            minuteMax: 59,
            secondMax: 59,
            millisecMax: 999,
            minDateTime: null,
            maxDateTime: null,
            onSelect: null,
            hourGrid: 0,
            minuteGrid: 0,
            secondGrid: 0,
            millisecGrid: 0,
            alwaysSetTime: true,
            separator: ' ',
            altFieldTimeOnly: true,
            showTimepicker: true,
            timezoneIso8609: false,
            timezoneList: null,
            addSliderAccess: false,
            sliderAccessArgs: null
        };
        $.extend(this._defaults, this.regional['']);
    };

    $.extend(Timepicker.prototype, {
        $input: null,
        $altInput: null,
        $timeObj: null,
        inst: null,
        hour_slider: null,
        minute_slider: null,
        second_slider: null,
        millisec_slider: null,
        timezone_select: null,
        hour: 0,
        minute: 0,
        second: 0,
        millisec: 0,
        timezone: '+0000',
        hourMinOriginal: null,
        minuteMinOriginal: null,
        secondMinOriginal: null,
        millisecMinOriginal: null,
        hourMaxOriginal: null,
        minuteMaxOriginal: null,
        secondMaxOriginal: null,
        millisecMaxOriginal: null,
        ampm: '',
        formattedDate: '',
        formattedTime: '',
        formattedDateTime: '',
        timezoneList: null,

        /* Override the default settings for all instances of the time picker.
        @param  settings  object - the new settings to use as defaults (anonymous object)
        @return the manager object */
        setDefaults: function (settings) {
            extendRemove(this._defaults, settings || {});
            return this;
        },

        //########################################################################
        // Create a new Timepicker instance
        //########################################################################
        _newInst: function ($input, o) {
            var tp_inst = new Timepicker(),
		inlineSettings = {};

            for (var attrName in this._defaults) {
                var attrValue = $input.attr('time:' + attrName);
                if (attrValue) {
                    try {
                        inlineSettings[attrName] = eval(attrValue);
                    } catch (err) {
                        inlineSettings[attrName] = attrValue;
                    }
                }
            }
            tp_inst._defaults = $.extend({}, this._defaults, inlineSettings, o, {
                beforeShow: function (input, dp_inst) {
                    if ($.isFunction(o.beforeShow))
                        return o.beforeShow(input, dp_inst, tp_inst);
                },
                onChangeMonthYear: function (year, month, dp_inst) {
                    // Update the time as well : this prevents the time from disappearing from the $input field.
                    tp_inst._updateDateTime(dp_inst);
                    if ($.isFunction(o.onChangeMonthYear))
                        o.onChangeMonthYear.call($input[0], year, month, dp_inst, tp_inst);
                },
                onClose: function (dateText, dp_inst) {
                    if (tp_inst.timeDefined === true && $input.val() != '')
                        tp_inst._updateDateTime(dp_inst);
                    if ($.isFunction(o.onClose))
                        o.onClose.call($input[0], dateText, dp_inst, tp_inst);
                },
                timepicker: tp_inst // add timepicker as a property of datepicker: $.datepicker._get(dp_inst, 'timepicker');
            });
            tp_inst.amNames = $.map(tp_inst._defaults.amNames, function (val) { return val.toUpperCase() });
            tp_inst.pmNames = $.map(tp_inst._defaults.pmNames, function (val) { return val.toUpperCase() });

            if (tp_inst._defaults.timezoneList === null) {
                var timezoneList = [];
                for (var i = -11; i <= 12; i++)
                    timezoneList.push((i >= 0 ? '+' : '-') + ('0' + Math.abs(i).toString()).slice(-2) + '00');
                if (tp_inst._defaults.timezoneIso8609)
                    timezoneList = $.map(timezoneList, function (val) {
                        return val == '+0000' ? 'Z' : (val.substring(0, 3) + ':' + val.substring(3));
                    });
                tp_inst._defaults.timezoneList = timezoneList;
            }

            tp_inst.hour = tp_inst._defaults.hour;
            tp_inst.minute = tp_inst._defaults.minute;
            tp_inst.second = tp_inst._defaults.second;
            tp_inst.millisec = tp_inst._defaults.millisec;
            tp_inst.ampm = '';
            tp_inst.$input = $input;

            if (o.altField)
                tp_inst.$altInput = $(o.altField)
			.css({ cursor: 'pointer' })
			.focus(function () { $input.trigger("focus"); });

            if (tp_inst._defaults.minDate == 0 || tp_inst._defaults.minDateTime == 0) {
                tp_inst._defaults.minDate = new Date();
            }
            if (tp_inst._defaults.maxDate == 0 || tp_inst._defaults.maxDateTime == 0) {
                tp_inst._defaults.maxDate = new Date();
            }

            // datepicker needs minDate/maxDate, timepicker needs minDateTime/maxDateTime..
            if (tp_inst._defaults.minDate !== undefined && tp_inst._defaults.minDate instanceof Date)
                tp_inst._defaults.minDateTime = new Date(tp_inst._defaults.minDate.getTime());
            if (tp_inst._defaults.minDateTime !== undefined && tp_inst._defaults.minDateTime instanceof Date)
                tp_inst._defaults.minDate = new Date(tp_inst._defaults.minDateTime.getTime());
            if (tp_inst._defaults.maxDate !== undefined && tp_inst._defaults.maxDate instanceof Date)
                tp_inst._defaults.maxDateTime = new Date(tp_inst._defaults.maxDate.getTime());
            if (tp_inst._defaults.maxDateTime !== undefined && tp_inst._defaults.maxDateTime instanceof Date)
                tp_inst._defaults.maxDate = new Date(tp_inst._defaults.maxDateTime.getTime());
            return tp_inst;
        },

        //########################################################################
        // add our sliders to the calendar
        //########################################################################
        _addTimePicker: function (dp_inst) {
            var currDT = (this.$altInput && this._defaults.altFieldTimeOnly) ?
			this.$input.val() + ' ' + this.$altInput.val() :
			this.$input.val();

            this.timeDefined = this._parseTime(currDT);
            this._limitMinMaxDateTime(dp_inst, false);
            this._injectTimePicker();
        },

        //########################################################################
        // parse the time string from input value or _setTime
        //########################################################################
        _parseTime: function (timeString, withDate) {
            var regstr = this._defaults.timeFormat.toString()
			.replace(/h{1,2}/ig, '(\\d?\\d)')
			.replace(/m{1,2}/ig, '(\\d?\\d)')
			.replace(/s{1,2}/ig, '(\\d?\\d)')
			.replace(/l{1}/ig, '(\\d?\\d?\\d)')
			.replace(/t{1,2}/ig, this._getPatternAmpm())
			.replace(/z{1}/ig, '(z|[-+]\\d\\d:?\\d\\d)?')
			.replace(/\s/g, '\\s?') + this._defaults.timeSuffix + '$',
		order = this._getFormatPositions(),
		ampm = '',
		treg;

            if (!this.inst) this.inst = $.datepicker._getInst(this.$input[0]);

            if (withDate || !this._defaults.timeOnly) {
                // the time should come after x number of characters and a space.
                // x = at least the length of text specified by the date format
                var dp_dateFormat = $.datepicker._get(this.inst, 'dateFormat');
                // escape special regex characters in the seperator
                var specials = new RegExp("[.*+?|()\\[\\]{}\\\\]", "g");
                regstr = '^.{' + dp_dateFormat.length + ',}?' + this._defaults.separator.replace(specials, "\\$&") + regstr;
            }

            treg = timeString.match(new RegExp(regstr, 'i'));

            if (treg) {
                if (order.t !== -1) {
                    if (treg[order.t] === undefined || treg[order.t].length === 0) {
                        ampm = '';
                        this.ampm = '';
                    } else {
                        ampm = $.inArray(treg[order.t].toUpperCase(), this.amNames) !== -1 ? 'AM' : 'PM';
                        this.ampm = this._defaults[ampm == 'AM' ? 'amNames' : 'pmNames'][0];
                    }
                }

                if (order.h !== -1) {
                    if (ampm == 'AM' && treg[order.h] == '12')
                        this.hour = 0; // 12am = 0 hour
                    else if (ampm == 'PM' && treg[order.h] != '12')
                        this.hour = (parseFloat(treg[order.h]) + 12).toFixed(0); // 12pm = 12 hour, any other pm = hour + 12
                    else this.hour = Number(treg[order.h]);
                }

                if (order.m !== -1) this.minute = Number(treg[order.m]);
                if (order.s !== -1) this.second = Number(treg[order.s]);
                if (order.l !== -1) this.millisec = Number(treg[order.l]);
                if (order.z !== -1 && treg[order.z] !== undefined) {
                    var tz = treg[order.z].toUpperCase();
                    switch (tz.length) {
                        case 1: // Z
                            tz = this._defaults.timezoneIso8609 ? 'Z' : '+0000';
                            break;
                        case 5: // +hhmm
                            if (this._defaults.timezoneIso8609)
                                tz = tz.substring(1) == '0000'
						? 'Z'
						: tz.substring(0, 3) + ':' + tz.substring(3);
                            break;
                        case 6: // +hh:mm
                            if (!this._defaults.timezoneIso8609)
                                tz = tz == 'Z' || tz.substring(1) == '00:00'
						? '+0000'
						: tz.replace(/:/, '');
                            else if (tz.substring(1) == '00:00')
                                tz = 'Z';
                            break;
                    }
                    this.timezone = tz;
                }

                return true;

            }
            return false;
        },

        //########################################################################
        // pattern for standard and localized AM/PM markers
        //########################################################################
        _getPatternAmpm: function () {
            var markers = [];
            o = this._defaults;
            if (o.amNames)
                $.merge(markers, o.amNames);
            if (o.pmNames)
                $.merge(markers, o.pmNames);
            markers = $.map(markers, function (val) { return val.replace(/[.*+?|()\[\]{}\\]/g, '\\$&') });
            return '(' + markers.join('|') + ')?';
        },

        //########################################################################
        // figure out position of time elements.. cause js cant do named captures
        //########################################################################
        _getFormatPositions: function () {
            var finds = this._defaults.timeFormat.toLowerCase().match(/(h{1,2}|m{1,2}|s{1,2}|l{1}|t{1,2}|z)/g),
		orders = { h: -1, m: -1, s: -1, l: -1, t: -1, z: -1 };

            if (finds)
                for (var i = 0; i < finds.length; i++)
                    if (orders[finds[i].toString().charAt(0)] == -1)
                        orders[finds[i].toString().charAt(0)] = i + 1;

            return orders;
        },

        //########################################################################
        // generate and inject html for timepicker into ui datepicker
        //########################################################################
        _injectTimePicker: function () {
            var $dp = this.inst.dpDiv,
		o = this._defaults,
		tp_inst = this,
            // Added by Peter Medeiros:
            // - Figure out what the hour/minute/second max should be based on the step values.
            // - Example: if stepMinute is 15, then minMax is 45.
		hourMax = parseInt((o.hourMax - ((o.hourMax - o.hourMin) % o.stepHour)), 10),
		minMax = parseInt((o.minuteMax - ((o.minuteMax - o.minuteMin) % o.stepMinute)), 10),
		secMax = parseInt((o.secondMax - ((o.secondMax - o.secondMin) % o.stepSecond)), 10),
		millisecMax = parseInt((o.millisecMax - ((o.millisecMax - o.millisecMin) % o.stepMillisec)), 10),
		dp_id = this.inst.id.toString().replace(/([^A-Za-z0-9_])/g, '');

            // Prevent displaying twice
            //if ($dp.find("div#ui-timepicker-div-"+ dp_id).length === 0) {
            if ($dp.find("div#ui-timepicker-div-" + dp_id).length === 0 && o.showTimepicker) {
                var noDisplay = ' style="display:none;"',
			html = '<div class="ui-timepicker-div" id="ui-timepicker-div-' + dp_id + '"><dl>' +
					'<dt class="ui_tpicker_time_label" id="ui_tpicker_time_label_' + dp_id + '"' +
					((o.showTime) ? '' : noDisplay) + '>' + o.timeText + '</dt>' +
					'<dd class="ui_tpicker_time" id="ui_tpicker_time_' + dp_id + '"' +
					((o.showTime) ? '' : noDisplay) + '></dd>' +
					'<dt class="ui_tpicker_hour_label" id="ui_tpicker_hour_label_' + dp_id + '"' +
					((o.showHour) ? '' : noDisplay) + '>' + o.hourText + '</dt>',
			hourGridSize = 0,
			minuteGridSize = 0,
			secondGridSize = 0,
			millisecGridSize = 0,
			size;

                // Hours
                html += '<dd class="ui_tpicker_hour"><div id="ui_tpicker_hour_' + dp_id + '"' +
					((o.showHour) ? '' : noDisplay) + '></div>';
                if (o.showHour && o.hourGrid > 0) {
                    html += '<div style="padding-left: 1px"><table class="ui-tpicker-grid-label"><tr>';

                    for (var h = o.hourMin; h <= hourMax; h += parseInt(o.hourGrid, 10)) {
                        hourGridSize++;
                        var tmph = (o.ampm && h > 12) ? h - 12 : h;
                        if (tmph < 10) tmph = '0' + tmph;
                        if (o.ampm) {
                            if (h == 0) tmph = 12 + 'a';
                            else if (h < 12) tmph += 'a';
                            else tmph += 'p';
                        }
                        html += '<td>' + tmph + '</td>';
                    }

                    html += '</tr></table></div>';
                }
                html += '</dd>';

                // Minutes
                html += '<dt class="ui_tpicker_minute_label" id="ui_tpicker_minute_label_' + dp_id + '"' +
				((o.showMinute) ? '' : noDisplay) + '>' + o.minuteText + '</dt>' +
				'<dd class="ui_tpicker_minute"><div id="ui_tpicker_minute_' + dp_id + '"' +
						((o.showMinute) ? '' : noDisplay) + '></div>';

                if (o.showMinute && o.minuteGrid > 0) {
                    html += '<div style="padding-left: 1px"><table class="ui-tpicker-grid-label"><tr>';

                    for (var m = o.minuteMin; m <= minMax; m += parseInt(o.minuteGrid, 10)) {
                        minuteGridSize++;
                        html += '<td>' + ((m < 10) ? '0' : '') + m + '</td>';
                    }

                    html += '</tr></table></div>';
                }
                html += '</dd>';

                // Seconds
                html += '<dt class="ui_tpicker_second_label" id="ui_tpicker_second_label_' + dp_id + '"' +
				((o.showSecond) ? '' : noDisplay) + '>' + o.secondText + '</dt>' +
				'<dd class="ui_tpicker_second"><div id="ui_tpicker_second_' + dp_id + '"' +
						((o.showSecond) ? '' : noDisplay) + '></div>';

                if (o.showSecond && o.secondGrid > 0) {
                    html += '<div style="padding-left: 1px"><table><tr>';

                    for (var s = o.secondMin; s <= secMax; s += parseInt(o.secondGrid, 10)) {
                        secondGridSize++;
                        html += '<td>' + ((s < 10) ? '0' : '') + s + '</td>';
                    }

                    html += '</tr></table></div>';
                }
                html += '</dd>';

                // Milliseconds
                html += '<dt class="ui_tpicker_millisec_label" id="ui_tpicker_millisec_label_' + dp_id + '"' +
				((o.showMillisec) ? '' : noDisplay) + '>' + o.millisecText + '</dt>' +
				'<dd class="ui_tpicker_millisec"><div id="ui_tpicker_millisec_' + dp_id + '"' +
						((o.showMillisec) ? '' : noDisplay) + '></div>';

                if (o.showMillisec && o.millisecGrid > 0) {
                    html += '<div style="padding-left: 1px"><table><tr>';

                    for (var l = o.millisecMin; l <= millisecMax; l += parseInt(o.millisecGrid, 10)) {
                        millisecGridSize++;
                        html += '<td>' + ((l < 10) ? '0' : '') + l + '</td>';
                    }

                    html += '</tr></table></div>';
                }
                html += '</dd>';

                // Timezone
                html += '<dt class="ui_tpicker_timezone_label" id="ui_tpicker_timezone_label_' + dp_id + '"' +
				((o.showTimezone) ? '' : noDisplay) + '>' + o.timezoneText + '</dt>';
                html += '<dd class="ui_tpicker_timezone" id="ui_tpicker_timezone_' + dp_id + '"' +
						((o.showTimezone) ? '' : noDisplay) + '></dd>';

                html += '</dl></div>';
                $tp = $(html);

                // if we only want time picker...
                if (o.timeOnly === true) {
                    $tp.prepend(
				'<div class="ui-widget-header ui-helper-clearfix ui-corner-all">' +
					'<div class="ui-datepicker-title">' + o.timeOnlyTitle + '</div>' +
				'</div>');
                    $dp.find('.ui-datepicker-header, .ui-datepicker-calendar').hide();
                }

                this.hour_slider = $tp.find('#ui_tpicker_hour_' + dp_id).slider({
                    orientation: "horizontal",
                    value: this.hour,
                    min: o.hourMin,
                    max: hourMax,
                    step: o.stepHour,
                    slide: function (event, ui) {
                        tp_inst.hour_slider.slider("option", "value", ui.value);
                        tp_inst._onTimeChange();
                    }
                });


                // Updated by Peter Medeiros:
                // - Pass in Event and UI instance into slide function
                this.minute_slider = $tp.find('#ui_tpicker_minute_' + dp_id).slider({
                    orientation: "horizontal",
                    value: this.minute,
                    min: o.minuteMin,
                    max: minMax,
                    step: o.stepMinute,
                    slide: function (event, ui) {
                        tp_inst.minute_slider.slider("option", "value", ui.value);
                        tp_inst._onTimeChange();
                    }
                });

                this.second_slider = $tp.find('#ui_tpicker_second_' + dp_id).slider({
                    orientation: "horizontal",
                    value: this.second,
                    min: o.secondMin,
                    max: secMax,
                    step: o.stepSecond,
                    slide: function (event, ui) {
                        tp_inst.second_slider.slider("option", "value", ui.value);
                        tp_inst._onTimeChange();
                    }
                });

                this.millisec_slider = $tp.find('#ui_tpicker_millisec_' + dp_id).slider({
                    orientation: "horizontal",
                    value: this.millisec,
                    min: o.millisecMin,
                    max: millisecMax,
                    step: o.stepMillisec,
                    slide: function (event, ui) {
                        tp_inst.millisec_slider.slider("option", "value", ui.value);
                        tp_inst._onTimeChange();
                    }
                });

                this.timezone_select = $tp.find('#ui_tpicker_timezone_' + dp_id).append('<select></select>').find("select");
                $.fn.append.apply(this.timezone_select,
			$.map(o.timezoneList, function (val, idx) {
			    return $("<option />")
					.val(typeof val == "object" ? val.value : val)
					.text(typeof val == "object" ? val.label : val);
			})
		);
                this.timezone_select.val((typeof this.timezone != "undefined" && this.timezone != null && this.timezone != "") ? this.timezone : o.timezone);
                this.timezone_select.change(function () {
                    tp_inst._onTimeChange();
                });

                // Add grid functionality
                if (o.showHour && o.hourGrid > 0) {
                    size = 100 * hourGridSize * o.hourGrid / (hourMax - o.hourMin);

                    $tp.find(".ui_tpicker_hour table").css({
                        width: size + "%",
                        marginLeft: (size / (-2 * hourGridSize)) + "%",
                        borderCollapse: 'collapse'
                    }).find("td").each(function (index) {
                        $(this).click(function () {
                            var h = $(this).html();
                            if (o.ampm) {
                                var ap = h.substring(2).toLowerCase(),
							aph = parseInt(h.substring(0, 2), 10);
                                if (ap == 'a') {
                                    if (aph == 12) h = 0;
                                    else h = aph;
                                } else if (aph == 12) h = 12;
                                else h = aph + 12;
                            }
                            tp_inst.hour_slider.slider("option", "value", h);
                            tp_inst._onTimeChange();
                            tp_inst._onSelectHandler();
                        }).css({
                            cursor: 'pointer',
                            width: (100 / hourGridSize) + '%',
                            textAlign: 'center',
                            overflow: 'hidden'
                        });
                    });
                }

                if (o.showMinute && o.minuteGrid > 0) {
                    size = 100 * minuteGridSize * o.minuteGrid / (minMax - o.minuteMin);
                    $tp.find(".ui_tpicker_minute table").css({
                        width: size + "%",
                        marginLeft: (size / (-2 * minuteGridSize)) + "%",
                        borderCollapse: 'collapse'
                    }).find("td").each(function (index) {
                        $(this).click(function () {
                            tp_inst.minute_slider.slider("option", "value", $(this).html());
                            tp_inst._onTimeChange();
                            tp_inst._onSelectHandler();
                        }).css({
                            cursor: 'pointer',
                            width: (100 / minuteGridSize) + '%',
                            textAlign: 'center',
                            overflow: 'hidden'
                        });
                    });
                }

                if (o.showSecond && o.secondGrid > 0) {
                    $tp.find(".ui_tpicker_second table").css({
                        width: size + "%",
                        marginLeft: (size / (-2 * secondGridSize)) + "%",
                        borderCollapse: 'collapse'
                    }).find("td").each(function (index) {
                        $(this).click(function () {
                            tp_inst.second_slider.slider("option", "value", $(this).html());
                            tp_inst._onTimeChange();
                            tp_inst._onSelectHandler();
                        }).css({
                            cursor: 'pointer',
                            width: (100 / secondGridSize) + '%',
                            textAlign: 'center',
                            overflow: 'hidden'
                        });
                    });
                }

                if (o.showMillisec && o.millisecGrid > 0) {
                    $tp.find(".ui_tpicker_millisec table").css({
                        width: size + "%",
                        marginLeft: (size / (-2 * millisecGridSize)) + "%",
                        borderCollapse: 'collapse'
                    }).find("td").each(function (index) {
                        $(this).click(function () {
                            tp_inst.millisec_slider.slider("option", "value", $(this).html());
                            tp_inst._onTimeChange();
                            tp_inst._onSelectHandler();
                        }).css({
                            cursor: 'pointer',
                            width: (100 / millisecGridSize) + '%',
                            textAlign: 'center',
                            overflow: 'hidden'
                        });
                    });
                }

                var $buttonPanel = $dp.find('.ui-datepicker-buttonpane');
                if ($buttonPanel.length) $buttonPanel.before($tp);
                else $dp.append($tp);

                this.$timeObj = $tp.find('#ui_tpicker_time_' + dp_id);

                if (this.inst !== null) {
                    var timeDefined = this.timeDefined;
                    this._onTimeChange();
                    this.timeDefined = timeDefined;
                }

                //Emulate datepicker onSelect behavior. Call on slidestop.
                var onSelectDelegate = function () {
                    tp_inst._onSelectHandler();
                };
                this.hour_slider.bind('slidestop', onSelectDelegate);
                this.minute_slider.bind('slidestop', onSelectDelegate);
                this.second_slider.bind('slidestop', onSelectDelegate);
                this.millisec_slider.bind('slidestop', onSelectDelegate);

                // slideAccess integration: http://trentrichardson.com/2011/11/11/jquery-ui-sliders-and-touch-accessibility/
                if (this._defaults.addSliderAccess) {
                    var sliderAccessArgs = this._defaults.sliderAccessArgs;
                    setTimeout(function () { // fix for inline mode
                        if ($tp.find('.ui-slider-access').length == 0) {
                            $tp.find('.ui-slider:visible').sliderAccess(sliderAccessArgs);

                            // fix any grids since sliders are shorter
                            var sliderAccessWidth = $tp.find('.ui-slider-access:eq(0)').outerWidth(true);
                            if (sliderAccessWidth) {
                                $tp.find('table:visible').each(function () {
                                    var $g = $(this),
								oldWidth = $g.outerWidth(),
								oldMarginLeft = $g.css('marginLeft').toString().replace('%', ''),
								newWidth = oldWidth - sliderAccessWidth,
								newMarginLeft = ((oldMarginLeft * newWidth) / oldWidth) + '%';

                                    $g.css({ width: newWidth, marginLeft: newMarginLeft });
                                });
                            }
                        }
                    }, 0);
                }
                // end slideAccess integration

            }
        },

        //########################################################################
        // This function tries to limit the ability to go outside the
        // min/max date range
        //########################################################################
        _limitMinMaxDateTime: function (dp_inst, adjustSliders) {
            var o = this._defaults,
		dp_date = new Date(dp_inst.selectedYear, dp_inst.selectedMonth, dp_inst.selectedDay);

            if (!this._defaults.showTimepicker) return; // No time so nothing to check here

            if ($.datepicker._get(dp_inst, 'minDateTime') !== null && $.datepicker._get(dp_inst, 'minDateTime') !== undefined && dp_date) {
                var minDateTime = $.datepicker._get(dp_inst, 'minDateTime'),
			minDateTimeDate = new Date(minDateTime.getFullYear(), minDateTime.getMonth(), minDateTime.getDate(), 0, 0, 0, 0);

                if (this.hourMinOriginal === null || this.minuteMinOriginal === null || this.secondMinOriginal === null || this.millisecMinOriginal === null) {
                    this.hourMinOriginal = o.hourMin;
                    this.minuteMinOriginal = o.minuteMin;
                    this.secondMinOriginal = o.secondMin;
                    this.millisecMinOriginal = o.millisecMin;
                }

                if (dp_inst.settings.timeOnly || minDateTimeDate.getTime() == dp_date.getTime()) {
                    this._defaults.hourMin = minDateTime.getHours();
                    if (this.hour <= this._defaults.hourMin) {
                        this.hour = this._defaults.hourMin;
                        this._defaults.minuteMin = minDateTime.getMinutes();
                        if (this.minute <= this._defaults.minuteMin) {
                            this.minute = this._defaults.minuteMin;
                            this._defaults.secondMin = minDateTime.getSeconds();
                        } else if (this.second <= this._defaults.secondMin) {
                            this.second = this._defaults.secondMin;
                            this._defaults.millisecMin = minDateTime.getMilliseconds();
                        } else {
                            if (this.millisec < this._defaults.millisecMin)
                                this.millisec = this._defaults.millisecMin;
                            this._defaults.millisecMin = this.millisecMinOriginal;
                        }
                    } else {
                        this._defaults.minuteMin = this.minuteMinOriginal;
                        this._defaults.secondMin = this.secondMinOriginal;
                        this._defaults.millisecMin = this.millisecMinOriginal;
                    }
                } else {
                    this._defaults.hourMin = this.hourMinOriginal;
                    this._defaults.minuteMin = this.minuteMinOriginal;
                    this._defaults.secondMin = this.secondMinOriginal;
                    this._defaults.millisecMin = this.millisecMinOriginal;
                }
            }

            if ($.datepicker._get(dp_inst, 'maxDateTime') !== null && $.datepicker._get(dp_inst, 'maxDateTime') !== undefined && dp_date) {
                var maxDateTime = $.datepicker._get(dp_inst, 'maxDateTime'),
			maxDateTimeDate = new Date(maxDateTime.getFullYear(), maxDateTime.getMonth(), maxDateTime.getDate(), 0, 0, 0, 0);

                if (this.hourMaxOriginal === null || this.minuteMaxOriginal === null || this.secondMaxOriginal === null) {
                    this.hourMaxOriginal = o.hourMax;
                    this.minuteMaxOriginal = o.minuteMax;
                    this.secondMaxOriginal = o.secondMax;
                    this.millisecMaxOriginal = o.millisecMax;
                }

                if (dp_inst.settings.timeOnly || maxDateTimeDate.getTime() == dp_date.getTime()) {
                    this._defaults.hourMax = maxDateTime.getHours();
                    if (this.hour >= this._defaults.hourMax) {
                        this.hour = this._defaults.hourMax;
                        this._defaults.minuteMax = maxDateTime.getMinutes();
                        if (this.minute >= this._defaults.minuteMax) {
                            this.minute = this._defaults.minuteMax;
                            this._defaults.secondMax = maxDateTime.getSeconds();
                        } else if (this.second >= this._defaults.secondMax) {
                            this.second = this._defaults.secondMax;
                            this._defaults.millisecMax = maxDateTime.getMilliseconds();
                        } else {
                            if (this.millisec > this._defaults.millisecMax) this.millisec = this._defaults.millisecMax;
                            this._defaults.millisecMax = this.millisecMaxOriginal;
                        }
                    } else {
                        this._defaults.minuteMax = this.minuteMaxOriginal;
                        this._defaults.secondMax = this.secondMaxOriginal;
                        this._defaults.millisecMax = this.millisecMaxOriginal;
                    }
                } else {
                    this._defaults.hourMax = this.hourMaxOriginal;
                    this._defaults.minuteMax = this.minuteMaxOriginal;
                    this._defaults.secondMax = this.secondMaxOriginal;
                    this._defaults.millisecMax = this.millisecMaxOriginal;
                }
            }

            if (adjustSliders !== undefined && adjustSliders === true) {
                var hourMax = parseInt((this._defaults.hourMax - ((this._defaults.hourMax - this._defaults.hourMin) % this._defaults.stepHour)), 10),
            minMax = parseInt((this._defaults.minuteMax - ((this._defaults.minuteMax - this._defaults.minuteMin) % this._defaults.stepMinute)), 10),
            secMax = parseInt((this._defaults.secondMax - ((this._defaults.secondMax - this._defaults.secondMin) % this._defaults.stepSecond)), 10),
			millisecMax = parseInt((this._defaults.millisecMax - ((this._defaults.millisecMax - this._defaults.millisecMin) % this._defaults.stepMillisec)), 10);

                if (this.hour_slider)
                    this.hour_slider.slider("option", { min: this._defaults.hourMin, max: hourMax }).slider('value', this.hour);
                if (this.minute_slider)
                    this.minute_slider.slider("option", { min: this._defaults.minuteMin, max: minMax }).slider('value', this.minute);
                if (this.second_slider)
                    this.second_slider.slider("option", { min: this._defaults.secondMin, max: secMax }).slider('value', this.second);
                if (this.millisec_slider)
                    this.millisec_slider.slider("option", { min: this._defaults.millisecMin, max: millisecMax }).slider('value', this.millisec);
            }

        },


        //########################################################################
        // when a slider moves, set the internal time...
        // on time change is also called when the time is updated in the text field
        //########################################################################
        _onTimeChange: function () {
            var hour = (this.hour_slider) ? this.hour_slider.slider('value') : false,
		minute = (this.minute_slider) ? this.minute_slider.slider('value') : false,
		second = (this.second_slider) ? this.second_slider.slider('value') : false,
		millisec = (this.millisec_slider) ? this.millisec_slider.slider('value') : false,
		timezone = (this.timezone_select) ? this.timezone_select.val() : false,
		o = this._defaults;

            if (typeof (hour) == 'object') hour = false;
            if (typeof (minute) == 'object') minute = false;
            if (typeof (second) == 'object') second = false;
            if (typeof (millisec) == 'object') millisec = false;
            if (typeof (timezone) == 'object') timezone = false;

            if (hour !== false) hour = parseInt(hour, 10);
            if (minute !== false) minute = parseInt(minute, 10);
            if (second !== false) second = parseInt(second, 10);
            if (millisec !== false) millisec = parseInt(millisec, 10);

            var ampm = o[hour < 12 ? 'amNames' : 'pmNames'][0];

            // If the update was done in the input field, the input field should not be updated.
            // If the update was done using the sliders, update the input field.
            var hasChanged = (hour != this.hour || minute != this.minute
			|| second != this.second || millisec != this.millisec
			|| (this.ampm.length > 0
				&& (hour < 12) != ($.inArray(this.ampm.toUpperCase(), this.amNames) !== -1))
			|| timezone != this.timezone);

            if (hasChanged) {

                if (hour !== false) this.hour = hour;
                if (minute !== false) this.minute = minute;
                if (second !== false) this.second = second;
                if (millisec !== false) this.millisec = millisec;
                if (timezone !== false) this.timezone = timezone;

                if (!this.inst) this.inst = $.datepicker._getInst(this.$input[0]);

                this._limitMinMaxDateTime(this.inst, true);
            }
            if (o.ampm) this.ampm = ampm;

            //this._formatTime();
            this.formattedTime = $.datepicker.formatTime(this._defaults.timeFormat, this, this._defaults);
            if (this.$timeObj) this.$timeObj.text(this.formattedTime + o.timeSuffix);
            this.timeDefined = true;
            if (hasChanged) this._updateDateTime();
        },

        //########################################################################
        // call custom onSelect. 
        // bind to sliders slidestop, and grid click.
        //########################################################################
        _onSelectHandler: function () {
            var onSelect = this._defaults.onSelect;
            var inputEl = this.$input ? this.$input[0] : null;
            if (onSelect && inputEl) {
                onSelect.apply(inputEl, [this.formattedDateTime, this]);
            }
        },

        //########################################################################
        // left for any backwards compatibility
        //########################################################################
        _formatTime: function (time, format) {
            time = time || { hour: this.hour, minute: this.minute, second: this.second, millisec: this.millisec, ampm: this.ampm, timezone: this.timezone };
            var tmptime = (format || this._defaults.timeFormat).toString();

            tmptime = $.datepicker.formatTime(tmptime, time, this._defaults);

            if (arguments.length) return tmptime;
            else this.formattedTime = tmptime;
        },

        //########################################################################
        // update our input with the new date time..
        //########################################################################
        _updateDateTime: function (dp_inst) {
            dp_inst = this.inst || dp_inst;
            var dt = $.datepicker._daylightSavingAdjust(new Date(dp_inst.selectedYear, dp_inst.selectedMonth, dp_inst.selectedDay)),
		dateFmt = $.datepicker._get(dp_inst, 'dateFormat'),
		formatCfg = $.datepicker._getFormatConfig(dp_inst),
		timeAvailable = dt !== null && this.timeDefined;
            this.formattedDate = $.datepicker.formatDate(dateFmt, (dt === null ? new Date() : dt), formatCfg);
            var formattedDateTime = this.formattedDate;
            if (dp_inst.lastVal !== undefined && (dp_inst.lastVal.length > 0 && this.$input.val().length === 0))
                return;

            if (this._defaults.timeOnly === true) {
                formattedDateTime = this.formattedTime;
            } else if (this._defaults.timeOnly !== true && (this._defaults.alwaysSetTime || timeAvailable)) {
                formattedDateTime += this._defaults.separator + this.formattedTime + this._defaults.timeSuffix;
            }

            this.formattedDateTime = formattedDateTime;

            if (!this._defaults.showTimepicker) {
                this.$input.val(this.formattedDate);
            } else if (this.$altInput && this._defaults.altFieldTimeOnly === true) {
                this.$altInput.val(this.formattedTime);
                this.$input.val(this.formattedDate);
            } else if (this.$altInput) {
                this.$altInput.val(formattedDateTime);
                this.$input.val(formattedDateTime);
            } else {
                this.$input.val(formattedDateTime);
            }

            this.$input.trigger("change");
        }

    });

    $.fn.extend({
        //########################################################################
        // shorthand just to use timepicker..
        //########################################################################
        timepicker: function (o) {
            o = o || {};
            var tmp_args = arguments;

            if (typeof o == 'object') tmp_args[0] = $.extend(o, { timeOnly: true });

            return $(this).each(function () {
                $.fn.datetimepicker.apply($(this), tmp_args);
            });
        },

        //########################################################################
        // extend timepicker to datepicker
        //########################################################################
        datetimepicker: function (o) {
            o = o || {};
            var $input = this,
	tmp_args = arguments;

            if (typeof (o) == 'string') {
                if (o == 'getDate')
                    return $.fn.datepicker.apply($(this[0]), tmp_args);
                else
                    return this.each(function () {
                        var $t = $(this);
                        $t.datepicker.apply($t, tmp_args);
                    });
            }
            else
                return this.each(function () {
                    var $t = $(this);
                    $t.datepicker($.timepicker._newInst($t, o)._defaults);
                });
        }
    });

    //########################################################################
    // format the time all pretty... 
    // format = string format of the time
    // time = a {}, not a Date() for timezones
    // options = essentially the regional[].. amNames, pmNames, ampm
    //########################################################################
    $.datepicker.formatTime = function (format, time, options) {
        options = options || {};
        options = $.extend($.timepicker._defaults, options);
        time = $.extend({ hour: 0, minute: 0, second: 0, millisec: 0, timezone: '+0000' }, time);

        var tmptime = format;
        var ampmName = options['amNames'][0];

        var hour = parseInt(time.hour, 10);
        if (options.ampm) {
            if (hour > 11) {
                ampmName = options['pmNames'][0];
                if (hour > 12)
                    hour = hour % 12;
            }
            if (hour === 0)
                hour = 12;
        }
        tmptime = tmptime.replace(/(?:hh?|mm?|ss?|[tT]{1,2}|[lz])/g, function (match) {
            switch (match.toLowerCase()) {
                case 'hh': return ('0' + hour).slice(-2);
                case 'h': return hour;
                case 'mm': return ('0' + time.minute).slice(-2);
                case 'm': return time.minute;
                case 'ss': return ('0' + time.second).slice(-2);
                case 's': return time.second;
                case 'l': return ('00' + time.millisec).slice(-3);
                case 'z': return time.timezone;
                case 't': case 'tt':
                    if (options.ampm) {
                        if (match.length == 1)
                            ampmName = ampmName.charAt(0);
                        return match.charAt(0) == 'T' ? ampmName.toUpperCase() : ampmName.toLowerCase();
                    }
                    return '';
            }
        });

        tmptime = $.trim(tmptime);
        return tmptime;
    }

    //########################################################################
    // the bad hack :/ override datepicker so it doesnt close on select
    // inspired: http://stackoverflow.com/questions/1252512/jquery-datepicker-prevent-closing-picker-when-clicking-a-date/1762378#1762378
    //########################################################################
    $.datepicker._base_selectDate = $.datepicker._selectDate;
    $.datepicker._selectDate = function (id, dateStr) {
        var inst = this._getInst($(id)[0]),
	tp_inst = this._get(inst, 'timepicker');

        if (tp_inst) {
            tp_inst._limitMinMaxDateTime(inst, true);
            inst.inline = inst.stay_open = true;
            //This way the onSelect handler called from calendarpicker get the full dateTime
            this._base_selectDate(id, dateStr);
            inst.inline = inst.stay_open = false;
            this._notifyChange(inst);
            this._updateDatepicker(inst);
        }
        else this._base_selectDate(id, dateStr);
    };

    //#############################################################################################
    // second bad hack :/ override datepicker so it triggers an event when changing the input field
    // and does not redraw the datepicker on every selectDate event
    //#############################################################################################
    $.datepicker._base_updateDatepicker = $.datepicker._updateDatepicker;
    $.datepicker._updateDatepicker = function (inst) {

        // don't popup the datepicker if there is another instance already opened
        var input = inst.input[0];
        if ($.datepicker._curInst &&
	$.datepicker._curInst != inst &&
	$.datepicker._datepickerShowing &&
	$.datepicker._lastInput != input) {
            return;
        }

        if (typeof (inst.stay_open) !== 'boolean' || inst.stay_open === false) {

            this._base_updateDatepicker(inst);

            // Reload the time control when changing something in the input text field.
            var tp_inst = this._get(inst, 'timepicker');
            if (tp_inst) tp_inst._addTimePicker(inst);
        }
    };

    //#######################################################################################
    // third bad hack :/ override datepicker so it allows spaces and colon in the input field
    //#######################################################################################
    $.datepicker._base_doKeyPress = $.datepicker._doKeyPress;
    $.datepicker._doKeyPress = function (event) {
        var inst = $.datepicker._getInst(event.target),
	tp_inst = $.datepicker._get(inst, 'timepicker');

        if (tp_inst) {
            if ($.datepicker._get(inst, 'constrainInput')) {
                var ampm = tp_inst._defaults.ampm,
			dateChars = $.datepicker._possibleChars($.datepicker._get(inst, 'dateFormat')),
			datetimeChars = tp_inst._defaults.timeFormat.toString()
							.replace(/[hms]/g, '')
							.replace(/TT/g, ampm ? 'APM' : '')
							.replace(/Tt/g, ampm ? 'AaPpMm' : '')
							.replace(/tT/g, ampm ? 'AaPpMm' : '')
							.replace(/T/g, ampm ? 'AP' : '')
							.replace(/tt/g, ampm ? 'apm' : '')
							.replace(/t/g, ampm ? 'ap' : '') +
							" " +
							tp_inst._defaults.separator +
							tp_inst._defaults.timeSuffix +
							(tp_inst._defaults.showTimezone ? tp_inst._defaults.timezoneList.join('') : '') +
							(tp_inst._defaults.amNames.join('')) +
							(tp_inst._defaults.pmNames.join('')) +
							dateChars,
			chr = String.fromCharCode(event.charCode === undefined ? event.keyCode : event.charCode);
                return event.ctrlKey || (chr < ' ' || !dateChars || datetimeChars.indexOf(chr) > -1);
            }
        }

        return $.datepicker._base_doKeyPress(event);
    };

    //#######################################################################################
    // Override key up event to sync manual input changes.
    //#######################################################################################
    $.datepicker._base_doKeyUp = $.datepicker._doKeyUp;
    $.datepicker._doKeyUp = function (event) {
        var inst = $.datepicker._getInst(event.target),
	tp_inst = $.datepicker._get(inst, 'timepicker');

        if (tp_inst) {
            if (tp_inst._defaults.timeOnly && (inst.input.val() != inst.lastVal)) {
                try {
                    $.datepicker._updateDatepicker(inst);
                }
                catch (err) {
                    $.datepicker.log(err);
                }
            }
        }

        return $.datepicker._base_doKeyUp(event);
    };

    //#######################################################################################
    // override "Today" button to also grab the time.
    //#######################################################################################
    $.datepicker._base_gotoToday = $.datepicker._gotoToday;
    $.datepicker._gotoToday = function (id) {
        var inst = this._getInst($(id)[0]),
	$dp = inst.dpDiv;
        this._base_gotoToday(id);
        var now = new Date();
        var tp_inst = this._get(inst, 'timepicker');
        if (tp_inst && tp_inst._defaults.showTimezone && tp_inst.timezone_select) {
            var tzoffset = now.getTimezoneOffset(); // If +0100, returns -60
            var tzsign = tzoffset > 0 ? '-' : '+';
            tzoffset = Math.abs(tzoffset);
            var tzmin = tzoffset % 60;
            tzoffset = tzsign + ('0' + (tzoffset - tzmin) / 60).slice(-2) + ('0' + tzmin).slice(-2);
            if (tp_inst._defaults.timezoneIso8609)
                tzoffset = tzoffset.substring(0, 3) + ':' + tzoffset.substring(3);
            tp_inst.timezone_select.val(tzoffset);
        }
        this._setTime(inst, now);
        $('.ui-datepicker-today', $dp).click();
    };

    //#######################################################################################
    // Disable & enable the Time in the datetimepicker
    //#######################################################################################
    $.datepicker._disableTimepickerDatepicker = function (target, date, withDate) {
        var inst = this._getInst(target),
tp_inst = this._get(inst, 'timepicker');
        $(target).datepicker('getDate'); // Init selected[Year|Month|Day]
        if (tp_inst) {
            tp_inst._defaults.showTimepicker = false;
            tp_inst._updateDateTime(inst);
        }
    };

    $.datepicker._enableTimepickerDatepicker = function (target, date, withDate) {
        var inst = this._getInst(target),
tp_inst = this._get(inst, 'timepicker');
        $(target).datepicker('getDate'); // Init selected[Year|Month|Day]
        if (tp_inst) {
            tp_inst._defaults.showTimepicker = true;
            tp_inst._addTimePicker(inst); // Could be disabled on page load
            tp_inst._updateDateTime(inst);
        }
    };

    //#######################################################################################
    // Create our own set time function
    //#######################################################################################
    $.datepicker._setTime = function (inst, date) {
        var tp_inst = this._get(inst, 'timepicker');
        if (tp_inst) {
            var defaults = tp_inst._defaults,
            // calling _setTime with no date sets time to defaults
		hour = date ? date.getHours() : defaults.hour,
		minute = date ? date.getMinutes() : defaults.minute,
		second = date ? date.getSeconds() : defaults.second,
		millisec = date ? date.getMilliseconds() : defaults.millisec;

            //check if within min/max times..
            if ((hour < defaults.hourMin || hour > defaults.hourMax) || (minute < defaults.minuteMin || minute > defaults.minuteMax) || (second < defaults.secondMin || second > defaults.secondMax) || (millisec < defaults.millisecMin || millisec > defaults.millisecMax)) {
                hour = defaults.hourMin;
                minute = defaults.minuteMin;
                second = defaults.secondMin;
                millisec = defaults.millisecMin;
            }

            tp_inst.hour = hour;
            tp_inst.minute = minute;
            tp_inst.second = second;
            tp_inst.millisec = millisec;

            if (tp_inst.hour_slider) tp_inst.hour_slider.slider('value', hour);
            if (tp_inst.minute_slider) tp_inst.minute_slider.slider('value', minute);
            if (tp_inst.second_slider) tp_inst.second_slider.slider('value', second);
            if (tp_inst.millisec_slider) tp_inst.millisec_slider.slider('value', millisec);

            tp_inst._onTimeChange();
            tp_inst._updateDateTime(inst);
        }
    };

    //#######################################################################################
    // Create new public method to set only time, callable as $().datepicker('setTime', date)
    //#######################################################################################
    $.datepicker._setTimeDatepicker = function (target, date, withDate) {
        var inst = this._getInst(target),
	tp_inst = this._get(inst, 'timepicker');

        if (tp_inst) {
            this._setDateFromField(inst);
            var tp_date;
            if (date) {
                if (typeof date == "string") {
                    tp_inst._parseTime(date, withDate);
                    tp_date = new Date();
                    tp_date.setHours(tp_inst.hour, tp_inst.minute, tp_inst.second, tp_inst.millisec);
                }
                else tp_date = new Date(date.getTime());
                if (tp_date.toString() == 'Invalid Date') tp_date = undefined;
                this._setTime(inst, tp_date);
            }
        }

    };

    //#######################################################################################
    // override setDate() to allow setting time too within Date object
    //#######################################################################################
    $.datepicker._base_setDateDatepicker = $.datepicker._setDateDatepicker;
    $.datepicker._setDateDatepicker = function (target, date) {
        var inst = this._getInst(target),
tp_date = (date instanceof Date) ? new Date(date.getTime()) : date;

        this._updateDatepicker(inst);
        this._base_setDateDatepicker.apply(this, arguments);
        this._setTimeDatepicker(target, tp_date, true);
    };

    //#######################################################################################
    // override getDate() to allow getting time too within Date object
    //#######################################################################################
    $.datepicker._base_getDateDatepicker = $.datepicker._getDateDatepicker;
    $.datepicker._getDateDatepicker = function (target, noDefault) {
        var inst = this._getInst(target),
	tp_inst = this._get(inst, 'timepicker');

        if (tp_inst) {
            this._setDateFromField(inst, noDefault);
            var date = this._getDate(inst);
            if (date && tp_inst._parseTime($(target).val(), tp_inst.timeOnly)) date.setHours(tp_inst.hour, tp_inst.minute, tp_inst.second, tp_inst.millisec);
            return date;
        }
        return this._base_getDateDatepicker(target, noDefault);
    };

    //#######################################################################################
    // override parseDate() because UI 1.8.14 throws an error about "Extra characters"
    // An option in datapicker to ignore extra format characters would be nicer.
    //#######################################################################################
    $.datepicker._base_parseDate = $.datepicker.parseDate;
    $.datepicker.parseDate = function (format, value, settings) {
        var date;
        try {
            date = this._base_parseDate(format, value, settings);
        } catch (err) {
            if (err.indexOf(":") >= 0) {
                // Hack!  The error message ends with a colon, a space, and
                // the "extra" characters.  We rely on that instead of
                // attempting to perfectly reproduce the parsing algorithm.
                date = this._base_parseDate(format, value.substring(0, value.length - (err.length - err.indexOf(':') - 2)), settings);
            } else {
                // The underlying error was not related to the time
                throw err;
            }
        }
        return date;
    };

    //#######################################################################################
    // override formatDate to set date with time to the input
    //#######################################################################################
    $.datepicker._base_formatDate = $.datepicker._formatDate;
    $.datepicker._formatDate = function (inst, day, month, year) {
        var tp_inst = this._get(inst, 'timepicker');
        if (tp_inst) {
            if (day)
                var b = this._base_formatDate(inst, day, month, year);
            tp_inst._updateDateTime(inst);
            return tp_inst.$input.val();
        }
        return this._base_formatDate(inst);
    };

    //#######################################################################################
    // override options setter to add time to maxDate(Time) and minDate(Time). MaxDate
    //#######################################################################################
    $.datepicker._base_optionDatepicker = $.datepicker._optionDatepicker;
    $.datepicker._optionDatepicker = function (target, name, value) {
        var inst = this._getInst(target),
	tp_inst = this._get(inst, 'timepicker');
        if (tp_inst) {
            var min, max, onselect;
            if (typeof name == 'string') { // if min/max was set with the string
                if (name === 'minDate' || name === 'minDateTime')
                    min = value;
                else if (name === 'maxDate' || name === 'maxDateTime')
                    max = value;
                else if (name === 'onSelect')
                    onselect = value;
            } else if (typeof name == 'object') { //if min/max was set with the JSON
                if (name.minDate)
                    min = name.minDate;
                else if (name.minDateTime)
                    min = name.minDateTime;
                else if (name.maxDate)
                    max = name.maxDate;
                else if (name.maxDateTime)
                    max = name.maxDateTime;
            }
            if (min) { //if min was set
                if (min == 0)
                    min = new Date();
                else
                    min = new Date(min);

                tp_inst._defaults.minDate = min;
                tp_inst._defaults.minDateTime = min;
            } else if (max) { //if max was set
                if (max == 0)
                    max = new Date();
                else
                    max = new Date(max);
                tp_inst._defaults.maxDate = max;
                tp_inst._defaults.maxDateTime = max;
            }
            else if (onselect)
                tp_inst._defaults.onSelect = onselect;
        }
        if (value === undefined)
            return this._base_optionDatepicker(target, name);
        return this._base_optionDatepicker(target, name, value);
    };

    //#######################################################################################
    // jQuery extend now ignores nulls!
    //#######################################################################################
    function extendRemove(target, props) {
        $.extend(target, props);
        for (var name in props)
            if (props[name] === null || props[name] === undefined)
                target[name] = props[name];
        return target;
    };

    $.timepicker = new Timepicker(); // singleton instance
    $.timepicker.version = "0.9.9";

})(jQuery);

/*End of third party scripts*/
/*Mpage Modal Dialog Scripting*/
/**
* The ModalDialog object contains information about the aspects of how the modal dialog will be created and what actions will take
* place.  Depending on how the variables are set, the modal can flex based on the consumers needs.  Customizable options include the following;
* size, modal title, onClose function, modal body content, variable footer buttons with dither options and onclick events.
* @constructor
*/
function ModalDialog(modalId) {
    //The id given to the ModalDialog object.  Will be used to set/retrieve the modal dialog
    this.m_modalId = modalId;
    //A flag used to determine if the modal is active or not
    this.m_isModalActive = false;
    //A flag to determine if the modal should be fixed to the icon used to activate the modal
    this.m_isFixedToIcon = false;
    //A flag to determine if the modal dialog should grey out the background when being displayed or not.
    this.m_hasGrayBackground = true;
    //A flag to determine if the close icon should be shown or not
    this.m_showCloseIcon = true;

    //The margins object contains the margins that will be applied to the modal window.
    this.m_margins = {
        top: 5,
        right: 5,
        bottom: 5,
        left: 5
    };

    //The icon object contains information about the icon that the user will use to launch the modal dialog
    this.m_icon = {
        elementId: modalId + "icon",
        cssClass: "",
        text: "",
        hoverText: "",
        isActive: true
    };

    //The header object of the modal.  Contains all of the necessary information to render the header of the dialog
    this.m_header = {
        elementId: modalId + "header",
        title: "",
        closeFunction: null
    };

    //The body object of the modal.  Contains all of the necessary information to render the body of the dialog
    this.m_body = {
        elementId: modalId + "body",
        dataFunction: null,
        isBodySizeFixed: true
    };

    //The footer object of the modal.  Contains all of the necessary information to render the footer of the dialog
    this.m_footer = {
        isAlwaysShown: false,
        elementId: modalId + "footer",
        buttons: []
    };
}

/** Adders **/

/**
* Adds a ModalButton object to the list of buttons that will be used in the footer of to modal dialog.
* Only ModalButtons will be used, no other object type will be accepted.
* @param {ModalButton} modalButton The button to add to the footer.
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.addFooterButton = function (modalButton) {
    if (!(modalButton instanceof ModalButton)) {
        MP_Util.LogError("ModalDialog.addFooterButton: Cannot add footer button which isnt a ModalButton object.\nModalButtons can be created using the ModalDialog.createModalButton function.");
        return this;
    }

    if (!modalButton.getId()) {
        MP_Util.LogError("ModalDialog.addFooterButton: All ModalButton objects must have an id assigned");
        return this;
    }

    this.m_footer.buttons.push(modalButton);
    return this;
};

/** Checkers **/

/**
* Checks to see if the modal dialog object has a gray background or not
* @return {boolean} True if the modal dialog is active, false otherwise
*/
ModalDialog.prototype.hasGrayBackground = function () {
    return this.m_hasGrayBackground;
};

/**
* Checks to see if the modal dialog object is active or not
* @return {boolean} True if the modal dialog is active, false otherwise
*/
ModalDialog.prototype.isActive = function () {
    return this.m_isModalActive;
};

/**
* Checks to see if the modal dialog body should have a fixed size or not
* @return {boolean} True if the modal dialog body is a fixed size, false otherwise
*/
ModalDialog.prototype.isBodySizeFixed = function () {
    return this.m_body.isBodySizeFixed;
};

/**
* Checks to see if the modal dialog footer should always be shown or not
* @return {boolean} True if the modal dialog footer should always be shown
*/
ModalDialog.prototype.isFooterAlwaysShown = function () {
    return this.m_footer.isAlwaysShown;
};

/**
* Checks to see if the modal dialog object is active or not
* @return {boolean} True if the modal dialog is active, false otherwise
*/
ModalDialog.prototype.isFixedToIcon = function () {
    return this.m_isFixedToIcon;
};

/**
* Checks to see if the modal dialog icon is active or not
* @return {boolean} True if the modal dialog icon is active, false otherwise
*/
ModalDialog.prototype.isIconActive = function () {
    return this.m_icon.isActive;
};

/**
* Checks to see if the close icon should be shown in the modal dialog
* @return {boolean} True if the close icon should be shown, false otherwise
*/
ModalDialog.prototype.showCloseIcon = function () {
    return this.m_showCloseIcon;
};

/** Getters **/

/**
* Retrieves the function that will be used when attempting to populate the content of the modal dialog body.
* @return {function} The function used when loading the modal dialog body
*/
ModalDialog.prototype.getBodyDataFunction = function () {
    return this.m_body.dataFunction;
};

/**
* Retrieves the id associated to the modal dialog body element
* @return {string} The id associated to the modal dialog body element
*/
ModalDialog.prototype.getBodyElementId = function () {
    return this.m_body.elementId;
};

/**
* Retrieves the percentage set for the bottom margin of the modal dialog
* @return {number} The percentage assigned to the bottom margin for the modal dialog
*/
ModalDialog.prototype.getBottomMarginPercentage = function () {
    return this.m_margins.bottom;
};

/**
* Retrieves the button identified by the id passed into the function
* @param {string} buttonId The if of the ModalButton object to retrieve
* @return {ModalButton} The modal button with the id of buttonId, else null
*/
ModalDialog.prototype.getFooterButton = function (buttonId) {
    var x = 0;
    var buttons = this.getFooterButtons();
    var buttonCnt = buttons.length;
    //Get the ModalButton
    for (x = buttonCnt; x--; ) {
        button = buttons[x];
        if (button.getId() === buttonId) {
            return buttons[x];
        }
    }
    return null;
};

/**
* Retrieves the array of buttons which will be used in the footer of the modal dialog.
* @return {ModalButton[]} An array of ModalButton objects which will be used in the footer of the modal dialog
*/
ModalDialog.prototype.getFooterButtons = function () {
    return this.m_footer.buttons;
};

/**
* Retrieves the id associated to the modal dialog footer element
* @return {string} The id associated to the modal dialog footer element
*/
ModalDialog.prototype.getFooterElementId = function () {
    return this.m_footer.elementId;
};

/**
* Retrieves a boolean which determines if the modal dialog should display a gray background or not
* @return {boolean} The flag which determines if this modal dialog should display a gray background
*/
ModalDialog.prototype.getHasGrayBackground = function () {
    return this.m_hasGrayBackground;
};

/**
* Retrieves the function that will be used when the user attempts to close the modal dialog.
* @return {function} The function used when closing the modal dialog
*/
ModalDialog.prototype.getHeaderCloseFunction = function () {
    return this.m_header.closeFunction;
};

/**
* Retrieves the id associated to the modal dialog header element
* @return {string} The id associated to the modal dialog header element
*/
ModalDialog.prototype.getHeaderElementId = function () {
    return this.m_header.elementId;
};

/**
* Retrieves the title which will be used in the header of the modal dialog
* @return {string} The title given to the modal dialog header element
*/
ModalDialog.prototype.getHeaderTitle = function () {
    return this.m_header.title;
};

/**
* Retrieves the css class which will be applied to the html span used to open the modal dialog
* @return {string} The css which will be applied to the html span used ot open the modal dialog
*/
ModalDialog.prototype.getIconClass = function () {
    return this.m_icon.cssClass;
};

/**
* Retrieves the id associated to the modal dialog icon element
* @return {string} The id associated to the modal dialog icon element
*/
ModalDialog.prototype.getIconElementId = function () {
    return this.m_icon.elementId;
};

/**
* Retrieves the text which will be displayed the user hovers over the modal dialog icon
* @return {string} The text displayed when hovering over the modal dialog icon
*/
ModalDialog.prototype.getIconHoverText = function () {
    return this.m_icon.hoverText;
};

/**
* Retrieves the text which will be displayed next to the icon used to open the modal dialog
* @return {string} The text displayed next to the icon
*/
ModalDialog.prototype.getIconText = function () {
    return this.m_icon.text;
};

/**
* Retrieves the id given to this modal dialog object
* @return {string} The id given to this modal dialog object
*/
ModalDialog.prototype.getId = function () {
    return this.m_modalId;
};

/**
* Retrieves a boolean which determines if this modal dialog object is active or not
* @return {boolean} The flag which determines if this modal dialog object is active or not
*/
ModalDialog.prototype.getIsActive = function () {
    return this.m_isModalActive;
};

/**
* Retrieves a boolean which determines if this body of the modal dialog object has a fixed height or not
* @return {boolean} The flag which determines if the body of the modal dialog object is fixed or not
*/
ModalDialog.prototype.getIsBodySizeFixed = function () {
    return this.m_body.isBodySizeFixed;
};

/**
* Retrieves a boolean which determines if this modal dialog object is fixed to the icon used to launch it.
* @return {boolean} The flag which determines if this modal dialog object is active or not
*/
ModalDialog.prototype.getIsFixedToIcon = function () {
    return this.m_isFixedToIcon;
};

/**
* Retrieves a boolean which determines if this modal dialog footer is always shown or not.
* @return {boolean} The flag which determines if this modal dialog footer is always shown or not.
*/
ModalDialog.prototype.getIsFooterAlwaysShown = function () {
    return this.m_footer.isAlwaysShown;
};

/**
* Retrieves a boolean which determines if this modal dialog icon is active or not.  If the icon is not active it should
* not be clickable by the user and the cursor should not change when hovered over.
* @return {boolean} The flag which determines if modal dialog icon is active or not.
*/
ModalDialog.prototype.getIsIconActive = function () {
    return this.m_icon.isActive;
};

/**
* Retrieves the percentage set for the left margin of the modal dialog
* @return {number} The percentage assigned to the left margin for the modal dialog
*/
ModalDialog.prototype.getLeftMarginPercentage = function () {
    return this.m_margins.left;
};

/**
* Retrieves the percentage set for the right margin of the modal dialog
* @return {number} The percentage assigned to the right margin for the modal dialog
*/
ModalDialog.prototype.getRightMarginPercentage = function () {
    return this.m_margins.right;
};

/**
* Retrieves a boolean which determines if the close icon should be shown in the modal dialog.
* @return {boolean} The flag which determines if the close icon should be shown or not.
*/
ModalDialog.prototype.getShowCloseIcon = function () {
    return this.m_showCloseIcon;
};

/**
* Retrieves the percentage set for the top margin of the modal dialog
* @return {number} The percentage assigned to the top margin for the modal dialog
*/
ModalDialog.prototype.getTopMarginPercentage = function () {
    return this.m_margins.top;
};

/** Setters **/
/**
* Sets the function to be called when the modal dialog is shown.  This function will be passed ModalDialog object so that
* it can interact with the modal dialog easily while the dialog is open.
* @param {function} dataFunc The function used to populate the body of the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setBodyDataFunction = function (dataFunc) {

    //Check the proposed function
    if (!(typeof dataFunc === "function") && dataFunc !== null) {
        MP_Util.LogError("ModalDialog.setBodyDataFunction: dataFunc param must be a function or null");
        return this;
    }

    this.m_body.dataFunction = dataFunc;
    return this;
};

/**
* Sets the html element id of the modal dialog body.  This id will be used to insert html into the body of the modal dialog.
* @param {string} elementId The id of the html element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setBodyElementId = function (elementId) {
    if (elementId && typeof elementId == "string") {
        //Update the existing element id if the modal dialog is active
        if (this.isActive()) {
            $("#" + this.getBodyElementId()).attr("id", elementId);
        }
        this.m_body.elementId = elementId;
    }
    return this;
};

/**
* Sets the html of the body element.
* @param {string} html The HTML to insert into the body element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setBodyHTML = function (html) {
    if (html && typeof html == "string") {
        //Update the existing html iff the modal dialog is active
        if (this.isActive()) {
            $("#" + this.getBodyElementId()).html(html);
        }
    }
    return this;
};

/**
* Sets the percentage of the window size that will make up the bottom margin of the modal dialog.  The default value is 5.
* @param {number} margin A number that determines what percentage of the window's width will make up the bottom margin of the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setBottomMarginPercentage = function (margin) {
    if (typeof margin == "number") {
        this.m_margins.bottom = (margin <= 0) ? 1 : margin;
        //Resize the modal if it is active
        if (this.isActive()) {
            MP_ModalDialog.resizeModalDialog(this.getId());
        }
    }
    return this;
};

/**
* Sets the close on click property of a specific button in the modal dialog.
* @param {string} buttonId The id of the button to be dithered
* @param {boolean} closeOnClick A boolean used to determine if the button should close the dialog or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setFooterButtonCloseOnClick = function (buttonId, closeOnClick) {
    var button = null;
    var buttonElement = null;
    var onClickFunc = null;
    var modal = this;

    //check the closeOnClick type
    if (!(typeof closeOnClick === "boolean")) {
        MP_Util.LogError("ModalDialog.setFooterButtonCloseOnClick: closeOnClick param must be of type boolean");
        return this;
    }

    //Get the ModalButton
    button = this.getFooterButton(buttonId);
    if (button) {
        //Update the closeOnClick flag
        button.setCloseOnClick(closeOnClick);
        //If the modal dialog is active, update the existing class
        if (this.isActive()) {
            //Update the class of the object
            buttonElement = $("#" + buttonId);
            buttonElement.click(function () {
                onClickFunc = button.getOnClickFunction();
                if (onClickFunc && typeof onClickFunc == "function") {
                    onClickFunc();
                }
                if (closeOnClick) {
                    MP_ModalDialog.closeModalDialog(modal.getId());
                }
            });

        }
    }
    else {
        MP_Util.LogError("ModalDialog.setFooterButtonCloseOnClick: No button with the id of " + buttonId + " exists for this ModalDialog");
    }
    return this;
};

/**
* Sets the dithered property of a specific button in the modal dialog
* @param {string} buttonId The id of the button to be dithered
* @param {boolean} dithered A boolean used to determine if the button should be dithered or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setFooterButtonDither = function (buttonId, dithered) {
    var button = null;
    var buttonElement = null;

    //check the dithered type
    if (!(typeof dithered === "boolean")) {
        MP_Util.LogError("ModalDialog.setFooterButtonDither: Dithered param must be of type boolean");
        return this;
    }

    //Get the ModalButton
    button = this.getFooterButton(buttonId);
    if (button) {
        //Update the dithered flag
        button.setIsDithered(dithered);
        //If the modal dialog is active, update the existing class
        if (this.isActive()) {
            //Update the class of the object
            buttonElement = $("#" + buttonId);
            if (dithered) {
                $(buttonElement).attr("disabled", true);
            }
            else {
                $(buttonElement).attr("disabled", false);
            }
        }
    }
    else {
        MP_Util.LogError("ModalDialog.setFooterButtonDither: No button with the id of " + buttonId + " exists for this ModalDialog");
    }
    return this;
};

/**
* Sets the onclick function of the footer button with the given buttonId
* @param {string} buttonId The id of the button to be dithered
* @param {boolean} dithered A boolean used to determine if the button should be dithered or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setFooterButtonOnClickFunction = function (buttonId, clickFunc) {
    var button = null;
    var modal = this;

    //Check the proposed function and make sure it is a function
    if (!(typeof clickFunc == "function") && clickFunc !== null) {
        MP_Util.LogError("ModalDialog.setFooterButtonOnClickFunction: clickFunc param must be a function or null");
        return this;
    }

    //Get the modal button
    button = this.getFooterButton(buttonId);
    if (button) {
        //Set the onclick function of the button
        button.setOnClickFunction(clickFunc);
        //If the modal dialog is active, update the existing onClick function
        $("#" + buttonId).unbind("click").click(function () {
            if (clickFunc) {
                clickFunc();
            }
            if (button.closeOnClick()) {
                MP_ModalDialog.closeModalDialog(modal.getId());
            }
        });
    }
    else {
        MP_Util.LogError("ModalDialog.setFooterButtonOnClickFunction: No button with the id of " + buttonId + " exists for this ModalDialog");
    }
    return this;
};

/**
* Sets the text displayed in the footer button with the given buttonId
* @param {string} buttonId The id of the button to be dithered
* @param {string} buttonText the text to display in the button
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setFooterButtonText = function (buttonId, buttonText) {
    var button = null;

    //Check the proposed text and make sure it is a string
    if (!(typeof buttonText === "string")) {
        MP_Util.LogError("ModalDialog.setFooterButtonText: buttonText param must be a string");
        return this;
    }

    //Check make sure the string is not empty
    if (!buttonText) {
        MP_Util.LogError("ModalDialog.setFooterButtonText: buttonText param must not be empty or null");
        return this;
    }

    //Get the modal button
    button = this.getFooterButton(buttonId);
    if (button) {
        //Set the onclick function of the button
        button.setText(buttonText);
        //If the modal dialog is active, update the existing onClick function
        $("#" + buttonId).html(buttonText);
    }
    else {
        MP_Util.LogError("ModalDialog.setFooterButtonText: No button with the id of " + buttonId + " exists for this ModalDialog");
    }
    return this;
};

/**
* Sets the html element id of the modal dialog footer.  This id will be used to interact with the footer of the modal dialog.
* @param {string} elementId The id of the html element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setFooterElementId = function (elementId) {
    if (elementId && typeof elementId == "string") {
        //Update the existing element id if the modal dialog is active
        if (this.isActive()) {
            $("#" + this.getFooterElementId()).attr("id", elementId);
        }
        this.m_footer.elementId = elementId;
    }
    return this;
};

/**
* Sets the indicator which determines if the icon to launch the modal dialog is active or not.  When this is
* set, the icon and its interactions are updated if it is shown on the MPage.
* @param {boolean} activeInd An indicator which determines if the modal dialog icon is active or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIsIconActive = function (activeInd) {
    var modal = this;

    if (typeof activeInd == "boolean") {
        this.m_icon.isActive = activeInd;
        //Update the icon click event based on the indicator
        //Get the icon container and remove all events if there are any
        var iconElement = $("#" + this.getIconElementId());
        if (iconElement) {
            $(iconElement).unbind("click");
            $(iconElement).removeClass("vwp-util-icon");
            if (activeInd) {
                //Add the click event
                $(iconElement).click(function () {
                    MP_ModalDialog.showModalDialog(modal.getId());
                });


                $(iconElement).addClass("vwp-util-icon");
            }
        }
    }
    return this;
};

/**
* Sets the flag which determines if the modal dialog will have a gray backgound when rendered.  This property
* will not update dynamically.
* @param {boolean} hasGrayBackground The id of the html element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setHasGrayBackground = function (hasGrayBackground) {
    if (typeof hasGrayBackground == "boolean") {
        this.m_hasGrayBackground = hasGrayBackground;
    }
    return this;
};

/**
* Sets the function to be called upon the user choosing to close the dialog via the exit button instead of one of the available buttons.
* @param {function} closeFunc The function to call when the user closes the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setHeaderCloseFunction = function (closeFunc) {
    var modal = this;
    //Check the proposed function and make sure it is a function
    if (!(typeof closeFunc === "function") && closeFunc !== null) {
        MP_Util.LogError("ModalDialog.setHeaderCloseFunction: closeFunc param must be a function or null");
        return this;
    }

    //Update close function since it is valid
    this.m_header.closeFunction = closeFunc;

    //Update the header close function if the modal is active
    if (this.isActive()) {
        //Get the close element
        $('.dyn-modal-hdr-close').click(function () {
            if (closeFunc) {
                closeFunc();
            }
            //call the close mechanism of the modal dialog to cleanup everything
            MP_ModalDialog.closeModalDialog(modal.getId());
        });

    }
    return this;
};

/**
* Sets the html element id of the modal dialog header.  This id will be used to interact with the header of the modal dialog.
* @param {string} elementId The id of the html element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setHeaderElementId = function (elementId) {
    if (elementId && typeof elementId == "string") {
        //Update the existing element id if the modal dialog is active
        if (this.isActive()) {
            $("#" + this.getHeaderElementId()).attr("id", elementId);
        }
        this.m_header.elementId = elementId;
    }
    return this;
};

/**
* Sets the title to be displayed in the modal dialog header.
* @param {string} headerTitle The string to be used in the modal dialog header as the title
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setHeaderTitle = function (headerTitle) {
    if (headerTitle && typeof headerTitle == "string") {
        this.m_header.title = headerTitle;
        //Update the existing header title if the modal dialog is active
        if (this.isActive()) {
            $('#' + this.getHeaderElementId() + " .dyn-modal-hdr-title").html(headerTitle);
        }
    }
    return this;
};

/**
* Sets the css class to be used to display the modal dialog launch icon.  This class should contain a background and proper sizing
* as to diaply the entire icon.
* @param {string} iconClass The css class to be applied to the html element the user will use to launch the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIconClass = function (iconClass) {
    if (iconClass && typeof iconClass == "string") {
        //Update the existing icon class
        $('#' + this.getIconElementId()).removeClass(this.m_icon.cssClass).addClass(iconClass);
        this.m_icon.cssClass = iconClass;
    }
    return this;
};

/**
* Sets the html element id of the modal dialog icon.  This id will be used to interact with the icon of the modal dialog.
* @param {string} elementId The id of the html element
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIconElementId = function (elementId) {
    if (elementId && typeof elementId == "string") {
        //Update the existing element id if the modal dialog is active
        if (this.isActive()) {
            $("#" + this.getIconElementId()).attr("id", elementId);
        }
        this.m_icon.elementId = elementId;
    }
    return this;
};

/**
* Sets the test which will be displayed to the user when hovering over the modal dialog icon.
* @param {string} iconHoverText The text to display in the icon hover
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIconHoverText = function (iconHoverText) {
    if (iconHoverText !== null && typeof iconHoverText == "string") {
        this.m_icon.hoverText = iconHoverText;
        //Update the icon hover text
        if ($('#' + this.getIconElementId()).length > 0) {
            $('#' + this.getIconElementId()).attr("title", iconHoverText);
        }
    }
    return this;
};

/**
* Sets the text to be displayed next to the modal dialog icon.
* @param {string} iconText The text to display next to the modal dialog icon.
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIconText = function (iconText) {
    if (iconText !== null && typeof iconText == "string") {
        this.m_icon.text = iconText;
        //Update the icon text
        if ($('#' + this.getIconElementId()).length > 0) {
            $('#' + this.getIconElementId()).html(iconText);
        }
    }
    return this;
};

/**
* Sets the id which will be used to identify a particular ModalDialog object.
* @param {string} id The id that will be assigned to this ModalDialog object
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setId = function (id) {
    if (id && typeof id == "string") {
        this.m_modalId = id;
    }
    return this;
};

/**
* Sets the flag which identifies the modal dialog as being active or not
* @param {boolean} activeInd A boolean that can be used to determine if the modal is active or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIsActive = function (activeInd) {
    if (typeof activeInd == "boolean") {
        this.m_isModalActive = activeInd;
    }
    return this;
};

/**
* Sets the flag which identifies if the modal dialog body is a fixed height or not.
* @param {boolean} bodyFixed A boolean that can be used to determine if the modal dialog has a fixed size body or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIsBodySizeFixed = function (bodyFixed) {
    if (typeof bodyFixed == "boolean") {
        this.m_body.isBodySizeFixed = bodyFixed;
    }
    return this;
};

/**
* Sets the flag which identifies if the modal dialog is fixed to the icon or not.  If this flag is set
* the modal dialog will be displayed as an extension of the icon used to launch the dialog, much like a popup window.
* In this case the Top and Right margins are ignored and the location of the icon will determine those margins.  If this
* flag is set to false the modal dialog window will be displayed according to all of the margin settings.
* @param {boolean} fixedToIcon A boolean that can be used to determine if the modal is fixed to the launch icon or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIsFixedToIcon = function (fixedToIcon) {
    if (typeof fixedToIcon == "boolean") {
        this.m_isFixedToIcon = fixedToIcon;
    }
    return this;
};

/**
* Sets the flag which identifies if the modal dialog footer is always shown or not
* @param {boolean} footerAlwaysShown A boolean used to determine if the modal dialog footer is always shown or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setIsFooterAlwaysShown = function (footerAlwaysShown) {
    if (typeof footerAlwaysShown == "boolean") {
        this.m_footer.isAlwaysShown = footerAlwaysShown;
    }
    return this;
};

/**
* Sets the percentage of the window size that will make up the left margin of the modal dialog.  The default value is 5.
* @param {number} margin A number that determines what percentage of the window's width will make up the left margin of the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setLeftMarginPercentage = function (margin) {
    if (typeof margin == "number") {
        this.m_margins.left = (margin <= 0) ? 1 : margin;
        //Resize the modal if it is active
        if (this.isActive()) {
            MP_ModalDialog.resizeModalDialog(this.getId());
        }
    }
    return this;
};

/**
* Sets the percentage of the window size that will make up the right margin of the modal dialog.  The default value is 5.
* @param {number} margin A number that determines what percentage of the window's width will make up the right margin of the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setRightMarginPercentage = function (margin) {
    if (typeof margin == "number") {
        this.m_margins.right = (margin <= 0) ? 1 : margin;
        //Resize the modal if it is active
        if (this.isActive()) {
            MP_ModalDialog.resizeModalDialog(this.getId());
        }
    }
    return this;
};

/**
* Sets the flag which identifies if the modal dialog close icon is shown or not
* @param {boolean} showCloseIcon A boolean used to determine if the modal dialog close icon is shown or not
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setShowCloseIcon = function (showCloseIcon) {
    if (typeof showCloseIcon == "boolean") {
        this.m_showCloseIcon = showCloseIcon;
    }
    return this;
};

/**
* Sets the percentage of the window size that will make up the top margin of the modal dialog.  The default value is 5.
* @param {number} margin A number that determines what percentage of the window's width will make up the top margin of the modal dialog
* @return {ModalDialog} The modal dialog object calling this function so chaining can be used
*/
ModalDialog.prototype.setTopMarginPercentage = function (margin) {
    if (typeof margin == "number") {
        this.m_margins.top = (margin <= 0) ? 1 : margin;
        //Resize the modal if it is active
        if (this.isActive()) {
            MP_ModalDialog.resizeModalDialog(this.getId());
        }
    }
    return this;
};

/**
* The ModalButton class is used specifically for adding buttons to the footer of a modal dialog.
* @constructor
*/
function ModalButton(buttonId) {
    //The id given to the button.  This id will be used to identify individual buttons
    this.m_buttonId = buttonId;
    //The text that will be displayed in the button itself
    this.m_buttonText = "";
    //A flag to determine if the button shall be disabled or not
    this.m_dithered = false;
    //The function to call when the button is clicked
    this.m_onClickFunction = null;
    //A flag to determine if this button should be closed when clicked.
    this.m_closeOnClick = true;
    //A flag to determine if this button should be focused when the modal dialog is shown
    this.m_focusInd = false;
}

/** Checkers **/
/**
* Check to see if the button click should close the modal dialog on click
* @return {boolean} A boolean which determines if the button click should cause the modal dialog to close
*/
ModalButton.prototype.closeOnClick = function () {
    return this.m_closeOnClick;
};

/**
* Check to see if the Modal Button is currently dithered
* @return {boolean} A boolean flag that indicates if the modal button is dithered or not
*/
ModalButton.prototype.isDithered = function () {
    return this.m_dithered;
};

/** Getters **/
/**
* Retrieves the id assigned the this ModalButton object
* @return {string} The id assigned to this ModalButton object
*/
ModalButton.prototype.getId = function () {
    return this.m_buttonId;
};

/**
* Retrieve the close on click flag of the ModalButton object
* @return {boolean} The close on click flag of the ModalButton object
*/
ModalButton.prototype.getCloseOnClick = function () {
    return this.m_closeOnClick;
};

/**
* Retrieve the focus indicator flag of the ModalButton object
* @return {boolean} The focus indicator flag of the ModalButton object
*/
ModalButton.prototype.getFocusInd = function () {
    return this.m_focusInd;
};

/**
* Retrieves the text used for the ModalButton display
* @return {string} The text which will be used in the button display
*/
ModalButton.prototype.getText = function () {
    return this.m_buttonText;
};

/**
* Retrieves the onClick function associated to this Modal Button
* @return {function} The function executed when the button is clicked
*/
ModalButton.prototype.getOnClickFunction = function () {
    return this.m_onClickFunction;
};

/** Setters **/

/**
* Sets the id of the ModalButton object.  The id must be a string otherwise it is ignored.
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setId = function (buttonId) {
    if (buttonId && typeof buttonId == "string") {
        this.m_buttonId = buttonId;
    }
    return this;
};

/**
* Sets the close on click flag of the dialog button
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setCloseOnClick = function (closeFlag) {
    if (typeof closeFlag == "boolean") {
        this.m_closeOnClick = closeFlag;
    }
    return this;
};

/**
* Sets the focus indicator flag of the dialog button
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setFocusInd = function (focusInd) {
    if (typeof focusInd == "boolean") {
        this.m_focusInd = focusInd;
    }
    return this;
};

/**
* Sets the text which will be shown in the button
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setText = function (buttonText) {
    if (buttonText && typeof buttonText == "string") {
        this.m_buttonText = buttonText;
    }
    return this;
};

/**
* Sets the dithered status of the dialog button
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setIsDithered = function (dithered) {
    if (typeof dithered == "boolean") {
        this.m_dithered = dithered;
    }
    return this;
};

/**
* Sets the onClick function for the ModalButton
* @return {ModalButton} The modal button object calling this function so chaining can be used
*/
ModalButton.prototype.setOnClickFunction = function (clickFunc) {
    this.m_onClickFunction = clickFunc;
    return this;
};

/**
* A collection of functions which can be used to maintain, create, destroy and update modal dialogs.
* The MP_ModalDialog function keeps a copy of all of the ModalDialog objects that have been created
* for the current view.  If a ModalDialog object is updated outside of these functions, the updated
* version of the object should replace the stale version that is stored here by using the
* updateModalDialogObject functionality.
* @namespace
*/
var MP_ModalDialog = function () {
    var modalDialogObjects = {};
    var whiteSpacePixels = 26;

    //A inner function used to the resize event that can be added and also removed from the window
    var resizeFunction = function () {
        MP_ModalDialog.resizeAllModalDialogs();
    };

    return {
        /**
        * This function will be used to add ModalDialog objects to the collection of ModalDialog objects for the current
        * View.  This list of ModalDialog objects will be the one source of this type of object and will be used when
        * showing modal dialogs.
        * @param {ModalDialog} modalObject An instance of the ModalDialog object
        */
        addModalDialogObject: function (modalObject) {
            var modalId = "";
            //Check that he object is not null and that the object type is ModalDialog
            if (!(modalObject instanceof ModalDialog)) {
                MP_Util.LogError("MP_ModalDialog.addModalDialogObject only accepts objects of type ModalDialog");
                return false;
            }

            //Check for a valid id.
            modalId = modalObject.getId();
            if (!modalId) {
                //Modal id is not populated
                MP_Util.LogError("MP_ModalDialog.addModalDialogObject: no/invalid ModalDialog id given");
                return false;
            }
            else if (modalDialogObjects[modalId]) {
                //Modal id is already in use
                MP_Util.LogError("MP_ModalDialog.addModalDialogObject: modal dialog id" + modalId + " is already in use");
                return false;
            }

            //Add the ModalDialog Object to the list of ModalDialog objects
            modalDialogObjects[modalId] = modalObject;
        },

        /**
        * Add the modal dialog icon to the viewpoint framework.  This icon will be responsible for
        * launching the correct modal dialog based on the ModalDialog object that it is associated to.
        * @param {string} modalDialogId The id of the ModalDialog object to reference when creating the modal dialog icon
        * @return null
        */
        addModalDialogOptionToViewpoint: function (modalDialogId) {
            var modalObj = null;
            var iconElement = null;
            var vwpUtilElement = null;

            //Check to see if the ModalDialog exists
            modalObj = modalDialogObjects[modalDialogId];
            if (!modalObj) {
                return;
            }

            //Check to see if the modal utility has already been added to the viewpoint
            if ($("#" + modalDialogId).length > 0) {
                MP_Util.LogError("MP_ModalDialog.addModalDialogObject: Modal dialog " + modalDialogId + " already added");
                return;
            }

            //If the MP_Viewpoint function is defined call it
            if (typeof MP_Viewpoint.addModalDialogUtility != 'undefined') {
                MP_Viewpoint.addModalDialogUtility(modalObj);
            }
        },

        /**
        * Closes all of the associated modal dialog windows and removes the resize event listener
        * @return null
        */
        closeModalDialog: function (modalDialogId) {
            var modalObj = null;

            //Check to see if the ModalDialog exists
            modalObj = modalDialogObjects[modalDialogId];
            if (!modalObj) {
                return;
            }

            //destroy the modal dialog
            $("#vwpModalDialog" + modalObj.getId()).remove();
            //destroy the modal background
            $("#vwpModalBackground" + modalObj.getId()).remove();
            //remove modal dialog resize event from the window
            $(window).unbind("resize", resizeFunction);
            //Mark the modal dialog as inactive
            modalObj.setIsActive(false);
            $("html").css("overflow", "auto");
        },

        /**
        * Deletes the modal dialog object with the id modalDialogId.
        * @param {string} modalDialogId The id of the modal dialog object to be deleted
        * @return {boolean} True if a ModalDialog object was deleted, false otherwise
        */
        deleteModalDialogObject: function (modalDialogId) {
            if (modalDialogObjects[modalDialogId]) {
                modalDialogObjects[modalDialogId] = null;
                return true;
            }
            return false;
        },

        /**
        * Retrieves the ModalDialog object with the id of modalDialogId
        * @param {string} modalDialogId The id of the modal dialog object to retrieve
        */
        retrieveModalDialogObject: function (modalDialogId) {
            if (modalDialogObjects[modalDialogId]) {
                return modalDialogObjects[modalDialogId];
            }
            return null;
        },

        /**
        * Resizes all of the active modal dialogs when the window itself is being resized.
        * @param {string} modalDialogId The id of the modal dialog object to resize
        */
        resizeAllModalDialogs: function () {
            var tempObj = null;
            var attr = "";
            //Get all of the modal dialog objects from the modalDialogObjects collection
            for (attr in modalDialogObjects) {
                if (modalDialogObjects.hasOwnProperty(attr)) {
                    tempObj = modalDialogObjects[attr];
                    if ((tempObj instanceof ModalDialog) && tempObj.isActive()) {
                        MP_ModalDialog.resizeModalDialog(tempObj.getId());
                    }
                }
            }
        },

        /**
        * Resizes the modal dialog when the window itself is being resized.
        * @param {string} modalDialogId The id of the modal dialog object to resize
        */
        resizeModalDialog: function (modalDialogId) {
            var docHeight = 0;
            var docWidth = 0;
            var topMarginSize = 0;
            var leftMarginSize = 0;
            var bottomMarginSize = 0;
            var rightMarginSize = 0;
            var modalWidth = "";
            var modalHeight = "";
            var modalObj = null;

            //Get the ModalDialog object
            modalObj = modalDialogObjects[modalDialogId];
            if (!modalObj) {
                MP_Util.LogError("MP_ModalDialog.resizeModalDialog: No modal dialog with the id " + modalDialogId + "exists");
                return;
            }

            if (!modalObj.isActive()) {
                MP_Util.LogError("MP_ModalDialog.resizeModalDialog: this modal dialog is not active it cannot be resized");
                return;
            }

            //Determine the new margins and update accordingly
            docHeight = $(window).height();
            docWidth = $(document.body).width();
            topMarginSize = Math.floor(docHeight * (modalObj.getTopMarginPercentage() / 100));
            leftMarginSize = Math.floor(docWidth * (modalObj.getLeftMarginPercentage() / 100));
            bottomMarginSize = Math.floor(docHeight * (modalObj.getBottomMarginPercentage() / 100));
            rightMarginSize = Math.floor(docWidth * (modalObj.getRightMarginPercentage() / 100));
            modalWidth = (docWidth - leftMarginSize - rightMarginSize);
            modalHeight = (docHeight - topMarginSize - bottomMarginSize);
            $("#vwpModalDialog" + modalObj.getId()).css({
                "top": topMarginSize,
                "left": leftMarginSize,
                "width": modalWidth + "px"
            });

            //Make sure the body div fills all of the alloted space if the body is a fixed size and also make sure the modal dialog is sized correctly.
            if (modalObj.isBodySizeFixed()) {
                $("#vwpModalDialog" + modalObj.getId()).css("height", modalHeight + "px");
                $("#" + modalObj.getBodyElementId()).height(modalHeight - $("#" + modalObj.getHeaderElementId()).height() - $("#" + modalObj.getFooterElementId()).height() - whiteSpacePixels);
            }
            else {
                $("#vwpModalDialog" + modalObj.getId()).css("max-height", modalHeight + "px");
                $("#" + modalObj.getBodyElementId()).css("max-height", (modalHeight - $("#" + modalObj.getHeaderElementId()).height() - $("#" + modalObj.getFooterElementId()).height() - whiteSpacePixels) + "px");
            }

            //Make sure the modal background is resized as well
            $("#vwpModalBackground" + modalObj.getId()).css({
                "height": "100%",
                "width": "100%"
            });
        },

        /**
        * Render and show the modal dialog based on the settings applied in the ModalDialog object referenced by the
        * modalDialogId parameter.
        * @param {string} modalDialogId The id of the ModalDialog object to render
        * @return null
        */
        showModalDialog: function (modalDialogId) {
            var bodyDiv = null;
            var bodyLoadFunc = null;
            var bottomMarginSize = 0;
            var button = null;
            var dialogDiv = null;
            var docHeight = 0;
            var docWidth = 0;
            var focusButtonId = "";
            var footerDiv = null;
            var footerButtons = [];
            var footerButtonsCnt = 0;
            var footerButtonContainer = null;
            var headerDiv = null;
            var leftMarginSize = 0;
            var modalDiv = null;
            var modalObj = null;
            var modalHeight = "";
            var modalWidth = "";
            var rightMarginSize = 0;
            var topMarginSize = 0;
            var x = 0;

            /**
            * This function is used to create onClick functions for each button.  Using this function
            * will prevent closures from applying the same action onClick function to all buttons.
            */
            function createButtonClickFunc(buttonObj, modalDialogId) {
                var clickFunc = buttonObj.getOnClickFunction();
                var closeModal = buttonObj.closeOnClick();
                if (!clickFunc) {
                    clickFunc = function () {
                    };

                }
                return function () {
                    clickFunc();
                    if (closeModal) {
                        MP_ModalDialog.closeModalDialog(modalDialogId);
                    }
                };

            }

            //Get the ModalDialog object
            modalObj = modalDialogObjects[modalDialogId];
            if (!modalObj) {
                MP_Util.LogError("MP_ModalDialog.showModalDialog: No modal dialog with the id " + modalDialogId + "exists");
                return;
            }

            //Check to see if the modal dialog is already displayed.  If so, return
            if (modalObj.isActive()) {
                return;
            }

            //Create the modal window based on the ModalDialog object
            //Create the header div element
            headerDiv = $('<div></div>').attr({
                id: modalObj.getHeaderElementId()
            }).addClass("dyn-modal-hdr-container").append($('<span></span>').addClass("dyn-modal-hdr-title").html(modalObj.getHeaderTitle()));
            if (modalObj.showCloseIcon()) {
                headerDiv.append($('<span></span>').addClass("dyn-modal-hdr-close").click(function () {
                    var closeFunc = null;
                    //call the close function of the modalObj
                    closeFunc = modalObj.getHeaderCloseFunction();
                    if (closeFunc) {
                        closeFunc();
                    }
                    //call the close mechanism of the modal dialog to cleanup everything
                    MP_ModalDialog.closeModalDialog(modalDialogId);
                }));

            }

            //Create the body div element
            bodyDiv = $('<div></div>').attr({
                id: modalObj.getBodyElementId()
            }).addClass("dyn-modal-body-container");

            //Create the footer element if there are any buttons available
            footerButtons = modalObj.getFooterButtons();
            footerButtonsCnt = footerButtons.length;
            if (footerButtonsCnt) {
                footerDiv = $('<div></div>').attr({
                    id: modalObj.getFooterElementId()
                }).addClass("dyn-modal-footer-container");
                footerButtonContainer = $('<div></div>').attr({
                    id: modalObj.getFooterElementId() + "btnCont"
                }).addClass("dyn-modal-button-container");
                for (x = 0; x < footerButtonsCnt; x++) {
                    button = footerButtons[x];
                    buttonFunc = button.getOnClickFunction();
                    footerButtonContainer.append($('<button></button>').attr({
                        id: button.getId(),
                        disabled: button.isDithered()
                    }).addClass("dyn-modal-button").html(button.getText()).click(createButtonClickFunc(button, modalObj.getId())));

                    //Check to see if we should focus on this button when loading the modal dialog
                    if (!focusButtonId) {
                        focusButtonId = (button.getFocusInd()) ? button.getId() : "";
                    }
                }
                footerDiv.append(footerButtonContainer);
            }
            else if (modalObj.isFooterAlwaysShown()) {
                footerDiv = $('<div></div>').attr({
                    id: modalObj.getFooterElementId()
                }).addClass("dyn-modal-footer-container");
                footerDiv.append(footerButtonContainer);
            }

            //determine the dialog size
            docHeight = $(window).height();
            docWidth = $(document.body).width();
            topMarginSize = Math.floor(docHeight * (modalObj.getTopMarginPercentage() / 100));
            leftMarginSize = Math.floor(docWidth * (modalObj.getLeftMarginPercentage() / 100));
            bottomMarginSize = Math.floor(docHeight * (modalObj.getBottomMarginPercentage() / 100));
            rightMarginSize = Math.floor(docWidth * (modalObj.getRightMarginPercentage() / 100));
            modalWidth = (docWidth - leftMarginSize - rightMarginSize);
            modalHeight = (docHeight - topMarginSize - bottomMarginSize);
            dialogDiv = $('<div></div>').attr({
                id: "vwpModalDialog" + modalObj.getId()
            }).addClass("dyn-modal-dialog").css({
                "top": topMarginSize,
                "left": leftMarginSize,
                "width": modalWidth + "px"
            }).append(headerDiv).append(bodyDiv).append(footerDiv);

            //Create the modal background if set in the ModalDialog object.
            modalDiv = $('<div></div>').attr({
                id: "vwpModalBackground" + modalObj.getId()
            }).addClass((modalObj.hasGrayBackground()) ? "dyn-modal-div" : "dyn-modal-div-clear").height($(document).height());

            //Add the flash function to the modal if using a clear background
            if (!modalObj.hasGrayBackground()) {
                modalDiv.click(function () {
                    var modal = $("#vwpModalDialog" + modalObj.getId());
                    $(modal).fadeOut(100);
                    $(modal).fadeIn(100);
                });

            }

            //Add all of these elements to the document body
            $(document.body).append(modalDiv).append(dialogDiv);
            //Set the focus of a button if indicated
            if (focusButtonId) {
                $("#" + focusButtonId).focus();
            }
            //disable page scrolling when modal is enabled
            $("html").css("overflow", "hidden");

            //Make sure the body div fills all of the alloted space if the body is a fixed size and also make sure the modal dialog is sized correctly.
            if (modalObj.isBodySizeFixed()) {
                $(dialogDiv).css("height", modalHeight + "px");
                $(bodyDiv).height(modalHeight - $(headerDiv).height() - $(footerDiv).height() - whiteSpacePixels);
            }
            else {
                $(dialogDiv).css("max-height", modalHeight + "px");
                $(bodyDiv).css("max-height", (modalHeight - $(headerDiv).height() - $(footerDiv).height() - whiteSpacePixels) + "px");
            }

            //This next line makes the modal draggable.  If this is commented out updates will need to be made
            //to resize functions and also updates to the ModalDialog object to save the location of the modal
            //$(dialogDiv).draggable({containment: "parent"});

            //Mark the displayed modal as active and save its id
            modalObj.setIsActive(true);

            //Call the onBodyLoadFunction of the modal dialog
            bodyLoadFunc = modalObj.getBodyDataFunction();
            if (bodyLoadFunc) {
                bodyLoadFunc(modalObj);
            }

            //Attempt to resize the window as it is being resized
            $(window).resize(resizeFunction);
        },

        /**
        * Updates the existing ModalDialog with a new instance of the object.  If the modal objet does not exist it is added to the collection
        * @param {ModalDialog} modalObject The updated instance of the ModalDialog object.
        * @return null
        */
        updateModalDialogObject: function (modalObject) {
            var modalDialogId = "";

            //Check to see if we were passed a ModalDialog object
            if (!modalObject || !(modalObject instanceof ModalDialog)) {
                MP_Util.LogError("MP_ModalDialog.updateModalDialogObject only accepts objects of type ModalDialog");
                return;
            }

            //Blindly update the ModalDialog object.  If it didnt previously exist, it will now.
            modalDialogId = modalObject.getId();
            modalDialogObjects[modalDialogId] = modalObject;
            return;
        }

    };
} ();

// Chosen, a Select Box Enhancer for jQuery and Protoype
// by Patrick Filler for Harvest, http://getharvest.com
//
// Version 0.9.8
// Full source at https://github.com/harvesthq/chosen
// Copyright (c) 2011 Harvest http://getharvest.com

// MIT License, https://github.com/harvesthq/chosen/blob/master/LICENSE.md
// This file is generated by `cake build`, do not edit it by hand.
((function () {
		var a;
		a = function () {
			function a() {
				this.options_index = 0,
				this.parsed = []
			}
			return a.prototype.add_node = function (a) {
				return a.nodeName === "OPTGROUP" ? this.add_group(a) : this.add_option(a)
			},
			a.prototype.add_group = function (a) {
				var b,
				c,
				d,
				e,
				f,
				g;
				b = this.parsed.length,
				this.parsed.push({
					array_index : b,
					group : !0,
					label : a.label,
					children : 0,
					disabled : a.disabled
				}),
				f = a.childNodes,
				g = [];
				for (d = 0, e = f.length; d < e; d++)
					c = f[d], g.push(this.add_option(c, b, a.disabled));
				return g
			},
			a.prototype.add_option = function (a, b, c) {
				if (a.nodeName === "OPTION")
					return a.text !== "" ? (b != null && (this.parsed[b].children += 1), this.parsed.push({
							array_index : this.parsed.length,
							options_index : this.options_index,
							value : a.value,
							text : a.text,
							html : a.innerHTML,
							selected : a.selected,
							disabled : c === !0 ? c : a.disabled,
							group_array_index : b,
							classes : a.className,
							style : a.style.cssText
						})) : this.parsed.push({
						array_index : this.parsed.length,
						options_index : this.options_index,
						empty : !0
					}), this.options_index += 1
			},
			a
		}
		(),
		a.select_to_array = function (b) {
			var c,
			d,
			e,
			f,
			g;
			d = new a,
			g = b.childNodes;
			for (e = 0, f = g.length; e < f; e++)
				c = g[e], d.add_node(c);
			return d.parsed
		},
		this.SelectParser = a
	})).call(this), function () {
	var a,
	b;
	b = this,
	a = function () {
		function a(a, b) {
			this.form_field = a,
			this.options = b != null ? b : {},
			this.set_default_values(),
			this.is_multiple = this.form_field.multiple,
			this.default_text_default = this.is_multiple ? "Select Some Options" : "Select an Option",
			this.setup(),
			this.set_up_html(),
			this.register_observers(),
			this.finish_setup()
		}
		return a.prototype.set_default_values = function () {
			var a = this;
			return this.click_test_action = function (b) {
				return a.test_active_click(b)
			},
			this.activate_action = function (b) {
				return a.activate_field(b)
			},
			this.active_field = !1,
			this.mouse_on_container = !1,
			this.results_showing = !1,
			this.result_highlighted = null,
			this.result_single_selected = null,
			this.allow_single_deselect = this.options.allow_single_deselect != null && this.form_field.options[0] != null && this.form_field.options[0].text === "" ? this.options.allow_single_deselect : !1,
			this.disable_search_threshold = this.options.disable_search_threshold || 0,
			this.search_contains = this.options.search_contains || !1,
			this.choices = 0,
			this.results_none_found = this.options.no_results_text || "No results match"
		},
		a.prototype.mouse_enter = function () {
			return this.mouse_on_container = !0
		},
		a.prototype.mouse_leave = function () {
			return this.mouse_on_container = !1
		},
		a.prototype.input_focus = function (a) {
			var b = this;
			if (!this.active_field)
				return setTimeout(function () {
					return b.container_mousedown()
				}, 50)
		},
		a.prototype.input_blur = function (a) {
			var b = this;
			if (!this.mouse_on_container)
				return this.active_field = !1, setTimeout(function () {
					return b.blur_test()
				}, 100)
		},
		a.prototype.result_add_option = function (a) {
			var b,
			c;
			return a.disabled ? "" : (a.dom_id = this.container_id + "_o_" + a.array_index, b = a.selected && this.is_multiple ? [] : ["active-result"], a.selected && b.push("result-selected"), a.group_array_index != null && b.push("group-option"), a.classes !== "" && b.push(a.classes), c = a.style.cssText !== "" ? ' style="' + a.style + '"' : "", '<li id="' + a.dom_id + '" class="' + b.join(" ") + '"' + c + ">" + a.html + "</li>")
		},
		a.prototype.results_update_field = function () {
			return this.result_clear_highlight(),
			this.result_single_selected = null,
			this.results_build()
		},
		a.prototype.results_toggle = function () {
			return this.results_showing ? this.results_hide() : this.results_show()
		},
		a.prototype.results_search = function (a) {
			return this.results_showing ? this.winnow_results() : this.results_show()
		},
		a.prototype.keyup_checker = function (a) {
			var b,
			c;
			b = (c = a.which) != null ? c : a.keyCode,
			this.search_field_scale();
			switch (b) {
			case 8:
				if (this.is_multiple && this.backstroke_length < 1 && this.choices > 0)
					return this.keydown_backstroke();
				if (!this.pending_backstroke)
					return this.result_clear_highlight(), this.results_search();
				break;
			case 13:
				a.preventDefault();
				if (this.results_showing)
					return this.result_select(a);
				break;
			case 27:
				return this.results_showing && this.results_hide(),
				!0;
			case 9:
			case 38:
			case 40:
			case 16:
			case 91:
			case 17:
				break;
			default:
				return this.results_search()
			}
		},
		a.prototype.generate_field_id = function () {
			var a;
			return a = this.generate_random_id(),
			this.form_field.id = a,
			a
		},
		a.prototype.generate_random_char = function () {
			var a,
			b,
			c;
			return a = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZ",
			c = Math.floor(Math.random() * a.length),
			b = a.substring(c, c + 1)
		},
		a
	}
	(),
	b.AbstractChosen = a
}
.call(this), function () {
	var a,
	b,
	c,
	d,
	e = Object.prototype.hasOwnProperty,
	f = function (a, b) {
		function d() {
			this.constructor = a
		}
		for (var c in b)
			e.call(b, c) && (a[c] = b[c]);
		return d.prototype = b.prototype,
		a.prototype = new d,
		a.__super__ = b.prototype,
		a
	};
	d = this,
	a = jQuery,
	a.fn.extend({
		chosen : function (c) {
			return !a.browser.msie || a.browser.version !== "5.0" && a.browser.version !== "5.0" ? a(this).each(function (d) {
				if (!a(this).hasClass("chzn-done"))
					return new b(this, c)
			}) : this
		}
	}),
	b = function (b) {
		function e() {
			e.__super__.constructor.apply(this, arguments)
		}
		return f(e, b),
		e.prototype.setup = function () {
			return this.form_field_jq = a(this.form_field),
			this.is_rtl = this.form_field_jq.hasClass("chzn-rtl")
		},
		e.prototype.finish_setup = function () {
			return this.form_field_jq.addClass("chzn-done")
		},
		e.prototype.set_up_html = function () {
			var b,
			d,
			e,
			f;
			return this.container_id = this.form_field.id.length ? this.form_field.id.replace(/[^\w]/g, "_") : this.generate_field_id(),
			this.container_id += "_chzn",
			this.f_width = this.form_field_jq.outerWidth(),
			this.default_text = this.form_field_jq.data("placeholder") ? this.form_field_jq.data("placeholder") : this.default_text_default,
			b = a("<div />", {
					id : this.container_id,
					"class" : "chzn-container" + (this.is_rtl ? " chzn-rtl" : ""),
					style : "width: " + this.f_width + "px;"
				}),
			this.is_multiple ? b.html('<ul class="chzn-choices"><li class="search-field"><input type="text" value="' + this.default_text + '" class="default" autocomplete="off" style="width:25px;" /></li></ul><div class="chzn-drop" style="left:-9000px;"><ul class="chzn-results"></ul></div>') : b.html('<a href="javascript:void(0)" class="chzn-single chzn-default"><span>' + this.default_text + '</span><div><b></b></div></a><div class="chzn-drop" style="left:-9000px;"><div class="chzn-search"><input type="text" autocomplete="off" /></div><ul class="chzn-results"></ul></div>'),
			this.form_field_jq.hide().after(b),
			this.container = a("#" + this.container_id),
			this.container.addClass("chzn-container-" + (this.is_multiple ? "multi" : "single")),
			this.dropdown = this.container.find("div.chzn-drop").first(),
			d = this.container.height(),
			e = this.f_width - c(this.dropdown),
			this.dropdown.css({
				width : e + "px",
				top : d + "px"
			}),
			this.search_field = this.container.find("input").first(),
			this.search_results = this.container.find("ul.chzn-results").first(),
			this.search_field_scale(),
			this.search_no_results = this.container.find("li.no-results").first(),
			this.is_multiple ? (this.search_choices = this.container.find("ul.chzn-choices").first(), this.search_container = this.container.find("li.search-field").first()) : (this.search_container = this.container.find("div.chzn-search").first(), this.selected_item = this.container.find(".chzn-single").first(), f = e - c(this.search_container) - c(this.search_field), this.search_field.css({
					width : f + "px"
				})),
			this.results_build(),
			this.set_tab_index(),
			this.form_field_jq.trigger("liszt:ready", {
				chosen : this
			})
		},
		e.prototype.register_observers = function () {
			var a = this;
			return this.container.mousedown(function (b) {
				return a.container_mousedown(b)
			}),
			this.container.mouseup(function (b) {
				return a.container_mouseup(b)
			}),
			this.container.mouseenter(function (b) {
				return a.mouse_enter(b)
			}),
			this.container.mouseleave(function (b) {
				return a.mouse_leave(b)
			}),
			this.search_results.mouseup(function (b) {
				return a.search_results_mouseup(b)
			}),
			this.search_results.mouseover(function (b) {
				return a.search_results_mouseover(b)
			}),
			this.search_results.mouseout(function (b) {
				return a.search_results_mouseout(b)
			}),
			this.form_field_jq.bind("liszt:updated", function (b) {
				return a.results_update_field(b)
			}),
			this.search_field.blur(function (b) {
				return a.input_blur(b)
			}),
			this.search_field.keyup(function (b) {
				return a.keyup_checker(b)
			}),
			this.search_field.keydown(function (b) {
				return a.keydown_checker(b)
			}),
			this.is_multiple ? (this.search_choices.click(function (b) {
					return a.choices_click(b)
				}), this.search_field.focus(function (b) {
					return a.input_focus(b)
				})) : this.container.click(function (a) {
				return a.preventDefault()
			})
		},
		e.prototype.search_field_disabled = function () {
			this.is_disabled = this.form_field_jq[0].disabled;
			if (this.is_disabled)
				return this.container.addClass("chzn-disabled"), this.search_field[0].disabled = !0, this.is_multiple || this.selected_item.unbind("focus", this.activate_action), this.close_field();
			this.container.removeClass("chzn-disabled"),
			this.search_field[0].disabled = !1;
			if (!this.is_multiple)
				return this.selected_item.bind("focus", this.activate_action)
		},
		e.prototype.container_mousedown = function (b) {
			var c;
			if (!this.is_disabled)
				return c = b != null ? a(b.target).hasClass("search-choice-close") : !1, b && b.type === "mousedown" && !this.results_showing && b.stopPropagation(), !this.pending_destroy_click && !c ? (this.active_field ? !this.is_multiple && b && (a(b.target)[0] === this.selected_item[0] || a(b.target).parents("a.chzn-single").length) && (b.preventDefault(), this.results_toggle()) : (this.is_multiple && this.search_field.val(""), a(document).click(this.click_test_action), this.results_show()), this.activate_field()) : this.pending_destroy_click = !1
		},
		e.prototype.container_mouseup = function (a) {
			if (a.target.nodeName === "ABBR")
				return this.results_reset(a)
		},
		e.prototype.blur_test = function (a) {
			if (!this.active_field && this.container.hasClass("chzn-container-active"))
				return this.close_field()
		},
		e.prototype.close_field = function () {
			return a(document).unbind("click", this.click_test_action),
			this.is_multiple || (this.selected_item.attr("tabindex", this.search_field.attr("tabindex")), this.search_field.attr("tabindex", -1)),
			this.active_field = !1,
			this.results_hide(),
			this.container.removeClass("chzn-container-active"),
			this.winnow_results_clear(),
			this.clear_backstroke(),
			this.show_search_field_default(),
			this.search_field_scale()
		},
		e.prototype.activate_field = function () {
			return !this.is_multiple && !this.active_field && (this.search_field.attr("tabindex", this.selected_item.attr("tabindex")), this.selected_item.attr("tabindex", -1)),
			this.container.addClass("chzn-container-active"),
			this.active_field = !0,
			this.search_field.val(this.search_field.val()),
			this.search_field.focus()
		},
		e.prototype.test_active_click = function (b) {
			return a(b.target).parents("#" + this.container_id).length ? this.active_field = !0 : this.close_field()
		},
		e.prototype.results_build = function () {
			var a,
			b,
			c,
			e,
			f;
			this.parsing = !0,
			this.results_data = d.SelectParser.select_to_array(this.form_field),
			this.is_multiple && this.choices > 0 ? (this.search_choices.find("li.search-choice").remove(), this.choices = 0) : this.is_multiple || (this.selected_item.find("span").text(this.default_text), this.form_field.options.length <= this.disable_search_threshold ? this.container.addClass("chzn-container-single-nosearch") : this.container.removeClass("chzn-container-single-nosearch")),
			a = "",
			f = this.results_data;
			for (c = 0, e = f.length; c < e; c++)
				b = f[c], b.group ? a += this.result_add_group(b) : b.empty || (a += this.result_add_option(b), b.selected && this.is_multiple ? this.choice_build(b) : b.selected && !this.is_multiple && (this.selected_item.removeClass("chzn-default").find("span").text(b.text), this.allow_single_deselect && this.single_deselect_control_build()));
			return this.search_field_disabled(),
			this.show_search_field_default(),
			this.search_field_scale(),
			this.search_results.html(a),
			this.parsing = !1
		},
		e.prototype.result_add_group = function (b) {
			return b.disabled ? "" : (b.dom_id = this.container_id + "_g_" + b.array_index, '<li id="' + b.dom_id + '" class="group-result">' + a("<div />").text(b.label).html() + "</li>")
		},
		e.prototype.result_do_highlight = function (a) {
			var b,
			c,
			d,
			e,
			f;
			if (a.length) {
				this.result_clear_highlight(),
				this.result_highlight = a,
				this.result_highlight.addClass("highlighted"),
				d = parseInt(this.search_results.css("maxHeight"), 10),
				f = this.search_results.scrollTop(),
				e = d + f,
				c = this.result_highlight.position().top + this.search_results.scrollTop(),
				b = c + this.result_highlight.outerHeight();
				if (b >= e)
					return this.search_results.scrollTop(b - d > 0 ? b - d : 0);
				if (c < f)
					return this.search_results.scrollTop(c)
			}
		},
		e.prototype.result_clear_highlight = function () {
			return this.result_highlight && this.result_highlight.removeClass("highlighted"),
			this.result_highlight = null
		},
		e.prototype.results_show = function () {
			var a;
			return this.is_multiple || (this.selected_item.addClass("chzn-single-with-drop"), this.result_single_selected && this.result_do_highlight(this.result_single_selected)),
			a = this.is_multiple ? this.container.height() : this.container.height() - 1,
			this.dropdown.css({
				top : a + "px",
				left : 0
			}),
			this.results_showing = !0,
			this.search_field.focus(),
			this.search_field.val(this.search_field.val()),
			this.winnow_results()
		},
		e.prototype.results_hide = function () {
			return this.is_multiple || this.selected_item.removeClass("chzn-single-with-drop"),
			this.result_clear_highlight(),
			this.dropdown.css({
				left : "-9000px"
			}),
			this.results_showing = !1
		},
		e.prototype.set_tab_index = function (a) {
			var b;
			if (this.form_field_jq.attr("tabindex"))
				return b = this.form_field_jq.attr("tabindex"), this.form_field_jq.attr("tabindex", -1), this.is_multiple ? this.search_field.attr("tabindex", b) : (this.selected_item.attr("tabindex", b), this.search_field.attr("tabindex", -1))
		},
		e.prototype.show_search_field_default = function () {
			return this.is_multiple && this.choices < 1 && !this.active_field ? (this.search_field.val(this.default_text), this.search_field.addClass("default")) : (this.search_field.val(""), this.search_field.removeClass("default"))
		},
		e.prototype.search_results_mouseup = function (b) {
			var c;
			c = a(b.target).hasClass("active-result") ? a(b.target) : a(b.target).parents(".active-result").first();
			if (c.length)
				return this.result_highlight = c, this.result_select(b)
		},
		e.prototype.search_results_mouseover = function (b) {
			var c;
			c = a(b.target).hasClass("active-result") ? a(b.target) : a(b.target).parents(".active-result").first();
			if (c)
				return this.result_do_highlight(c)
		},
		e.prototype.search_results_mouseout = function (b) {
			if (a(b.target).hasClass("active-result"))
				return this.result_clear_highlight()
		},
		e.prototype.choices_click = function (b) {
			b.preventDefault();
			if (this.active_field && !a(b.target).hasClass("search-choice") && !this.results_showing)
				return this.results_show()
		},
		e.prototype.choice_build = function (b) {
			var c,
			d,
			e = this;
			return c = this.container_id + "_c_" + b.array_index,
			this.choices += 1,
			this.search_container.before('<li class="search-choice" id="' + c + '"><span>' + b.html + '</span><a href="javascript:void(0)" class="search-choice-close" rel="' + b.array_index + '"></a></li>'),
			d = a("#" + c).find("a").first(),
			d.click(function (a) {
				return e.choice_destroy_link_click(a)
			})
		},
		e.prototype.choice_destroy_link_click = function (b) {
			return b.preventDefault(),
			this.is_disabled ? b.stopPropagation : (this.pending_destroy_click = !0, this.choice_destroy(a(b.target)))
		},
		e.prototype.choice_destroy = function (a) {
			return this.choices -= 1,
			this.show_search_field_default(),
			this.is_multiple && this.choices > 0 && this.search_field.val().length < 1 && this.results_hide(),
			this.result_deselect(a.attr("rel")),
			a.parents("li").first().remove()
		},
		e.prototype.results_reset = function (b) {
			this.form_field.options[0].selected = !0,
			this.selected_item.find("span").text(this.default_text),
			this.is_multiple || this.selected_item.addClass("chzn-default"),
			this.show_search_field_default(),
			a(b.target).remove(),
			this.form_field_jq.trigger("change");
			if (this.active_field)
				return this.results_hide()
		},
		e.prototype.result_select = function (a) {
			var b,
			c,
			d,
			e;
			if (this.result_highlight)
				return b = this.result_highlight, c = b.attr("id"), this.result_clear_highlight(), this.is_multiple ? this.result_deactivate(b) : (this.search_results.find(".result-selected").removeClass("result-selected"), this.result_single_selected = b, this.selected_item.removeClass("chzn-default")), b.addClass("result-selected"), e = c.substr(c.lastIndexOf("_") + 1), d = this.results_data[e], d.selected = !0, this.form_field.options[d.options_index].selected = !0, this.is_multiple ? this.choice_build(d) : (this.selected_item.find("span").first().text(d.text), this.allow_single_deselect && this.single_deselect_control_build()), (!a.metaKey || !this.is_multiple) && this.results_hide(), this.search_field.val(""), this.form_field_jq.trigger("change"), this.search_field_scale()
		},
		e.prototype.result_activate = function (a) {
			return a.addClass("active-result")
		},
		e.prototype.result_deactivate = function (a) {
			return a.removeClass("active-result")
		},
		e.prototype.result_deselect = function (b) {
			var c,
			d;
			return d = this.results_data[b],
			d.selected = !1,
			this.form_field.options[d.options_index].selected = !1,
			c = a("#" + this.container_id + "_o_" + b),
			c.removeClass("result-selected").addClass("active-result").show(),
			this.result_clear_highlight(),
			this.winnow_results(),
			this.form_field_jq.trigger("change"),
			this.search_field_scale()
		},
		e.prototype.single_deselect_control_build = function () {
			if (this.allow_single_deselect && this.selected_item.find("abbr").length < 1)
				return this.selected_item.find("span").first().after('<abbr class="search-choice-close"></abbr>')
		},
		e.prototype.winnow_results = function () {
			var b,
			c,
			d,
			e,
			f,
			g,
			h,
			i,
			j,
			k,
			l,
			m,
			n,
			o,
			p,
			q,
			r,
			s;
			this.no_results_clear(),
			j = 0,
			k = this.search_field.val() === this.default_text ? "" : a("<div/>").text(a.trim(this.search_field.val())).html(),
			g = this.search_contains ? "" : "^",
			f = new RegExp(g + k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"), "i"),
			n = new RegExp(k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"), "i"),
			s = this.results_data;
			for (o = 0, q = s.length; o < q; o++) {
				c = s[o];
				if (!c.disabled && !c.empty)
					if (c.group)
						a("#" + c.dom_id).css("display", "none");
					else if (!this.is_multiple || !c.selected) {
						b = !1,
						i = c.dom_id,
						h = a("#" + i);
						if (f.test(c.html))
							b = !0, j += 1;
						else if (c.html.indexOf(" ") >= 0 || c.html.indexOf("[") === 0) {
							e = c.html.replace(/\[|\]/g, "").split(" ");
							if (e.length)
								for (p = 0, r = e.length; p < r; p++)
									d = e[p], f.test(d) && (b = !0, j += 1)
						}
						b ? (k.length ? (l = c.html.search(n), m = c.html.substr(0, l + k.length) + "</em>" + c.html.substr(l + k.length), m = m.substr(0, l) + "<em>" + m.substr(l)) : m = c.html, h.html(m), this.result_activate(h), c.group_array_index != null && a("#" + this.results_data[c.group_array_index].dom_id).css("display", "list-item")) : (this.result_highlight && i === this.result_highlight.attr("id") && this.result_clear_highlight(), this.result_deactivate(h))
					}
			}
			return j < 1 && k.length ? this.no_results(k) : this.winnow_results_set_highlight()
		},
		e.prototype.winnow_results_clear = function () {
			var b,
			c,
			d,
			e,
			f;
			this.search_field.val(""),
			c = this.search_results.find("li"),
			f = [];
			for (d = 0, e = c.length; d < e; d++)
				b = c[d], b = a(b), b.hasClass("group-result") ? f.push(b.css("display", "auto")) : !this.is_multiple || !b.hasClass("result-selected") ? f.push(this.result_activate(b)) : f.push(void 0);
			return f
		},
		e.prototype.winnow_results_set_highlight = function () {
			var a,
			b;
			if (!this.result_highlight) {
				b = this.is_multiple ? [] : this.search_results.find(".result-selected.active-result"),
				a = b.length ? b.first() : this.search_results.find(".active-result").first();
				if (a != null)
					return this.result_do_highlight(a)
			}
		},
		e.prototype.no_results = function (b) {
			var c;
			return c = a('<li class="no-results">' + this.results_none_found + ' "<span></span>"</li>'),
			c.find("span").first().html(b),
			this.search_results.append(c)
		},
		e.prototype.no_results_clear = function () {
			return this.search_results.find(".no-results").remove()
		},
		e.prototype.keydown_arrow = function () {
			var b,
			c;
			this.result_highlight ? this.results_showing && (c = this.result_highlight.nextAll("li.active-result").first(), c && this.result_do_highlight(c)) : (b = this.search_results.find("li.active-result").first(), b && this.result_do_highlight(a(b)));
			if (!this.results_showing)
				return this.results_show()
		},
		e.prototype.keyup_arrow = function () {
			var a;
			if (!this.results_showing && !this.is_multiple)
				return this.results_show();
			if (this.result_highlight)
				return a = this.result_highlight.prevAll("li.active-result"), a.length ? this.result_do_highlight(a.first()) : (this.choices > 0 && this.results_hide(), this.result_clear_highlight())
		},
		e.prototype.keydown_backstroke = function () {
			return this.pending_backstroke ? (this.choice_destroy(this.pending_backstroke.find("a").first()), this.clear_backstroke()) : (this.pending_backstroke = this.search_container.siblings("li.search-choice").last(), this.pending_backstroke.addClass("search-choice-focus"))
		},
		e.prototype.clear_backstroke = function () {
			return this.pending_backstroke && this.pending_backstroke.removeClass("search-choice-focus"),
			this.pending_backstroke = null
		},
		e.prototype.keydown_checker = function (a) {
			var b,
			c;
			b = (c = a.which) != null ? c : a.keyCode,
			this.search_field_scale(),
			b !== 8 && this.pending_backstroke && this.clear_backstroke();
			switch (b) {
			case 8:
				this.backstroke_length = this.search_field.val().length;
				break;
			case 9:
				this.results_showing && !this.is_multiple && this.result_select(a),
				this.mouse_on_container = !1;
				break;
			case 13:
				a.preventDefault();
				break;
			case 38:
				a.preventDefault(),
				this.keyup_arrow();
				break;
			case 40:
				this.keydown_arrow()
			}
		},
		e.prototype.search_field_scale = function () {
			var b,
			c,
			d,
			e,
			f,
			g,
			h,
			i,
			j;
			if (this.is_multiple) {
				d = 0,
				h = 0,
				f = "position:absolute; left: -1000px; top: -1000px; display:none;",
				g = ["font-size", "font-style", "font-weight", "font-family", "line-height", "text-transform", "letter-spacing"];
				for (i = 0, j = g.length; i < j; i++)
					e = g[i], f += e + ":" + this.search_field.css(e) + ";";
				return c = a("<div />", {
						style : f
					}),
				c.text(this.search_field.val()),
				a("body").append(c),
				h = c.width() + 25,
				c.remove(),
				h > this.f_width - 10 && (h = this.f_width - 10),
				this.search_field.css({
					width : h + "px"
				}),
				b = this.container.height(),
				this.dropdown.css({
					top : b + "px"
				})
			}
		},
		e.prototype.generate_random_id = function () {
			var b;
			b = "sel" + this.generate_random_char() + this.generate_random_char() + this.generate_random_char();
			while (a("#" + b).length > 0)
				b += this.generate_random_char();
			return b
		},
		e
	}
	(AbstractChosen),
	c = function (a) {
		var b;
		return b = a.outerWidth() - a.width()
	},
	d.get_side_border_padding = c
}
.call(this)
/*Custom Scripting*/
/*Returns unique values in an array*/
$.extend({
    distinct: function (anArray) {
        var result = [];
        $.each(anArray, function (i, v) {
            if ($.inArray(v, result) == -1) result.push(v);
        });
        return result;
    }
});

//create the form launch function
pwx_form_launch = function (persId, encntrId, formId, activityId, chartMode) {
    var pwxFormObj = window.external.DiscernObjectFactory('POWERFORM');
    pwxFormObj.OpenForm(persId, encntrId, formId, activityId, chartMode);
}
//create the task launch function
pwx_task_launch = function (persId, taskId, chartMode) {
    var collection = window.external.DiscernObjectFactory("INDEXEDDOUBLECOLLECTION");  //creates indexed double collection
    var taskArr = taskId.split(',');
    for (var i = 0; i < taskArr.length; i++) {  //loops through standard javascript array to extract each taskId.
        collection.Add(taskArr[i]);  //adds each task id to the indexed double collection
    }
    var pwxTaskObj = window.external.DiscernObjectFactory("TASKDOC");
    var success = pwxTaskObj.DocumentTasks(window, persId, collection, chartMode);

    return success;
}
//create the task label print launch function
pwx_task_label_print_launch = function (persId, taskId) {
    var collection = window.external.DiscernObjectFactory("INDEXEDDOUBLECOLLECTION");  //creates indexed double collection
    var taskArr = taskId.split(',');
    for (var i = 0; i < taskArr.length; i++) {  //loops through standard javascript array to extract each taskId.
        collection.Add(taskArr[i]);  //adds each task id to the indexed double collection
    }
    var pwxTaskObj = window.external.DiscernObjectFactory("TASKDOC");
    var success = pwxTaskObj.PrintLabels(persId, collection);
    return success;
}
//create form menu function
pwx_form_menu = function (form_menu_id) {
    var element;
    if (document.getElementById && (element = document.getElementById(form_menu_id))) {
        if (document.getElementById(form_menu_id).style.display == 'block') {
            document.getElementById(form_menu_id).style.display = 'none';
        }
        else {
            document.getElementById(form_menu_id).style.display = 'block';
        }
    }
}

//set patient focus
pwx_set_patient_focus = function (persId, encntrId, personName) {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.SetPatientFocus(persId,encntrId,personName);
	}
}
//clear patient focus
pwx_clear_patient_focus = function () {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.ClearPatientFocus();
	}
}
pwx_get_selected = function (class_name) {
    var selectedElems = new Array(8);
    selectedElems[0] = new Array()
    selectedElems[1] = new Array()
    selectedElems[2] = new Array()
    selectedElems[3] = new Array()
    selectedElems[4] = new Array()
    selectedElems[5] = new Array()
    selectedElems[6] = new Array()
    selectedElems[7] = new Array()
    $(class_name).each(function (index) {
        selectedElems[0].length = index + 1
        selectedElems[1].length = index + 1
        selectedElems[2].length = index + 1
        selectedElems[3].length = index + 1
        selectedElems[4].length = index + 1
        selectedElems[5].length = index + 1
        selectedElems[6].length = index + 1
        selectedElems[7].length = index + 1
        selectedElems[0][index] = $(this).children('span.pwx_task_id_hidden').text() + ".0";
        selectedElems[1][index] = $(this).children('dt.pwx_task_type_ind_hidden').text()
        selectedElems[2][index] = $(this).children('dt.pwx_fcr_content_status_dt').text()
        selectedElems[3][index] = $(this).children('dt.pwx_task_canchart_hidden').text()
        selectedElems[4][index] = $(this).children('dt.pwx_person_id_hidden').text() + ".0";
        selectedElems[5][index] = $(this).children('dt.pwx_encounter_id_hidden').text() + ".0";
        selectedElems[6][index] = $(this)
        selectedElems[7][index] = $(this).children('dt.pwx_task_order_id_hidden').text() + ".0";
    });
    return selectedElems;
}
pwx_get_selected_order_id = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var taskObj = $(class_name).children('dt.pwx_task_order_id_hidden').map(function () { return $(this).text() + ".0"; });
    var orderAr = jQuery.makeArray(taskObj);
    return orderAr;
}
pwx_get_selected_resched_time_limit = function (class_name) {
    var resched_detailsArr = new Array(2);
    resched_detailsArr[0] = $(class_name).children('dt.pwx_task_resched_time_hidden').text();
    resched_detailsArr[1] = $(class_name).children('dt.pwx_fcr_content_schdate_dt').text();
    return resched_detailsArr;
}
pwx_get_selected_task_comment = function (class_name) {
    var task_comment = '';
    task_comment = $(class_name).children('dt.pwx_task_comment_hidden').text();
    return task_comment;
}
pwx_get_selected_unchart_data = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var unchartTaskArr = new Array();
    $(class_name).children('dt.pwx_fcr_content_task_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
        var ar_cnt = unchartTaskArr.length
        unchartTaskArr.length = ar_cnt + 1
        unchartTaskArr[ar_cnt] = new Array(2);
        unchartTaskArr[ar_cnt][0] = $(this).children('span.pwx_task_lab_line_text_hidden').text();
        unchartTaskArr[ar_cnt][1] = $(this).children('span.pwx_task_lab_taskid_hidden').text() + ".0";
    });
    return unchartTaskArr;
}
pwx_get_selected_unchart_not_done = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var taskObj = $(class_name).children('dt.pwx_task_lab_notchart_hidden').map(function () { return $(this).text(); });
    var unchart_not_doneAr = jQuery.makeArray(taskObj);
    return unchart_not_doneAr;
}

//function to take date/times and sort and then reload the Task
function pwx_sort_by_task_date(a, b) {
    if (a.TASK_DT_TM_NUM < b.TASK_DT_TM_NUM)
        return -1
    if (a.TASK_DT_TM_NUM > b.TASK_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_view_prefs(a, b) {
    if (a.VIEW_SEQ < b.VIEW_SEQ)
        return -1
    if (a.VIEW_SEQ > b.VIEW_SEQ)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task(a, b) {
    var nameA = a.TASK_DISPLAY.toLowerCase(), nameB = b.TASK_DISPLAY.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_personname(a, b) {
    var nameA = a.PERSON_NAME.toLowerCase(), nameB = b.PERSON_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_visitdate(a, b) {
    if (a.VISIT_DT_TM_NUM < b.VISIT_DT_TM_NUM)
        return -1
    if (a.VISIT_DT_TM_NUM > b.VISIT_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_form_name(a, b) {
    var nameA = a.FORM_NAME.toLowerCase(), nameB = b.FORM_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task_type(a, b) {
    var nameA = a.TASK_TYPE.toLowerCase(), nameB = b.TASK_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_order_by(a, b) {
    var nameA = a.ORDERING_PROVIDER.toLowerCase(), nameB = b.ORDERING_PROVIDER.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_status(a, b) {
    var nameA = a.TASK_STATUS.toLowerCase(), nameB = b.TASK_STATUS.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_task_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_task_start_number = 0;
    json_task_end_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    if (clicked_header_id == pwx_task_header_id) {
        if (pwx_task_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_task_header_id = clicked_header_id
        pwx_task_sort_ind = sort_ind
        RenderTaskListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_schdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_date)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_orderby_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_by)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_task_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_visitdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_visitdate)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_type_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_type)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
        }
    }
}

function pwx_isOdd(num) { return num % 2; }

function pwx_select_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name).addClass(class_name);
}
function pwx_deselect_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name);
}

function callCCLLINK(ccllinkparams) {
    window.location = "javascript:CCLLINK('pwx_rpt_driver_to_mpage','" + ccllinkparams + "',0)";
}
function pwx_toggle_person_task_type_pref_save() {
    if ($('#pwx_update_task_type_pref_dt').length > 0) {
        $('#pwx_update_task_type_pref').off('click');
        $('#pwx_clear_task_type_pref').off('click');
        $('#pwx_update_task_type_pref_dt').off('click');
        $('#pwx_task_type_update_menu').off().remove();
        $('#pwx_update_task_type_pref_dt').html("").attr("id", "pwx_new_task_types_pref_dt");
        $('#pwx_new_task_types_pref_dt').html('<span id="pwx_new_task_types_pref" title="' + amb_i18n.SAVE_TASK_TYPE_TOOLTIP + '" class="pwx-discsave-icon pwx_pointer_cursor">&nbsp;</span>');
        $('#pwx_new_task_types_pref_dt').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
                return this.value;
            }).get();
            typeArr = jQuery.makeArray(array_of_checked_values);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
            pwx_toggle_person_task_type_pref_save()
        });
    }
    else if ($('#pwx_new_task_types_pref_dt').length > 0) {
        $('#pwx_new_task_types_pref_dt').off('click').html("").attr("id", "pwx_update_task_type_pref_dt");
        var newHTML = '<span class="pwx-discsave_checkmark-icon">&nbsp;</span><span class="pwx-icon_submenu_arrow-icon">&nbsp;</span>';
        $('#pwx_update_task_type_pref_dt').html(newHTML);
        $('#pwx_update_task_type_pref_dt').after('<div id="pwx_task_type_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_type_pref">' + amb_i18n.UPDATE + '</a></br><a class="pwx_result_link" id="pwx_clear_task_type_pref">' + amb_i18n.CLEAR + '</a></div>')
        $('#pwx_task_type_update_menu').on('mouseleave', function (event) {
            $(this).css('display', 'none');
        });
        $('#pwx_update_task_type_pref_dt').on('click', function (event) {
            var dt_pos = $(this).position();
            $('#pwx_task_type_update_menu').css('top', dt_pos.top + 16).css('left', dt_pos.left + 20).css('display', 'block');
        });
        $('#pwx_update_task_type_pref').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
                return this.value;
            }).get();
            typeArr = jQuery.makeArray(array_of_checked_values);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
            $('#pwx_task_type_update_menu').css('display', 'none');
        });
        $('#pwx_clear_task_type_pref').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", "", true)
            $('#pwx_task_type_update_menu').css('display', 'none');
            pwx_toggle_person_task_type_pref_save()
        });
    }
}

function pwx_open_person_details(details) {
    //alert(JSON.stringify(details))
    var detailText = [];
    detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', details.PERSON_NAME, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', details.DOB, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', details.PT_AGE, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', details.GENDER_CD, '</span>')
    detailText.push('</div></br></br>')
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.MRN,':</dt><dd>', details.MRN, '</dd></dl>')
	if(details.VISIT_DT_UTC != "" && details.VISIT_DT_UTC != "TZ") {
		var visitUTCDate = new Date();
		visitUTCDate.setISO8601(details.VISIT_DT_UTC);
		detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE,':</dt><dd>', visitUTCDate.format("shortDate3"), '</dd></dl>')
	} else {
		detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE,':</dt><dd>--</dd></dl>')
	}
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_LOC,':</dt><dd>', details.VISIT_LOC, '</dd></dl>')
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PCP,':</dt><dd>')
    if (details.PCP == "") { detailText.push("--") }
    else { detailText.push(details.PCP) }
    detailText.push('</dd></dl>')
    if (details.PHONE.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PHONE_NUM,' (', details.PHONE.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.PHONE.length; cc++) {
            detailText.push('<span ><span class="pwx_grey">', details.PHONE[cc].PHONE_TYPE, ':</span> ', details.PHONE[cc].PHONE_NUM, '</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PHONE_NUM,' (0):</dt><dd>--</dd></dl>')
    }
    if (details.DLIST.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DIAG,' (', details.DLIST.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.DLIST.length; cc++) {
            detailText.push('<span>', details.DLIST[cc].DIAG);
            if (details.DLIST[cc].CODE != "") {
                detailText.push('<span class="pwx_grey"> (', details.DLIST[cc].CODE, ')</span>');
            }
            detailText.push('</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DIAG,' (0):</dt><dd>--</dd></dl>')
    }

    if (details.ALLERGIES.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ALLERGIES,' (', details.ALLERGIES.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.ALLERGIES.length; cc++) {
            detailText.push('<span >', details.ALLERGIES[cc].ALLERGY);
            if (details.ALLERGIES[cc].REACTION != "") {
                detailText.push(': <span class="pwx_grey">', details.ALLERGIES[cc].REACTION, '</span>');
            }
            detailText.push('</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ALLERGIES,' (0):</dt><dd>--</dd></dl>')
    }
    MP_ModalDialog.deleteModalDialogObject("PatientDetailModal")
    var ptDetailModal = new ModalDialog("PatientDetailModal")
             .setHeaderTitle(amb_i18n.PATIENT_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(30)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(30)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
    ptDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + detailText.join("") + '</div>');
             });
    var closebtn = new ModalButton("addCancel");
    closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
    ptDetailModal.addFooterButton(closebtn)
    MP_ModalDialog.addModalDialogObject(ptDetailModal);
    MP_ModalDialog.showModalDialog("PatientDetailModal")
}

function pwx_timer_display() {
    pwx_task_count += 1;
    $('#pwx_loading_div_time').text(pwx_task_count + ' ' + amb_i18n.SEC)
}
function start_pwx_timer() {
    pwx_task_count = 0;
    pwx_task_counter = 0;
    pwx_task_counter = setInterval("pwx_timer_display()", 1000);
}

function stop_pwx_timer() {
    clearInterval(pwx_task_counter)
}
//PWX Mpage Framework
//function to call a ccl script to gather data and return the json object
function PWX_CCL_Request(program, paramAr, async, callback) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.RECORD_DATA;
            if (recordData.STATUS_DATA.STATUS === "S") {
                callback.call(recordData);
            }
            else {
                callback.call(recordData);
                alert(amb_i18n.STATUS + ": ", this.status, "<br />" + amb_i18n.REQUEST_TEXT + ": ", this.requestText);
            }
        }
    };
    info.open('GET', program, async);
    info.send(paramAr.join(","));
}

//render page
var pwx_task_header_id = "pwx_fcr_header_schdate_dt";
var pwx_task_sort_ind = "0";
var pwx_all_show_clicked = "0";
var pwx_task_get_type = "0";
var pwx_task_get_type_str = "All";
var pwx_global_statusArr = new Array;
var pwx_global_typeArr = new Array;
var pwx_global_orderprovArr = new Array;
var pwx_global_orderprovFiltered = 0;
var pwx_global_expanded = 0;
var pwx_current_set_location = 0;
var pwx_task_global_from_date = "0";
var pwx_task_global_to_date = "0";
var pwx_task_submenu_clicked_task_id = "0";
var pwx_task_submenu_clicked_order_id = "0";
var pwx_task_submenu_clicked_person_id = "0";
var pwx_task_submenu_clicked_task_type_ind = 0;
var pwx_task_submenu_clicked_row_elem;
var reschedule_TaskIds = '';
var start_page_load_timer = new Date();
var ccl_timer = 0;
var filterbar_timer = 0;
var delegate_event_timer = 0;
var json_task_end_number = 0;
var json_task_start_number = 0;
var json_task_page_start_numbersAr = [];
var task_list_curpage = 1;
var pwx_task_counter;
var current_from_date = '';
var current_to_date = '';
var current_location_id = 0;
var pwx_task_load_counter = 0;
//var pwxstoreddata;
function RenderPWxFrame() {
    json_task_end_number = 0;
    json_task_start_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    //gather data
    var js_criterion = JSON.parse(m_criterionJSON);
    $.contextMenu('destroy');
    $('#pwx_frame_filter_content').empty();
    //set pref
    PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_MULTI_TASK_TAB_PREF", "ORDERTASKS", true)
    //display frame header
    var headelement = document.getElementById('pwx_frame_head');
    var pwxheadHTML = [];
    pwxheadHTML.push('<div id="pwx_frame_toolbar"><dt class="pwx_list_view_radio">');
    pwxheadHTML.push('<div class="pwx_tasklist-seg-cntrl tab-layout-active" ><div id="tasklistLeft"></div><div id="tasklistCenter">',amb_i18n.ORDER_TASKS,'</div><div id="tasklistRight"></div></div>')
    if (js_criterion.CRITERION.PWX_REFLAB_LIST_DISP == 1) {
        pwxheadHTML.push('<div class="pwx_reflab-seg-cntrl" onclick="RenderPWxRefLabFrame()"><div id="refLabLeft"></div><div id="refLabCenter">',amb_i18n.REF_LAB,'</div><div id="refLabRight"></div></div>');
    }
    pwxheadHTML.push('<div id="pwx_list_total_count"><span class="pwx_grey">0 total ',amb_i18n.TOTAL_ITEMS,'</span></div></dt>');
    if (js_criterion.CRITERION.PWX_HELP_LINK != "") {
        //pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: CCLNEWSESSIONWINDOW("', js_criterion.CRITERION.PWX_HELP_LINK, '","_blank","left=0,top=0,width=1200,height=700,toolbar=no",0,1)\' class="pwx_no_text_decor" title="Help Page" onClick="">',
        pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: APPLINK(100,"', js_criterion.CRITERION.PWX_HELP_LINK, '","")\' class="pwx_no_text_decor" title="',amb_i18n.HELP_PAGE,'" onClick="">',
        '<span class="pwx-help-icon">&nbsp;</span></a></dt>');
    }
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.DESELECT_ALL,'" onClick="pwx_deselect_all(\'pwx_row_selected\')"> <span class="pwx-deselect_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.SELECT_ALL,'" onClick="pwx_select_all(\'pwx_row_selected\')"><span class="pwx-select_all-icon">&nbsp;</span></a></dt>');
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
    }
    pwxheadHTML.push('<dt id="pwx_location_list">');
    if (js_criterion.CRITERION.LOC_LIST.length > 0) {
        pwxheadHTML.push('<span class="pwx_location_list_lbl">',amb_i18n.LOCATION,': </span>');
		pwxheadHTML.push('<select id="task_location" name="task_location" style="width:300px;" data-placeholder="Choose a Location..." class="chzn-select"><option value=""></option>');
        var loc_height = 30;
        for (var i = 0; i < js_criterion.CRITERION.LOC_LIST.length; i++) {
            loc_height += 26;
            if (pwx_current_set_location == js_criterion.CRITERION.LOC_LIST[i].ORG_ID) {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '" selected="selected">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
            else {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
        }
        if (loc_height > 300) { loc_height = 300; }
        pwxheadHTML.push('</select>');
    }
    else {
        pwxheadHTML.push(amb_i18n.NO_RELATED_LOC);
    }
    pwxheadHTML.push('</dt></div><div id="pwx_task_loc_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_loc_pref">',amb_i18n.UPDATE,'</a></br><a class="pwx_result_link" id="pwx_clear_task_loc_pref">',amb_i18n.CLEAR,'</a></div>');
    headelement.innerHTML = pwxheadHTML.join("");

	$('#task_location').chosen({
		no_results_text : "No results matched"
	});
    $("#task_location").on("change", function (event) {
        pwx_current_set_location = $("#task_location").val();
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_LOCS", pwx_current_set_location, true);
    });

    //display the filter bar with date pickers
    var filterelement = document.getElementById('pwx_frame_filter_content');
    //build the filter bar
    var pwxfilterbarHTML = [];
    pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar"><div id="pwx_frame_filter_bar_container"><dl>');
    pwxfilterbarHTML.push('<dt id="pwx_date_picker"><label for="from"><span style="vertical-align:20%;">',amb_i18n.TASK_DATE,': </span><input type="text" id="from" name="from" class="pwx_date_box" /></label><label for="to"><span style="vertical-align:20%;"> ',amb_i18n.TO,' </span><input type="text" id="to" name="to" class="pwx_date_box" /></label></dt>');
    pwxfilterbarHTML.push('<dt id="pwx_task_status_filter"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_left_icon" id="pwx_task_adv_filter_tgl"></dt>')
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_info_icon"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_list_refresh_icon"></dt>');
    pwxfilterbarHTML.push('<div id="pwx_frame_advanced_filters_container" style="display:none;">')
    pwxfilterbarHTML.push('<dt id="pwx_task_orderprov_filter"></dt><dt id="pwx_task_type_filter"></dt><dt class="pwx_task_adv_filterbar_left_icon pwx_pointer_cursor" id="pwx_task_type_pref_dt"></dt></div>')
    pwxfilterbarHTML.push('</dl></div>');
    pwxfilterbarHTML.push('<div id="pwx_frame_paging_bar_container" style="display:none;"><dt id="pwx_task_filterbar_page_prev" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_filterbar_page_next" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_pagingbar_cur_page" class="pwx_grey"></dt><dt id="pwx_task_pagingbar_load_text"></dt><dt id="pwx_task_pagingbar_load_count" class="pwx_grey"></dt></div>');
    pwxfilterbarHTML.push('<dl><dt id="pwx_frame_filter_bar_bottom_pad"></dt><dl></div>');
    filterelement.innerHTML = pwxfilterbarHTML.join("");
    //function to handle a date range entry
    function RenderDateRangeTaskList(selectedDate, dateId, locId) {
        if (dateId == 'to') {
            current_to_date = selectedDate;
            pwx_task_global_to_date = selectedDate;
            $("#from").datepicker("option", "maxDate", selectedDate);
            mindate = Date.parse(selectedDate).addDays(-31).toString("MM/dd/yyyy");
            $("#from").datepicker("option", "minDate", mindate);
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
        }
        else if (dateId == 'from') {
            current_from_date = selectedDate;
            pwx_task_global_from_date = selectedDate;
            $("#to").datepicker("option", "minDate", selectedDate);
            maxdate = Date.parse(selectedDate).addDays(31).toString("MM/dd/yyyy");
            $("#to").datepicker("option", "maxDate", maxdate);
            if ($("#to").val() != "" && current_to_date == '') {
                $("#to").val("")
            }

        }
        else if (dateId == 'pwx_location') {
            current_location_id = locId;
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
            if ($("#to").val() != "" && current_to_date == '') {
                $("#to").val("")
            }
        }
        if (current_from_date != '' && current_to_date != '' && current_location_id > 0) {
            //both dates and location found load list
            $('#pwx_frame_content').empty();
            $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            pwx_current_set_location = current_location_id;
            pwx_task_global_from_date = current_from_date;
            pwx_task_global_to_date = current_to_date
            start_pwx_timer()
            var start_ccl_timer = new Date();
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + current_from_date + "^", "^" + current_to_date + "^", current_location_id + ".0"];
            PWX_CCL_Request("amb_cust_mp_task_by_loc_dt", sendArr, true, function () {
                pwx_global_orderprovArr = []
                current_to_date = "";
                current_from_date = "";
                $("#from, #to").datepicker("option", "maxDate", null)
                $("#from, #to").datepicker("option", "minDate", null)
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                start_page_load_timer = new Date();
                if (pwx_task_load_counter == 0) {
                    this.TLIST.sort(pwx_sort_by_task_date)
                    RenderTaskList(this);
                    pwx_task_load_counter += 1;
                }
                else {
                    switch (pwx_task_header_id) {
                        case 'pwx_fcr_header_task_dt':
                            this.TLIST.sort(pwx_sort_by_task)
                            break;
                        case 'pwx_fcr_header_personname_dt':
                            this.TLIST.sort(pwx_sort_by_personname)
                            break;
                        case 'pwx_fcr_header_visitdate_dt':
                            this.TLIST.sort(pwx_sort_by_visitdate)
                            break;
                        case 'pwx_fcr_header_schdate_dt':
                            this.TLIST.sort(pwx_sort_by_task_date)
                            break;
                        case 'pwx_fcr_header_orderby_dt':
                            this.TLIST.sort(pwx_sort_by_order_by)
                            break;
                        case 'pwx_fcr_header_type_dt':
                            this.TLIST.sort(pwx_sort_by_task_type)
                            break;
                        case 'pwx_fcr_header_status_dt':
                            this.TLIST.sort(pwx_sort_by_status)
                            break;
                    }
                    if (pwx_task_sort_ind == "1") {
                        this.TLIST.reverse()
                    }
                    filterbar_timer = 0
                    json_task_start_number = 0;
                    json_task_end_number = 0;
                    json_task_page_start_numbersAr = [];
                    task_list_curpage = 1;
                    //pwxstoreddata = this;
                    RenderTaskListContent(this)
                    pwx_task_load_counter += 1;
                }
            });
        }
    }
    //set the date range datepickers
    var dates = $("#from, #to").datepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        onSelect: function (selectedDate) {
            RenderDateRangeTaskList(selectedDate, this.id);
            $.datepicker._hideDatepicker();
        }
    });
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
    //$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	//var contentrowsH = filterbarH + 19;
	//$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
    $(window).on('resize', function () {
        //make sure fixed position for filter bar correct
        var toolbarH = $('#pwx_frame_toolbar').height() + 6;
        $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
        var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
		$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
		var contentrowsH = filterbarH + 19;
		$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_orderby_dt').each(function (index) {
            if (this.clientWidth < this.scrollWidth) {
                var titleText = $(this).text()
                $(this).attr("title", titleText)
            }
        });
    });
    $('#pwx_task_adv_filter_tgl').on('click', function () {
        if ($('#pwx_frame_advanced_filters_container').css('display') == 'none') {
            $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
            pwx_global_expanded = 1;
            $('#pwx_task_adv_filter_tgl').attr('title', amb_i18n.HIDE_ADV_FILTERS)
            $('#pwx_task_adv_filter_tgl').html('<span class="pwx-collapse-tgl"></span>')
            var toolbarH = $('#pwx_frame_toolbar').height() + 6;
            $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
            var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
			$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
			var contentrowsH = filterbarH + 19;
			$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        }
        else {
            $('#pwx_frame_advanced_filters_container').css('display', 'none')
            pwx_global_expanded = 0;
            $('#pwx_task_adv_filter_tgl').attr('title', amb_i18n.SHOW_ADV_FILTERS)
            $('#pwx_task_adv_filter_tgl').html('<span class="pwx-expand-tgl"></span>')
            var toolbarH = $('#pwx_frame_toolbar').height() + 6;
            $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
            var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
			$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
			var contentrowsH = filterbarH + 19;
			$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        }
    })
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        if (pwx_task_global_from_date == "0" || pwx_task_global_to_date == "0") {
            var fromdate = Date.today().addDays(-7).toString("MM/dd/yyyy");
            var todate = Date.today().toString("MM/dd/yyyy");
            $('#from').datepicker("setDate", fromdate)
            RenderDateRangeTaskList(fromdate, "from");
            $('#to').datepicker("setDate", todate)
            RenderDateRangeTaskList(todate, "to");
        }
        else {
            var fromdate = pwx_task_global_from_date;
            var todate = pwx_task_global_to_date;
            $('#from').datepicker("setDate", fromdate)
            RenderDateRangeTaskList(fromdate, "from");
            $('#to').datepicker("setDate", todate)
            RenderDateRangeTaskList(todate, "to");
        }
    }
    else {
        $('#pwx_frame_head').append('<div id="pwx-task_list_no_pref_dialog"><p class="pwx_small_text">' + amb_i18n.FIRST_LOGIN_SENT1 + '<br/>' +
        '</br></br><span class="pwx-location_pref_screen-icon"></span></br></br>' + amb_i18n.FIRST_LOGIN_SENT2 + '</p></div>')
        $("#pwx-task_list_no_pref_dialog").dialog({
            resizable: false,
            height: 400,
            width: 450,
            modal: true,
            title: '<span class="pwx-information-icon" style="vertical-align:10%"></span>&nbsp;<span class="pwx_alert" style="vertical-align:20%">' + amb_i18n.SAVE_LOC_PREF + '</span>',
            buttons: {
                "OK": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}
function RenderTaskList(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    framecontentElem.off()
    var start_filterbar_timer = new Date();
    var js_criterion = JSON.parse(m_criterionJSON);
    js_criterion.CRITERION.VPREF.sort(pwx_sort_view_prefs)
    var statusElem = $('#pwx_task_status_filter')
    var typeElem = $('#pwx_task_type_filter')
    var orderprovElem = $('#pwx_task_orderprov_filter')
    var statusHTML = [];
    if (pwx_global_statusArr.length > 0) {
        if (pwxdata.STATUS_LIST.length > 0) {
            statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
            for (var i = 0; i < pwxdata.STATUS_LIST.length; i++) {
                var status_match = 0;
                for (var y = 0; y < pwx_global_statusArr.length; y++) {
                    if (pwx_global_statusArr[y] == pwxdata.STATUS_LIST[i].STATUS) {
                        status_match = 1;
                        break;
                    }
                }
                if (status_match == 1) {
                    statusHTML.push('<option selected="selected" value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
                else {
                    statusHTML.push('<option value="', pwxdata.STATUS_LIST[i].STATUS + '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
            }
            statusHTML.push('</select>');
        }
    }
    else {
        if (pwxdata.STATUS_LIST.length > 0) {
            statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
            for (var i = 0; i < pwxdata.STATUS_LIST.length; i++) {
                if (pwxdata.STATUS_LIST[i].SELECTED == 1) {
                    statusHTML.push('<option selected="selected" value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
                else {
                    statusHTML.push('<option value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
            }
            statusHTML.push('</select>');
        }
    }
    $(statusElem).html(statusHTML.join(""))
    var typeHTML = [];
    if (pwx_global_typeArr.length > 0) {
        if (pwxdata.TYPE_LIST.length > 0) {
            typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
            for (var i = 0; i < pwxdata.TYPE_LIST.length; i++) {
                var type_match = 0;
                for (var y = 0; y < pwx_global_typeArr.length; y++) {
                    if (pwx_global_typeArr[y] == pwxdata.TYPE_LIST[i].TYPE) {
                        type_match = 1;
                        break;
                    }
                }
                if (type_match == 1) {
                    typeHTML.push('<option selected="selected" value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
                else {
                    typeHTML.push('<option value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
            }
            typeHTML.push('</select>');
        }
    }
    else {
        if (pwxdata.TYPE_LIST.length > 0) {
            typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
            for (var i = 0; i < pwxdata.TYPE_LIST.length; i++) {
                if (pwxdata.TYPE_LIST[i].SELECTED == 1) {
                    typeHTML.push('<option selected="selected" value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
                else {
                    typeHTML.push('<option value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
            }
            typeHTML.push('</select></dt>');
        }
    }
    $(typeElem).html(typeHTML.join(""))
    orderprovHTML = [];
    var fullOrderProv = $.map(pwxdata.TLIST, function (n, i) {
        return pwxdata.TLIST[i].ORDERING_PROVIDER;
    });
    var uniqueOrderProv = $.distinct(fullOrderProv);
    if (pwx_global_orderprovArr.length > 0 && pwx_global_orderprovFiltered == 1) {
        if (uniqueOrderProv.length > 0) {
            orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
            for (var i = 0; i < uniqueOrderProv.length; i++) {
                var type_match = 0;
                for (var y = 0; y < pwx_global_orderprovArr.length; y++) {
                    if (pwx_global_orderprovArr[y] == uniqueOrderProv[i]) {
                        type_match = 1;
                        break;
                    }
                }
                if (type_match == 1) {
                    orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
                else {
                    orderprovHTML.push('<option value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
            }
            orderprovHTML.push('</select>');
        }
    }
    else {
        if (uniqueOrderProv.length > 0) {
            orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
            for (var i = 0; i < uniqueOrderProv.length; i++) {
                orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
            }
            orderprovHTML.push('</select>');
        }
    }
    $(orderprovElem).html(orderprovHTML.join(""))
    if (pwxdata.TYPE_PREF_FOUND == 1) {
        $('#pwx_task_type_pref_dt').attr("id", "pwx_update_task_type_pref_dt")
        $('#pwx_update_task_type_pref_dt').html('<span class="pwx-discsave_checkmark-icon">&nbsp;</span><span class="pwx-icon_submenu_arrow-icon">&nbsp;</span>')
        $('#pwx_frame_advanced_filters_container').append('<div id="pwx_task_type_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_type_pref">' + amb_i18n.UPDATE + '</a></br><a class="pwx_result_link" id="pwx_clear_task_type_pref">' + amb_i18n.CLEAR + '</a></div>')
    }
    else {
        $('#pwx_task_type_pref_dt').attr("id", "pwx_new_task_types_pref_dt")
        $('#pwx_new_task_types_pref_dt').html('<span id="pwx_new_task_types_pref" title="' + amb_i18n.SAVE_TASK_TYPE_TOOLTIP + '" class="pwx-discsave-icon">&nbsp;</span>')
    }
    if (pwx_global_expanded == 1) {
        $('#pwx_task_adv_filter_tgl').attr('title',amb_i18n.HIDE_ADV_FILTERS)
        $('#pwx_task_adv_filter_tgl').html('<span class="pwx-collapse-tgl"></span>')
    } else {
        $('#pwx_task_adv_filter_tgl').attr('title',amb_i18n.SHOW_ADV_FILTERS)
        $('#pwx_task_adv_filter_tgl').html('<span class="pwx-expand-tgl"></span>')
    }

    if (pwxdata.TASK_INFO_TEXT != "") {
        $('#pwx_task_info_icon').html('<a class="pwx_no_text_decor" title="' + amb_i18n.TASK_LIST_INFO + '"> <span class="pwx-information-icon">&nbsp;</span></a>');
        $('#pwx_task_info_icon a').on('click', function () {
            MP_ModalDialog.deleteModalDialogObject("TaskInfoModal")
            var taskInfoModal = new ModalDialog("TaskInfoModal")
             .setHeaderTitle(amb_i18n.TASK_LIST)
             .setShowCloseIcon(true)
             .setTopMarginPercentage(20)
             .setRightMarginPercentage(35)
             .setBottomMarginPercentage(35)
             .setLeftMarginPercentage(35)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(false);
            taskInfoModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + pwxdata.TASK_INFO_TEXT + '</div>');
             });
            MP_ModalDialog.addModalDialogObject(taskInfoModal);
            MP_ModalDialog.showModalDialog("TaskInfoModal")
        });
    }
    $("#task_status").multiselect({
        height: "80",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_STATUS,
        selectedList: 2
    });
    $("#task_type").multiselect({
        height: "300",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_TYPE,
        selectedList: 1
    });
    $("#task_orderprov").multiselect({
        height: "300",
        minWidth: "300",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_PROV,
        selectedList: 1
    });
    $('#pwx_task_type_update_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_update_task_type_pref_dt').on('click', function (event) {
        var dt_pos = $(this).position();
        $('#pwx_task_type_update_menu').css('top', dt_pos.top + 16).css('left', dt_pos.left + 20).css('display', 'block');
    });
    $('#pwx_new_task_types_pref_dt').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        typeArr = jQuery.makeArray(array_of_checked_values);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
        pwx_toggle_person_task_type_pref_save()
    });
    $('#pwx_update_task_type_pref').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        typeArr = jQuery.makeArray(array_of_checked_values);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
        $('#pwx_task_type_update_menu').css('display', 'none');
    });
    $('#pwx_clear_task_type_pref').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", "", true)
        $('#pwx_task_type_update_menu').css('display', 'none');
        pwx_toggle_person_task_type_pref_save()
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_personname_dt a', function () {
        var parentelement = $(this).parents('dt.pwx_fcr_content_person_dt')
        var parentpersonid = $(parentelement).siblings('.pwx_person_id_hidden').text()
        var parentencntridid = $(parentelement).siblings('.pwx_encounter_id_hidden').text()
        var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid + ' /FIRSTTAB=^^'
        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
    });
    framecontentElem.on('mousedown', 'dl.pwx_content_row', function (e) {
        if (e.which == '3') {
            $(this).removeClass('pwx_row_selected').addClass('pwx_row_selected');
			var persId = $(this).children('dt.pwx_person_id_hidden').text();
			var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
			var persName = $(this).children('dt.pwx_person_name_hidden').text();
			pwx_set_patient_focus (persId, encntrId, persName);
        }
        else {
            //$(this).toggleClass('pwx_row_selected');
			if($(this).hasClass('pwx_row_selected') === true) {
				$(this).removeClass('pwx_row_selected');
				pwx_clear_patient_focus();
			} else {
				$(this).addClass('pwx_row_selected');
				var persId = $(this).children('dt.pwx_person_id_hidden').text();
				var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
				var persName = $(this).children('dt.pwx_person_name_hidden').text();
				pwx_set_patient_focus (persId, encntrId, persName);
			}
        }
    });
    //create dialogs
    //create the task note modal
    var pwxdialogHTML = []
    //create the reschedule modal
    pwxdialogHTML.push('<div id="pwx-resched-dialog-confirm"><p class="pwx_small_text"><label for="pwx_resched_dt_tm"><span style="vertical-align:30%;">',amb_i18n.RESCHEDULED_TO,': </span><input type="text" id="pwx_resched_dt_tm" name="pwx_resched_dt_tm" style="width: 125px; height:14px;" /></label></p></div>');
    $('#pwx_frame_filter_bar').after(pwxdialogHTML.join(""))

    $("#pwx-resched-dialog-confirm").dialog({
        resizable: false,
        height: 200,
        modal: true,
        autoOpen: false,
        title: amb_i18n.RESCHEDULE_TASK,
        buttons: [
            {
                text: amb_i18n.RESCHEDULE,
                id: "pwx-reschedule-btn",
                disabled: true,
                click: function () {
                    var real_date = Date.parse($("#pwx_resched_dt_tm").datetimepicker('getDate'))
                    var string_date = real_date.toString("MM/dd/yyyy HH:mm")
                    var resched_dt_tm = string_date.split(" ");
                    PWX_CCL_Request_Task_Reschedule('amb_cust_srv_task_reschedule', reschedule_TaskIds, resched_dt_tm[0], resched_dt_tm[1], false);
                    $(this).dialog("close");
                }
            },
            {
                text: amb_i18n.CANCEL,
                click: function () {
                    $(this).dialog("close");
                }
            }
        ]
    });
    $("#pwx_resched_dt_tm").datetimepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        ampm: true,
        timeFormat: "hh:mmtt",
        onSelect: function (dateText, inst) {
            if (dateText != "") {
                $('#pwx-reschedule-btn').button('enable')
            }
        }
    });

    //quick chart icons
    framecontentElem.on('click', 'span.pwx-med_task-icon.pwx_pointer_cursor, span.pwx-form_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
        }
    });
    framecontentElem.on('click', 'span.pwx-lab_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                    var taskSuccess = pwx_task_label_print_launch(cur_person_id, cur_task_id);
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                }
                else {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                }
            }
            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", cur_task_id, true) }, 1000); }
        }
    });
    framecontentElem.on('click', 'span.pwx-clip_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART_DONE');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
        }
    });
    //single click menus
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_menu', function (event) {
        pwx_task_submenu_clicked_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html()  + ".0";
        pwx_task_submenu_clicked_order_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_order_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_person_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_task_type_ind = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_type_ind_hidden').html();
        pwx_task_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_done_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 40) > scrolled_bottom_var) {
            $('#pwx_task_chart_menu').css('top', dt_pos.top - 40);
        }
        else {
            $('#pwx_task_chart_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_menu').css('display', 'block');
    });
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_done_menu', function (event) {
        pwx_task_submenu_clicked_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_order_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_order_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_person_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 55) > scrolled_bottom_var) {
            $('#pwx_task_chart_done_menu').css('top', dt_pos.top - 55);
        }
        else {
            $('#pwx_task_chart_done_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_done_menu').css('display', 'block');
    });
    //right click menu
    $.contextMenu('destroy', 'dl.pwx_content_row');
    $.contextMenu({
        selector: 'dl.pwx_content_row',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).addClass('pwx_row_selected')
            var taskInfo = pwx_get_selected('dl.pwx_row_selected');
            // alert(taskInfo[0][0] + ',' + taskInfo[1][0] + ',' + taskInfo[2][0] + ',');
            taskIdlist = taskInfo[0].join(',');
            reschedule_TaskIds = taskInfo[0][0]
            var chart_done_tasks_found = 0;
            var chart_tasks_found = 0;
            var lab_tasks_found = 0;
            var none_lab_tasks_found = 0;
            var chart_done_str = '';
            var can_not_chart_found = 0;
            for (var cc = 0; cc < taskInfo[1].length; cc++) {
                if (taskInfo[1][cc] == 0) {
                    chart_done_tasks_found = 1;
                    none_lab_tasks_found = 1;
                    chart_done_str = 'CHART_DONE';
                }
                else if (taskInfo[1][cc] == 1 || taskInfo[1][cc] == 2) {
                    chart_tasks_found = 1;
                    none_lab_tasks_found = 1;
                    chart_done_str = 'CHART';
                }
                else if (taskInfo[1][cc] == 3) {
                    lab_tasks_found = 1;
                    chart_done_tasks_found = 1;
                    chart_done_str = 'CHART_DONE';
                }
                if (taskInfo[3][cc] == 0) {
                    can_not_chart_found = 1;
                }
            }
            var uniquePersonArr = []
            uniquePersonArr = $.grep(taskInfo[4], function (v, k) {
                return $.inArray(v, taskInfo[4]) === k;
            });
            var uniqueEncounterArr = []
            uniqueEncounterArr = $.grep(taskInfo[5], function (v, k) {
                return $.inArray(v, taskInfo[5]) === k;
            });
            var ccllinkparams = '^MINE^,^' + js_criterion.CRITERION.PWX_PATIENT_SUMM_PRG + '^,' + uniquePersonArr[0] + '.0,' + uniqueEncounterArr[0] + '.0';
            var options = {
                items: {
                    "Done": { "name": amb_i18n.DONE, callback: function (key, opt) {
                        var lab_taskAr = new Array()
                        var lab_OrderAr = new Array()
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], chart_done_str);
                            if (taskSuccess == true) {
                                var dlHeight = $(taskInfo[6][cc]).height()
                                $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                                if (taskInfo[1][cc] == 3) {
                                    lab_taskAr.push(taskInfo[0][cc])
                                    lab_OrderAr.push(taskInfo[7][cc])
                                }
                            }
                        }
                        if (lab_taskAr.length > 0) {
                            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], lab_taskAr.join(','));
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                            }
                            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", lab_taskAr.join(','), true) }, 1000); }
                        }
                    }
                    },
                    "Done (with Date/Time)": { "name": amb_i18n.DONE_WITH_DATE_TIME, callback: function (key, opt) {
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], 'CHART_DONE_DT_TM');
                            if (taskSuccess == true) {
                                $('dl.pwx_row_selected').each(function (index) {
                                    var dlHeight = $(taskInfo[6][cc]).height()
                                    $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                    $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                                });
                            }
                        }
                    }
                    },
                    "Not Done": { "name": amb_i18n.NOT_DONE, callback: function (key, opt) {
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], 'CHART_NOT_DONE');
                            if (taskSuccess == true) {
                                var dlHeight = $(taskInfo[6][cc]).height()
                                $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                                $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                            }
                        }
                    }
                    },
                    "sep1": "---------",
                    "Unchart": { "name": amb_i18n.UNCHART, callback: function (key, opt) {
                        if (taskInfo[1][0] == 3) {
                            var unchartHTML = '<p class="pwx_small_text">';
                            var unchartArr = pwx_get_selected_unchart_data('dl.pwx_row_selected');
                            unchartHTML += amb_i18n.SELECT_UNCHART + ':';
                            for (var cc = 0; cc < unchartArr.length; cc++) {
                                unchartHTML += '<br /><input type="checkbox" checked="checked" name="pwx_unchart_tasks" value="' + unchartArr[cc][1] + '" />' + unchartArr[cc][0];
                            }
                            unchartHTML += '</p>';
                            MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                            var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(30)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(30)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + unchartHTML + '</div>');
                            });
                            var unchartbtn = new ModalButton("UnchartTask");
                            unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setOnClickFunction(function () {
                                var taskidObj = $("input[name='pwx_unchart_tasks']:checked").map(function () { return $(this).val(); });
                                var taskAr = jQuery.makeArray(taskidObj);
                                taskIdlist = taskAr.join(',');
                                if (taskIdlist != "") {
                                    PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, '', '3', false);
                                }
                            });
                            var closebtn = new ModalButton("unchartCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            unChartTaskModal.addFooterButton(unchartbtn)
                            unChartTaskModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                            MP_ModalDialog.showModalDialog("UnchartTaskModal")
                            $('input[name="pwx_unchart_tasks"]').on('change', function (event) {
                                var any_checked = 0;
                                $('input[name="pwx_unchart_tasks"]').each(function (index) {
                                    if ($(this).prop("checked") == true) {
                                        any_checked = 1;
                                    }
                                });
                                if (any_checked == 0) {
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                }
                                else {
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                }
                            });
                        }
                        else {
                            MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                            var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(30)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(30)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_unchart_task_comment">' + amb_i18n.UNCHART_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" ' +
                                'id="pwx_unchart_task_comment" name="pwx_unchart_task_comment" /></textarea></label></p></div>');
                            });
                            var unchartbtn = new ModalButton("UnchartTask");
                            unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_unchart_task_comment').text()
                                PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, comment_text, taskInfo[1][0], false);
                                $(this).dialog("close");
                            });
                            var closebtn = new ModalButton("unchartCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            unChartTaskModal.addFooterButton(unchartbtn)
                            unChartTaskModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                            MP_ModalDialog.showModalDialog("UnchartTaskModal")
                            $('#pwx_unchart_task_comment').on('keyup', function (event) {
                                if ($('#pwx_unchart_task_comment').text() != "") {
                                    $("#pwx-task-unchart-btn").button("enable");
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                }
                                else {
                                    $("#pwx-task-unchart-btn").button("disable");
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                }
                            })
                        }
                    }
                    },
                    "Reschedule": { "name": amb_i18n.RESCHEDULE, callback: function (key, opt) {
                        var time_check = pwx_get_selected_resched_time_limit('dl.pwx_row_selected');
                        var task_dt = Date.parse(time_check[1]);
                        if (lab_tasks_found == 0) {
                            var resched_limit_dt = task_dt.addHours(time_check[0]);
                        }
                        else {
                            var curDate = new Date()
                            var resched_limit_dt = curDate.addHours(time_check[0]);
                        }
                        $('#pwx_resched_dt_tm').val("")
                        $('#pwx-reschedule-btn').button('disable')
                        $("#pwx_resched_dt_tm").datetimepicker('option', 'minDate', new Date());
                        $("#pwx_resched_dt_tm").datetimepicker('option', 'maxDate', resched_limit_dt);
                        $("#pwx-resched-dialog-confirm").dialog('open')
                    }
                    },
                    "Task Comment": { "name": amb_i18n.TASK_COMM, callback: function (key, opt) {
                        var task_comm = pwx_get_selected_task_comment('dl.pwx_row_selected');
                        if (task_comm != "--") {
                            MP_ModalDialog.deleteModalDialogObject("TaskCommentModal")
                            var taskCommentModal = new ModalDialog("TaskCommentModal")
                                .setHeaderTitle(amb_i18n.TASK_COMM)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            taskCommentModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_create_task_comment">' + amb_i18n.TASK_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" id="pwx_create_task_comment" name="pwx_create_task_comment" >' + task_comm + '</textarea></label></p></div>');
                            });
                            var removebtn = new ModalButton("RemoveTaskComment");
                            removebtn.setText(amb_i18n.REMOVE).setCloseOnClick(true).setOnClickFunction(function () {
                                $('#pwx_create_task_comment').text("");
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, "", false);
                            });
                            var updatebtn = new ModalButton("updateTaskComment");
                            updatebtn.setText(amb_i18n.UPDATE).setCloseOnClick(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_create_task_comment').text();
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, comment_text, false);
                            });
                            var closebtn = new ModalButton("commentCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            taskCommentModal.addFooterButton(removebtn)
                            taskCommentModal.addFooterButton(updatebtn)
                            taskCommentModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(taskCommentModal);
                            MP_ModalDialog.showModalDialog("TaskCommentModal")
                        }
                        else {
                            MP_ModalDialog.deleteModalDialogObject("TaskCommentModal")
                            var taskCommentModal = new ModalDialog("TaskCommentModal")
                                .setHeaderTitle(amb_i18n.TASK_COMM)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            taskCommentModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_create_task_comment">' + amb_i18n.TASK_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" id="pwx_create_task_comment" name="pwx_create_task_comment" ></textarea></label></p></div>');
                            });
                            var createbtn = new ModalButton("createTaskComment");
                            createbtn.setText(amb_i18n.CREATE).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_create_task_comment').text()
                                if (comment_text != "") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, comment_text, false);
                                }
                            });
                            var closebtn = new ModalButton("commentCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            taskCommentModal.addFooterButton(createbtn)
                            taskCommentModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(taskCommentModal);
                            MP_ModalDialog.showModalDialog("TaskCommentModal")
                            $('#pwx_create_task_comment').on('keyup', function (event) {
                                if ($('#pwx_create_task_comment').text() != "") {
                                    $("#pwx_create_task_comment_btn").button("enable");
                                    taskCommentModal.setFooterButtonDither("createTaskComment", false);
                                }
                                else {
                                    $("#pwx_create_task_comment_btn").button("disable");
                                    taskCommentModal.setFooterButtonDither("createTaskComment", true);
                                }
                            })
                        }
                    }
                    },
                    "sep2": "---------",
                    "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                        if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                            var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                        }
                        else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                        }
                        else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                        }
                        else {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                        }
                        $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                    }
                    },
                    "fold2": { "name": amb_i18n.PRINT_REQ,
                        //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "items": {
                            "Selected Requisitions": { "name": amb_i18n.SELECTED_REQ, callback: function (key, opt) {
                                if (lab_tasks_found == 1) {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                } else {
                                    var ccllinkparams = '^MINE^,^' + taskIdlist + '^,' + 0;
                                    window.location = "javascript:CCLLINK('amb_cust_mp_call_orderreq','" + ccllinkparams + "',0)";
                                }
                            }
                            },
                            "Visit Requisitions": { "name": amb_i18n.VISIT_REQ, callback: function (key, opt) {
                                if (lab_tasks_found == 1) {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                } else {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + '';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_call_orderreq','" + ccllinkparams + "',0)";
                                }
                            }
                            }

                        }
                    },
                    "sep3": "---------",
                    //"Patient Summary": { "name": "Patient Summary", callback: function (key, opt) { callCCLLINK(ccllinkparams); } },
                    "fold1": {
                        //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "name": amb_i18n.CHART_FORMS,
                        "items": {},
                        disabled: false
                    },
                    "sep4": "---------",
                    "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); } },
                    "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); } },
                    "sep5": "---------",
                    "fold3": {
                        //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };
            if (uniqueEncounterArr.length > 1) {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                //options.items["Patient Summary"] = { "name": "Patient Summary", disabled: function (key, opt) { return true; } };
                //options.items["Print Requisitions"] = { "name": "Print Requisitions", disabled: function (key, opt) { return true; } };
                options.items["fold2"].items["Visit Requisitions"] = { "name": amb_i18n.VISIT_REQ, disabled: function (key, opt) { return true; } };
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            else {
                if (pwxdata.FORMSLIST.length > 0) {
                    for (var cc in pwxdata.FORMSLIST) {
                        options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                    }
                    options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                }
                else {
                    options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                }
                if (js_criterion.CRITERION.VPREF.length > 0) {
                    for (var cc in js_criterion.CRITERION.VPREF) {
                        options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                            var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                            APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                        }
                        }
                    }
                }
                else {
                    options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                }
            }
            if (pwxdata.ALLOW_REQ_PRINT == 0) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            if (uniquePersonArr.length > 1) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            if (taskInfo[0].length > 1) {
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
            }
            else {
                //check reschedule
                var time_check = pwx_get_selected_resched_time_limit('dl.pwx_row_selected');
                if (time_check[1] == "PRN" || time_check[0] < 1) {
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
                else {
                    if (lab_tasks_found == 0) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                        var task_dt = Date.parse(time_check[1]);
                        var resched_limit_dt = task_dt.addHours(time_check[0]);
                        var curDate = new Date()
                        var resched_ind = resched_limit_dt.compareTo(curDate);
                        if (resched_ind != 1) {
                            options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                        }
                    }
                }
            }
            var task_status_cancel_all = 0;
            var task_status_all_complete = 1;
            var task_status_complete_present = 0;
            var task_status_active_present = 0;
            for (var cc = 0; cc < taskInfo[2].length; cc++) {
                if (taskInfo[2][cc] != "Complete") {
                    task_status_all_complete = 0;
                }
                if (taskInfo[2][cc] == "Discontinued") {
                    task_status_cancel_all = 1;
                }
                else if (taskInfo[2][cc] == "Complete") {
                    task_status_complete_present = 1;
                }
                else {
                    task_status_active_present = 1;
                }
            }
            if (task_status_cancel_all == 1 || can_not_chart_found == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };

            }
            else if (task_status_all_complete == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                //options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                if (lab_tasks_found == 1) {
                    var unchart_status = pwx_get_selected_unchart_not_done('dl.pwx_row_selected');
                    if (unchart_status[0] > 0) {
                        options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                    }
                }
                if (none_lab_tasks_found == 1) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
            }
            else if (task_status_all_complete == 0 && task_status_complete_present == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                //options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
            }
            else {
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                if (chart_done_tasks_found == 1 && chart_tasks_found == 1) {
                    options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                else if (chart_done_tasks_found == 0 && chart_tasks_found == 1) {
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (lab_tasks_found == 1) {
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                } else {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (none_lab_tasks_found == 1) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
            }
            if(lab_tasks_found == 1){
				options.items["Task Comment"] = { "name": "Task Comment", disabled: function (key, opt) { return true; } };				
			}
            if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
            }
            if (none_lab_tasks_found == 1 && lab_tasks_found == 1) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    $('#pwx_task_list_refresh_icon').html('<span class="pwx-refresh-icon" title="' + amb_i18n.REFRESH_LIST + '"></span>')
    $('#pwx_task_list_refresh_icon').on('click', function () {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        var start_ccl_timer = new Date();
        var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + pwx_task_global_from_date + "^", "^" + pwx_task_global_to_date + "^", pwx_current_set_location + ".0"];
        PWX_CCL_Request("amb_cust_mp_task_by_loc_dt", sendArr, true, function () {
            var end_ccl_timer = new Date();
            ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
            start_page_load_timer = new Date();
            if (pwx_task_load_counter == 0) {
                this.TLIST.sort(pwx_sort_by_task_date)
                RenderTaskList(this);
                pwx_task_load_counter += 1;
            }
            else {
                switch (pwx_task_header_id) {
                    case 'pwx_fcr_header_task_dt':
                        this.TLIST.sort(pwx_sort_by_task)
                        break;
                    case 'pwx_fcr_header_personname_dt':
                        this.TLIST.sort(pwx_sort_by_personname)
                        break;
                    case 'pwx_fcr_header_visitdate_dt':
                        this.TLIST.sort(pwx_sort_by_visitdate)
                        break;
                    case 'pwx_fcr_header_schdate_dt':
                        this.TLIST.sort(pwx_sort_by_task_date)
                        break;
                    case 'pwx_fcr_header_orderby_dt':
                        this.TLIST.sort(pwx_sort_by_order_by)
                        break;
                    case 'pwx_fcr_header_type_dt':
                        this.TLIST.sort(pwx_sort_by_task_type)
                        break;
                    case 'pwx_fcr_header_status_dt':
                        this.TLIST.sort(pwx_sort_by_status)
                        break;
                }
                if (pwx_task_sort_ind == "1") {
                    this.TLIST.reverse()
                }
                filterbar_timer = 0
                json_task_start_number = 0;
                json_task_end_number = 0;
                json_task_page_start_numbersAr = [];
                task_list_curpage = 1;
                //pwxstoreddata = this;
                RenderTaskListContent(this)
                pwx_task_load_counter += 1;
            }
        });
    });
    
    var end_filterbar_timer = new Date();
    filterbar_timer = (end_filterbar_timer - start_filterbar_timer) / 1000
    RenderTaskListContent(pwxdata)
}

function RenderTaskListContent(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    $.contextMenu('destroy', 'span.pwx_fcr_content_type_person_icon_dt');
	pwx_clear_patient_focus();
    var js_criterion = JSON.parse(m_criterionJSON);
    var start_content_timer = new Date();
    var fullOrderProv = $.map(pwxdata.TLIST, function (n, i) {
        return pwxdata.TLIST[i].ORDERING_PROVIDER;
    });
    var uniqueOrderProv = $.distinct(fullOrderProv);
    if (pwx_task_load_counter > 0) {
        $('#pwx_task_orderprov_filter').empty();
        var orderprovElem = $('#pwx_task_orderprov_filter')
        orderprovHTML = [];
        if (pwx_global_orderprovArr.length > 0 && pwx_global_orderprovFiltered == 1) {
            if (uniqueOrderProv.length > 0) {
                orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
                for (var i = 0; i < uniqueOrderProv.length; i++) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_global_orderprovArr.length; y++) {
                        if (pwx_global_orderprovArr[y] == uniqueOrderProv[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                    }
                    else {
                        orderprovHTML.push('<option value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                    }
                }
                orderprovHTML.push('</select>');
            }
        }
        else {
            if (uniqueOrderProv.length > 0) {
                orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
                for (var i = 0; i < uniqueOrderProv.length; i++) {
                    orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
                orderprovHTML.push('</select>');
            }
        }
        $(orderprovElem).html(orderprovHTML.join(""))
        $("#task_orderprov").multiselect({
            height: "300",
            minWidth: "300",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.SELECT_PROV,
            selectedList: 1
        });
    }

    $("#task_status").off("multiselectclose")
    $("#task_type").off("multiselectclose")
    $("#task_orderprov").off("multiselectclose")
    framecontentElem.off('click', 'span.pwx_fcr_content_type_detail_icon_dt')
    framecontentElem.off('click', 'span.pwx_fcr_content_type_person_icon_dt')
    framecontentElem.off('click', 'dt.pwx_fcr_content_task_abn_dt')
    $("#task_status").on("multiselectclose", function (event, ui) {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $("#task_type").on("multiselectclose", function (event, ui) {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $("#task_orderprov").on("multiselectclose", function (event, ui) {
        var array_of_checked_values = $("#task_orderprov").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        pwx_global_orderprovArr = jQuery.makeArray(array_of_checked_values);
        if (pwx_global_orderprovArr.length == uniqueOrderProv.length) {
            pwx_global_orderprovFiltered = 0
        } else {
            pwx_global_orderprovFiltered = 1
        }
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $('#pwx_task_filterbar_page_prev').html("")
    $('#pwx_task_filterbar_page_prev').off()
    $('#pwx_task_filterbar_page_next').html("")
    $('#pwx_task_filterbar_page_next').off()
    var array_of_checked_values = $("#task_orderprov").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_orderprovArr = jQuery.makeArray(array_of_checked_values);
    var array_of_checked_values = $("#task_status").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_statusArr = jQuery.makeArray(array_of_checked_values);

    var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_typeArr = jQuery.makeArray(array_of_checked_values);
    var pwxcontentHTML = [];

    if (pwxdata.TLIST.length > 0) {
        //icon type
        if (pwx_task_sort_ind == '1') {
            var sort_icon = 'pwx-sort_up-icon';
        }
        else {
            var sort_icon = 'pwx-sort_down-icon';
        }
        //make the header
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl"><dt id="pwx_fcr_header_type_icon_dt">&nbsp;</dt>');
        if (pwx_task_header_id == 'pwx_fcr_header_personname_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_visitdate_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_visitdate_dt">',amb_i18n.VISIT_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_visitdate_dt">',amb_i18n.VISIT_DATE,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_task_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_schdate_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_orderby_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_type_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'</dt>');
        }
        pwxcontentHTML.push('</dl></div>');
		pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
		pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link">',amb_i18n.NOT_DONE,'</a></div>');
		pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_done_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_done_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_done_dt_tm_link">',amb_i18n.DONE_WITH_DATE_TIME,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link2">',amb_i18n.NOT_DONE,'</a></div>');
		var pwx_row_color = ''
        var row_cnt = 0;
        var pagin_active = 0;
        var end_of_task_list = 0;
        json_task_start_number = json_task_end_number;
        if (task_list_curpage > json_task_page_start_numbersAr.length) {
            json_task_page_start_numbersAr.push(json_task_start_number)
        }
        for (var i = json_task_end_number; i < pwxdata.TLIST.length; i++) {
            //do the filtering
            var status_match = 0
            for (var cc = 0; cc < pwx_global_statusArr.length; cc++) {
                if (pwx_global_statusArr[cc] == pwxdata.TLIST[i].TASK_STATUS) {
                    status_match = 1;
                    break;
                }
            }
            var type_match = 0
            for (var cc = 0; cc < pwx_global_typeArr.length; cc++) {
                if (pwx_global_typeArr[cc] == pwxdata.TLIST[i].TASK_TYPE) {
                    type_match = 1;
                    break;
                }
            }
            var orderprov_match = 0
            for (var cc = 0; cc < pwx_global_orderprovArr.length; cc++) {
                if (pwxdata.TLIST[i].ORDERING_PROVIDER.indexOf(pwx_global_orderprovArr[cc]) != -1) {
                    orderprov_match = 1;
                    break;
                }
            }
            var task_row_visable = '';
            var task_row_zebra_type = '';
            if (status_match == 1 && type_match == 1 && orderprov_match == 1) {
                if (pwx_isOdd(row_cnt) == 1) {
                    task_row_zebra_type = " pwx_zebra_dark "
                }
                else {
                    task_row_zebra_type = " pwx_zebra_light "
                }
                row_cnt++
                /*
                if (pwxdata.TLIST[i].TASK_OVERDUE == 1 && pwxdata.TLIST[i].TASK_STATUS == 'Active') {
                var overdue_icon = '<span class="pwx-highprio-icon">&nbsp;</span>';
                }
                else {
                var overdue_icon = '';
                }
                */
                if (pwxdata.TLIST[i].TASK_STATUS == 'Discontinued' || pwxdata.TLIST[i].CAN_CHART_IND == 0) {
                    var grey_text = ' pwx_grey ';
                }
                else if (pwxdata.TLIST[i].TASK_TYPE_IND == 3 && pwxdata.TLIST[i].TASK_STATUS == 'Complete' && pwxdata.TLIST[i].NOT_DONE > 0) {
                    var grey_text = ' pwx_grey ';
                }
                else {
                    var grey_text = '';
                }
                pwxcontentHTML.push('<dl class="pwx_content_row', grey_text, task_row_zebra_type, '">');
                pwxcontentHTML.push('<dt class="pwx_fcr_content_status_dt">', pwxdata.TLIST[i].TASK_STATUS, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
				pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_type_ind_hidden">', pwxdata.TLIST[i].TASK_TYPE_IND, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_comment_hidden">', pwxdata.TLIST[i].TASK_NOTE, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_fcr_content_type_icon_dt"><div class="pwx_fcr_content_action_bar">&nbsp;</div>');
                if (pwxdata.TLIST[i].TASK_STATUS == 'Active') {
                    if (pwxdata.TLIST[i].TASK_TYPE_IND > 0) {
                        var taskmenuClass = 'pwx_task_need_chart_menu';
                    }
                    else {
                        var taskmenuClass = 'pwx_task_need_chart_done_menu';
                    }
                    if (pwxdata.TLIST[i].CAN_CHART_IND == 1) {
                        var taskmenuIcon = '<span class="pwx-icon_submenu_arrow-icon ' + taskmenuClass + ' ">&nbsp;</span>';
                        if (pwxdata.TLIST[i].TASK_TYPE_IND == 1) {
                            pwxcontentHTML.push('<span class="pwx-med_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else if (pwxdata.TLIST[i].TASK_TYPE_IND == 2) {
                            pwxcontentHTML.push('<span class="pwx-form_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else if (pwxdata.TLIST[i].TASK_TYPE_IND == 3) {
                            pwxcontentHTML.push('<span class="pwx-lab_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else {
                            pwxcontentHTML.push('<span class="pwx-clip_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx-task_disabled-icon" title="',amb_i18n.TASK_NOT_AVAIL,'">&nbsp;</span>');
                    }
                }
                else if (pwxdata.TLIST[i].TASK_STATUS == 'Complete') {
                    var completeicon = '<span class="pwx-completed_grey-icon" title="' + amb_i18n.TASK_DONE + '"></span>';
                    if (pwxdata.TLIST[i].NOT_DONE > 0) {
                        completeicon = '<span class="pwx-complet_not_done_grey-icon" title="' + amb_i18n.TASK_NOT_DONE + '"></span>';
                    }
                    pwxcontentHTML.push(completeicon);
                }
                else if (pwxdata.TLIST[i].TASK_STATUS == 'Discontinued') {
                    pwxcontentHTML.push('<span class="pwx-cancelcircle_grey-icon" title="',amb_i18n.TASK_DISCONTINUED,'"></span>');
                }
                pwxcontentHTML.push('</dt>');
                //build the task column now to see if more that one line
                var task_colHTML = [];
                //add italic class if inprocess;
                if (pwxdata.TLIST[i].INPROCESS_IND == 1) { var italicClass = 'pwx_italic'; var italicTitle = 'title="' + amb_i18n.TASK_IN_PROCESS + '"' } else { var italicClass = ''; var italicTitle = '' }
                //display based on if task is lab or anything else
                if (pwxdata.TLIST[i].TASK_TYPE_IND == 3) {
                    task_colHTML.push('<dt class="pwx_fcr_content_task_dt ' + italicClass + '" ' + italicTitle + '><span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].TASK_DISPLAY);
                    if (pwxdata.TLIST[i].POWERPLAN_IND > 0) {
                        task_colHTML.push('&nbsp;&nbsp;&nbsp;<span class="pwx-powerplan-icon"></span>');
                    }
                    task_colHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        task_colHTML.push('<div class="pwx_task_lab_container_hidden">');
                        task_colHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        task_colHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        task_colHTML.push('</div>');
                        task_colHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    task_colHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
                }
                else {
                    task_colHTML.push('<dt class="pwx_fcr_content_task_dt  ' + italicClass + '" ' + italicTitle + '><span class="pwx_fcr_content_type_name_dt">', pwxdata.TLIST[i].TASK_DISPLAY);
                    if (pwxdata.TLIST[i].ORD_COMMENT != "--") {
                        task_colHTML.push('<span class="pwx-small-comment-icon" title="',amb_i18n.ORDER_COMM_DETECT,'">&nbsp;</span>');
                    }
                    else if (pwxdata.TLIST[i].TASK_NOTE != "--") {
                        task_colHTML.push('<span class="pwx-small-comment-icon" title="',amb_i18n.TASK_COMM_DETECT,'">&nbsp;</span>');
                    }
                    if (pwxdata.TLIST[i].POWERPLAN_IND > 0) {
                        task_colHTML.push('&nbsp;&nbsp;&nbsp;<span class="pwx-powerplan-icon">&nbsp;</span>');
                    }
                    if (pwxdata.TLIST[i].ORDER_CDL != "--") {
                        task_colHTML.push('&nbsp;<span class="pwx_grey pwx_extra_small_text">', pwxdata.TLIST[i].ORDER_CDL, '</span>');
                    }
                    task_colHTML.push('</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>',
                '</dt><span class="pwx_task_id_hidden">', pwxdata.TLIST[i].TASK_ID, '</span>');
                    var task_row_lines = '';
                }
                //display pt and visit date column
                pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
				if(pwxdata.TLIST[i].VISIT_DT_UTC != "" && pwxdata.TLIST[i].VISIT_DT_UTC != "TZ") {
					var visitUTCDate = new Date();
					visitUTCDate.setISO8601(pwxdata.TLIST[i].VISIT_DT_UTC);
					pwxcontentHTML.push('<dt class="pwx_fcr_content_visitdate_dt">', visitUTCDate.format("shortDate3"), task_row_lines, '</dt>');
				} else {
					pwxcontentHTML.push('<dt class="pwx_fcr_content_visitdate_dt">--', task_row_lines, '</dt>');
				}
                //insert the task column here
                pwxcontentHTML.push(task_colHTML.join(""));
                if (pwxdata.TLIST[i].TASK_PRN_IND == 1) {
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt" style="padding-bottom:2px;">PRN', task_row_lines, '</dt>');
                }
                else {
					//Shaun UTC Change
                    //pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].TASK_DATE, ' ', pwxdata.TLIST[i].TASK_TIME, ' ', task_row_lines, '</span></dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">', taskUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                }
                pwxcontentHTML.push('<dt class="pwx_fcr_content_orderby_dt pwx_grey">', pwxdata.TLIST[i].ORDERING_PROVIDER, task_row_lines, '</dt>');
                //if abn add this here
                var abnDT = ""
                var abnmodStyle = ""
                if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                    abnDT = '<dt class="pwx_fcr_content_task_abn_dt" title="' + amb_i18n.ABN_TOOLTIP + '"><span style="display:none" class="pwx_abn_track_id_hidden">' + pwxdata.TLIST[i].ABN_TRACK_IDS + '</span><span style="display:none" class="pwx_abn_json_id_hidden">' + i + '</span><span class="pwx-abn-icon"></span></dt>';
                    abnmodStyle = 'style="max-width:7.5%;"'
                }

                pwxcontentHTML.push('<dt class="pwx_fcr_content_type_dt pwx_grey" ' + abnmodStyle + '>', pwxdata.TLIST[i].TASK_TYPE, '</dt>', abnDT);

                pwxcontentHTML.push('</dl>');
            }
            if (i + 1 == pwxdata.TLIST.length) {
                end_of_task_list = 1;
            }
            if (row_cnt == 100) {
                json_task_end_number = i + 1; //add one to start on next one not displayed
                pagin_active = 1;
                break;
            }
        }
        if (row_cnt == 0) {
            pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_TASKS,'</span></dl>');
        }
    }
    else {
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"></div><div id="pwx_frame_content_rows"><dl class="pwx_content_nores_row"><span class="pwx_noresult_text">',amb_i18n.NO_RESULTS,'</span></dl>');
    }
    pwxcontentHTML.push('</div>');
    framecontentElem.html(pwxcontentHTML.join(""))
    var end_content_timer = new Date();
    var start_event_timer = new Date();
    $('#pwx_list_total_count').html('<span class="pwx_grey">' + pwxdata.TLIST.length + ' ' + amb_i18n.TOTAL_ITEMS + '</span>')
    $('#pwx_fcr_header_schdate_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_schdate_dt')
    });
    $('#pwx_fcr_header_orderby_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_orderby_dt')
    });
    $('#pwx_fcr_header_task_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_task_dt')
    });
    $('#pwx_fcr_header_personname_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_personname_dt')
    });
    $('#pwx_fcr_header_visitdate_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_visitdate_dt')
    });
    $('#pwx_fcr_header_type_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_type_dt')
    });
    $('#pwx_task_pagingbar_cur_page').text(amb_i18n.PAGE + ': ' + task_list_curpage)
    //setup next paging button
    if (pagin_active == 1 && end_of_task_list != 1) {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage-icon"></span>')
        $('#pwx_task_filterbar_page_next').on('click', function () {
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            task_list_curpage++
            RenderTaskListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage_grey-icon"></span>')
    }
    //setup prev paging button
    if (json_task_start_number > 0) {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage-icon"></span>')
        $('#pwx_task_filterbar_page_prev').on('click', function () {
            task_list_curpage--
            json_task_end_number = json_task_page_start_numbersAr[task_list_curpage - 1]
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            RenderTaskListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage_grey-icon"></span>')
    }
    if (json_task_start_number > 0 || (pagin_active == 1 && end_of_task_list != 1)) {
        $('#pwx_frame_paging_bar_container').css('display', 'inline-block')
    }
    else {
        $('#pwx_frame_paging_bar_container').css('display', 'none')
    }

    $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_orderby_dt').each(function (index) {
        if (this.clientWidth < this.scrollWidth) {
            var titleText = $(this).text()
            $(this).attr("title", titleText)
        }
    });
    //single click menus
    $('#pwx_task_chart_done_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_task_chart_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_task_chart_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
            if (pwx_task_submenu_clicked_task_type_ind == 3) {
                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                        var taskSuccess = pwx_task_label_print_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id);
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                    }
                    else {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                    }
                }
                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", pwx_task_submenu_clicked_task_id, true) }, 1000); }
            }
        }
        $('#pwx_task_chart_menu').css('display', 'none');
    });
    $('#pwx_task_chart_done_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_DONE');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    $('#pwx_task_chart_done_dt_tm_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_DONE_DT_TM');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    $('#pwx_task_chart_not_done_link, #pwx_task_chart_not_done_link2').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_NOT_DONE');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_menu').css('display', 'none');
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    //person menu
    $.contextMenu({
        selector: 'span.pwx_fcr_content_type_person_icon_dt',
        trigger: 'left',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).parents('dl.pwx_content_row').addClass('pwx_row_selected')
            json_index = $($trigger).children('span.pwx_task_json_index_hidden').text()
            var options = {
                items: {
                    "Visit Summary (Depart)": { "name": pwxdata.DEPART_LABEL, callback: function (key, opt) {
                        var dpObject = new Object();
                        dpObject = window.external.DiscernObjectFactory("DISCHARGEPROCESS");
                        dpObject.person_id = pwxdata.TLIST[json_index].PERSON_ID;
                        dpObject.encounter_id = pwxdata.TLIST[json_index].ENCOUNTER_ID;
                        dpObject.user_id = js_criterion.CRITERION.PRSNL_ID;
                        dpObject.LaunchDischargeDialog();
                    }
                    },
                    "fold1": {
                        "name": amb_i18n.CHART_FORMS,
                        "items": {},
                        disabled: false
                    },
                    "Patient Snapshot": { "name": amb_i18n.PATIENT_SNAPSHOT, callback: function (key, opt) {
                        PWX_CCL_Request_Person_Details("amb_cust_person_details_diag", pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, false)
                    }
                    },
                    "sep5": "---------",
                    "fold3": {
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };

            if (pwxdata.FORMSLIST.length > 0) {
                for (var cc in pwxdata.FORMSLIST) {
                    options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                }
                options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, 0.0, 0.0, 0); } }
            }
            else {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
            }
            if (pwxdata.ALLOW_DEPART == 0) {
                options.items["Visit Summary (Depart)"] = { "name": pwxdata.DEPART_LABEL, disabled: function (key, opt) { return true; } };
            }
            if (js_criterion.CRITERION.VPREF.length > 0) {
                for (var cc in js_criterion.CRITERION.VPREF) {
                    options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                        var parameter_person_launch = '/PERSONID=' + pwxdata.TLIST[json_index].PERSON_ID + ' /ENCNTRID=' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                    }
                    };
                }
            }
            else {
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    //task detail
    framecontentElem.on('click', 'span.pwx_fcr_content_type_detail_icon_dt', function (e) {
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var task_detailText = [];
        task_detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[json_index].PERSON_NAME, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[json_index].DOB, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[json_index].AGE, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[json_index].GENDER, '</span>')
        task_detailText.push('</div></br></br>')
        if (pwxdata.TLIST[json_index].TASK_STATUS == 'Complete') {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>');
            if (pwxdata.TLIST[json_index].NOT_DONE > 0) {
                task_detailText.push('<span class="pwx-complet_not_done-icon"></span>',amb_i18n.NOT_DONE,':');
				var reasonCD = ""
				if(pwxdata.TLIST[json_index].NOT_DONE_REASON != "") {
					reasonCD = '<dl class="pwx_task_detail_line"><dt>' + amb_i18n.REASON + ':</dt><dd>' + pwxdata.TLIST[json_index].NOT_DONE_REASON + '</dd></dl>';
					if(pwxdata.TLIST[json_index].NOT_DONE_REASON_COMM != "") {
						reasonCD += '<dl class="pwx_task_detail_line"><dt>' + amb_i18n.REASON_COMM + ':</dt><dd>' + pwxdata.TLIST[json_index].NOT_DONE_REASON_COMM + '</dd></dl>';
					}
				}
            }
            else {
                task_detailText.push('<span class="pwx-completed-icon"></span>',amb_i18n.DONE,':');
				var reasonCD = ""
            }
			if(pwxdata.TLIST[json_index].CHARTED_DT_UTC != "" && pwxdata.TLIST[json_index].CHARTED_DT_UTC != "TZ") {
				var chartedUTCDate = new Date();
				chartedUTCDate.setISO8601(pwxdata.TLIST[json_index].CHARTED_DT_UTC);
				task_detailText.push('<span style="color:black;padding-left:5px;">', pwxdata.TLIST[json_index].CHARTED_BY, ' ',amb_i18n.ON,' ', chartedUTCDate.format("longDateTime4"), '</span></dt><dd>&nbsp</dd></dl>',
				reasonCD,'<dl class="pwx_task_detail_line"><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			} else {
			    task_detailText.push('<span style="color:black;padding-left:5px;">', pwxdata.TLIST[json_index].CHARTED_BY, ' ',amb_i18n.ON,' --</span></dt><dd>&nbsp</dd></dl>',
				reasonCD,'<dl class="pwx_task_detail_line"><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			}
        }
        if (pwxdata.TLIST[json_index].TASK_TYPE_IND == 3) {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,' (', pwxdata.TLIST[json_index].ORDER_CNT, '):</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ACCESSION_NUM,':</dt><dd>', pwxdata.TLIST[json_index].ASC_NUM, '</dd></dl>');
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.STATUS,':</dt><dd>', pwxdata.TLIST[json_index].DISPLAY_STATUS, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].TASK_TYPE, '</dd></dl>');
			if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
				var visitUTCDate = new Date();
				visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			}
            for (var y = 0; y < pwxdata.TLIST[json_index].OLIST.length; y++) {
                task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title"><span class="pwx_semi_bold">',amb_i18n.ORDER,' ', (y + 1), ':</span>&nbsp;', pwxdata.TLIST[json_index].OLIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
                if (pwxdata.TLIST[json_index].POWERPLAN_IND == 1) {
                    task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_PLAN,':</dt><dd>', pwxdata.TLIST[json_index].POWERPLAN_NAME, '</dd></dl>');
                }
				if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
					var orderUTCDate = new Date();
					orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
					task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
				} else {
					task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
				}
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDERING_PROV, '</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDER_ID, '</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].OLIST[y].DLIST.length, '):</dt>');
                if (pwxdata.TLIST[json_index].OLIST[y].DLIST.length > 0) {
                    task_detailText.push('</dl>');
                    task_detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text pwx_hvr_order_info_diag_pad">');
                    for (var cc = 0; cc < pwxdata.TLIST[json_index].OLIST[y].DLIST.length; cc++) {
                        if (cc > 0) {
                            task_detailText.push('<br />');
                        }
                        if (pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE != '') {
                            task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE, ')</span>');
                        }
                        else {
                            task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG);
                        }
                    }
                    task_detailText.push('</dd></dl>');
                }
                else {
                    task_detailText.push('<dd>--</dd></dl>');
                }
            }
        }
        else {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK,':</dt><dd>', pwxdata.TLIST[json_index].TASK_DESCRIB, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,':</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
			var formLink = "";
			if (pwxdata.TLIST[json_index].DFAC_ACTIVITY_ID > 0) {
				formLink = '&nbsp;&nbsp;<a class="pwx_blue_link" onClick="pwx_form_launch(' +  pwxdata.TLIST[json_index].PERSON_ID + ',' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ',0.0,' + pwxdata.TLIST[json_index].DFAC_ACTIVITY_ID + ',1)">' + amb_i18n.OPEN_CHARTED_FORM + '</a>';
			}
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.STATUS,':</dt><dd>', pwxdata.TLIST[json_index].DISPLAY_STATUS, formLink,'</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].TASK_TYPE, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_COMMS,':</dt><dd>', pwxdata.TLIST[json_index].TASK_NOTE, '</dd></dl>');
			if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
				var visitUTCDate = new Date();
				visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.ORDER_INFO,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
            if (pwxdata.TLIST[json_index].POWERPLAN_IND == 1) {
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_PLAN,':</dt><dd>', pwxdata.TLIST[json_index].POWERPLAN_NAME, '</dd></dl>');
            }

			if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
				var orderUTCDate = new Date();
				orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].ORDERING_PROVIDER, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].ORDER_ID, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_DETAILS,':</dt><dd>', pwxdata.TLIST[json_index].ORDER_CDL, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_COMMS,':</dt><dd>', pwxdata.TLIST[json_index].ORD_COMMENT, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].DLIST.length, '):</dt>');
            if (pwxdata.TLIST[json_index].DLIST.length > 0) {
                task_detailText.push('</dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_diag_pad"><dd class="pwx_normal_line_height pwx_extra_small_text">');
                for (var cc = 0; cc < pwxdata.TLIST[json_index].DLIST.length; cc++) {
                    if (pwxdata.TLIST[json_index].DLIST[cc].CODE != '') {
                        task_detailText.push(pwxdata.TLIST[json_index].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].DLIST[cc].CODE, ')</span><br />');
                    }
                    else {
                        task_detailText.push(pwxdata.TLIST[json_index].DLIST[cc].DIAG, '<br />');
                    }
                }
                task_detailText.push('</dd></dl>');
            }
            else {
                task_detailText.push('<dd>--</dd></dl>');
            }
        }
        MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
        var taskDetailModal = new ModalDialog("TaskDetailModal")
             .setHeaderTitle(amb_i18n.TASK_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(30)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(30)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
        taskDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
             });
        var closebtn = new ModalButton("addCancel");
        closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
        taskDetailModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(taskDetailModal);
        MP_ModalDialog.showModalDialog("TaskDetailModal")
    });

    //ABN launch link
    framecontentElem.on('click', 'dt.pwx_fcr_content_task_abn_dt', function () {
        // show dialog
        var abnProgramName = '';
        var trackId = $(this).children('.pwx_abn_track_id_hidden').text()
        var jsonId = $(this).children('.pwx_abn_json_id_hidden').text()
        var abnHTML = '<p class="pwx_small_text hvr_table"><span style="vertical-align:30%;">' + amb_i18n.ABN_TEMPLATE + ': </span><select id="abn_programs" name="abn_programs" multiple="multiple">'
        for (var cc = 0; cc < pwxdata.ABN_FORM_LIST.length; cc++) {
            abnHTML += '<option value="' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_NAME + '">' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_DESC + '</option>';
        }
        abnHTML += '</select></br></br>';
        abnHTML += '<table width="95%" ><tr><th>' + amb_i18n.ORDER + '</th><th>' + amb_i18n.ALERT_DATE + '</th><th>' + amb_i18n.ALERT_STATE + '</th></tr>';
        for (var cc = 0; cc < pwxdata.TLIST[jsonId].ABN_LIST.length; cc++) {
            abnHTML += '<tr><td class="abn_order_mne">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ORDER_DISP + '</td><td class="abn_alert_date">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_DATE +
            '</td><td class="abn_alert_state">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_STATE + '</td></tr>';
        }
        abnHTML += '</table></p>';
        //build the drop down
        MP_ModalDialog.deleteModalDialogObject("ABNModal")
        var abnModal = new ModalDialog("ABNModal")
                                .setHeaderTitle(amb_i18n.ABN)
                                .setTopMarginPercentage(15)
                                .setRightMarginPercentage(25)
                                .setBottomMarginPercentage(15)
                                .setLeftMarginPercentage(25)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
        abnModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + abnHTML + '</div>');
                            });
        var printbtn = new ModalButton("PrintABN");
        printbtn.setText(amb_i18n.VIEW).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
            var ccllinkparams = '^MINE^,^' + trackId + '^,^' + abnProgramName + '^';
            window.location = "javascript:CCLLINK('amb_cust_abn_print_wrapper','" + ccllinkparams + "',0)";
        });
        var closebtn = new ModalButton("abnCancel");
        closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
        abnModal.addFooterButton(printbtn)
        abnModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(abnModal);
        MP_ModalDialog.showModalDialog("ABNModal")
        $("#abn_programs").multiselect({
            //height: loc_height,
            header: false,
            multiple: false,
            //minWidth: "250",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.ABN_SELECT,
            selectedList: 1
        });
        $("#abn_programs").on("multiselectclick", function (event, ui) {
            abnProgramName = ui.value
            abnModal.setFooterButtonDither("PrintABN", false);
        })
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
    })
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
    $('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	var contentrowsH = filterbarH + 19;
	$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
	window.scrollTo(0,0);
    //timers!!
    var end_event_timer = new Date();
    var end_page_load_timer = new Date();
    var event_timer = (end_event_timer - start_event_timer) / 1000
    var content_timer = (end_content_timer - start_content_timer) / 1000
    var program_timer = (end_page_load_timer - start_page_load_timer) / 1000
    stop_pwx_timer()
    //$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text"><dt>CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</dt></dl>')
}

function PWX_CCL_Request_User_Pref(program, param1, param2, param3, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };
    var sendArr = ["^MINE^", param1 + ".0", "^" + param2 + "^", "^" + param3 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

//function to call a ccl script to remove prsnl_reltns or encounter_reltns
function PWX_CCL_Request_Task_Unchart(program, param1, param2, param3, param4, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#36A7DA').css('height', dlHeight).attr("title", amb_i18n.UNCHART_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^", param2 + ".0", "^" + param3 + "^", "^" + param4 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Task_Add_Task_Note(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#FFE366').css('height', dlHeight).attr("title", amb_i18n.TASK_COMM_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", param1 , "^" + param2 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Task_Reschedule(program, param1, param2, param3, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#FF8C18').css('height', dlHeight).attr("title", amb_i18n.RESCHEDULE_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^", "^" + param2 + "^", "^" + param3 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Specimen_Login(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "L") {
                var error_text = amb_i18n.SPEC_LOGIN_ERROR;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else if (recordData.STATUS_DATA.STATUS == "F") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function PWX_CCL_Request_Person_Details(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.PATIENT_INFO;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                pwx_open_person_details(recordData)
            }
        }
    };
    var sendArr = ["^MINE^", param1 + ".0", param2 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

/*START OF REFERENCE LAB PAGE*/
function pwx_sort_by_order_date(a, b) {
    if (a.ORDER_DT_TM_NUM < b.ORDER_DT_TM_NUM)
        return -1
    if (a.ORDER_DT_TM_NUM > b.ORDER_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_trans_date(a, b) {
    if (a.TRANSFER_DT_TM_NUM < b.TRANSFER_DT_TM_NUM)
        return -1
    if (a.TRANSFER_DT_TM_NUM > b.TRANSFER_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}

function pwx_sort_by_labname(a, b) {
    var nameA = a.ORDERED_AS_NAME.toLowerCase(), nameB = b.ORDERED_AS_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_subtype(a, b) {
    var nameA = a.ACTIVITY_SUB_TYPE.toLowerCase(), nameB = b.ACTIVITY_SUB_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_tolocation(a, b) {
    var nameA = a.TRANSFER_TO_LOC.toLowerCase(), nameB = b.TRANSFER_TO_LOC.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pwx_trans_reflab_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_trans_header_id) {
        if (pwx_reflab_trans_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_trans_header_id = clicked_header_id
        pwx_reflab_trans_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_trans_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_date)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_tolocation_dt':
                pwxObj.TLIST.sort(pwx_sort_by_tolocation)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_transdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_trans_date)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}
function pwx_reflab_col_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_coll_header_id) {
        if (pwx_reflab_coll_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_coll_header_id = clicked_header_id
        pwx_reflab_coll_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_date)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_subtype_dt':
                pwxObj.TLIST.sort(pwx_sort_by_subtype)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_orderprov_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_by)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}


function pwx_reflab_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_header_id) {
        if (pwx_reflab_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_header_id = clicked_header_id
        pwx_reflab_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_date)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_subtype_dt':
                pwxObj.TLIST.sort(pwx_sort_by_subtype)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}
function refLabSubTab(pwxObj, from, clicked_id) {
    switch (clicked_id) {
        case 'pwx_inoffice_lab_tab':
            if (pwx_reflab_type_view != 1) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 1
                RenderRefLabList(pwxObj, from)
            }
            break;
        case 'pwx_outoffice_lab_tab':
            if (pwx_reflab_type_view != 2) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 2
                RenderRefLabList(pwxObj, from)
            }
            break;
        case 'pwx_transferred_lab_tab':
            if (pwx_reflab_type_view != 3) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 3
                RenderRefLabList(pwxObj, from)
            }
            break;
    }
}

pwx_get_reflab_selected = function (class_name) {
    var selectedElems = new Array(9);
    selectedElems[0] = new Array()
    selectedElems[1] = new Array()
    selectedElems[2] = new Array()
    selectedElems[3] = new Array()
    selectedElems[4] = new Array()
    selectedElems[5] = new Array()
    selectedElems[6] = new Array()
    selectedElems[7] = new Array()
    selectedElems[8] = new Array()
    $(class_name).each(function (index) {
        selectedElems[0].length = index + 1
        selectedElems[1].length = index + 1
        selectedElems[2].length = index + 1
        selectedElems[3].length = index + 1
        selectedElems[4].length = index + 1
        selectedElems[5].length = index + 1
        selectedElems[6].length = index + 1
        selectedElems[7].length = index + 1
        selectedElems[8].length = index + 1
        selectedElems[0][index] = $(this).children('span.pwx_task_id_hidden').text() + ".0";
        selectedElems[1][index] = $(this).children('dt.pwx_reflab_type_hidden').text()
        selectedElems[2][index] = $(this).children('dt.pwx_reflab_recieved_hidden').text()
        selectedElems[3][index] = $(this).children('dt.pwx_task_canchart_hidden').text()
        selectedElems[4][index] = $(this).children('dt.pwx_encounter_id_hidden').text() + ".0";
        selectedElems[5][index] = $(this)
        selectedElems[6][index] = $(this).children('dt.pwx_task_order_id_hidden').text() + ".0";
        selectedElems[7][index] = $(this).children('dt.pwx_reflab_trans_ind').text()
        selectedElems[8][index] = $(this).children('dt.pwx_person_id_hidden').text() + ".0";
    });
    return selectedElems;
}

pwx_get_selected_reflab_resched_time_limit = function (class_name) {
    var resched_detailsArr = new Array(2);
    resched_detailsArr[0] = $(class_name).children('dt.pwx_task_resched_time_hidden').text();
    resched_detailsArr[1] = $(class_name).children('dt.pwx_fcr_reflab_taskdate_hidden').text();
    return resched_detailsArr;
}

pwx_get_selected_reflab_unchart_data = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var unchartTaskArr = new Array();
    $(class_name).children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
        var ar_cnt = unchartTaskArr.length
        unchartTaskArr.length = ar_cnt + 1
        unchartTaskArr[ar_cnt] = new Array(2);
        unchartTaskArr[ar_cnt][0] = $(this).children('span.pwx_task_lab_line_text_hidden').text();
        unchartTaskArr[ar_cnt][1] = $(this).children('span.pwx_task_lab_taskid_hidden').text() + ".0";
    });
    return unchartTaskArr;
}

pwx_reflab_selectall_check = function () {
    var transButtonOn = 1;
    if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
        $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
            if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                transButtonOn = 0;
            }
        });
    }
    else {
        transButtonOn = 0;
    }
    if (transButtonOn == 1) {
        //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
    }
    else {
        //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
    }
}

pwx_reflab_collection_filter_change = function (pwxObj) {
	$('#context-menu-layer').trigger('mousedown'); //close all menus
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    RenderRefLabListContent(pwxObj);
    var transButtonOn = 1;
    if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
        $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
            if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                transButtonOn = 0;
            }
        });
    }
    else {
        transButtonOn = 0;
    }
    if (transButtonOn == 1) {
        //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
    }
    else {
        //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
    }
}

var pwx_reflab_type_view = 1; //1 pending collection //2 ready to transfer //3 is transferred
var pwx_reflab_collection_type_view = '2';
var pwx_reflab_header_id = "pwx_fcr_header_orderdate_dt";
var pwx_reflab_sort_ind = "0";
var pwx_reflab_trans_header_id = "pwx_fcr_trans_header_transdate_dt";
var pwx_reflab_trans_sort_ind = "1";
var pwx_reflab_coll_header_id = "pwx_fcr_header_orderdate_dt";
var pwx_reflab_coll_sort_ind = "0";
var pwx_reflab_get_type = "0";
var pwx_reflab_get_type_str = "All";
var pwx_reflab_global_date = "0";
var json_reflab_end_number = 0;
var json_reflab_start_number = 0;
var json_reflab_page_start_numbersAr = [];
var reflab_list_curpage = 1;
var pwx_reflab_submenu_clicked_task_id = "0";
var pwx_reflab_submenu_clicked_order_id = "0";
var pwx_reflab_submenu_clicked_person_id = "0";
var pwx_reflab_submenu_clicked_row_elem;
var pwx_reflab_to_location_filterArr = [];
var pwx_reflab_to_location_filterApplied = 0;
var pwx_reflab_result_filter = "All"

function RenderPWxRefLabFrame() {
    json_reflab_end_number = 0;
    json_reflab_start_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    var js_criterion = JSON.parse(m_criterionJSON);
    PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_MULTI_TASK_TAB_PREF", "REFLABS", true)
    //empty the div's
    $('#pwx_frame_head').empty();
    $('#pwx_frame_content').empty();
    $('#pwx_frame_filter_content').empty();
    $.contextMenu('destroy');
    pwx_task_load_counter = 0
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
    }
    //display frame header
    var headelement = document.getElementById('pwx_frame_head');
    var pwxheadHTML = [];
    pwxheadHTML.push('<div id="pwx_frame_toolbar"><dt class="pwx_list_view_radio">');
    if (js_criterion.CRITERION.PWX_TASK_LIST_DISP == 1) {
        pwxheadHTML.push('<div class="pwx_tasklist-seg-cntrl" onclick="RenderPWxFrame()"><div id="tasklistLeft"></div><div id="tasklistCenter">',amb_i18n.ORDER_TASKS,'</div><div id="tasklistRight"></div></div>')
    }
    pwxheadHTML.push('<div class="pwx_reflab-seg-cntrl  tab-layout-active"><div id="refLabLeft"></div><div id="refLabCenter">',amb_i18n.REF_LAB,'</div><div id="refLabRight"></div></div>');
    pwxheadHTML.push('<dt id="pwx_reflab_progressbar_dt_label"></dt><dt id="pwx_reflab_progressbar_dt"></dt>')
    if (js_criterion.CRITERION.PWX_REFLAB_HELP_LINK != "") {
        pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: APPLINK(100,"', js_criterion.CRITERION.PWX_REFLAB_HELP_LINK, '","")\' class="pwx_no_text_decor" title="',amb_i18n.HELP_PAGE,'" onClick="">',
        '<span class="pwx-help-icon">&nbsp;</span></a></dt>');
    }
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.DESELECT_ALL,'" onClick="pwx_deselect_all(\'pwx_row_selected\');pwx_reflab_selectall_check()"> <span class="pwx-deselect_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.SELECT_ALL,'" onClick="pwx_select_all(\'pwx_row_selected\');pwx_reflab_selectall_check()"><span class="pwx-select_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt id="pwx_location_list">');
    if (js_criterion.CRITERION.LOC_LIST.length > 0) {
        pwxheadHTML.push('<span class="pwx_location_list_lbl">',amb_i18n.LOCATION,': </span>');
		pwxheadHTML.push('<select id="ref_location" name="ref_location" style="width:300px;" data-placeholder="Choose a Location..." class="chzn-select"><option value=""></option>');
        var loc_height = 30;
        for (var i = 0; i < js_criterion.CRITERION.LOC_LIST.length; i++) {
            loc_height += 26;
            if (pwx_current_set_location == js_criterion.CRITERION.LOC_LIST[i].ORG_ID) {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '" selected="selected">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
            else {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
        }
        if (loc_height > 300) { loc_height = 300; }
        pwxheadHTML.push('</select>');
    }
    else {
        pwxheadHTML.push(amb_i18n.NO_RELATED_LOC);
    }
    headelement.innerHTML = pwxheadHTML.join("");
	$('#ref_location').chosen({
		no_results_text : "No results matched"
	});
	$("#ref_location").on("change", function (event) {
        pwx_current_set_location = $("#ref_location").val();
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_LOCS", pwx_current_set_location, true);
    });
    //build filter here just do date at first
    var filterelement = document.getElementById('pwx_frame_filter_content');
    var pwxfilterbarHTML = [];
    pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar"><div id="pwx_frame_filter_bar_container"><dl>');
    pwxfilterbarHTML.push('<dt id="pwx_reflab_subtabs_filter"></dt>')
    pwxfilterbarHTML.push('<dt id="pwx_date_picker" class="pwx_reflab_filter_bar_toppad"><label for="from"><span style="vertical-align:20%;">',amb_i18n.ORDER_DATE,': </span><input type="text" id="from" name="from" class="pwx_date_box" /></label></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_reflab_transfer_btn_dt"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_info_icon"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_list_refresh_icon"></dt>');
    pwxfilterbarHTML.push('</dl><div id="pwx_frame_advanced_filters_container" style="display:none;"></div></div>');
    pwxfilterbarHTML.push('<div id="pwx_frame_paging_bar_container" style="display:none;"><dt id="pwx_task_filterbar_page_prev" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_filterbar_page_next" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_pagingbar_cur_page" class="pwx_grey"></dt><dt id="pwx_task_pagingbar_load_text"></dt><dt id="pwx_task_pagingbar_load_count" class="pwx_grey"></dt></div>');
    pwxfilterbarHTML.push('<dl><dt id="pwx_frame_filter_bar_bottom_pad"></dt><dl></div>');
    filterelement.innerHTML = pwxfilterbarHTML.join("");
    //function to handle a date range entry
    function RenderDateRangeTaskList(selectedDate, dateId, locId) {
        if (dateId == 'from') {
            current_from_date = selectedDate;
            pwx_reflab_global_date = selectedDate;
        }
        else if (dateId == 'pwx_location') {
            current_location_id = locId;
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
        }
        if (current_from_date != '' && current_location_id > 0) {
            //both dates and location found load list
            $('#pwx_frame_content').empty();
            $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            pwx_current_set_location = current_location_id;
            pwx_reflab_global_date = current_from_date;
            start_pwx_timer()
            var start_ccl_timer = new Date();
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + current_from_date + "^", current_location_id + ".0"];
            PWX_CCL_Request("amb_cust_mp_reflab_by_loc_dt", sendArr, true, function () {
                current_from_date = "";
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                start_page_load_timer = new Date();

                pwx_reflab_header_id = 'pwx_fcr_header_orderdate_dt'
                pwx_reflab_sort_ind = '0'
                pwx_reflab_trans_header_id = 'pwx_fcr_trans_header_transdate_dt'
                pwx_reflab_trans_sort_ind = '1'
                pwx_reflab_coll_header_id = "pwx_fcr_header_orderdate_dt";
                pwx_reflab_coll_sort_ind = "0";
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                //check counts and default tab based on counts
                if (this.INCNT == 0 && this.OUTCNT != 0) {
                    pwx_reflab_type_view = 2
                    if (this.READY_OUT_CNT == 0 && this.READY_IN_CNT != 0) {
                        pwx_reflab_collection_type_view = 1
                    }
                }
                else if (this.INCNT == 0 && this.OUTCNT == 0 && this.TRANSCNT != 0) {
                    pwx_reflab_type_view = 3
                    if (this.TRANS_OUT_CNT == 0 && this.TRANS_IN_CNT != 0) {
                        pwx_reflab_collection_type_view = 1
                    }
                }
                RenderRefLabList(this, pwx_reflab_global_date);
            });
        }
    }
    //set the date range datepickers
    $("#from").datepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        onSelect: function (selectedDate) {
            RenderDateRangeTaskList(selectedDate, this.id);
            $.datepicker._hideDatepicker();
        }
    });
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        if (pwx_reflab_global_date == "0") {
            var fromdate = Date.today().toString("MM/dd/yyyy");
            $('#from').datepicker("setDate", fromdate)
        }
        else {
            var fromdate = pwx_reflab_global_date;
            $('#from').datepicker("setDate", fromdate)
        }
        RenderDateRangeTaskList(fromdate, "from");
    }
}

function RenderRefLabList(pwxdata, from) {
    var start_filterbar_timer = new Date();
    json_task_start_number = 0;
    json_task_end_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    $(window).off('resize')
	var framecontentElem =  $('#pwx_frame_content')
    framecontentElem.off()
    $('#pwx_frame_filter_content').off()
    var js_criterion = JSON.parse(m_criterionJSON);
    //build the filter bar
    var pwxfilterbarHTML = [];
    if (pwx_reflab_type_view == 1) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_inoffice_lab_tab"><div id="inOfficeLeft"></div><div id="inOfficeCenter">', pwxdata.INOFFICE_LBL, ' (', pwxdata.INCNT, ')</div><div id="inOfficeRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_inoffice_lab_tab"><div id="inOfficeLeft"></div><div id="inOfficeCenter">', pwxdata.INOFFICE_LBL, ' (', pwxdata.INCNT, ')</div><div id="inOfficeRight"></div></div>')
    }
    if (pwx_reflab_type_view == 2) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_outoffice_lab_tab"><div id="outOfficeLeft"></div><div id="outOfficeCenter">', pwxdata.OUTOFFICE_LBL, ' (', pwxdata.OUTCNT, ')</div><div id="outOfficeRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_outoffice_lab_tab"><div id="outOfficeLeft"></div><div id="outOfficeCenter">', pwxdata.OUTOFFICE_LBL, ' (', pwxdata.OUTCNT, ')</div><div id="outOfficeRight"></div></div>')
    }
    if (pwx_reflab_type_view == 3) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_transferred_lab_tab"><div id="transferredLeft"></div><div id="transferredCenter">', pwxdata.TRANSORDERS_LBL, ' (', pwxdata.TRANSCNT, ')</div><div id="transferredRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_transferred_lab_tab"><div id="transferredLeft" ></div><div id="transferredCenter">', pwxdata.TRANSORDERS_LBL, ' (', pwxdata.TRANSCNT, ')</div><div id="transferredRight"></div></div>')
    }
    $('#pwx_reflab_subtabs_filter').html(pwxfilterbarHTML.join(""));
    $('#pwx_task_list_refresh_icon').html('<span class="pwx-refresh-icon" title="' + amb_i18n.REFRESH_LIST + '"></span>')
    pwxfilterbarHTML = []
    if (pwx_reflab_type_view == 2) {
        $('dt.pwx_reflab_transfer_btn_dt').html('<div class="pwx_blue_button-cntrl_inactive" id="pwx_transfer_btn_cntrl"><div class="pwx_blue_buttonLeft"></div><div class="pwx_blue_buttonCenter">' + amb_i18n.TRANSMIT + '</div><div class="pwx_blue_buttonRight"></div></div>').css('display', 'inline-block');
        pwxfilterbarHTML.push('<dt id="pwx_reflab_collection_filter" >')
        if (pwx_reflab_collection_type_view == 2) {
            pwxfilterbarHTML.push('<label for="pwx_tab2_col_radio_val2" ><input id="pwx_tab2_col_radio_val2" name="reflab_collection_radio" type="radio" checked="checked" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.READY_OUT_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('<label for="pwx_tab2_col_radio_val2" ><input id="pwx_tab2_col_radio_val2" name="reflab_collection_radio" type="radio" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.READY_OUT_CNT, ')</span></input></label>')
        }
        if (pwx_reflab_collection_type_view == 1) {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab2_col_radio_val1" ><input id="pwx_tab2_col_radio_val1" name="reflab_collection_radio" type="radio" checked="checked" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.READY_IN_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab2_col_radio_val1" ><input id="pwx_tab2_col_radio_val1" name="reflab_collection_radio" type="radio" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.READY_IN_CNT, ')</span></input></label>')
        }
        pwxfilterbarHTML.push('</dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_tolocation_filter" ></dt>')
        $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
    } else if (pwx_reflab_type_view == 3) {
        $('dt.pwx_reflab_transfer_btn_dt').html('').css('display', 'none')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_collection_filter" >')
        if (pwx_reflab_collection_type_view == 2) {
            pwxfilterbarHTML.push('<label for="pwx_tab3_col_radio_val2" ><input id="pwx_tab3_col_radio_val2" name="reflab_collection_radio" type="radio" checked="checked" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.TRANS_OUT_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('<label for="pwx_tab3_col_radio_val2" ><input id="pwx_tab3_col_radio_val2" name="reflab_collection_radio" type="radio" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.TRANS_OUT_CNT, ')</span></input></label>')
        }
        if (pwx_reflab_collection_type_view == 1) {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab3_col_radio_val1" ><input id="pwx_tab3_col_radio_val1" name="reflab_collection_radio" type="radio" checked="checked" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.TRANS_IN_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab3_col_radio_val1" ><input id="pwx_tab3_col_radio_val1" name="reflab_collection_radio" type="radio" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,'(', pwxdata.TRANS_IN_CNT, ')</span></input></label>')
        }
        pwxfilterbarHTML.push('</dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_tolocation_filter" ></dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_result_filter" ><span style="vertical-align:30%;">',amb_i18n.RESULT_STATUS,': </span><select id="reflab_results" name="reflab_results" multiple="multiple" width="150">')
        if (pwx_reflab_result_filter == "All") {
            pwxfilterbarHTML.push('<option selected="selected" value="All">',amb_i18n.ALL,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="All">',amb_i18n.ALL,'</option>')
        }
        if (pwx_reflab_result_filter == "Pending") {
            pwxfilterbarHTML.push('<option selected="selected" value="Pending">',amb_i18n.PENDING_RESULTS,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="Pending">',amb_i18n.PENDING_RESULTS,'</option>')
        }
        if (pwx_reflab_result_filter == "Results") {
            pwxfilterbarHTML.push('<option selected="selected" value="Results">',amb_i18n.RESULTS_REC,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="Results">',amb_i18n.RESULTS_REC,'</option>')
        }
        pwxfilterbarHTML.push('</select></dt>')
        $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
    }
    else {
        $('dt.pwx_reflab_transfer_btn_dt').html('').css('display', 'none')
        $('#pwx_frame_advanced_filters_container').css('display', 'none')
    }
    $('#pwx_frame_advanced_filters_container').html(pwxfilterbarHTML.join(""))
    if (pwx_reflab_type_view == 3) {
        var progBarValue = Math.round((pwxdata.RESULT_CNT / pwxdata.TRANSCNT) * 100);
        if (isNaN(progBarValue) == true) {
            progBarValue = 0
        }
        $('#pwx_reflab_progressbar_dt_label').html('<span class="pwx_grey">' + amb_i18n.RESULTS_REC + ' (' + progBarValue + '%):</span>')
        $('#pwx_reflab_progressbar_dt').attr('title', pwxdata.RESULT_CNT + ' ' + amb_i18n.OF + ' ' + pwxdata.TRANSCNT + ' ' + amb_i18n.RESULTS_REC).html('<div id="pwx_reflab_progressbar"></div>')
    }
    else {
        var progBarValue = Math.round((pwxdata.TRANSCNT / (pwxdata.INCNT + pwxdata.OUTCNT + pwxdata.TRANSCNT)) * 100)
        if (isNaN(progBarValue) == true) {
            progBarValue = 0
        }
        $('#pwx_reflab_progressbar_dt_label').html('<span class="pwx_grey">' + amb_i18n.TRANSMITTED + ' (' + progBarValue + '%):</span>')
        $('#pwx_reflab_progressbar_dt').attr('title', pwxdata.TRANSCNT + ' ' + amb_i18n.OF + ' ' + (pwxdata.INCNT + pwxdata.OUTCNT + pwxdata.TRANSCNT) + ' ' + amb_i18n.TRANSFERRED).html('<div id="pwx_reflab_progressbar"></div>')
    }
    $('#pwx_reflab_progressbar').progressbar({
        value: progBarValue
    });
    $('.pwx_lab_subtab-seg-cntrl').on('click', function () {
        var tabId = $(this).attr('id')
        refLabSubTab(pwxdata, from, tabId);
    })

    if (pwxdata.TASK_INFO_TEXT != "") {
        $('#pwx_task_info_icon').html('<a class="pwx_no_text_decor" title="' + amb_i18n.REF_LAB_INFO + '"> <span class="pwx-information-icon">&nbsp;</span></a>');

        $('#pwx_task_info_icon a').on('click', function () {
            MP_ModalDialog.deleteModalDialogObject("TaskInfoModal")
            var taskInfoModal = new ModalDialog("TaskInfoModal")
             .setHeaderTitle(amb_i18n.REF_LAB_INFO)
             .setShowCloseIcon(true)
             .setTopMarginPercentage(20)
             .setRightMarginPercentage(35)
             .setBottomMarginPercentage(35)
             .setLeftMarginPercentage(35)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(false);
            taskInfoModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + pwxdata.TASK_INFO_TEXT + '</div>');
             });
            MP_ModalDialog.addModalDialogObject(taskInfoModal);
            MP_ModalDialog.showModalDialog("TaskInfoModal")
        });
    }
    else {
        $('#pwx_task_info_icon').remove()
    }

    $('#pwx_task_list_refresh_icon').on('click', function () {
        var js_criterion = JSON.parse(m_criterionJSON);
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        var start_ccl_timer = new Date();
        var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + pwx_reflab_global_date + "^", pwx_current_set_location + ".0"];
        PWX_CCL_Request("amb_cust_mp_reflab_by_loc_dt", sendArr, true, function () {
            var end_ccl_timer = new Date();
            ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
            start_page_load_timer = new Date();
            RenderRefLabList(this, from);
        });
    });
	
    if (pwx_reflab_type_view == 2) {
        $('#pwx_frame_filter_content').on('click', '.pwx_blue_button-cntrl#pwx_transfer_btn_cntrl ', function () {
            var js_criterion = JSON.parse(m_criterionJSON);
            var transferblob = { "TRANSFERS": { "TLIST": {}} };
            //var containidArr = [{ "CONTAINER_ID": 0 }, { "CONTAINER_ID": 1}]
            var containidArr = new Array();
            $('dl.pwx_row_selected').children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
                var to_location = $(this).parents('dt.pwx_fcr_content_labname_dt').siblings('dt.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').text()
                containidArr.push({ "CONTAINER_ID": parseFloat($(this).children('span.pwx_task_lab_containid_hidden').text()), "TO_LOCATION": parseFloat(to_location) })
            });
            transferblob.TRANSFERS.TLIST = containidArr
            //alert(JSON.stringify(transferblob))
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0"];
            MP_DCP_REFLAB_TRANSFER_Request("AMB_CUST_MP_REFLAB_TRANSFER", transferblob, sendArr, true);
        });
    }
    $("#reflab_results").multiselect({
        height: "80",
        header: false,
        multiple: false,
        minWidth: "150",
        classes: "pwx_select_box",
        selectedList: 1
    });
    $(window).on('resize', function () {
        //make sure fixed position for filter bar correct
        var toolbarH = $('#pwx_frame_toolbar').height() + 6;
        $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
        var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
		$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
		var contentrowsH = filterbarH + 19;
		$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_col_orderprov_dt, dt.pwx_fcr_trans_content_tolocation_dt').each(function (index) {
            if (this.clientWidth < this.scrollWidth) {
                var titleText = $(this).text()
                $(this).attr("title", titleText)
            }
        });
        $(".pwx_to_location_class").css("width", "")
        $(".pwx_to_location_class").multiselect('refresh')
        var selectWidth = $(".pwx_fcr_content_action_move_dt").width()
        $(".pwx_to_location_class").css("width", selectWidth - 10)
        $(".pwx_to_location_class").multiselect('refresh')
    });
    //tab specifc workings
    if (pwx_reflab_type_view == 3) {
        switch (pwx_reflab_trans_header_id) {
            case 'pwx_fcr_trans_header_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_trans_header_tolocation_dt':
                pwxdata.TLIST.sort(pwx_sort_by_tolocation)
                break;
            case 'pwx_fcr_trans_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_date)
                break;
            case 'pwx_fcr_trans_header_transdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_trans_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }
        if (pwx_reflab_trans_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }
    else if (pwx_reflab_type_view == 2) {
        switch (pwx_reflab_header_id) {
            case 'pwx_fcr_header_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_header_subtype_dt':
                pwxdata.TLIST.sort(pwx_sort_by_suptype)
                break;
            case 'pwx_fcr_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }

        if (pwx_reflab_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }
    else if (pwx_reflab_type_view == 1) {
        switch (pwx_reflab_coll_header_id) {
            case 'pwx_fcr_header_col_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_header_col_subtype_dt':
                pwxdata.TLIST.sort(pwx_sort_by_suptype)
                break;
            case 'pwx_fcr_header_col_orderprov_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_by)
                break;
            case 'pwx_fcr_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_task_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }

        if (pwx_reflab_coll_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }

    var end_filterbar_timer = new Date();
    filterbar_timer = (end_filterbar_timer - start_filterbar_timer) / 1000

    RenderRefLabListContent(pwxdata);

    var start_delegate_event_timer = new Date();
    //build the row events
    framecontentElem.on('mousedown', 'dl.pwx_content_row', function (e) {
        if (e.which == '3') {
            $(this).removeClass('pwx_row_selected').addClass('pwx_row_selected');
			var persId = $(this).children('dt.pwx_person_id_hidden').text();
			var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
			var persName = $(this).children('dt.pwx_person_name_hidden').text();
			pwx_set_patient_focus(persId, encntrId, persName);
        }
        else {
            //$(this).toggleClass('pwx_row_selected');
			if($(this).hasClass('pwx_row_selected') === true) {
				$(this).removeClass('pwx_row_selected');
				pwx_clear_patient_focus();
			} else {
				$(this).addClass('pwx_row_selected');
				var persId = $(this).children('dt.pwx_person_id_hidden').text();
				var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
				var persName = $(this).children('dt.pwx_person_name_hidden').text();
				pwx_set_patient_focus(persId, encntrId, persName);
			}
        }
        if (pwx_reflab_type_view == 2) {
            var transButtonOn = 1;
            if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
                $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
                    if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                        transButtonOn = 0;
                    }
                });
            }
            else {
                transButtonOn = 0;
            }
            if (transButtonOn == 1) {
                //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
                $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
            }
            else {
                //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
                $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
            }
        }
    });
    $.contextMenu('destroy', 'dl.pwx_content_row');
    $.contextMenu({
        selector: 'dl.pwx_content_row',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).addClass('pwx_row_selected')
            var taskInfo = pwx_get_reflab_selected('dl.pwx_row_selected');
            // alert(taskInfo[0][0] + ',' + taskInfo[1][0] + ',' + taskInfo[2][0] + ',');
            taskIdlist = taskInfo[0].join(',');
            orderIdlist = taskInfo[6].join(',');
            reschedule_TaskIds = taskInfo[0][0]
            var can_not_chart_found = 0;
            var transButtonOn = 1;
            for (var cc = 0; cc < taskInfo[1].length; cc++) {
                if (taskInfo[3][cc] == 0) {
                    can_not_chart_found = 1;
                }
                if (taskInfo[7][cc] == '0') {
                    transButtonOn = 0;
                }
            }
            var uniquePersonArr = []
            uniquePersonArr = $.grep(taskInfo[8], function (v, k) {
                return $.inArray(v, taskInfo[8]) === k;
            });
            var uniqueEncounterArr = []
            uniqueEncounterArr = $.grep(taskInfo[4], function (v, k) {
                return $.inArray(v, taskInfo[4]) === k;
            });
            var ccllinkparams = '^MINE^,^' + js_criterion.CRITERION.PWX_PATIENT_SUMM_PRG + '^,' + uniquePersonArr[0] + '.0,' + uniqueEncounterArr[0] + '.0';
            //Build options dependending on tab.
            if (pwx_reflab_type_view == 1) {
                var options = {
                    items: {
                        "Done": { "name": amb_i18n.DONE, callback: function (key, opt) {
                            var lab_taskAr = new Array()
                            for (var cc = 0; cc < taskInfo[0].length; cc++) {
                                var taskSuccess = pwx_task_launch(taskInfo[8][cc], taskInfo[0][cc], 'CHART');
                                if (taskSuccess == true) {
                                    var dlHeight = $(taskInfo[5][cc]).height()
                                    $(taskInfo[5][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                    $(taskInfo[5][cc]).removeClass('pwx_row_selected')
                                    lab_taskAr.push(taskInfo[0][cc])
                                }
                            }
                            if (lab_taskAr.length > 0) {
                                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                        var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], lab_taskAr.join(','));
                                    }
                                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                    }
                                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                    }
                                    else {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                    }
                                }
                                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", lab_taskAr.join(','), true) }, 1000); }
                            }
                        }
                        },
                        "Not Done": { "name": amb_i18n.NOT_DONE, callback: function (key, opt) {
                            for (var cc = 0; cc < taskInfo[0].length; cc++) {
                                var taskSuccess = pwx_task_launch(taskInfo[8][cc], taskInfo[0][cc], 'CHART_NOT_DONE');
                                if (taskSuccess == true) {
                                    var dlHeight = $(taskInfo[5][cc]).height()
                                    $(taskInfo[5][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                                    $(taskInfo[5][cc]).removeClass('pwx_row_selected')
                                }
                            }
                        }
                        },
                        "Reschedule": { "name": amb_i18n.RESCHEDULE, callback: function (key, opt) {
                            var time_check = pwx_get_selected_reflab_resched_time_limit('dl.pwx_row_selected');
                            var task_dt = Date.parse(time_check[1]);
                            var curDate = new Date()
                            var resched_limit_dt = curDate.addHours(time_check[0]);
                            $('#pwx_resched_dt_tm').val("")
                            $('#pwx-reschedule-btn').button('disable')
                            $("#pwx_resched_dt_tm").datetimepicker('option', 'minDate', new Date());
                            $("#pwx_resched_dt_tm").datetimepicker('option', 'maxDate', resched_limit_dt);
                            $("#pwx-resched-dialog-confirm").dialog('open')
                        }
                        },
                        "sep2": "---------",
                        "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                            if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                            }
                            else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                            }
                            else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                            }
                            else {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                            }
                            $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                        }
                        },
                        "fold2": { "name": amb_i18n.PRINT_REQ,
                            //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "items": {
                                "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                }
                                },
                                "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                }
                                }

                            }
                        },
                        "sep3": "---------",
                        "fold1": {
                            //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "name": amb_i18n.CHART_FORMS,
                            "items": {},
                            disabled: false
                        },
                        "sep4": "---------",
                        "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                        "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                        "sep5": "---------",
                        "fold3": {
                            //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "name": amb_i18n.OPEN_PT_CHART,
                            "items": {},
                            disabled: false
                        }
                    }
                };

                if (uniqueEncounterArr.length > 1) {
                    options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                    options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                    options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                    options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                } else {
                    if (pwxdata.FORMSLIST.length > 0) {
                        for (var cc in pwxdata.FORMSLIST) {
                            options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                        }
                        options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                    }
                    else {
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                    }
                    if (js_criterion.CRITERION.VPREF.length > 0) {
                        for (var cc in js_criterion.CRITERION.VPREF) {
                            options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                            }
                            }
                        }
                    }
                    else {
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    }
                }
                if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                    options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                }

                if (taskInfo[0].length > 1) {
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
                else {
                    //check reschedule
                    var time_check = pwx_get_selected_reflab_resched_time_limit('dl.pwx_row_selected');
                    if (time_check[0] < 1 || taskInfo[2] == 1) {
                        options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                    }
                }
                if (can_not_chart_found == 1) {
                    options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                    options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
            }
            else if (pwx_reflab_type_view == 2) {
                if (pwx_reflab_collection_type_view == '2') {
                    var options = {
                        items: {
                            "Transmit": { "name": amb_i18n.TRANSMIT, callback: function (key, opt) { $('#pwx_transfer_btn_cntrl').trigger('click') } },
                            "sep1": "---------",
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (transButtonOn == 0) {
                        options.items["Transmit"] = { "name": amb_i18n.TRANSMIT, disabled: function (key, opt) { return true; } };
                    }
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }
                else {
                    var options = {
                        items: {
                            "Transmit": { "name": amb_i18n.TRANSMIT, callback: function (key, opt) { $('#pwx_transfer_btn_cntrl').trigger('click') } },
                            "sep1": "---------",
                            "Unchart": { "name": amb_i18n.UNCHART, callback: function (key, opt) {
                                var unchartHTML = '<p class="pwx_small_text">';
                                var unchartArr = pwx_get_selected_reflab_unchart_data('dl.pwx_row_selected');
                                unchartHTML += amb_i18n.SELECT_UNCHART + ':';
                                for (var cc = 0; cc < unchartArr.length; cc++) {
                                    unchartHTML += '<br /><input type="checkbox" checked="checked" name="pwx_unchart_tasks" value="' + unchartArr[cc][1] + '" />' + unchartArr[cc][0];
                                }
                                unchartHTML += '</p>';
                                MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                                var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                                unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + unchartHTML + '</div>');
                            });
                                var unchartbtn = new ModalButton("UnchartTask");
                                unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setOnClickFunction(function () {
                                    var taskidObj = $("input[name='pwx_unchart_tasks']:checked").map(function () { return $(this).val(); });
                                    var taskAr = jQuery.makeArray(taskidObj);
                                    taskIdlist = taskAr.join(',');
                                    if (taskIdlist != "") {
                                        PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, '', '3', false);
                                    }
                                });
                                var closebtn = new ModalButton("unchartCancel");
                                closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                                unChartTaskModal.addFooterButton(unchartbtn)
                                unChartTaskModal.addFooterButton(closebtn)
                                MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                                MP_ModalDialog.showModalDialog("UnchartTaskModal")
                                $('input[name="pwx_unchart_tasks"]').on('change', function (event) {
                                    var any_checked = 0;
                                    $('input[name="pwx_unchart_tasks"]').each(function (index) {
                                        if ($(this).prop("checked") == true) {
                                            any_checked = 1;
                                        }
                                    });
                                    if (any_checked == 0) {
                                        unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                    }
                                    else {
                                        unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                    }
                                });
                            }
                            },
                            "sep2": "---------",
                            "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                            }
                            },

                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (transButtonOn == 0) {
                        options.items["Transmit"] = { "name": amb_i18n.TRANSMIT, disabled: function (key, opt) { return true; } };
                    }
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }

                    if (taskInfo[0].length > 1 || can_not_chart_found == 1) {
                        options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                    }
                }
            }
            else if (pwx_reflab_type_view == 3) {
                if (pwx_reflab_collection_type_view == '2') {
                    var options = {
                        items: {
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }
                else {
                    var options = {
                        items: {
                            "Print Pickup List(s)": { "name": amb_i18n.PRINT_PICKUP, callback: function (key, opt) {
                                var transferlistFull = $('dl.pwx_content_row.pwx_row_selected').find('span.pwx_reflab_hidden_trans_id').map(function () {
                                    return $(this).text() + ".0";
                                })
                                var transferlistFullArr = jQuery.makeArray(transferlistFull);
                                var uniqueListArr = $.distinct(transferlistFullArr);
                                var ccllinkparams = '^MINE^,^' + uniqueListArr.join(",") + '^'
                                window.location = "javascript:CCLLINK('amb_cust_reflab_transfer_list','" + ccllinkparams + "',0)";
                            }
                            },
                            "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                            }
                            },
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": "Chart Forms",
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }

            }
            return options;
        }
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_detail_icon_dt', function (e) {
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var task_detailText = [];
        task_detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[json_index].PERSON_NAME, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[json_index].DOB, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[json_index].AGE, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[json_index].GENDER, '</span>')
        task_detailText.push('</div></br></br>')
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,' (', pwxdata.TLIST[json_index].ORDER_CNT, '):</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ACCESSION_NUM,':</dt><dd>', pwxdata.TLIST[json_index].ASC_NUM, '</dd></dl>');
        if (pwxdata.TLIST[json_index].COLLECTED_IND == 1) {
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
        }
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].ACTIVITY_SUB_TYPE, '</dd></dl>');
		if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
			var visitUTCDate = new Date();
			visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
			task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
		} else {
			task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
		}
        if (pwx_reflab_type_view == 3) {
			if (pwxdata.TLIST[json_index].COLLECTED_IND == 2) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[0]) {
					if(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "TZ") {
						var collectUTCDate = new Date();
						collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC);
						task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.COLLECTED_DATE,':</dt><dd>', collectUTCDate.format("shortDate3"), '</dd></dl>');
					}
				}
			}
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.TRANSMIT_DETAILS,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			if(pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC != "TZ") {
				var transferUTCDate = new Date();
				transferUTCDate.setISO8601(pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMIT_DATE,':</dt><dd>', transferUTCDate.format("longDateTime4"), '</dd></dl>')
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMIT_DATE,':</dt><dd>--</dd></dl>')
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.SYSTEM_TRANS_INFO,':</dt><dd>',amb_i18n.LIST_NUM,' ', pwxdata.TLIST[json_index].TRANSFER_LIST_NUM, ', ',amb_i18n.ID,':', pwxdata.TLIST[json_index].TRANSFER_LIST_ID, '</dd></dl>')
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.LAB,':</dt><dd>', pwxdata.TLIST[json_index].TRANSFER_TO_LOC, '</dd></dl>')
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMITTED_BY,':</dt><dd>', pwxdata.TLIST[json_index].TRANSFERRED_BY, '</dd></dl>')
        }
        else if (pwx_reflab_type_view == 2 && pwxdata.TLIST[json_index].COLLECTED_IND == 1) {
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.COLLECTION_DETAILS,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><th>',amb_i18n.CONTAINER,'</th><th>',amb_i18n.COLLECTED_DATE,'</th><th>',amb_i18n.COLLECTED_BY,'</th></tr>')
            for (var cc = 0; cc < pwxdata.TLIST[json_index].CONTAIN_LIST.length; cc++) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC != "TZ") {
					var collectUTCDate = new Date();
					collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC);
					task_detailText.push('<tr><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].CONTAIN_SENT, '</td><td>', collectUTCDate.format("longDateTime4"), '</td><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_BY, '</td></tr>')
				} else {
					task_detailText.push('<tr><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].CONTAIN_SENT, '</td><td>--</td><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_BY, '</td></tr>')
				}
            }
            task_detailText.push('</table></dl>')
        } else if (pwx_reflab_type_view == 2 && pwxdata.TLIST[json_index].COLLECTED_IND == 2) {
			if(pwxdata.TLIST[json_index].CONTAIN_LIST[0]) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "TZ") {
					var collectUTCDate = new Date();
					collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC);
					task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.COLLECTED_DATE,':</dt><dd>', collectUTCDate.format("shortDate3"), '</dd></dl>');
				}
			}
		}
        for (var y = 0; y < pwxdata.TLIST[json_index].OLIST.length; y++) {
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title"><span class="pwx_semi_bold">',amb_i18n.ORDER,' ', (y + 1), ':</span>&nbsp;', pwxdata.TLIST[json_index].OLIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
			var orderUTCDate = new Date();
			orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
			task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDERING_PROV, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDER_ID, '</dd></dl>');
            if (pwx_reflab_type_view == 3) {
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.RESULTS_REC,':</dt><dd>')
                if (pwxdata.TLIST[json_index].OLIST[y].RESULTS_IND == 1) {
                    task_detailText.push(amb_i18n.YES);
                } else {
                    task_detailText.push(amb_i18n.NO);
                }
                task_detailText.push('</dd></dl>');
            }
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].OLIST[y].DLIST.length, '):</dt>');
            if (pwxdata.TLIST[json_index].OLIST[y].DLIST.length > 0) {
                task_detailText.push('<dd>&nbsp;</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text pwx_hvr_order_info_diag_pad">');
                for (var cc = 0; cc < pwxdata.TLIST[json_index].OLIST[y].DLIST.length; cc++) {
                    if (cc > 0) {
                        task_detailText.push('<br />');
                    }
                    if (pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE != '') {
                        task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE, ')</span>');
                    }
                    else {
                        task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG);
                    }
                }
                task_detailText.push('</dd></dl>');
            }
            else {
                task_detailText.push('<dd>--</dd></dl>');
            }
        }
        MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
        var taskDetailModal = new ModalDialog("TaskDetailModal")
             .setHeaderTitle(amb_i18n.ORDER_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(20)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(20)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
        taskDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail_no_pad">' + task_detailText.join("") + '</div>');
             });
        var closebtn = new ModalButton("addCancel");
        closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
        taskDetailModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(taskDetailModal);
        MP_ModalDialog.showModalDialog("TaskDetailModal")
    });
    var pwxdialogHTML = []
    //create the reschedule modal
    pwxdialogHTML.push('<div id="pwx-resched-dialog-confirm"><p class="pwx_small_text"><label for="pwx_resched_dt_tm"><span style="vertical-align:30%;">',amb_i18n.RESCHEDULED_TO,': </span><input type="text" id="pwx_resched_dt_tm" name="pwx_resched_dt_tm" style="width: 125px; height:14px;" /></label></p></div>');
    $('#pwx_frame_filter_bar').after(pwxdialogHTML.join(""))


    $("#pwx-resched-dialog-confirm").dialog({
        resizable: false,
        height: 200,
        modal: true,
        autoOpen: false,
        title: amb_i18n.RESCHEDULE_TASK,
        buttons: [
            {
                text: amb_i18n.RESCHEDULE,
                id: "pwx-reschedule-btn",
                disabled: true,
                click: function () {
                    var real_date = Date.parse($("#pwx_resched_dt_tm").datetimepicker('getDate'))
                    var string_date = real_date.toString("MM/dd/yyyy HH:mm")
                    var resched_dt_tm = string_date.split(" ");
                    PWX_CCL_Request_Task_Reschedule('amb_cust_srv_task_reschedule', reschedule_TaskIds, resched_dt_tm[0], resched_dt_tm[1], false);
                    $(this).dialog("close");
                }
            },
            {
                text: amb_i18n.CANCEL,
                click: function () {
                    $(this).dialog("close");
                }
            }
        ]
    });
    $("#pwx_resched_dt_tm").datetimepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        ampm: true,
        timeFormat: "hh:mmtt",
        onSelect: function (dateText, inst) {
            if (dateText != "") {
                $('#pwx-reschedule-btn').button('enable')
            }
        }
    });
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_menu', function (event) {
        pwx_reflab_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        pwx_reflab_submenu_clicked_task_id = $(pwx_reflab_submenu_clicked_row_elem).children('span.pwx_task_id_hidden').html()  + ".0";
        pwx_reflab_submenu_clicked_order_id = $(pwx_reflab_submenu_clicked_row_elem).children('dt.pwx_task_order_id_hidden').html()  + ".0";
        pwx_reflab_submenu_clicked_person_id = $(pwx_reflab_submenu_clicked_row_elem).children('dt.pwx_person_id_hidden').html()  + ".0";
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_done_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 40) > scrolled_bottom_var) {
            $('#pwx_task_chart_menu').css('top', dt_pos.top - 40);
        }
        else {
            $('#pwx_task_chart_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_menu').css('display', 'block');
    });

    framecontentElem.on('click', 'span.pwx-lab_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parents('dl.pwx_content_row').children('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                    var taskSuccess = pwx_task_label_print_launch(cur_person_id, cur_task_id);
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                }
                else {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                }
            }
            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", cur_task_id, true) }, 1000); }
        }
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_personname_dt a', function () {
        var parentelement = $(this).parents('dt.pwx_fcr_content_person_dt')
        var parentpersonid = $(parentelement).siblings('.pwx_person_id_hidden').text()
        var parentencntridid = $(parentelement).siblings('.pwx_encounter_id_hidden').text()
        var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid + ' /FIRSTTAB=^^'
        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
    });

    framecontentElem.on('click', 'span.pwx_reflab_relogin_lab', function (e) {
        var logintaskId = $(this).parents('dl.pwx_content_row').children('span.pwx_task_id_hidden').html() + ".0";
        PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", logintaskId, true)
        setTimeout(function () { $('#pwx_task_list_refresh_icon').trigger('click') }, 1000);
    });
    framecontentElem.on('click', 'span.pwx_reflab_remove_trans_list', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        var containerObj = $(this).parents('dl.pwx_content_row').children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').children('.pwx_task_lab_containid_hidden').map(function () {
            return $(this).text() + ".0";
        })
        var containerArr = jQuery.makeArray(containerObj);
        MP_DCP_REFLAB_REMOVE_FROM_LIST_Request("amb_cust_rmv_from_trans_list", transListId, containerArr.join(","), true)
    });
    framecontentElem.on('click', 'span.pwx_reflab_retransfer_link', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        MP_DCP_REFLAB_RETRANSFER_Request("amb_cust_mp_reflab_retransfer", transListId, true)
    });
    framecontentElem.on('click', 'span.pwx_reflab_lab_results', function (e) {
        cur_person_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_person_id_hidden').html();
        cur_encntr_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_encounter_id_hidden').html();
        //var parameter_person_launch = '/PERSONID=' + cur_person_id + ' /ENCNTRID=' + cur_encntr_id + ' /FIRSTTAB=^Laboratory^'
        //APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
        var resultorderId = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html() + ".0";
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var pname = pwxdata.TLIST[json_index].PERSON_NAME
        var pdob = pwxdata.TLIST[json_index].DOB
        var pers_age = pwxdata.TLIST[json_index].AGE
        var pgender = pwxdata.TLIST[json_index].GENDER
        MP_DCP_REFLAB_GET_ORDER_RESULTS_Request("amb_cust_mp_get_order_results", resultorderId, cur_person_id, pname, pdob, pers_age, pgender, true)
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
    });
    framecontentElem.on('click', 'span.pwx_reflab_retransfer_success_link', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        MP_DCP_REFLAB_GET_LIST_DETAILS_Request("amb_cust_reflab_tranlist_dets", transListId, true)
    });
    //ABN launch link
    framecontentElem.on('click', 'dt.pwx_fcr_content_col_abn_dt', function () {
        // show dialog
        var abnProgramName = '';
        var trackId = $(this).children('.pwx_abn_track_id_hidden').text()
        var jsonId = $(this).children('.pwx_abn_json_id_hidden').text()
        var abnHTML = []
        abnHTML.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[jsonId].PERSON_NAME, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[jsonId].DOB, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[jsonId].AGE, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[jsonId].GENDER, '</span>')
        abnHTML.push('</div>')
        abnHTML.push('<p class="pwx_small_text hvr_table"><span style="vertical-align:30%;">' + amb_i18n.ABN_TEMPLATE + ': </span><select id="abn_programs" name="abn_programs" multiple="multiple">')
        for (var cc = 0; cc < pwxdata.ABN_FORM_LIST.length; cc++) {
            abnHTML.push('<option value="' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_NAME + '">' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_DESC + '</option>');
        }
        abnHTML.push('</select></br></br>');
        abnHTML.push('<table width="95%" ><tr><th>' + amb_i18n.ORDER + '</th><th>' + amb_i18n.ALERT_DATE + '</th><th>' + amb_i18n.ALERT_STATE + '</th></tr>');
        for (var cc = 0; cc < pwxdata.TLIST[jsonId].ABN_LIST.length; cc++) {
            abnHTML.push('<tr><td class="abn_order_mne">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ORDER_DISP + '</td><td class="abn_alert_date">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_DATE +
            '</td><td class="abn_alert_state">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_STATE + '</td></tr>');
        }
        abnHTML.push('</table></p>');
        //build the drop down
        MP_ModalDialog.deleteModalDialogObject("ABNModal")
        var abnModal = new ModalDialog("ABNModal")
                                .setHeaderTitle(amb_i18n.ABN)
                                .setTopMarginPercentage(15)
                                .setRightMarginPercentage(25)
                                .setBottomMarginPercentage(15)
                                .setLeftMarginPercentage(25)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
        abnModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div class="pwx_task_detail_no_pad">' + abnHTML.join("") + '</div>');
                            });
        var printbtn = new ModalButton("PrintABN");
        printbtn.setText(amb_i18n.VIEW).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
            var ccllinkparams = '^MINE^,^' + trackId + '^,^' + abnProgramName + '^';
            window.location = "javascript:CCLLINK('amb_cust_abn_print_wrapper','" + ccllinkparams + "',0)";
        });
        var closebtn = new ModalButton("abnCancel");
        closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
        abnModal.addFooterButton(printbtn)
        abnModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(abnModal);
        MP_ModalDialog.showModalDialog("ABNModal")
        $("#abn_programs").multiselect({
            //height: loc_height,
            header: false,
            multiple: false,
            //minWidth: "250",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.ABN_SELECT,
            selectedList: 1
        });
        $("#abn_programs").on("multiselectclick", function (event, ui) {
            abnProgramName = ui.value
            abnModal.setFooterButtonDither("PrintABN", false);
        })
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
    })
    var end_delegate_event_timer = new Date();
    delegate_event_timer = (end_delegate_event_timer - start_delegate_event_timer) / 1000

}

function RenderRefLabListContent(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    $.contextMenu('destroy', 'span.pwx_fcr_content_type_person_icon_dt');
	pwx_clear_patient_focus();
    var start_content_timer = new Date();
    $('#pwx_task_filterbar_page_prev').html("")
    $('#pwx_task_filterbar_page_prev').off()
    $('#pwx_task_filterbar_page_next').html("")
    $('#pwx_task_filterbar_page_next').off()
    $('#pwx_reflab_collection_filter input').off()
    $('#pwx_reflab_tolocation_filter').empty()
    //build the content
    var js_criterion = JSON.parse(m_criterionJSON);
    var pwxcontentHTML = [];
    if (pwxdata.TLIST.length > 0) {
        //if viw = 3 create the transferred layout otherwise use the collection layout for in/out of office
        if (pwx_reflab_type_view == 3) {
            //icon type
            if (pwx_reflab_trans_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl">');
            if (pwx_reflab_trans_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_orderdate_dt">',amb_i18n.ORDERED,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_orderdate_dt">',amb_i18n.ORDERED,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_tolocation_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_tolocation_dt">',amb_i18n.LAB,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_tolocation_dt">',amb_i18n.LAB,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_transdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_transdate_dt">',amb_i18n.TRANSMIT_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_transdate_dt">',amb_i18n.TRANSMIT_DATE,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_action_dt"><span style="padding-left:5px;">',amb_i18n.STATUS,'</span></dt>');
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var toLocationMatch = 0;
                    for (var cc = 0; cc < pwx_reflab_to_location_filterArr.length; cc++) {
                        if (pwx_reflab_to_location_filterArr[cc] == pwxdata.TLIST[i].TRANSFER_TO_LOC) {
                            toLocationMatch = 1;
                            break;
                        }
                    }
                }
                else {
                    var toLocationMatch = 1;
                }
                var resultMatch = 1;
                if (pwx_reflab_result_filter == "Pending") {
                    if (pwxdata.TLIST[i].RESULTS_IND == 1) {
                        resultMatch = 0;
                    }
                }
                else if (pwx_reflab_result_filter == "Results") {
                    if (pwxdata.TLIST[i].RESULTS_IND == 0) {
                        resultMatch = 0;
                    }
                }
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view && pwxdata.TLIST[i].COLLECTED_IND == pwx_reflab_collection_type_view && toLocationMatch == 1 && resultMatch == 1) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != ""  && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    var containerHTML = []
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        containerHTML.push('<div class="pwx_task_lab_container_hidden">');
                        containerHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        containerHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        containerHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        containerHTML.push('</div>');
                        containerHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    //add italic class if inprocess;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt pwx_no_border_left"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_labname_dt " ><span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    pwxcontentHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    pwxcontentHTML.push(containerHTML.join(""));
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[i].ORDER_DT_TM_UTC != "TZ") {
						var orderUTCDate = new Date();
						orderUTCDate.setISO8601(pwxdata.TLIST[i].ORDER_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_orderdate_dt"><span style="padding-bottom:2px;">', orderUTCDate.format("shortDate3"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_orderdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_tolocation_dt">');
                    pwxcontentHTML.push(pwxdata.TLIST[i].TRANSFER_TO_LOC, task_row_lines);
                    pwxcontentHTML.push('</dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_transdate_dt">');
					if(pwxdata.TLIST[i].TRANSFER_DT_TM_UTC != "" && pwxdata.TLIST[i].TRANSFER_DT_TM_UTC != "TZ") {
						var transferUTCDate = new Date();
						transferUTCDate.setISO8601(pwxdata.TLIST[i].TRANSFER_DT_TM_UTC);
						pwxcontentHTML.push(transferUTCDate.format("longDateTime4"), task_row_lines);
					} else {
						pwxcontentHTML.push('--', task_row_lines);
					}
                    pwxcontentHTML.push('</dt>');
                    var readytoTrans = 0;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_action_dt">');
                    if (pwxdata.TLIST[i].RESULTS_IND == 1) {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_ready_trans"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_reflab_lab_results"><a class="pwx_blue_link">',amb_i18n.RESULTS_REC,'</a><span class="pwx_task_json_index_hidden" style="display:none !important;">', i, '</span></span></span>');
                    }
                    else if (pwxdata.TLIST[i].RESULTS_IND == 2) {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_warning_trans"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_reflab_lab_results"><a class="pwx_blue_link">',amb_i18n.PARTIAL_RESULTS,'</a><span class="pwx_task_json_index_hidden" style="display:none !important;">', i, '</span></span></span>');
                    }
                    else {
                        if (pwxdata.TLIST[i].OUTBOUND_IND == 1) {
							if (pwxdata.ALLOW_TRANSFER_IND == 1) {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span>',amb_i18n.TRANSMITTED,'</span></br><span class="pwx_reflab_retransfer_success_link"><a class="pwx_blue_link">',amb_i18n.RETRANSMIT,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
							} else {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span>',amb_i18n.TRANSMITTED,'</span></span>');
							}
						}
                        else {
							if (pwxdata.ALLOW_TRANSFER_IND == 1) {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt" ><span title="',amb_i18n.ORDER_NOT_TRANS,'">',amb_i18n.NOT_TRANSMITTED,'</span></br><span class="pwx_reflab_retransfer_link"><a class="pwx_blue_link">',amb_i18n.RETRANSMIT,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
							} else {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt" ><span title="',amb_i18n.ORDER_NOT_TRANS,'">',amb_i18n.NOT_TRANSMITTED,'</span></span>');
							}
						}
                    }
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }

                    pwxcontentHTML.push('</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_trans_ind" style="display:none;">', readytoTrans, '</dt>');
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

        }
        else if (pwx_reflab_type_view == 2) {
            //icon type
            if (pwx_reflab_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl">');
            if (pwx_reflab_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.ORDER_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.ORDER_DATE,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_subtype_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_subtype_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_subtype_dt">',amb_i18n.TYPE,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_action_dt"><span style="padding-left:5px;">',amb_i18n.STATUS,'</span></dt>');
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var toLocationMatch = 0;
                    for (var cc = 0; cc < pwx_reflab_to_location_filterArr.length; cc++) {
                        for (var yy = 0; yy < pwxdata.TLIST[i].TRANS_LOC.length; yy++) {
                            if (pwx_reflab_to_location_filterArr[cc] == pwxdata.TLIST[i].TRANS_LOC[yy].LOCATION_DISP) {
                                toLocationMatch = 1;
                                break;
                            }
                        }
                        if (toLocationMatch == 1) {
                            break;
                        }
                    }
                }
                else {
                    var toLocationMatch = 1;
                }
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view && pwxdata.TLIST[i].COLLECTED_IND == pwx_reflab_collection_type_view && toLocationMatch == 1) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    //add italic class if inprocess;
                    var labnameHTML = []
                    labnameHTML.push('<span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    labnameHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        labnameHTML.push('<div class="pwx_task_lab_container_hidden">');
                        labnameHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        labnameHTML.push('</div>');
                        labnameHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt pwx_no_border_left"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_labname_dt " >', labnameHTML.join(""))
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[i].ORDER_DT_TM_UTC != "TZ") {
						var orderUTCDate = new Date();
						orderUTCDate.setISO8601(pwxdata.TLIST[i].ORDER_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">', orderUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;"> ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_subtype_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ACTIVITY_SUB_TYPE, task_row_lines, '</span></dt>');
                    var readytoTrans = 0;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_action_dt">');
                    if (pwxdata.TLIST[i].NO_LOGIN_LOCATION != 1) {
                        if (pwxdata.TLIST[i].NOT_LOGIN_LOC != 1) {
                            if (pwxdata.ALLOW_TRANSFER_IND == 1) {
                                if (pwxdata.TLIST[i].TRANSFER_LIST_ID == 0) {
                                    if (pwxdata.TLIST[i].TRANS_LOC.length > 0) {
                                        if (pwxdata.TLIST[i].TRANS_LOC.length == 1) {
                                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_ready_trans" title="',amb_i18n.LAB_RDY_TRANS,'"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_lab_transfer_link pwx_semi_bold" title="', pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP, '">',
                                             pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP, '</span><span class="pwx_reflab_to_location" style="display:none;">', pwxdata.TLIST[i].TRANS_LOC[0].SR_RESOURCE_CD, '</span></span>');
                                            readytoTrans = 1;
                                        }
                                        else {
                                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_lab_transfer_link"><span class="pwx_lab_transfer_loc_multi pwx_pointer_cursor"><a class="pwx_blue_link">',amb_i18n.SELECT_LAB_LOC,'</a></span>')
                                            pwxcontentHTML.push('</span><span class="pwx_reflab_to_location" style="display:none;"></span><span style="display:none;" class="pwx_task_json_index_hidden">', i, '</span></span>');
                                        }
                                    }
                                    else {
                                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.NO_LAB_ASSOC,'">',amb_i18n.NO_LAB_LOC,'</span></span>');
                                    }
                                }
                                else {
                                    pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_warning_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.CONTAINER_ON_TRANS_LIST,'">',amb_i18n.CONTAINER_EXIST_LIST,'</span></br><span class="pwx_reflab_remove_trans_list"><a class="pwx_blue_link">',amb_i18n.REMOVE_FROM_LIST,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
                                }
                            }
                            else {
                                pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt">',amb_i18n.NOT_ALLOW_TRANS,'</span>');
                            }
                        }
                        else {
                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.SPEC_NOT_LOGIN_LOC_TOOLTIP,'">',amb_i18n.SPEC_NOT_LOGIN,'</span></br><span class="pwx_reflab_relogin_lab"><a class="pwx_blue_link">',amb_i18n.LOGIN_TO_SPEC_LOC,'</a></span></span>');
                        }
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.SPEC_NO_LAB_LOC,'">',amb_i18n.NO_DEFAULT_SPEC_LOC,'</span></span>');
                    }
                    pwxcontentHTML.push('</dt>');
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }


                    pwxcontentHTML.push('<dt class="pwx_reflab_trans_ind" style="display:none;">', readytoTrans, '</dt>');
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }
        }
        else if (pwx_reflab_type_view == 1) {
            //icon type
            if (pwx_reflab_coll_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl"><dt id="pwx_fcr_header_labtype_icon_dt">&nbsp;</dt>');

            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.TASK_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.TASK_DATE,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_subtype_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_subtype_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_subtype_dt">',amb_i18n.TYPE,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_orderprov_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_orderprov_dt">',amb_i18n.ORDERING_PROV,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_orderprov_dt">',amb_i18n.ORDERING_PROV,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
			pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link2">',amb_i18n.NOT_DONE,'</a></div>');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					}
					else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_type_icon_dt"><div class="pwx_fcr_content_action_bar">&nbsp;</div>');
                    //pwxcontentHTML.push('<dt class="pwx_fcr_content_labtype_icon_dt">');
                    if (pwxdata.TLIST[i].CAN_CHART_IND == 1) {
                        var taskmenuIcon = '<span class="pwx-icon_submenu_arrow-icon pwx_task_need_chart_menu">&nbsp;</span>';
                        pwxcontentHTML.push('<span class="pwx-lab_task-icon pwx_pointer_cursor" title="',amb_i18n.COLLECT_SPEC,'">&nbsp;</span>', taskmenuIcon);
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx-task_disabled-icon" title="',amb_i18n.ACTIONS_NOT_AVAIL,'">&nbsp;</span>');
                    }
                    pwxcontentHTML.push('</dt>');
                    //add italic class if inprocess;
                    var labnameHTML = []
                    labnameHTML.push('<span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    labnameHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        labnameHTML.push('<div class="pwx_task_lab_container_hidden">');
                        labnameHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        labnameHTML.push('</div>');
                        labnameHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_labname_dt " >', labnameHTML.join(""))
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">', taskUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					}
					else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_subtype_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ACTIVITY_SUB_TYPE, task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_orderprov_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ORDERING_PROVIDER, task_row_lines, '</span></dt>');
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }
        }
    }
    else {
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"></div><div id="pwx_frame_content_rows"><dl class="pwx_content_nores_row"><span class="pwx_noresult_text">',amb_i18n.NO_RESULTS,'</span></dl>');
    }
    pwxcontentHTML.push('</div>');
    //display content
    framecontentElem.html(pwxcontentHTML.join(""));
    var end_content_timer = new Date();
    var start_event_timer = new Date();
    $('#pwx_task_pagingbar_cur_page').text(amb_i18n.PAGE + ': ' + reflab_list_curpage)
    //setup next paging button
    if (pagin_active == 1 && end_of_reflab_list != 1) {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage-icon"></span>')
        $('#pwx_task_filterbar_page_next').on('click', function () {
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            reflab_list_curpage++
            RenderRefLabListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage_grey-icon"></span>')
    }
    //setup prev paging button
    if (json_reflab_start_number > 0) {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage-icon"></span>')
        $('#pwx_task_filterbar_page_prev').on('click', function () {
            reflab_list_curpage--
            json_task_end_number = json_reflab_page_start_numbersAr[reflab_list_curpage - 1]
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            RenderRefLabListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage_grey-icon"></span>')
    }
    if (json_reflab_start_number > 0 || pagin_active == 1) {
        $('#pwx_frame_paging_bar_container').css('display', 'inline-block')
    }
    else {
        $('#pwx_frame_paging_bar_container').css('display', 'none')
    }
    $('#pwxptsumm').on('click', function () {
        callCCLLINK(ccllinkparams)
    });
    $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_col_orderprov_dt, dt.pwx_fcr_trans_content_tolocation_dt').each(function (index) {
        if (this.clientWidth < this.scrollWidth) {
            var titleText = $(this).text()
            $(this).attr("title", titleText)
        }
    });
	/*
    //multiple lab locations dropdown
    $(".pwx_to_location_class").multiselect({
        header: false,
        minWidth: "50",
        multiple: false,
        classes: "pwx_select_box",
        noneSelectedText: 'Select Lab Location',
        selectedList: 1
    });
	$(".pwx_to_location_class").multiselect('refresh')
	var selectWidth = $(".pwx_fcr_content_action_move_dt").width()
	$(".pwx_to_location_class").css("width", selectWidth - 10)
	$(".pwx_to_location_class").multiselect('refresh')
    $(".pwx_to_location_class").on("multiselectclick", function (event, ui) {
        var toLocationID = ui.value
        $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(toLocationID)
        $(this).parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html("1")
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected')
        var transButtonOn = 1;
        if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
            $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
                if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                    transButtonOn = 0;
                }
            });
        }
        else {
            transButtonOn = 0;
        }
        if (transButtonOn == 1) {
            //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
            $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
        }
        else {
            //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
            $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
        }
    })
	*/
    //set action dt events
    //sorting events
    if (pwx_reflab_type_view == 1) {
        $('#pwx_fcr_header_orderdate_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_orderdate_dt')
        });
        $('#pwx_fcr_header_col_subtype_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_subtype_dt')
        });
        $('#pwx_fcr_header_col_labname_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_labname_dt')
        });
        $('#pwx_fcr_header_col_orderprov_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_orderprov_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //add charting done events
        $('#pwx_task_chart_menu').on('mouseleave', function (event) {
            $(this).css('display', 'none');
        });
        $('#pwx_task_chart_link').on('click', function (e) {
            var taskSuccess = pwx_task_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id, 'CHART');
            if (taskSuccess == true) {
                $(pwx_reflab_submenu_clicked_row_elem).each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                });
                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                        var taskSuccess = pwx_task_label_print_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id);
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                    }
                    else {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                    }
                }
                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", pwx_reflab_submenu_clicked_task_id, true) }, 1000); }
            }
            $('#pwx_task_chart_menu').css('display', 'none');
        });
        $('#pwx_task_chart_not_done_link2').on('click', function (e) {
            var taskSuccess = pwx_task_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id, 'CHART_NOT_DONE');

            if (taskSuccess == true) {
                $(pwx_reflab_submenu_clicked_row_elem).each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                });
            }
            $('#pwx_task_chart_menu').css('display', 'none');
        });
    }
    else if (pwx_reflab_type_view == 2) {
        $('#pwx_fcr_header_orderdate_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_orderdate_dt')
        });
        $('#pwx_fcr_header_subtype_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_subtype_dt')
        });
        $('#pwx_fcr_header_labname_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_labname_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //action height
        $('dt.pwx_fcr_content_action_dt').each(function (index) {
            var dlHeight = $(this).siblings('dt.pwx_fcr_content_labname_dt').height()
            $(this).children('.pwx_fcr_content_action_indicator_dt').css('height', dlHeight).css('line-height', dlHeight + 'px')
        });
        $('#pwx_reflab_collection_filter input').on('change', function () {
            pwx_reflab_collection_type_view = $('#pwx_reflab_collection_filter input:checked').val()
            pwx_reflab_collection_filter_change(pwxdata)
        })
        var fullLabLoc = $.map(pwxdata.TLIST, function (n, i) {
            if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                if (pwxdata.TLIST[i].TRANS_LOC.length > 0) {
                    if (pwxdata.TLIST[i].TRANS_LOC.length > 1) {
                        var iterateLabLoc = $.map(pwxdata.TLIST[i].TRANS_LOC, function (y, cc) {
                            return pwxdata.TLIST[i].TRANS_LOC[cc].LOCATION_DISP
                        })
                        return iterateLabLoc
                    }
                    else {
                        return pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP;
                    }
                }
            }
            else {
                return null
            }

        });
        var uniqueLabLoc = $.distinct(fullLabLoc);
        if (uniqueLabLoc.length > 1) {
            var labLocHTML = []
            labLocHTML.push('<span style="vertical-align:30%;">Lab: </span><select id="reflab_to_location" name="reflab_to_location" multiple="multiple" width="220px">');
            for (var i = 0; i < uniqueLabLoc.length; i++) {
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_reflab_to_location_filterArr.length; y++) {
                        if (pwx_reflab_to_location_filterArr[y] == uniqueLabLoc[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                    else {
                        labLocHTML.push('<option value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                }
                else {
                    labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                }
            }
            labLocHTML.push('</select>');
            $('#pwx_reflab_tolocation_filter').html(labLocHTML.join(""))
            $("#reflab_to_location").multiselect({
                height: "100",
                minWidth: "225",
                classes: "pwx_select_box",
                noneSelectedText: 'Select To Location',
                selectedList: 1
            });
            $("#reflab_to_location").on("multiselectclose", function (event, ui) {
                var array_of_checked_values = $("#reflab_to_location").multiselect("getChecked").map(function () {
                    return this.value;
                }).get();
                pwx_reflab_to_location_filterArr = jQuery.makeArray(array_of_checked_values);
                if (uniqueLabLoc.length == pwx_reflab_to_location_filterArr.length) {
                    pwx_reflab_to_location_filterApplied = 0
                } else {
                    pwx_reflab_to_location_filterApplied = 1
                }
                pwx_reflab_collection_filter_change(pwxdata)
            });
        }
	//multiple lab locations dropdown
		framecontentElem.off('click', 'span.pwx_lab_transfer_loc_multi')
		framecontentElem.on('click', 'span.pwx_lab_transfer_loc_multi', function () {
			var locJSONId = $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_task_json_index_hidden').text()
			var loccontentElem = $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_lab_transfer_link')
			var loccontentOldHTML = loccontentElem.html()
			var setLabLocation = loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html();
			var setHTMLInd = loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html()
			var setIndicator = loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').hasClass('pwx_reflab_ready_trans')
			var setTitle = loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title')	
			
			var tempElemId = "pwx_to_location_dropdown_" + locJSONId
			var tempHTML = []
			tempHTML.push('<select class="pwx_to_location_class" id="', tempElemId, '" multiple="multiple" >')
			for (var cc = 0; cc < pwxdata.TLIST[locJSONId].TRANS_LOC.length; cc++) {
				if(pwxdata.TLIST[locJSONId].TRANS_LOC[cc].SR_RESOURCE_CD == setLabLocation) {
					var selectInd = 'selected="selected"'
				} else {
					var selectInd = ''
				}
				tempHTML.push('<option value="', pwxdata.TLIST[locJSONId].TRANS_LOC[cc].SR_RESOURCE_CD, '" ',selectInd,'>', pwxdata.TLIST[locJSONId].TRANS_LOC[cc].LOCATION_DISP, '</option>')
			}
			tempHTML.push('</select>');
			loccontentElem.html(tempHTML.join(""))
			$("#" + tempElemId).off("multiselectclick multiselectclose")
			$("#" + tempElemId).multiselect({
				header: false,
				minWidth: "50",
				multiple: false,
				classes: "pwx_select_box",
				noneSelectedText: amb_i18n.SELECT_LAB_LOC,
				autoOpen: true,
				selectedList: 1,
				position: {
                    my: "top",
                    at: "bottom",
                    collision: "flip"
                }
			});
			setTimeout(function () {  
				var selectWidth = $(".pwx_fcr_content_action_dt").width() - $(".pwx_fcr_content_action_indicator_dt").width()
				$("#" + tempElemId).css("width", selectWidth - 10)
				$("#" + tempElemId).multiselect('refresh')			
			},0);

			$("#" + tempElemId).on("multiselectclick multiselectclose", function (event, ui) {
				var toLocationID = ui.value
				if(toLocationID != undefined) {
					loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(toLocationID)
					loccontentElem.attr("title",ui.text)
					loccontentElem.html('<span class="pwx_lab_transfer_loc_multi pwx_pointer_cursor">' + ui.text + '</span>')
					loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html("1")
					loccontentElem.parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected')
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').addClass('pwx_reflab_ready_trans')
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title',amb_i18n.LAB_RDY_TRANS)
					pwx_reflab_selectall_check();
				} else {
					loccontentElem.html(loccontentOldHTML);
					loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(setLabLocation);
					loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html(setHTMLInd)
					if(setIndicator == false) {
						loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').removeClass('pwx_reflab_ready_trans')
					}
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title',setTitle)
				}
				//$("#" + tempElemId).destroy()
			})
		});
    }
    else if (pwx_reflab_type_view == 3) {
        $('#pwx_fcr_trans_header_transdate_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_transdate_dt')
        });
        $('#pwx_fcr_trans_header_tolocation_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_tolocation_dt')
        });
        $('#pwx_fcr_trans_header_labname_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_labname_dt')
        });
        $('#pwx_fcr_trans_header_orderdate_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_orderdate_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //action height
        $('dt.pwx_fcr_content_action_dt').each(function (index) {
            var dlHeight = $(this).siblings('dt.pwx_fcr_trans_content_labname_dt').height()
            $(this).children('.pwx_fcr_content_action_indicator_dt').css('height', dlHeight).css('line-height', dlHeight + 'px')
        });
        $('#pwx_reflab_collection_filter input').on('change', function () {
            pwx_reflab_collection_type_view = $('#pwx_reflab_collection_filter input:checked').val()
            pwx_reflab_collection_filter_change(pwxdata)
        })
        $("#reflab_results").on("multiselectclick", function (event, ui) {
            pwx_reflab_result_filter = ui.value
            pwx_reflab_collection_filter_change(pwxdata)
        })
        var fullLabLoc = $.map(pwxdata.TLIST, function (n, i) {
            if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                return pwxdata.TLIST[i].TRANSFER_TO_LOC;
            }
            else {
                return null
            }

        });
        var uniqueLabLoc = $.distinct(fullLabLoc);
        if (uniqueLabLoc.length > 1) {
            var labLocHTML = []
            labLocHTML.push('<span style="vertical-align:30%;">Lab: </span><select id="reflab_to_location" name="reflab_to_location" multiple="multiple" width="220px">');
            for (var i = 0; i < uniqueLabLoc.length; i++) {
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_reflab_to_location_filterArr.length; y++) {
                        if (pwx_reflab_to_location_filterArr[y] == uniqueLabLoc[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                    else {
                        labLocHTML.push('<option value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                }
                else {
                    labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                }
            }
            labLocHTML.push('</select>');
            $('#pwx_reflab_tolocation_filter').html(labLocHTML.join(""))
            $("#reflab_to_location").multiselect({
                height: "100",
                minWidth: "225",
                classes: "pwx_select_box",
                noneSelectedText: amb_i18n.SELECT_TO_LOCATION,
                selectedList: 1
            });
            $("#reflab_to_location").on("multiselectclose", function (event, ui) {
                pwx_reflab_to_location_filterApplied = 1
                var array_of_checked_values = $("#reflab_to_location").multiselect("getChecked").map(function () {
                    return this.value;
                }).get();
                pwx_reflab_to_location_filterArr = jQuery.makeArray(array_of_checked_values);
                pwx_reflab_collection_filter_change(pwxdata)
            });
        }
    }
    //person menu
    $.contextMenu({
        selector: 'span.pwx_fcr_content_type_person_icon_dt',
        trigger: 'left',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).parents('dl.pwx_content_row').addClass('pwx_row_selected')
            json_index = $($trigger).children('span.pwx_task_json_index_hidden').text()
            var options = {
                items: {
                    "Visit Summary (Depart)": { "name": pwxdata.DEPART_LABEL, callback: function (key, opt) {
                        var dpObject = new Object();
                        dpObject = window.external.DiscernObjectFactory("DISCHARGEPROCESS");
                        dpObject.person_id = pwxdata.TLIST[json_index].PERSON_ID;
                        dpObject.encounter_id = pwxdata.TLIST[json_index].ENCOUNTER_ID;
                        dpObject.user_id = js_criterion.CRITERION.PRSNL_ID;
                        dpObject.LaunchDischargeDialog();
                    }
                    },
                    "fold1": {
                        "name": "Chart Forms",
                        "items": {},
                        disabled: false
                    },
                    "Patient Snapshot": { "name": amb_i18n.PATIENT_SNAPSHOT, callback: function (key, opt) {
                        PWX_CCL_Request_Person_Details("amb_cust_person_details_diag", pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, false)
                    }
                    },
                    "sep5": "---------",
                    "fold3": {
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };

            if (pwxdata.FORMSLIST.length > 0) {
                for (var cc in pwxdata.FORMSLIST) {
                    options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                }
                options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, 0.0, 0.0, 0); } }
            }
            else {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
            }
            if (pwxdata.ALLOW_DEPART == 0) {
                options.items["Visit Summary (Depart)"] = { "name": pwxdata.DEPART_LABEL, disabled: function (key, opt) { return true; } };
            }
            if (js_criterion.CRITERION.VPREF.length > 0) {
                for (var cc in js_criterion.CRITERION.VPREF) {
                    options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                        var parameter_person_launch = '/PERSONID=' + pwxdata.TLIST[json_index].PERSON_ID + ' /ENCNTRID=' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                    }
                    };
                }
            }
            else {
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
	$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	var contentrowsH = filterbarH + 19;
	$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
	window.scrollTo(0,0);
    //timers
    var end_event_timer = new Date();
    var end_page_load_timer = new Date();
    var event_timer = (end_event_timer - start_event_timer) / 1000
    var content_timer = (end_content_timer - start_content_timer) / 1000
    var program_timer = (end_page_load_timer - start_page_load_timer) / 1000
    stop_pwx_timer()
    //$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text"><dt>CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</dt></dl>')
}








function MP_DCP_REFLAB_TRANSFER_Request(program, blobIn, paramAr, async) {
    //create spinning modal
    MP_ModalDialog.deleteModalDialogObject("RefTransmittingModal")
    var refTransmitModal = new ModalDialog("RefTransmittingModal")
                    .setHeaderTitle(amb_i18n.TRANSMITTING + '...')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(false)
                    .setShowCloseIcon(false);
    refTransmitModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;" style="float:left;width:100%;text-align:center;"><div class="pwx_loading-spinner" style="position:relative;width:32px;left:50%;margin-left:-16px;"></div></div>');
                });
    MP_ModalDialog.addModalDialogObject(refTransmitModal);
    MP_ModalDialog.showModalDialog("RefTransmittingModal")

    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            MP_ModalDialog.closeModalDialog("RefTransmittingModal")
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
				setTimeout(function () { 
					$('#pwx_task_list_refresh_icon').trigger('click')
					if (pwx_reflab_collection_type_view == '1') {
						var ccllinkparams = '^MINE^,^' + recordData.TRANS_LISTS + '^'
						window.location = "javascript:CCLLINK('amb_cust_reflab_transfer_list','" + ccllinkparams + "',0)";
					}
				}, 500);
            }
            else if (recordData.STATUS_DATA.STATUS == "T") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + amb_i18n.UNABLE_ESO_ERROR + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    info.setBlobIn(JSON.stringify(blobIn));
    info.open('GET', program, async);
    info.send(paramAr.join(","));
}

function MP_DCP_REFLAB_REMOVE_FROM_LIST_Request(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        //alert(info.readyState + ' ' + info.status)
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                $('#pwx_task_list_refresh_icon').trigger('click')
            }
            else if (recordData.STATUS_DATA.STATUS == "D") {
                var error_text = amb_i18n.LIST_ALREADY_TRANS;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0", "^" + param2 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_RETRANSFER_Request(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        //alert(info.readyState + ' ' + info.status)
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                $('#pwx_task_list_refresh_icon').trigger('click')
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_GET_LIST_DETAILS_Request(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                var detailsHTML = []
                detailsHTML.push('<span class="pwx_grey">',amb_i18n.FROM,': </span>', recordData.FROM_LOCATION, '<span class="pwx_grey">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',amb_i18n.TO,': </span>', recordData.TO_LOCATION, '</br></br>')
                detailsHTML.push('<div class="hvr_table"><table><tr><th>',amb_i18n.PATIENT_NAME,'</th><th>',amb_i18n.GENDER,'</th><th>',amb_i18n.DOB,'</th><th>',amb_i18n.ACCESSION,'</th><th>',amb_i18n.ORDER,'</th><th>',amb_i18n.DESCRIPTION,'</th></tr>')
                for (var y = 0; y < recordData.CONTAIN_LIST.length; y++) {
                    detailsHTML.push('<tr>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_NAME, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_GENDER, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_DOB, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].ACCESSION, ' ', recordData.CONTAIN_LIST[y].ACCESSION_NUM, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].ORDER_LINE, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].CONTAINER_SENT, '</td>')
                    detailsHTML.push('</tr>')
                }
                detailsHTML.push('</table></div>')
                MP_ModalDialog.deleteModalDialogObject("ListDetailModal")
                var listDetailModal = new ModalDialog("ListDetailModal")
                    .setHeaderTitle(amb_i18n.TRANSMIT_LIST + ' #' + recordData.TRANSFER_LIST_NUM + ' on ' + recordData.TRANSFER_LIST_DT)
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(10)
                    .setBottomMarginPercentage(15)
                    .setLeftMarginPercentage(10)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                listDetailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + detailsHTML.join("") + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                var retransferbtn = new ModalButton("retransfer");
                retransferbtn.setText(amb_i18n.RETRANSMIT).setCloseOnClick(true).setOnClickFunction(function () { MP_DCP_REFLAB_RETRANSFER_Request("amb_cust_mp_reflab_retransfer", param1, true) }); ;
                listDetailModal.addFooterButton(retransferbtn)
                listDetailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(listDetailModal);
                MP_ModalDialog.showModalDialog("ListDetailModal")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_GET_ORDER_RESULTS_Request(program, param1, param2, pname, pdob, person_age, pgender, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                //alert(JSON.stringify(recordData))
                var detailsHTML = []
                detailsHTML.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pname, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pdob, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', person_age, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pgender, '</span>')
                detailsHTML.push('</div></br></br>')
                for (var y = 0; y < recordData.ORDER_LIST.length; y++) {
                    detailsHTML.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title">',amb_i18n.ORDER,' ', (y + 1), ':&nbsp;<span class="pwx_semi_bold">', recordData.ORDER_LIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
                    if (recordData.ORDER_LIST[y].RESLIST.length > 0) {
                        detailsHTML.push('</br></br><dl class="pwx_task_detail_line"><dt>',amb_i18n.RESULT_DATE,':</dt><dd>', recordData.ORDER_LIST[y].RESLIST[0].RESULT_DATE, '</dd></dl>')
                        detailsHTML.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><th>',amb_i18n.RESULT,'</th><th>',amb_i18n.VALUE,'</th></tr>')
                        for (var z = 0; z < recordData.ORDER_LIST[y].RESLIST.length; z++) {
                            detailsHTML.push('<tr>')
                            var normalcy = "res-normal";
                            var normalcyMeaning = recordData.ORDER_LIST[y].RESLIST[z].NORMALCY_CD_MEAN
                            if (normalcyMeaning != null) {
                                if (normalcyMeaning === "LOW") {
                                    normalcy = "res-low";
                                } else {
                                    if (normalcyMeaning === "HIGH") {
                                        normalcy = "res-high";
                                    } else {
                                        if (normalcyMeaning === "CRITICAL" || normalcyMeaning === "EXTREMEHIGH" || normalcyMeaning === "PANICHIGH" || normalcyMeaning === "EXTREMELOW" || normalcyMeaning === "PANICLOW" || normalcyMeaning === "VABNORMAL" || normalcyMeaning === "POSITIVE") {
                                            normalcy = "res-severe";
                                        } else {
                                            if (normalcyMeaning === "ABNORMAL") {
                                                normalcy = "res-abnormal";
                                            }
                                        }
                                    }
                                }
                            }
                            var resDisp = ""
                            resDisp += '<span class="' + normalcy + '"><span class="res-ind" style="margin:2px .3em 1px 0 !important;">&nbsp;</span><a class="pwx_nocolor_link" onClick="pwx_result_view_launch(' + param2 + ',' + recordData.ORDER_LIST[y].RESLIST[z].EVENT_ID + ')">' + recordData.ORDER_LIST[y].RESLIST[z].RESULT_VAL + '</a></span><span class="pwx_extra_small_text pwx_grey">&nbsp;' + recordData.ORDER_LIST[y].RESLIST[z].RESULT_UNITS + '</span>'

                            var js_criterion = JSON.parse(m_criterionJSON);
                            js_criterion.CRITERION.PRSNL_ID
                            if (!isIntegerorFloat(recordData.ORDER_LIST[y].RESLIST[z].RESULT_VAL)) {
                                detailsHTML.push('<td>', recordData.ORDER_LIST[y].RESLIST[z].RESULT_NAME, '</td>')
                            }
                            else {
                                detailsHTML.push('<td><a class="pwx_result_link" onClick="pwx_launch_vitals_result_graphing(', param2, ',', recordData.ORDER_LIST[y].RESLIST[z].EVENT_CD, ',0,', js_criterion.CRITERION.PRSNL_ID, ',', js_criterion.CRITERION.POSITION_CD, ',', js_criterion.CRITERION.PPR_CD, ')">', recordData.ORDER_LIST[y].RESLIST[z].RESULT_NAME, '</a></td>')
                            }
                            detailsHTML.push('<td>', resDisp, '</td>')
                            detailsHTML.push('</tr>')
                        }
                        detailsHTML.push('</table></dl>')

                    }
                    else {
                        detailsHTML.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><td><span class="pwx_grey">',amb_i18n.NO_RESULTS,'</span></td></tr></table></dl>')
                    }
                }
                MP_ModalDialog.deleteModalDialogObject("OrderResultsModal")
                var orderResultModal = new ModalDialog("OrderResultsModal")
                    .setHeaderTitle(amb_i18n.ORDER_RESULTS + ' (' + recordData.ORDER_LIST.length + ')')
                    .setTopMarginPercentage(15)
                    .setRightMarginPercentage(30)
                    .setBottomMarginPercentage(15)
                    .setLeftMarginPercentage(30)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                orderResultModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="pwx_task_detail_no_pad"><p class="pwx_small_text">' + detailsHTML.join("") + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
                orderResultModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(orderResultModal);
                MP_ModalDialog.showModalDialog("OrderResultsModal")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", "^" + param1 + "^", param2 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

//create the result viewer launch function
pwx_result_view_launch = function (persId, eventId) {
    var pwxPVViewerMPage = window.external.DiscernObjectFactory('PVVIEWERMPAGE');
    pwxPVViewerMPage.CreateEventViewer(persId);
    pwxPVViewerMPage.AppendEvent(eventId);
    pwxPVViewerMPage.LaunchEventViewer();
}

function pwx_launch_vitals_result_graphing(personId, eventCd, groupID, userId, positionCd, pprCd) {
    //var js_criterion = JSON.parse(m_criterionJSON);
    var wParams = "left=0,top=0,width=1200,height=700,toolbar=no";
    var sParams = "^MINE^," + personId + ".0,0.0," + eventCd + ".0,^I:\\WININTEL\\static_content\\MasterSummary_V4\\discrete-graphing^," + groupID + ".0," + userId + ".0," + positionCd + ".0," + pprCd + ".0,2,5,200,^Last 2 years for all visits^";
    var graphCall = "javascript:CCLLINK('mp_retrieve_graph_results', '" + sParams + "',1)";
    //MP_Util.LogCclNewSessionWindowInfo(null, graphCall, "mp_core.js", "GraphResults");
    javascript: CCLNEWSESSIONWINDOW(graphCall, "_self", wParams, 0, 1);

}

function isIntegerorFloat(str) {
    var intRegex = /^\d+$/;
    var floatRegex = /^((\d+(\.\d *)?)|((\d*\.)?\d+))$/;
    if (intRegex.test(str) || floatRegex.test(str)) {
        return true;
    }
    else {
        return false;
    }
}
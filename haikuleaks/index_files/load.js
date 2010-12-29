/** FlattrLoader */

var FlattrLoader = {

	instance: false,
	queryString: false,
	validParams: ['mode', 'https', 'uid', 'category', 'button', 'language'],
	validButtonParams: ['uid', 'category', 'button', 'language', 'hidden', 'tags', 'title', 'url', 'description'],
	options: {},

	addLoadEvent: function(func) {

		if (document.readyState == 'complete') {
			return func();
		}
	
		if (window.addEventListener) {
			window.addEventListener("load", func, true);
		} else if (window.attachEvent) {
			window.attachEvent("onload", func);
		} else {
		
			if ( window.onload != null ) {
				var oldOnload = window.onload;
				window.onload = function ( e ) {
					oldOnload( e );
					func();
				};
		    }
			else {
				window.onload = func;
			}

		}

	},

	createIframe: function(data) {

		var compact = false;
		if (data.button == 'compact') {
			var compact = true;
		}

		var iframe = document.createElement('iframe');
		iframe.setAttribute('src', ( this.getParam('https') == 1 ? 'https' : 'http' ) +'://'+ this.getParam('domain', 'api.flattr.com') + '/button/view/?'+ this.encodeData(data));
		iframe.setAttribute('width', (compact == true ? 110 : 55) );
		iframe.setAttribute('height', (compact == true ? 20 : 62) );
		iframe.setAttribute('frameBorder', 0);
		iframe.setAttribute('scrolling', 'no');
		iframe.setAttribute('border', 0);
		iframe.setAttribute('marginHeight', 0);
		iframe.setAttribute('marginWidth', 0);
		iframe.setAttribute('allowTransparency', 'true');

		return iframe;
	},

	encodeData: function(data) {
	
		var result = '';
		
		for (prop in data) {
			
			var value = data[prop];
			
			if (prop == 'description') {
				value = this.stripTags(value, '<br>');
				if (value.length > 1000) {
					value = value.substring(0, 1000);
				}
			}

			value = value.replace(/^\s+|\s+$/g, '').replace(/\s{2,}|\t+/g, ' ');
			result += prop + '=' + encodeURIComponent(value) + '&';
		}

		return result;
	},

	getParam: function (key, defaultValue)
	{		
		if ( key in this.options ) {
			return this.options[key];
		}

	    return defaultValue;
	},

	init: function() {

		try
		{
			var scripts = document.getElementsByTagName("script");

			for (var i = (scripts.length - 1); i >= 0; i--) {

				var instance = scripts[ i ];

				if (!instance.hasAttribute('src')) {
					continue;
				}

				var src = instance.getAttribute('src');	
				var re = new RegExp('^(http(?:s?))://(api\.(?:.*\.?)flattr\.(?:com|local))', 'i');

				var result = src.match(re);
				if (result) {

					this.options['domain'] = result[2].toString();
					this.options['https']  = (result[1].toString() == 'https' ? 1 : 0);
	
					var pos = src.indexOf('?');
					if (pos) {
						var qs = src.substring(++pos);

					    var params = qs.split("&");
					    for (var i = 0; i < params.length; i++) {
					        var pair = params[i].split("=");

					        if (this.validParam(pair[0], this.validParams)) {
					        	this.options[pair[0]] = pair[1];
					        }
					    }
					}

					this.instance = instance;
					break;
				}

			}
		}
		catch(e)
		{
			// ge fel
		}

		switch(this.getParam('mode', 'manual')) {

			case 'direct': this.render(); break;

			case 'auto':
			case 'automatic':
					var that = this;

					this.addLoadEvent(function() {
						that.setup();
					});
				break;

			case 'manual':
			default:
		}

	},

	loadButton: function(elm) {

		var data = {};

		for (prop in this.options) {
			if (this.validParam(prop, this.validButtonParams)) {
				data[prop] = this.options[prop];
			}
		}

		if (elm.getAttribute('href')) {
			data.url = elm.getAttribute('href');
		}

		if (elm.getAttribute('title')) {
			data.title = elm.getAttribute('title');
		}
			
		if (elm.getAttribute('lang')) {
			data.language = elm.getAttribute('lang');
		}

		if (elm.innerHTML) {
			data.description = elm.innerHTML;
		}

		if (elm.getAttribute('rev')) {
			var rev = elm.getAttribute('rev');
			if (rev.substring(0, 6) == 'flattr') {

				rev = rev.substring(7).split(';');
				for (var i = 0; i < rev.length; i++) {
					var pair = rev[i].split(":");

					if (this.validParam(pair[0], this.validButtonParams)) {
						data[pair[0]] = pair[1];
					}
				}
			}
		}

		this.replaceWith(elm, this.createIframe(data));
	},

	render: function(options, target, position) {

		var data = {};
		for (prop in this.options) {
			if (this.validParam(prop, this.validButtonParams)) {
				data[prop] = this.options[prop];
			}
		}

		try
		{
			if (options) {
				for (prop in options) {
					if (this.validParam(prop, this.validButtonParams)) {
						data[prop] = options[prop];
					}
				}
			} else {

				if (window['flattr_uid']) { data.uid = flattr_uid; }
				if (window['flattr_url']) { data.url = flattr_url; }
				if (window['flattr_btn']) { data.button = flattr_btn; }
				if (window['flattr_hide']) { data.hidden = (flattr_hide == true ? 1 : 0); }
				if (window['flattr_cat']) { data.category = flattr_cat; }
				if (window['flattr_tag']) { data.tags = flattr_tag; }
				if (window['flattr_lng']) { data.language = flattr_lng; }
				if (window['flattr_tle']) { data.title = flattr_tle; }
				if (window['flattr_dsc']) { data.description = flattr_dsc; }

			}
			
			var frame = this.createIframe(data);
	
			if (target) {
				
				if (typeof(target) == 'string') {
					target = document.getElementById(target);
					if (!target) {
						// ge fel
					}
				}

				switch(position) {
					case 'before':
							target.parentNode.insertBefore(frame, target);
						break;
					case 'replace':
							this.replaceWith(target, frame);
						break;
					case 'append':
					default:
							target.appendChild(frame);
						break;
				}
				
			} else {
				
				if (this.getParam('mode', 'manual') == 'direct') {

					this.replaceWith(this.instance, this.createIframe(data));

				} else {
					// ge fel
				}
				
			}

		}
		catch(e)
		{
			// ge fel
		}

	},

	replaceWith: function (old, content)
	{
		if (typeof content == 'string') {

			if ('outerHTML' in document.documentElement) {
				old.outerHTML = content;
			}
			else {
				var range = document.createRange();
				range.selectNode(old);
				content = range.createContextualFragment(content);

				old.parentNode.replaceChild(content, old);
			}
		}

		var parent = old.parentNode;
		parent.replaceChild(content, old);
	},

	setup: function() {

		var btns = document.getElementsByTagName('a');
		for(var i = (btns.length - 1); i >= 0 ; i--) {
			if (/FlattrButton/.test(btns[i].className)) {
				this.loadButton(btns[i]);
			}
		}

	},

	stripTags: function(str, allowed_tags) {
	
	    var key = '', allowed = false;
	    var matches = [];
	    var allowed_array = [];
	    var allowed_tag = '';
	    var i = 0;
	    var k = '';
	    var html = '';
	
	    var replacer = function (search, replace, str) {
	        return str.split(search).join(replace);
	    };
	
	    // Build allowed tags associative array
	    if (allowed_tags) {
	        allowed_array = allowed_tags.match(/([a-zA-Z0-9]+)/gi);
	    }
	
	    str += '';
	
	    // Match tags
	    matches = str.match(/(<\/?[\S][^>]*>)/gi);
	
	    // Go through all HTML tags
	    for (key in matches) {
	        if (isNaN(key)) {
	            // IE7 Hack
	            continue;
	        }
	
	        // Save HTML tag
	        html = matches[key].toString();
	
	        // Is tag not in allowed list? Remove from str!
	        allowed = false;
	
	        // Go through all allowed tags
	        for (k in allowed_array) {
	            // Init
	            allowed_tag = allowed_array[k];
	            i = -1;
	
	            if (i != 0) { i = html.toLowerCase().indexOf('<'+allowed_tag+'>');}
	            if (i != 0) { i = html.toLowerCase().indexOf('<'+allowed_tag+' ');}
	            if (i != 0) { i = html.toLowerCase().indexOf('</'+allowed_tag)   ;}
	
	            // Determine
	            if (i == 0) {
	                allowed = true;
	                break;
	            }
	        }
	
	        if (!allowed) {
	            str = replacer(html, "", str); // Custom replace. No regexing
	        }
	    }
	
	    return str;
	},
	
	validParam: function(key, arr) {
		
		for (var i = 0; i < arr.length; i++) {
			if ( arr[i] == key ) {
				return true;
			}
		}
		
		return false;
	}
	
};
FlattrLoader.init();

var con = new SimpleConsole({
	handleCommand: handle_command,
	placeholder: "Enter commands or expressions",
	storageID: "ooplie"
});
document.body.appendChild(con.element);

// con.logHTML(
// 	"<h1>Welcome to <a href='https://github.com/1j01/ooplie'>Ooplie!</a></h1>" +
// 	"<p>Try entering <code>5 + 5</code> below. Or some faces.</p>"
// );

var Ooplie = typeof require !== "undefined" ? require("../ooplie") : self.Ooplie;

var context = new Ooplie.Context({console: con});

var parts_menu_button = con.addPopupButton(update_parts_menu);
parts_menu_button.classList.add("parts-menu-button");
parts_menu_button.setAttribute("title", "Parts menu");

var parts_menu = parts_menu_button.popup;
parts_menu.classList.add("parts-menu");

var get_parts_menu_icon_svg_markup = function update_parts_menu(unescaped_style){
	// TODO: do this in a simpler way with React or whatever
	// var view_box = inline ? ("0 14.61 92 "+(92 - 14.61)) : "0 0 92 92";
	// return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="' + view_box + '" style="height: 1em;">' +
	return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 92 92"'+ (unescaped_style ? ' style="' + unescaped_style + '"' : '') + '>' +
		'<rect width="91.96" height="51.79" x=".02" y="25.6" rx="4" fill="currentColor"/>' +
		'<rect width="26.43" height="21.43" x="53.94" y="14.61" rx="4" fill="currentColor"/>' +
		'<rect width="26.43" height="21.43" x="11.62" y="14.61" rx="4" fill="currentColor"/>' +
	'</svg>';
};
	
parts_menu_button.innerHTML = get_parts_menu_icon_svg_markup();

var accordion_state = {};

function update_parts_menu(){
	parts_menu.innerHTML = "";
	
	for(var i = 0; i < context.libraries.length; i++){
		var library = context.libraries[i];
		
		var library_section = document.createElement("section");
		library_section.classList.add("library");
		library_section.id = library.name.replace(/\W/g, "") + "-library";
		
		var library_header = document.createElement("h1");
		library_header.classList.add("library-header");
		library_header.textContent = library.name;
		library_section.appendChild(library_header);
		
		var library_content = document.createElement("div");
		library_content.classList.add("library-content");
		library_section.appendChild(library_content);
		
		for(var j = 0; j < library.patterns.length; j++){
			var pattern = library.patterns[j];
			var pattern_el = document.createElement("p");
			pattern_el.classList.add("pattern");
			
			var matcher = pattern.prefered_matcher;
			for(var k = 0; k < matcher.length; k++){
				var segment = matcher[k];
				if(segment.type !== "punctuation" || !segment.value.match(/[?:;,.]/)){
					pattern_el.appendChild(document.createTextNode(" "));
				}
				if(segment.type === "variable"){
					var var_el = document.createElement("var");
					var_el.textContent = segment.name;
					pattern_el.appendChild(var_el);
				}else{
					pattern_el.appendChild(document.createTextNode(segment.value));
				}
			}
			
			library_content.appendChild(pattern_el);
		}
		for(var j = 0; j < library.operators.length; j++){
			var operator = library.operators[j];
			var operator_el = document.createElement("div");
			operator_el.classList.add("operator");
			
			if(operator.binary){
				var var_el = document.createElement("var");
				var_el.textContent = "a";
				operator_el.appendChild(var_el);
				operator_el.appendChild(document.createTextNode(" "));
			}
			
			var matcher = operator.prefered_matcher;
			var segment = matcher[0];
			operator_el.appendChild(document.createTextNode(segment.value));
			
			operator_el.appendChild(document.createTextNode(" "));
			
			var var_el = document.createElement("var");
			var_el.textContent = "b";
			operator_el.appendChild(var_el);
			
			if(j !== 0){
				var separator_el = document.createElement("hr");
				separator_el.classList.add("separator");
				library_content.appendChild(separator_el);
			}
			
			library_content.appendChild(operator_el);
		}
		var constants_by_value = new Map;
		for(var constant_name in library.constants){
			var constant_value = library.constants[constant_name];
			if(constants_by_value.has(constant_value)){
				constants_by_value.set(constant_value, [constant_name].concat(constants_by_value.get(constant_value)));
			}else{
				constants_by_value.set(constant_value, [constant_name]);
			}
		}
		var is_first_consant = true;
		for(var [constant_value, constant_names] of constants_by_value){
			
			if(!is_first_consant){
				var separator_el = document.createElement("hr");
				separator_el.classList.add("separator");
				library_content.appendChild(separator_el);
				library_content.appendChild(document.createTextNode(" "));
			}
			
			var constant_el = document.createElement("div");
			constant_el.classList.add("constant");
			
			for(var k=0; k<constant_names.length; k++){
				var constant_name = constant_names[k];
				if(k !== 0){
					constant_el.appendChild(document.createTextNode(" = "));
				}
				constant_el.appendChild(document.createTextNode(constant_name));
			}
			if(constant_names.indexOf("" + constant_value) === -1){
				constant_el.appendChild(document.createTextNode(" = "));
				constant_el.appendChild(document.createTextNode(constant_value));
			}
			
			library_content.appendChild(constant_el);
			
			is_first_consant = false;
		}
		parts_menu.appendChild(library_section);
	}
	
	var accordion = new Accordion(parts_menu, {
		onToggle: function(fold, is_open){
			accordion_state[fold.el.id] = is_open;
			try{
				localStorage["ooplie-parts-menu-accordion-state"] = JSON.stringify(accordion_state);
			}catch(e){}
		}
	});
	
	try{
		accordion_state = JSON.parse(localStorage["ooplie-parts-menu-accordion-state"]);
	}catch(e){}
	
	var headers = parts_menu.querySelectorAll("h1");
	for(var i=0; i<headers.length; i++){
		if(accordion_state[headers[i].parentElement.id] !== false){
			headers[i].click();
		}
	}
	// TODO: fix ugly animations when opening or resizing across the css break point

};
// TODO: add extra information about patterns, like alternate phrasings, maybe descriptions?

var meta_theme_color = document.createElement("meta");
meta_theme_color.setAttribute("name", "theme-color");
document.head.appendChild(meta_theme_color);

var set_theme = function(theme){
	document.body.className = theme;
	var theme_color = getComputedStyle(document.body).backgroundColor;
	meta_theme_color.setAttribute("content", theme_color);
	try{
		localStorage.ooplie_console_theme = theme;
	}catch(e){}
};

var get_theme = function(){
	return document.body.className;
};

try{
	set_theme(localStorage.ooplie_console_theme || "light");
}catch(e){}

context.libraries.push(new Ooplie.Library("Ooplie Console", {patterns: [
	new Ooplie.Pattern({
		match: [
			"Open the parts menu",
			"Show the parts menu",
			"Open parts menu",
			"Show parts menu"
		],
		bad_match: [
			"Open the parts drawer",
			"Show the parts drawer",
			"Open parts drawer",
			"Show parts drawer"
		],
		fn: function(){
			parts_menu_button.openPopup();
		}
	}),
	
	new Ooplie.Pattern({
		match: [
			"Close the parts menu",
			"Hide the parts menu",
			"Close parts menu",
			"Hide parts menu"
		],
		bad_match: [
			"Close the parts drawer",
			"Hide the parts drawer",
			"Close parts drawer",
			"Hide parts drawer"
		],
		fn: function(){
			parts_menu_button.closePopup();
		}
	}),
	
	new Ooplie.Pattern({
		match: [
			"Toggle the parts menu",
			"Toggle parts menu"
		],
		bad_match: [
			"Show/hide the parts menu",
			"Show/hide parts menu",
			"Toggle the parts drawer",
			"Show/hide the parts drawer",
			"Toggle parts drawer",
			"Show/hide parts drawer"
		],
		fn: function(){
			parts_menu_button.togglePopup();
		}
	}),
	
	new Ooplie.Pattern({
		match: [
			"Report an issue with Ooplie",
			"Report an issue",
			"Report a bug with Ooplie",
			"Report a bug",
			"Open an issue with Ooplie",
			"Open an issue",
			"Open an issue report with Ooplie",
			"Open an issue report",
			"Open a bug report with Ooplie",
			"Open a bug report",
			"File an issue with Ooplie",
			"File an issue",
			"File an issue report with Ooplie",
			"File an issue report",
			"File a bug with Ooplie",
			"File a bug",
			"File a bug report with Ooplie",
			"File a bug report"
		],
		// TODO: maybe_match "report a bug" etc.
		maybe_match: [
			"oh man",
			"wtf",
			"wut",
			"hey!",
			"um",
			"um..."
		],
		bad_match: [
			"That's a bug",
			"That's not right",
			"That's weird",
			"That was weird",
			"Report a bug on Ooplie",
			"Report an issue on Ooplie",
			"Open an issue on Ooplie",
			"I found a bug",
			"I think I found a bug",
			"I think that's a bug"
		],
		fn: function(){
			con.logHTML("<a href='https://github.com/1j01/ooplie/issues/new' target='_blank'>https://github.com/1j01/ooplie/issues/new</a>");
		}
	}),
	
	new Ooplie.Pattern({
		// TODO: have a command "go to"/"open"
		// and define constants for "this repo on GitHub" etc.
		// also constants should be able to have matchers
		match: [
			"Go to this repo",
			"Go to this repo on GitHub",
			"Go to this repository",
			"Go to this repository on GitHub",
		],
		bad_match: [
			"Go to GitHub",
			"Open GitHub",
			"Open the repo",
			"Open this repo",
			"Open the repository",
			"Open this repository",
			"Open the repo on GitHub",
			"Open this repo on GitHub",
			"Open the repository on GitHub",
			"Open this repository on GitHub"
		],
		fn: function(){
			con.logHTML("<a href='https://github.com/1j01/ooplie' target='_blank'>https://github.com/1j01/ooplie</a>");
			// TODO: maybe output "Opening <linky link>" and call window.open()
		}
	}),
	
	new Ooplie.Pattern({
		match: [
			"Report an issue with this console",
			"Report a bug with this console",
			"Open an issue with this console",
			"Open an issue report with this console",
			"Open a bug report with this console",
			"File an issue with this console",
			"File an issue report with this console",
			"File a bug with this console",
			"File a bug report with this console",
			
			"Report an issue with the console",
			"Report a bug with the console",
			"Open an issue with the console",
			"Open an issue report with the console",
			"Open a bug report with the console",
			"File an issue with the console",
			"File an issue report with the console",
			"File a bug with the console",
			"File a bug report with the console"
		],
		// TODO: maybe_match "report a bug" etc.
		fn: function(){
			con.logHTML("<a href='https://github.com/1j01/simple-console/issues/new' target='_blank'>https://github.com/1j01/simple-console/issues/new</a>");
		}
	}),
	
	// TODO: switching to light/dark should use a single command
	// but it would be good to have the actual options appear in the parts menu

	// TODO: maybe have a "Toggle dark theme" command
	// and/or "Toggle theme", "Change theme", "Choose a theme"
	// (maybe more themes but whatever)

	new Ooplie.Pattern({
		match: [
			"Switch to dark theme",
			"Switch to the dark theme",
			"Switch theme to dark",
			"Switch the theme to dark",
			"Switch style to dark",
			"Switch the style to dark",
			"Switch to dark style",
			"Switch to dark the style",
			"Switch to dark mode", // TODO: "Already in dark mode"?
			"Use dark theme",
			"Use the dark theme",
			"Use dark mode", // TODO: "Already in dark mode"?
			"Set theme to dark",
			"Set theme dark",
			"Set the theme to dark",
			"Set style to dark",
			"Set the style to dark",
			"Choose theme dark",
			"Choose dark theme",
			"theme dark"
		],
		bad_match: [
			"Use the dark style",
			"Use the dark styles",
			"Use the dark stylesheet",
			"dark theme",
			"dark mode"
		],
		fn: function(){
			var previous_theme = get_theme();
			set_theme("dark");
			if(previous_theme !== "dark"){
				con.log("Theme set to dark.");
			}else{
				con.log("Already using dark theme.");
			}
		}
	}),

	new Ooplie.Pattern({
		match: [
			"Switch to light theme",
			"Switch to the light theme",
			"Switch theme to light",
			"Switch the theme to light",
			"Switch style to light",
			"Switch the style to light",
			"Switch to light style",
			"Switch to light the style",
			"Switch to light mode", // TODO: "Already in light mode"?
			"Use light theme",
			"Use light mode", // TODO: "Already in light mode"?
			"Use the light theme",
			"Set theme to light",
			"Set theme light",
			"Set the theme to light",
			"Set style to light",
			"Set the style to light",
			"Choose theme light",
			"Choose light theme",
			"theme light"
		],
		bad_match: [
			"Use the light style",
			"Use the light styles",
			"Use the light stylesheet",
			"light theme",
			"light mode"
		],
		fn: function(){
			var previous_theme = get_theme();
			set_theme("light");
			if(previous_theme !== "light"){
				con.log("Theme set to light.");
			}else{
				con.log("Already using light theme.");
			}
		}
	})

]}));

function handle_command(input){
	// Conversational trivialities
	var log_emoji = function(face, rotate_direction){
		// top notch emotional mirroring
		var span = document.createElement("span");
		span.style.display = "inline-block";
		span.style.transform = "rotate(" + (rotate_direction / 4) + "turn)";
		span.style.cursor = "vertical-text";
		span.style.fontSize = "1.3em";
		span.innerText = face.replace(">", "〉").replace("<", "〈");
		con.log(span);
	};
	var user_used_upper_case = input.match(/\s*^[A-Z]/);
	var maybe_use_title_case = function(str){
		if(user_used_upper_case){
			return str.charAt(0).toUpperCase() + str.slice(1);
		}else{
			return str;
		}
	};
	var choose_from = function(arr){
		return arr[~~(Math.random() * arr.length)];
	};
	var stripped_input = input.replace(/^\s*((Okay|Well|Uh|Um|So),? )*/i, ""); // input_sans_basic_discourse_markers
	if(input.match(/^((Okay|Well|Uh|Um|So|Yo|Hey),? )*(What'?s up|Sup|What up|Whaddup|What?'?s goin.? on)/i)){
		con.log(maybe_use_title_case("not much") + (user_used_upper_case ? "." : ""));
	}else if(stripped_input.match(/(How'?s? ?it hangin|How('?re| a) (you|u) doin)/i)){
		con.log(maybe_use_title_case(choose_from(["pretty good", "swell", "10/10 tbh"])));
	}else if(stripped_input.match(/^(Hi|Hello|Hey|Greetings|Hola|Yo)/i)){
		con.log(maybe_use_title_case(choose_from(["hello", "hi"])) + (input.match(/\.|!/) ? "!" : ""));
	}else if(stripped_input.match(/^(bye|good.?bye|fare.?well|too?-?da?-?le?-?oo|so long)/i)){
		con.log(maybe_use_title_case(choose_from(["goodbye", "bye", "farewell", "toodaloo, my sweet and deerest aquatence person"])) + (input.match(/\.|!/) ? "!" : ""));
	}else if(stripped_input.match(/^(nice|cool|sweet|awesome|neat)[\.!]*$/i)){
		con.log(maybe_use_title_case(input.match(/nice/i) ? "noice" : stripped_input) + (input.match(/\.|!/) ? "!" : ""));
	}else if(stripped_input.match(/^So[\.!]*$/i)){
		con.log(maybe_use_title_case("so..."));
	}else if(input.match(/^\s*((Well|Uh|Um),? )*(okay|'?kay|k|ok)(,? then)?[\.!]*$/i)){
		con.log(input.replace(/^\s*((Well|Uh|Um),? )*/i, ""));
	}else if(input.match(/^(>?[:;8X]-?[()O03PCDS])$/i)){
		log_emoji(input, +1);
	}else if(input.match(/^([D()O0C]-?[:;8X]<?)$/i)){
		log_emoji(input, -1);
	}else if(input.match(/^<3$/i)){
		con.log("❤");
	// Help
	}else if(input.match(/^(!*\?+!*|(please |plz )?(((I )?(want|need)[sz]?|display|show( me)?|view) )?(the |some )?help|^(gimme|give me|lend me) ((the |some )?)help| a hand( here)?)/i)){ // overly comprehensive, much?
		con.logHTML(
			"Open the <b>" + get_parts_menu_icon_svg_markup("height: 1em; margin-bottom: -0.1em; margin-right: 0.2em") + "parts menu</b> " +
			"to see commands and expressions you can use. " +
			"Note that there are often many synoynms for a command."
			// synonyms AKA alternate syntaxes, to give a synonym
			// so a command for listing command synonyms might have synonyms
			// "List synonyms for X"
			// "Show alternate syntaxes for X"
			// "Enumerate patterns for command X"
		);
	}else{
		var err;
		try{
			var result = context.eval(input);
		}catch(error){
			err = error;
		}
		if(err){
			con.error(err);
		}else if(result !== undefined){
			con.log(result);
			con.getLastEntry().classList.add("result");
		}
	}
}

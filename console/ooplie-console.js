
var con = new SimpleConsole({
	handleCommand: handle_command,
	placeholder: "Enter JavaScript or ASCII emoji",
	storageID: "ooplie"
});
document.body.appendChild(con.element);

// con.logHTML(
// 	"<h1>Welcome to <a href='https://github.com/1j01/ooplie'>Ooplie!</a></h1>" +
// 	"<p>Try entering <code>5 + 5</code> below. Or some faces.</p>"
// );

var context = new Ooplie.Context({console: con});

var parts_menu_button = document.createElement("button");
parts_menu_button.classList.add("parts-menu-button");
con.input.parentElement.appendChild(parts_menu_button);
parts_menu_button.setAttribute("title", "Parts menu");

var parts_menu = document.createElement("div");
parts_menu.classList.add("parts-menu");
con.input.parentElement.appendChild(parts_menu);

var parts_menu_icon = document.createElement("img");
parts_menu_icon.classList.add("parts-menu-button");
parts_menu_button.appendChild(parts_menu_icon);
parts_menu_icon.src = "parts.svg";

var accordion_state = {};

var update_parts_menu = function(){
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
			// TODO: mark up variables with <var> tags
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
		parts_menu.appendChild(library_section);
	}
	
	var accordion = new Accordion(parts_menu, {
		onToggle: function(fold, is_open){
			accordion_state[fold.el.id] = is_open;
			localStorage["ooplie-parts-menu-accordion-state"] = JSON.stringify(accordion_state);
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
// TODO: display constants etc.

var open_parts_menu = function(){
	parts_menu.style.display = "block";
	update_parts_menu();
};

var close_parts_menu = function(){
	parts_menu.style.display = "none";
};

var parts_menu_is_open = function(){
	return parts_menu.style.display === "block";
};

var toggle_parts_menu = function(){
	if(parts_menu_is_open()){
		close_parts_menu();
	}else{
		open_parts_menu();
	}
};

close_parts_menu();

parts_menu_button.addEventListener("click", function(e){
	toggle_parts_menu();
});

parts_menu_button.addEventListener("keydown", function(e){
	if(e.keyCode === 40){ // Down
		if(!parts_menu_is_open()){
			open_parts_menu();
		}
		parts_menu.querySelector("h1").focus();
	}
});

// con.input.addEventListener("focus", function(e){
// 	close_parts_menu();
// });

// parts_menu.addEventListener("keydown", function(e){
// 	if(e.keyCode === 38){ // Up
// 		if(document.activeElement === parts_menu.querySelector("h1")){
// 			parts_menu_button.focus();
// 		}
// 	}
// });

addEventListener("keydown", function(e){
	if(parts_menu_is_open()){
		if(e.keyCode === 27){
			e.preventDefault();
			close_parts_menu();
		}
	}
});

// addEventListener("mousedown", function(e){
// 	if(parts_menu_is_open()){
// 		if(!e.target.closest(".parts-menu-button, .parts-menu")){
// 			e.preventDefault();
// 			close_parts_menu();
// 		}
// 	}
// });

// TODO: use a Library so these commands can show up in the parts menu
// what should the library be called? "Ooplie Console"?
// "Console" is already a thing, but should it just be in the same category?
// context.loadLibrary(new Library());
// context.libraries.push(new Ooplie.Library());

context.patterns.push(new Ooplie.Pattern({
	match: [
		"Open the parts menu",
		"Show the parts menu"
	],
	bad_match: [
		"Open the parts drawer",
		"Show the parts drawer"
	],
	fn: function(){
		open_parts_menu();
	}
}));

context.patterns.push(new Ooplie.Pattern({
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
	maybe_match: [
		"oh man",
		"wtf",
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
}));
context.patterns.push(new Ooplie.Pattern({
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
		con.logHTML("<a href='https://github.com/1j01/ooplie/issues/new' target='_blank'>https://github.com/1j01/ooplie/issues/new</a>");
		// TODO: maybe output "Opening <linky link>" and call window.open()
	}
}));
context.patterns.push(new Ooplie.Pattern({
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
	// TODO: maybe have maybe_match(ers) for "report a bug" etc.
	// TODO: "action" for things that only "do"
	// to avoid logging "undefined" all the time
	fn: function(){
		con.logHTML("<a href='https://github.com/1j01/simple-console/issues/new' target='_blank'>https://github.com/1j01/simple-console/issues/new</a>");
	}
}));

// TODO: add command to set the theme to light or dark

// TODO: avoid logging "undefined" all the time
function handle_command(command){
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
	if(command.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)){
		con.log((command.match(/^[A-Z]/) ? "Hello" : "hello") + (command.match(/\.|!/) ? "." : ""));
	}else if(command.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)){
		con.log((command.match(/^[A-Z]/) ? "Not much" : "not much") + (command.match(/\?|!/) ? "." : ""));
	}else if(command.match(/^(>?[:;8X]-?[()O03PCDS])$/i)){
		log_emoji(command, +1);
	}else if(command.match(/^([D()O0C]-?[:;8X]<?)$/i)){
		log_emoji(command, -1);
	}else if(command.match(/^<3$/i)){
		con.log("❤");
	// Unhelp
	}else if(command.match(/^(!*\?+!*|(please |plz )?(((I )?(want|need)[sz]?|display|show( me)?|view) )?(the |some )?help|^(gimme|give me|lend me) ((the |some )?)help| a hand( here)?)/i)){ // overly comprehensive, much?
		con.log("Sorry, I can't help."); // TODO: recommend the parts menu at least
	}else{
		var err;
		try{
			var result = context.eval(command);
		}catch(error){
			err = error;
		}
		if(err){
			con.error(err);
		}else{
			con.log(result).classList.add("result");
		}
	}
};

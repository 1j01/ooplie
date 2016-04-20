
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

// context.loadLibrary(new Library());
// context.libraries.push(new Ooplie.Library());

context.patterns.push(new Ooplie.Pattern({
	match: [
		"report an issue with Ooplie",
		"report an issue",
		"report a bug with Ooplie",
		"report a bug",
		"open an issue with Ooplie",
		"open an issue",
		"open an issue report with Ooplie",
		"open an issue report",
		"open a bug report with Ooplie",
		"open a bug report",
		"file an issue with Ooplie",
		"file an issue",
		"file an issue report with Ooplie",
		"file an issue report",
		"file a bug with Ooplie",
		"file a bug",
		"file a bug report with Ooplie",
		"file a bug report"
	],
	maybe_match: [
		"oh man",
		"wtf",
		"hey!",
		"um",
		"um..."
	],
	bad_match: [
		"that's a bug",
		"that's not right",
		"that's weird",
		"that was weird",
		"report a bug on Ooplie",
		"report an issue on Ooplie",
		"open an issue on Ooplie",
		"I found a bug",
		"I think I found a bug",
		"I think that's a bug"
	],
	// TODO: "action" for things that only "do"
	// to avoid logging "undefined" all the time
	fn: function(){
		con.logHTML("<a href='https://github.com/1j01/ooplie/issues/new' target='_blank'>https://github.com/1j01/ooplie/issues/new</a>");
	}
}));
context.patterns.push(new Ooplie.Pattern({
	// TODO: have a command "go to"/"open"
	// and define constants for "this repo on GitHub" etc.
	// also constants should be able to have matchers
	match: [
		"go to this repo",
		"go to this repo on GitHub",
		"go to this repository",
		"go to this repository on GitHub",
	],
	bad_match: [
		"go to GitHub",
		"open GitHub",
		"open the repo",
		"open this repo",
		"open the repository",
		"open this repository",
		"open the repo on GitHub",
		"open this repo on GitHub",
		"open the repository on GitHub",
		"open this repository on GitHub"
	],
	fn: function(){
		con.logHTML("<a href='https://github.com/1j01/ooplie/issues/new' target='_blank'>https://github.com/1j01/ooplie/issues/new</a>");
		// TODO: maybe output "Opening <linky link>" and call window.open()
	}
}));
context.patterns.push(new Ooplie.Pattern({
	match: [
		"report an issue with this console",
		"report a bug with this console",
		"open an issue with this console",
		"open an issue report with this console",
		"open a bug report with this console",
		"file an issue with this console",
		"file an issue report with this console",
		"file a bug with this console",
		"file a bug report with this console",
		
		"report an issue with the console",
		"report a bug with the console",
		"open an issue with the console",
		"open an issue report with the console",
		"open a bug report with the console",
		"file an issue with the console",
		"file an issue report with the console",
		"file a bug with the console",
		"file a bug report with the console"
	],
	// TODO: maybe have maybe_match(ers) for "report a bug" etc.
	// TODO: "action" for things that only "do"
	// to avoid logging "undefined" all the time
	fn: function(){
		con.logHTML("<a href='https://github.com/1j01/simple-console/issues/new' target='_blank'>https://github.com/1j01/simple-console/issues/new</a>");
	}
}));

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
		con.log("Sorry, I can't help."); // TODO
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

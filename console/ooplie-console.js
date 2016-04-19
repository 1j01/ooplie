
var context = new Ooplie.Context({console: {clear: clear, log: log}});

var handle_command = function(command){
	// Conversational trivialities
	var log_emoji = function(face, rotate_direction){
		// top notch emotional mirroring
		var span = document.createElement("span");
		span.style.display = "inline-block";
		span.style.transform = "rotate(" + (rotate_direction / 4) + "turn)";
		span.style.cursor = "vertical-text";
		span.style.fontSize = "1.3em";
		span.innerText = face.replace(">", "〉").replace("<", "〈");
		log("").appendChild(span);
	};
	if(command.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)){
		log((command.match(/^[A-Z]/) ? "Hello" : "hello") + (command.match(/\.|!/) ? "." : ""));
	}else if(command.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)){
		log((command.match(/^[A-Z]/) ? "Not much" : "not much") + (command.match(/\?|!/) ? "." : ""));
	}else if(command.match(/^(>?[:;8X]-?[()O03PCDS])$/i)){
		log_emoji(command, +1);
	}else if(command.match(/^([D()O0C]-?[:;8X]<?)$/i)){
		log_emoji(command, -1);
	}else if(command.match(/^<3$/i)){
		log("❤");
	// Unhelp
	}else if(command.match(/^(!*\?+!*|(please |plz )?(((I )?(want|need)[sz]?|display|show( me)?|view) )?(the |some )?help|^(gimme|give me|lend me) ((the |some )?)help| a hand( here)?)/i)){ // overly comprehensive, much?
		log("Sorry, I can't help."); // TODO
	}else{
		var err;
		try{
			var result = context.eval(command);
		}catch(error){
			err = error;
		}
		if(err){
			var error_entry = log(err);
			error_entry.classList.add("error");
		}else{
			var result_entry = log(result);
			result_entry.classList.add("result");
		}
	}
};

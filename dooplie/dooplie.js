
var output = document.getElementById("ooplie-output");
var input = document.getElementById("ooplie-input");

var clear = function(){
	output.innerHTML = "";
};

var log = function(text){
	var was_scrolled_to_bottom = output.is_scrolled_to_bottom();
	
	var entry = document.createElement("div");
	entry.className = "entry";
	entry.innerText = entry.textContent = text;
	output.appendChild(entry);
	
	setTimeout(function(){
		if(was_scrolled_to_bottom){
			output.scroll_to_bottom();
		}
	});
	
	return entry;
};

var context = new Ooplie.Context({console: {clear: clear, log: log}});

var handle_command = function(command){
	// Conversational trivialities
	if(command.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)){
		log((command.match(/^[A-Z]/) ? "Hello" : "hello") + (command.match(/\.|!/) ? "." : ""));
	}else if(command.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)){
		log((command.match(/^[A-Z]/) ? "Not much" : "not much") + (command.match(/\?|!/) ? "." : ""));
	}else if(command.match(/^(>?[:;8X]-?[()O3PCDS]|[D()OC]-?[:;8X]<?)$/i)){
		log(command); // top notch emotional mirroring
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

output.is_scrolled_to_bottom = function(){
	return output.scrollTop + output.clientHeight >= output.scrollHeight
};

output.scroll_to_bottom = function(){
	output.scrollTop = output.scrollHeight;
};

var command_history = [];
var cmdi = command_history.length;

var load_command_history = function(){
	try{
		command_history = JSON.parse(localStorage.command_history);
		cmdi = command_history.length;
	}catch(e){}
};

var save_command_history = function(){
	try{
		localStorage.command_history = JSON.stringify(command_history);
	}catch(e){}
};

load_command_history();

input.addEventListener("keydown", function(e){
	if(e.keyCode === 13){ // Enter
		// if(!e.shiftKey){
			// @TODO: textarea?
		// }
		
		var command = input.value;
		if(command === ""){ return; }
		input.value = "";
		
		command_history.push(command);
		cmdi = command_history.length;
		save_command_history();
		
		var command_entry = log(command);
		command_entry.classList.add("input");
		var icon = document.createElement("span");
		icon.className = "octicon octicon-chevron-right";
		command_entry.insertBefore(icon, command_entry.firstChild);
		
		output.scroll_to_bottom();
		
		handle_command(command);
		
	}else if(e.keyCode === 38){ // Up
		input.value = (--cmdi < 0) ? (cmdi = -1, "") : command_history[cmdi];
		input.setSelectionRange(input.value.length, input.value.length);
		e.preventDefault();
	}else if(e.keyCode === 40){ // Down
		input.value = (++cmdi >= command_history.length) ? (cmdi = command_history.length, "") : command_history[cmdi];
		input.setSelectionRange(input.value.length, input.value.length);
		e.preventDefault();
	}else if(e.keyCode === 46 && e.shiftKey){ // Shift+Delete
		if(input.value === command_history[cmdi]){
			command_history.splice(cmdi, 1);
			cmdi = Math.max(0, cmdi - 1)
			input.value = command_history[cmdi] || "";
			save_command_history();
		}
		e.preventDefault();
	}
});

window.onerror = function(error_message, etc){
	var error_entry = log(error_message);
	error_entry.classList.add("error");
};

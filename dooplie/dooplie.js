
var output = document.createElement("div");
var input = document.createElement("input");

output.id = "ooplie-output";
input.id = "ooplie-input";

output.setAttribute("role", "log");
output.setAttribute("aria-live", "polite");
input.setAttribute("aria-label", "Enter commands or expressions");
input.setAttribute("placeholder", "Enter commands or expressions");
input.setAttribute("aria-controls", output.id);

document.body.appendChild(output);
document.body.appendChild(input);

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

var context = new OOPLiE.Context;

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
	if(e.keyCode === 13){
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
		
		output.scroll_to_bottom();
		
		context.interpret(command, function(err, result){
			if(err){
				var error_entry = log(err);
				error_entry.classList.add("error");
			}else{
				var result_entry = log(result);
				result_entry.classList.add("result");
			}
		});
		
	}else if(e.keyCode === 38){
		input.value = (--cmdi < 0) ? (cmdi = -1, "") : command_history[cmdi];
	}else if(e.keyCode === 40){
		input.value = (++cmdi >= command_history.length) ? (cmdi = command_history.length, "") : command_history[cmdi]
	}else if(e.keyCode === 46 && e.shiftKey){
		command_history.splice(cmdi, 1);
		input.value = command_history[--cmdi];
		save_command_history();
	}
});

window.onerror = function(error_message, etc){
	var error_entry = log(error_message);
	error_entry.classList.add("error");
};

// log("Welcome to OOPLiE").classList.add("welcome");

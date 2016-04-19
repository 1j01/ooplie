
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "Console", patterns: [
	
	new Pattern
		match: [
			"output <text>"
			"output <text> to the console"
			"log <text>"
			"log <text> to the console"
			"print <text>"
			"print <text> to the console"
			"say <text>"
		]
		bad_match: [
			"puts <text>"
			"println <text>"
			"print line <text>" # you can only output one or more lines
			"printf <text>"
			"console.log <text>"
			"writeln <text>"
			"output <text> to the terminal"
			"log <text> to the terminal"
			"print <text> to the terminal"
		]
		fn: (v, context)=>
			context.console.log v("text")
			return
	
	new Pattern
		match: [
			"clear the console"
			"clear console"
		]
		bad_match: [
			"clear the terminal"
			"clear terminal"
			"cls"
			"clr"
		]
		fn: (v, context)=>
			context.console.clear()
			return
	
]

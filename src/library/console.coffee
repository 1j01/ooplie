
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "Console", patterns: [
	
	new Pattern
		match: [
			"Output <text>"
			"Output <text> to the console"
			"Log <text>"
			"Log <text> to the console"
			"Print <text>"
			"Print <text> to the console"
			"Say <text>"
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
			"Clear the console"
			"Clear console"
		]
		bad_match: [
			"Clear the terminal"
			"Clear terminal"
			"clear"
			"cls"
			"clr"
		]
		fn: (v, context)=>
			context.console.clear()
			return
	
]

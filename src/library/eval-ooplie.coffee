
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "Ooplie Eval", patterns: [
	
	new Pattern
		match: [
			"Interpret <text> as English"
			"Run <text> as English"
			"Execute <text> as English"
			"Eval <text> as English"
			
			"Interpret <text> as Ooplie code"
			"Run <text> as Ooplie code"
			"Execute <text> as Ooplie code"
			"Eval <text> as Ooplie code"
			
			"Run code <text> with Ooplie"
			"Eval code <text> with Ooplie"
			"Execute code <text> with Ooplie"
			"Interpret code <text> with Ooplie"
			
			"Run Ooplie code <text>"
			"Eval Ooplie code <text>"
			"Execute Ooplie code <text>"
			"Interpret Ooplie code <text>"
			
			"Run English <text>"
			"Eval English <text>"
			"Execute English <text>"
			
			"Interpret <text> with Ooplie"
			"Run <text> with Ooplie"
			"Eval <text> with Ooplie"
			"Execute <text> with Ooplie"
		]
		bad_match: [
			"Run Ooplie <text>"
			"Eval Ooplie <text>"
			"Execute Ooplie <text>"
			"Interpret Ooplie <text>"
			
			"Run <text> as Ooplie"
			"Run code <text> as Ooplie"
			"Execute <text> as Ooplie"
			"Execute <text> as Ooplie"
			"Eval <text> as Ooplie"
			"Eval code <text> as Ooplie"
			"Run code <text> as English"
			
			"Run English code <text>"
			"Eval English code <text>"
			"Execute English code <text>"
			"Interpret English code <text>"
			"Run English code <text>"
			"Eval <text> as English code"
			"Execute English code <text>"
			"Interpret <text> as English code"
			
			"Make Ooplie Interpret <text>"
			"Have Ooplie Interpret <text>"
			"Let Ooplie Interpret <text>"
		]
		fn: (v, context)=>
			context.eval v("text")
	
]

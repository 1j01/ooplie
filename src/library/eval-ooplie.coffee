
Pattern = require "../Pattern"

module.exports = [
	
	new Pattern
		match: [
			"run code <text> with Ooplie"
			"eval code <text> with Ooplie"
			"execute code <text> with Ooplie"
			"interpret code <text> with Ooplie"
			
			"interpret <text> as English"
			"run <text> as English"
			"execute <text> as English"
			"eval <text> as English"
			
			"interpret <text> as Ooplie code"
			"run <text> as Ooplie code"
			"execute <text> as Ooplie code"
			"eval <text> as Ooplie code"
			
			"run Ooplie code <text>"
			"eval Ooplie code <text>"
			"execute Ooplie code <text>"
			"interpret Ooplie code <text>"
			
			"run English <text>"
			"eval English <text>"
			"execute English <text>"
			
			"run <text> with Ooplie"
			"eval <text> with Ooplie"
			"execute <text> with Ooplie"
			"interpret <text> with Ooplie"
		]
		bad_match: [
			"run Ooplie <text>"
			"eval Ooplie <text>"
			"execute Ooplie <text>"
			"interpret Ooplie <text>"
			
			"run <text> as Ooplie"
			"run code <text> as Ooplie"
			"execute <text> as Ooplie"
			"execute <text> as Ooplie"
			"eval <text> as Ooplie"
			"eval code <text> as Ooplie"
			"run code <text> as English"
			
			"run English code <text>"
			"eval English code <text>"
			"execute English code <text>"
			"interpret English code <text>"
			"run English code <text>"
			"eval <text> as English code"
			"execute English code <text>"
			"interpret <text> as English code"
			
			"make Ooplie interpret <text>"
			"have Ooplie interpret <text>"
			"let Ooplie interpret <text>"
		]
		fn: (v, context)=>
			context.eval v("text")
	
]

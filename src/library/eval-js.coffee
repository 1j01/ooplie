
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "JavaScript Eval", patterns: [
	
	new Pattern
		match: [
			"run JS <text>"
			"run JavaScript <text>"
			"run <text> as JS"
			"run <text> as JavaScript"
			"execute JS <text>"
			"execute JavaScript <text>"
			"execute <text> as JS"
			"execute <text> as JavaScript"
			"eval JS <text>"
			"eval JavaScript <text>"
			"eval <text> as JS"
			"eval <text> as JavaScript"
		]
		bad_match: [
			# TODO: these two should be maybe_matches
			# and eval-ooplie should have them defined as well
			# and it should ask you to disambiguate between them
			"eval <text>" # as what? (should the error message say something like "as what?"?)
			"execute <text>"
			"JavaScript <text>" # not sure JavaScript is a verb
			"JS <text>"
		]
		fn: (v, context)=>
			{console} = context # bring context's console into scope as "console"
			eval v("text")
	
]

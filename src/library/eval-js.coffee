
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "JavaScript Eval", patterns: [
	
	new Pattern
		match: [
			"Run JS <text>"
			"Run JavaScript <text>"
			"Run <text> as JS"
			"Run <text> as JavaScript"
			"Execute JS <text>"
			"Execute JavaScript <text>"
			"Execute <text> as JS"
			"Execute <text> as JavaScript"
			"Eval JS <text>"
			"Eval JavaScript <text>"
			"Eval <text> as JS"
			"Eval <text> as JavaScript"
		]
		bad_match: [
			# TODO: these two should be maybe_matches
			# and eval-ooplie should have them defined as well
			# and it should ask you to disambiguate between them
			"Eval <text>" # as what? (should the error message say something like "as what?"?)
			"Run <text>" # ditto
			"Execute <text>" # ditto
			"JavaScript <text>" # not sure JavaScript is a verb
			"JS <text>" # ditto
		]
		fn: (v, context)=>
			{console} = context # bring context's console into scope as "console"
			eval v("text")
	
]

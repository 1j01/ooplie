
Pattern = require "../Pattern"

module.exports = [
	
	# NOTE: If-else has to be above If, otherwise If will be matched first
	new Pattern
		# TODO: should be able to use <alt body> but spaces are converted to underscores
		match: [
			"If <condition>, <body>, else <alt_body>"
			"If <condition> then <body>, else <alt_body>"
			"If <condition> then <body> else <alt_body>"
			"<body> if <condition> else <alt_body>" # pythonic ternary
		]
		bad_match: [
			"if <condition>, then <body>, else <alt_body>"
			"if <condition>, then <body>, else, <alt_body>"
			"if <condition>, <body>, else, <alt_body>"
			# and other things; also this might be sort of arbitrary
			# comma misplacement should really be handled dynamically by the near-match system
		]
		fn: (v)=> if v("condition") then v("body") else v("alt_body")
	
	new Pattern
		match: [
			"If <condition>, <body>"
			"If <condition> then <body>"
			"<body> if <condition>"
		]
		fn: (v)=> v("body") if v("condition")
	
	new Pattern
		match: [
			"Unless <condition>, <body>"
			"Unless <condition> then <body>" # doesn't sound like good English
			"<body> unless <condition>"
		]
		fn: (v)=> v("body") unless v("condition")
	
]

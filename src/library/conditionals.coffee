
Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "Conditionals", patterns: [
	
	# NOTE: If-else has to be above If, otherwise If will be matched first
	new Pattern
		match: [
			"If <condition>, <body>, else <alt body>"
			"If <condition>, <body> else <alt body>"
			"If <condition> then <body>, else <alt body>"
			"If <condition> then <body> else <alt body>"
			"<body> if <condition> else <alt body>" # pythonic ternary
		]
		bad_match: [
			"if <condition>, then <body>, else <alt body>"
			"if <condition>, then <body>, else, <alt body>"
			"if <condition>, <body>, else, <alt body>"
			# and other things; also this might be sort of arbitrary
			# comma misplacement should really be handled dynamically by the near-match system
			"<condition> ? <body> : <alt body>"
			"unless <condition>, <alt body> else <body>"
			"unless <condition>, <alt body>, else <body>"
			"unless <condition> then <alt body>, else <body>"
			"unless <condition> then <alt body>, else, <body>"
			"unless <condition>, then <alt body>, else <body>"
			"unless <condition>, then <alt body>, else, <body>"
		]
		fn: (v)=> if v("condition") then v("body") else v("alt body")
	
	new Pattern
		match: [
			"If <condition>, <body>"
			"If <condition> then <body>"
			"<body> if <condition>"
		]
		fn: (v)=> v("body") if v("condition")
	
	new Pattern
		match: [
			"<body> unless <condition> in which case <alt body>"
			"<body>, unless <condition> in which case <alt body>"
			"<body> unless <condition>, in which case <alt body>"
			"<body>, unless <condition>, in which case <alt body>"
			"<body> unless <condition> in which case just <alt body>"
			"<body>, unless <condition> in which case just <alt body>"
			"<body> unless <condition>, in which case just <alt body>"
			"<body>, unless <condition>, in which case just <alt body>"
		]
		bad_match: [
			"Unless <condition>, <body>, else <alt body>"
			"Unless <condition> then <body>, else <alt body>"
			"Unless <condition> then <body> else <alt body>"
			"<body> unless <condition> else <alt body>" # psuedo-pythonic ternary
		]
		fn: (v)=> unless v("condition") then v("body") else v("alt body")
	
	new Pattern
		match: [
			"Unless <condition>, <body>"
			"<body> unless <condition>"
		]
		bad_match: [
			"Unless <condition> then <body>" # not good English
		]
		fn: (v)=> v("body") unless v("condition")
	
]

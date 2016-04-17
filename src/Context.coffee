
tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console
		
		# semantics are quite tied to context in the case of natural language
		# so maybe this stuff should be handled a Lexer class
		# but then the lexer would be coupled with the context
		# which can be considered a hack: https://en.wikipedia.org/wiki/The_lexer_hack
		# but may be overall reasonable
		
		@patterns = [
			
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
				fn: (v)=>
					@console.log v("text")
					return
			
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
					"eval <text>" # as what? (should the error message say something like "as what?"?)
					"execute <text>"
					"JavaScript <text>" # not sure JavaScript is a verb
					"JS <text>"
				]
				fn: (v)=>
					{console} = @ # bring @console into scope as "console"
					eval v("text")
			
			new Pattern
				match: [
					"<a> ^ <b>"
					"<a> to the power of <b>"
				]
				bad_match: [
					"<a> ** <b>"
				]
				fn: (v)=> v("a") ** v("b")
			
			new Pattern
				match: [
					"<a> × <b>"
					"<a> * <b>"
					"<a> times <b>"
				]
				bad_match: [
					"<a> ✖ <b>" # heavy multiplication X
					"<a> ⨉ <b>" # n-ary times operator
					"<a> ⨯ <b>" # vector or cross-product
					"<a> ∗ <b>" # asterisk operator
					"<a> ⋅ <b>" # dot operator
					"<a> ∙ <b>" # bullet operator
					"<a> • <b>" # bullet (are you kidding me?)
					"<a> ✗ <b>" # ballot
					"<a> ✘ <b>" # heavy ballot
				]
				fn: (v)=> v("a") * v("b")
			
			new Pattern
				match: [
					"<a> ÷ <b>" # obelus
					"<a> / <b>" # slash
					"<a> ∕ <b>" # division slash
					"<a> divided by <b>"
				]
				bad_match: [
					"<a> ／ <b>" # fullwidth solidus
					"<a> ⁄ <b>" # fraction slash
				]
				fn: (v)=> v("a") / v("b")
			
			new Pattern
				match: [
					"<a> + <b>"
					"<a> plus <b>"
				]
				bad_match: [
					"<a> ＋ <b>" # fullwidth plus
					"<a> ﬩ <b>" # Hebrew alternative plus sign (only English is supported, plus + is the internationally standard plus symbol) 
				]
				fn: (v)=> v("a") + v("b")
			
			new Pattern
				match: [
					"<a> − <b>" # minus
					"<a> - <b>" # hyphen-minus
					"<a> minus <b>"
				]
				fn: (v)=> v("a") - v("b")
			
			new Pattern
				match: [
					"− <b>" # minus
					"- <b>" # hyphen-minus
					"negative <b>"
					"the opposite of <b>"
				]
				bad_match: [
					"minus <b>"
				]
				fn: (v)=> - v("b")
			
			new Pattern
				match: [
					"+ <b>"
					"positive <b>"
				]
				bad_match: [
					"plus <b>"
				]
				fn: (v)=> + v("b")
			
			new Pattern
				match: [
					"<a> = <b>"
					"<a> equals <b>"
					"<a> is equal to <b>"
					"<a> is <b>"
				]
				bad_match: [
					"<a> == <b>"
					"<a> === <b>"
				]
				fn: (v)=>
					# if a.every((token)-> token.type is "word")
					# 	name = a.join(" ")
					# 	value = @eval_tokens(b)
					# 	if @constants.has(name)
					# 		unless @constants.get(name) is value
					# 			throw new Error "#{name} is already defined as #{@constants.get(name)} (which does not equal #{value})"
					# 	else if @constants.has(name)
					# 		unless @constants.get(name) is value
					# 			throw new Error "#{name} is already defined as #{@variables.get(name)} (which does not equal #{value})"
					# 	else
					# 		@variables.set(name, value)
					# else
					v("a") is v("b")
			
			new Pattern
				match: [
					"<a> ≠ <b>"
					"<a> != <b>"
					"<a> does not equal <b>"
					"<a> is not equal to <b>"
					"<a> isn't <b>"
				]
				bad_match: [
					"<a> isnt <b>" # this isn't coffeescript, you can punctuate contractions
					"<a> isnt equal to <b>" # ditto
					"<a> isn't equal to <b>" # this sounds slightly silly to me
				]
				fn: (v)=> v("a") isnt v("b")
			
			new Pattern
				match: [
					"<a> > <b>"
					"<a> is greater than <b>"
				]
				bad_match: [
					"<a> is more than <b>"
				]
				fn: (v)=> v("a") > v("b")
			
			new Pattern
				match: [
					"<a> < <b>"
					"<a> is less than <b>"
				]
				fn: (v)=> v("a") < v("b")
			
			new Pattern
				match: [
					"<a> ≥ <b>"
					"<a> >= <b>"
					"<a> is greater than or equal to <b>"
				]
				bad_match: [
					"<a> is more than or equal to <b>"
				]
				fn: (v)=> v("a") >= v("b")
			
			new Pattern
				match: [
					"<a> ≤ <b>"
					"<a> <= <b>"
					"<a> is less than or equal to <b>"
				]
				fn: (v)=> v("a") <= v("b")
			
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
			
			# NOTE: If-else has to be below If, otherwise If will be matched first
			new Pattern
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
		]
		@classes = []
		@objects = []
		@variables = {}
		@constants = {
			"true": true
			"yes": yes
			"on": on
			"false": false
			"no": no
			"off": off
			"null": null
			"infinity": Infinity
			"∞": Infinity
			"pi": Math.PI
			"π": Math.PI
			"tau": Math.PI * 2
			"τ": Math.PI * 2
			"e": Math.E
			"the golden ratio": (1 + Math.sqrt(5)) / 2
			"phi": (1 + Math.sqrt(5)) / 2
			"φ": (1 + Math.sqrt(5)) / 2
			"Pythagoras's constant": Math.SQRT2
			# "Archimedes' constant": Math.PI # can't do quotes at ends of words yet
		}
	
	subcontext: ({console}={})->
		console ?= @console
		new Context {console, supercontext: @}
	
	eval: (text)->
		# interpret is actually syncronous for now, so we can do this:
		result = null
		@interpret text, (err, res)->
			throw err if err
			result = res
		result
	
	eval_tokens: (tokens)->
		# # console.log "eval_tokens", tokens
		# if tokens.every((token)-> token.type in ["string", "number"])
		# 	# TODO: throw an error if there are two consecutive numbers
		# 	if tokens.some((token)-> token.type is "string")
		# 		str = ""
		# 		str += token.value for token in tokens
		# 		return str
		# 	else if tokens.length
		# 		last_token = tokens[tokens.length - 1]
		# 		return last_token.value
		# else if tokens.length
		# 	tok_str = stringify_tokens(tokens)
			
		# 	# for constant_name, constant_value of @constants
		# 	# 	if tok_str is constant_name
		# 	# 		return constant_value
			
		# 	# for variable_name, variable_value of @variables
		# 	# 	if tok_str is variable_name
		# 	# 		return variable_value
			
		# 	if tok_str of @constants
		# 		return @constants[tok_str]
			
		# 	if tok_str of @variables
		# 		return @variables[tok_str]
			
		# 	for pattern in @patterns by -1
		# 		match = pattern.match(tokens)
		# 		break if match?
		# 	if match?
		# 		return pattern.fn((var_name)=> @eval_tokens(match[var_name]))
		# 	else
		# 		for pattern in @patterns by -1
		# 			bad_match = pattern.bad_match(tokens)
		# 			break if bad_match?
		# 		if bad_match?
		# 			throw new Error "For `#{tok_str}`, use #{bad_match.pattern.prefered} instead"
		# 		else
		# 			throw new Error "I don't understand `#{tok_str}`"
		
		index = 0
		peek = ->
			tokens[index + 1]
		# TODO: peek, peek_all
		advance = ->
			index += 1
			# TODO: arg default to 1
		
		parse_primary = =>
			# if tokens[0].type in ["number", "string"]
			# 	tokens[0].value
			next_tokens = tokens.slice(index)
			next_literal_tokens = []
			for token, i in next_tokens
				if token.type in ["string", "number"]
					next_literal_tokens.push(token)
				else
					break
			next_word_tokens = []
			for token, i in next_tokens
				if token.type is "word"
					next_word_tokens.push(token)
				else
					break
			
			if next_literal_tokens.length
				if next_literal_tokens.some((token)-> token.type is "string")
					str = ""
					str += token.value for token in next_tokens
					index += next_literal_tokens.length
					return str
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					# advance()
					return next_literal_tokens[0].value
			else if next_word_tokens.length
				tok_str = stringify_tokens(tokens)
				
				if tok_str of @constants
					# console.log "constant", tok_str, @constants[tok_str]
					return @constants[tok_str]
				
				if tok_str of @variables
					return @variables[tok_str]
				
				throw new Error "Unknown expression `#{tok_str}`"
			else if next_tokens.length
				# # # advance()
				# # console.log "parse_primary dumping #{next_tokens[0].value}"
				# # return next_tokens[0].value
				# # return parse_expression(undefined, 0)
				# next_token = next_tokens[0]
				# if next_token.type is "punctuation" and next_token.value in ["+", "-"]
				# 	# # next_token
				# 	# # tokens.push new Token("number", -1, -1, 0)
				# 	# tokens.splice index+1, 0, new Token("number", -1, -1, 0)
				# 	# return parse_expression(undefined, 0)
				# 	# index -= 1
				# 	# return parse_expression(undefined, 0)
				# 	advance()
				# 	if next_token.value is "-"
				# 		return -parse_primary()
				# 	else
				# 		return +parse_primary()
				token = tokens[index]
				# next_token = peek()
				if token.type is "punctuation" and token.value in ["+", "-"]
					advance()
					if token.value is "-"
						return -parse_primary()
					else
						return +parse_primary()
		
		# is_binary_operator = (token)->
		# 	return false unless token?
		# 	token.type is "punctuation" and token.value in ["*", "/", "+", "-", "^"] and not is_binary_operator(tokens[tokens.indexOf(token) - 1])
		# is_right_associative_operator = (token)->
		# 	return false unless token?
		# 	# token.type is "punctuation" and token.value in []
		# 	# token.type is "punctuation" and token.value in ["*", "/", "+", "-", "^"] and is_binary_operator(tokens[tokens.indexOf(token) - 1])
		# 	# token.type is "punctuation" and token.value is "^" #and is_binary_operator(tokens[tokens.indexOf(token) - 1])
		# 	token.type is "punctuation" and (
		# 		(token.value is "^") or
		# 		(token.value in ["+", "-"] and is_binary_operator(tokens[tokens.indexOf(token) - 1]))
		# 	)
		# precedence_of = (token)->
		# 	switch token.value
		# 		when "^" then 3
		# 		when "*", "/" then 0
		# 		when "+", "-" then 0
		# 		when "=" then 0
		# 		else 0
		is_unary_operator = (token)->
			return false unless token?
			token.type is "punctuation" and token.value in ["+", "-"] and is_binary_operator(tokens[tokens.indexOf(token) - 1])
		is_binary_operator = (token)->
			return false unless token?
			token.type is "punctuation" and token.value in ["*", "/", "+", "-", "^"] and not is_binary_operator(tokens[tokens.indexOf(token) - 1])
		is_right_associative_operator = (token)->
			return false unless token?
			token.type is "punctuation" and ((token.value is "^") or is_unary_operator(token))
		
		precedence_of = (token)->
			if is_unary_operator(token)
				1
			else
				switch token.value
					when "^" then 3
					when "*", "/" then 2
					when "+", "-" then 1
					when "=", "<=", ">=", "<", ">" then 0
					else 0
		
		apply_operator = (op_token, lhs, rhs)->
			# console.log "apply_operator", lhs, op_token.value, rhs
			throw new Error "Non-number #{lhs} as left-hand-side of #{op_token.value}" if isNaN(lhs)
			throw new Error "Non-number #{rhs} as right-hand-side of #{op_token.value}" if isNaN(rhs)
			if is_unary_operator(op_token)
				switch op_token.value
					when "+" then + rhs
					when "-" then - rhs
					else throw new Error "Unknown unary operator (for now at least): #{op_token.value}"
			else
				switch op_token.value
					when "^" then lhs ** rhs
					when "*" then lhs * rhs
					when "/" then lhs / rhs
					when "+" then lhs + rhs
					when "-" then lhs - rhs
					when "=" then lhs is rhs
					else throw new Error "Unknown binary operator (for now at least): #{op_token.value}"
		
		parse_expression = (lhs, min_precedence)->
			# debugger
			lookahead = peek()
			while is_binary_operator(lookahead) and precedence_of(lookahead) >= min_precedence
				op = lookahead
				advance()
				advance()
				rhs = parse_primary()
				lookahead = peek()
				while (
					(is_binary_operator(lookahead) and precedence_of(lookahead) > precedence_of(op)) or
					(is_right_associative_operator(lookahead) and precedence_of(lookahead) is precedence_of(op))
				)
					rhs = parse_expression(rhs, precedence_of(lookahead))
					lookahead = peek()
				lhs = apply_operator(op, lhs, rhs)
			return lhs
		
		parse_expression(parse_primary(), 0)

	
	interpret: (text, callback)->
		# TODO: get this stuff out of here
		# Conversational trivialities
		if text.match /^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i
			callback null, (if text.match /^[A-Z]/ then "Hello" else "hello") + (if text.match /\.|!/ then "." else "")
		else if text.match /^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i
			callback null, (if text.match /^[A-Z]/ then "Not much" else "not much") + (if text.match /\?|!/ then "." else "")
		else if text.match /^(>?[:;8X]-?[()O3PCDS]|[D()OC]-?[:;8X]<?)$/i
			callback null, text # top notch emotional mirroring
		# Unhelp
		else if text.match /^(!*\?+!*|(please |plz )?(((I )?(want|need)[sz]?|display|show( me)?|view) )?(the |some )?help|^(gimme|give me|lend me) ((the |some )?)help| a hand( here)?)/i # overly comprehensive, much?
			callback null, "Sorry, I can't help." # TODO
		# Console
		else if text.match /^(clr|clear)( console)?( output)?|cls$/i
			if @console?
				@console.clear()
				callback null, "Console cleared."
			else
				callback new Error "No console to clear."
		else
			result = undefined
			
			line_tokens = []
			
			handle_line = =>
				if line_tokens.length
					try
						result = @eval_tokens(line_tokens)
					catch e
						callback e
				line_tokens = []
			
			for token in tokenize(text) when token.type isnt "comment"
				if token.type is "newline"
					handle_line()
				else
					line_tokens.push token
			
			handle_line()
			
			callback null, result

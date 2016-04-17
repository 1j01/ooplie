
tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"

# TODO: move class to file
class Operator extends Pattern
	constructor: ({@precedence, right_associative, binary, unary})->
		super
		throw new Error "Operator constructor requires {precedence}" unless @precedence?
		@right_associative = right_associative ? false
		if binary?
			@binary = binary
			@unary = not binary
		else
			@unary = unary
			@binary = not unary
		if @unary and not @right_associative
			throw new Error "Non-right-associative unary operators are probably not supported"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console
		# TODO: externalize all patterns and operators
		
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
		]
		@classes = []
		@instances = []
		# TODO: block-level scopes
		# should @supercontext be @superscope?
		# should contexts be scopes? should scopes be contexts?
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
		@operators = [
			new Operator
				match: [
					"^"
					"to the power of"
				]
				bad_match: [
					"**"
				]
				precedence: 3
				right_associative: yes
				fn: (v)=> v("a") ** v("b")
			
			new Operator
				match: [
					"×"
					"*"
					"times"
				]
				bad_match: [
					"✖" # heavy multiplication X
					"⨉" # n-ary times operator
					"⨯" # vector or cross-product
					"∗" # asterisk operator
					"⋅" # dot operator
					"∙" # bullet operator
					"•" # bullet (are you kidding me?)
					"✗" # ballot
					"✘" # heavy ballot
				]
				precedence: 2
				fn: (v)=> v("a") * v("b")
			
			new Operator
				match: [
					"÷" # obelus
					"/" # slash
					"∕" # division slash
					"divided by"
				]
				bad_match: [
					"／" # fullwidth solidus
					"⁄" # fraction slash
				]
				precedence: 2
				fn: (v)=> v("a") / v("b")
			
			new Operator
				match: [
					"+"
					"plus"
				]
				bad_match: [
					"＋" # fullwidth plus
					"﬩" # Hebrew alternative plus sign (only English is supported, plus + is the internationally standard plus symbol) 
				]
				precedence: 1
				fn: (v)=> v("a") + v("b")
			
			new Operator
				match: [
					"−" # minus
					"-" # hyphen-minus
					"minus"
				]
				precedence: 1
				fn: (v)=> v("a") - v("b")
			
			new Operator
				match: [
					"−" # minus
					"-" # hyphen-minus
					"negative"
					"the opposite of"
				]
				bad_match: [
					"minus"
				]
				precedence: 1
				right_associative: yes
				unary: yes
				fn: (v)=> - v("b")
			
			new Operator
				match: [
					"+"
					"positive"
				]
				bad_match: [
					"plus"
				]
				precedence: 1
				right_associative: yes
				unary: yes
				fn: (v)=> + v("b")
			
			new Operator
				match: [
					"="
					"equals"
					"is equal to"
					"is"
				]
				bad_match: [
					"=="
					"==="
				]
				precedence: 0
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
			
			new Operator
				match: [
					"≠"
					"!="
					"does not equal"
					"is not equal to"
					"isn't"
				]
				bad_match: [
					"isnt" # this isn't CoffeeScript, you can actually punctuate contractions
					"isnt equal to" # ditto
					"isn't equal to" # this sounds slightly silly to me
				]
				precedence: 0
				fn: (v)=> v("a") isnt v("b")
			
			new Operator
				match: [
					">"
					"is greater than"
				]
				bad_match: [
					"is more than"
				]
				precedence: 0
				fn: (v)=> v("a") > v("b")
			
			new Operator
				match: [
					"<"
					"is less than"
				]
				precedence: 0
				fn: (v)=> v("a") < v("b")
			
			new Operator
				match: [
					"≥"
					">="
					"is greater than or equal to"
				]
				bad_match: [
					"is more than or equal to"
				]
				precedence: 0
				fn: (v)=> v("a") >= v("b")
			
			new Operator
				match: [
					"≤"
					"<="
					"is less than or equal to"
				]
				precedence: 0
				fn: (v)=> v("a") <= v("b")
		]
	
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
		# we should probably actually ditch interpret,
		# only have syncronous eval,
		# and return Promises for asyncronous operations
		# a block of async statements should probably return a single Promise that wraps all the Promises of its statements
	
	eval_tokens: (tokens)->
		index = 0
		peek = =>
			tokens[index + 1]
		advance = (advance_by=1)=>
			index += advance_by
		
		parse_primary = =>
			next_tokens = tokens.slice(index)
			return if next_tokens.length is 0
			
			# NOTE: in the future there will be other kinds of literals
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
			
			tok_str = stringify_tokens(next_tokens)
			next_word_tok_str = stringify_tokens(next_word_tokens)
			
			# TODO: don't need to have this in reverse
			for pattern in @patterns by -1
				match = pattern.match(next_tokens)
				break if match?
			
			if match?
				return pattern.fn((var_name)=> @eval_tokens(match[var_name]))
			else
				# TODO: don't need to have this in reverse
				for pattern in @patterns by -1
					bad_match = pattern.bad_match(next_tokens)
					break if bad_match?
			
			if next_literal_tokens.length
				if next_literal_tokens.some((token)-> token.type is "string")
					str = ""
					str += token.value for token in next_tokens
					advance(next_literal_tokens.length)
					return str
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					return next_literal_tokens[0].value
			else
				
				if next_word_tokens.length
					if next_word_tok_str of @constants
						return @constants[next_word_tok_str]
					
					if next_word_tok_str of @variables
						return @variables[next_word_tok_str]
				else
					if tok_str of @constants
						return @constants[tok_str]
					
					if tok_str of @variables
						return @variables[tok_str]
				
				token = tokens[index]
				if token.type is "punctuation"
					for operator in @operators when operator.unary
						if operator.match([token])
							advance()
							following_value = parse_primary()
							return operator.fn((var_name)=> {b: following_value}[var_name])
				
				if bad_match?
					throw new Error "For `#{tok_str}`, use #{bad_match.pattern.prefered} instead"
				else
					throw new Error "I don't understand `#{tok_str}`"
		
		get_operator = (token)=>
			return undefined unless token?
			for operator in @operators
				match = operator.match([token])
				# console.log token, operator, match
				return operator if match?
		
		precedence_of = (token)=>
			get_operator(token).precedence
		
		apply_operator = (operator, a, b, op_token)=>
			throw new Error "Non-number #{a} as left-hand-side of #{op_token.value}" if isNaN(a)
			throw new Error "Non-number #{b} as right-hand-side of #{op_token.value}" if isNaN(b)
			# get_operator(op_token).fn((var_name)=> {a, b}[var_name])
			# operator = get_operator(op_token)
			res = operator.fn((var_name)=> {a, b}[var_name])
			# console.log(op_token, a, b, operator, res)
			res
		
		parse_expression = (lhs, min_precedence)=>
			# peek_operator = =>
			# 	for operator in @operators
			# 		
			
			lookahead = peek()
			lookahead_operator = get_operator(lookahead)
			# console.log "OP", lookahead, lookahead_operator
			while lookahead_operator?.binary and lookahead_operator.precedence >= min_precedence
				op_token = lookahead
				operator = lookahead_operator
				advance(2)
				rhs = parse_primary()
				lookahead = peek()
				lookahead_operator = get_operator(lookahead)
				while (
					(lookahead_operator?.binary and lookahead_operator.precedence > operator.precedence) or
					(lookahead_operator?.right_associative and lookahead_operator.precedence is operator.precedence)
				)
					rhs = parse_expression(rhs, lookahead_operator.precedence)
					lookahead = peek()
					lookahead_operator = get_operator(lookahead)
				# console.log operator, lhs, rhs
				lhs = apply_operator(operator, lhs, rhs, op_token)
				# console.log lhs
			if lookahead_operator? and not lookahead_operator.binary
				throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
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

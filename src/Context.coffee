
{Lexer} = require "./lex"
Pattern = require "./Pattern"

stringify_tokens = (tokens)->
	str = ""
	for token in tokens
		if token.type is "punctuation"
			if token.value in [",", ".", ";", ":"]
				str += token.value
			else
				str += " #{token.value}"
		else if token.type is "string"
			str += " #{JSON.stringify(token.value)}"
		else
			str += " #{token.value}"
	str.trim()

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console
		
		@lexer = new Lexer
		
		# maybe this stuff should be handled in the lexer
		# (but then the lexer would be coupled with the context
		# which is maybe not a horrible thing, but it can be considered a hack: https://en.wikipedia.org/wiki/The_lexer_hack
		# semantics are quite tied to context in this case)
		@patterns = [
			# NOTE: If-else has to be above If, otherwise If will be matched first
			new Pattern
				match: [
					"If <condition>, <actions>, else <alt_actions>"
					"If <condition> then <actions>, else <alt_actions>"
					"If <condition> then <actions> else <alt_actions>"
					"<actions> if <condition> else <alt_actions>" # pythonic ternary
				]
				bad_match: [
					"if <condition>, then <actions>, else <alt_actions>"
					"if <condition>, then <actions>, else, <alt_actions>"
					"if <condition>, <actions>, else, <alt_actions>"
					# and other things; it might be sort of arbitrary
					# comma misplacement should really be handled dynamically by the near-match system
				]
				fn: ({condition, actions, alt_actions})=>
					if @eval_expression(condition)
						@eval_expression(actions)
					else
						@eval_expression(alt_actions)
			
			new Pattern
				match: [
					"If <condition>, <actions>"
					"If <condition> then <actions>"
					"<actions> if <condition>"
				]
				fn: ({condition, actions})=>
					if @eval_expression(condition)
						@eval_expression(actions)
			
			new Pattern
				match: [
					"Unless <condition>, <actions>"
					"Unless <condition> then <actions>" # doesn't sound like good English
					"<actions> unless <condition>"
				]
				fn: ({condition, actions})=>
					unless @eval_expression(condition)
						@eval_expression(actions)
			
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
				fn: ({text})=>
					@console.log @eval_expression(text)
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
				fn: ({text})=>
					{console} = @
					eval @eval_expression(text)
			
			# new Pattern
			# 	match: [
			# 		"<text> <text>"
			# 	]
			# 	fn: (text)=>
			# 		"#{text}#{text}"
			
			# # within an expression
			# new Pattern
			# 	match: [
			# 		"<expression a> = <expression b>"
			# 	]
			# 	fn: (a, b)=>
			# 		a is b
			
			# # as a statement
			# new Pattern
			# 	match: [
			# 		"<variable name> = <expression b>"
			# 	]
			# 	fn: (a, b)=>
			# 		if a of (@variables or @definitions)
			# 			unless (@variables or @definitions)[a] is b
			# 				throw new Error "#{a} is already defined as #{(@variables or @definitions)[a]} (which does not equal #{b})"
			# 		else
			# 			(@variables or @definitions)[a] = b
		]
		@classes = []
		@objects = []
		@variables = {}
	
	subcontext: ({console}={})->
		console ?= @console
		new Context {console, supercontext: @}
	
	eval: (text)->
		# everything's syncronous for now, so we can do this:
		result = null
		@interpret text, (err, res)->
			throw err if err
			result = res
		result
	
	eval_expression: (tokens)->
		if tokens.every((token)-> token.type in ["string", "number"])
			# if there are two consecutive numbers
			# 	TODO: throw an error
			# if there's at least one string
			if tokens.some((token)-> token.type is "string")
				str = ""
				str += token.value for token in tokens
				return str
			else if tokens.length
				last_token = tokens[tokens.length - 1]
				return last_token.value
		else if tokens.length is 1
			[token] = tokens
			if token.type is "word"
				switch token.value
					when "true" then return true
					when "false" then return false
					else throw new Error "I don't understand the expression `#{stringify_tokens(tokens)}`"
		else
			throw new Error "I don't understand the expression `#{stringify_tokens(tokens)}`"
	
	interpret: (text, callback)->
		# TODO: get this stuff out of here
		# Conversational trivialities
		if text.match /^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i
			callback null, (if text.match /^[A-Z]/ then "Hello" else "hello") + (if text.match /\.|!/ then "." else "")
		else if text.match /^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i
			callback null, (if text.match /^[A-Z]/ then "Not much" else "not much") + (if text.match /\?|!/ then "." else "")
		else if text.match /^>?[:;8X][()O3PCD]$/i
			callback null, text # top notch emotional mirroring
		# Unhelp
		else if text.match /^(!*\?+!*|(I (want|need) |display|show|view)?help)/i
			callback null, "Sorry, I can't help." # TODO
		# Console
		else if text.match /^(clr|clear)( console| output)?$/i
			if @console?
				@console.clear()
				callback null, "Console cleared."
			else
				callback new Error "No console to clear."
		else
			result = undefined
			
			handle_expression = (tokens)=>
				@eval_expression(tokens)
			
			handle_statement = (tokens)=>
				# TODO: we need to find the outermost pattern, which can be anchored before or after (or both)
				# this is ridiculous:
				# 	if a then b (unless y) else c or 5 and true but not 7
				# but we should handle
				# 	a unless b
				# as well as
				# 	unless b, a
				
				bad_match = null
				for pattern in @patterns
					match = pattern.match(tokens)
					if match?
						if match.bad or match.near
							bad_match = match
						else
							break
				if match
					result = pattern.fn(match)
				else if bad_match
					throw new Error "For `#{stringify_tokens(tokens)}`, use #{pattern.prefered} instead"
				else
					throw new Error "I don't understand"
			
			line_tokens = []
			
			handle_line = =>
				if line_tokens.length
					try
						result = handle_statement(line_tokens)
					catch e
						if e.message isnt "I don't understand"
							throw e
						result = handle_expression(line_tokens)
				line_tokens = []
			
			for token in @lexer.lex(text) when token.type isnt "comment"
				if token.type is "newline"
					handle_line()
				else
					line_tokens.push token
			
			handle_line()
			
			callback null, result
			

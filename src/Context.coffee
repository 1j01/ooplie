
tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = require "./Token"

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
				fn: ({text})=>
					@console.log @eval_tokens(text)
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
					eval @eval_tokens(text)
			
			new Pattern
				match: [
					"<a> ^ <b>"
					"<a> to the power of <b>"
				]
				bad_match: [
					"<a> ** <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) ** @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> * <b>"
					"<a> times <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) * @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> / <b>"
					"<a> divided by <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) / @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> + <b>"
					"<a> plus <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) + @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> - <b>"
					"<a> minus <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) - @eval_tokens(b)
			
			new Pattern
				match: [
					"- <b>"
					"negative <b>"
				]
				bad_match: [
					"minus <b>"
				]
				fn: ({a, b})=>
					- @eval_tokens(b)
			
			new Pattern
				match: [
					"+ <b>"
					"positive <b>"
				]
				fn: ({a, b})=>
					+ @eval_tokens(b)
			
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
				fn: ({a, b})=>
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
					@eval_tokens(a) == @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> != <b>"
					"<a> does not equal <b>"
					"<a> is not equal to <b>"
					"<a> isn't <b>"
				]
				bad_match: [
					"<a> isnt <b>" # this isn't coffeescript, you can punctuate contractions
					"<a> isnt equal to <b>"
					"<a> isn't equal to <b>" # this just sounds silly; be formal or don't
				]
				fn: ({a, b})=>
					@eval_tokens(a) != @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> > <b>"
					"<a> is greater than <b>"
				]
				bad_match: [
					"<a> is more than <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) > @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> < <b>"
					"<a> is less than <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) < @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> >= <b>"
					"<a> is greater than or equal to <b>"
				]
				bad_match: [
					"<a> is more than or equal to <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) >= @eval_tokens(b)
			
			new Pattern
				match: [
					"<a> <= <b>"
					"<a> is less than or equal to <b>"
				]
				fn: ({a, b})=>
					@eval_tokens(a) <= @eval_tokens(b)
			
			# TODO: these should just be constants, not "patterns"
			new Pattern
				match: [
					"true"
					"yes"
					"on"
				]
				fn: ({a, b})=>
					true
			new Pattern
				match: [
					"false"
					"no"
					"off"
				]
				fn: ({a, b})=>
					false
			
			new Pattern
				match: [
					"If <condition>, <actions>"
					"If <condition> then <actions>"
					"<actions> if <condition>"
				]
				fn: ({condition, actions})=>
					if @eval_tokens(condition)
						@eval_tokens(actions)
			
			new Pattern
				match: [
					"Unless <condition>, <actions>"
					"Unless <condition> then <actions>" # doesn't sound like good English
					"<actions> unless <condition>"
				]
				fn: ({condition, actions})=>
					unless @eval_tokens(condition)
						@eval_tokens(actions)
			
			# NOTE: If-else has to be below If, otherwise If will be matched first
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
					# and other things; also this might be sort of arbitrary
					# comma misplacement should really be handled dynamically by the near-match system
				]
				fn: ({condition, actions, alt_actions})=>
					if @eval_tokens(condition)
						@eval_tokens(actions)
					else
						@eval_tokens(alt_actions)
			
		]
		@classes = []
		@objects = []
		@variables = {}
	
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
		# console.log "eval_tokens", tokens
		if tokens.every((token)-> token.type in ["string", "number"])
			# TODO: throw an error if there are two consecutive numbers
			if tokens.some((token)-> token.type is "string")
				str = ""
				str += token.value for token in tokens
				return str
			else if tokens.length
				last_token = tokens[tokens.length - 1]
				return last_token.value
		else if tokens.length
			# TODO: it might be better if Pattern has a seperate function bad_match
			bad_match = null
			for pattern in @patterns by -1
				match = pattern.match(tokens)
				if match?
					if match.bad or match.near
						bad_match = match
					else
						break
			if match
				return pattern.fn(match)
			else if bad_match
				throw new Error "For `#{stringify_tokens(tokens)}`, use #{bad_match.pattern.prefered} instead"
			else
				throw new Error "I don't understand `#{stringify_tokens(tokens)}`"
	
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

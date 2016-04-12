
{Lexer} = require "./lex"
Pattern = require "./Pattern"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console
		
		@lexer = new Lexer
		
		# definitions / rules / data / information / stuff
		
		perform = (actions)->
			result = undefined
			result = do action for action in actions
			result
		
		# we should have a class Pattern
		# (and maybe this stuff should be handled in the lexer)
		# (but then the lexer would be coupled with the context)
		# (which is maybe not a horrible thing, but it can be considered a hack: https://en.wikipedia.org/wiki/The_lexer_hack)
		# (semantics are quite tied to context in this case)
		@patterns = [
			new Pattern
				match: [
					"if <condition>, <actions>"
					"if <condition> then <actions>"
					"<actions> if <condition>"
				]
				action: (condition, actions)->
					perform actions if condition
			
			new Pattern
				match: [
					"unless <condition>, <actions>"
					"unless <condition> then <actions>" # doesn't sound like good English
					"<actions> unless <condition>"
				]
				action: (condition, actions)->
					perform actions unless condition
			
			new Pattern
				match: [
					"output <text>"
					"output <text> to the console"
					"log <text>"
					"log <text> to the console"
					"print <text>"
					"print <text> to the console"
					"println <text>" # no
					"say <text>"
				]
				action: (text)=>
					@console.log text
			
			new Pattern
				match: [
					"<text> <text>"
				]
				action: (text)=>
					"#{text}#{text}"
		]
		@classes = []
		@objects = []
	
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
			# actually useful stuff goes here
			
			tokens = @lexer.lex(text)
			
			# tokens = (token for token in tokens when token.type isnt "comment" and token.type isnt "newline")
			# tokens = (token for token in tokens when token.type isnt "comment")
			
			# console.log non_comment_tokens
			
			result = undefined
			console.log result
			
			line_tokens = []
			
			handle_line = =>
				# if all the tokens are either numbers or strings
				if line_tokens.every((token)-> token.type in ["string", "number"])
					# if there are two consecutive numbers
					# 	TODO: throw an error
					# if there's at least one string
					if line_tokens.some((token)-> token.type is "string")
						str = ""
						str += token.value for token in line_tokens
						result = str
					else if line_tokens.length
						last_token = line_tokens[line_tokens.length - 1]
						result = last_token.value
						# console.log last_token.value, last_token
				else
					console.log "can't handle", line_tokens
					throw new Error "IDK"
				
				line_tokens = []
			
			for token in tokens when token.type isnt "comment"
				if token.type is "newline"
					handle_line()
				else
					line_tokens.push token
			
			handle_line()
			
			console.log result
			callback null, result
			
			###
			i = 0
			expr_tokens = []
			while i < tokens.length
				token = tokens[i]
				unless token.type is "comment"
					expr_tokens.push token
					# try to match expr_tokens to each known pattern?
					# if found, you can't just execute it right away
				i++
			###
			
			# we need to find the outermost pattern, which can come before or after
			# "if a then b (unless y) else c or 5 and true but not 7"
			# alright, maybe first just match a single pattern per line
			# and then do conditionals and stuff later

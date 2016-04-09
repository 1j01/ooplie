
lex = require "./lex"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# definitions / rules / data / information / stuff = [{[{[]}]}]
	
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
		# Conversational trivialities
		if text.match /^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i
			callback null, (if text.match /^[A-Z]/ then "Hello" else "hello") + (if text.match /\.|!/ then "." else "")
		else if text.match /^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i
			callback null, (if text.match /^[A-Z]/ then "Not much" else "not much") + (if text.match /\?|!/ then "." else "")
		else if text.match /^>?[:;8X][()O3PCD]$/i
			callback null, text # top notch emotional mirroring
		# Unhelp
		else if text.match /^\?|help/i
			callback null, "Sorry, I can't help."
		# Console
		else if text.match /^(clr|clear)( console| output)?/i
			if @console?
				@console.clear()
				callback null, "Console cleared."
			else
				callback new Error "No console to clear."
		# TODO: anything useful
		else
			tokens = lex(text)
			# console.log (token.value for token in tokens)...
			result = undefined
			for token in tokens when token.type in ["number", "string"]
				result = token.value
			callback null, result

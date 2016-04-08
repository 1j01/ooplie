
# lex = require "./lex"

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
		else if text.match /^(Create|Make|Do|Just)/i
			callback new Error "I don't know how to do that."
		else if text.match /\(*(new )?\(*(window|global)(\.|\[)/
			error = null
			try
				result = eval(text)
			catch e
				error = e
			callback error, result
		else
			callback new Error "I don't understand."
		# else
		# 	console.log lex(text)

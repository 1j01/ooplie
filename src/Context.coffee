
module.exports =
class Context
	constructor: ->
		
	interpret: (text, callback)->
		# Conversational trivialities
		if text.match /^((Well|So),? )?(Hi|Hello|Hey|Greetings|Hola)/i
			callback null, (if text.match /^[A-Z]/ then "Hello" else "hello") + (if text.match /\.|!/ then "." else "")
		else if text.match /^((Well|So),? )?(What'?s up)/i
			callback null, (if text.match /^[A-Z]/ then "Not much" else "not much") + (if text.match /\?|!/ then "." else "")
		else if text.match /^>?[:;8X][()O3PCD]$/i
			callback null, text # top notch emotional mirroring
		# Unhelp
		else if text.match /^\?|help/i
			callback null, "Sorry, I can't help."
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
		else if Math.random() < 0.5
			callback new Error "Nothing happened."
		else
			callback null, text + "?"
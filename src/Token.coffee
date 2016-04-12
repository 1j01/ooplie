
module.exports =
class Token
	constructor: (@type, @col, @row, @value)->
	
	toString: ->
		# @TODO: stringify_tokens helper that outputs tokens (with whitespace) as they were in the source
		if @type is "comment"
			"#" + @value
		else
			@value

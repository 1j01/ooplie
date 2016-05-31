
module.exports =
class Token
	constructor: (@type, @col, @row, @value)->
		# TODO: @pos = {first_line, first_column, last_line, last_column}
		# instead of @col and @row
	
	toString: ->
		Token.stringify_tokens(@)
	
	@stringify_tokens = (tokens)->
		# @TODO: output token (with whitespace) as they were in the source
		str = ""
		for token in tokens
			if token.type is "punctuation"
				if token.value in [",", ".", ";", ":"]
					str += token.value
				else
					str += " #{token.value}"
			else if token.type is "string"
				str += " #{JSON.stringify(token.value)}"
			else if token.type is "comment"
				str += "##{token.value}"
			else if token.type is "newline"
				str += "\n"
			else
				str += " #{token.value}"
		str.trim()


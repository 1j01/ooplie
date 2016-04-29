
{stringify_tokens} = require "./Token"

module.exports = (tokens, start_index)->
	opening_token = tokens[start_index]
	lookahead_index = start_index
	level = 1
	# TODO: <> maybe handle XML/HTML
	loop
		lookahead_index += 1
		lookahead_token = tokens[lookahead_index]
		if lookahead_token?
			if opening_token.type is "punctuation"
				if lookahead_token.type is "punctuation"
					opening_bracket = opening_token.value
					closing_bracket = {"(": ")", "[": "]", "{": "}"}[opening_bracket]
					level += 1 if lookahead_token.value is opening_bracket
					level -= 1 if lookahead_token.value is closing_bracket
			else
				level += 1 if lookahead_token.type is "indent"
				level -= 1 if lookahead_token.type is "dedent"
			
			ended = level is 0
			
			if ended
				# bracketed_tokens = tokens.slice(token_index + 1, lookahead_index)
				return lookahead_index
		else
			if opening_token.type is "punctuation"
				bracket_name = switch opening_token.value
					when "(" then "parenthesis"
					when "[" then "square bracket"
					when "{" then "curly bracket"
				throw new Error "Missing closing #{bracket_name} in `#{stringify_tokens(tokens)}`"
			else
				# console.error "wtf", next_tokens, tokens
				throw new Error "Missing closing... dedent? in `#{stringify_tokens(tokens)}`? #{JSON.stringify tokens}"

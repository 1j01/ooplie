
module.exports =
class Pattern
	constructor: ({match, @fn})->
		# TODO: also allow [optional phrase segments]
		# TODO: try longer matchers first
		# TODO: throw error if duplicate variable names and store variables keyed by name
		@matchers =
			for def in match
				segments = def.replace(/<([^>]*)(\ )/, (m, words, space)-> "#{words}_").split(" ")
				for segment in segments
					if segment.match /^<.*>$/
						type: "variable"
						name: segment.replace(/[<>]/g, "")
					else
						type: "word"
						value: segment
	
	match_with: (tokens, matcher)->
		variables = []
		current_variable = null
		
		i = 0
		for token in tokens
			matching = matcher[i]
			if matching.type is "variable"
				if current_variable?
					if token.type is matcher[i + 1].type and token.value is matcher[i + 1].value
						current_variable = null
						i += 1
					else
						current_variable.tokens.push token
				else
					current_variable = {name: matching.name, tokens: []}
					variables.push current_variable
					current_variable.tokens.push token
			else
				current_variable = null
				if token.type is matching.type and token.value is matching.value
					i += 1
				else
					return
		if matching.type is "variable"
			i += 1
		if i is matcher.length
			return variables
		# else
		# 	console.log "almost matched", @, tokens, variables
	
	match: (tokens)->
		for matcher in @matchers
			match = @match_with(tokens, matcher)
			return match if match?

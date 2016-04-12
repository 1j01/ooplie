
module.exports =
class Pattern
	constructor: ({match, @fn})->
		# TODO: also allow [optional phrase segments]
		# and maybe (either|or|groups)
		# TODO: try longer matchers first
		# TODO: throw error if duplicate variable names and store variables keyed by name
		@matchers =
			for def in match
				segments = def.replace(/<([^>]*)(\ )/, (m, words, space)-> "#{words}_").split(" ")
				for segment in segments
					if segment.match /^<.*>$/
						type: "variable"
						name: segment.replace(/[<>]/g, "")
						toString: -> "<#{@name}>"
					else
						type: "word"
						value: segment
						toString: -> @value
	
	match_with: (tokens, matcher)->
		variables = []
		current_variable = null
		
		i = 0
		for token in tokens
			matching = matcher[i]
			if matching.type is "variable"
				if current_variable?
					if token.type is matcher[i + 1].type and token.value is matcher[i + 1].value
						console.log "end of variable"
						current_variable = null
						i += 2 # end of the variable, plus we already matched the next token
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
					# console.log "failed to match", tokens.join(" "), "against", matcher.join(" "), "at", i, matching, "vs", token
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
		
		# TODO: match bad matches
		# TODO: find near-matches (i.e. differing case, typos, differing gramatical structure if possible)
		# differing case is obviously usually not a problem whereas typos would be more likely to be incorrectly detected
		# so differing case should probably run it and maybe suggest the proper capitalization (if it can without being wrong in context)
		# whereas typos and grammar differences (with similarity algorithms applied to letters and words respectively)
		# should be more of a "Did you mean?" type of deal, and should only show up if nothing else matches
		# in fact the text similarity algorithm(s) shouldn't run unless no patterns match normally

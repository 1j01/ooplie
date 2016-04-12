
module.exports =
class Pattern
	constructor: ({match, bad_match, @fn})->
		# TODO: also allow [optional phrase segments]
		# and maybe (either|or|groups)
		# TODO: try longer matchers first
		
		parse_matchers = (matcher_defs)->
			for def in matcher_defs
				segments = def
					.replace(/<([^>]*)(\ )/g, (m, words, space)-> "#{words}_**")
					.replace(/>\ /g, ">")
					.replace(/>/g, "> ")
					.trim()
					.split(" ")
				variable_names_used = []
				for segment in segments
					if segment.match /^<.*>$/
						variable_name = segment
							.replace(/[<>]/g, "")
							.replace(/_\*\*/g, " ")
						if variable_name in variable_names_used
							throw new Error "Variable name `#{variable_name}` used twice in pattern `#{def}`"
						variable_names_used.push variable_name
						
						type: "variable"
						name: variable_name
						toString: -> "<#{@name}>"
					else
						type: if segment.match(/\w/) then "word" else "punctuation"
						value: segment
						toString: -> @value
		
		@matchers = parse_matchers(match)
		@bad_matchers = parse_matchers(bad_match ? [])
		
		@prefered = match[0]
	
	match_with: (tokens, matcher)->
		variables = {}
		current_variable_tokens = null
		
		i = 0
		for token in tokens
			matching = matcher[i]
			if matching.type is "variable"
				if current_variable_tokens?
					if token.type is matcher[i + 1].type and token.value is matcher[i + 1].value
						current_variable_tokens = null
						i += 2 # end of the variable, plus we already matched the next token
					else
						current_variable_tokens.push token
				else
					current_variable_tokens = []
					variables[matching.name] = current_variable_tokens
					current_variable_tokens.push token
			else
				current_variable_tokens = null
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
		# 	console.log "almost matched", tokens, "against", @
		# 	console.log "got variables", variables
		# 	console.log "but ended at index", i, "on", matcher
	
	match: (tokens)->
		for matcher in @matchers
			match = @match_with(tokens, matcher)
			return match if match?
		
		for matcher in @bad_matchers
			match = @match_with(tokens, matcher)
			if match?
				match.bad = true
				return match
		
		# TODO: find near-matches (i.e. differing case, typos, differing gramatical structure if possible)
		# differing case is obviously usually not a problem whereas typos would be more likely to be incorrectly detected
		# so differing case should probably run it and maybe suggest the proper capitalization (if it can without being wrong in context)
		# whereas typos and grammar differences (with similarity algorithms applied to letters and words respectively)
		# should be more of a "Did you mean?" type of deal, and should only show up if nothing else matches
		# in fact the text similarity algorithm(s) shouldn't run unless no patterns match normally

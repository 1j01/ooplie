
tokenize = require "./tokenize"
{stringify_tokens} = require "./Token"

stringify_matcher = (matcher)->
	matcher.join(" ")

module.exports =
class Pattern
	constructor: ({match, bad_match, @fn})->
		# TODO: also allow [optional phrase segments]
		# and maybe (either|or|groups)
		# TODO: syntax for matching indented blocks 
		# TODO: try longer matchers first
		
		parse_matchers = (matcher_defs)->
			for def in matcher_defs
				tokens = tokenize(def)
				segments = []
				variable_names_used = []
				current_variable_name = null
				for token, index in tokens
					if token.type is "punctuation"
						if token.value is "<"
							if current_variable_name?
								throw new Error "Unexpected `<` within variable name in pattern `#{def}`"
							else if tokens[index + 1]?.type is "word"
								current_variable_name = ""
							else
								segments.push {type: token.type, value: token.value, toString: -> @value}
						else if token.value is ">"
							if current_variable_name?
								if current_variable_name in variable_names_used
									throw new Error "Variable name `#{current_variable_name}` used twice in pattern `#{def}`"
								if current_variable_name is "pattern"
									throw new Error "Reserved pattern variable `pattern` used in pattern `#{def}`"
								variable_names_used.push current_variable_name
								segments.push {type: "variable", name: current_variable_name, toString: -> "<#{@name}>"}
								current_variable_name = null
							else
								segments.push {type: token.type, value: token.value, toString: -> @value}
						else if current_variable_name?
							current_variable_name += token.value
						else
							segments.push {type: token.type, value: token.value, toString: -> @value}
					else
						if current_variable_name?
							current_variable_name += " " if current_variable_name.slice(-1).match(/[a-z]/i)
							current_variable_name += token.value
						else
							segments.push {type: token.type, value: token.value, toString: -> @value}
							# TODO: DRY
				
				segments
		
		@matchers = parse_matchers(match)
		@bad_matchers = parse_matchers(bad_match ? [])
		
		@prefered = match[0]
	
	match_with: (tokens, matcher)->
		variables = {}
		current_variable_tokens = null
		
		token_matches = (token, segment)->
			token?.type is segment.type and
			token.value.toLowerCase() is segment.value.toLowerCase()
		
		i = 0
		for token in tokens
			if i >= matcher.length
				# console.log "failed to match", stringify_tokens(tokens), "against", stringify_matcher(matcher), "(ended)"
				return
			segment = matcher[i]
			if segment.type is "variable"
				if current_variable_tokens?
					next_segment = matcher[i + 1]
					if next_segment? and token_matches(token, next_segment)
						current_variable_tokens = null
						i += 2 # end of the variable, plus we already matched the next token
					else
						current_variable_tokens.push token
				else
					current_variable_tokens = []
					variables[segment.name] = current_variable_tokens
					current_variable_tokens.push token
			else
				current_variable_tokens = null
				if token_matches(token, segment)
					i += 1
				else
					# console.log "failed to match", stringify_tokens(tokens), "against", stringify_matcher(matcher), "at", i, segment, "vs", token
					return
		if current_variable_tokens?
			i += 1
		if i is matcher.length
			variables.pattern = @
			# console.warn "matched", "`#{stringify_tokens(tokens)}`", "against", "`#{stringify_matcher(matcher)}`", @
			# console.log "got variables", variables
			# console.log "ended at index", i, "on", matcher
			return variables
		else
			# console.log "almost matched", "`#{stringify_tokens(tokens)}`", "against", "`#{stringify_matcher(matcher)}`", @
			# console.log "got variables", variables
			# console.log "but ended at index", i, "on", matcher
	
	match: (tokens)->
		for matcher in @matchers
			match = @match_with(tokens, matcher)
			return match if match?
	
	bad_match: (tokens)->
		for matcher in @bad_matchers
			match = @match_with(tokens, matcher)
			return match if match?
	
	match_near: ->
		# for matcher in @matchers
		# 	match = @match_with(tokens, matcher, near: true)
		# return best match if any
		
		# TODO: find near-matches (i.e. differing case, typos, differing gramatical structure if possible)
		# differing case is obviously usually not a problem whereas typos would be more likely to be incorrectly detected
		# so differing case should probably run it and maybe suggest the proper capitalization (if it can without being wrong in context)
		# whereas typos and grammar differences (with similarity algorithms applied to letters and words respectively)
		# should be more of a "Did you mean?" type of deal, and should only show up if nothing else matches
		# in fact the text similarity algorithm(s) shouldn't run unless no patterns match normally

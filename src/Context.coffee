
tokenize = require "./tokenize"
Pattern = require "./Pattern"
# Operator = require "./Operator"
{stringify_tokens} = Token = require "./Token"
find_closing_token = require "./find-closing-token"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: further decouple from console somehow?
		# console IO is exceedingly common, but it might be good to establish
		# a more reusable pattern for passing interfaces and things to a context
		
		# TODO: seperate AST parsing from eval
		# in the case of natural language, semantics are quite tied to context
		# so the parser will need access to the context
		@libraries = [
			require "./library/operators"
			require "./library/constants"
			require "./library/conditionals"
			require "./library/console"
			require "./library/eval-js"
			require "./library/eval-ooplie"
		]
		unless window? and not window.require?
			@libraries = @libraries.concat [
				require "./library/fs"
				require "./library/process"
			]
		
		@classes = []
		@instances = []
	
	subcontext: ({console}={})->
		console ?= @console
		new Context {console, supercontext: @}
	
	coalesce_libraries: ->
		@patterns = []
		@operators = []
		@constants = new Map
		@variables = new Map
		# TODO: block-level scopes
		# should @supercontext be @superscope?
		# should contexts be scopes? should scopes be contexts?
		# also make sure we don't encourage global-like behavior
		for lib in @libraries
			@patterns = @patterns.concat(lib.patterns)
			@operators = @operators.concat(lib.operators)
			@constants.set(k, v) for k, v of lib.constants
		# TODO: collect from supercontexts as well
	
	eval: (text)->
		# TODO: coalesce libs only when @libraries array is modified
		# using https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy
		# and not https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/observe
		# although, note that that means a modified individual library wouldn't be updated
		# (until any change to @libraries, not necessarily a removal and addition of the given library)
		@coalesce_libraries()
		
		tokens = tokenize(text)
		
		@eval_tokens(token for token in tokens when token.type isnt "comment")
		# @eval_tokens(token for token in tokens when token.type not in ["comment"])
		
		# eval is syncronous, but could return Promises for asyncronous operations
		# a block of async statements should probably return a single Promise that wraps all the Promises of its statements
	
	eval_tokens: (tokens)->
		index = 0
		
		find_longest_match = (tokens, match_fn_type="match")=>
			longest_match = undefined
			for pattern in @patterns
				match = pattern[match_fn_type](tokens)
				longest_match ?= match
				if match?.matcher.length > longest_match?.matcher.length
					longest_match = match
			longest_match
		
		# if token.type is "punctuation" and token.value is "(" or token.type is "indent"
		# 	closing_token_index = find_closing_token tokens, index

		parse_primary = =>
			parse_tokens = []
			for token, i in tokens.slice(index)
				if token.type is "newline"
					prev_token = tokens[i - 1]
					next_token = tokens[i + 1]
					if prev_token? and prev_token.type not in ["newline", "dedent"] # isnt "newline"
						# unless next_token.type is "indent" # or prev_token.type is "dedent"
						unless next_token?.type in ["indent", "dedent"]
							break
				else
					parse_tokens.push(token)
			# console.log "parse_primary", stringify_tokens(parse_tokens)
			return if parse_tokens.length is 0
			
			# NOTE: in the future there will be other kinds of literals
			next_literal_tokens = []
			# for token, i in parse_tokens when token.type isnt "newline"
			for token, i in parse_tokens
				if token.type in ["string", "number"]
					next_literal_tokens.push(token)
				# else if token.type is "newline"
				# 	prev_token = next_literal_tokens[next_literal_tokens.length - 1] (um, this wouldn't work)
				# 	break if prev_token? and prev_token.type isnt "newline"
				else
					break
			next_word_tokens = []
			# for token, i in parse_tokens when token.type isnt "newline"
			for token, i in parse_tokens
				if token.type is "word"
					next_word_tokens.push(token)
				# else if token.type is "newline"
				# 	prev_token = next_word_tokens[next_word_tokens.length - 1] (um, this wouldn't work)
				# 	break if prev_token? and prev_token.type isnt "newline"
				else
					break
			
			tok_str = stringify_tokens(parse_tokens)
			next_word_tok_str = stringify_tokens(next_word_tokens)
			
			match = find_longest_match(parse_tokens)
			
			if match?
				get_var_value = (var_name)=>
					@eval_tokens(match[var_name])
				returns = match.pattern.fn(get_var_value, @)
				return returns
			else
				bad_match = find_longest_match(parse_tokens, "bad_match")
				if bad_match?
					throw new Error "For `#{tok_str}`, use `#{bad_match.pattern.prefered}` instead"
			
			# console.log next_literal_tokens, parse_tokens
			if next_literal_tokens.length
				if next_literal_tokens.some((token)-> token.type is "string")
					str = ""
					str += token.value for token in next_literal_tokens
					# index += next_literal_tokens.length
					return str
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					return next_literal_tokens[0].value
			else
				
				if next_word_tokens.length
					if @constants.has(next_word_tok_str)
						# index += next_word_tokens.length
						return @constants.get(next_word_tok_str)
					
					if @variables.has(next_word_tok_str)
						# index += next_word_tokens.length
						return @variables.get(next_word_tok_str)
				else
					if @constants.has(tok_str)
						# index += parse_tokens.length
						return @constants.get(tok_str)
					
					if @variables.has(tok_str)
						# index += parse_tokens.length
						return @variables.get(tok_str)
				
				token = tokens[index]
				
				if token.type is "punctuation" and token.value is "(" or token.type is "indent"
					closing_token_index = find_closing_token tokens, index
					bracketed_tokens = tokens.slice(index + 1, closing_token_index)
					# console.log bracketed_tokens, closing_token_index, tokens
					bracketed_value = @eval_tokens(bracketed_tokens)
					index = closing_token_index
					return parse_expression(bracketed_value, 0)
					# return bracketed_value
				
				for operator in @operators when operator.unary
					matcher = operator.match(tokens, index)
					if matcher
						index += matcher.length
						if index is tokens.length
							throw new Error "missing right operand for `#{operator.prefered}`"
						
						following_value = parse_primary()
						# following_value = parse_expression(parse_primary(), 1)
						# following_value = parse_expression(parse_primary(), 0)
						return operator.fn(following_value)
				
				# throw new Error "I don't understand `#{JSON.stringify parse_tokens}`"
				throw new Error "I don't understand `#{tok_str}`"
		
		# newline_operator = new Operator
		# 	match: [
		# 		"\n"
		# 		"\r\n"
		# 	]
		# 	bad_match: [
		# 		"\r"
		# 	]
		# 	precedence: 0
		# 	# right_associative: yes
		# 	fn: (lhs, rhs)-> lhs; rhs
		
		parse_expression = (lhs, min_precedence)=>
			# console.log "parse_expression", lhs, min_precedence, tokens, index
			match_operator = =>
				# console.log tokens[index]?.type, tokens[index + 1]?.type
				# if tokens[index]?.type is "newline" and tokens[index + 1]? and tokens[index + 1].type isnt "dedent"
				# 	return newline_operator
					
				for operator in @operators
					matcher = operator.match(tokens, index)
					if matcher?
						index += matcher.length
						return operator
			
			index += 1
			lookahead_operator = match_operator()
			
			while lookahead_operator?.binary and lookahead_operator.precedence >= min_precedence
				operator = lookahead_operator
				if lookahead_operator.binary and not tokens[index]?
					throw new Error "missing right operand for `#{lookahead_operator.prefered}`"
				rhs = parse_primary()
				index += 1
				lookahead_operator = match_operator()
				while (
					(lookahead_operator?.binary and lookahead_operator.precedence > operator.precedence) or
					(lookahead_operator?.right_associative and lookahead_operator.precedence is operator.precedence)
				)
					if lookahead_operator.binary and not tokens[index]?
						throw new Error "missing right operand for `#{lookahead_operator.prefered}`"
					index -= 2
					rhs = parse_expression(rhs, lookahead_operator.precedence)
					index += 2
					lookahead_operator = match_operator()
				lhs = operator.fn(lhs, rhs)
			if lookahead_operator?.unary
				throw new Error "unary operator at end of expression? (missing right operand?)" # TODO/FIXME: terrible error message
			# if tokens[index + 1] and not lookahead_operator?
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			# if tokens[index + 1]
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			# console.log "tokens[index + 1]", tokens[index + 1]
			if tokens[index + 1]?.type is "newline"
				anything_substantial_after_newline = no
				for i in [index + 1 .. tokens.length - 1]
					# console.log i, tokens.length, tokens[i]
					unless tokens[i].type in ["newline", "comment", "indent", "dedent"]
						# console.log "substantial:", tokens[i]
						anything_substantial_after_newline = yes
				# console.log "anything_substantial_after_newline:", anything_substantial_after_newline
				if anything_substantial_after_newline
					index += 1
					return parse_expression(parse_primary(), 0)
			return lhs
		
		parse_expression(parse_primary(), 0)


tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"

default_operators = require "./default-operators"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console somehow?
		
		# TODO: seperate AST parsing from eval
		# semantics are quite tied to context in the case of natural language
		# the parser will need access to the context
		
		@patterns = [].concat(
			require "./library/conditionals"
			require "./library/console"
			require "./library/eval-js"
			require "./library/eval-ooplie"
		)
		@classes = []
		@instances = []
		# TODO: block-level scopes
		# should @supercontext be @superscope?
		# should contexts be scopes? should scopes be contexts?
		@variables = {}
		@constants = require "./constants"
		@operators = (operator for operator in default_operators)
	
	subcontext: ({console}={})->
		console ?= @console
		new Context {console, supercontext: @}
	
	eval: (text)->
		result = undefined
		
		line_tokens = []
		
		handle_line = =>
			if line_tokens.length
				result = @eval_tokens(line_tokens)
			line_tokens = []
		
		for token in tokenize(text) when token.type isnt "comment"
			if token.type is "newline"
				handle_line()
			else
				line_tokens.push token
		
		handle_line()
		
		result
		
		# eval is syncronous, but could return Promises for asyncronous operations
		# a block of async statements should probably return a single Promise that wraps all the Promises of its statements
	
	eval_tokens: (tokens)->
		index = 0
		peek = =>
			tokens[index + 1]
		advance = (advance_by=1)=>
			index += advance_by
		
		parse_primary = =>
			next_tokens = tokens.slice(index)
			return if next_tokens.length is 0
			
			# NOTE: in the future there will be other kinds of literals
			next_literal_tokens = []
			for token, i in next_tokens
				if token.type in ["string", "number"]
					next_literal_tokens.push(token)
				else
					break
			next_word_tokens = []
			for token, i in next_tokens
				if token.type is "word"
					next_word_tokens.push(token)
				else
					break
			
			tok_str = stringify_tokens(next_tokens)
			next_word_tok_str = stringify_tokens(next_word_tokens)
			
			for pattern in @patterns
				match = pattern.match(next_tokens)
				break if match?
			
			if match?
				get_var_value = (var_name)=>
					# console.log "get_var_value", var_name
					@eval_tokens(match[var_name])
				returns = pattern.fn(get_var_value, @)
				# console.log "return", returns
				return returns
			else
				for pattern in @patterns
					bad_match = pattern.bad_match(next_tokens)
					break if bad_match?
				if bad_match?
					throw new Error "For `#{tok_str}`, use #{bad_match.pattern.prefered} instead"
			
			if next_literal_tokens.length
				if next_literal_tokens.some((token)-> token.type is "string")
					str = ""
					str += token.value for token in next_tokens
					advance(next_literal_tokens.length)
					return str
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					return next_literal_tokens[0].value
			else
				
				if next_word_tokens.length
					if next_word_tok_str of @constants
						# advance(next_word_tokens.length)
						return @constants[next_word_tok_str]
					
					if next_word_tok_str of @variables
						# advance(next_word_tokens.length)
						return @variables[next_word_tok_str]
				else
					if tok_str of @constants
						# advance(next_word_tokens.length)
						return @constants[tok_str]
					
					if tok_str of @variables
						# advance(next_word_tokens.length)
						return @variables[tok_str]
				
				token = tokens[index]
				
				if token.type is "punctuation" and token.value is "("
					lookahead_index = index
					loop
						lookahead_index += 1
						lookahead_token = tokens[lookahead_index]
						if lookahead_token?
							if lookahead_token.type is "punctuation" and lookahead_token.value is ")"
								# advance(lookahead_index - 1)
								# return parse_expression(parse_primary(), 0)
								result = @eval_tokens(tokens.slice(index + 1, lookahead_index))
								advance(lookahead_index) # NOTE: this may be useless or could even cause problems
								return result
						else
							throw new Error "Missing ending parenthesis in `#{tok_str}`"
				
				for operator in @operators when operator.unary
					matcher = operator.match(tokens, index)
					if matcher
						advance(matcher.length)
						following_value = parse_primary()
						# following_value = parse_expression(parse_primary(), 1)
						# following_value = parse_expression(parse_primary(), 0)
						return operator.fn(following_value)
				
				throw new Error "I don't understand `#{tok_str}`"
		
		parse_expression = (lhs, min_precedence)=>
			match_operator = =>
				for operator in @operators
					matcher = operator.match(tokens, index)
					if matcher?
						advance(matcher.length)
						return operator
			
			advance()
			lookahead_operator = match_operator()
			
			while lookahead_operator?.binary and lookahead_operator.precedence >= min_precedence
				operator = lookahead_operator
				if lookahead_operator.binary and not tokens[index]?
					throw new Error "binary operator at end of expression"
				rhs = parse_primary()
				advance()
				lookahead_operator = match_operator()
				while (
					(lookahead_operator?.binary and lookahead_operator.precedence > operator.precedence) or
					(lookahead_operator?.right_associative and lookahead_operator.precedence is operator.precedence)
				)
					if lookahead_operator.binary and not tokens[index]?
						throw new Error "binary operator at end of expression"
					advance(-2)
					rhs = parse_expression(rhs, lookahead_operator.precedence)
					advance(2)
					lookahead_operator = match_operator()
				lhs = operator.fn(lhs, rhs)
			if lookahead_operator?.unary
				throw new Error "unary operator at end of expression?" # TODO/FIXME: terrible error message
			# if peek() and not lookahead_operator?
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			# if peek()
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			return lhs
		
		parse_expression(parse_primary(), 0)

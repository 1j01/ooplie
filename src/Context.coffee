
tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"

default_operators = require "./default-operators"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: decouple from console somehow?
		
		# semantics are quite tied to context in the case of natural language
		# so maybe this stuff should be handled a Lexer class
		# but then the lexer would be coupled with the context
		# which can be considered a hack: https://en.wikipedia.org/wiki/The_lexer_hack
		# but may be overall reasonable
		
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
		# interpret is actually syncronous for now, so we can do this:
		result = null
		@interpret text, (err, res)->
			throw err if err
			result = res
		result
		# we should probably actually ditch interpret,
		# only have syncronous eval,
		# and return Promises for asyncronous operations
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
				get_var_value = (var_name)=> @eval_tokens(match[var_name])
				return pattern.fn(get_var_value, @)
			else
				for pattern in @patterns
					bad_match = pattern.bad_match(next_tokens)
					break if bad_match?
			
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
						return @constants[next_word_tok_str]
					
					if next_word_tok_str of @variables
						return @variables[next_word_tok_str]
				else
					if tok_str of @constants
						return @constants[tok_str]
					
					if tok_str of @variables
						return @variables[tok_str]
				
				token = tokens[index]
				if token.type is "punctuation"
					for operator in @operators when operator.unary
						if operator.match(tokens, index)
							advance()
							following_value = parse_primary()
							# following_value = parse_expression(parse_primary(), 1)
							# following_value = parse_expression(parse_primary(), 0)
							return operator.fn(following_value)
				
				if bad_match?
					throw new Error "For `#{tok_str}`, use #{bad_match.pattern.prefered} instead"
				else
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
				rhs = parse_primary()
				advance()
				lookahead_operator = match_operator()
				while (
					(lookahead_operator?.binary and lookahead_operator.precedence > operator.precedence) or
					(lookahead_operator?.right_associative and lookahead_operator.precedence is operator.precedence)
				)
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

	
	interpret: (text, callback)->
		result = undefined
		
		line_tokens = []
		
		handle_line = =>
			if line_tokens.length
				try
					result = @eval_tokens(line_tokens)
				catch e
					callback e
			line_tokens = []
		
		for token in tokenize(text) when token.type isnt "comment"
			if token.type is "newline"
				handle_line()
			else
				line_tokens.push token
		
		handle_line()
		
		callback null, result

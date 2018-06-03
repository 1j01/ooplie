
tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"
find_closing_token = require "./find-closing-token"

# map_object_values = (object, fn)->
# 	Object.assign(...Object.entries(object).map(
# 		([key, value]) => ({[key]: fn(value)})
# 	))

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
		
		# TODO: why are comments handled like this?
		# this should at LEAST be in eval_tokens, not outside of it
		@eval_tokens(token for token in tokens when token.type isnt "comment")
		
		# eval is syncronous, but could return Promises for asyncronous operations
		# a block of async statements should probably return a single Promise that wraps all the Promises of its statements
	
	eval_tokens: (tokens)->
		console.log("eval_tokens", stringify_tokens(tokens))
		ast = @parse_tokens(tokens)
		@eval_ast(ast)
	
	stringify_ast: (ast)->
		JSON.stringify(ast, (key, ast)-> if ast instanceof Pattern then ast.prefered else ast)
	
	eval_ast: (ast)->
		console.log("eval_ast", @stringify_ast(ast))
		return unless ast
		
		# TODO: better AST in general
		# include Tokens 
		switch ast.type
			when "literal"
				return ast.value
			when "constant" # maybe these should both just be identifiers or whatever
				return @constants.get(ast.name)
			when "variable" # maybe these should both just be identifiers or whatever
				return @variables.get(ast.name)
			# when "match" # TODO: naming (pattern?)
			# 	get_var_value = (var_name)=>
			# 		@eval_tokens(ast.match[var_name])
			# 	return ast.pattern.fn(get_var_value, @)
			when "pattern" # TODO: naming
				get_var_value = (var_name)=>
					@eval_ast(ast.vars[var_name])
				return ast.pattern.fn(get_var_value, @)
			when "operator"
				if ast.lhs and ast.rhs
					ast.operator.fn(@eval_ast(ast.lhs), @eval_ast(ast.rhs))
				else
					ast.operator.fn(@eval_ast(ast.operand))
			when "concat_literals" # TODO: should probably be an operation!
				str = ""
				str += token.value for token in ast.params
				return str
	
	parse_tokens: (tokens)->
		# TODO: rename some things like _value -> _ast or _node or _ast_node or whatever
		console.log("parse_tokens", stringify_tokens(tokens))
		index = 0
		
		find_longest_match = (tokens, match_fn_type="match")=>
			longest_match = undefined
			for pattern in @patterns
				match = pattern[match_fn_type](tokens)
				longest_match ?= match
				if match?.matcher.length > longest_match?.matcher.length
					longest_match = match
			longest_match
		
		parse_primary = =>
			console.log("parse_primary", stringify_tokens(tokens))
			parse_tokens = []
			for token, i in tokens.slice(index)
				if token.type is "newline"
					prev_token = tokens[i - 1]
					next_token = tokens[i + 1]
					if prev_token? and prev_token.type not in ["newline", "dedent"]
						unless next_token?.type in ["indent", "dedent"]
							break
				else
					parse_tokens.push(token)
			return if parse_tokens.length is 0
			
			# NOTE: in the future there will be other kinds of literals
			next_literal_tokens = []
			for token, i in parse_tokens
				if token.type in ["string", "number"]
					next_literal_tokens.push(token)
				else
					break
			next_word_tokens = []
			for token, i in parse_tokens
				if token.type is "word"
					next_word_tokens.push(token)
				else
					break
			
			tok_str = stringify_tokens(parse_tokens)
			next_word_tok_str = stringify_tokens(next_word_tokens)
			
			match = find_longest_match(parse_tokens)
			
			if match?
				# return {type: "match", match, pattern: match.pattern}
				# vars = map_object_values(match, (tokens)=> console.log "tokens????", tokens; @parse_tokens(tokens))
				vars = {}
				for k, v of match when k not in ["pattern", "matcher"]
					vars[k] = @parse_tokens(v)
				return {type: "pattern", pattern: match.pattern, vars}
			else
				bad_match = find_longest_match(parse_tokens, "bad_match")
				if bad_match?
					throw new Error "For `#{tok_str}`, use `#{bad_match.pattern.prefered}` instead"
			
			if next_literal_tokens.length
				if next_literal_tokens.some((token)-> token.type is "string")
					return {type: "concat_literals", params: next_literal_tokens}
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					return {type: "literal", value: next_literal_tokens[0].value, token: next_literal_tokens[0]}
			else
				
				if next_word_tokens.length
					if @constants.has(next_word_tok_str)
						return {type: "constant", name: next_word_tok_str}
					
					if @variables.has(next_word_tok_str)
						return {type: "variable", name: next_word_tok_str}
				else
					if @constants.has(tok_str)
						return {type: "constant", name: tok_str}
					
					if @variables.has(tok_str)
						return {type: "variable", name: tok_str}
				
				token = tokens[index]
				
				if token.type is "punctuation" and token.value is "(" or token.type is "indent"
					closing_token_index = find_closing_token tokens, index
					bracketed_tokens = tokens.slice(index + 1, closing_token_index)
					bracketed_value = @parse_tokens(bracketed_tokens)
					index = closing_token_index
					return parse_expression(bracketed_value, 0)
				
				for operator in @operators when operator.unary
					matcher = operator.match(tokens, index)
					if matcher
						index += matcher.length
						if index is tokens.length
							throw new Error "missing right operand for `#{operator.prefered}`"
						
						following_value = parse_primary()
						return {type: "operator", operator, operand: following_value}
				
				throw new Error "I don't understand `#{tok_str}`"
		
		parse_expression = (lhs, min_precedence)=>
			console.log "parse_expression", @stringify_ast(lhs), min_precedence #, tokens, index
			match_operator = =>
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
				lhs = {type: "operator", operator, lhs, rhs}
			if lookahead_operator?.unary
				throw new Error "unary operator at end of expression? (missing right operand?)" # TODO/FIXME: terrible error message
			# if tokens[index + 1] and not lookahead_operator?
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			# if tokens[index + 1]
			# 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
			if tokens[index + 1]?.type is "newline"
				anything_substantial_after_newline = no
				for i in [index + 1 .. tokens.length - 1]
					unless tokens[i].type in ["newline", "comment", "indent", "dedent"]
						anything_substantial_after_newline = yes
				if anything_substantial_after_newline
					index += 1
					return parse_expression(parse_primary(), 0)
			return lhs
		
		parse_expression(parse_primary(), 0)


tokenize = require "./tokenize"
Pattern = require "./Pattern"
{stringify_tokens} = Token = require "./Token"
find_closing_token = require "./find-closing-token"

module.exports =
class Context
	constructor: ({@console, @supercontext}={})->
		# TODO: further decouple from console somehow?
		# console IO is exceedingly common, but it might be good to establish
		# a more reusable pattern for passing interfaces and things to a context
		
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
		# console.log("eval_tokens", stringify_tokens(tokens))
		ast_node = @parse_tokens(tokens)
		@eval_ast(ast_node)
	
	stringify_ast: (ast_node)->
		JSON.stringify(ast_node, (key, ast_node)-> if ast_node instanceof Pattern then ast_node.prefered else ast_node)
	
	eval_ast: (ast_node)->
		# console.log("eval_ast", @stringify_ast(ast_node))
		return unless ast_node
		
		if Array.isArray(ast_node)
			for inner_ast_node in ast_node
				result = @eval_ast(inner_ast_node)
			return result
		
		# TODO: better AST in general
		# include Tokens for character ranges
		switch ast_node.type
			when "literal"
				return ast_node.value
			when "constant" # maybe these should both just be identifiers or whatever
				return @constants.get(ast_node.name)
			when "variable" # maybe these should both just be identifiers or whatever
				return @variables.get(ast_node.name)
			when "pattern" # TODO: naming?
				get_var_value = (var_name)=>
					@eval_ast(ast_node.vars[var_name])
				return ast_node.pattern.fn(get_var_value, @)
			when "operator"
				if ast_node.left_hand_ast_node and ast_node.right_hand_ast_node
					ast_node.operator.fn(@eval_ast(ast_node.left_hand_ast_node), @eval_ast(ast_node.right_hand_ast_node))
				else
					ast_node.operator.fn(@eval_ast(ast_node.operand))
			when "concat_literals" # TODO: should probably be an operation!
				string = ""
				string += token.value for token in ast_node.params
				return string
	
	parse_tokens: (tokens)->
		# TODO: rename some things like _ast_node -> _ast or _node or _ast_node or whatever
		# console.log("parse_tokens", stringify_tokens(tokens))
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
			# console.log("parse_primary (using tokens from parse_tokens:)", stringify_tokens(tokens))
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
			
			token_string = stringify_tokens(parse_tokens)
			next_word_token_string = stringify_tokens(next_word_tokens)
			
			match = find_longest_match(parse_tokens)
			
			if match?
				vars = {}
				for key, value of match when key not in ["pattern", "matcher"]
					vars[key] = @parse_tokens(value)
				return {type: "pattern", pattern: match.pattern, vars}
			else
				bad_match = find_longest_match(parse_tokens, "bad_match")
				if bad_match?
					throw new Error "For `#{token_string}`, use `#{bad_match.pattern.prefered}` instead"
			
			if next_literal_tokens.length
				# TODO: give just a literal for a single string
				if next_literal_tokens.some((token)-> token.type is "string")
					return {type: "concat_literals", params: next_literal_tokens}
				else if next_literal_tokens.length > 1
					# TODO: row/column numbers in errors
					throw new Error "Consecutive numbers, #{next_literal_tokens[0].value} and #{next_literal_tokens[1].value}"
				else
					return {type: "literal", value: next_literal_tokens[0].value, token: next_literal_tokens[0]}
			else
				
				if next_word_tokens.length
					if @constants.has(next_word_token_string)
						return {type: "constant", name: next_word_token_string}
					
					if @variables.has(next_word_token_string)
						return {type: "variable", name: next_word_token_string}
				else
					if @constants.has(token_string)
						return {type: "constant", name: token_string}
					
					if @variables.has(token_string)
						return {type: "variable", name: token_string}
				
				token = tokens[index]
				
				if token.type is "punctuation" and token.value is "(" or token.type is "indent"
					closing_token_index = find_closing_token(tokens, index)
					bracketed_tokens = tokens.slice(index + 1, closing_token_index)
					bracketed_ast_node = @parse_tokens(bracketed_tokens)
					index = closing_token_index
					return parse_expression(bracketed_ast_node, 0)
				
				for operator in @operators when operator.unary
					matcher = operator.match(tokens, index)
					if matcher
						index += matcher.length
						if index is tokens.length
							throw new Error "missing right operand for `#{operator.prefered}`"
						
						following_ast_node = parse_primary()
						return {type: "operator", operator, operand: following_ast_node}
				
				throw new Error "I don't understand `#{token_string}`"
		
		parse_expression = (left_hand_ast_node, min_precedence)=>
			# console.log "parse_expression", @stringify_ast(left_hand_ast_node), min_precedence #, tokens, index
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
				right_hand_ast_node = parse_primary()
				index += 1
				lookahead_operator = match_operator()
				while (
					(lookahead_operator?.binary and lookahead_operator.precedence > operator.precedence) or
					(lookahead_operator?.right_associative and lookahead_operator.precedence is operator.precedence)
				)
					if lookahead_operator.binary and not tokens[index]?
						throw new Error "missing right operand for `#{lookahead_operator.prefered}`"
					index -= 2
					right_hand_ast_node = parse_expression(right_hand_ast_node, lookahead_operator.precedence)
					index += 2
					lookahead_operator = match_operator()
				left_hand_ast_node = {type: "operator", operator, left_hand_ast_node, right_hand_ast_node}
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
					return [left_hand_ast_node, parse_expression(parse_primary(), 0)]
			return left_hand_ast_node
		
		parse_expression(parse_primary(), 0)

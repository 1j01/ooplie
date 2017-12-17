
Pattern = require "./Pattern"

module.exports =
class Operator extends Pattern
	constructor: ({match, bad_match, fn, precedence, right_associative, binary, unary})->
		super({match, bad_match, fn})
		throw new Error "Operator constructor requires {precedence}" unless precedence?
		@precedence = precedence
		@right_associative = right_associative ? false
		if binary?
			@unary = not binary
			@binary = not @unary
		else
			@binary = not unary
			@unary = not @binary
		if @unary and not @right_associative
			throw new Error "Non-right-associative unary operators are probably not supported"
	
	match: (tokens, index)->
		for matcher in @matchers
			matching = yes
			for segment, segment_index in matcher
				token = tokens[index + segment_index]
				matching = (token?.type is segment.type and token?.value is segment.value)
				break unless matching
			if matching
				return matcher
	
	bad_match: ->
		throw new Error "Not implemented!"

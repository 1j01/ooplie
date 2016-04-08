
Lexer = require "lex"

module.exports = (source)->
	row = 1
	col = 1
	
	lexer = new Lexer
	# lexer = new Lexer (char)->
	# 	throw new Error "Unexpected character at row #{row}, column #{col}: #{JSON.stringify(char)}"
	
	lexer.addRule /#[0-9a-f]{6}/i, (lexeme)-> "COLOR"
	
	lexer.addRule /rgb\(\d+\s*,\s*\d+\s*,\s*\d+\s*\)/i, (lexeme)-> "COLOR"
	
	lexer.addRule /rgba\(\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)/i, (lexeme)-> "COLOR"
	
	lexer.addRule /hsl\(\d+\s*,\s*\d+\s*%?,\s*\d+\s*%?\)/i, (lexeme)-> "COLOR"
	
	lexer.addRule /hsla\(\d+\s*,\s*\d+\s*%?,\s*\d+\s*%?,\s*\d+\s*%?\)/i, (lexeme)-> "COLOR"
	
	lexer.addRule /\n/, ->
		row++
		col = 1
	, []

	lexer.addRule /./, ->
		# @reject = true
		col++
	, []
	
	indent = [0]

	lexer = new Lexer

	lexer.addRule /^[\t ]*/gm, (lexeme)->
		indentation = lexeme.length
		
		if indentation > indent[0]
			indent.unshift(indentation)
			return "INDENT"
		
		tokens = []
		
		while indentation < indent[0]
			tokens.push("DEDENT")
			indent.shift()
		
		return tokens if tokens.length
	
	lexer.input = source
	
	lexer.lex()
	
	lexer.output


class Lexer
	constructor: ->
		
	
	check_indentation: (source)->
		previous_indentation = ""
		for line, line_index in source.replace(/\r/g, "").split("\n")
			indentation = line.match(/^\s*/)[0]
			for previous_indentation_char, column_index in previous_indentation when indentation[column_index]
				if indentation[column_index] isnt previous_indentation_char
					char_name = switch indentation[column_index]
						when "\t" then "tab"
						when " " then "space"
						else JSON.stringify(indentation[column_index])
					# throw new Error "Mixed indentation, unexpected #{char_name} on line #{line_index + 1}, column #{column_index + 1}"
					throw new Error "Mixed indentation between lines #{line_index} and #{line_index + 1} on column #{column_index + 1}"
			previous_indentation = indentation
	
	tokenize: (source)->
		@check_indentation(source)
		
		tokens = []
		
		row = 1
		col = 1
		
		current_type = null
		current_token_string = ""
		quote_char = null
		
		indent = [0]
		handle_indentation = (i, row, col)->
			indentation = ""
			loop
				i += 1
				if source[i]?.match(/[\t\ ]/)
					indentation += source[i]
				else
					break
			
			if indentation.length > indent[0]
				indent.unshift(indentation.length)
				tokens.push(new Token("indent", row, col, indentation))
				return
			
			while indentation.length < indent[0]
				tokens.push(new Token("dedent", row, col, indentation))
				indent.shift()
		
		finish_token = ->
			if current_type is "number"
				tokens.push(new Token(current_type, row, col, parseFloat(current_token_string)))
			else if current_type is "string"
				tokens.push(new Token(current_type, row, col, current_token_string.replace(/^['"]/, "")))
			else if current_type?
				tokens.push(new Token(current_type, row, col, current_token_string))
			current_token_string = ""
		
		for char, i in source
			next_char = source[i + 1] ? ""
			next_type = current_type
			
			if current_type is "string"
				if char is quote_char
					next_type = null
			else
				if char.match(/\d/)
					next_type = "number"
				else if char is "."
					if next_char.match(/\d/)
						next_type = "number"
					else
						next_type = "punctuation"
				else if char is ","
					next_type = "punctuation"
				else if char.match(/[a-z]/i)
					next_type = "word"
				else if char.match(/'/)
					if current_type is "word" and next_char.match(/[a-z]/i)
						next_type = "word"
					else
						quote_char = char
						next_type = "string"
				else if char.match(/"/)
					next_type = "string"
					quote_char = char
				else if char.match(/\s/)
					next_type = null
				else
					next_type = "other"
			
			finish_token() if next_type isnt current_type
			
			current_type = next_type
			current_token_string += char
			
			if char is "\n"
				row++
				col = 1
				handle_indentation(i, row, col)
			else
				col += 1
		
		if current_type is "string"
			throw new Error "Missing end quote (#{quote_char}) for string at row #{row}, column #{col}"
		
		finish_token()
		
		tokens
	
	lex: (source)->
		tokens = @tokenize(source)
		# if tokens[0]?.type is "number"
		# 	tokens[0].value
		# else
		# 	tokens
		# tokens[tokens.length-1]?.value ? tokens
		tokens

class Token
	constructor: (@type, @col, @row, @value)->
		
	# toString: ->
	# 	"#{@type}:#{JSON.stringify(@value)}"
	# 	"#{JSON.stringify(@value)}"

module.exports = (source)->
	lexer = new Lexer

	# lexer.addRule /^[\t ]*/gm, (lexeme)->
	# 	indentation = lexeme.length
		
	# 	if indentation > indent[0]
	# 		indent.unshift(indentation)
	# 		return "INDENT"
		
	# 	tokens = []
		
	# 	while indentation < indent[0]
	# 		tokens.push("DEDENT")
	# 		indent.shift()
		
	# 	return tokens if tokens.length
	
	lexer.lex(source)

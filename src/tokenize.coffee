
Token = require './Token'

check_indentation = (source)->
	previous_indentation = ""
	for line, line_index in source.replace(/\r/g, "").split("\n")
		indentation = line.match(/^\s*/)[0]
		for previous_indentation_char, column_index in previous_indentation when indentation[column_index]
			if indentation[column_index] isnt previous_indentation_char
				char_name = switch indentation[column_index]
					when "\t" then "tab"
					when " " then "space"
					else JSON.stringify(indentation[column_index])
				throw new Error "Mixed indentation between lines #{line_index} and #{line_index + 1} at column #{column_index + 1}"
		previous_indentation = indentation
	
module.exports = (source)->
	check_indentation(source)
	
	tokens = []
	
	row = 1
	col = 1
	
	current_type = null
	next_type = null
	current_token_string = ""
	quote_char = null
	string_content_on_first_line = no
	string_first_newline_found = no
	string_content_started = no
	string_content_indentation = null
	
	indent_level = 0
	handle_indentation = (i, row, col)->
		indentation = ""
		loop
			i += 1
			if source[i]?.match(/[\t\ ]/)
				indentation += source[i]
			else
				break
		
		if indentation.length > indent_level
			tokens.push(new Token("indent", row, col, indentation))
			indent_level = indentation.length
		
		while indentation.length < indent_level
			tokens.push(new Token("dedent", row, col, indentation))
			indent_level -= 1
	
	start_string = (char)->
		next_type = "string"
		quote_char = char
		string_content_on_first_line = no
		string_first_newline_found = no
		string_content_started = no
		string_content_indentation = null
	
	finish_token = ->
		if current_type is "number"
			tokens.push(new Token(current_type, row, col, parseFloat(current_token_string)))
		else if current_type?
			tokens.push(new Token(current_type, row, col, current_token_string))
		current_token_string = ""
		current_type = null
	
	previous_was_escape = no
	
	for char, i in source
		prev_char = source[i - 1] ? ""
		next_char = source[i + 1] ? ""
		next_type = current_type
		
		if current_type is "comment"
			if char is "\n"
				next_type = null
				finish_token() if next_type isnt current_type
				current_type = next_type
				tokens.push(new Token("newline", row, col, "\n"))
				handle_indentation(i, row, col)
			else
				current_token_string += char
		else if current_type is "string"
			if previous_was_escape
				previous_was_escape = no
			else if char is "\\"
				switch next_char
					when "n" then current_token_string += "\n"
					when "r" then current_token_string += "\r"
					when "t" then current_token_string += "\t"
					when "v" then current_token_string += "\v"
					when "b" then current_token_string += "\b"
					when "0" then current_token_string += "\0"
					when "\\" then current_token_string += "\\"
					when "'" then current_token_string += "'"
					when '"' then current_token_string += '"'
					else throw new Error "Unknown backslash escape \\#{char} (Do you need to escape the backslash?)"
				previous_was_escape = yes
			else if char is quote_char
				finish_token()
				next_type = null
			else if char is "\n"
				whitespace_after = source.slice(i).match(/^\s*/m)
				is_last_newline_before_quote = source[i + whitespace_after.length] is quote_char
				if string_first_newline_found or string_first_newline_cannot_be_ignored
					unless is_last_newline_before_quote
						current_token_string += char
				
				string_first_newline_found = yes
			else if char.match(/[\t\ ]/)
				# TODO: support spaces
				match = source.slice(0, i + 1).match(/\n([\t\ ]*)$/)
				# console.log {source, row, col, match}
				if match?
					string_indent_level = match[1].length
					if string_indent_level > indent_level + 1
						current_token_string += char
				else
					current_token_string += char
			else
				string_first_newline_cannot_be_ignored = yes unless string_first_newline_found
				current_token_string += char
		else if char is "\n"
			next_type = null
			finish_token() if next_type isnt current_type
			current_type = next_type
			tokens.push(new Token("newline", row, col, "\n"))
			handle_indentation(i, row, col)
		else
			if char.match(/\d/)
				next_type = "number"
			else if char is "."
				if next_char.match(/\d/)
					next_type = "number"
				else
					next_type = "punctuation"
			else if char is "-"
				if next_char.match(/\d/) and not prev_char.match(/\d/)
					next_type = "number"
				else
					next_type = "punctuation"
			else if char is "#"
				next_type = "comment"
			else if char.match(/[,!?@#$%^&*\(\)\[\]\{\}<>\/\|\\\-+=~:;]/)
				next_type = "punctuation"
			else if char.match(/[a-z]/i)
				next_type = "word"
			else if char is "'"
				if current_type is "word" and next_char.match(/[a-z]/i)
					# e.g. it's, isn't, doesn't, shouldn't etc.
					# (but not e.g. 'tis or fightin')
					next_type = "word"
				else
					start_string(char)
			else if char is '"'
				start_string(char)
			else if char.match(/\s/)
				next_type = null
			else
				next_type = "unknown"
			
			if next_type isnt current_type
				finish_token()
			else if next_type is "punctuation" and current_type is "punctuation"
				unless prev_char in ["?", "!"] and char in ["?", "!"] or prev_char is "." and char is "."
					finish_token()
			
			current_type = next_type
			unless next_type in ["string", "comment"]
				current_token_string += char
		
		if char is "\n"
			row++
			col = 1
		else
			col += 1
	
	if current_type is "string"
		throw new Error "Missing end quote (#{quote_char}) for string at row #{row}, column #{col}"
	
	finish_token()
	handle_indentation(i, row, col)
	
	tokens

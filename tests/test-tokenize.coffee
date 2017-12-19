
{expect} = require?("chai") ? chai
Ooplie = require?("../src/ooplie.coffee") ? @Ooplie

tokenize = (source)->
	tokens = Ooplie.tokenize(source)
	stripped_tokens = ({type, value} for {type, value} in tokens)
	to = (value)-> expect(stripped_tokens).to.eql(value)
	{to}

suite "tokenize", ->
	
	test "numbers", ->
		tokenize("1").to([{type: "number", value: 1}])
		tokenize("1.5").to([{type: "number", value: 1.5}])
	
	test "negative numbers", ->
		tokenize("-1").to([
			{type: "punctuation", value: "-"}
			{type: "number", value: 1}
		])
		tokenize("-24.8").to([
			{type: "punctuation", value: "-"}
			{type: "number", value: 24.8}
		])
	
	test.skip "numbers with exponents", ->
		tokenize("2e3").to([{type: "number", value: 2e3}])
		tokenize("1.3e4").to([{type: "number", value: 1.3e4}])
	
	test.skip "numbers with radices", ->
		tokenize("0x5f").to([{type: "number", value: 0x5f}])
		tokenize("0b01").to([{type: "number", value: 0b01}])
		tokenize("0o77").to([{type: "number", value: 0o77}])
	
	test "expressions", ->
		tokenize("1-6").to([
			{type: "number", value: 1}
			{type: "punctuation", value: "-"}
			{type: "number", value: 6}
		])
		tokenize("1*6 + 4").to([
			{type: "number", value: 1}
			{type: "punctuation", value: "*"}
			{type: "number", value: 6}
			{type: "punctuation", value: "+"}
			{type: "number", value: 4}
		])
	
	test "words", ->
		tokenize("3 monkeys").to([
			{type: "number", value: 3}
			{type: "word", value: "monkeys"}
		])
	
	test "midway contractions", ->
		tokenize("it's gonna be a g'day t'day").to([
			{type: "word", value: "it's"}
			{type: "word", value: "gonna"}
			{type: "word", value: "be"}
			{type: "word", value: "a"}
			{type: "word", value: "g'day"}
			{type: "word", value: "t'day"}
		])
	
	test.skip "starting/ending contractions", ->
		tokenize("'tis nothin', really").to([
			{type: "word", value: "'tis"}
			{type: "word", value: "nothin'"}
			{type: "punctuation", value: ","}
			{type: "word", value: "really"}
		])
	
	test "punctuation", ->
		tokenize("Comma, semicolon; period. Exclamation! Question?").to([
			{type: "word", value: "Comma"}
			{type: "punctuation", value: ","}
			{type: "word", value: "semicolon"}
			{type: "punctuation", value: ";"}
			{type: "word", value: "period"}
			{type: "punctuation", value: "."}
			{type: "word", value: "Exclamation"}
			{type: "punctuation", value: "!"}
			{type: "word", value: "Question"}
			{type: "punctuation", value: "?"}
		])
	
	test "combined punctuation", ->
		tokenize("Exclamatory question!?").to([
			{type: "word", value: "Exclamatory"}
			{type: "word", value: "question"}
			{type: "punctuation", value: "!?"}
		])
		tokenize("Exclamatory question?!").to([
			{type: "word", value: "Exclamatory"}
			{type: "word", value: "question"}
			{type: "punctuation", value: "?!"}
		])
		tokenize("Elipses...").to([
			{type: "word", value: "Elipses"}
			{type: "punctuation", value: "..."}
		])
		tokenize("Greater than >= or equal to").to([
			{type: "word", value: "Greater"}
			{type: "word", value: "than"}
			{type: "punctuation", value: ">="}
			{type: "word", value: "or"}
			{type: "word", value: "equal"}
			{type: "word", value: "to"}
		])
		tokenize("Less than <= or equal to").to([
			{type: "word", value: "Less"}
			{type: "word", value: "than"}
			{type: "punctuation", value: "<="}
			{type: "word", value: "or"}
			{type: "word", value: "equal"}
			{type: "word", value: "to"}
		])
		tokenize("Not != equal to").to([
			{type: "word", value: "Not"}
			{type: "punctuation", value: "!="}
			{type: "word", value: "equal"}
			{type: "word", value: "to"}
		])
	
	test "punctuation that shouldn't be combined", ->
		tokenize("{()}").to([
			{type: "punctuation", value: "{"}
			{type: "punctuation", value: "("}
			{type: "punctuation", value: ")"}
			{type: "punctuation", value: "}"}
		])
		tokenize("+-*/").to([
			{type: "punctuation", value: "+"}
			{type: "punctuation", value: "-"}
			{type: "punctuation", value: "*"}
			{type: "punctuation", value: "/"}
		])
		tokenize("Dr., uh, Frankenstein, was it?").to([
			# I guess ideally this would be {type: "word", value: "Dr."}
			# or maybe a further lexing step could transform it to {type: "noun", proper: true, value: "Dr."}
			# or whatever... anyways
			{type: "word", value: "Dr"}
			{type: "punctuation", value: "."}
			{type: "punctuation", value: ","}
			{type: "word", value: "uh"}
			{type: "punctuation", value: ","}
			{type: "word", value: "Frankenstein"}
			{type: "punctuation", value: ","}
			{type: "word", value: "was"}
			{type: "word", value: "it"}
			{type: "punctuation", value: "?"}
		])
	
	test "numbers at the end of sentences", ->
		tokenize("Three equals 3.").to([
			{type: "word", value: "Three"}
			{type: "word", value: "equals"}
			{type: "number", value: 3}
			{type: "punctuation", value: "."}
		])
		tokenize("Three equals 3. That's a fact.").to([
			{type: "word", value: "Three"}
			{type: "word", value: "equals"}
			{type: "number", value: 3}
			{type: "punctuation", value: "."}
			{type: "word", value: "That's"}
			{type: "word", value: "a"}
			{type: "word", value: "fact"}
			{type: "punctuation", value: "."}
		])
		tokenize("Just... 42...?").to([
			{type: "word", value: "Just"}
			{type: "punctuation", value: "..."}
			{type: "number", value: 42}
			{type: "punctuation", value: "..."}
			{type: "punctuation", value: "?"}
		])
	
	test "simple strings", ->
		tokenize("say 'hi'").to([
			{type: "word", value: "say"}
			{type: "string", value: "hi"}
		])
		tokenize("say 'hi', then say 'bye bye'!").to([
			{type: "word", value: "say"}
			{type: "string", value: "hi"}
			{type: "punctuation", value: ","}
			{type: "word", value: "then"}
			{type: "word", value: "say"}
			{type: "string", value: "bye bye"}
			{type: "punctuation", value: "!"}
		])
	
	test "empty strings", ->
		tokenize("empty string = ''").to([
			{type: "word", value: "empty"}
			{type: "word", value: "string"}
			{type: "punctuation", value: "="}
			{type: "string", value: ""}
		])
		tokenize('empty string = ""').to([
			{type: "word", value: "empty"}
			{type: "word", value: "string"}
			{type: "punctuation", value: "="}
			{type: "string", value: ""}
		])
	
	test "escaped quotes", ->
		tokenize("say '\\'hi\\''").to([
			{type: "word", value: "say"}
			{type: "string", value: "'hi'"}
		])
		tokenize('say "\\"hi\\""').to([
			{type: "word", value: "say"}
			{type: "string", value: '"hi"'}
		])
	
	test "escape characters", ->
		tokenize("'\0\b\r\n\v'").to([
			{type: "string", value: "\0\b\r\n\v"}
		])
	
	test "multiline strings", ->
		tokenize('"Hello\nWorld"').to([
			{type: "string", value: "Hello\nWorld"}
		])
		tokenize("'Hello\nWorld'").to([
			{type: "string", value: "Hello\nWorld"}
		])
	
	test "multiline strings with ignored whitespace", ->
		tokenize("""
			say '
				hello world
			'
		""").to([
			{type: "word", value: "say"}
			{type: "string", value: "hello world"}
		])
		tokenize("""
			say '
				hi
				bye
			'
		""").to([
			{type: "word", value: "say"}
			{type: "string", value: "hi\nbye"}
		])
		tokenize("""
			say '
				
				hi, and...
				
				bye
				
			'
		""").to([
			{type: "word", value: "say"}
			{type: "string", value: "\nhi, and...\n\nbye\n"}
		])
		tokenize("""
			'
			Hello
			Goodbye
			'
		""").to([
			{type: "string", value: "Hello\nGoodbye"}
		])
		tokenize("""
			'
				Hello	Merhaba
				Goodbye	Elveda
			'
		""").to([
			{type: "string", value: """
				Hello	Merhaba
				Goodbye	Elveda
			"""}
		])
		tokenize("""
			'
				Hallo
					Afscheid
			'
		""").to([
			{type: "string", value: "Hallo\n\tAfscheid"}
		])
		tokenize("""
			"
				Salut
				 Au revoir
			"
		""").to([
			{type: "string", value: "Salut\n Au revoir"}
		])
		tokenize("""
			'
					¡Hola
					Despedida
			'
		""").to([
			{type: "string", value: "\t¡Hola\n\tDespedida"}
		])
	
	test.skip "multiline strings with ignored spaces", ->
		tokenize("""
			'
			 Zdraveĭte
			     Dovizhdane
			'
		""").to([
			{type: "string", value: "Zdraveĭte\n    Dovizhdane"}
		])
		tokenize("""
			'
			    Ciao
			        Addio
			'
		""").to([
			{type: "string", value: "Ciao\n    Addio"}
		])
	
	test "badly formed strings", ->
		expect(->
			tokenize('say "hello world')
		).to.throw('Missing end quote (") for string at row 1, column 17')
		expect(->
			tokenize('say "hello world\'')
		).to.throw('Missing end quote (") for string at row 1, column 18')
		expect(->
			tokenize('say \'hello world"')
		).to.throw("Missing end quote (') for string at row 1, column 18")
	
	test "single-line comments with #", ->
		tokenize("""
			#!/usr/bin/english
			# "hiya world"
			"Hello, world!"
			# "Hello World"
		""").to([
			{type: "comment", value: "!/usr/bin/english"}
			{type: "newline", value: "\n"}
			{type: "comment", value: ' "hiya world"'}
			{type: "newline", value: "\n"}
			{type: "string", value: "Hello, world!"}
			{type: "newline", value: "\n"}
			{type: "comment", value: ' "Hello World"'}
		])
		tokenize("""
			# "hiya world"
			"Hello, world!" # this is the line that shouldn't be ignored
			# "Hello World"
		""").to([
			{type: "comment", value: ' "hiya world"'}
			{type: "newline", value: "\n"}
			{type: "string", value: "Hello, world!"}
			{type: "comment", value: " this is the line that shouldn't be ignored"}
			{type: "newline", value: "\n"}
			{type: "comment", value: ' "Hello World"'}
		])
		tokenize("""
			# "hiya world"
			"#wassup world?" # hashes within strings
			# "Hello World"
		""").to([
			{type: "comment", value: ' "hiya world"'}
			{type: "newline", value: "\n"}
			{type: "string", value: "#wassup world?"}
			{type: "comment", value: ' hashes within strings'}
			{type: "newline", value: "\n"}
			{type: "comment", value: ' "Hello World"'}
		])
	
	test "indentation", ->
		tokenize("""
			If true,
				Do something
		""").to([
			{type: "word", value: "If"}
			{type: "word", value: "true"}
			{type: "punctuation", value: ","}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Do"}
			{type: "word", value: "something"}
			{type: "dedent", value: ""}
		])
		tokenize("""
			If true,
				Do something
			Else,
				Do something else
		""").to([
			{type: "word", value: "If"}
			{type: "word", value: "true"}
			{type: "punctuation", value: ","}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Do"}
			{type: "word", value: "something"}
			{type: "newline", value: "\n"}
			{type: "dedent", value: ""}
			{type: "word", value: "Else"}
			{type: "punctuation", value: ","}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Do"}
			{type: "word", value: "something"}
			{type: "word", value: "else"}
			{type: "dedent", value: ""}
		])
	
	test "more indentation", ->
		tokenize("""
			If true,
				Do something with:
					Alphabet
			Else,
				Do something with:
				# awkward comment
					Bobbafett
		""").to([
			{type: "word", value: "If"}
			{type: "word", value: "true"}
			{type: "punctuation", value: ","}
			
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Do"}
			{type: "word", value: "something"}
			{type: "word", value: "with"}
			{type: "punctuation", value: ":"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t\t"}
			{type: "word", value: "Alphabet"}
			
			{type: "newline", value: "\n"}
			{type: "dedent", value: ""}
			{type: "dedent", value: ""}
			{type: "word", value: "Else"}
			{type: "punctuation", value: ","}
			
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Do"}
			{type: "word", value: "something"}
			{type: "word", value: "with"}
			{type: "punctuation", value: ":"}
			{type: "newline", value: "\n"}
			{type: "comment", value: " awkward comment"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t\t"}
			{type: "word", value: "Bobbafett"}
			{type: "dedent", value: ""}
			{type: "dedent", value: ""}
		])
	
	test.skip "spaced indentation", ->
		tokenize("""
			If
			    A
			        B
			Else
			    C
			        D
		""").to([
			{type: "word", value: "If"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "    "}
			{type: "word", value: "A"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "        "}
			{type: "word", value: "B"}
			
			{type: "newline", value: "\n"}
			{type: "dedent", value: ""}
			{type: "dedent", value: ""}
			{type: "word", value: "Else"}
			
			{type: "newline", value: "\n"}
			{type: "indent", value: "    "}
			{type: "word", value: "C"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "        "}
			{type: "word", value: "D"}
			{type: "dedent", value: ""}
			{type: "dedent", value: ""}
		])
	
	test.skip "keep indentation until content", ->
		# but ideally if there isn't content, maybe the dedent token would come before other newline tokens?
		# (shouldn't really matter until the dedent is referenced in an error)
		tokenize("""
			A
				B
			
				C
			D
		""").to([
			{type: "word", value: "A"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "B"}
			{type: "newline", value: "\n"}
			{type: "newline", value: "\n"}
			{type: "word", value: "C"}
			{type: "newline", value: "\n"}
			{type: "dedent", value: ""}
			{type: "word", value: "D"}
		])
	
	test "bad indentation", ->
		expect(->
			tokenize("""
				Indented:
				    Four spaces
					Tabs
			""")
		).to.throw("Mixed indentation between lines 2 and 3 at column 1")
		
		expect(->
			tokenize("""
				Indented with spaces:
				  But then
					omg
			""")
		).to.throw("Mixed indentation between lines 2 and 3 at column 1")
		
		expect(->
			tokenize("""
				Indented with spaces:
				    But then
				        suddenly
				    	omg
			""")
		).to.throw("Mixed indentation between lines 3 and 4 at column 5")
	
	test "mediocre indentation", ->
		tokenize("""
			Indented:
				Tabbed
				  Spaced
				Tabbed
		""").to([
			{type: "word", value: "Indented"}
			{type: "punctuation", value: ":"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t"}
			{type: "word", value: "Tabbed"}
			{type: "newline", value: "\n"}
			{type: "indent", value: "\t  "}
			{type: "word", value: "Spaced"}
			{type: "newline", value: "\n"}
			{type: "dedent", value: "\t"}
			{type: "dedent", value: "\t"} # FIXME: multiple dedents (despite combined indents)
			{type: "word", value: "Tabbed"}
			{type: "dedent", value: ""}
		])
		tokenize("""
			Indented with spaces:
			  But then
			  	omg
		""")
		# this should probably be an error:
		tokenize("""
			Indented:
				Tabbed
				  Spaced
				 Half-despaced
		""")
	
	test "CSS colors"
	test "URLs"
	test "email addresses"
	test "ip addresses"
	test "version strings"
	test "file paths"
	test "XML"
	test "HTML"
	
	test "different line-endings"
	
	test "row/column properties"
		# row/column properties of the start and the end of the token
		# and also the file name or other input source identification
		# Token.pos something like {first_line, first_column, last_line, last_column}

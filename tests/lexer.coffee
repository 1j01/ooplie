
{expect} = require?("chai") ? chai
{lex} = require?("../src/ooplie.coffee") ? Ooplie

tokenize = (source)->
	tokens = lex(source)
	stripped_tokens = ({type, value} for {type, value} in tokens)
	to = (value)-> expect(stripped_tokens).to.eql(value)
	{to}

suite "tokenization", ->
	
	test "numbers", ->
		tokenize("1").to([{type: "number", value: 1}])
		tokenize("1.5").to([{type: "number", value: 1.5}])
	
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
	
	test "starting/ending contractions", ->
		tokenize("'tis goin' ta be a g'day t'day").to([
			{type: "word", value: "'tis"}
			{type: "word", value: "goin'"}
			{type: "word", value: "ta"}
			{type: "word", value: "be"}
			{type: "word", value: "a"}
			{type: "word", value: "g'day"}
			{type: "word", value: "t'day"}
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
			{type: "string", value: "hi"}
			{type: "punctuation", value: ","}
			{type: "word", value: "then"}
			{type: "word", value: "say"}
			{type: "string", value: "bye bye"}
			{type: "punctuation", value: "!"}
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
	
	test "badly formed strings"
		# including sudden EOF and mismatched quote characters
	
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
		])
	
	test "bad indentation"
		# TODO: test mixed indentation errors
	
	test "single-line comments with #", ->
		tokenize("""
			#!/usr/bin/english
			# "hiya world"
			"Hello, world!"
			# "Hello World"
		""").to([
			{type: "comment", value: "!/usr/bin/english"}
			{type: "comment", value: ' "hiya world"'}
			{type: "string", value: "Hello, world!"}
			{type: "comment", value: ' "Hello World"'}
		])
		tokenize("""
			# "hiya world"
			"Hello, world!" # this is the line that shouldn't be ignored
			# "Hello World"
		""").to([
			{type: "comment", value: ' "hiya world"'}
			{type: "string", value: "Hello, world!"}
			{type: "comment", value: ' this is the line that shouldn\'t be ignored'}
			{type: "comment", value: ' "Hello World"'}
		])
		tokenize("""
			# "hiya world"
			"#wassup world?" # hashes within strings
			# "Hello World"
		""").to([
			{type: "comment", value: ' "hiya world"'}
			{type: "string", value: "#wassup world?"}
			{type: "comment", value: ' hashes within strings'}
			{type: "comment", value: ' "Hello World"'}
		])
	
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
		# which btw shouldn't be the end of the token (although that would be good to have additionally)


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

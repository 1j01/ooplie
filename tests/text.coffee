
{expect} = require "chai"
{Context} = require "../src/ooplie.coffee"

context = new Context

evaluate = (expression)->
	to: expect(context.eval(expression)).to.eql

suite "strings", ->
	test "simple strings", ->
		evaluate('"Hello World"').to("Hello World")
		evaluate("'Hello World'").to("Hello World")
	test "escaping quotes", ->
		evaluate("\"I said \\\"Good day!\\\"").to("Hello World")
		evaluate("'I said \"Good day!\"'").to("Hello World")
	test "escaping backslashes", ->
		evaluate('"Backslashes look like this: \\\\"').to('"Backslashes look like this: \\"')
		evaluate("'Backslashes look like this: \\\\'").to("'Backslashes look like this: \\'")
		# Backslashes look like this: https://en.wikipedia.org/wiki/Leaning_toothpick_syndrome
	test "unicode"
	test "special escape characters", ->
		evaluate("'\\n'").to("\n")
		evaluate("'\\r'").to("\r")
		evaluate("'\\b'").to("\b")
		evaluate("'\\t'").to("\t")
		evaluate("'\\v'").to("\v")
		evaluate("'\\0'").to("\0")
	test "unicode escape characters"
	test "string concatenation", ->
		evaluate('"Hello " "World"').to("Hello World")
		# or maybe two different concatenation operations based on the presence of whitespace
		evaluate('"Hello ""World"').to("Hello World") # "Hello "+"World"
		evaluate('"Hello"" ""World"').to("Hello World") # "Hello"+" "+"World"
		evaluate('"Hello" "World"').to("Hello World") # Hello + World with space added automatically
	test "string concatenation with numbers", ->
		context.eval("iterations = 1024")
		evaluate("'Completed 'iterations' iterations'").to("Completed 1024 iterations")
	test "string concatenation with nully values", ->
		# have to decide which nully values we actually want to have
		# null? nil? undefined? unknown? nothing? notta? "the lack of anything in particular"?
		evaluate('"Hello World" null').to("Hello World")

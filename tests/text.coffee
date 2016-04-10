
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "strings", ->
	test "simple strings", ->
		evaluate('"Hello World"').to("Hello World")
		evaluate("'Hello World'").to("Hello World")
	test "multiline strings", ->
		evaluate('"Hello\nWorld"').to("Hello\nWorld")
		evaluate("'Hello\nWorld'").to("Hello\nWorld")
		evaluate("""
			'
			Hello
			World
			'
		""").to("Hello\nWorld")
		evaluate("""
			'
				Hello
				World
			'
		""").to("Hello\nWorld")
		evaluate("""
			'
				
				Hello
				World
				
			'
		""").to("\nHello\nWorld\n")
		evaluate("""
			'
				Hello
					World
			'
		""").to("Hello\n\tWorld")
		evaluate("""
			'
				Hello
				 World
			'
		""").to("Hello\n World")
		evaluate("""
			'
					Hello
					World
			'
		""").to("\tHello\n\tWorld")
	test "escaping quotes", ->
		evaluate('"I said \\\"Good day!\\""').to('I said "Good day!"')
		evaluate("'I said \\\'Good day!\\''").to("I said 'Good day!'")
	test "escaping backslashes", ->
		evaluate('"Backslashes look like this: \\\\"').to('Backslashes look like this: \\')
		evaluate("'Backslashes look like this: \\\\'").to("Backslashes look like this: \\")
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
	test.skip "string concatenation", ->
		evaluate('"Hello " "World"').to("Hello World")
		# or maybe two different concatenation operations based on the presence of whitespace
		evaluate('"Hello ""World"').to("Hello World") # "Hello "+"World"
		evaluate('"Hello"" ""World"').to("Hello World") # "Hello"+" "+"World"
		evaluate('"Hello" "World"').to("Hello World") # Hello + World with space added automatically
		# but that's probably too complicated
	test.skip "string concatenation with numbers", ->
		evaluate("'Completed '5' iterations'").to("Completed 5 iterations")
		context.eval("iterations = 1024")
		evaluate("'Completed 'iterations' iterations'").to("Completed 1024 iterations")
		evaluate("iterations' iterations'").to("1024 iterations")
		evaluate("'Completed 'iterations").to("Completed 1024")
	test.skip "string concatenation with nully values", ->
		# have to decide which nully values we actually want to have
		# null? nil? undefined? unknown? nothing? notta? "the lack of anything in particular"?
		evaluate('"Hello World" null').to("Hello World")

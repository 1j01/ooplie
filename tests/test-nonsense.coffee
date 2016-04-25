
{expect} = require?("chai") ? chai
{Context, Range} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "nonsense", ->
	test.skip "gibberish argument", ->
		expect(->
			context.eval("say sdfsdfj")
			# currently this fails because there's no console to log to,
			# but it should probably show this error first and foremost anyways
		).to.throw("I don't understand `sdfsdfj`")
	
	test.skip "consecutive numbers", ->
		expect(->
			context.eval("5 10")
		).to.throw("consecutive numbers")
		expect(->
			context.eval("'but I\\'m' 5 10 'doing concatenation!'")
		).to.throw("consecutive numbers")
	
	test.skip "mixed multiple comparison", ->
		expect(->
			context.eval("a <= b = c")
		).to.throw("multiple comparison mismatch")
		expect(->
			context.eval("a = b >= c")
		).to.throw("multiple comparison mismatch")
		expect(->
			context.eval("a < b > c")
		).to.throw("multiple comparison mismatch")
	
	test.skip "type mismatch", ->
		expect(->
			context.eval('5 - "LUL"')
		).to.throw("type mismatch")
		expect(->
			context.eval('"derp"^2')
		).to.throw("type mismatch")
	
	test.skip "unexpected end of input", ->
		expect(->
			context.eval('5 +')
		).to.throw("binary operator at end")
		expect(->
			context.eval('5 + 3 *')
		).to.throw("binary operator at end")
		expect(->
			context.eval('5 + 3 * -')
		).to.throw("unary operator at end")
		expect(->
			context.eval('3 tho')
		).to.throw("3 tho?")
		expect(->
			context.eval('3(')
		).to.throw("missing ending parenthesis")
		expect(->
			context.eval('3}')
		).to.throw("unexpected ending curly bracket")
		expect(->
			context.eval('3\\')
		).to.throw("backslash what?")
		expect(->
			context.eval('3|')
		).to.throw("what is this pipe you speak of?")
	
	test.skip "missing left operand", ->
		expect(->
			context.eval('^2')
		).to.throw("missing left operand for `^`")
		expect(->
			context.eval('* 2')
		).to.throw("missing left operand for `*`")
		# is this supposed to be a bulleted list?
	
	test.skip "unknown variable as left operand", ->
		expect(->
			context.eval('a + 5')
		).to.throw("I don't understand `a`")
		# or better yet "`a` is not defined" (in this case, which you probably can't distinguish from anything else)
	
	test.skip "unknown operators", ->
		expect(->
			context.eval('5 $ 2')
		).to.throw("unknown binary operator?")
		expect(->
			context.eval('5 ! 2')
		).to.throw("is this a binary operator I don't know about?")
	
	test.skip "incrementing number literals", ->
		expect(->
			context.eval("2.345++")
		).to.throw("um")
		expect(->
			context.eval("2.345--")
		).to.throw("um")
		expect(->
			context.eval("--2.345")
		).to.throw("um")
		expect(->
			context.eval("++2.345")
		).to.throw("um")
	
	test.skip "obfuscation of order of operations", ->
		# throw style error when whitespace obfuscates order of operations
		expect(->
			evaluate("3 * 6-1").to(3 * 6 - 1) 
		).to.throw("Spacing does not match the order of operations")
		# but not when it enforces it
		evaluate("3*6 - 1").to(3 * 6 - 1)
		# definitely throw here
		expect(->
			evaluate("1+3 ^ 3*2").to(55)
		).to.throw("Spacing does not match the order of operations. Add parentheses if you want it to behave how it looks. Otherwise, fix the whitespace.")
		# that's more like it
		evaluate("1 + 3^3 * 2").to(55)
		
		# throw style error / warning for exponents with whitespace?
		# expect(->
		# 	evaluate("1 + 3 ^ 3 * 2").to(55) 
		# ).to.throw("Unexpected whitespace around exponent")
		# ).to.throw("Bad whitespace around exponent; plz remove")
	
	test.skip "bad units", ->
		# you know, like percent meters
		expect(->
			context.eval('100% meters')
		).to.throw("unit doesn't make sense")

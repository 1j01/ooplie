
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
			evaluate("say sdfsdfj")
			# currently this fails because there's no console to log to,
			# but it should probably show this error first and foremost anyways
		).to.throw("I don't understand `sdfsdfj`")
	
	test.skip "consecutive numbers", ->
		expect(->
			evaluate("5 10")
		).to.throw("consecutive numbers")
		expect(->
			evaluate("'but I\\'m' 5 10 'doing concatenation!'")
		).to.throw("consecutive numbers")
	
	test.skip "mixed multiple comparison", ->
		expect(->
			evaluate("a <= b = c")
		).to.throw("multiple comparison mismatch")
		expect(->
			evaluate("a = b >= c")
		).to.throw("multiple comparison mismatch")
		expect(->
			evaluate("a < b > c")
		).to.throw("multiple comparison mismatch")
	
	test.skip "type mismatch", ->
		expect(->
			evaluate('5 - "LUL"')
		).to.throw("type mismatch")
		expect(->
			evaluate('"derp"^2')
		).to.throw("type mismatch")
	
	test.skip "unexpected end of input", ->
		expect(->
			evaluate('5 +')
		).to.throw("binary operator at end")
		expect(->
			evaluate('5 + 3 *')
		).to.throw("binary operator at end")
		expect(->
			evaluate('5 + 3 * -')
		).to.throw("unary operator at end")
		expect(->
			evaluate('3 tho')
		).to.throw("3 tho?")
		expect(->
			evaluate('3(')
		).to.throw("missing ending parenthesis")
		expect(->
			evaluate('3}')
		).to.throw("unexpected ending curly bracket")
		expect(->
			evaluate('3\\')
		).to.throw("backslash what?")
		expect(->
			evaluate('3|')
		).to.throw("what is this pipe you speak of?")
	
	test.skip "missing left operand", ->
		expect(->
			evaluate('^2')
		).to.throw("missing left operand for `^`")
		expect(->
			evaluate('* 2')
		).to.throw("missing left operand for `*`")
		# is this supposed to be a bulleted list?
	
	test.skip "unknown operators", ->
		expect(->
			evaluate('5 $ 2')
		).to.throw("unknown binary operator?")
		expect(->
			evaluate('5 $ 2')
		).to.throw("is this a binary operator I don't know about?")
	
	test.skip "nonsense units", ->
		expect(->
			evaluate('100% meters')
		).to.throw("unit doesn't make sense")
	
		
		

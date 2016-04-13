
{expect} = require?("chai") ? chai
{Pattern, tokenize} = require?("../src/ooplie.coffee") ? @Ooplie

tokens_eql = (tokens_a, tokens_b)->
	stripped_tokens_a = ({type, value} for {type, value} in tokens_a)
	stripped_tokens_b = ({type, value} for {type, value} in tokens_b)
	expect(stripped_tokens_a).to.eql(stripped_tokens_b)

suite "Pattern", ->
	
	test "should throw error when given duplicated variable names", ->
		expect(->
			new Pattern
				match: [
					"<expression> + <expression>"
					"<expression> plus <expression>"
				]
				fn: ({a, b})=>
					@eval_expression(a) + @eval_expression(b)
		).to.throw("Variable name `expression` used twice in pattern `<expression> + <expression>`")
	
	test "matching words ", ->
		pattern = new Pattern
			match: [
				"hey ho"
				"woah ho"
			]
		expect(pattern.match(tokenize("hey ho"))).to.be.ok
		expect(pattern.match(tokenize("woah ho"))).to.be.ok
		expect(pattern.match(tokenize("heave ho"))).not.to.be.ok
		expect(pattern.match(tokenize("woah there"))).not.to.be.ok
		expect(pattern.match(tokenize("hey now"))).not.to.be.ok
	
	test "matching variables ", ->
		pattern = new Pattern
			match: [
				"<a> + <b>"
				"<a> plus <b>"
			]
		
		expect(pattern.match(tokenize("a + b"))).to.be.ok
		expect(pattern.match(tokenize("a plus b"))).to.be.ok
		expect(pattern.match(tokenize("a plus b * c"))).to.be.ok
		expect(pattern.match(tokenize("a^2 + b^3"))).to.be.ok
		expect(pattern.match(tokenize("a^2 - b^3"))).not.to.be.ok
		expect(pattern.match(tokenize("a +"))).not.to.be.ok
		tokens_eql(pattern.match(tokenize("2a + 4b")).a, tokenize("2a"))
		tokens_eql(pattern.match(tokenize("2a + 4b")).b, tokenize("4b"))
	
	test "greater than / less than", ->
		pattern = new Pattern
			match: [
				"<a> < <b>"
				"<a> <= <b>"
				"<a> > <b>"
				"<a> >= <b>"
			]
		expect(pattern.match(tokenize("a < b"))).to.be.ok
		expect(pattern.match(tokenize("a <= b"))).to.be.ok
		expect(pattern.match(tokenize("a > b"))).to.be.ok
		expect(pattern.match(tokenize("a >= b"))).to.be.ok
		expect(pattern.match(tokenize("a = b"))).not.to.be.ok
	
	test "bad matches", ->
		pattern = new Pattern
			match: [
				"<a> is greater than <b>"
			]
			bad_match: [
				"<a> is more than <b>"
			]
		expect(pattern.match(tokenize("a is greater than b"))).to.be.ok
		expect(pattern.match(tokenize("a is greater than b")).bad).not.to.be.true
		expect(pattern.match(tokenize("a is more than b"))).to.be.ok # but not really okay
		expect(pattern.match(tokenize("a is more than b")).bad).to.be.true # because it's bad
	
	test "near matches"
	
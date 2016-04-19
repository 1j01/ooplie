
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
	
	test "matching words", ->
		pattern = new Pattern
			match: [
				"hey ho"
				"woah ho"
			]
		expect(pattern.match(tokenize("hey ho"))).to.exist
		expect(pattern.match(tokenize("woah ho"))).to.exist
		expect(pattern.match(tokenize("heave ho"))).not.to.exist
		expect(pattern.match(tokenize("woah there"))).not.to.exist
		expect(pattern.match(tokenize("hey now"))).not.to.exist
	
	test "matching variables", ->
		pattern = new Pattern
			match: [
				"<a> + <b>"
				"<a> plus <b>"
			]
		
		expect(pattern.match(tokenize("a + b"))).to.exist
		expect(pattern.match(tokenize("a plus b"))).to.exist
		expect(pattern.match(tokenize("a plus b * c"))).to.exist
		expect(pattern.match(tokenize("a^2 + b^3"))).to.exist
		expect(pattern.match(tokenize("a^2 - b^3"))).not.to.exist
		expect(pattern.match(tokenize("a +"))).not.to.exist
		tokens_eql(pattern.match(tokenize("2a + 4b")).a, tokenize("2a"))
		tokens_eql(pattern.match(tokenize("2a + 4b")).b, tokenize("4b"))
	
	test "matching case-insensitive", ->
		pattern = new Pattern
			match: [
				"If <a> then <b>"
			]
		
		expect(pattern.match(tokenize("If a then b"))).to.exist
		expect(pattern.match(tokenize("if a then b"))).to.exist
		expect(pattern.match(tokenize("IF a THEN b"))).to.exist
	
	test "matching indented blocks", ->
		pattern = new Pattern
			match: [
				"If <a>, <b> else <c>"
			]
		
		match = pattern.match(tokenize("""
			If a,
				If x, y else z
			else
				c
		"""))
		expect(match).to.exist
		tokens_eql(match.a, tokenize("a"))
		tokens_eql(match.b, [].concat(
			{type: "indent", value: "\t"}
			tokenize("If x, y else z")
			{type: "newline", value: "\n"}
			{type: "dedent", value: ""}
		))
		tokens_eql(match.c, [].concat(
			{type: "indent", value: "\t"}
			{type: "word", value: "c"}
			{type: "dedent", value: ""}
		))
	
	test "greater than / less than", ->
		pattern = new Pattern
			match: [
				"<a> < <b>"
				"<a> <= <b>"
				"<a> > <b>"
				"<a> >= <b>"
			]
		expect(pattern.match(tokenize("a < b"))).to.exist
		expect(pattern.match(tokenize("a <= b"))).to.exist
		expect(pattern.match(tokenize("a > b"))).to.exist
		expect(pattern.match(tokenize("a >= b"))).to.exist
		expect(pattern.match(tokenize("a = b"))).not.to.exist
	
	test "greater than / less than alone", ->
		pattern = new Pattern
			match: [
				"<"
				"<="
				">"
				">="
			]
		expect(pattern.match(tokenize("<"))).to.exist
		expect(pattern.match(tokenize("<="))).to.exist
		expect(pattern.match(tokenize(">"))).to.exist
		expect(pattern.match(tokenize(">="))).to.exist
		expect(pattern.match(tokenize("="))).not.to.exist
	
	test "bad matches", ->
		pattern = new Pattern
			match: [
				"<a> is greater than <b>"
			]
			bad_match: [
				"<a> is more than <b>"
			]
		expect(pattern.match(tokenize("a is greater than b"))).to.exist
		expect(pattern.match(tokenize("a is more than b"))).not.to.exist
		expect(pattern.bad_match(tokenize("a is greater than b"))).not.to.exist
		expect(pattern.bad_match(tokenize("a is more than b"))).to.exist
	
	test "bad pattern syntax", ->
		expect(->
			pattern = new Pattern
				match: [
					"<a> is less than <b<"
				]
		).to.throw("`<` within variable name in pattern `<a> is less than <b<`")
	
	test "allowed variable names", ->
		pattern = new Pattern
			match: [
				"<alt_body> wut <alt-body-2>"
				"<aaa$_> ills <bah;)>"
			]
		
		expect(pattern.match(tokenize("a way ills bee"))).to.exist
		tokens_eql(pattern.match(tokenize("a way wut bee"))["alt_body"], tokenize("a way"))
		tokens_eql(pattern.match(tokenize("a way wut bee"))["alt-body-2"], tokenize("bee"))
		tokens_eql(pattern.match(tokenize("a way ills bee"))["aaa$_"], tokenize("a way"))
		tokens_eql(pattern.match(tokenize("a way ills bee"))["bah;)"], tokenize("bee"))
	
	test "near matches"
	
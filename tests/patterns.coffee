
{expect} = require?("chai") ? chai
{Pattern} = require?("../src/ooplie.coffee") ? @Ooplie

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
	
	test "greater than / less than", ->
		console.log new Pattern
			match: [
				"<a> < <b>"
				"<a> <= <b>"
				"<a> > <b>"
				"<a> = <b>"
			]
			fn: ({a, b})=>
				@eval_expression(a) + @eval_expression(b)

	test "matching"
	test "bad matching"
	test "near matching"
	